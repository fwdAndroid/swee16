import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

// ignore: must_be_immutable
class GoodMissedButtonWidget extends StatelessWidget {
  VoidCallback? onTap;
  Color? color;
  String titleText;
  String subtitleText;
  GoodMissedButtonWidget({
    super.key,
    required this.onTap,
    this.color,
    required this.titleText,
    required this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Center(
          child: Column(
            children: [
              Text(
                titleText,
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitleText,
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
