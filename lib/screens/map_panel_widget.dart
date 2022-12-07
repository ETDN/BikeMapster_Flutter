import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/networkHelper_map.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class PanelWidget extends StatelessWidget {
  var roadInfo;
  final PanelController panelController;

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black87, backgroundColor: Colors.green[300],
    // minimumSize: Size(88, 36),
    maximumSize: Size(65, 40),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(7)),
    ),
  );

  PanelWidget({Key? key, required this.roadInfo, required this.panelController})
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
          roadInfo != null
              ? showwidget(roadInfo.distance, roadInfo.duration)
              : noData(),
          ElevatedButton(
            onPressed: () {},
            child: Text("Save the route"),
            style: raisedButtonStyle,
          )
        ],
      );

  Widget noData() => Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Text(
          "Select a start and a destination",
        ),
      );

  Widget showwidget(double dist, double dura) => Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Distance : ${dist} km",
          ),
          SizedBox(height: 10),
          Text(
            "Estimated duration : ${dura / 60} min",
          ),
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
}
