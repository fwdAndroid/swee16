import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swee16/utils/color_platter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
                  _buildCircle(10, goldenYellow, 70, 10),
                  _buildCircle(11, lightGrey, 97, 40),
                  _buildCircle(9, red, 60, 100),
                  _buildCircle(12, purpleBlue, 100, 115),
                  _buildCircle(2, lightGreen, 40, 150),
                  _buildCircle(1, redOrange, 5, 10),
                  _buildCircle(16, margintaPink, 170, 20),
                  _buildCircle(13, warmOrange, 170, 90),
                  _buildCircle(8, goldenOrange, 172, 142),
                  _buildCircle(3, brightNeonGreen, 170, 205),
                  _buildCircle(14, royalPurple, 240, 115),
                  _buildCircle(7, oliveGreen, 270, 90),
                  _buildCircle(4, vivedYellow, 290, 150),
                  _buildCircle(6, hotPink, 280, 11),
                  _buildCircle(5, brownishOrange, 335, 10),
                  _buildCircle(15, greenishGrey, 240, 40),
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
                  Visibility(
                    visible: _showUndo,
                    child: GestureDetector(
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
                  ),
                ],
              ),
            ),

            Center(
              child: SizedBox(
                width: 300,
                child: Padding(
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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xff200E32).withOpacity(.10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(color: Color(0xff200E32)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(color: Color(0xff200E32)),
                      ),
                      fillColor: Color(0xff200E32),
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

  Widget _buildCircle(int number, Color color, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
