import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  Future<bool> savePracticeSession(
    Map<int, int> goodCounts,
    Map<int, int> missedCounts,
  ) async {
    try {
      final String sessionId = _uuid.v4();
      final Map<String, dynamic> sessionData = {};

      // Add only numbers with attempts
      for (int number = 1; number <= 16; number++) {
        final good = goodCounts[number]!;
        final missed = missedCounts[number]!;

        if (good > 0 || missed > 0) {
          final total = good + missed;
          sessionData['$number'] = {
            'good': good,
            'missed': missed,
            'percentage': total > 0 ? (good / total * 100).round() : 0,
          };
        }
      }

      // Add metadata
      sessionData['session_id'] = sessionId;
      sessionData['timestamp'] = FieldValue.serverTimestamp();
      sessionData['uid'] = FirebaseAuth.instance.currentUser?.uid;

      // Set document with UUID
      await _firestore
          .collection('practice_sessions')
          .doc(sessionId)
          .set(sessionData);

      return true;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
  }

  void deleteSession(String sessionId) async {
    await _firestore.collection('practice_sessions').doc(sessionId).delete();
  }
}
