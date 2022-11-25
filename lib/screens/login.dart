import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';
import 'package:flutter_crashcourse/screens/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _MyLoginState createState() => new _MyLoginState();
}

class _MyLoginState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  late String email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            //Commented out by Pinto for testing
            /*SizedBox(
              height: 40,
            ),*/
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
              ),
              hintText: 'email',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            style: GoogleFonts.bebasNeue(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Color.fromRGBO(53, 66, 74, 1)),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(0, 181, 107, 1),
                ),
              ),
              hintText: 'password',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          SizedBox(height: 5.0),
          // GestureDetector(
          //   onTap: () {
          //     //To do.......
          //   },
          //   child: Container(
          //     alignment: Alignment(1.0, 0.0),
          //     padding: EdgeInsets.only(top: 15.0, left: 20.0),
          //     child: InkWell(
          //       child: Text(
          //         'No account ? Sign in',
          //         style: GoogleFonts.bebasNeue(
          //             fontSize: 15,
          //             fontWeight: FontWeight.w300,
          //             color: Color.fromRGBO(117, 169, 249, 1),
          //             decoration: TextDecoration.underline),
          //       ),
          //     ),
          //   ),
          // ),

          RichText(
              textAlign: TextAlign.right,
              text: TextSpan(children: [
                TextSpan(
                    style: GoogleFonts.bebasNeue(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(117, 169, 249, 1),
                        decoration: TextDecoration.underline),
                    text: "No account ? Sign in",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      }),
              ])),

          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () => onItemPressed(context, index: 0),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(20, 50),
              primary: Color.fromRGBO(0, 181, 107, 1), // Background color
            ),
            child: Text(
              'Login',
              style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Image.asset(
            'assets/images/cyclists.png',
            height: 200,
          ),
        ],
      ),
    );
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
