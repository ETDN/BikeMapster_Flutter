import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/screens/Map/Route_Map.dart';
import 'package:flutter_crashcourse/screens/Map/map_page.dart';
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
  distance_desc,
  distance_asc,
  duration_desc,
  duration_asc,
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
  String userNameText = "";

  // FAVORITE METHOD //

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
  /*Future<QuerySnapshot>? postDocumentsList;
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
  }*/

  // SORT METHODS //

  void sortByDurationAsc() async {
    _sortMode = SortMode.duration_asc;
    _filterMode = FilterMode.normal;
    setState(() {});
  }

  void sortByDurationDesc() async {
    _sortMode = SortMode.duration_desc;
    _filterMode = FilterMode.normal;
    setState(() {});
  }

  void sortByDistanceAsc() async {
    _sortMode = SortMode.distance_asc;
    _filterMode = FilterMode.normal;
    setState(() {});
  }

  void sortByDistanceDesc() async {
    _sortMode = SortMode.distance_desc;
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
    if (_sortMode == SortMode.duration_asc) {
      routes = routes.orderBy('duration', descending: false);
    }

    if (_sortMode == SortMode.duration_desc) {
      routes = routes.orderBy('duration', descending: true);
    }

    //order the routes by distance
    if (_sortMode == SortMode.distance_asc) {
      routes = routes.orderBy('length', descending: false);
    }

    if (_sortMode == SortMode.distance_desc) {
      routes = routes.orderBy('length', descending: true);
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
    //must work with upper and lower case
    if (userNameText != '') {
      routes = routes
          .where('name', isGreaterThanOrEqualTo: userNameText)
          .where('name', isLessThan: userNameText + 'z');
    }

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
                              'Duration asc',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => sortByDurationAsc(),
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
                              'Duration desc',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => sortByDurationDesc(),
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
                              'Distance asc',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => sortByDistanceAsc(),
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
                              'Distance desc',
                              style: GoogleFonts.bebasNeue(fontSize: 15),
                            ),
                          ),
                        ),
                        onTap: () => sortByDistanceDesc(),
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
                //initSearchingPost(textInput);
              },
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        //initSearchingPost(userNameText);
                      }),
                  hintText: 'Search a road',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(152, 158, 177, 1), width: 2),
                      borderRadius: BorderRadius.circular(10.0))),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
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

                return ListView(
                  children: snapshot.data!.docs.map((roadTomap) {
                    //check if the route is in the favorites of the Biker and wait for the result
                    //When clicking on the road, it will appear on the map
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

                    return new SizedBox(
                        width: 150,
                        height: 105,
                        child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListTile(
                                        leading: Image.network(
                                          "https://images.unsplash.com/photo-1621576884714-8c4de1175adf?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
                                          width: 100,
                                          height: 55,
                                        ),
                                        trailing: FutureBuilder(
                                          future: biker_ref.get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data.exists) {
                                              if (snapshot.data
                                                      .get('isAdmin') ==
                                                  true) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit),
                                                      color: Color.fromRGBO(
                                                          0, 181, 107, 1),
                                                      onPressed: () =>
                                                          _editRoute(
                                                              roadTomap.id),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete_forever),
                                                      color: Color.fromARGB(
                                                          255, 198, 0, 0),
                                                      onPressed: () =>
                                                          _deleteRoute(
                                                              roadTomap.id),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      //Onpressing the bike icon, the road will appear on the RouteMap
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      RouteMap(
                                                                          roadTomap
                                                                              .id)));
                                                        },
                                                        icon: const Icon(Icons
                                                            .directions_bike),
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                      ),
                                                      IconButton(
                                                        icon: (_isFavorited
                                                            ? const Icon(
                                                                Icons.favorite)
                                                            : const Icon(Icons
                                                                .favorite_border)),
                                                        color: Color.fromARGB(
                                                            255, 198, 0, 0),
                                                        onPressed: () =>
                                                            _toggleFavorite(
                                                                roadTomap.id),
                                                      ),
                                                    ]);
                                              }
                                            } else {
                                              return const CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                        title: Text(
                                          data['name'],
                                          style: GoogleFonts.bebasNeue(
                                              fontSize: 17,
                                              color: Color.fromRGBO(
                                                  53, 66, 74, 1)),
                                        ),
                                        subtitle: Text(
                                          data['length'].toString() +
                                              ' km | ' +
                                              data['duration'].toString() +
                                              ' minutes',
                                          style: GoogleFonts.bebasNeue(
                                              fontSize: 15,
                                              color: Color.fromRGBO(
                                                  152, 158, 177, 1)),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ]))));
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
