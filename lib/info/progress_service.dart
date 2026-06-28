import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../info/progress_data.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection name for progress data
  static const String _progressCollection = 'userProgress';

  /// Load all progress from Firestore and populate ProgressData
  Future<void> loadProgressData() async {
    try {
      if (_userId.isEmpty) {
        debugPrint('No user logged in, skipping progress load');
        return;
      }

      final doc = await _firestore
          .collection(_progressCollection)
          .doc(_userId)
          .get();

      if (!doc.exists) {
        debugPrint('No progress data found for user, using defaults');
        return;
      }

      final data = doc.data() ?? {};

      // Load completed lessons
      if (data['completedLessons'] is Map) {
        Map<String, dynamic> lessons = data['completedLessons'];
        lessons.forEach((level, completed) {
          if (ProgressData.completedLessons.containsKey(level)) {
            ProgressData.completedLessons[level] = completed as int? ?? 0;
          }
        });
      }

      // Load level unlock status
      if (data['levelUnlocked'] is Map) {
        Map<String, dynamic> unlocked = data['levelUnlocked'];
        unlocked.forEach((level, isUnlocked) {
          if (ProgressData.levelUnlocked.containsKey(level)) {
            ProgressData.levelUnlocked[level] = isUnlocked as bool? ?? false;
          }
        });
      }

      // Load quiz passed status
      if (data['quizPassed'] is Map) {
        Map<String, dynamic> passed = data['quizPassed'];
        passed.forEach((level, isPassed) {
          if (ProgressData.quizPassed.containsKey(level)) {
            ProgressData.quizPassed[level] = isPassed as bool? ?? false;
          }
        });
      }

      // Load quiz results
      if (data['quizResults'] is Map) {
        Map<String, dynamic> results = data['quizResults'];
        results.forEach((level, resultsList) {
          if (ProgressData.quizResults.containsKey(level) &&
              resultsList is List) {
            ProgressData.quizResults[level]!.clear();
            for (var result in resultsList) {
              try {
                ProgressData.quizResults[level]!.add(
                  QuizResult.fromMap(result),
                );
              } catch (e) {
                debugPrint('Error loading quiz result: $e');
              }
            }
          }
        });
      }

      debugPrint('Progress data loaded successfully from Firestore');
    } catch (e) {
      debugPrint('Error loading progress data: $e');
    }
  }

  /// Save all progress to Firestore
  Future<void> saveProgressData() async {
    try {
      if (_userId.isEmpty) {
        debugPrint('No user logged in, skipping save');
        return;
      }

      // Convert quizResults to serializable format
      Map<String, List<Map<String, dynamic>>> serializedResults = {};
      ProgressData.quizResults.forEach((level, results) {
        serializedResults[level] = results.map((r) => r.toMap()).toList();
      });

      await _firestore.collection(_progressCollection).doc(_userId).set({
        'completedLessons': ProgressData.completedLessons,
        'levelUnlocked': ProgressData.levelUnlocked,
        'quizPassed': ProgressData.quizPassed,
        'quizResults': serializedResults,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Progress data saved to Firestore');
    } catch (e) {
      debugPrint('Error saving progress data: $e');
    }
  }

  /// Save after quiz completion
  Future<void> saveQuizAttempt({
    required String level,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      // Record in ProgressData
      ProgressData.recordQuizAttempt(
        level: level,
        score: score,
        totalQuestions: totalQuestions,
      );

      // Save to Firestore
      await saveProgressData();
      debugPrint('Quiz attempt saved for $level');
    } catch (e) {
      debugPrint('Error saving quiz attempt: $e');
    }
  }

  /// Save lesson progress
  Future<void> saveLessonProgress({
    required String level,
    required int lessonsCompleted,
  }) async {
    try {
      ProgressData.updateLessonProgress(level, lessonsCompleted);
      await saveProgressData();
      debugPrint('Lesson progress saved for $level');
    } catch (e) {
      debugPrint('Error saving lesson progress: $e');
    }
  }

  /// Reset all progress (for testing)
  Future<void> resetAllProgress() async {
    try {
      ProgressData.resetAllProgress();
      await _firestore.collection(_progressCollection).doc(_userId).delete();
      debugPrint('All progress reset');
    } catch (e) {
      debugPrint('Error resetting progress: $e');
    }
  }

  /// Reset specific level (for testing)
  Future<void> resetLevel(String level) async {
    try {
      ProgressData.resetLevel(level);
      await saveProgressData();
      debugPrint('Level $level reset');
    } catch (e) {
      debugPrint('Error resetting level: $e');
    }
  }
}
