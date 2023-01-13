import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';

import 'Utils.dart';

class Register extends StatefulWidget {
  @override
  _MyRegisterState createState() => new _MyRegisterState();
}

class _MyRegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late String email, password;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Form(
          child: _buildRegisterForm(),
        ),
      ),
    );
  }

  _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      child: ListView(
        children: [
          SizedBox(height: 75.0),
          Container(
            height: 80.0,
            width: 200.0,
            child: Stack(
              children: [
                Text(
                  'Registration',
                  style: GoogleFonts.bebasNeue(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(53, 66, 74, 1)),
                ),
                Positioned(
                  top: 5.0,
                  right: 20.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                    'Welcome to bikeMapster',
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
          TextFormField(
            controller: emailController,
            style: GoogleFonts.bebasNeue(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Color.fromRGBO(98, 156, 68, 1)),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(0, 181, 107, 1),
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
            controller: passwordController,
            style: GoogleFonts.bebasNeue(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Color.fromRGBO(98, 156, 68, 1)),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(0, 181, 107, 1),
                ),
              ),
              hintText: 'password',
            ),
            obscureText: true, //Hide input text
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value != null && value.length < 6
                ? 'Password must have min. 6 characters'
                : null,
          ),
          SizedBox(height: 5.0),
          RichText(
              textAlign: TextAlign.right,
              text: TextSpan(children: [
                TextSpan(
                    style: GoogleFonts.bebasNeue(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(117, 169, 249, 1),
                        decoration: TextDecoration.underline),
                    text: "Already have an account ? Log in",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      }),
              ])),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            child: ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(20, 50),
                primary: Color.fromRGBO(0, 181, 107, 1), // Background color
              ),
              child: Text(
                'Register',
                style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
              ),
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AllRoutes()));
        break;
    }
  }

  Future signUp() async {
    debugPrint(emailController.text.trim());
    debugPrint(passwordController.text.trim());
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      onItemPressed(context, index: 0);

      //Store it in firebase
      final docUser = FirebaseFirestore.instance
          .collection("Bikers")
          .doc(FirebaseAuth.instance.currentUser?.uid);
      final json = {
        "email": emailController.text.trim(),
        "favorites": [],
        "isAdmin": false,
      };

      await docUser.set(json);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      print(e);
      Utils.showSnackBar(context, e.message);
    }
  }
}
