import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider for context.read
import 'package:speech_to_text/speech_to_text.dart';
import 'package:swee16/provider/practice_provider.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isVoiceMode = false;
  Timer? _voiceDebounce;

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
        },
        onError: (error) {
          print('SpeechToText Error: $error');
          _isListening = false;
          _isVoiceMode = false;
          notifyListeners();
        },
      );
      if (!available) {
        print('Speech recognition not available on this device.');
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
    stopListening();
    notifyListeners();
  }

  void startListening({BuildContext? context}) async {
    if (!_isVoiceMode) return;

    if (!_speechToText.isAvailable) {
      bool available = await _speechToText.initialize();
      if (!available) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _isVoiceMode = false;
        notifyListeners();
        return;
      }
    }

    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    _isListening = true;
    notifyListeners();

    _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          String recognizedText = result.recognizedWords.toLowerCase();
          _processVoiceCommand(recognizedText, context); // Pass context here

          // Re-start listening after processing a final result
          // Only if voice mode is still active and not already listening.
          // Add a small delay to prevent rapid restarts overwhelming the system.
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_isVoiceMode && !_speechToText.isListening) {
              startListening(context: context);
            }
          });
        }
      },
      listenFor: const Duration(seconds: 10), // Listen for a longer period
      cancelOnError: false, // Keep listening even if an error occurs
      partialResults: false,
      listenMode:
          ListenMode.dictation, // More suitable for continuous listening
    );
  }

  void stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    _isListening = false;
    _voiceDebounce?.cancel();
    notifyListeners();
  }

  // Pass context to this method to access PracticeProvider
  void _processVoiceCommand(String text, BuildContext? context) {
    _voiceDebounce?.cancel(); // Cancel any previous debounce

    _voiceDebounce = Timer(const Duration(milliseconds: 500), () {
      if (context == null) return; // Ensure context is available

      final practiceProvider = Provider.of<PracticeProvider>(
        context,
        listen: false,
      );

      // Extract number if present (e.g., "good 5", "missed 12")
      int? recognizedNumber;
      final RegExp numRegExp = RegExp(
        r'\b(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|\d+)\b',
      );
      final Iterable<RegExpMatch> matches = numRegExp.allMatches(text);

      if (matches.isNotEmpty) {
        for (final m in matches) {
          final String? numWord = m.group(1);
          if (numWord != null) {
            // Basic word to number conversion (can be expanded)
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
                // Try parsing as an integer if it's a digit string
                recognizedNumber = int.tryParse(numWord);
                break;
            }
            if (recognizedNumber != null &&
                recognizedNumber! >= 1 &&
                recognizedNumber! <= 16) {
              break; // Found a valid number, stop searching
            } else {
              recognizedNumber = null; // Reset if number is out of range
            }
          }
        }
      }

      if (text.contains('good')) {
        practiceProvider.incrementCounter(
          'good',
          specificNumber: recognizedNumber,
        );
        print(
          'Voice Command: Good shot at spot ${recognizedNumber ?? 'selected/default'}',
        );
      } else if (text.contains('miss') || text.contains('mist')) {
        practiceProvider.incrementCounter(
          'missed',
          specificNumber: recognizedNumber,
        );
        print(
          'Voice Command: Missed shot at spot ${recognizedNumber ?? 'selected/default'}',
        );
      }
      // No need to re-start listening here, the onResult callback handles it
    });
  }

  @override
  void dispose() {
    _voiceDebounce?.cancel();
    _speechToText.stop();
    super.dispose();
  }
}
