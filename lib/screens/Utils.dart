import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/all_routes.dart';
import 'package:flutter_crashcourse/screens/introductionPage.dart';
import 'package:flutter_crashcourse/screens/login.dart';

class Utils {
  //Method to design the snack bar for the error messages
  static void showSnackBar(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(
            color: Color(0xFFC72C41),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error!',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      message!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

//boolean value which changes when the user is an admin
bool isAdmin = false;
//getter for the isAdmin value
bool get adminRights {
  return isAdmin;
}

//Method to check if the user was loged in before he closed the app
class AuthUtils {
  static checkLoginState(context, bool? firstLoggedin) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return AllRoutes();
        } else {
          if (firstLoggedin == null) {
            return IntroductionPage();
          }
          return LoginPage();
        }
      }),
    ));
  }
}
