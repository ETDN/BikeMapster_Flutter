import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: 'Welcome to BikeMapster',
              body: 'The best way to find your next bike adventure',
              image: buildImage('assets/images/logo_white_no_bg.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Find new bike routes for you',
              body: 'Choose from various routes from all over Switzerland.',
              image: buildImage('assets/images/cyclists.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Mark the best routes as your favourites',
              body: 'Find your favourite biking route easily with BikeMapster',
              image: buildImage('assets/images/favoriteRoutes.png'),
              decoration: getPageDecoration(),
            ),
          ],
          done: Text(
            'Start',
            style: GoogleFonts.bebasNeue(
              fontSize: 25,
              fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 38, 139, 84),
            ),
          ),
          onDone: () => goToLogin(context),
          showSkipButton: true,
          skip: Text(
            'Skip',
            style: GoogleFonts.bebasNeue(
              fontSize: 25,
              fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 38, 139, 84),
            ),
          ),
          onSkip: () => goToLogin(context),
          next: Icon(Icons.arrow_forward,
              color: Color.fromARGB(255, 38, 139, 84)),
          dotsDecorator: getDocDecoration(),
          globalBackgroundColor: Colors.white,
          isProgressTap: false,
        ),
      );

  Future<void> goToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstLoggedIn', false);
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: LoginPage(),
      ),
    );
  }

  Widget buildImage(String path) =>
      Center(child: Image.asset(path, width: 350));

  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: GoogleFonts.bebasNeue(
          fontSize: 25,
          fontWeight: FontWeight.w300,
          color: Color.fromARGB(255, 38, 139, 84),
        ),
        bodyTextStyle: GoogleFonts.bebasNeue(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        imagePadding: EdgeInsets.all(24),
        pageColor: Colors.white,
      );

  DotsDecorator getDocDecoration() => DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color.fromARGB(255, 160, 160, 160),
        activeSize: Size(22.0, 10.0),
        activeColor: Color.fromARGB(255, 38, 139, 84),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      );
}
