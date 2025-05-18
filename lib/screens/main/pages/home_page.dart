import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  TextEditingController emailController = TextEditingController();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  bool isVoiceMode = false;
  List<Map<String, dynamic>> _actionHistory = [];
  bool _showUndo = false;
  int? _selectedNumber;
  Offset? _selectedPosition;
  Map<int, int> _goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
  Map<int, int> _missedCounts = {for (var i = 1; i <= 16; i++) i: 0};

  int get totalGood => _goodCounts.values.fold(0, (a, b) => a + b);
  int get totalMissed => _missedCounts.values.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _initSpeech();
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
    if (_selectedNumber == null) return;

    setState(() {
      if (type == 'good') {
        _goodCounts[_selectedNumber!] = _goodCounts[_selectedNumber!]! + 1;
      } else if (type == 'missed') {
        _missedCounts[_selectedNumber!] = _missedCounts[_selectedNumber!]! + 1;
      }
      _actionHistory.add({'type': type, 'number': _selectedNumber!});
      _showUndo = true;
    });
  }

  void _undoLastAction() {
    if (_actionHistory.isEmpty) return;

    var lastAction = _actionHistory.removeLast();
    int number = lastAction['number'];
    String type = lastAction['type'];

    setState(() {
      if (type == 'good' && _goodCounts[number]! > 0) {
        _goodCounts[number] = _goodCounts[number]! - 1;
      } else if (type == 'missed' && _missedCounts[number]! > 0) {
        _missedCounts[number] = _missedCounts[number]! - 1;
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
                    percentage:
                        ((_goodCounts[1]! + _missedCounts[1]!) == 0)
                            ? 0
                            : (_goodCounts[1]! /
                                    (_goodCounts[1]! + _missedCounts[1]!)) *
                                100,

                    onTap: () => _handleNumberTap(1, 5, 7),
                  ),
                  BuildCircleWidget(
                    percentage:
                        ((_goodCounts[2]! + _missedCounts[2]!) == 0)
                            ? 0
                            : (_goodCounts[2]! /
                                    (_goodCounts[2]! + _missedCounts[2]!)) *
                                100,
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
                        ((_goodCounts[3]! + _missedCounts[3]!) == 0)
                            ? 0
                            : (_goodCounts[3]! /
                                    (_goodCounts[3]! + _missedCounts[3]!)) *
                                100,
                    top: 200,
                    onTap: () => _handleNumberTap(3, 170, 200),
                  ),
                  BuildCircleWidget(
                    number: 4,
                    color: vivedYellow,
                    left: 290,
                    top: 150,
                    percentage:
                        ((_goodCounts[4]! + _missedCounts[4]!) == 0)
                            ? 0
                            : (_goodCounts[4]! /
                                    (_goodCounts[4]! + _missedCounts[4]!)) *
                                100,

                    onTap: () => _handleNumberTap(4, 290, 150),
                  ),
                  BuildCircleWidget(
                    number: 5,
                    color: brownishOrange,
                    left: 335,
                    top: 7,
                    percentage:
                        ((_goodCounts[5]! + _missedCounts[5]!) == 0)
                            ? 0
                            : (_goodCounts[5]! /
                                    (_goodCounts[5]! + _missedCounts[5]!)) *
                                100,
                    onTap: () => _handleNumberTap(5, 335, 7),
                  ),
                  BuildCircleWidget(
                    number: 6,
                    percentage:
                        ((_goodCounts[6]! + _missedCounts[6]!) == 0)
                            ? 0
                            : (_goodCounts[6]! /
                                    (_goodCounts[6]! + _missedCounts[6]!)) *
                                100,
                    color: hotPink,
                    left: 280,
                    top: 7,
                    onTap: () => _handleNumberTap(6, 280, 7),
                  ),
                  BuildCircleWidget(
                    number: 7,
                    percentage:
                        ((_goodCounts[7]! + _missedCounts[7]!) == 0)
                            ? 0
                            : (_goodCounts[7]! /
                                    (_goodCounts[7]! + _missedCounts[7]!)) *
                                100,

                    color: oliveGreen,
                    left: 270,
                    top: 90,
                    onTap: () => _handleNumberTap(7, 270, 90),
                  ),
                  BuildCircleWidget(
                    number: 8,
                    color: goldenOrange,
                    percentage:
                        ((_goodCounts[8]! + _missedCounts[8]!) == 0)
                            ? 0
                            : (_goodCounts[8]! /
                                    (_goodCounts[8]! + _missedCounts[8]!)) *
                                100,
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
                        ((_goodCounts[9]! + _missedCounts[9]!) == 0)
                            ? 0
                            : (_goodCounts[9]! /
                                    (_goodCounts[9]! + _missedCounts[9]!)) *
                                100,

                    onTap: () => _handleNumberTap(9, 60, 100),
                  ),
                  BuildCircleWidget(
                    number: 10,
                    color: goldenYellow,
                    left: 60,
                    top: 7,
                    percentage:
                        ((_goodCounts[10]! + _missedCounts[10]!) == 0)
                            ? 0
                            : (_goodCounts[10]! /
                                    (_goodCounts[10]! + _missedCounts[10]!)) *
                                100,
                    onTap: () => _handleNumberTap(10, 60, 7),
                  ),
                  BuildCircleWidget(
                    number: 11,
                    color: lightGrey,
                    left: 97,
                    top: 27,
                    percentage:
                        ((_goodCounts[11]! + _missedCounts[11]!) == 0)
                            ? 0
                            : (_goodCounts[11]! /
                                    (_goodCounts[11]! + _missedCounts[11]!)) *
                                100,
                    onTap: () => _handleNumberTap(11, 97, 27),
                  ),
                  BuildCircleWidget(
                    number: 12,
                    percentage:
                        ((_goodCounts[12]! + _missedCounts[12]!) == 0)
                            ? 0
                            : (_goodCounts[12]! /
                                    (_goodCounts[12]! + _missedCounts[12]!)) *
                                100,
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
                        ((_goodCounts[13]! + _missedCounts[13]!) == 0)
                            ? 0
                            : (_goodCounts[13]! /
                                    (_goodCounts[13]! + _missedCounts[13]!)) *
                                100,
                    top: 77,
                    onTap: () => _handleNumberTap(13, 170, 77),
                  ),
                  BuildCircleWidget(
                    number: 14,
                    color: royalPurple,
                    left: 240,
                    top: 100,
                    percentage:
                        ((_goodCounts[14]! + _missedCounts[14]!) == 0)
                            ? 0
                            : (_goodCounts[14]! /
                                    (_goodCounts[14]! + _missedCounts[14]!)) *
                                100,
                    onTap: () => _handleNumberTap(14, 240, 100),
                  ),
                  BuildCircleWidget(
                    number: 15,
                    color: greenishGrey,
                    percentage:
                        ((_goodCounts[15]! + _missedCounts[15]!) == 0)
                            ? 0
                            : (_goodCounts[15]! /
                                    (_goodCounts[15]! + _missedCounts[15]!)) *
                                100,
                    left: 240,
                    top: 27,
                    onTap: () => _handleNumberTap(15, 240, 27),
                  ),
                  BuildCircleWidget(
                    number: 16,
                    percentage:
                        ((_goodCounts[16]! + _missedCounts[16]!) == 0)
                            ? 0
                            : (_goodCounts[16]! /
                                    (_goodCounts[16]! + _missedCounts[16]!)) *
                                100,

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
                      IconButton(
                        icon: Icon(Icons.undo, color: whiteColor),
                        onPressed: _undoLastAction,
                        tooltip: "Undo Last Action",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FunctionsButtonWidget(
                    onTap: () {},
                    color: mainColor,
                    titleText: 'Save Practice',
                  ),

                  const SizedBox(width: 10),
                  FunctionsButtonWidget(
                    onTap: () {},
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

  void _handleNumberTap(int number, double left, double top) {
    setState(() {
      if (_selectedNumber == number) {
        _selectedNumber = null;
        _selectedPosition = null;
      } else {
        _selectedNumber = number;
        _selectedPosition = Offset(left + 10, top + 25);
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
