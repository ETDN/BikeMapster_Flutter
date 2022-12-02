import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/Utils.dart';
import 'package:flutter_crashcourse/screens/navbar/drawer_nav.dart';
import 'package:flutter_crashcourse/screens/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/Utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MaterialApp(
    home: SplashScreen(),
  ));
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: Text(
          'Bike Mapster',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(0, 181, 107, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/logo_white_no_bg.png',
                  fit: BoxFit.contain,
                ),
              )
            ],
          )),

      // backgroundColor: Color.fromRGBO(23, 23, 23, 1),
      // body: Center(
      //     child: Container(
      //   child: Image(image: AssetImage('images/logo.png'), fit: BoxFit.fill),
    );
  }
}
