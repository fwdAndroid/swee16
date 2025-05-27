import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swee16/screens/auth/login_screen.dart';
import 'package:swee16/screens/settings/subscription.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/logout_widget.dart';
import 'package:swee16/widget/save_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                title: "Subscription",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => Subscription()),
                  );
                },
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                title: "Switch Account",
                onTap: () {
                  _googleSignIn.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (builder) => LoginScreen()),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                title: "Contact Us",
                onTap: () {
                  _openGmail();
                },
              ),
            ),
          ),
          Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(title: "Cancel Subscription", onTap: () {}),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                title: "Log out",
                onTap: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return LogoutWidget();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to launch the Gmail application with a pre-filled email address
  Future<void> _openGmail() async {
    const recipient = 'fwdkaleem@gmail.com';
    const subject = 'Your Subject';
    const body = 'Your email body text';

    // Android: Try to open Gmail app directly
    if (Theme.of(context).platform == TargetPlatform.android) {
      final gmailUri =
          Uri(
            scheme: 'intent',
            path: 'send',
            queryParameters: {
              'to': recipient,
              'subject': subject,
              'body': body,
            },
          ).toString();

      final gmailUrl = '${gmailUri}#Intent;package=com.google.android.gm;end';

      if (await canLaunchUrl(Uri.parse(gmailUrl))) {
        await launchUrl(Uri.parse(gmailUrl));
      } else {
        // Fallback to Play Store if Gmail isn't installed
        await launchUrl(Uri.parse('market://details?id=com.google.android.gm'));
      }
    } else {
      // iOS: Open mailto (may not open Gmail directly)
      final mailUrl = Uri(
        scheme: 'mailto',
        path: recipient,
        queryParameters: {'subject': subject, 'body': body},
      );
      if (await canLaunchUrl(mailUrl)) {
        await launchUrl(mailUrl);
      } else {
        throw 'Could not launch email';
      }
    }
  }
}
