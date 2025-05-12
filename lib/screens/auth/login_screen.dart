import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:swee16/screens/main/main_dashboard.dart';
import 'package:swee16/utils/color_platter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  bool isGoogle = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: mainColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/logo.png', // Replace with your icon asset
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: GoogleFonts.poppins(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.only(left: 8, top: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Color(0xff151313).withOpacity(.10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: boderColor),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: boderColor),
                  ),
                  fillColor: fillColor,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 20),
            isGoogle
                ? Center(child: CircularProgressIndicator())
                : _buildGoogleSignInButton(),
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
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop(); // For Android
                  } else if (Platform.isIOS) {
                    exit(0); // For iOS
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SocialLoginButton(
        height: 55,
        width: 327,
        buttonType: SocialLoginButtonType.google,
        borderRadius: 15,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => MainDashboard()),
          );
        },
      ),
    );
  }

  // Future<void> _loginWithGoogle() async {
  //   AuthMethods().signInWithGoogle().then((value) async {
  //     setState(() {
  //       isGoogle = true;
  //     });

  //     User? user = FirebaseAuth.instance.currentUser;

  //     await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
  //       "email": user?.email,
  //       "fullName": user?.displayName,
  //       "phoneNumber": user?.phoneNumber ?? "Not Available",
  //       "password": "No Password Available",
  //       "image": FirebaseAuth.instance.currentUser!.photoURL,
  //       "confrimPassword": "No Password Available",

  //       "uid": user!.uid,
  //     });

  //     setState(() {
  //       isGoogle = false;
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (builder) => MainDashboard()),
  //       );
  //     });
  //   });
  // }
}
