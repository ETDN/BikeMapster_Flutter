import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/screens/favorites.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navbar/drawer_nav.dart';
import 'new_route.dart';
import 'route_editing.dart';

enum SortMode {
  normal,
  distance,
  duration,
}

enum FilterMode {
  normal,
  favorite,
  distance,
  durationLess,
  durationMore,
  starpoint,
  endpoint,
}

class AllRoutes extends StatefulWidget {
  const AllRoutes({Key? key}) : super(key: key);

  @override
  _AllRouteState createState() => _AllRouteState();
}

class _AllRouteState extends State<AllRoutes> {
  SortMode _sortMode = SortMode.normal;
  FilterMode _filterMode = FilterMode.normal;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // FAVORITE METHOD //

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

  // DELETE METHOD //

  _deleteRoute(String id) {
    //delete the route from the favorites of the bikers
    FirebaseFirestore.instance
        .collection('Bikers')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.get('favorites').contains(id)) {
          doc.reference.update({
            'favorites': FieldValue.arrayRemove([id])
          });
        }
      });
    });

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

  _editRoute(String id) {
    //navigate to the edit route page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditRoute(
                  routeID: id,
                )));
  }

  // SEARCH METHOD //

  Future<QuerySnapshot>? postDocumentsList;
  String userNameText = '';

  initSearchingPost(String textInput) {
    postDocumentsList = FirebaseFirestore.instance
        .collection('Routes')
        .where('name', isGreaterThanOrEqualTo: textInput)
        .get();

    print(textInput);

    setState(() {
      postDocumentsList;
    });
  }

  // SORT METHODS //

  void sortByDuration() async {
    _sortMode = SortMode.duration;
    _filterMode = FilterMode.normal;
    setState(() {});
  }

  void sortByDistance() async {
    _sortMode = SortMode.distance;
    _filterMode = FilterMode.normal;
    setState(() {});
  }

  void _resetSort() {
    setState(() {
      _sortMode = SortMode.normal;
      _filterMode = FilterMode.normal;
      // _fetchRoutes();
    });
  }

  // FILTER METHOD //

  void filterByFavorite() async {
    setState(() {
      _filterMode = FilterMode.favorite;
      _sortMode = SortMode.normal;
    });
    //   /*final User user = auth.currentUser!;
    //   final uid = user.uid;
    //   // sort routes to display only user's favorites
    //   FirebaseFirestore.instance
    //       .collection('Bikers')
    //       .doc(uid)
    //       .get()
    //       .then((DocumentSnapshot userData) {
    //     if (userData.exists) {
    //       print('Document favorites: ${userData['favorites']}');
    //     } else {
    //       print('Document does not exist on the database');
    //     }
    //   });*/
  }

  @override
  build(BuildContext context) {
    final User user = auth.currentUser!;
    final uid = user.uid;

    DocumentReference biker_ref =
        FirebaseFirestore.instance.collection("Bikers").doc(uid);

    //get data from firestore
    /*Query<Map<String, dynamic>> routes =
        FirebaseFirestore.instance.collection('Routes');*/

    Query<Map<String, dynamic>> routes;
    if (_filterMode == FilterMode.favorite) {
      routes = FirebaseFirestore.instance.collection('Routes');
    } else {
      routes = FirebaseFirestore.instance.collection('Routes');
    }
    // Query query = Query(biker_ref).orderBy('favorites');

    //order the routes by duration
    if (_sortMode == SortMode.duration) {
      routes = routes.orderBy('duration', descending: false);
    }

    //order the routes by distance
    if (_sortMode == SortMode.distance) {
      routes = routes.orderBy('length', descending: false);
    }

    // reset the routes into the db order
    if (_sortMode == SortMode.normal) {
      routes = routes;
    }

    if (_filterMode == FilterMode.durationLess) {
      routes = routes.where('duration', isLessThan: 60);
    }

    if (_filterMode == FilterMode.durationMore) {
      routes = routes.where('duration', isGreaterThan: 60);
    }

    //search the routes by name
    if (userNameText != '') {
      routes = routes
          .where('name', isGreaterThanOrEqualTo: userNameText)
          .where('name', isLessThan: userNameText + 'z');
    }

    //filter out the routes that are not in the favorites of the biker
    /*if (_filterMode == FilterMode.favorite) {
      biker_ref.get().then((bikerValue) {
        try {
          print(bikerValue.get("favorites"));
          //get the favorites of the biker
          List favorites = bikerValue.get("favorites");
          //filter the routes to display only the favorites

          routes.get().then((value) {
            value.docs.forEach((element) {
              if (favorites.contains(element.id)) {
                print(element.id);
              }
            });
          });         
        } catch (e) {
          print("no favorites");
        }
      });
      //value.get("favorites")
      //routes = routes.where('favorites', arrayContains: uid);
    }*/

/*
    if (_filterMode == FilterMode.favorite) {
      final User user = auth.currentUser!;
      final uid = user.uid;
      // sort routes to display only user's favorites
      FirebaseFirestore.instance
          .collection('Bikers')
          .doc(uid)
          .get()
          .then((DocumentSnapshot userData) {
        if (userData.exists) {
          print('Document favorites: ${userData['favorites']}');
          routes = routes.where(userData['favorites'], arrayContains: "id");
        } else {
          print('Document does not exist on the database');
        }
      });
    }*/

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
          PopupMenuButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              icon: Icon(Icons.filter_alt),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          Icons.favorite,
                          color: Color.fromARGB(255, 198, 0, 0),
                        ),
                        title: Transform.translate(
                          offset: Offset(-20, 0),
                          child: Text(
                            'Favorites',
                            style: GoogleFonts.bebasNeue(fontSize: 15),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Favorites()));
                      },
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          Icons.timelapse,
                          color: Color.fromRGBO(53, 66, 74, 1),
                        ),
                        title: Transform.translate(
                          offset: Offset(-20, 0),
                          child: Text(
                            'Less than 1 hour',
                            style: GoogleFonts.bebasNeue(fontSize: 15),
                          ),
                        ),
                      ),
                      onTap: () => setState(() {
                        _filterMode = FilterMode.durationLess;
                        _sortMode = SortMode.normal;
                      }),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          Icons.timelapse,
                          color: Color.fromRGBO(53, 66, 74, 1),
                        ),
                        title: Transform.translate(
                          offset: Offset(-20, 0),
                          child: Text(
                            'More than 1 hour',
                            style: GoogleFonts.bebasNeue(fontSize: 15),
                          ),
                        ),
                      ),
                      onTap: () => setState(() {
                        _filterMode = FilterMode.durationMore;
                        _sortMode = SortMode.normal;
                      }),
                    ),
                  ]),
          Padding(
            padding: EdgeInsets.only(right: 10),
            //Dropdown filter
            child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                icon: Icon(Icons.sort),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            Icons.restore,
                            color: Color.fromRGBO(53, 66, 74, 1),
                          ),
                          title: Transform.translate(
                            offset: Offset(-20, 0),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => _resetSort(),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            Icons.timer,
                            color: Color.fromRGBO(53, 66, 74, 1),
                          ),
                          title: Transform.translate(
                            offset: Offset(-20, 0),
                            child: Text(
                              'Duration',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => sortByDuration(),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            Icons.straighten,
                            color: Color.fromRGBO(53, 66, 74, 1),
                          ),
                          title: Transform.translate(
                            offset: Offset(-20, 0),
                            child: Text(
                              'Distance',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => sortByDistance(),
                      ),
                    ]),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 20)),
          SizedBox(
            height: 55,
            width: 300,
            child: TextField(
              onChanged: (textInput) {
                setState(() {
                  userNameText = textInput;
                });
                initSearchingPost(textInput);
              },
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        initSearchingPost(userNameText);
                      }),
                  hintText: 'Search a road',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.blue))),
            ),
          ),
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

                //filter out the routes that are not in the favorites of the Biker
                /*Future.delayed(Duration.zero, () async {
                  await biker_ref.get().then((bikerValue) {
                    try {
                      snapshot.data!.docs.forEach((element) {
                        if (_filterMode == FilterMode.favorite) {
                          if (!bikerValue
                              .get('favorites')
                              .contains(element.id)) {
                            snapshot.data!.docs.remove(element);
                            print("removed " + element.id);
                          }
                        }
                      });
                    } catch (e) {
                      print("something went wrong");
                    }
                  });
                });*/

                /*snapshot.data!.docs.forEach((element) {
                  biker_ref.get().then((bikerValue) {
                    try {
                      if (!bikerValue.get('favorites').contains(element.id)) {
                        snapshot.data!.docs.remove(element);
                        print("removed " + element.id);
                      }
                    } catch (e) {
                      print("something went wrong");
                    }
                  });
                  /* if (_filterMode == FilterMode.favorite) {
                    if (!biker.get('favorites').contains(element.id)) {
                      snapshot.data!.docs.remove(element);
                    }
                  }*/
                });*/

                return ListView(
                  children: snapshot.data!.docs.map((roadTomap) {
                    //check if the route is in the favorites of the Biker and wait for the result
                    bool _isFavorited = false;
                    biker_ref.get().then((value) {
                      try {
                        if (value.get('favorites').contains(roadTomap.id)) {
                          _isFavorited = true;
                        }
                      } catch (e) {
                        _isFavorited = false;
                      }
                    });

                    Map<String, dynamic> data =
                        roadTomap.data()! as Map<String, dynamic>;
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
                                    onPressed: () => _editRoute(roadTomap.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever),
                                    color: Color.fromARGB(255, 198, 0, 0),
                                    onPressed: () => _deleteRoute(roadTomap.id),
                                  ),
                                ],
                              );
                            } else {
                              return IconButton(
                                icon: (_isFavorited
                                    ? const Icon(Icons.favorite)
                                    : const Icon(Icons.favorite_border)),
                                color: Color.fromARGB(255, 198, 0, 0),
                                onPressed: () => _toggleFavorite(roadTomap.id),
                              );
                            }
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
          Padding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    );
  }
}


// //Search by city method empty

// class CustomSearchDelegate extends SearchDelegate {
//   List<String> nameCity = [];
//   // Names of the city stored in the Database ?
//   //Or hardcoded ?

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         onPressed: () {
//           query = '';
//         },
//         icon: Icon(Icons.clear),
//       ),
//     ];
//   }

//   // second overwrite to pop out of search menu
//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       onPressed: () {
//         close(context, null);
//       },
//       icon: Icon(Icons.arrow_back),
//     );
//   }

//   // third overwrite to show query result
//   @override
//   Widget buildResults(BuildContext context) {
//     List<String> matchQuery = [];
//     for (var city in nameCity) {
//       if (city.toLowerCase().contains(query.toLowerCase())) {
//         matchQuery.add(city);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           title: Text(result),
//         );
//       },
//     );
//   }

//   // last overwrite to show the
//   // querying process at the runtime
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     List<String> matchQuery = [];
//     for (var city in nameCity) {
//       if (city.toLowerCase().contains(query.toLowerCase())) {
//         matchQuery.add(city);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           title: Text(result),
//         );
//       },
//     );
//   }
// }
