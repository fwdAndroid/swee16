import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

class Spot {
  final int number;
  final Color color;
  final double x, y;
  Spot({
    required this.number,
    required this.color,
    required this.x,
    required this.y,
  });
}

final List<Spot> spots = [
  Spot(number: 1, color: blueLight, x: -385, y: 7),
  Spot(number: 2, color: lightGreen, x: -320, y: 150),
  Spot(number: 3, color: brightNeonGreen, x: 300, y: 185),
  Spot(number: 4, color: vivedYellow, x: 320, y: 150),
  Spot(number: 5, color: brownishOrange, x: 385, y: 7),
  Spot(number: 6, color: hotPink, x: 280, y: 5),
  Spot(number: 7, color: oliveGreen, x: 240, y: 90),
  Spot(number: 8, color: goldenOrange, x: 5, y: 153),
  Spot(number: 9, color: red, x: -260, y: 95),
  Spot(number: 10, color: goldenYellow, x: -260, y: 7),
  Spot(number: 11, color: lightGrey, x: -170, y: 32),
  Spot(number: 12, color: purpleBlue, x: -170, y: 120),
  Spot(number: 13, color: warmOrange, x: 5, y: 92),
  Spot(number: 14, color: royalPurple, x: 170, y: 120),
  Spot(number: 15, color: greenishGrey, x: 165, y: 30),
  Spot(number: 16, color: margintaPink, x: 5, y: 20),

  // … and so on through spot 16 …
];
