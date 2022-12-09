import 'dart:developer';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navbar/drawer_nav.dart';
import 'package:flutter/material.dart';

// Define a custom Form widget.
class RouteForm extends StatefulWidget {
  RouteForm(double distance, double duration, LatLng start, LatLng end,
      {Key? key}) {
    this.distance = distance;
    this.duration = duration;
    this.start = start;
    this.end = end;
  }

  double duration = 0.0;
  double distance = 0.0;
  LatLng start = LatLng(0, 0);
  LatLng end = LatLng(0, 0);

  @override
  State<RouteForm> createState() => _RouteForm(distance, duration, start, end);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _RouteForm extends State<RouteForm> {
  final nameController = TextEditingController();

  _RouteForm(double distance, double duration, LatLng start, LatLng end) {
    this.lenght = distance;
    this.duration = duration;
    this.start = start;
    this.end = end;
  }

  double lenght = 0.0;
  double duration = 0.0;
  LatLng start = LatLng(0, 0);
  LatLng end = LatLng(0, 0);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: Text(
          'New Route',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(53, 66, 74, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      //Form to add a new route
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Route Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Route Name',
              ),
            ),
            //Submit Button
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text != '') {
                    //add route to database
                    CollectionReference routes =
                        FirebaseFirestore.instance.collection('Routes');
                    routes.add({
                      'name': nameController.text,
                      'length': lenght.toInt(),
                      'duration': duration.toInt(),
                      'startLat': start.latitude,
                      'startLong': start.longitude,
                      'endLat': end.latitude,
                      'endLong': end.longitude,
                    });
                    //show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Route added successfully'),
                      ),
                    );
                    //clear text fields
                    nameController.clear();
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
