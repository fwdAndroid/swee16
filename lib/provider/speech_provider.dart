import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:swee16/provider/practice_provider.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isVoiceMode = false;
  Timer? _voiceDebounce;
  Timer? _restartListeningTimer;

  bool get isListening => _isListening;
  bool get isVoiceMode => _isVoiceMode;
  SpeechToText get speechToTextInstance => _speechToText;

  SpeechProvider() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    if (!_speechToText.isAvailable) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
          notifyListeners();
          if (status == 'notListening' && _isVoiceMode) {
            _scheduleRestartListening(context: null);
          }
        },
        onError: (error) {
          print('Initialization Error: $error');
          _isListening = false;
          notifyListeners();
        },
      );
      if (!available) {
        print('Speech recognition unavailable');
      }
    }
  }

  void toggleVoiceMode({BuildContext? context}) {
    _isVoiceMode = !_isVoiceMode;
    if (_isVoiceMode) {
      startListening(context: context);
    } else {
      stopListening();
    }
    notifyListeners();
  }

  void _scheduleRestartListening({BuildContext? context}) {
    _restartListeningTimer?.cancel();
    if (_isVoiceMode) {
      _restartListeningTimer = Timer(const Duration(milliseconds: 300), () {
        if (_isVoiceMode && !_speechToText.isListening) {
          startListening(context: context);
        }
      });
    }
  }

  void startListening({BuildContext? context}) async {
    // Safety check: ensure context is valid and mounted
    if (context != null && !context.mounted) {
      print("Context not available or not mounted");
      return;
    }

    if (!_isVoiceMode) return;

    // Initialize speech recognition if needed
    if (!_speechToText.isAvailable) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
          notifyListeners();
          if (status == 'notListening' && _isVoiceMode) {
            _scheduleRestartListening(context: context);
          }
        },
        onError: (error) {
          print('Initialization Error: $error');
          _isListening = false;
          notifyListeners();

          // Handle errors during initialization
          if (!error.permanent) {
            _scheduleRestartListening(context: context);
          }
        },
      );

      if (!available) {
        print('Speech recognition unavailable');
        _isVoiceMode = false;
        notifyListeners();
        return;
      }
    }

    // Stop any existing listening session
    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    _isListening = true;
    notifyListeners();

    // Start new listening session
    _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          // Process command only if context is still valid
          if (context != null && context.mounted) {
            _processVoiceCommand(result.recognizedWords.toLowerCase(), context);
          }
          _scheduleRestartListening(context: context);
        }
      },
      listenFor: const Duration(seconds: 5),
      cancelOnError: true,
      partialResults: false,
      listenMode: ListenMode.dictation,
      listenOptions: SpeechListenOptions(autoPunctuation: true),
      // onError: (error) {
      //   print('Listening Error: $error');
      //   _isListening = false;
      //   notifyListeners();

      //   // Handle different error types
      //   if (error.errorMsg == 'error_no_match') {
      //     // Treat "no match" as temporary error
      //     _scheduleRestartListening(context: context);

      //     // Also increment missed shot if context is valid
      //     if (context != null && context.mounted) {
      //       Provider.of<PracticeProvider>(
      //         context,
      //         listen: false,
      //       ).incrementCounter('missed');
      //     }
      //   } else if (!error.permanent) {
      //     // Schedule restart for other temporary errors
      //     _scheduleRestartListening(context: context);
      //   }
      // },
    );
  }

  void stopListening() {
    _restartListeningTimer?.cancel();
    _restartListeningTimer = null;
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    _isListening = false;
    _voiceDebounce?.cancel();
    notifyListeners();
  }

  void setManualMode() {
    if (_isVoiceMode) {
      print('VOICE DEBUG: Switching to Manual mode.');
    }
    _isVoiceMode = false;
    stopListening();
    notifyListeners();
  }

  void _processVoiceCommand(String text, BuildContext? context) {
    _voiceDebounce?.cancel();
    _voiceDebounce = Timer(const Duration(milliseconds: 500), () {
      if (context == null || !context.mounted) return;

      final practiceProvider = Provider.of<PracticeProvider>(
        context,
        listen: false,
      );

      // Improved command matching with regex
      final bool isGood = RegExp(r'\b(good)\b').hasMatch(text);
      final bool isMissed = RegExp(r'\b(missed)\b').hasMatch(text);

      // Number extraction logic
      int? recognizedNumber;
      final numberWords = {
        'one': 1,
        'two': 2,
        'three': 3,
        'four': 4,
        'five': 5,
        'six': 6,
        'seven': 7,
        'eight': 8,
        'nine': 9,
        'ten': 10,
        'eleven': 11,
        'twelve': 12,
        'thirteen': 13,
        'fourteen': 14,
        'fifteen': 15,
        'sixteen': 16,
      };

      final match = RegExp(
        r'\b(\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen)\b',
      ).firstMatch(text);

      if (match != null) {
        final numberString = match.group(1)!;
        recognizedNumber =
            numberWords[numberString] ?? int.tryParse(numberString);
      }

      // Command handling
      if (isGood) {
        practiceProvider.incrementCounter(
          'good',
          specificNumber: recognizedNumber,
        );
      } else if (isMissed) {
        practiceProvider.incrementCounter(
          'missed',
          specificNumber: recognizedNumber,
        );
      } else {
        // Increment missed for any unrecognized speech
        practiceProvider.incrementCounter(
          'missed',
          specificNumber: recognizedNumber,
        );
      }
    });
  }

  @override
  void dispose() {
    _voiceDebounce?.cancel();
    _restartListeningTimer?.cancel();
    _speechToText.stop();
    super.dispose();
  }
}
