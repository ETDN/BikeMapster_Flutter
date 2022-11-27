import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'navbar/drawer_nav.dart';

class AllRoutes extends StatefulWidget {
  const AllRoutes({Key? key}) : super(key: key);

  @override
  _AllRouteState createState() => _AllRouteState();
}

class _AllRouteState extends State<AllRoutes> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      if (_isFavorited) {
        _isFavorited = false;
      } else {
        _isFavorited = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerNav(),
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Color.fromRGBO(53, 66, 74, 1)),
          backgroundColor: Colors.white,
          title: Text(
            'All Routes',
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
              icon: const Icon(Icons.filter_list),
            ),
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
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ListTile(
                title: Text(
                  "Sion - Visp",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 17,
                    color: Color.fromRGBO(53, 66, 74, 1),
                  ),
                ),
                subtitle: Text(
                  "DISTANCE 35 KM | DURATION : 1H50",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 15, color: Color.fromRGBO(152, 158, 177, 1)),
                ),
                leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1609605988071-0d1cfd25044e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1935&q=80")),
                trailing: IconButton(
                  icon: (_isFavorited
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border)),
                  color: Color.fromRGBO(139, 0, 0, 1),
                  onPressed: (_toggleFavorite),
                )),
            ListTile(
                title: Text(
                  "Sion - Visp",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 17,
                    color: Color.fromRGBO(53, 66, 74, 1),
                  ),
                ),
                subtitle: Text(
                  "DISTANCE 35 KM | DURATION : 1H50",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 15, color: Color.fromRGBO(152, 158, 177, 1)),
                ),
                leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1609605988071-0d1cfd25044e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1935&q=80")),
                trailing: IconButton(
                  icon: (_isFavorited
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border)),
                  color: Color.fromRGBO(139, 0, 0, 1),
                  onPressed: (_toggleFavorite),
                )),
            ListTile(
                title: Text(
                  "Sion - Visp",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 17,
                    color: Color.fromRGBO(53, 66, 74, 1),
                  ),
                ),
                subtitle: Text(
                  "DISTANCE 35 KM | DURATION : 1H50",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 15, color: Color.fromRGBO(152, 158, 177, 1)),
                ),
                leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1609605988071-0d1cfd25044e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1935&q=80")),
                trailing: IconButton(
                  icon: (_isFavorited
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border)),
                  color: Color.fromRGBO(139, 0, 0, 1),
                  onPressed: (_toggleFavorite),
                )),
            ListTile(
                title: Text(
                  "Sion - Visp",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 17,
                    color: Color.fromRGBO(53, 66, 74, 1),
                  ),
                ),
                subtitle: Text(
                  "DISTANCE 35 KM | DURATION : 1H50",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 15, color: Color.fromRGBO(152, 158, 177, 1)),
                ),
                leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1609605988071-0d1cfd25044e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1935&q=80")),
                trailing: IconButton(
                  icon: (_isFavorited
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border)),
                  color: Color.fromRGBO(139, 0, 0, 1),
                  onPressed: (_toggleFavorite),
                ))
          ],
        ));
  }
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
