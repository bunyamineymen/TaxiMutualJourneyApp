import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = "AIzaSyDdE-Zf-lde27PunpxnY-cmKYXJ5G2FL1I";

class GoogleMapsServices {
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&traffic_model=best_guess&destination=${l2.latitude},${l2.longitude}&departure_time=now&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    //  print(values["routes"][0]["legs"][0]["distance"]["value"]);
    //  print(values["routes"][0]["legs"][0]["duration"]["value"]);

/*
    print(values["routes"][0]["legs"][0]["distance"]);
    print(values["routes"][0]["legs"][0]["duration"]);
*/
    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<Map> getDistanceCoordinates(
      LatLng startLocation, LatLng targetLocation) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startLocation.latitude},${startLocation.longitude}&traffic_model=best_guess&destination=${targetLocation.latitude},${targetLocation.longitude}&departure_time=now&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    // print(values["routes"][0]["legs"][0]["distance"]["value"]);
    //  print(values["routes"][0]["legs"][0]["duration"]["value"]);

/*
    print(values["routes"][0]["legs"][0]["distance"]);
    print(values["routes"][0]["legs"][0]["duration"]);
*/
    // return values["routes"][0]["overview_polyline"]["points"];

    return {
      'duration': values["routes"][0]["legs"][0]["duration"]["value"],
      'distance': values["routes"][0]["legs"][0]["distance"]["value"]
    };
  }
}
