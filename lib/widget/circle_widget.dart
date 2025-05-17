import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

class CircleWidget extends StatelessWidget {
  double size;
  double opacity;
  Offset? selectedPosition;
  CircleWidget({
    super.key,
    required this.size,
    required this.opacity,
    required this.selectedPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: selectedPosition!.dx - size / 2,
      top: selectedPosition!.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selectedColor, width: 1.5),
        ),
      ),
    );
  }
}
