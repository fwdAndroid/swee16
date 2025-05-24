import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:battery_plus/battery_plus.dart';
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
  Timer? _voiceDebounce;
  final Battery _battery = Battery();
  int? _batteryLevel;

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
    _checkBatteryLevel();
    // Periodic battery check every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) => _checkBatteryLevel());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _voiceDebounce?.cancel();
    _stopListening();
    super.dispose();
  }

  Future<void> _checkBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() => _batteryLevel = batteryLevel);

    if (batteryLevel < 20 && isVoiceMode) {
      setState(() {
        isVoiceMode = false;
        _stopListening();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice mode disabled - low battery ($batteryLevel%)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VoiceManualWidget(
                        styleColor: blackColor,
                        onTap: () {
                          setState(() {
                            isVoiceMode = !isVoiceMode;
                            if (isVoiceMode) {
                              _startListening();
                            } else {
                              _stopListening();
                            }
                          });
                        },
                        color: isVoiceMode ? mainColor : labelColor,
                        titleText: isVoiceMode ? 'Listening...' : 'Voice',
                      ),
                      const SizedBox(width: 10),
                      VoiceManualWidget(
                        styleColor: blackColor,
                        onTap: () {
                          setState(() {
                            isVoiceMode = false;
                            _stopListening();
                          });
                        },
                        color: !isVoiceMode ? mainColor : labelColor,
                        titleText: 'Manual',
                      ),
                    ],
                  ),
                  if (_batteryLevel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Battery: $_batteryLevel%',
                        style: TextStyle(
                          color: _batteryLevel! < 20 ? Colors.red : whiteColor,
                          fontSize: 14,
                        ),
                      ),
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
                    const SizedBox(width: 8),
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
              aspectRatio: 420 / 310,
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
                            isSelected: selectedNumber == spot.number,
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
                                      ? whiteColor
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
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            isListening = status == 'listening';
          });
        }
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
    if (!isVoiceMode || !mounted) return;

    if (!speech.isAvailable) {
      bool available = await speech.initialize();
      if (!available) return;
    }

    if (mounted) {
      setState(() => isListening = true);
    }

    speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          String recognizedText = result.recognizedWords.toLowerCase();
          _processVoiceCommand(recognizedText);

          Future.delayed(const Duration(milliseconds: 300), () {
            if (isVoiceMode && mounted) {
              _startListening();
            }
          });
        }
      },
      listenFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: false,
      listenMode: ListenMode.confirmation,
    );
  }

  void _processVoiceCommand(String text) {
    _voiceDebounce?.cancel();

    _voiceDebounce = Timer(const Duration(milliseconds: 500), () {
      if (text.contains('good')) {
        _incrementCounter('good');
      } else if (text.contains('miss') || text.contains('mist')) {
        _incrementCounter('missed');
      }
    });
  }

  void _stopListening() {
    if (isListening) {
      speech.stop();
      if (mounted) {
        setState(() => isListening = false);
      }
    }
  }

  void _incrementCounter(String type) {
    if (selectedNumber == null) {
      if (mounted) {
        setState(() => selectedNumber = 1);
      }
    }

    if (mounted) {
      setState(() {
        if (type == 'good') {
          goodCounts[selectedNumber!] = (goodCounts[selectedNumber!] ?? 0) + 1;
        } else if (type == 'missed') {
          missedCounts[selectedNumber!] =
              (missedCounts[selectedNumber!] ?? 0) + 1;
        }
        actionHistory.add({'type': type, 'number': selectedNumber!});
      });
    }
  }

  void _undoLastAction() {
    if (actionHistory.isEmpty) return;

    var lastAction = actionHistory.removeLast();
    int number = lastAction['number'];
    String type = lastAction['type'];

    if (mounted) {
      setState(() {
        if (type == 'good' && goodCounts[number]! > 0) {
          goodCounts[number] = goodCounts[number]! - 1;
        } else if (type == 'missed' && missedCounts[number]! > 0) {
          missedCounts[number] = missedCounts[number]! - 1;
        }
        showUndo = actionHistory.isNotEmpty;
      });
    }
  }

  void _handleNumberTap(int number, double scaledX, double scaledY) {
    if (mounted) {
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
  }

  Future<void> _savePracticeResults() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Practice'),
          content: const Text(
            'Are you sure you want to save this practice session?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: red)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: mainColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await firestoreService.savePracticeSession(
      goodCounts,
      missedCounts,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Practice session saved!' : 'Failed to save session',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        setState(() {
          goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
          missedCounts = {for (var i = 1; i <= 16; i++) i: 0};
          actionHistory.clear();
        });
      }
    }
  }

  void _deletePracticeResults() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Practice Data'),
          content: const Text(
            'Are you sure you want to delete all practice data? This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: mainColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (mounted) {
      setState(() {
        goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
        missedCounts = {for (var i = 1; i <= 16; i++) i: 0};
        actionHistory.clear();
        selectedNumber = null;
        selectedPosition = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All practice data cleared!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
