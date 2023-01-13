import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class map extends StatelessWidget {
  //Constructor
  map({
    super.key,
    required Map<String, Marker> myMarkers,
    required Map<String, Marker> warningMarkers,
    required List<LatLng> polyPoints,
    required Function(LatLng tappedPoint) handleTap,
    bool? showWarnings,
  }) {
    this.myMarkers = myMarkers;
    this.warningMarkers = warningMarkers;
    this.polyPoints = polyPoints;
    this._handleTap = handleTap;
    this._showWarnings = showWarnings == null ? false : showWarnings;
  }

  Function _handleTap = (LatLng tappedPoint) {};
  //for holding starting and destination points
  Map<String, Marker> myMarkers = {};
  // for holding markers indicate problems on road
  Map<String, Marker> warningMarkers = {};
  bool _showWarnings = false;
  //for holding all points needed to draw the route
  List<LatLng> polyPoints = [];
  //position of map when open it. May be modified according to customer settings (future improvement)
  LatLng mapCenterPosition = LatLng(46.2293518, 7.3620487);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          markers: myMarkers.values.toList(),
        ),
        if (_showWarnings)
          MarkerLayer(
            markers: warningMarkers.values.toList(),
          ),
        if (polyPoints != null) BuildPolylineLayer(),
      ],
    ));
  }

  PolylineLayer BuildPolylineLayer() {
    return PolylineLayer(
      polylineCulling: false,
      polylines: [
        Polyline(
            points: polyPoints,
            color: Colors.grey,
            borderColor: Colors.deepPurpleAccent,
            borderStrokeWidth: 4.0,
            strokeCap: StrokeCap.round),
      ], //polylines
    );
  }
}
