import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/Map/map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../map_panel_widget.dart';
import '../navbar/drawer_nav.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../networkHelper_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  //for holding starting and destination points
  Map<String, Marker> myMarkers = {};
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];
  //for knowing if starting point or destination point is selected
  var currentIndex = null;
  var data;
  var roadInfo;
  var userLocationAuthorized =
      false; //to check if user authorizes to display his/her current location
  var currentLocation;
  var startingPointPlaced = false;
  // var startCoordinates = null;
  var startLocation;
  var destinationPointPlaced = false;
  // var destCoordinates = null;
  var destination;

  //for managing onTap method on grey bar to up the sliding panel
  final panelController = PanelController();
  //variables to store user location data
  var _latitude = "";
  var _longitude = "";
  var _altitude = "";
  var _speed = "";
  var _address = "";

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.4;
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.08;
    _updatePosition();
    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: Text(
          'Map',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(53, 66, 74, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(53, 66, 74, 1)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(alignment: Alignment.topCenter, children: <Widget>[
        SlidingUpPanel(
          controller:
              panelController, //used for managing onTap method to control sliding up
          maxHeight: panelHeightOpen,
          minHeight: panelHeightClosed,
          //for making the map following (moving) when sliding up or down
          parallaxEnabled: true,
          parallaxOffset: 0.4,
          panelBuilder: () => PanelWidget(
            panelController: panelController,
            roadInfo: roadInfo,
            startLocation: startLocation,
            destination: destination,
            polyPoints: polyPoints,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          body: Center(
            child: Container(
              child: map(
                  myMarkers: myMarkers,
                  polyPoints: polyPoints,
                  handleTap: _handleTap),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: buildStartDestButton(),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: buildRoadProblemButton(),
        )
      ]),
    );
  }

//managing the adding of start and end point of route when tapped on the map
  _handleTap(LatLng tappedPoint) async {
    //currentIndex is set in this code, according to user's action.
    // if == null : user should be free to tap on map without trigger an action except closing the slider
    if (currentIndex == null) {
      if (panelController.isPanelOpen) {
        panelController.close();
      }
      return;
    }

    // myMarkers = [];
    var markersSizeControl = 0;
    // Adaptations required if currentLocation is activated (true)
    if (userLocationAuthorized) {
      markersSizeControl =
          1; //adapt the sizeControl variable because myMarkers already contains the currentLocation's marker (at index 0)

      //The "route editing" works with "myMarkers.first" as starting point and "myMarkers.last" as destination.
      //Meaning the start point HAS TO BE AT INDEX 0 and the destination point HAS TO BE the LAST marker in myMarkers list
    }

    if (currentIndex == 0) {
      //meaning we are adding a starter point
      startingPointPlaced = true;
      // extract the location from coordinates (geocoding API)
      List<Placemark> startMarks = await placemarkFromCoordinates(
          tappedPoint.latitude, tappedPoint.longitude);
      startLocation = startMarks.first;

      if (myMarkers.length > markersSizeControl) {
        myMarkers.remove("start");
        //.removeAt(currentIndex); //starting point is always at index 0
      }

      myMarkers["start"] = (
          // currentIndex, //has to be inserted at index 0
          Marker(
        point: tappedPoint,
        builder: (context) => Icon(
          FontAwesomeIcons.locationDot,
          color: Color.fromRGBO(0, 181, 107, 1),
          size: 35,
        ),
        // key: Key("start"),
        anchorPos: AnchorPos.align(AnchorAlign.top),
        rotate: true,
      ));
      print(tappedPoint.toString());
    }
    //placing destination
    if (currentIndex == 1) {
      destinationPointPlaced = true;
      //extract destination locality
      List<Placemark> destinationMarks = await placemarkFromCoordinates(
          tappedPoint.latitude, tappedPoint.longitude);
      destination = destinationMarks.first;

      if (myMarkers.length > markersSizeControl + 1) {
        myMarkers.remove("end");
        //.removeAt(pointIndex);
      }
      myMarkers["end"] = (
          //pointIndex, // has to be inserted either at index 1 or 2
          Marker(
              point: tappedPoint,
              builder: (context) => Icon(
                    FontAwesomeIcons.crosshairs,
                    color: Colors.redAccent,
                    size: 30,
                  ),
              rotate: true
              // key: Key("end"),
              ));
    }

    // this part handle that addition of warning markers either by an admin or a normal user
    if (currentIndex == 2) {
      // =============================================
      // MAYBE NOT MANDATORY. SHOULD BE CHECKED
      startingPointPlaced = false;
      destinationPointPlaced = false;

      //extract destination locality
      List<Placemark> destinationMarks = await placemarkFromCoordinates(
          tappedPoint.latitude, tappedPoint.longitude);
      destination = destinationMarks.first;
      // =============================================
      DateTime current_date = DateTime.now();
      var warningMarkerName = "Own_Warning_" + current_date.toString();

      myMarkers[warningMarkerName] = (
          //pointIndex, // has to be inserted either at index 1 or 2
          Marker(
        point: tappedPoint,
        builder: (context) => Icon(
          Icons.warning,
          color: Colors.deepOrange,
          size: 30,
        ),
        rotate: true,
        // key: Key("end"),
      ));
    }

    getJsonData();
    _getTripInformation();
    setState(() {});
  }

  _getTripInformation() async {
    //drawing route using ORSM package
    if (myMarkers["start"] == null || myMarkers["end"] == null) {
      return;
    }
    var latStart = myMarkers["start"]!.point.latitude;
    var lngStart = myMarkers["start"]!.point.longitude;
    var latEnd = myMarkers["end"]!.point.latitude;
    var lngEnd = myMarkers["end"]!.point.longitude;

    List<LngLat> waypoints = [
      LngLat(lng: lngStart, lat: latStart),
      LngLat(lng: lngEnd, lat: latEnd)
    ];
    final manager = OSRMManager();
    roadInfo = await manager.getTrip(
        waypoints: waypoints,
        roundTrip: true,
        destination: DestinationGeoPointOption.last,
        source: SourceGeoPointOption.first,
        geometry: Geometries.geojson,
        steps: true,
        languageCode: "en");
  }

  /*largely inspired by Arafat Rohan's method, founded here: 
  https://medium.com/@rohanarafat86/drawing-route-direction-in-flutter-using-openrouteservice-api-and-google-maps-in-flutter-4431a2989dd5
  Git repository : https://github.com/ArafatRohan93/flutter-polyline-demo/blob/master/lib/main.dart
  */
  getJsonData() async {
    //check if both source and destination points are filled out. if not : return
    if (myMarkers["start"] == null || myMarkers["end"] == null) {
      print("not enough pins on the map");
      return;
    }

    //clean polyPoints data
    polyPoints.clear();

    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
      startLat: myMarkers["start"]!.point.latitude,
      startLng: myMarkers["start"]!.point.longitude,
      endLat: myMarkers["end"]!.point.latitude,
      endLng: myMarkers["end"]!.point.longitude,
    );

    try {
      // getData() returns a json Decoded data
      data = await network.getData();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      setState(() {});
    } catch (e) {
      print("Error on map_page, from method 'getJsonData()' : " + e.toString());
    }
  }

  buildRoadProblemButton() => SpeedDial(
          overlayOpacity: 0.5,
          renderOverlay: false,
          // animatedIcon: AnimatedIcons.menu_close,
          // icon: Icons.warning_amber,
          icon: Icons.warning,
          foregroundColor: Colors.deepOrange,
          activeIcon: Icons.close_rounded,
          backgroundColor: Colors.white70,
          direction: SpeedDialDirection.down,
          buttonSize: Size(40.0, 40.0),
          closeManually: true,
          onClose: () {
            currentIndex = null;
          },
          switchLabelPosition: true,
          children: [
            SpeedDialChild(
              child: Align(
                alignment: Alignment(0.0, 0.0),
                child: Icon(
                  Icons.warning,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              label: 'indicate a problem',
              backgroundColor: Colors.white70,
              onTap: () {
                currentIndex = 2;
              },
            ),
            SpeedDialChild(
              child: Align(
                alignment: Alignment(-0.1, 0.0),
                child: Icon(
                  FontAwesomeIcons.broom,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              label: 'clear my road problem markers',
              backgroundColor: Colors.deepOrange,
              onTap: () {
                clearOwnProblemMarkers();
              },
            ),
          ]);

  buildStartDestButton() => SpeedDial(
        tooltip: "Select a marker and place it on the map",
        overlayOpacity: 0.5,
        renderOverlay: false,
        // animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.location_on,
        activeIcon: Icons.close_rounded,
        backgroundColor: Color.fromRGBO(0, 181, 107, 1),
        direction: SpeedDialDirection.down,
        buttonSize: Size(50.0, 50.0),
        closeManually: true,
        onClose: () {
          currentIndex = null;
        },
        children: [
          SpeedDialChild(
            child: Icon(Icons.location_pin),
            label: 'Starting point',
            backgroundColor: Color.fromRGBO(0, 181, 107, 1),
            onTap: () {
              currentIndex = 0;
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.my_location_sharp),
            label: 'Destination',
            backgroundColor: Colors.redAccent,
            onTap: () {
              currentIndex = 1;
            },
          ),
          SpeedDialChild(
            child: Align(
              alignment: Alignment(0.0, 0.0),
              child: Icon(
                Icons.warning,
                color: Colors.deepOrange,
                size: 30,
              ),
            ),
            label: 'indicate a problem',
            backgroundColor: Colors.white70,
            onTap: () {
              currentIndex = 2;
            },
          ),
        ],
      );

  clearOwnProblemMarkers() {
    List<String> keysToRemove = [];
    myMarkers.forEach((key, value) {
      if (key.contains("Own")) keysToRemove.add(key);
    });
    keysToRemove.forEach((key) => myMarkers.remove(key));
  }

// ===================================
// update user's live-position
// ===================================
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
        rotate: true,
      );

      //adding the marker to list of markers
      // /!\ /!\ /!\
      // /!\ beware of repercussions on the indexes of the start and destination markers in handleTap method! /!\
      // /!\ /!\ /!\
      if (!startingPointPlaced) //meaning a starting point is saved
      {
        //   myMarkers.removeAt(1);
        //   myMarkers.insert(1, userLocationMarker); //so insert at index 1
        // } else {
        //   myMarkers.remove(0);
        //   myMarkers.insert(0, userLocationMarker);
        List<Placemark> startMarks = await placemarkFromCoordinates(
            currentLocation.latitude, currentLocation.longitude);
        startLocation = startMarks.first;
      }
      if (!destinationPointPlaced) {
        List<Placemark> startMarks = await placemarkFromCoordinates(
            currentLocation.latitude, currentLocation.longitude);
        destination = startMarks.first;
      }

      myMarkers["userLocation"] = userLocationMarker;
    }
    setState(() {});
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
}

//Create a new class to hold the Coordinates we have received from the response data
class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
