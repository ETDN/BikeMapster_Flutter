import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';

import 'drawer_nav.dart';

class AllRoutes extends StatelessWidget {
  const AllRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerNav(),
      appBar: AppBar(
        title: const Text(
          'All Routes',
          style: TextStyle(color: Color.fromRGBO(98, 156, 68, 1)),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color.fromRGBO(98, 156, 68, 1)),
        backgroundColor: Colors.white,
      ),
    );
  }
}
