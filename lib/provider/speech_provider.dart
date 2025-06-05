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

  // --- ADDED: Method to set media volume to full ---
  Future<void> _setMediaVolumeFull() async {
    try {
      await _audioChannel.invokeMethod('setMediaVolumeFull');
      print('Dart: Called setMediaVolumeFull native method.');
    } catch (e) {
      print('Dart: Could not set media volume to full: $e');
    }
  }

  // --- MODIFIED: These will now use the specific mute/unmute system sounds methods ---
  Future<void> _muteSystemSounds() async {
    try {
      await _audioChannel.invokeMethod('muteSounds');
      print('Dart: Called muteSounds native method.');
    } catch (e) {
      print('Dart: Could not mute sounds: $e');
    }
  }

  Future<void> _unmuteSystemSounds() async {
    try {
      await _audioChannel.invokeMethod('unmuteSounds');
      print('Dart: Called unmuteSounds native method.');
    } catch (e) {
      print('Dart: Could not unmute sounds: $e');
    }
  }

  void linkWithPracticeProvider(PracticeProvider provider) {
    _practiceProvider = provider;
  }

  Future<void> _initSpeech() async {
    try {
      // 1. Set media volume to full FIRST
      await _setMediaVolumeFull();

      // 2. Then mute system sounds for speech recognition
      await _muteSystemSounds();

      // 3. Initialize speech recognition
      _initialized = await _speechToText.initialize(
        onStatus: _handleStatusUpdate,
        onError: _handleSpeechError,
      );

      if (_initialized) {
        await _startSilentListening();
      }
      print('Dart: Speech initialization completed: $_initialized');
    } catch (e) {
      print('Dart: Speech initialization failed: $e');
      // Ensure sounds are unmuted if initialization fails
      await _unmuteSystemSounds();
    }
  }

  Future<void> _startSilentListening() async {
    // REMOVED: if (_speechToText.isListening) check.
    // This allows the method to always attempt to start listening
    // when called in a context where continuous listening is desired.

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processVoiceCommand(result.recognizedWords.toLowerCase());
          }
        },
        listenFor: Duration(minutes: 30),
        pauseFor: Duration(minutes: 20),
        cancelOnError: true,
        partialResults: false,
        listenMode: ListenMode.confirmation,
        onSoundLevelChange: null,
      );
      _continuousListening =
          true; // Ensure this is set when silent listening starts
      _isListening = true; // Update internal state
      print('VOICE DEBUG: Started silent listening.');
    } catch (e) {
      print('Background listening failed: $e');
      _continuousListening = false;
      _isListening = false; // Update internal state on failure
    } finally {
      notifyListeners(); // Notify listeners of state change
    }
  }

  void _handleStatusUpdate(String status) {
    if (_isVoiceMode) {
      _isListening = status == 'listening';
      notifyListeners();
    }

    if (status == 'notListening' && _continuousListening) {
      print(
        'VOICE DEBUG: Speech recognition stopped unexpectedly. Restarting silent listening.',
      );
      _scheduleRestartListening();
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    print('Speech Error: ${error.errorMsg}');
    if (_isVoiceMode) {
      _isListening = false;
      notifyListeners();
      // On error, ensure sounds are properly managed. Mute then unmute might reset
      // or simply rely on the unmuting when voice mode is off or disposing.
      // For persistent mute, keeping these, but be aware of the impact.
      _unmuteSystemSounds();
      _muteSystemSounds();
    }
    if (_continuousListening) {
      _scheduleRestartListening();
    }
  }

  Future<void> toggleVoiceMode() async {
    if (!_initialized) await _initSpeech();
    if (!_initialized) {
      print(
        'VOICE DEBUG: Speech initialization failed, cannot toggle voice mode.',
      );
      return;
    }

    // Always stop listening first to ensure a clean state before toggling mode
    if (_speechToText.isListening) {
      _speechToText.stop();
      _isListening = false; // Update internal state immediately
      notifyListeners();
      print('VOICE DEBUG: Stopping existing listening before toggling mode.');
    }

    _isVoiceMode = !_isVoiceMode;
    print('VOICE DEBUG: Voice mode toggled to $_isVoiceMode.');

    if (_isVoiceMode) {
      await _muteSystemSounds(); // Mute system sounds for voice recognition
      _continuousListening =
          true; // Ensure continuous listening is active for voice mode
      await _startSilentListening(); // Explicitly restart listening
      _isListening = _speechToText.isListening;
    } else {
      await _unmuteSystemSounds(); // Unmute system sounds when switching to manual
      stopListening(); // Stop any active listening (this will also set _continuousListening to false)
    }

    notifyListeners();
  }

  void _scheduleRestartListening() {
    if (!_continuousListening) {
      print(
        'VOICE DEBUG: Not in continuous listening mode, not scheduling restart.',
      );
      return;
    }

    _restartListeningTimer?.cancel();
    _restartListeningTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_speechToText.isListening && _continuousListening) {
        print(
          'VOICE DEBUG: Attempting to restart silent listening from timer.',
        );
        _startSilentListening();
      }
    });
  }

  void _processVoiceCommand(String text) {
    _voiceDebounce?.cancel();
    _voiceDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!_isVoiceMode) return;

      final cleanedText = text.trim();
      if (cleanedText.isEmpty || !RegExp(r'[a-zA-Z]').hasMatch(cleanedText)) {
        return;
      }

      if (_practiceProvider == null) return;

      _handleCommand(cleanedText);
    });
  }

  // In SpeechProvider class
  // In SpeechProvider
  bool _handleCommand(String text) {
    final isGood = RegExp(r'\b(good|yes|correct|nice)\b').hasMatch(text);
    final isMissed = RegExp(
      r'\b(m|missed|miss|misst|missing|mist|misset|mi|mis|bad|fail|wrong|no)\b',
    ).hasMatch(text);
    final number = _extractNumber(text);

    if (_practiceProvider?.selectedNumber == null) {
      _practiceProvider?.showErrorMessage("Please tap any spot first");
      return false;
    }

    if (isGood) {
      _practiceProvider!.incrementCounter(
        'good',
        specificNumber: number ?? _practiceProvider!.selectedNumber,
      );
      return true;
    } else if (isMissed) {
      _practiceProvider!.incrementCounter(
        'missed',
        specificNumber: number ?? _practiceProvider!.selectedNumber,
      );
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
          }
        },
        listenFor: const Duration(seconds: 30),
        cancelOnError: false,
        partialResults: false,
        listenMode: ListenMode.dictation,
      );
      print('VOICE DEBUG: Started active dictation listening.');
    } catch (e) {
      print('Listening start failed: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  void stopListening() {
    _restartListeningTimer?.cancel();
    _voiceDebounce?.cancel();

    if (_speechToText.isListening) {
      _speechToText.stop();
      print('VOICE DEBUG: Speech recognition stopped.');
    }
    _continuousListening = false;
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
    _unmuteSystemSounds(); // Ensure sounds are restored on dispose
    super.dispose();
  }
}
