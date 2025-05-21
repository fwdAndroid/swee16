import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swee16/services/database_service.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/utils/show_message_bar.dart';

class DeleteWidget extends StatelessWidget {
  String sessionId;
  DeleteWidget({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: ListBody(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Delete Session",
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: blackColor,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Are you sure you want to delete this session?",
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                // Sign out from Firebase

                Navigator.of(context).pop(); // Close the dialog
                FirestoreService().deleteSession(
                  sessionId,
                ); // Delete the session

                // Show snack bar message
                showMessageBar("Delete Practice", context);

                // Show snack bar message
              },
              child: Text("Yes", style: TextStyle(color: whiteColor)),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(137, 50),
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
