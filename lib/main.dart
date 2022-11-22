import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/bottom_bar.dart';
import 'package:flutter_crashcourse/screens/drawer_nav.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
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

      // backgroundColor: Color.fromRGBO(23, 23, 23, 1),
      // body: Center(
      //     child: Container(
      //   child: Image(image: AssetImage('images/logo.png'), fit: BoxFit.fill),
    );
  }
}
