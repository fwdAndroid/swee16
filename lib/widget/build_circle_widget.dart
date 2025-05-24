import 'package:flutter/material.dart';

class BuildCircleWidget extends StatelessWidget {
  final int number;
  final Color color;
  final int percentage;
  final VoidCallback? onTap;
  final bool isSelected;

  const BuildCircleWidget({
    Key? key,
    required this.number,
    required this.color,
    required this.percentage,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The Positioned widget is now handled in HomePage's Stack.
    // This widget simply paints the circle and text.
    return GestureDetector(
      onTap: onTap,
      child:
          number == 3
              ? _buildNumberWithRightPercentage()
              : _buildNumberWithTopPercentage(),
    );
  }

  Widget _buildNumberWithRightPercentage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircle(),
        const SizedBox(width: 4),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        _buildCircle(),
      ],
    );
  }

  Widget _buildCircle() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            isSelected
                ? Border.all(color: Colors.white, width: 3)
                : Border.all(color: Colors.transparent),
        boxShadow:
            isSelected ? [BoxShadow(color: Colors.white, blurRadius: 10)] : [],
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
