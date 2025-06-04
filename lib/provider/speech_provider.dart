// Update SpeechProvider to fix both issues
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Continuous listening flag to prevent beeps
  bool _continuousListening = false;

  bool get isListening => _isListening;
  bool get isVoiceMode => _isVoiceMode;
  SpeechToText get speechToTextInstance => _speechToText;

  static const MethodChannel _audioChannel = MethodChannel(
    'com.example.audio_channel',
  );

  Future<void> _muteSystemSounds() async {
    try {
      await _audioChannel.invokeMethod('muteSounds');
    } catch (e) {
      print('Could not mute sounds: $e');
    }
  }

  Future<void> _unmuteSystemSounds() async {
    try {
      await _audioChannel.invokeMethod('unmuteSounds');
    } catch (e) {
      print('Could not unmute sounds: $e');
    }
  }

  void linkWithPracticeProvider(PracticeProvider provider) {
    _practiceProvider = provider;
  }

  Future<void> _initSpeech() async {
    try {
      // Mute system sounds first
      await _muteSystemSounds();

      // Then initialize speech recognition
      _initialized = await _speechToText.initialize(
        onStatus: _handleStatusUpdate,
        onError: _handleSpeechError,
      );

      if (_initialized) {
        await _startSilentListening();
      }
    } catch (e) {
      print('Speech initialization failed: $e');
      // Ensure sounds are unmuted if initialization fails
      await _unmuteSystemSounds();
    }
  }

  Future<void> _startSilentListening() async {
    try {
      // Start listening in background without UI feedback
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processVoiceCommand(result.recognizedWords.toLowerCase());
          }
        },
        listenFor: Duration(minutes: 30), // Very long duration
        pauseFor: Duration(minutes: 20),
        cancelOnError: true,
        partialResults: false,
        listenMode: ListenMode.confirmation,
        onSoundLevelChange: null, // Disable sound level callbacks
      );
      _continuousListening = true;
    } catch (e) {
      print('Background listening failed: $e');
    }
  }

  void _handleStatusUpdate(String status) {
    // Only update UI listening state if we're in voice mode
    if (_isVoiceMode) {
      _isListening = status == 'listening';
      notifyListeners();
    }

    // Automatically restart if stopped unexpectedly
    if (status == 'notListening' && _continuousListening) {
      _scheduleRestartListening();
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    print('Speech Error: ${error.errorMsg}');
    if (_isVoiceMode) {
      _isListening = false;
      notifyListeners();
      // Ensure sounds are properly managed on error
      _unmuteSystemSounds();
      _muteSystemSounds();
    }
    _scheduleRestartListening();
  }

  Future<void> toggleVoiceMode() async {
    if (!_initialized) await _initSpeech();
    if (!_initialized) return;

    _isVoiceMode = !_isVoiceMode;

    if (_isVoiceMode) {
      await _muteSystemSounds();
      _isListening = _speechToText.isListening;
    } else {
      await _unmuteSystemSounds();
      _isListening = false;
    }

    notifyListeners();
  }

  void _scheduleRestartListening() {
    if (!_continuousListening) return;

    _restartListeningTimer?.cancel();
    _restartListeningTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_speechToText.isListening && _continuousListening) {
        _startSilentListening();
      }
    });
  }

  void _processVoiceCommand(String text) {
    _voiceDebounce?.cancel();
    _voiceDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!_isVoiceMode) return; // Ignore commands when not in voice mode

      final cleanedText = text.trim();
      if (cleanedText.isEmpty || !RegExp(r'[a-zA-Z]').hasMatch(cleanedText)) {
        return;
      }

      if (_practiceProvider == null) return;

      _handleCommand(cleanedText);
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
        listenFor: const Duration(seconds: 30),
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
    _speechToText.cancel();
    _unmuteSystemSounds(); // Restore sounds when provider is disposed
    super.dispose();
  }
}
