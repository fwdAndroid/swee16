import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/save_button.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: blackColor,
        title: Text("Subscription Page", style: TextStyle(color: whiteColor)),
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Subscription Detail",
                style: GoogleFonts.poppins(color: whiteColor, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: ListTile(
                leading: Icon(Icons.monetization_on, color: whiteColor),
                title: Text(
                  "\$2.99",
                  style: GoogleFonts.poppins(color: whiteColor),
                ),
                subtitle: Text(
                  "For Per  Month Subscription",
                  style: GoogleFonts.poppins(
                    color: Color(0xffEBEBF5).withOpacity(.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: ListTile(
                leading: Icon(Icons.monetization_on, color: whiteColor),
                title: Text(
                  "\$39.99",
                  style: GoogleFonts.poppins(color: whiteColor),
                ),
                subtitle: Text(
                  "For One Year Subscription",
                  style: GoogleFonts.poppins(
                    color: Color(0xffEBEBF5).withOpacity(.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: Text(
                "Pay Via",
                style: GoogleFonts.poppins(color: whiteColor, fontSize: 20),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),

                child: Image.asset("assets/apple.png", height: 53.92),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),

                child: Image.asset("assets/google.png", height: 53.92),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),

                child: Image.asset("assets/cash.png", height: 48),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  controller: nameController,
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
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Billing Address',
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
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SaveButton(title: "Subscribe", onTap: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
