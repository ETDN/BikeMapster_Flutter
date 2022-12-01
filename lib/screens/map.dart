import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar/drawer_nav.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> myMarkers = [];
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          // child: Column(
          //   children: [
          //     Flexible(
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(46.2293518, 7.3620487),
              zoom: 13.0,
              onTap: (tapPosition, point) => _handleTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg",
              ),
              MarkerLayer(
                markers: myMarkers,
              ),
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
            key: Key(tappedPoint.toString()),
          ),
        );
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
              Icons.my_location_sharp,
              color: Colors.redAccent,
              size: 50,
            ),
            key: Key(tappedPoint.toString()),
          ),
        );
      }
    });
  }
}
