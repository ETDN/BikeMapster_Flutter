import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/main.dart';
import 'package:flutter_crashcourse/screens/favorites.dart';

class SplashScreen extends StatefulWidget {
  @override
  LandingPage createState() => LandingPage();
}

class LandingPage extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    new Future.delayed(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(
                  'assets/images/logo_white_no_bg.png',
                  fit: BoxFit.contain,
                ),
              )
            ],
          )),
    );
  }
}
