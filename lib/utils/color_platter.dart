import 'package:flutter/material.dart';

final mainColor = const Color(0xFF90EE90);
final blackColor = Colors.black;

final buttonColor = const Color(0xFF00AB66);
final removeColor = Colors.red;
final whiteColor = Colors.white;
final textFieldColor = const Color(0xFF200E32);
final unselectedIconColor = Color(0xff808080);
final labelColor = const Color(0xFFA4A9AE);
final fillColor = const Color(0xFF151313).withOpacity(.60);
final boderColor = const Color(0xFF151313).withOpacity(.10);

//Basket Ball Colors
final blueLight = Color(0xFF4285F4); //1
final lightGreen = Color(0xFF90EE90); //2
final brightNeonGreen = Color(0xFF0CFF79).withOpacity(.4); //3
final vivedYellow = Color(0xFFFFEA00); //4
final brownishOrange = Color(0xFFB5651D); //5
final hotPink = Color(0xFFFF7CEE); //6
final oliveGreen = Color(0xFF75911A); //7
final goldenOrange = Color(0xFFDF9C3E); //8
final red = Color(0xFFEA4335); //9
final goldenYellow = Color(0xFFFBBC05); //10
final lightGrey = Color(0xFFF5F5F5); //11
final purpleBlue = Color(0xFF4F42B5); //12
final warmOrange = Color(0xFFEE5E10); //13
final royalPurple = Color(0xFF800080); //14
final greenishGrey = Color(0xFFA5C7A6); //15
final margintaPink = Color(0xFFEE10AB); //16

//Selected Color
final selectedColor = Color(0xFFADD8E6);

//gET THE COLOR
Color getNumberColor(int number) {
  switch (number) {
    case 1:
      return blueLight;
    case 2:
      return lightGreen;
    case 3:
      return brightNeonGreen;
    case 4:
      return vivedYellow;
    case 5:
      return brownishOrange;
    case 6:
      return hotPink;
    case 7:
      return oliveGreen;
    case 8:
      return goldenOrange;
    case 9:
      return red;
    case 10:
      return goldenYellow;
    case 11:
      return lightGrey;
    case 12:
      return purpleBlue;
    case 13:
      return warmOrange;
    case 14:
      return royalPurple;
    case 15:
      return greenishGrey;
    case 16:
      return margintaPink;
    default:
      return whiteColor;
  }
}
