import 'package:flutter/material.dart';
import 'package:swee16/helper/percentage_helper.dart';
import 'package:swee16/helper/variables.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/build_circle_widget.dart';
import 'package:swee16/widget/circle_widget.dart';
import 'package:swee16/widget/functions_button_widget.dart';
import 'package:swee16/widget/good_missed_button_widget.dart';
import 'package:swee16/widget/voice_manual_button_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VoiceManualWidget(
                    styleColor: blackColor,
                    onTap: () {
                      setState(() {
                        isVoiceMode = false;
                        _stopListening();
                      });
                    },
                    color: !isVoiceMode ? mainColor : labelColor,
                    titleText: 'Manually',
                  ),

                  const SizedBox(width: 10),
                  VoiceManualWidget(
                    styleColor: blackColor,
                    onTap: () {
                      setState(() {
                        isVoiceMode = true;
                        _startListening();
                      });
                    },
                    color: isVoiceMode ? mainColor : labelColor,
                    titleText: 'Voice',
                  ),
                ],
              ),
            ),
            if (isVoiceMode)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isListening
                      ? 'Listening... Say "Good" or "Missed"'
                      : 'Tap Voice button to start',
                  style: TextStyle(color: whiteColor, fontSize: 16),
                ),
              ),
            SizedBox(
              height: 310,
              child: Stack(
                children: [
                  Image.asset("assets/basketball.png", width: 400),

                  BuildCircleWidget(
                    number: 1,
                    color: blueLight,
                    left: 5,
                    top: 7,
                    percentage: calculatePercentage(
                      goodCounts[1]!,
                      missedCounts[1]!,
                    ),
                    onTap: () => _handleNumberTap(1, 5, 7),
                  ),
                  BuildCircleWidget(
                    percentage: calculatePercentage(
                      goodCounts[2]!,
                      missedCounts[2]!,
                    ),
                    number: 2,
                    color: lightGreen,
                    left: 40,
                    top: 150,
                    onTap: () => _handleNumberTap(2, 40, 150),
                  ),
                  BuildCircleWidget(
                    number: 3,
                    color: brightNeonGreen,
                    left: 170,
                    percentage: calculatePercentage(
                      goodCounts[3]!,
                      missedCounts[3]!,
                    ),
                    top: 200,
                    onTap: () => _handleNumberTap(3, 170, 185),
                  ),
                  BuildCircleWidget(
                    number: 4,
                    color: vivedYellow,
                    left: 290,
                    top: 150,
                    percentage: calculatePercentage(
                      goodCounts[4]!,
                      missedCounts[4]!,
                    ),
                    onTap: () => _handleNumberTap(4, 290, 150),
                  ),
                  BuildCircleWidget(
                    number: 5,
                    color: brownishOrange,
                    left: 335,
                    top: 7,
                    percentage: calculatePercentage(
                      goodCounts[5]!,
                      missedCounts[5]!,
                    ),
                    onTap: () => _handleNumberTap(5, 335, 7),
                  ),
                  BuildCircleWidget(
                    number: 6,
                    percentage: calculatePercentage(
                      goodCounts[6]!,
                      missedCounts[6]!,
                    ),
                    color: hotPink,
                    left: 280,
                    top: 5,
                    onTap: () => _handleNumberTap(6, 280, 5),
                  ),
                  BuildCircleWidget(
                    number: 7,
                    percentage: calculatePercentage(
                      goodCounts[7]!,
                      missedCounts[7]!,
                    ),
                    color: oliveGreen,
                    left: 280,
                    top: 70,
                    onTap: () => _handleNumberTap(7, 280, 70),
                  ),
                  BuildCircleWidget(
                    number: 8,
                    color: goldenOrange,
                    percentage: calculatePercentage(
                      goodCounts[8]!,
                      missedCounts[8]!,
                    ),
                    left: 172,
                    top: 132,
                    onTap: () => _handleNumberTap(8, 172, 132),
                  ),
                  BuildCircleWidget(
                    number: 9,
                    color: red,
                    left: 60,
                    top: 75,
                    percentage: calculatePercentage(
                      goodCounts[9]!,
                      missedCounts[9]!,
                    ),
                    onTap: () => _handleNumberTap(9, 60, 75),
                  ),
                  BuildCircleWidget(
                    number: 10,
                    color: goldenYellow,
                    left: 60,
                    top: 7,
                    percentage: calculatePercentage(
                      goodCounts[10]!,
                      missedCounts[10]!,
                    ),
                    onTap: () => _handleNumberTap(10, 60, 7),
                  ),
                  BuildCircleWidget(
                    number: 11,
                    color: lightGrey,
                    left: 97,
                    top: 27,
                    percentage: calculatePercentage(
                      goodCounts[11]!,
                      missedCounts[11]!,
                    ),
                    onTap: () => _handleNumberTap(11, 97, 27),
                  ),
                  BuildCircleWidget(
                    number: 12,
                    percentage: calculatePercentage(
                      goodCounts[12]!,
                      missedCounts[12]!,
                    ),
                    color: purpleBlue,
                    left: 100,
                    top: 104,
                    onTap: () => _handleNumberTap(12, 100, 104),
                  ),
                  BuildCircleWidget(
                    number: 13,
                    color: warmOrange,
                    left: 170,
                    percentage: calculatePercentage(
                      goodCounts[13]!,
                      missedCounts[13]!,
                    ),
                    top: 77,
                    onTap: () => _handleNumberTap(13, 170, 77),
                  ),
                  BuildCircleWidget(
                    number: 14,
                    color: royalPurple,
                    left: 240,
                    top: 100,
                    percentage: calculatePercentage(
                      goodCounts[14]!,
                      missedCounts[14]!,
                    ),
                    onTap: () => _handleNumberTap(14, 240, 100),
                  ),
                  BuildCircleWidget(
                    number: 15,
                    color: greenishGrey,
                    percentage: calculatePercentage(
                      goodCounts[15]!,
                      missedCounts[15]!,
                    ),
                    left: 240,
                    top: 27,
                    onTap: () => _handleNumberTap(15, 240, 27),
                  ),
                  BuildCircleWidget(
                    number: 16,
                    percentage: calculatePercentage(
                      goodCounts[16]!,
                      missedCounts[16]!,
                    ),
                    color: margintaPink,
                    left: 170,
                    top: 20,
                    onTap: () => _handleNumberTap(16, 170, 20),
                  ),
                  if (selectedPosition != null) ..._buildConcentricCircles(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GoodMissedButtonWidget(
                        onTap:
                            () =>
                                !isVoiceMode ? _incrementCounter('good') : null,
                        color: mainColor,
                        titleText: 'Good',
                        subtitleText: totalGood.toString(),
                      ),
                      const SizedBox(width: 10),
                      GoodMissedButtonWidget(
                        onTap:
                            () =>
                                !isVoiceMode
                                    ? _incrementCounter('missed')
                                    : null,
                        color: red,
                        titleText: 'Missed',
                        subtitleText: totalMissed.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: _undoLastAction,
                      child: Text(
                        "Undo Actions",
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Over All Percentage: ',
                    style: TextStyle(color: whiteColor, fontSize: 16),
                  ),
                  Text(
                    '${calculatePercentage(totalGood, totalMissed)}%',
                    style: TextStyle(color: whiteColor, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Individual Shot: ",
                        style: TextStyle(color: whiteColor, fontSize: 16),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              selectedNumber != null
                                  ? getNumberColor(selectedNumber!)
                                  : whiteColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            selectedNumber != null ? '$selectedNumber' : 'None',
                            style: TextStyle(
                              color:
                                  selectedNumber != null
                                      ? whiteColor // White text for contrast
                                      : blackColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${selectedNumber != null ? goodCounts[selectedNumber] ?? 0 : 0} Good / '
                    '${selectedNumber != null ? missedCounts[selectedNumber] ?? 0 : 0} Missed',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FunctionsButtonWidget(
                    onTap: _savePracticeResults,
                    color: mainColor,
                    titleText: 'Save Practice',
                  ),

                  const SizedBox(width: 10),
                  FunctionsButtonWidget(
                    onTap: _deletePracticeResults,
                    color: red,
                    titleText: 'Delete practice',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //Functions

  void _initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        setState(() {
          isListening = status == 'listening';
        });
      },
      onError: (error) {
        print('Error: $error');
      },
    );
    if (!available) {
      print('Speech recognition not available');
    }
  }

  Future<void> _savePracticeResults() async {
    final success = await firestoreService.savePracticeSession(
      goodCounts,
      missedCounts,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Practice session saved!' : 'Failed to save session',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      //Clear counts after successful save if needed
      setState(() {
        goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
        missedCounts = {for (var i = 1; i <= 16; i++) i: 0};
      });
    }
  }

  void _startListening() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() {
          isListening = true;
        });
        speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              String recognizedText = result.recognizedWords.toLowerCase();
              if (recognizedText.contains('good')) {
                _incrementCounter('good');
              } else if (recognizedText.contains('missed')) {
                _incrementCounter('missed');
              }
            }
          },
        );
      }
    }
  }

  void _stopListening() {
    if (isListening) {
      speech.stop();
      setState(() {
        isListening = false;
      });
    }
  }

  void _incrementCounter(String type) {
    if (selectedNumber == null) return;

    setState(() {
      if (type == 'good') {
        goodCounts[selectedNumber!] = goodCounts[selectedNumber!]! + 1;
      } else if (type == 'missed') {
        missedCounts[selectedNumber!] = missedCounts[selectedNumber!]! + 1;
      }
      actionHistory.add({'type': type, 'number': selectedNumber!});
      showUndo = true;
    });
  }

  void _undoLastAction() {
    if (actionHistory.isEmpty) return;

    var lastAction = actionHistory.removeLast();
    int number = lastAction['number'];
    String type = lastAction['type'];

    setState(() {
      if (type == 'good' && goodCounts[number]! > 0) {
        goodCounts[number] = goodCounts[number]! - 1;
      } else if (type == 'missed' && missedCounts[number]! > 0) {
        missedCounts[number] = missedCounts[number]! - 1;
      }
      showUndo = actionHistory.isNotEmpty;
    });
  }

  void _handleNumberTap(int number, double left, double top) {
    setState(() {
      if (selectedNumber == number) {
        selectedNumber = null;
        selectedPosition = null;
      } else {
        selectedNumber = number;
        selectedPosition = Offset(left + 10, top + 25);
      }
    });
  }

  List<Widget> _buildConcentricCircles() {
    return [
      CircleWidget(size: 40, opacity: 1.0, selectedPosition: selectedPosition),
      CircleWidget(size: 60, opacity: 0.6, selectedPosition: selectedPosition),
    ];
  }

  void _deletePracticeResults() {
    setState(() {
      // Reset all good and missed counts to 0 for each position
      goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
      missedCounts = {for (var i = 1; i <= 16; i++) i: 0};
      // Clear action history to prevent undoing after deletion
      actionHistory.clear();
      // Reset selected position indicators
      selectedNumber = null;
      selectedPosition = null;
    });
    // Show confirmation feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All practice data cleared!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
