import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/drawer_nav.dart';
import 'package:flutter_crashcourse/screens/landing_page.dart';

void main() {
  runApp(new MaterialApp(
    home: new SplashScreen(),
  ));
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: const Text(
          'Bike Mapster',
          style: TextStyle(color: Color.fromRGBO(98, 156, 68, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(98, 156, 68, 1)),
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
