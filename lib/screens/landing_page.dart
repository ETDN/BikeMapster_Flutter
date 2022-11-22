import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Color.fromRGBO(98, 156, 68, 1),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/logo_no_bg.png',
                  fit: BoxFit.contain,
                ),
              )
            ],
          )),
    );
  }
}
