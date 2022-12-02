import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar/drawer_nav.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'networkHelper_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //for holding starting and destination points
  List<Marker> myMarkers = [];
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];
  //for knowing if starting point or destination point is selected
  var currentIndex = 0;
  var data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(53, 66, 74, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(53, 66, 74, 1)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          // child: Column(
          //   children: [
          //     Flexible(
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(46.2293518, 7.3620487),
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
                    color: Colors.blue,
                    borderColor: Colors.blueAccent,
                    borderStrokeWidth: 7.0,
                  ),
                ],
              ),
              // FloatingActionButton(
              //   onPressed: _changeMapType,
              //   backgroundColor: Colors.amber,
              //   child: const Icon(Icons.map, size: 30.0),
              // )
            ],
          ),
          //     ),
          //   ],
          // ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Starting point',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location_outlined),
              label: 'Destination',
            ),
          ]),
    );
  }

  // _changeMapType() {
  //   setState(() {
  //     // _currentMapType = _currentMapType == MapType.
  //   });
  // }

  _handleTap(LatLng tappedPoint) {
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
              Icons.location_on_sharp,
              color: Colors.redAccent,
              size: 50,
            ),
            key: Key("start"),
          ),
        );
        print(tappedPoint.toString());
      }
      if (currentIndex == 1) {
        if (myMarkers.length > 1) {
          myMarkers.removeAt(currentIndex);
        }
        polyPoints.clear();
        myMarkers.insert(
          currentIndex,
          Marker(
            point: tappedPoint,
            builder: (context) => Icon(
              Icons.my_location_sharp,
              color: Colors.redAccent,
              size: 50,
            ),
            key: Key("end"),
          ),
        );
        setState(() {
          getJsonData();
        });
      }
    });
  }

  _getTripInformation() async {
    //drawing route using ORSM package
    if (myMarkers.length != 2) {
      return;
    }
    print("Trying to print a road");
    var latStart = myMarkers.first.point.latitude;
    var lngStart = myMarkers.first.point.longitude;
    var latEnd = myMarkers.last.point.latitude;
    var lngEnd = myMarkers.last.point.longitude;

    List<LngLat> waypoints = [
      LngLat(lng: lngStart, lat: latStart),
      LngLat(lng: lngEnd, lat: latEnd)
    ];
    final manager = OSRMManager();
    final road = await manager.getTrip(
        waypoints: waypoints,
        roundTrip: true,
        destination: DestinationGeoPointOption.last,
        source: SourceGeoPointOption.first,
        geometry: Geometries.geojson,
        steps: true,
        languageCode: "en");

    // print(road.polyline);
  }

  /*largely inspired by Arafat Rohan's method, found here: 
  https://medium.com/@rohanarafat86/drawing-route-direction-in-flutter-using-openrouteservice-api-and-google-maps-in-flutter-4431a2989dd5
  Git repository : https://github.com/ArafatRohan93/flutter-polyline-demo/blob/master/lib/main.dart
  */
  void getJsonData() async {
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
    } catch (e) {
      print(e);
    }
  }
}

//Create a new class to hold the Co-ordinates we have received from the response data
class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
