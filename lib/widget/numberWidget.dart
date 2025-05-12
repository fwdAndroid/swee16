import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

class Numberwidget extends StatelessWidget {
  String title;
  Color color;
  String number;
  Numberwidget({
    super.key,
    required this.title,
    required this.color,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: whiteColor,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: blackColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
