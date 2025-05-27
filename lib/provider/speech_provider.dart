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
  Timer? _restartListeningTimer; // Timer for restarting listening sessions

  bool get isListening => _isListening;
  bool get isVoiceMode => _isVoiceMode;
  SpeechToText get speechToTextInstance => _speechToText;

  SpeechProvider() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // Only initialize if not already available
    if (!_speechToText.isAvailable) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
          notifyListeners();

          // This block ensures that if listening *stops* for any reason
          // (including natural end of listenFor duration, or errors),
          // we attempt to restart it IF voice mode is still ON.
          if (status == 'notListening' && _isVoiceMode) {
            print(
              'VOICE DEBUG: SpeechToText status changed to notListening. Attempting restart.',
            );
            // Context is passed from startListening, so it might be null here
            // but the _scheduleRestartListening can handle it.
            _scheduleRestartListening(context: null);
          }
        },
        onError: (error) {
          print('SpeechToText Error during initialization: $error');
          _isListening = false; // Update listening status in UI
          notifyListeners();
          // DO NOT set _isVoiceMode = false here.
          // The onStatus handler will primarily deal with restarting.
        },
      );
      if (!available) {
        print('Speech recognition not available on this device.');
        // Consider disabling the voice mode button or showing a persistent error if truly unavailable.
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

  void setManualMode() {
    _isVoiceMode = false;
    stopListening(); // This will also cancel any pending restart timers
    notifyListeners();
  }

  // Centralized function to schedule a restart
  void _scheduleRestartListening({BuildContext? context}) {
    // Cancel any existing restart timer to prevent multiple restarts
    _restartListeningTimer?.cancel();

    if (_isVoiceMode) {
      // Only schedule if voice mode is still desired
      _restartListeningTimer = Timer(const Duration(milliseconds: 300), () {
        if (_isVoiceMode && !_speechToText.isListening) {
          // Double check conditions before restarting
          print('VOICE DEBUG: Restarting listening session...');
          startListening(context: context);
        } else if (!_isVoiceMode) {
          print('VOICE DEBUG: Not restarting, voice mode was turned off.');
        }
      });
    }
  }

  void startListening({BuildContext? context}) async {
    if (!_isVoiceMode) return; // Only proceed if voice mode is intentionally ON

    // Ensure speech recognition is available first
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
          print('SpeechToText Error during active listening: $error');
          _isListening = false; // Update listening status in UI
          notifyListeners();

          // --- MODIFICATION: Removed incrementing 'missed' on 'error_no_match' ---
          // Previously: if (error.errorMsg == 'error_no_match' && error.permanent && context != null) {
          //                Provider.of<PracticeProvider>(context, listen: false).incrementCounter('missed', specificNumber: null);
          //                print('VOICE DEBUG: Recognized nothing (no_match error), incrementing missed.');
          //              }
          // Now, this specific increment is removed as per user's request.
          // --- END MODIFICATION ---

          // Schedule restart after any error (unless voice mode is explicitly off)
          _scheduleRestartListening(context: context);
        },
      );
      if (!available) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available on this device.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _isVoiceMode =
            false; // Disable voice mode only if STT is truly unavailable
        notifyListeners();
        return;
      }
    }

    // Stop any existing session before starting a new one
    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    _isListening = true; // Set listening state before starting
    notifyListeners();

    _speechToText.listen(
      onResult: (result) {
        print(
          'VOICE DEBUG: Recognized (partial/final): "${result.recognizedWords}" (Final: ${result.finalResult})',
        );
        if (result.finalResult) {
          String recognizedText = result.recognizedWords.toLowerCase();
          _processVoiceCommand(recognizedText, context);

          // After a final result, schedule a restart.
          _scheduleRestartListening(context: context);
        }
      },
      listenFor: const Duration(seconds: 10), // Maximum duration to listen for
      cancelOnError: false, // Prevents automatic stopping on some errors
      partialResults: false, // Only interested in final results for commands
      listenMode: ListenMode.dictation, // Optimized for general speech
    );
  }

  void stopListening() {
    // Cancel any pending restart timers first
    _restartListeningTimer?.cancel();
    _restartListeningTimer = null;

    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    _isListening = false;
    _voiceDebounce?.cancel(); // Cancel any pending debounce timers
    notifyListeners();
  }

  void _processVoiceCommand(String text, BuildContext? context) {
    print('VOICE DEBUG: Raw recognized text for command processing: "$text"');

    _voiceDebounce
        ?.cancel(); // Cancel any previous debounce if a new command comes in quickly

    _voiceDebounce = Timer(const Duration(milliseconds: 500), () {
      if (context == null) return;

      final practiceProvider = Provider.of<PracticeProvider>(
        context,
        listen: false,
      );

      int? recognizedNumber;
      final RegExp numRegExp = RegExp(
        r'\b(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|\d+)\b',
      );
      final Iterable<RegExpMatch> matches = numRegExp.allMatches(text);

      if (matches.isNotEmpty) {
        for (final m in matches) {
          final String? numWord = m.group(1);
          if (numWord != null) {
            switch (numWord) {
              case 'one':
                recognizedNumber = 1;
                break;
              case 'two':
                recognizedNumber = 2;
                break;
              case 'three':
                recognizedNumber = 3;
                break;
              case 'four':
                recognizedNumber = 4;
                break;
              case 'five':
                recognizedNumber = 5;
                break;
              case 'six':
                recognizedNumber = 6;
                break;
              case 'seven':
                recognizedNumber = 7;
                break;
              case 'eight':
                recognizedNumber = 8;
                break;
              case 'nine':
                recognizedNumber = 9;
                break;
              case 'ten':
                recognizedNumber = 10;
                break;
              case 'eleven':
                recognizedNumber = 11;
                break;
              case 'twelve':
                recognizedNumber = 12;
                break;
              case 'thirteen':
                recognizedNumber = 13;
                break;
              case 'fourteen':
                recognizedNumber = 14;
                break;
              case 'fifteen':
                recognizedNumber = 15;
                break;
              case 'sixteen':
                recognizedNumber = 16;
                break;
              default:
                recognizedNumber = int.tryParse(numWord);
                break;
            }
            if (recognizedNumber != null &&
                recognizedNumber >= 1 &&
                recognizedNumber <= 16) {
              break; // Found a valid number, stop searching
            } else {
              recognizedNumber = null; // Reset if invalid number found
            }
          }
        }
      }

      // Logic: If it contains 'good', it's a good shot. Otherwise, it's a missed shot.
      if (text.contains('good')) {
        practiceProvider.incrementCounter(
          'good',
          specificNumber: recognizedNumber,
        );
        print(
          'Voice Command: Good shot at spot ${recognizedNumber ?? 'selected/default'}',
        );
      } else {
        practiceProvider.incrementCounter(
          'missed',
          specificNumber: recognizedNumber,
        );
        print(
          'Voice Command: Missed shot at spot ${recognizedNumber ?? 'selected/default'} (Any other recognized speech)',
        );
      }
    });
  }

  @override
  void dispose() {
    _voiceDebounce?.cancel();
    _restartListeningTimer?.cancel(); // Cancel any pending restart timers
    _speechToText
        .stop(); // Ensure speech recognition is stopped when provider is disposed
    super.dispose();
  }
}
