import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem(
      {Key? key,
      required this.name,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  final String name;
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Color.fromRGBO(0, 181, 107, 1),
              ),
              SizedBox(
                width: 30,
              ),
              Text(
                name,
                style: GoogleFonts.bebasNeue(
                    fontSize: 18, color: Color.fromRGBO(0, 181, 107, 1)),
              )
            ],
          ),
        ));
  }
}
