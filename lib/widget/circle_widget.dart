import 'package:flutter/material.dart';

class CircleWidget extends StatelessWidget {
  final double size;
  final double opacity;
  final Offset selectedPosition;

  const CircleWidget({
    required this.size,
    required this.opacity,
    required this.selectedPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: selectedPosition.dx - size / 2,
      top: selectedPosition.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}
