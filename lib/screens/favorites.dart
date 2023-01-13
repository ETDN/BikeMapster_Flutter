import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Map/Route_Map.dart';
import 'navbar/drawer_nav.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool _isDeleted = false;

  @override
  Widget build(BuildContext context) {
    final User user = auth.currentUser!;
    final uid = user.uid;
    //Future<List> favoritesList = getFavRoutes(uid);
    Map<String, dynamic> data;
    DocumentReference biker_ref =
        FirebaseFirestore.instance.collection("Bikers").doc(uid);

    CollectionReference routes =
        FirebaseFirestore.instance.collection('Routes');

    void _toggleFavorite(String routeID) {
      final User user = auth.currentUser!;
      final uid = user.uid;
      //get the user from firebase with id
      DocumentReference biker_ref =
          FirebaseFirestore.instance.collection("Bikers").doc(uid);
      //check if the route is already in the favorites and if favorites does exist
      biker_ref.get().then((value) {
        try {
          if (value.get('favorites').contains(routeID)) {
            //remove the route from the favorites
            biker_ref.update({
              'favorites': FieldValue.arrayRemove([routeID])
            });
          } else {
            //add the route to the favorites
            biker_ref.update({
              'favorites': FieldValue.arrayUnion([routeID])
            });
          }
        } catch (e) {
          //create the favorites array and add the route to it
          biker_ref.update({
            'favorites': FieldValue.arrayUnion([routeID])
          });
        }
        //get firestore notification that changes have been made
        biker_ref.snapshots().listen((event) {
          setState(() {});
        });
      });
    }

    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Color.fromRGBO(53, 66, 74, 1)),
        backgroundColor: Colors.white,
        title: Text(
          'Favorites',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(53, 66, 74, 1)),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     // method to show the search bar
          //     showSearch(
          //         context: context,
          //         // delegate to customize the search bar
          //         delegate: CustomSearchDelegate());
          //   },
          //   icon: const Icon(Icons.search),
          // ),
          Padding(
            padding: EdgeInsets.only(right: 10),

            //Dropdown filter
            child: PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                          child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Distance'),
                        ),
                      ])),
                      PopupMenuItem(
                          child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Duration'),
                        ),
                      ])),
                      PopupMenuItem(
                          child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Elevation'),
                        ),
                      ]))
                    ]),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("Bikers")
                    .doc(uid)
                    .get(),
                builder: (context, favsnapshot) {
                  if (favsnapshot.hasData) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: routes.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }

                          return new ListView(
                            children:
                                //check if the route is in the favorites of the Biker and display the result
                                snapshot.data!.docs
                                    .where((element) => favsnapshot.data!
                                        .data()!['favorites']
                                        .contains(element.id))
                                    .map((DocumentSnapshot document) {
                              //Declaring a Map to receive the snapshot data
                              data = document.data()! as Map<String, dynamic>;

                              return new ListTile(
                                title: new Text(data['name'],
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 17,
                                      color: Color.fromRGBO(53, 66, 74, 1),
                                    )),
                                subtitle: Text(
                                  data['length'].toString() +
                                      ' km | ' +
                                      data['duration'].toString() +
                                      ' minutes',
                                  style: GoogleFonts.bebasNeue(
                                      fontSize: 15,
                                      color: Color.fromRGBO(152, 158, 177, 1)),
                                ),
                                //change color of the icon when the route is in the favorites
                                trailing:
                                    // use with delete button
                                    FutureBuilder(
                                  future: biker_ref.get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RouteMap(
                                                            document.id,
                                                          )));
                                            },
                                            icon: const Icon(
                                                Icons.directions_bike),
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _toggleFavorite(document.id);
                                            },
                                            icon: const Icon(Icons.favorite),
                                            color:
                                                Color.fromARGB(255, 198, 0, 0),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                                leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        "https://images.unsplash.com/photo-1609605988071-0d1cfd25044e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1935&q=80")),
                              );
                            }).toList(),
                          );
                        });
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser!;
  final uid = user.uid;
  //set up buttons

  Widget cancelButton = TextButton(
    child: Text(
      "Cancel",
      style: TextStyle(color: Color.fromRGBO(183, 15, 10, 1)),
    ),
    onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Favorites()));
    },
    //do something...
  );

  Widget continueButton = TextButton(
    child: Text(
      "Continue",
      style: TextStyle(color: Color.fromRGBO(0, 181, 107, 1)),
    ),
    onPressed: () {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection("Bikers").doc(uid);
      docRef.delete();

      // docRef.snapshots().listen((event) {
      //   setState(() {});
      // });
    },
    //do something...
  );

  AlertDialog alertDialog = AlertDialog(
    title: Text("Confirm delete"),
    content: Text("Are you sure you want to delete ?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}
