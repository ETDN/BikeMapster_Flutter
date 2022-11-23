import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'drawer_nav.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerNav(),
        appBar: AppBar(
          title: const Text('Maps',
              style: TextStyle(
                color: Color.fromRGBO(98, 156, 68, 1),
              )),
          iconTheme: IconThemeData(color: Color.fromRGBO(98, 156, 68, 1)),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: FlutterMap(
          options: MapOptions(
            center: LatLng(46.2293518, 7.3620487),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg",
                subdomains: ['a', 'b', 'c']),
            MarkerLayerOptions(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(46.2293518, 7.3620487),
                  builder: (ctx) => Container(),
                ),
              ],
            ),
          ],
        ));
  }
}
