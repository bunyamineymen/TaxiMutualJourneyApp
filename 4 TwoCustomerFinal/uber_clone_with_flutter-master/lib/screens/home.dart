import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/states/app_state.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Map());
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  bool timeOfSetTaxiLocation;
  bool timeOfSetTaxiTarget;
  bool timeOfSetCustomerLocation;
  bool timeOfSetCustomerTarget;

  LatLng taxiLocation;
  LatLng taxiTarget;
  LatLng customerLocation;
  LatLng customerTarget;

  bool taxiLocationIsHere;
  bool taxiTargetIsHere;
  bool customerLocationIsHere;
  bool customerTargetIsHere;

  double wasteOfTimeTaxi;
  double wasteOfDistanceTaxi;
  double wasteOfTimeCustomer;
  double wasteOfDistanceCustomer;

  String wasteOfTimeTaxiText;
  String wasteOfDistanceTaxiText;
  String wasteOfTimeCustomerText;
  String wasteOfDistanceCustomerText;

  void deleteAllMarkerMethod() {
    setState(() {
      timeOfSetTaxiLocation = false;
      timeOfSetTaxiTarget = false;
      timeOfSetCustomerLocation = false;
      timeOfSetCustomerTarget = false;

      taxiLocationIsHere = false;
      taxiTargetIsHere = false;
      customerLocationIsHere = false;
      customerTargetIsHere = false;

      taxiLocation = null;
      taxiTarget = null;
      customerLocation = null;
      customerTarget = null;
    });
  }

  void tapMap(AppState _appState, LatLng _location) {
    if (timeOfSetTaxiLocation) {
      taxiLocation = _location;

      _appState.addMarkerForTouch(_location, "taxilocation");

      setState(() {
        taxiLocationIsHere = true;
      });
    } else if (timeOfSetTaxiTarget) {
      taxiTarget = _location;

      _appState.addMarkerForTouch(_location, "taxitarget");

      setState(() {
        taxiTargetIsHere = true;
      });
    } else if (timeOfSetCustomerLocation) {
      customerLocation = _location;

      _appState.addMarkerForTouch(_location, "customerlocation");

      setState(() {
        customerLocationIsHere = true;
      });
    } else if (timeOfSetCustomerTarget) {
      customerTarget = _location;

      _appState.addMarkerForTouch(_location, "customertarget");

      setState(() {
        customerTargetIsHere = true;
      });
    }

    timeOfSetTaxiLocation = false;
    timeOfSetTaxiTarget = false;
    timeOfSetCustomerLocation = false;
    timeOfSetCustomerTarget = false;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      timeOfSetTaxiLocation = false;
      timeOfSetTaxiTarget = false;
      timeOfSetCustomerLocation = false;
      timeOfSetCustomerTarget = false;

      taxiLocationIsHere = false;
      taxiTargetIsHere = false;
      customerLocationIsHere = false;
      customerTargetIsHere = false;
    });
  }

  void showAlertDialogOnOkCallback(String title, String msg,
      DialogType dialogType, BuildContext context, VoidCallback onOkPress) {
    AwesomeDialog(
      context: context,
      animType: AnimType.TOPSLIDE,
      dialogType: dialogType,
      tittle: title,
      desc: msg,
      btnOkIcon: Icons.check_circle,
      btnOkColor: Colors.green.shade900,
      btnOkOnPress: onOkPress,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return SafeArea(
      child: appState.initialPosition == null
          ? Container(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitRotatingCircle(
                      color: Colors.black,
                      size: 50.0,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: appState.locationServiceActive == false,
                  child: Text(
                    "Please enable location services!",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
              ],
            ))
          : Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: appState.initialPosition, zoom: 10.0),
                  onMapCreated: appState.onCreated,
                  myLocationEnabled: true,
                  mapType: MapType.terrain,
                  compassEnabled: true,
                  markers: appState.markers,
                  onCameraMove: appState.onCameraMove,
                  polylines: appState.polyLines,
                  onTap: (location) {
                    tapMap(appState, location);
                  },
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                ),
                Positioned(
                  bottom: 45.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: Container(
                        color: Colors.grey,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 5,
                            ),
                            (!timeOfSetTaxiLocation)
                                ? new SizedBox(
                                    width: 70.0,
                                    height: 100.0,
                                    child: RaisedButton(
                                      child: Text(
                                        "T Loc",
                                        style: TextStyle(
                                            color: ((taxiLocationIsHere)
                                                ? Colors.blue
                                                : Colors.black)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          timeOfSetTaxiLocation = true;
                                        });
                                      },
                                      color: Colors.grey[50],
                                      textColor: Colors.yellow,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      splashColor: Colors.grey,
                                    ))
                                : CircularProgressIndicator(),
                            SizedBox(
                              width: 5,
                            ),
                            (!timeOfSetTaxiTarget)
                                ? new SizedBox(
                                    width: 70.0,
                                    height: 100.0,
                                    child: RaisedButton(
                                      child: Text(
                                        "T Tar",
                                        style: TextStyle(
                                            color: ((taxiTargetIsHere)
                                                ? Colors.blue
                                                : Colors.black)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          timeOfSetTaxiTarget = true;
                                        });
                                      },
                                      color: Colors.grey[50],
                                      textColor: Colors.yellow,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      splashColor: Colors.grey,
                                    ))
                                : CircularProgressIndicator(),
                            SizedBox(
                              width: 5,
                            ),
                            (!timeOfSetCustomerLocation)
                                ? new SizedBox(
                                    width: 70.0,
                                    height: 100.0,
                                    child: RaisedButton(
                                      child: Text(
                                        "C Loc",
                                        style: TextStyle(
                                            color: ((customerLocationIsHere)
                                                ? Colors.blue
                                                : Colors.black)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          timeOfSetCustomerLocation = true;
                                        });
                                      },
                                      color: Colors.grey[50],
                                      textColor: Colors.yellow,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      splashColor: Colors.grey,
                                    ))
                                : CircularProgressIndicator(),
                            SizedBox(
                              width: 5,
                            ),
                            (!timeOfSetCustomerTarget)
                                ? new SizedBox(
                                    width: 70.0,
                                    height: 100.0,
                                    child: RaisedButton(
                                      child: Text(
                                        "C Tar",
                                        style: TextStyle(
                                            color: ((customerTargetIsHere)
                                                ? Colors.blue
                                                : Colors.black)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          timeOfSetCustomerTarget = true;
                                        });
                                      },
                                      color: Colors.grey[50],
                                      textColor: Colors.yellow,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      splashColor: Colors.grey,
                                    ))
                                : CircularProgressIndicator(),
                          ],
                        ),
                      )),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    color: Colors.grey,
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        SizedBox(
                          width: 15,
                        ),
                        ProgressButton(
                          progressWidget: const CircularProgressIndicator(),
                          width: 140,
                          height: 40,
                          onPressed: () async {
                            if (taxiLocationIsHere ||
                                taxiTargetIsHere ||
                                customerLocationIsHere ||
                                customerTargetIsHere) {
                              appState
                                  .createMainRoute(taxiLocation, taxiTarget,
                                      customerLocation, customerTarget)
                                  .then((val) async {
                                wasteOfTimeTaxi = val['wasteOfTimeTaxi'] / 60;

                                wasteOfTimeTaxiText =
                                    wasteOfTimeTaxi.toStringAsFixed(2);

                                wasteOfDistanceTaxi =
                                    val['wasteOfDistanceTaxi'] / 1000;

                                wasteOfDistanceTaxiText =
                                    wasteOfDistanceTaxi.toStringAsFixed(2);

                                wasteOfTimeCustomer =
                                    val['wasteOfTimeCustomer'] / 60;

                                wasteOfTimeCustomerText =
                                    wasteOfTimeCustomer.toStringAsFixed(2);

                                wasteOfDistanceCustomer =
                                    val['wasteOfDistanceCustomer'] / 1000;

                                wasteOfDistanceCustomerText =
                                    wasteOfDistanceCustomer.toStringAsFixed(2);

                                AwesomeDialog(
                                  context: context,
                                  animType: AnimType.SCALE,
                                  customHeader: Icon(
                                    Icons.face,
                                    size: 50,
                                  ),
                                  tittle: 'Lose Of Customer',
                                  desc:
                                      'wasteOfTimeTaxi: $wasteOfTimeTaxiText dk \n wasteOfDistanceTaxi: $wasteOfDistanceTaxiText  km \n wasteOfTimeCustomer : $wasteOfTimeCustomerText dk \n wasteOfDistanceCustomer: $wasteOfDistanceCustomerText km',
                                  btnOk: FlatButton(
                                    child: Text('Custom Button'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  btnOkOnPress: () {},
                                ).show();
                              });
                            }

                            await Future.delayed(Duration(seconds: 2));

                            return () {};
                          },
                          defaultWidget: Text(
                            'Calculate',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        ProgressButton(
                          progressWidget: const CircularProgressIndicator(),
                          width: 140,
                          height: 40,
                          onPressed: () async {
                            int score = await Future.delayed(
                                const Duration(milliseconds: 1000), () => 42);
                            deleteAllMarkerMethod();
                            appState.deleteAllMarker();

                            return () {};
                          },
                          defaultWidget: const Text(
                            'CLEAN',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
