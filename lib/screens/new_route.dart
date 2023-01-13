import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navbar/drawer_nav.dart';

// Define a custom Form widget.
class RouteForm extends StatefulWidget {
  RouteForm(double distance, double duration, LatLng start, LatLng end,
      var startLocation, var destination,
      {Key? key}) {
    this.distance = distance;
    this.duration = duration;
    this.start = start;
    this.end = end;
    this.startLocation = startLocation;
    this.destination = destination;
  }

  var startLocation;
  var destination;
  double duration = 0.0;
  double distance = 0.0;
  LatLng start = LatLng(0, 0);
  LatLng end = LatLng(0, 0);

  @override
  State<RouteForm> createState() =>
      _RouteForm(distance, duration, start, end, startLocation, destination);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _RouteForm extends State<RouteForm> {
  final nameController = TextEditingController();

  _RouteForm(double distance, double duration, LatLng start, LatLng end,
      var startLocation, var destination) {
    this.lenght = distance;
    this.duration = duration;
    this.start = start;
    this.end = end;
    this.startLocation = startLocation;
    this.destination = destination;
  }

  double lenght = 0.0;
  double duration = 0.0;
  LatLng start = LatLng(0, 0);
  LatLng end = LatLng(0, 0);
  final FirebaseAuth auth = FirebaseAuth.instance;
  var startLocation;
  var destination;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = auth.currentUser!;
    final uid = user.uid;
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
            ListTile(
              dense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: Text(
                  "Your choice was : " +
                      startLocation.locality +
                      ' - ' +
                      destination.locality, // start locality
                  style: GoogleFonts.bebasNeue(
                      fontSize: 18, color: Color.fromRGBO(53, 66, 74, 1))),
              subtitle: Text(
                startLocation.street +
                    " - " +
                    destination.street, // start address
                style: GoogleFonts.bebasNeue(fontSize: 14),
              ),
            ),

            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  //add route to database
                  CollectionReference routes =
                      FirebaseFirestore.instance.collection('Routes');
                  routes.add({
                    'name': startLocation.locality.toString() +
                        ' - ' +
                        destination.locality.toString(),
                    'length': lenght.toInt(),
                    'duration': duration.toInt(),
                    'startLat': start.latitude,
                    'startLong': start.longitude,
                    'endLat': end.latitude,
                    'endLong': end.longitude,
                    'startLocation': startLocation.locality,
                    'destination': destination.locality,
                    'ownerId': uid,
                  });
                  //show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Route added successfully'),
                    ),
                  );

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AllRoutes()));
                  //clear text fields
                },
                child: Text(
                  'Confirm',
                  style: GoogleFonts.bebasNeue(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(0, 181, 107, 1),
                  fixedSize: const Size(100, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
