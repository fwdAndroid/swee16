import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:swee16/widget/build_circle_widget.dart';
import 'package:swee16/widget/circle_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emailController = TextEditingController();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  int goodCount = 0;
  int missedCount = 0;
  bool isVoiceMode = false;
  List<String> _actionHistory = [];
  bool _showUndo = false;
  int? _selectedNumber;
  Offset? _selectedPosition;
  Map<int, int> _tapCounts = {for (var i = 1; i <= 16; i++) i: 0};
  int get _totalTaps => _tapCounts.values.reduce((a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // for (int i = 1; i <= 16; i++) {
    //   _tapCounts[i] = 0;
    // }
  }

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
    setState(() {
      if (type == 'good') {
        goodCount++;
      } else {
        missedCount++;
      }
      _actionHistory.add(type);
      _showUndo = true;
    });
  }

  void _undoLastAction() {
    if (_actionHistory.isEmpty) return;

    setState(() {
      String lastAction = _actionHistory.removeLast();
      if (lastAction == 'good' && goodCount > 0) {
        goodCount--;
      } else if (lastAction == 'missed' && missedCount > 0) {
        missedCount--;
      }
      _showUndo = _actionHistory.isNotEmpty;
    });
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isVoiceMode = false;
                        _stopListening();
                      });
                    },
                    child: Container(
                      child: Center(
                        child: Text(
                          'Manually',
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      width: 142,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isVoiceMode ? labelColor : mainColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isVoiceMode = true;
                        _startListening();
                      });
                    },
                    child: Container(
                      child: Center(
                        child: Text(
                          'Voice',
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      width: 142,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isVoiceMode ? mainColor : labelColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
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
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[1]! / _totalTaps * 100),

                    onTap: () => _handleNumberTap(1, 5, 7),
                  ),
                  BuildCircleWidget(
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[2]! / _totalTaps * 100),
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
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[3]! / _totalTaps * 100),
                    top: 200,
                    onTap: () => _handleNumberTap(3, 170, 200),
                  ),
                  BuildCircleWidget(
                    number: 4,
                    color: vivedYellow,
                    left: 290,
                    top: 150,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[4]! / _totalTaps * 100),

                    onTap: () => _handleNumberTap(4, 290, 150),
                  ),
                  BuildCircleWidget(
                    number: 5,
                    color: brownishOrange,
                    left: 335,
                    top: 7,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[5]! / _totalTaps * 100),
                    onTap: () => _handleNumberTap(5, 335, 7),
                  ),
                  BuildCircleWidget(
                    number: 6,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[6]! / _totalTaps * 100),
                    color: hotPink,
                    left: 280,
                    top: 7,
                    onTap: () => _handleNumberTap(6, 280, 7),
                  ),
                  BuildCircleWidget(
                    number: 7,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[7]! / _totalTaps * 100),

                    color: oliveGreen,
                    left: 270,
                    top: 90,
                    onTap: () => _handleNumberTap(7, 270, 90),
                  ),
                  BuildCircleWidget(
                    number: 8,
                    color: goldenOrange,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[8]! / _totalTaps * 100),
                    left: 172,
                    top: 132,
                    onTap: () => _handleNumberTap(8, 172, 132),
                  ),
                  BuildCircleWidget(
                    number: 9,
                    color: red,
                    left: 60,
                    top: 100,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[9]! / _totalTaps * 100),

                    onTap: () => _handleNumberTap(9, 60, 100),
                  ),
                  BuildCircleWidget(
                    number: 10,
                    color: goldenYellow,
                    left: 60,
                    top: 7,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[10]! / _totalTaps * 100),
                    onTap: () => _handleNumberTap(10, 70, 20),
                  ),
                  BuildCircleWidget(
                    number: 11,
                    color: lightGrey,
                    left: 97,
                    top: 27,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[11]! / _totalTaps * 100),
                    onTap: () => _handleNumberTap(11, 97, 27),
                  ),
                  BuildCircleWidget(
                    number: 12,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[12]! / _totalTaps * 100),
                    color: purpleBlue,
                    left: 100,
                    top: 104,
                    onTap: () => _handleNumberTap(12, 100, 104),
                  ),
                  BuildCircleWidget(
                    number: 13,
                    color: warmOrange,
                    left: 170,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[13]! / _totalTaps * 100),
                    top: 77,
                    onTap: () => _handleNumberTap(13, 170, 77),
                  ),
                  BuildCircleWidget(
                    number: 14,
                    color: royalPurple,
                    left: 240,
                    top: 100,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[14]! / _totalTaps * 100),
                    onTap: () => _handleNumberTap(14, 240, 100),
                  ),
                  BuildCircleWidget(
                    number: 15,
                    color: greenishGrey,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[15]! / _totalTaps * 100),
                    left: 240,
                    top: 27,
                    onTap: () => _handleNumberTap(15, 240, 27),
                  ),
                  BuildCircleWidget(
                    number: 16,
                    percentage:
                        _totalTaps == 0
                            ? 0
                            : (_tapCounts[16]! / _totalTaps * 100),

                    color: margintaPink,
                    left: 170,
                    top: 20,
                    onTap: () => _handleNumberTap(16, 170, 20),
                  ),
                  if (_selectedPosition != null) ..._buildConcentricCircles(),
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
                      GestureDetector(
                        onTap:
                            () =>
                                !isVoiceMode ? _incrementCounter('good') : null,
                        child: Container(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'Good',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  goodCount.toString(),
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          width: 142,
                          height: 60,
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                !isVoiceMode
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap:
                            () =>
                                !isVoiceMode
                                    ? _incrementCounter('missed')
                                    : null,
                        child: Container(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'Missed',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  missedCount.toString(),
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          width: 142,
                          height: 60,
                          decoration: BoxDecoration(
                            color: red,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                !isVoiceMode
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _undoLastAction,
                    child: Container(
                      width: 142,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Undo Last Action',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Center(
                      child: Text(
                        'Save practice',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    width: 142,
                    height: 60,
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    child: Center(
                      child: Text(
                        'Delete practice',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    width: 142,
                    height: 60,
                    decoration: BoxDecoration(
                      color: red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNumberTap(int number, double left, double top) {
    setState(() {
      _tapCounts[number] = _tapCounts[number]! + 1;
      if (_selectedNumber == number) {
        _selectedNumber = null;
        _selectedPosition = null;
      } else {
        _selectedNumber = number;
        _selectedPosition = Offset(
          left + 10,
          top + 25,
        ); // Center of 20x20 circle
      }
    });
  }

  List<Widget> _buildConcentricCircles() {
    return [
      CircleWidget(size: 40, opacity: 1.0, selectedPosition: _selectedPosition),
      CircleWidget(size: 60, opacity: 0.6, selectedPosition: _selectedPosition),
    ];
  }
}
