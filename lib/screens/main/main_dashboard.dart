import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swee16/screens/main/pages/account_page.dart';
import 'package:swee16/screens/main/pages/home_page.dart';
import 'package:swee16/screens/main/pages/score_page.dart';
import 'package:swee16/utils/color_platter.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ScorePage(), // Replace with your screen widgets
    HomePage(),
    AccountPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: textFieldColor,
          selectedLabelStyle: TextStyle(color: mainColor),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedLabelStyle: TextStyle(color: Colors.white70),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon:
                  _currentIndex == 0
                      ? Image.asset("assets/scoreColor.png", height: 25)
                      : Image.asset("assets/scoreNoColor.png", height: 25),
              label: 'Score',
            ),
            BottomNavigationBarItem(
              icon:
                  _currentIndex == 1
                      ? Image.asset(
                        "assets/material-symbols_home-rounded.png",
                        height: 25,
                      )
                      : Icon(Icons.home, size: 25, color: unselectedIconColor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              label: "Account",
              icon:
                  _currentIndex == 2
                      ? Image.asset("assets/Group 7742.png", height: 25)
                      : Icon(
                        Icons.person,
                        size: 25,
                        color: unselectedIconColor,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop(); // For Android
                  } else if (Platform.isIOS) {
                    exit(0); // For iOS
                  }
                },
                child: Text('Yes'),
              ),
            ],
          ),
    );
  }
}
