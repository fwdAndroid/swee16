import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swee16/helper/percentage_helper.dart';
import 'package:swee16/model/spot_model.dart';
import 'package:swee16/provider/practice_provider.dart';
import 'package:swee16/provider/speech_provider.dart';
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
  bool _providersLinked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_providersLinked) {
      _linkProviders();
      _providersLinked = true;
    }
  }

  void _linkProviders() {
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    final practiceProvider = Provider.of<PracticeProvider>(
      context,
      listen: false,
    );

    speechProvider.linkWithPracticeProvider(practiceProvider);

    // Initialize voice mode only if not already active
    if (!speechProvider.isVoiceMode) {
      speechProvider.toggleVoiceMode();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);

    if (state == AppLifecycleState.resumed && speechProvider.isVoiceMode) {
      speechProvider.startListening();
    } else if (state == AppLifecycleState.paused) {
      speechProvider.stopListening();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    speechProvider.setManualMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context);
    final practiceProvider = Provider.of<PracticeProvider>(context);

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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      VoiceManualWidget(
                        onTap: () {
                          if (!speechProvider.isVoiceMode) {
                            speechProvider.toggleVoiceMode();
                          }
                        },
                        color: speechProvider.isVoiceMode ? red : Colors.grey,
                        titleText: 'Voice',
                        styleColor:
                            speechProvider.isVoiceMode
                                ? Colors.white
                                : Colors.black,
                      ),
                      VoiceManualWidget(
                        onTap: () {
                          if (speechProvider.isVoiceMode) {
                            speechProvider.setManualMode();
                          }
                        },
                        color:
                            speechProvider.isVoiceMode
                                ? Colors.grey
                                : Colors.orange,
                        titleText: 'Manual',
                        styleColor:
                            speechProvider.isVoiceMode
                                ? Colors.black
                                : Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (speechProvider.isVoiceMode)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      speechProvider.isListening ? Icons.mic : Icons.mic_off,
                      color:
                          speechProvider.isListening
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      speechProvider.isListening
                          ? 'Listening... Say "Good" or "Missed'
                          : 'Voice mode inactive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            speechProvider.isListening
                                ? Colors.green
                                : Colors.red,
                      ),
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
                              practiceProvider.goodCounts[spot.number]!,
                              practiceProvider.missedCounts[spot.number]!,
                            ),
                            isSelected:
                                practiceProvider.selectedNumber == spot.number,
                            onTap: () {
                              practiceProvider.handleNumberTap(
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GoodMissedButtonWidget(
                        onTap:
                            speechProvider.isVoiceMode
                                ? null
                                : () => practiceProvider.manualIncrementCounter(
                                  'good',
                                ),
                        color: Colors.green,
                        titleText: 'GOOD',
                        subtitleText: practiceProvider.totalGood.toString(),
                      ),
                      GoodMissedButtonWidget(
                        onTap:
                            speechProvider.isVoiceMode
                                ? null
                                : () => practiceProvider.manualIncrementCounter(
                                  'missed',
                                ),
                        color: red,
                        titleText: 'MISSED',
                        subtitleText: practiceProvider.totalMissed.toString(),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: practiceProvider.undoLastAction,
                      child: Text(
                        "Undo Last Action",
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8,
                      bottom: 9,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Selected Shot: ",
                              style: TextStyle(color: whiteColor, fontSize: 16),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color:
                                    practiceProvider.selectedNumber != null
                                        ? getNumberColor(
                                          practiceProvider.selectedNumber!,
                                        )
                                        : whiteColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  practiceProvider.selectedNumber != null
                                      ? '${practiceProvider.selectedNumber}'
                                      : 'None',
                                  style: TextStyle(
                                    color:
                                        practiceProvider.selectedNumber != null
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
                          '${practiceProvider.selectedNumber != null ? practiceProvider.goodCounts[practiceProvider.selectedNumber!] ?? 0 : 0} Good / '
                          '${practiceProvider.selectedNumber != null ? practiceProvider.missedCounts[practiceProvider.selectedNumber!] ?? 0 : 0} Missed',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Overall: ${calculateOverallPercentage(practiceProvider.totalGood, practiceProvider.totalMissed)}',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FunctionsButtonWidget(
                          onTap:
                              () => _showSaveConfirmation(
                                context,
                                practiceProvider,
                              ),
                          color: mainColor,
                          titleText: 'Save Session',
                        ),
                        const SizedBox(width: 10),
                        FunctionsButtonWidget(
                          onTap:
                              () => _showDeleteConfirmation(
                                context,
                                practiceProvider,
                              ),
                          color: red,
                          titleText: 'Clear Data',
                        ),
                      ],
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

  Future<void> _showSaveConfirmation(
    BuildContext context,
    PracticeProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Practice Session'),
            content: const Text(
              'Are you sure you want to save this practice session?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Save', style: TextStyle(color: mainColor)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      provider.savePracticeResults(context);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    PracticeProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Practice Data'),
            content: const Text(
              'All practice data will be permanently deleted. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: mainColor)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      provider.deletePracticeResults(context);
    }
  }
}
