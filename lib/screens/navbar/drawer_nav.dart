import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';
import 'package:flutter_crashcourse/screens/navbar/drawer_item.dart';
import 'package:flutter_crashcourse/screens/favorites.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:flutter_crashcourse/screens/Map/map_page.dart';
import 'package:flutter_crashcourse/screens/register.dart';
import 'package:flutter_crashcourse/screens/settings.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerNav extends StatelessWidget {
  const DrawerNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo_white_no_bg.png"),
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.unsplash.com/photo-1534787238916-9ba6764efd4f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1331&q=80"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          ListTile(
              title: Text(
                'Maps',
                style: GoogleFonts.bebasNeue(
                    fontSize: 17, color: Color.fromRGBO(53, 66, 74, 1)),
              ),
              leading: Icon(Icons.map, color: Color.fromRGBO(0, 181, 107, 1)),
              onTap: () => onItemPressed(context, index: 0)),
          ListTile(
              title: Text(
                'All routes',
                style: GoogleFonts.bebasNeue(
                    fontSize: 17, color: Color.fromRGBO(53, 66, 74, 1)),
              ),
              leading: Icon(Icons.electric_bike,
                  color: Color.fromARGB(160, 82, 45, 1)),
              onTap: () => onItemPressed(context, index: 1)),
          ListTile(
              title: Text(
                'Favorites',
                style: GoogleFonts.bebasNeue(
                    fontSize: 17, color: Color.fromRGBO(53, 66, 74, 1)),
              ),
              leading:
                  Icon(Icons.favorite, color: Color.fromARGB(255, 198, 0, 0)),
              onTap: () => onItemPressed(context, index: 2)),
          ListTile(
              title: Text(
                'Logout',
                style: GoogleFonts.bebasNeue(
                    fontSize: 17, color: Color.fromRGBO(53, 66, 74, 1)),
              ),
              leading: Icon(
                Icons.logout,
                color: Color.fromRGBO(53, 66, 74, 1),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                onItemPressed(context, index: 4);
              }),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MapPage()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AllRoutes()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Favorites()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Register()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
        break;
      default:
        Navigator.pop(context);
        break;
    }
  }
}
