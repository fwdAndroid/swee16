import 'package:flutter/material.dart';
import 'package:swee16/screens/subscription/subscription.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/save_button.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
              child: SaveButton(title: "Add Account", onTap: () {}),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(title: "Switch Account", onTap: () {}),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(title: "Contact Us", onTap: () {}),
            ),
          ),
          Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(title: "Cancel Subscription", onTap: () {}),
            ),
          ),
        ],
      ),
    );
  }
}
