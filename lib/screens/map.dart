import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'drawer_nav.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> myMarkers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: Text('Bike Mapster'),
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
                      "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.swissimage/default/current/3857/{z}/{x}/{y}.jpeg",
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
        ));
  }

  _handleTap(LatLng tappedPoint) {
    setState(() {
      myMarkers = [];
      myMarkers.add(
        Marker(
          point: tappedPoint,
          builder: (context) => Icon(
            Icons.location_on_sharp,
            color: Colors.green,
            size: 50,
          ),
          key: Key(tappedPoint.toString()),
        ),
      );
    });
  }
}
