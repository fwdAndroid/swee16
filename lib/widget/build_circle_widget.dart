import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

class BuildCircleWidget extends StatelessWidget {
  final int number;
  final Color color;
  final double left;
  final double top;
  final VoidCallback? onTap;
  final double percentage;

  BuildCircleWidget({
    super.key,
    required this.number,
    required this.color,
    required this.left,
    required this.top,
    required this.onTap,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child:
            number == 3
                ? _buildNumberWithRightPercentage()
                : _buildNumberWithTopPercentage(),
      ),
    );
  }

  // For number 3 (percentage on the right)
  Widget _buildNumberWithRightPercentage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircle(),
        const SizedBox(width: 4),
        Text(
          '${percentage.toStringAsFixed(0)}%', // Add % symbol
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberWithTopPercentage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ), 
        const SizedBox(height: 2),
        _buildCircle(),
      ],
    );
  }

  // Reusable circle widget
  Widget _buildCircle() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
