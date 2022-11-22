import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(color: Color.fromRGBO(98, 156, 68, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(98, 156, 68, 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
