import 'package:flutter/material.dart';
import 'package:swee16/helper/percentage_helper.dart';
import 'package:swee16/helper/variables.dart';
import 'package:swee16/model/spot_model.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:swee16/widget/build_circle_widget.dart';
import 'package:swee16/widget/functions_button_widget.dart';
import 'package:swee16/widget/good_missed_button_widget.dart';
import 'package:swee16/widget/voice_manual_button_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const double courtWidth = 420;
  static const double courtHeight = 310;
  double? selectedDx, selectedDy;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isVoiceMode) {
      if (state == AppLifecycleState.paused) {
        _stopListening();
      } else if (state == AppLifecycleState.resumed && !isListening) {
        _startListening();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSpeech();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListening();
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
                        _stopListening(); // Stop when switching to manual
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
                        _startListening(); // Always start when switching to voice
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isListening ? Icons.mic : Icons.mic_off,
                      color: isListening ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isListening
                          ? 'Listening... Say "Good" or "Missed"'
                          : 'Press Voice button to start',
                      style: TextStyle(color: whiteColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            AspectRatio(
              aspectRatio: 420 / 310, // match your asset’s real ratio

              child: LayoutBuilder(
                builder: (ctx, box) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/basketball.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      for (final spot in spots)
                        Positioned.fill(
                          left: (spot.x / courtWidth) * box.maxWidth,
                          top: (spot.y / courtHeight) * box.maxHeight,
                          child: BuildCircleWidget(
                            number: spot.number,
                            color: spot.color,
                            percentage: calculatePercentage(
                              goodCounts[spot.number]!,
                              missedCounts[spot.number]!,
                            ),
                            isSelected:
                                selectedNumber ==
                                spot.number, // highlight selected
                            onTap: () {
                              _handleNumberTap(
                                spot.number,
                                (spot.x / courtWidth) * box.maxWidth,
                                (spot.y / courtHeight) * box.maxHeight,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
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
    if (!isVoiceMode) return; // Only listen in voice mode

    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            String recognizedText = result.recognizedWords.toLowerCase();
            print("Heard: $recognizedText"); // Debug log

            // Check for "good" or "missed" commands
            if (recognizedText.contains('good')) {
              _incrementCounter('good');
            } else if (recognizedText.contains('miss') ||
                recognizedText.contains('mist') || // Common mishearing
                recognizedText.contains('this') // Sometimes misheard
                ) {
              _incrementCounter('missed');
            }

            // Restart listening if still in voice mode
            if (isVoiceMode) {
              Future.delayed(Duration(milliseconds: 500), () {
                _startListening(); // Small delay before restarting
              });
            }
          }
        },
        listenFor: Duration(seconds: 10),
        cancelOnError: true,
        partialResults: false,
      );
    }
  }

  // Modify the _stopListening function
  void _stopListening() {
    if (isListening) {
      speech.stop();
      setState(() => isListening = false);
    }
  }

  void _incrementCounter(String type) {
    if (selectedNumber == null) {
      // Optional: Auto-select a default spot if none selected
      setState(() => selectedNumber = 1); // Example: Default to spot 1
    }

    setState(() {
      if (type == 'good') {
        goodCounts[selectedNumber!] = (goodCounts[selectedNumber!] ?? 0) + 1;
      } else if (type == 'missed' || type == 'miss' || type == 'this') {
        missedCounts[selectedNumber!] =
            (missedCounts[selectedNumber!] ?? 0) + 1;
      }
      actionHistory.add({'type': type, 'number': selectedNumber!});
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

  void _handleNumberTap(int number, double scaledX, double scaledY) {
    setState(() {
      if (selectedNumber == number) {
        selectedNumber = null;
        selectedPosition = null;
      } else {
        selectedNumber = number;
        selectedPosition = Offset(scaledX, scaledY);
      }
    });
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
