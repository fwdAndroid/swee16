// Update SpeechProvider to fix both issues
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:swee16/provider/practice_provider.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isVoiceMode = false;
  Timer? _voiceDebounce;
  Timer? _restartListeningTimer;
  bool _initialized = false;
  PracticeProvider? _practiceProvider;

  // Remove error counter and max retries since we don't want auto-switch
  // int _errorCount = 0;
  // static const int _maxErrorRetries = 3;

  bool get isListening => _isListening;
  bool get isVoiceMode => _isVoiceMode;
  SpeechToText get speechToTextInstance => _speechToText;

  void linkWithPracticeProvider(PracticeProvider provider) {
    _practiceProvider = provider;
  }

  Future<void> _initSpeech() async {
    if (_initialized) return;

    try {
      _initialized = await _speechToText.initialize(
        onStatus: _handleStatusUpdate,
        onError: _handleSpeechError,
      );
    } catch (e) {
      print('Speech initialization failed: $e');
      _initialized = false;
    }
  }

  void _handleStatusUpdate(String status) {
    _isListening = status == 'listening';
    notifyListeners();

    if (status == 'notListening' && _isVoiceMode) {
      _scheduleRestartListening();
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    print('Speech Error: ${error.errorMsg}');
    _isListening = false;
    notifyListeners();

    // Remove auto-increment of missed shots
    // if (error.errorMsg == 'error_no_match' && _practiceProvider != null) {
    //   _practiceProvider!.incrementCounter('missed', specificNumber: null);
    //   _errorCount++;
    // }

    // Remove auto-switch to manual mode
    // if (_errorCount >= _maxErrorRetries) {
    //   _handleExcessiveErrors();
    // } else {
    _scheduleRestartListening();
    // }
  }

  // Remove auto-switch function
  // void _handleExcessiveErrors() {
  //   print('Max error retries reached. Disabling voice mode.');
  //   _isVoiceMode = false;
  //   _isListening = false;
  //   _errorCount = 0;
  //   stopListening();
  //   notifyListeners();
  // }

  Future<void> toggleVoiceMode() async {
    if (!_initialized) await _initSpeech();
    if (!_initialized) return;

    _isVoiceMode = !_isVoiceMode;
    if (_isVoiceMode) {
      // _errorCount = 0;  // No longer needed
      startListening();
    } else {
      stopListening();
    }
    notifyListeners();
  }

  void _scheduleRestartListening() {
    _restartListeningTimer?.cancel();
    _restartListeningTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isVoiceMode && !_speechToText.isListening) {
        startListening();
      }
    });
  }

  Future<void> startListening() async {
    if (!_isVoiceMode || !_initialized) return;
    if (_speechToText.isListening) return;

    try {
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processVoiceCommand(result.recognizedWords.toLowerCase());
            _scheduleRestartListening();
          }
        },
        listenFor: const Duration(seconds: 10),
        cancelOnError: false,
        partialResults: false,
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
      print('Listening start failed: $e');
      _isListening = false;
      notifyListeners();
      _scheduleRestartListening();
    }
  }

  void stopListening() {
    _restartListeningTimer?.cancel();
    _voiceDebounce?.cancel();

    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    _isListening = false;
    notifyListeners();
  }

  void setManualMode() {
    if (_isVoiceMode) {
      print('VOICE DEBUG: Switching to Manual mode.');
      _isVoiceMode = false;
      stopListening();
      notifyListeners();
    }
  }

  void _processVoiceCommand(String text) {
    _voiceDebounce?.cancel();
    _voiceDebounce = Timer(const Duration(milliseconds: 300), () {
      final cleanedText = text.trim();

      if (cleanedText.isEmpty || !RegExp(r'[a-zA-Z]').hasMatch(cleanedText)) {
        print("Ignored voice input: '$text'");
        return;
      }

      if (_practiceProvider == null) {
        print('PracticeProvider not available');
        return;
      }

      final commandHandled = _handleCommand(cleanedText);
      if (!commandHandled) {
        print("Unrecognized command: '$text'");
      }
    });
  }

  bool _handleCommand(String text) {
    final isGood = RegExp(r'\b(good|yes|correct|nice)\b').hasMatch(text);
    final isMissed = RegExp(
      r'\b(m|missed|miss|misst|missing|mist|misset|mi|mis|bad|fail|wrong|no)\b',
    ).hasMatch(text);
    final number = _extractNumber(text);

    if (isGood) {
      _practiceProvider!.incrementCounter('good', specificNumber: number);
      return true;
    } else if (isMissed) {
      _practiceProvider!.incrementCounter('missed', specificNumber: number);
      return true;
    }
    return false;
  }

  int? _extractNumber(String text) {
    const numberWords = {
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

    // Create a safe regex pattern
    final pattern = '\\b(\\d+|${numberWords.keys.join('|')})\\b';
    final match = RegExp(pattern, caseSensitive: false).firstMatch(text);

    if (match != null) {
      final numberString = match.group(1)!.toLowerCase();
      return numberWords[numberString] ?? int.tryParse(numberString);
    }
    return null;
  }

  @override
  void dispose() {
    _voiceDebounce?.cancel();
    _restartListeningTimer?.cancel();
    _speechToText.stop();
    super.dispose();
  }
}
