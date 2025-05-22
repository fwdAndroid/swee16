import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:swee16/services/database_service.dart';

TextEditingController emailController = TextEditingController();
stt.SpeechToText speech = stt.SpeechToText();
bool isListening = false;
bool isVoiceMode = false;
List<Map<String, dynamic>> actionHistory = [];
bool showUndo = false;
int? selectedNumber;
Offset? selectedPosition;
// Ensure they’re not null
Map<int, int> goodCounts = {for (var i = 1; i <= 16; i++) i: 0};
Map<int, int> missedCounts = {for (var i = 1; i <= 16; i++) i: 0};

int get totalGood => goodCounts.values.fold(0, (a, b) => a + b);
int get totalMissed => missedCounts.values.fold(0, (a, b) => a + b);
final FirestoreService firestoreService = FirestoreService();
