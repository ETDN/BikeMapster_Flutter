import 'dart:convert';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/networkHelper_map.dart';
import 'package:flutter_crashcourse/screens/new_route.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'Utils.dart';

class PanelWidget extends StatelessWidget {
  var roadInfo;
  var startLocation;
  var destination;
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
      required this.startLocation,
      required this.destination,
      required this.panelController,
      required this.polyPoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 10),
          buildDragHandle(),
          SizedBox(height: 7),
          Center(
            child: Text(
              "Information",
              style: GoogleFonts.bebasNeue(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          roadInfo != null ? showWidget(roadInfo, context) : noData(),
        ],
      );

  Widget noData() => Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Text(
          "Select a start and a destination",
        ),
      );

  Widget showWidget(dynamic roadInfo, BuildContext context) => Container(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  dense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                  title: Text(startLocation.locality, // start locality
                      style: GoogleFonts.bebasNeue(
                          fontSize: 18, color: Color.fromRGBO(53, 66, 74, 1))),
                  subtitle: Text(
                    startLocation.street, // start address
                    style: GoogleFonts.bebasNeue(fontSize: 14),
                  ),
                ),
              ),
              Expanded(
                  child: Icon(
                Icons.arrow_forward,
                size: 25,
              )),
              Expanded(
                  child: ListTile(
                      dense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      title: Text(destination.locality, // destination's name
                          style: GoogleFonts.bebasNeue(
                              fontSize: 18,
                              color: Color.fromRGBO(53, 66, 74, 1))),
                      subtitle:
                          Text(destination.street, // destination's address
                              style: GoogleFonts.bebasNeue(fontSize: 14))))
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          ListTile(
            dense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Transform.translate(
              offset: Offset(-25, 0),
              child: Text("Distance : ${roadInfo.distance.round()} km",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 16, color: Color.fromRGBO(53, 66, 74, 1))),
            ),
            leading: Icon(Icons.straighten),
          ),
          ListTile(
            dense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Transform.translate(
              offset: Offset(-25, 0),
              child: Text("Duration : ${(roadInfo.duration / 60).round()} min",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 16, color: Color.fromRGBO(53, 66, 74, 1))),
            ),
            leading: Icon(Icons.timer),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          adminRights
              ? ElevatedButton(
                  onPressed: () => saveRoute(roadInfo, context),
                  child: Text(
                    "Save",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 181, 107, 1),
                    fixedSize: const Size(80, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ))
              : const Text(""),
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
      return RouteForm(roadInfo.distance, roadInfo.duration / 60, polyPoints[0],
          polyPoints[polyPoints.length - 1], startLocation, destination);
    }));
  }
}
