import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/numberWidget.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _practiceSessions = [];

  @override
  void initState() {
    super.initState();
    _loadPracticeSessions();
  }

  void _loadPracticeSessions() {
    _firestore
        .collection('practice_sessions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            _practiceSessions = snapshot.docs;
          });
        });
  }

  void _deleteSession(String sessionId) async {
    await _firestore.collection('practice_sessions').doc(sessionId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: blackColor,
        automaticallyImplyLeading: false,
        title: Text("Fawad Kaleem", style: TextStyle(color: whiteColor)),
      ),
      body:
          _practiceSessions.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 64, color: whiteColor),
                    SizedBox(height: 16),
                    Text(
                      "No practice sessions found",
                      style: TextStyle(color: whiteColor, fontSize: 18),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _practiceSessions.length,
                itemBuilder: (context, index) {
                  final session = _practiceSessions[index];
                  final date = DateFormat(
                    'dd MMMM y',
                  ).format(session['timestamp'].toDate());

                  return Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 160,
                              width: 280,
                              child: Card(
                                color: textFieldColor,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          date,
                                          style: TextStyle(
                                            color: whiteColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Numbers 1-8
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(8, (i) {
                                          final number = i + 1;
                                          final sessionData =
                                              session.data()
                                                  as Map<String, dynamic>;
                                          final percentage =
                                              sessionData.containsKey('$number')
                                                  ? (sessionData['$number']['percentage']
                                                          ?.toString() ??
                                                      '0')
                                                  : '0';

                                          return Numberwidget(
                                            title: "$number",
                                            color: getNumberColor(number),
                                            number: "$percentage%",
                                          );
                                        }),
                                      ),
                                    ),
                                    // Numbers 9-16
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(8, (i) {
                                          final number = i + 9;
                                          final sessionData =
                                              session.data()
                                                  as Map<String, dynamic>;
                                          final percentage =
                                              sessionData.containsKey('$number')
                                                  ? (sessionData['$number']['percentage']
                                                          ?.toString() ??
                                                      '0')
                                                  : '0';

                                          return Numberwidget(
                                            title: "$number",
                                            color: getNumberColor(number),
                                            number: "$percentage%",
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteSession(session.id),
                            icon: Icon(Icons.delete, color: removeColor),
                          ),
                        ],
                      ),
                      Divider(color: whiteColor, height: 3),
                    ],
                  );
                },
              ),
    );
  }
}
 