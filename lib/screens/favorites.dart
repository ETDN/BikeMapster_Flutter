import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'navbar/drawer_nav.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: GoogleFonts.bebasNeue(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(0, 181, 107, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(0, 181, 107, 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
