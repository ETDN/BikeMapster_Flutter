import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/networkHelper_map.dart';
import 'package:flutter_crashcourse/screens/new_route.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class PanelWidget extends StatelessWidget {
  var roadInfo;
  final PanelController panelController;
  final List<LatLng> polyPoints;

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black87, backgroundColor: Colors.green[300],
    // minimumSize: Size(88, 36),
    maximumSize: Size(90, 40),
    padding: EdgeInsets.symmetric(horizontal: 10),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(7)),
    ),
  );

  PanelWidget(
      {Key? key,
      required this.roadInfo,
      required this.panelController,
      required this.polyPoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 12),
          buildDragHandle(),
          SizedBox(height: 7),
          Center(
            child: Text(
              "Your road's information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          SizedBox(height: 36),
          roadInfo != null ? showwidget(roadInfo, context) : noData(),
        ],
      );

  Widget noData() => Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Text(
          "Select a start and a destination",
        ),
      );

  Widget showwidget(dynamic roadInfo, BuildContext context) => Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Distance : ${roadInfo.distance} km",
          ),
          SizedBox(height: 10),
          Text(
            "Estimated duration : ${roadInfo.duration / 60} min",
          ),
          ElevatedButton(
            onPressed: () => saveRoute(roadInfo, context),
            child: Text("Save the route", textAlign: TextAlign.center),
            style: raisedButtonStyle,
          )
        ],
      ));

  buildDragHandle() => GestureDetector(
        child: Center(
          child: Container(
            width: 40,
            height: 7,
            decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
        onTap: togglePanel,
      );

  void togglePanel() {
    panelController.isPanelOpen
        ? panelController.close()
        : panelController.open();
  }

  saveRoute(dynamic roadInfo, BuildContext context) {
    //navigate to the new route page
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return RouteForm(roadInfo.distance, roadInfo.duration, polyPoints[0],
          polyPoints[polyPoints.length - 1]);
    }));
  }
}
