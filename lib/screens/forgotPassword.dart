import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = new GlobalKey<FormState>();
  final emailController = TextEditingController();

  late String email;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Form(
          child: _buildforgotPasswordForm(),
        ),
      ),
    );
  }

  _buildforgotPasswordForm() {
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
                  'Forgot password',
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
                    'Write your email and reset your password',
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
                return 'Please enter your email adress';
              }
              return null;
            },
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
                    text: "Remember your password?  Log in",
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
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(20, 50),
                primary: Color.fromRGBO(0, 181, 107, 1), // Background color
              ),
              child: Text(
                'Reset password',
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
            context, MaterialPageRoute(builder: (context) => LoginPage()));
        break;
    }
  }

  void message() {}

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      //Utils.showSnackBar('Password Reset Email sent');

      onItemPressed(context, index: 4);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}
