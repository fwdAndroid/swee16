import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:swee16/screens/main/main_dashboard.dart';
import 'package:swee16/services/auth.dart';
import 'package:swee16/utils/color_platter.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  TextEditingController emailController = TextEditingController();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isGoogle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: whiteColor),
        title: Text(
          "Add Account",
          style: GoogleFonts.poppins(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
          if (emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your full name')),
            );
            return;
          } else {
            _googleSignIn.signOut();
            _loginWithGoogle();
          }
        },
      ),
    );
  }

  Future<void> _loginWithGoogle() async {
    AuthService().signInWithGoogle().then((value) async {
      setState(() {
        isGoogle = true;
      });

      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
        "email": user?.email,
        "fullName": emailController.text,
        "uid": user!.uid,
      });

      setState(() {
        isGoogle = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (builder) => MainDashboard()),
        );
      });
    });
  }
}
