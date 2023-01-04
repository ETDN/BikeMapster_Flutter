import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'map_panel_widget.dart';
import 'navbar/drawer_nav.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'networkHelper_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  //for holding starting and destination points
  List<Marker> myMarkers = [];
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];
  //for knowing if starting point or destination point is selected
  var currentIndex = null;
  var data;
  var roadInfo;
  //position of map when open it. May be modified according to customer settings (future improvement)
  LatLng mapCenterPosition = LatLng(46.2293518, 7.3620487);
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
            polyPoints: polyPoints,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          body: Center(
            child: Container(
              child: FlutterMap(
                options: MapOptions(
                  center: mapCenterPosition,
                  zoom: 10.0,
                  onTap: (tapPosition, point) => _handleTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://wmts20.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg",
                  ),
                  MarkerLayer(
                    markers: myMarkers,
                  ),
                  PolylineLayer(
                    polylineCulling: false,
                    polylines: [
                      Polyline(
                          points: polyPoints,
                          color: Colors.grey,
                          borderColor: Colors.deepPurpleAccent,
                          borderStrokeWidth: 4.0,
                          strokeCap: StrokeCap.round),
                    ], //polylines
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: buildStartDestButton(),
        )
      ]),
    );
  }

  // _changeMapType() {
  //   setState(() {
  //     // _currentMapType = _currentMapType == MapType.
  //   });
  // }

  _handleTap(LatLng tappedPoint) {
    if (currentIndex == null) {
      if (panelController.isPanelOpen) {
        panelController.close();
      }
      return;
    }
    setState(() {
      // myMarkers = [];
      if (currentIndex == 0) {
        if (myMarkers.length > 0) {
          myMarkers.removeAt(currentIndex);
        }
        myMarkers.insert(
          currentIndex,
          Marker(
            point: tappedPoint,
            builder: (context) => Icon(
              FontAwesomeIcons.locationDot,
              color: Color.fromRGBO(0, 181, 107, 1),
              size: 35,
            ),
            key: Key("start"),
            anchorPos: AnchorPos.align(AnchorAlign.top),
          ),
        );
        print(tappedPoint.toString());
      }
      if (currentIndex == 1) {
        if (myMarkers.length > 1) {
          myMarkers.removeAt(currentIndex);
        }
        myMarkers.insert(
          currentIndex,
          Marker(
            point: tappedPoint,
            builder: (context) => Icon(
              FontAwesomeIcons.crosshairs,
              color: Colors.redAccent,
              size: 30,
            ),
            key: Key("end"),
          ),
        );
      }
      getJsonData();
      _getTripInformation();
    });
  }

  _getTripInformation() async {
    //drawing route using ORSM package
    if (myMarkers.length != 2) {
      return;
    }
    var latStart = myMarkers.first.point.latitude;
    var lngStart = myMarkers.first.point.longitude;
    var latEnd = myMarkers.last.point.latitude;
    var lngEnd = myMarkers.last.point.longitude;

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

    print(roadInfo.toString());
  }

  /*largely inspired by Arafat Rohan's method, founded here: 
  https://medium.com/@rohanarafat86/drawing-route-direction-in-flutter-using-openrouteservice-api-and-google-maps-in-flutter-4431a2989dd5
  Git repository : https://github.com/ArafatRohan93/flutter-polyline-demo/blob/master/lib/main.dart
  */
  getJsonData() async {
    //check if both source and destination points are filled out. if not : return
    if (myMarkers.length != 2) {
      print("not enough pins on the map");
      return;
    }

    //clean polyPoints data
    polyPoints.clear();

    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format
    NetworkHelper network = NetworkHelper(
      startLat: myMarkers.first.point.latitude,
      startLng: myMarkers.first.point.longitude,
      endLat: myMarkers.last.point.latitude,
      endLng: myMarkers.last.point.longitude,
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
      print("Error on map page, from method 'getJsonData()' : " + e.toString());
    }
  }

  buildStartDestButton() => SpeedDial(
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
        ],
      );

// ===================================
// update user's live-position
// ===================================
  Future<void> _updatePosition() async {
    Position pos = await _determinePosition();
    // List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    setState(() {
      _latitude = pos.latitude.toString();
      _longitude = pos.longitude.toString();
      _altitude = pos.altitude.toString();
      _speed = pos.speed.toString();

      // _address = pm[0].toString();
    });
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

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator
        .getCurrentPosition(); //.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}

//Create a new class to hold the Co-ordinates we have received from the response data
class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
