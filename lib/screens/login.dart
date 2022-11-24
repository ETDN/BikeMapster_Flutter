import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
            ),
            Image.asset(
              'assets/images/pin_logo.png',
              height: 40,
            ),
            Text(
              'Sign in',
              textAlign: TextAlign.left,
              style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(53, 66, 74, 1)),
            ),
            Text(
              'Hi, nice to see you !',
              textAlign: TextAlign.left,
              style: GoogleFonts.bebasNeue(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(152, 158, 177, 1)),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              width: 270,
              child: TextFormField(
                style: GoogleFonts.bebasNeue(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(98, 156, 68, 1)),
                decoration: const InputDecoration(
                  hintText: 'email',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Container(
              width: 270,
              child: TextFormField(
                style: GoogleFonts.bebasNeue(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(98, 156, 68, 1)),
                decoration: const InputDecoration(
                  hintText: 'password',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 50, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'No accounts? Sign in',
                    style: GoogleFonts.bebasNeue(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(117, 169, 249, 1)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () => onItemPressed(context, index: 0)),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/images/cyclists.jpg',
              height: 200,
            ),
          ],
        ),
      ),
    ));
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AllRoutes()));
        break;
    }
  }
}
