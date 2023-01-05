import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/screens/new_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navbar/drawer_nav.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  dynamic favoritesList;
  bool _isDeleted = false;

  // void _toggleDelete(String routeID) {
  //   //get the user from firebase with id
  //   DocumentReference biker_ref =
  //       FirebaseFirestore.instance.collection("Bikers").doc(uid);

  //   biker_ref.update({
  //     'favorites': FieldValue.arrayRemove([routeID])
  //   });

  //   biker_ref.snapshots().listen((event) {
  //     setState(() {});
  //   });

  //   setState(() {
  //     //do something
  //   });
  // }

  @override
  void initState() {
    final User user = auth.currentUser!;
    final uid = user.uid;

    FirebaseFirestore.instance
        .collection('Bikers')
        .doc(uid)
        .get()
        .then((DocumentSnapshot userData) {
      if (userData.exists) {
        try {
          favoritesList = userData.get('favorites');
        } on StateError catch (e) {
          print('stp');
        }
        print('stp fonctionne ${userData.data()}' + favoritesList.toString());
      }
      ;
    });
    getFavRoutes(uid, favoritesList);
  }

  @override
  Widget build(BuildContext context) {
    final User user = auth.currentUser!;
    final uid = user.uid;
    favoritesList = getFavRoutes(uid, favoritesList);
    Map<String, dynamic> data;
    DocumentReference biker_ref =
        FirebaseFirestore.instance.collection("Bikers").doc(uid);

    CollectionReference routes =
        FirebaseFirestore.instance.collection('Routes');

    // FirebaseFirestore.instance
    //     .collection('Bikers')
    //     .doc(uid)
    //     .get()
    //     .then((DocumentSnapshot userData) {
    //   if (userData.exists) {
    //     favoritesList = userData.get('favorites');
    //     print('Document favorites: ${userData['favorites']}');
    //   } else {
    //     print('Document does not exist on the database');
    //   }
    // });

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
                // favoritesList = getFavRoutes(uid, favoritesList);
                print(favoritesList);
                return new ListView(
                  children:

                      //check if the route is in the favorites of the Biker and display the result
                      snapshot.data!.docs
                          .where((element) => favoritesList
                              .any((field) => field.toString() == element.id))
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
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return IconButton(
                              icon: (_isDeleted
                                  ? const Icon(Icons.delete_forever)
                                  : const Icon(Icons.delete_forever_outlined)),
                              color: Color.fromRGBO(139, 0, 0, 1),
                              onPressed: () => {},
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
              },
            ),
          ),
          // CircleAvatar(
          //   radius: 30,
          //   backgroundColor: Color.fromRGBO(0, 181, 107, 1),
          //   child: IconButton(
          //     icon: Icon(
          //       Icons.add,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       //open widget from new_route.dart
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => const RouteForm()));
          //     },
          //   ),
          // ),
          //},
          Padding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    );
  }
}

getFavRoutes(uid, favoritesList) {
  dynamic favList = favoritesList;

  FirebaseFirestore.instance
      .collection('Bikers')
      .doc(uid)
      .get()
      .then((DocumentSnapshot userData) {
    if (userData.exists) {
      try {
        favList = userData.get('favorites');
      } on StateError catch (e) {
        print('ntm');
      }
      print('stp fonctionne ${userData.data()}' + favList.toString());
    }
    ;
  });

  return favList;
}

showAlertDialog(BuildContext context) {
  //set up buttons

  Widget cancelButton = TextButton(
    child: Text(
      "Cancel",
      style: TextStyle(color: Color.fromRGBO(183, 15, 10, 1)),
    ),
    onPressed: () {},
    //do something...
  );

  Widget continueButton = TextButton(
    child: Text(
      "Continue",
      style: TextStyle(color: Color.fromRGBO(0, 181, 107, 1)),
    ),
    onPressed: () {},
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
