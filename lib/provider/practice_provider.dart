import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:provider/provider.dart';
import 'package:swee16/provider/speech_provider.dart';
import 'package:swee16/services/database_service.dart'; // Make sure this path is correct

class PracticeProvider extends ChangeNotifier {
  final Battery _battery = Battery();
  int? _batteryLevel;
  int? _selectedNumber;
  Offset? _selectedPosition;
  Map<int, int> _goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
  Map<int, int> _missedCounts = {for (var i = 1; i <= 16; i++) i: 0};
  List<Map<String, dynamic>> _actionHistory = [];
  bool _showUndo = false; // Internal flag for undo button logic

  final FirestoreService _firestoreService = FirestoreService();
  final AudioPlayer _goodSoundPlayer = AudioPlayer();
  final AudioPlayer _missedSoundPlayer = AudioPlayer();
  // Expose getters for state
  int? get batteryLevel => _batteryLevel;
  int? get selectedNumber => _selectedNumber;
  Offset? get selectedPosition => _selectedPosition;
  Map<int, int> get goodCounts => _goodCounts;
  Map<int, int> get missedCounts => _missedCounts;
  List<Map<String, dynamic>> get actionHistory => _actionHistory;
  bool get showUndo => _showUndo; // Currently not used in UI but good to expose

  int get totalGood => _goodCounts.values.fold(0, (a, b) => a + b);
  int get totalMissed => _missedCounts.values.fold(0, (a, b) => a + b);

  // Constructor
  PracticeProvider() {
    _checkBatteryLevel();
    // Periodic battery check every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) => _checkBatteryLevel());
  }

  // Method to check battery level
  Future<void> _checkBatteryLevel() async {
    _batteryLevel = await _battery.batteryLevel;
    notifyListeners();
  }

  // Method to handle spot selection (from UI taps)
  void handleNumberTap(int number, double scaledX, double scaledY) {
    if (_selectedNumber == number) {
      // Deselect if already selected
      _selectedNumber = null;
      _selectedPosition = null;
    } else {
      // Select the new spot
      _selectedNumber = number;
      _selectedPosition = Offset(scaledX, scaledY);
    }
    notifyListeners(); // Notify listeners that state has changed
  }

  // Method to increment good/missed counts
  // This can be called from UI buttons OR voice commands
  void incrementCounter(String type, {int? specificNumber}) async {
    // If a specificNumber is provided (e.g., from a voice command "Good 5"), use it.
    // Otherwise, use the currently selected number.
    // If no number is selected, default to spot 1 (as in your original code)
    final int targetNumber = specificNumber ?? _selectedNumber ?? 1;

    // Ensure the targetNumber is within your valid range (1-16)
    if (targetNumber < 1 || targetNumber > 16) {
      print("Invalid shot number: $targetNumber");
      return; // Do not proceed with invalid number
    }

    if (type == 'good') {
      _goodCounts[targetNumber] = (_goodCounts[targetNumber] ?? 0) + 1;
    } else if (type == 'missed') {
      _missedCounts[targetNumber] = (_missedCounts[targetNumber] ?? 0) + 1;
    }
    if (type == 'good') {
      await _playSound(_goodSoundPlayer, 'sounds/good.mp3');
    } else if (type == 'missed') {
      await _playSound(_missedSoundPlayer, 'sounds/missed.mp3');
    }
    _actionHistory.add({'type': type, 'number': targetNumber});
    _showUndo = _actionHistory.isNotEmpty; // Update undo flag
    notifyListeners(); // Notify listeners that state has changed
  }

  Future<void> _playSound(AudioPlayer player, String assetPath) async {
    try {
      await player.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Method to undo the last action
  void undoLastAction() {
    if (_actionHistory.isEmpty) return;

    var lastAction = _actionHistory.removeLast();
    int number = lastAction['number'];
    String type = lastAction['type'];

    if (type == 'good' && _goodCounts[number]! > 0) {
      _goodCounts[number] = _goodCounts[number]! - 1;
    } else if (type == 'missed' && _missedCounts[number]! > 0) {
      _missedCounts[number] = _missedCounts[number]! - 1;
    }

    // Preserve selection if it's the same number
    if (_selectedNumber == number) {
      _selectedNumber = number;
    } else {
      _selectedNumber = null;
      _selectedPosition = null;
    }

    _showUndo = _actionHistory.isNotEmpty;
    notifyListeners();
  }

  void manualIncrementCounter(String type) async {
    if (_selectedNumber == null) return;

    if (type == 'good') {
      _goodCounts[_selectedNumber!] = (_goodCounts[_selectedNumber!] ?? 0) + 1;
    } else if (type == 'missed') {
      _missedCounts[_selectedNumber!] =
          (_missedCounts[_selectedNumber!] ?? 0) + 1;
    }
    if (type == 'good') {
      await _playSound(_goodSoundPlayer, 'sounds/good.mp3');
    } else if (type == 'missed') {
      await _playSound(_missedSoundPlayer, 'sounds/missed.mp3');
    }
    _actionHistory.add({'type': type, 'number': _selectedNumber!});
    _showUndo = _actionHistory.isNotEmpty;
    notifyListeners();
  }

  // Save practice results
  Future<bool> savePracticeResults(BuildContext context) async {
    // Disable voice mode if active when saving, as it's a new session
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    speechProvider.setManualMode(); // This will also stop listening

    final success = await _firestoreService.savePracticeSession(
      _goodCounts,
      _missedCounts,
    );

    if (success) {
      _resetPracticeData(); // Reset after successful save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Practice session saved!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save session'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return success;
  }

  // Delete all practice results
  void deletePracticeResults(BuildContext context) {
    // Disable voice mode if active
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    speechProvider.setManualMode(); // This will also stop listening

    _resetPracticeData(); // Reset all data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All practice data cleared!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper to reset all practice data
  void _resetPracticeData() {
    _goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
    _missedCounts = {for (var i = 1; i <= 16; i++) i: 0};
    _actionHistory.clear();
    _selectedNumber = null;
    _selectedPosition = null;
    _showUndo = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // No specific disposables needed for PracticeProvider itself
    super.dispose();
  }
}
