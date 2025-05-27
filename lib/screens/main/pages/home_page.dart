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
  double? selectedDx, selectedDy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // --- NEW: Start voice mode automatically on app launch ---
    // Using Future.microtask to ensure context is available after build method
    // Also, wrap it in a condition to prevent multiple calls if initState is called multiple times
    // (though for StatelessWidget, it's usually once per life cycle)
    Future.microtask(() {
      final speechProvider = Provider.of<SpeechProvider>(
        context,
        listen: false,
      );
      if (!speechProvider.isVoiceMode) {
        // Only start if not already in voice mode
        speechProvider.toggleVoiceMode(context: context);
      }
    });
    // --- END NEW ---
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      speechProvider.stopListening();
    } else if (state == AppLifecycleState.resumed) {
      // Only restart if voice mode was active before going to background
      if (speechProvider.isVoiceMode) {
        speechProvider.startListening(context: context);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Ensure speech listening is stopped when the widget is disposed
    Provider.of<SpeechProvider>(context, listen: false).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context);
    final practiceProvider = Provider.of<PracticeProvider>(context);
    // Determine the text and colors for the Voice/Manual buttons
    Color voiceButtonColor = speechProvider.isVoiceMode ? red : Colors.grey;
    Color manualButtonColor =
        speechProvider.isVoiceMode ? Colors.grey : Colors.orange;
    Color voiceButtonTextColor =
        speechProvider.isVoiceMode ? Colors.white : Colors.black;
    Color manualButtonTextColor =
        speechProvider.isVoiceMode ? Colors.black : Colors.white;
    String statusText =
        speechProvider.isVoiceMode
            ? (speechProvider.isListening
                ? 'Listening... Say "Good" or "Missed"'
                : 'Initializing voice...')
            : 'Manual Mode Active'; // Text for the status display

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
                            speechProvider.toggleVoiceMode(context: context);
                          }
                        },
                        color: voiceButtonColor,
                        titleText: 'Voice',
                        styleColor: voiceButtonTextColor,
                      ),
                      VoiceManualWidget(
                        onTap: () {
                          if (speechProvider.isVoiceMode) {
                            speechProvider.setManualMode();
                          }
                        },
                        color: manualButtonColor,
                        titleText: 'Manual',
                        styleColor: manualButtonTextColor,
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
                      statusText, // Use the dynamically determined statusText
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            speechProvider.isVoiceMode
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
                                : () =>
                                    practiceProvider.incrementCounter('good'),
                        color: Colors.green,
                        titleText: 'GOOD',
                        subtitleText: practiceProvider.totalGood.toString(),
                      ),
                      GoodMissedButtonWidget(
                        onTap:
                            speechProvider.isVoiceMode
                                ? null
                                : () =>
                                    practiceProvider.incrementCounter('missed'),
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
                        "Undo Actions",
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
                              "Individual Shot: ",
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
                                  textAlign: TextAlign.center,
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
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Overall Percentage: ${calculateOverallPercentage(practiceProvider.totalGood, practiceProvider.totalMissed)}',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
                              onTap: () async {
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
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(color: red),
                                          ),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                        ),
                                        TextButton(
                                          child: Text(
                                            'Save',
                                            style: TextStyle(color: mainColor),
                                          ),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  practiceProvider.savePracticeResults(context);
                                }
                              },
                              color: mainColor,
                              titleText: 'Save Practice',
                            ),
                            const SizedBox(width: 10),
                            FunctionsButtonWidget(
                              onTap: () async {
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
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(color: mainColor),
                                          ),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                        ),
                                        TextButton(
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: red),
                                          ),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  practiceProvider.deletePracticeResults(
                                    context,
                                  );
                                }
                              },
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
          ],
        ),
      ),
    );
  }
}
