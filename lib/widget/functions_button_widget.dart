import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

// ignore: must_be_immutable
class FunctionsButtonWidget extends StatelessWidget {
  VoidCallback? onTap;
  Color? color;
  String titleText;

  FunctionsButtonWidget({
    super.key,
    required this.onTap,
    this.color,
    required this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Center(
          child: Text(
            titleText,
            style: TextStyle(
              color: whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        width: 142,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
