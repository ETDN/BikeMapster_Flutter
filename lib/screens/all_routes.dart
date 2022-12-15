import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navbar/drawer_nav.dart';
import 'new_route.dart';

class AllRoutes extends StatefulWidget {
  const AllRoutes({Key? key}) : super(key: key);

  @override
  _AllRouteState createState() => _AllRouteState();
}

class _AllRouteState extends State<AllRoutes> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  //add the route to the favorites of the Biker
  void _toggleFavorite(String routeID) {
    //get the biker currently logged in
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

  _deleteRoute(String id) {
    //delete the route from the database
    FirebaseFirestore.instance.collection('Routes').doc(id).delete();
    //add comfirmation message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Route deleted'),
      duration: Duration(seconds: 2),
    ));
    //update the state of the widget
    setState(() {});
  }

  _editRoute(String id) {}

  @override
  build(BuildContext context) {
    //get data from firestore
    CollectionReference routes =
        FirebaseFirestore.instance.collection('Routes');

    final User user = auth.currentUser!;
    final uid = user.uid;
    DocumentReference biker_ref =
        FirebaseFirestore.instance.collection("Bikers").doc(uid);

    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: Text(
          'All Routes',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(53, 66, 74, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate());
            },
            icon: const Icon(Icons.search),
          ),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: routes.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return new ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    //check if the route is in the favorites of the Biker and wait for the result
                    bool _isFavorited = false;
                    biker_ref.get().then((value) {
                      try {
                        if (value.get('favorites').contains(document.id)) {
                          _isFavorited = true;
                        }
                      } catch (e) {
                        _isFavorited = false;
                      }
                    });

                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
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

                          //Check if the biker is admin
                          FutureBuilder(
                        future: biker_ref.get(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.get('isAdmin') == true) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Color.fromRGBO(0, 181, 107, 1),
                                    onPressed: () => _editRoute(document.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Color.fromARGB(255, 198, 0, 0),
                                    onPressed: () => _deleteRoute(document.id),
                                  ),
                                ],
                              );
                            } else {
                              return IconButton(
                                icon: (_isFavorited
                                    ? const Icon(Icons.favorite)
                                    : const Icon(Icons.favorite_border)),
                                color: Color.fromRGBO(0, 181, 107, 1),
                                onPressed: () => _toggleFavorite(document.id),
                              );
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),

                      //wait for _isFavorited to be set
                      /*FutureBuilder(
                        future: biker_ref.get(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return IconButton(
                              icon: (_isFavorited
                                  ? const Icon(Icons.favorite)
                                  : const Icon(Icons.favorite_border)),
                              color: Color.fromRGBO(0, 181, 107, 1),
                              onPressed: () => _toggleFavorite(document.id),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),*/
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://images.unsplash.com/photo-1609605988071-0d1cfd25044e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1935&q=80")),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    );
  }
}

//Search by city method empty

class CustomSearchDelegate extends SearchDelegate {
  List<String> nameCity = [];
  // Names of the city stored in the Database ?
  //Or hardcoded ?

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var city in nameCity) {
      if (city.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(city);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var city in nameCity) {
      if (city.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(city);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
