import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';
import 'package:flutter_crashcourse/screens/forgotPassword.dart';
import 'package:flutter_crashcourse/screens/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Utils.dart';

class LoginPage extends StatefulWidget {
  @override
  _MyLoginState createState() => new _MyLoginState();
}

class _MyLoginState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  late String email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Form(
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      child: ListView(
        children: [
          SizedBox(height: 90.0),
          Container(
            height: 80.0,
            width: 200.0,
            child: Stack(
              children: [
                Text(
                  'Login',
                  style: GoogleFonts.bebasNeue(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(53, 66, 74, 1)),
                ),
                Positioned(
                  top: 5.0,
                  right: 20.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/pin_logo.png',
                        scale: 1.5,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 30.0,
                  child: Text(
                    'Hi, nice to see you again',
                    style: GoogleFonts.bebasNeue(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(152, 158, 177, 1)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextFormField(
                  controller: emailController,
                  style: GoogleFonts.bebasNeue(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(53, 66, 74, 1)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          // Material(
          //   elevation: 20.0,
          //   shadowColor: Colors.blue,
          //   child: TextFormField(
          //     controller: emailController,
          //     style: GoogleFonts.bebasNeue(
          //         fontSize: 15,
          //         fontWeight: FontWeight.w300,
          //         color: Color.fromRGBO(53, 66, 74, 1)),
          //     decoration: const InputDecoration(
          //       focusedBorder: UnderlineInputBorder(
          //         borderSide: BorderSide(
          //           color: Color.fromRGBO(0, 181, 107, 1),
          //         ),
          //       ),
          //       hintText: 'email',
          //     ),
          //     validator: (String? value) {
          //       if (value == null || value.isEmpty) {
          //         return 'Please enter some text';
          //       }
          //       return null;
          //     },
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  style: GoogleFonts.bebasNeue(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(53, 66, 74, 1)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),

          // TextFormField(
          //   controller: passwordController,
          //   style: GoogleFonts.bebasNeue(
          //       fontSize: 15,
          //       fontWeight: FontWeight.w300,
          //       color: Color.fromRGBO(53, 66, 74, 1)),
          //   decoration: const InputDecoration(
          //     focusedBorder: UnderlineInputBorder(
          //       borderSide: BorderSide(
          //         color: Color.fromRGBO(0, 181, 107, 1),
          //       ),
          //     ),
          //     hintText: 'password',
          //   ),
          //   obscureText: true, //Hide input text
          //   validator: (String? value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter some text';
          //     }
          //     return null;
          //   },
          // ),
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
            height: 5.0,
          ),
          RichText(
              textAlign: TextAlign.right,
              text: TextSpan(children: [
                TextSpan(
                    style: GoogleFonts.bebasNeue(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(117, 169, 249, 1),
                        decoration: TextDecoration.underline),
                    text: "Forgot password",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()));
                      }),
              ])),
          ElevatedButton(
            onPressed: signIn,
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

          SizedBox(height: 16),
          Image.asset(
            'assets/images/cyclists.png',
            height: 200,
          ),
        ],
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight, child: AllRoutes()));
    switch (index) {
      case 0:
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.leftToRight, child: AllRoutes()));
        break;
    }
  }

  //Sign in Method and open the All routes page
  Future signIn() async {
    debugPrint(emailController.text.trim());
    debugPrint(passwordController.text.trim());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      onItemPressed(context, index: 0);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      print(e);
      Utils.showSnackBar(context, e.message);
    }
  }
}
