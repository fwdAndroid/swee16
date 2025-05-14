import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                    child: Text(
                      'Manually',
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  width: 142,
                  height: 60,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  child: Center(
                    child: Text(
                      'Voice',
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  width: 142,
                  height: 60,
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 310,
            child: Stack(
              children: [
                Image.asset("assets/basketball.png"),
                _buildCircle(10, Colors.orange, 125, 10),
                _buildCircle(11, Colors.white, 125, 50),
                _buildCircle(9, Colors.red, 80, 60),
                _buildCircle(12, Colors.indigo, 95, 100),
                _buildCircle(2, Colors.green.shade200, 40, 120),
                _buildCircle(1, Colors.blue, 20, 10),
                _buildCircle(16, Colors.pink, 160, 20),
                _buildCircle(13, Colors.deepOrange, 150, 120),
                _buildCircle(8, Colors.orange.shade300, 145, 180),
                _buildCircle(3, Colors.green.shade700, 200, 200),
                _buildCircle(14, Colors.purple.shade900, 200, 140),
                _buildCircle(7, Colors.green.shade800, 230, 90),
                _buildCircle(4, Colors.yellow, 260, 110),
                _buildCircle(6, Colors.pinkAccent, 280, 20),
                _buildCircle(5, Colors.deepOrange.shade700, 310, 10),
                _buildCircle(15, Colors.green.shade100, 215, 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(int number, Color color, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
