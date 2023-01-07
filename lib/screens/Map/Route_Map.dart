import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../navbar/drawer_nav.dart';
import '../networkHelper_map.dart';
import 'map.dart';
import 'map_page.dart';

class RouteMap extends StatefulWidget {
  var routeId;

  RouteMap(String routeId, {super.key}) {
    this.routeId = routeId;
  }

  @override
  State<RouteMap> createState() => _RouteMapState(routeId);
}

//This class will be used to display the map of the route and the user's location
class _RouteMapState extends State<RouteMap> {
  var routeId;
  _RouteMapState(String routeId) {
    this.routeId = routeId;
  }

  //for holding starting and destination points
  Map<String, Marker> myMarkers = {};
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];

  @override
  Widget build(BuildContext context) {
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

            //getting all points needed to draw the route
            //getJsonData();
            //_getTripInformation();

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
                        print(
                            "/////////////////////////////////////////////////////////////////////////////////");
                        return Container(
                          child: map(
                              myMarkers: myMarkers,
                              polyPoints: polyPoints,
                              handleTap: _handleTap),
                        );
                      } else {
                        return Container(
                          child: Text("Loading"),
                        );
                      }
                    }));
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text("Loading"),
              ),
              drawer: DrawerNav(),
              body: Container(
                child: Text("Loading"),
              ),
            );
          }
        });
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

  _getTripInformation() async {
    //drawing route using ORSM package
    if (myMarkers.length < 2) {
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
    /*final manager = OSRMManager();
    roadInfo = await manager.getTrip(
        waypoints: waypoints,
        roundTrip: true,
        destination: DestinationGeoPointOption.last,
        source: SourceGeoPointOption.first,
        geometry: Geometries.geojson,
        steps: true,
        languageCode: "en");*/
  }
}
