import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

class BuildCircleWidget extends StatelessWidget {
  int number;
  Color color;
  double left;
  double top;
  VoidCallback? onTap;
  double percent;
  BuildCircleWidget({
    super.key,
    required this.number,
    required this.color,
    required this.left,
    required this.top,
    required this.onTap,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              percent.toString() + "%",
              style: TextStyle(fontSize: 10, color: whiteColor),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                number.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
