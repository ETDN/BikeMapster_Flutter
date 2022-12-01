import 'dart:developer';

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
  const RouteForm({super.key});

  @override
  State<RouteForm> createState() => _RouteForm();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _RouteForm extends State<RouteForm> {
  final nameController = TextEditingController();
  final lenghtController = TextEditingController();
  final durationController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    lenghtController.dispose();
    durationController.dispose();
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
            //Route Lenght
            TextFormField(
              controller: lenghtController,
              decoration: const InputDecoration(
                hintText: 'Route Length in kilometers',
              ),
            ),
            //Route Duration
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                hintText: 'Route Duration in minutes',
              ),
            ),
            //Submit Button
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text != '' &&
                      lenghtController.text != '' &&
                      durationController.text != '') {
                    //add route to database
                    CollectionReference routes =
                        FirebaseFirestore.instance.collection('Routes');
                    routes.add({
                      'name': nameController.text,
                      'length': int.parse(lenghtController.text),
                      'duration': int.parse(durationController.text),
                    });
                    //show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Route added successfully'),
                      ),
                    );
                    //clear text fields
                    nameController.clear();
                    lenghtController.clear();
                    durationController.clear();
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
