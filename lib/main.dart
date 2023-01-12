import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:flutter_crashcourse/screens/navbar/drawer_nav.dart';

import 'package:google_fonts/google_fonts.dart';

late SharedPreferences sharedPreferences;

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool? firstLogin = sharedPreferences.getBool("firstLoggedIn");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BikeMapster',
      home: AuthUtils.checkLoginState(context, firstLogin),
    );
  }
}
