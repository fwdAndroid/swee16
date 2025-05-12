import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swee16/screens/main/main_dashboard.dart';
import 'package:swee16/utils/color_platter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate splash time

    //   User? user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainDashboard()),
    );

    // if (user != null) {
    //   // User is signed in, navigate to Home Page

    // } else {
    //   // No user signed in, navigate to Login Page
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => LoginScreen()),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Image.asset('assets/logo.png', width: 300)),
          ),
        ],
      ),
    );
  }
}
