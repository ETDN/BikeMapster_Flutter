import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/screens/Map/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import 'navbar/drawer_nav.dart';

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
  double lenght = 0.0;
  double duration = 0.0;
  List<LatLng> polypoints = [];

  _EditRouteState(String routeID) {
    this.routeID = routeID;
  }

  String routeID = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //Edit the name of the route
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Route Name',
                ),
              ),

              //Submit button
              Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text != '') {
                        //Get instance of the route from firebase and update it
                        /*FirebaseFirestore.instance
                            .collection('Routes')
                            .doc(routeID)
                            .update({
                          'name': nameController.text,
                        });*/
                        print("Route name updated");
                        print("Route lenght: " + lenght.toString());
                        print("Route duration: " + duration.toString());
                        print("Route polypoints: " + polypoints.toString());
                      } else
                        print("No name entered");
                    },
                    child: const Text('Submit'),
                  )),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(),
                      ),
                    );
                  },
                  child: const Text('Edit Route'),
                ),
              )
            ])));
  }
}
