import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../navbar/drawer_nav.dart';
import '../networkHelper_map.dart';
import 'map.dart';
import 'map_page.dart';

class RouteMap extends StatefulWidget {
  RouteMap(String routeId, {super.key}) {
    this.routeId = routeId;
  }

  var routeId;

  @override
  State<RouteMap> createState() => _RouteMapState(routeId);
}

//This class will be used to display the map of the route and the user's location
class _RouteMapState extends State<RouteMap> {
  var routeId;

  String _latitude = "";
  String _longitude = "";
  String _altitude = "";
  String _speed = "";

  var userLocationAuthorized;

  var currentLocation;

  var startLocation;

  var destination;

  _RouteMapState(String routeId) {
    this.routeId = routeId;
  }

  //for holding starting and destination points
  Map<String, Marker> myMarkers = {};
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];

  @override
  Widget build(BuildContext context) {
    //_updatePosition();
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('Routes').doc(routeId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data.data() as Map<String, dynamic>;

            //adding starting point to the map
            myMarkers["start"] = Marker(
                width: 45.0,
                height: 45.0,
                point: LatLng(data['startLat'], data['startLong']),
                builder: (ctx) => Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 45,
                      ),
                    ));

            //adding destination point to the map
            myMarkers["end"] = Marker(
                width: 45.0,
                height: 45.0,
                point: LatLng(data['endLat'], data['endLong']),
                builder: (ctx) => Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 45,
                      ),
                    ));

            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    data['name'],
                    style: GoogleFonts.bebasNeue(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(53, 66, 74, 1)),
                  ),
                  iconTheme:
                      IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                ),
                drawer: DrawerNav(),
                body: FutureBuilder(
                    future: getJsonData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          child: map(
                              myMarkers: myMarkers,
                              polyPoints: polyPoints,
                              handleTap: _handleTap),
                        );
                      } else {
                        return Container(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    }));
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    "Loading",
                    style: GoogleFonts.bebasNeue(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(53, 66, 74, 1)),
                  ),
                  iconTheme:
                      IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                ),
                drawer: DrawerNav(),
                //loading screen
                body: Container(
                    child: Center(
                  child: CircularProgressIndicator(),
                )));
          }
        });
  }

  Future<void> _updatePosition() async {
    Position pos = await _determinePosition();

    //setState(() {
    _latitude = pos.latitude.toString();
    _longitude = pos.longitude.toString();
    _altitude = pos.altitude.toString();
    _speed = pos.speed.toString();
    //});

    if (userLocationAuthorized) {
      currentLocation = pos;

      Marker userLocationMarker = Marker(
        width: 30.0,
        height: 30.0,
        point: LatLng(currentLocation.latitude, currentLocation.longitude),
        builder: (ctx) => Container(
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 2.0,
            child: Icon(
              Icons.person,
              color: Colors.white54,
              size: 30.0,
            ),
          ),
        ),
      );

      myMarkers["userLocation"] = userLocationMarker;
    }
  }

//GPS - user location - code from https://pub.dev/packages/geolocator
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time user could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // the App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Modify control boolean
    userLocationAuthorized = true;
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator
        .getCurrentPosition(); //.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  _handleTap(LatLng tappedPoint) {
    print(tappedPoint);
  }

  getJsonData() async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format
    NetworkHelper network = NetworkHelper(
      startLat: myMarkers["start"]!.point.latitude,
      startLng: myMarkers["start"]!.point.longitude,
      endLat: myMarkers["end"]!.point.latitude,
      endLng: myMarkers["end"]!.point.longitude,
    );

    try {
      await _updatePosition();
      // getData() returns a json Decoded data
      var data = await network.getData();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      return polyPoints;
    } catch (e) {
      print("Error on map_page, from method 'getJsonData()' : " + e.toString());
    }
  }
}
