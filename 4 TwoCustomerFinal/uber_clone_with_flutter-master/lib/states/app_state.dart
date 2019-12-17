import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/requests/google_maps_requests.dart';

class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  int followingIndexOfColor = 0;

  String casetext;

  AppState() {
    _getUserLocation();
    _loadingInitialPosition();
  }

  Future<Map> createMainRoute(LatLng taxiLocation, LatLng taxiTarget,
      LatLng customerLocation, LatLng customerTarget) async {
    Map mapA = await _googleMapsServices.getDistanceCoordinates(
        taxiLocation, customerLocation);

    Map mapB = await _googleMapsServices.getDistanceCoordinates(
        customerLocation, customerTarget);

    Map mapC = await _googleMapsServices.getDistanceCoordinates(
        customerLocation, taxiTarget);

    Map mapDForCustomer = await _googleMapsServices.getDistanceCoordinates(
        customerTarget, taxiTarget);

    Map mapDForTaxi = await _googleMapsServices.getDistanceCoordinates(
        taxiTarget, customerTarget);

    Map mapForTaxi = await _googleMapsServices.getDistanceCoordinates(
        taxiLocation, taxiTarget);

    int normalDistanceForTaxi = mapForTaxi['distance'];
    int normalDurationForTaxi = mapForTaxi['duration'];

    int distanceA = mapA['distance'];
    int distanceB = mapB['distance'];
    int distanceC = mapC['distance'];
    int distanceDForCustomer = mapDForCustomer['distance'];
    int distanceDForTaxi = mapDForTaxi['distance'];

    int durationA = mapA['duration'];
    int durationB = mapB['duration'];
    int durationC = mapC['duration'];
    int durationDForCustomer = mapDForCustomer['duration'];
    int durationDForTaxi = mapDForTaxi['duration'];

    int wasteOfTimeTaxi = 0;
    int wasteOfDistanceTaxi = 0;
    int wasteOfTimeCustomer = 0;
    int wasteOfDistanceCustomer = 0;

    int case1 = distanceA + distanceB + distanceDForCustomer;

    int case2 = distanceA + distanceC + distanceDForTaxi;

    if (case1 < case2) {
      // firstly customer

      casetext = "firstlycustomer";

      calculateBJKA(taxiLocation, taxiTarget, customerLocation, customerTarget);

      wasteOfTimeTaxi =
          (durationA + durationB + durationDForTaxi) - (normalDurationForTaxi);
      wasteOfDistanceTaxi =
          (distanceA + distanceB + distanceDForTaxi) - (normalDistanceForTaxi);
    } else {
      // firstly taxi

      casetext = "firstly taxi";

      calculateBJKB(taxiLocation, taxiTarget, customerLocation, customerTarget);

      wasteOfTimeCustomer =
          (durationA + durationC + durationDForCustomer) - (durationB);
      wasteOfDistanceCustomer =
          (distanceA + distanceC + distanceDForCustomer) - (distanceB);

      wasteOfTimeTaxi = (durationA + durationC) - (normalDurationForTaxi);

      wasteOfDistanceTaxi = (distanceA + distanceC) - (normalDistanceForTaxi);
    }

    return {
      'case': casetext,
      'wasteOfTimeTaxi': wasteOfTimeTaxi,
      'wasteOfDistanceTaxi': wasteOfDistanceTaxi,
      'wasteOfTimeCustomer': wasteOfTimeCustomer,
      'wasteOfDistanceCustomer': wasteOfDistanceCustomer
    };
  }

  void calculateBJKA(LatLng taxiLocation, LatLng taxiTarget,
      LatLng customerLocation, LatLng customerTarget) async {
    sendRequest(taxiLocation, customerLocation);

    sendRequest(customerLocation, customerTarget);

    sendRequest(customerTarget, taxiTarget);
  }

  void calculateBJKB(LatLng taxiLocation, LatLng taxiTarget,
      LatLng customerLocation, LatLng customerTarget) async {
    sendRequest(taxiLocation, customerLocation);

    sendRequest(customerLocation, taxiTarget);

    sendRequest(taxiTarget, customerTarget);
  }

  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

/*
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
*/

    _initialPosition = LatLng(position.latitude, position.longitude);

    /*
    locationController.text = placemark[0].name;
*/

    notifyListeners();
  }

  void createRoute(String encondedPoly, Color colorOfRoute, String id) {
    _polyLines.add(Polyline(
        consumeTapEvents: false,
        polylineId: PolylineId(id),
        width: 10,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: colorOfRoute));

    notifyListeners();
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  void deleteAllMarker() {
    _markers.clear();
    _polyLines.clear();
  }

  void deleteMarkerForTouch(String markername) {
    _markers.remove(Marker(
      markerId: MarkerId(markername),
    ));
  }

  void addMarkerForTouch(LatLng location, String markername) {
    deleteMarkerForTouch(markername);

    _markers.add(Marker(
        markerId: MarkerId(markername),
        position: location,
        infoWindow: InfoWindow(title: markername),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  void sendRequest(LatLng startLocation, LatLng endLocation) async {
    String route = await _googleMapsServices.getRouteCoordinates(
        startLocation, endLocation);

    Color colorOfLine;

    if (followingIndexOfColor == 0) {
      colorOfLine = Colors.red;
    } else if (followingIndexOfColor == 1) {
      colorOfLine = Colors.blue;
    } else {
      colorOfLine = Colors.green;
    }

    followingIndexOfColor++;

    createRoute(route, colorOfLine, colorOfLine.toString());
    notifyListeners();
  }

  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

//  LOADING INITIAL POSITION
  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }
}
