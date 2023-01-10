import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/screens/Map/map_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'navbar/drawer_nav.dart';
import 'Map/map.dart';
import 'networkHelper_map.dart';

class EditRoute extends StatefulWidget {
  EditRoute({super.key, required String routeID}) {
    this.routeID = routeID;
  }
  String routeID = "";

  @override
  State<EditRoute> createState() => _EditRouteState(routeID);
}

class _EditRouteState extends State<EditRoute> {
  final nameController = TextEditingController();
  int length = 0;
  int duration = 0;
  String routeID = "";
  var routeName = "";
  var currentIndex = null;
  var data;
  var roadInfo;
  var startLat;
  var startLong;
  //LatLng start = LatLng(0, 0);
  //LatLng end = LatLng(0, 0);
  var endLat;
  var endLong;
  //for holding starting and destination points
  Map<String, Marker> myMarkers = {};
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];

  _EditRouteState(String routeID) {
    this.routeID = routeID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: const DrawerNav(),
        appBar: AppBar(
          title: Text(
            'Route Editing',
            style: GoogleFonts.bebasNeue(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Color.fromRGBO(53, 66, 74, 1)),
          ),
          iconTheme: IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('Routes')
                .doc(routeID)
                .get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> data =
                    snapshot.data.data() as Map<String, dynamic>;
                //set route name
                routeName = data['name'];
                //get starting and destination points
                startLat = data['startLat'];
                startLong = data['startLong'];
                endLat = data['endLat'];
                endLong = data['endLong'];
                //get route lenght and duration
                length = data['length'];
                duration = data['duration'];
                //set starting and destination points
                //start = LatLng(startLat, startLong);
                //end = LatLng(endLat, endLong);
                return buildBody();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Padding buildBody() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Edit the name of the route
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: routeName,
                ),
              ),
              //Submit button
              Container(
                  //padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                onPressed: () {
                  if (nameController.text != '' &&
                      polyPoints != null &&
                      roadInfo != null) {
                    //Get instance of the route from firebase and update it
                    startLat = myMarkers["start"]!.point.latitude;
                    startLong = myMarkers["start"]!.point.longitude;
                    endLat = myMarkers["end"]!.point.latitude;
                    endLong = myMarkers["end"]!.point.longitude;
                    FirebaseFirestore.instance
                        .collection('Routes')
                        .doc(routeID)
                        .update({
                      'name': nameController.text,
                      'startLat': startLat,
                      'startLong': startLong,
                      'endLat': endLat,
                      'endLong': endLong,
                      'length': roadInfo.distance.toInt(),
                      'duration': roadInfo.duration.toInt(),

                      //comfirmation message
                    }).then((value) => {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Route updated'))),
                              Navigator.pop(context)
                            });
                  } else
                    print("No name entered");
                },
                child: const Text('Submit'),
              )),
              Stack(
                //Stack for the map
                children: <Widget>[
                  Container(
                      //padding: const EdgeInsets.only(bottom: 16.0),
                      //maximize the map
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: map(
                          myMarkers: myMarkers,
                          polyPoints: polyPoints,
                          handleTap: handleTap)),
                  //Buttons for adding starting and destination points
                  Positioned(
                    right: 10,
                    top: 10,
                    child: buildStartDestButton(),
                  )
                ],
              )
            ]));
  }

  handleTap(LatLng tappedPoint) {
    if (currentIndex == null) {
      /*if (panelController.isPanelOpen) {
        panelController.close();
      }*/
      return;
    }
    setState(() {
      // myMarkers = [];
      if (currentIndex == 0) {
        if (myMarkers.length > 0) {
          myMarkers.remove("start");
        }
        myMarkers["start"] = (
            // currentIndex,
            Marker(
          point: tappedPoint,
          builder: (context) => Icon(
            FontAwesomeIcons.locationDot,
            color: Color.fromRGBO(0, 181, 107, 1),
            size: 35,
          ),
          // key: Key("start"),
          anchorPos: AnchorPos.align(AnchorAlign.top),
        ));
        print(tappedPoint.toString());
      }
      if (currentIndex == 1) {
        if (myMarkers.length > 1) {
          myMarkers.remove("end");
        }
        myMarkers["end"] = (
            // currentIndex,
            Marker(
          point: tappedPoint,
          builder: (context) => Icon(
            FontAwesomeIcons.crosshairs,
            color: Colors.redAccent,
            size: 30,
          ),
          key: Key("end"),
        ));
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
      startLat: myMarkers["start"]!.point.latitude,
      startLng: myMarkers["start"]!.point.longitude,
      endLat: myMarkers["start"]!.point.latitude,
      endLng: myMarkers["start"]!.point.longitude,
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
      print(e);
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
}
