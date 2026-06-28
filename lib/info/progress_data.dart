class QuizResult {
  final String level;
  final int score;
  final int totalQuestions;
  final DateTime takenDate;
  final bool passed; // Pass = score >= 60%

  QuizResult({
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.takenDate,
    required this.passed,
  });

  double get percentage => (score / totalQuestions) * 100;

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      level: map['level'] as String,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      takenDate: DateTime.parse(map['takenDate'] as String),
      passed: map['passed'] as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'level': level,
    'score': score,
    'totalQuestions': totalQuestions,
    'takenDate': takenDate.toIso8601String(),
    'passed': passed,
  };
}

class ProgressData {
  // ===== LESSON TRACKING =====
  static final Map<String, int> completedLessons = {
    'Beginner': 0,
    'Intermediate': 0,
    'Advanced': 0,
  };

  static final Map<String, int> totalLessons = {
    'Beginner': 10,
    'Intermediate': 10,
    'Advanced': 10,
  };

  // ===== UNLOCK LOGIC =====
  // User can learn a level only if they've passed the quiz for the previous level
  // OR if it's the first level (Beginner)
  static final Map<String, bool> levelUnlocked = {
    'Beginner': true, // Always unlocked
    'Intermediate': false, // Unlocked after passing Beginner quiz
    'Advanced': false, // Unlocked after passing Intermediate quiz
  };

  // ===== QUIZ TRACKING =====
  // Stores all quiz attempts (allows multiple retakes)
  static final Map<String, List<QuizResult>> quizResults = {
    'Beginner': [],
    'Intermediate': [],
    'Advanced': [],
  };

  // Track if user has passed each level's quiz
  static final Map<String, bool> quizPassed = {
    'Beginner': false,
    'Intermediate': false,
    'Advanced': false,
  };

  // ===== PROGRESS CALCULATIONS =====

  /// Get overall progress (0.0 to 1.0)
  static double getProgress(String level) {
    int completed = completedLessons[level] ?? 0;
    int total = totalLessons[level] ?? 1;
    return (completed / total).clamp(0.0, 1.0);
  }

  /// Check if a level is unlocked for learning
  static bool isLevelUnlocked(String level) {
    return levelUnlocked[level] ?? false;
  }

  /// Unlock a level after passing its prerequisite quiz
  static void unlockLevel(String level) {
    if (levelUnlocked.containsKey(level)) {
      levelUnlocked[level] = true;
    }
  }

  /// Record a quiz attempt
  static void recordQuizAttempt({
    required String level,
    required int score,
    required int totalQuestions,
  }) {
    bool passed = (score / totalQuestions) >= 0.6; // 60% pass threshold

    final result = QuizResult(
      level: level,
      score: score,
      totalQuestions: totalQuestions,
      takenDate: DateTime.now(),
      passed: passed,
    );

    quizResults[level]?.add(result);

    // If passed, mark quiz as passed and unlock next level
    if (passed) {
      quizPassed[level] = true;

      // Unlock next level
      if (level == 'Beginner') {
        unlockLevel('Intermediate');
      } else if (level == 'Intermediate') {
        unlockLevel('Advanced');
      }

      // Mark all lessons as completed when quiz is passed
      completedLessons[level] = totalLessons[level] ?? 0;
    }
  }

  /// Get the latest quiz result for a level
  static QuizResult? getLatestQuizResult(String level) {
    final results = quizResults[level];
    if (results == null || results.isEmpty) return null;
    return results.last;
  }

  /// Get all quiz results for a level
  static List<QuizResult> getAllQuizResults(String level) {
    return quizResults[level] ?? [];
  }

  /// Get the best (highest score) quiz result for a level
  static QuizResult? getBestQuizResult(String level) {
    final results = quizResults[level];
    if (results == null || results.isEmpty) return null;
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.first;
  }

  /// Update lesson progress
  static void updateLessonProgress(String level, int lessonsCompleted) {
    if (completedLessons.containsKey(level)) {
      int total = totalLessons[level] ?? 1;
      completedLessons[level] = lessonsCompleted.clamp(0, total);
    }
  }

  // ===== GPA CALCULATION =====

  /// Calculate overall GPA (based on all passed quizzes: A=4.0, B=3.0, C=2.0, D=1.0)
  static double calculateGPA() {
    List<double> allScores = [];

    for (var level in quizResults.keys) {
      final results = quizResults[level] ?? [];
      for (var result in results) {
        if (result.passed) {
          allScores.add(result.percentage);
        }
      }
    }

    if (allScores.isEmpty) return 0.0;

    double avgPercentage = allScores.reduce((a, b) => a + b) / allScores.length;
    return percentageToGPA(avgPercentage);
  }

  /// Convert percentage score to GPA (4.0 scale)
  /// A (90-100) = 4.0
  /// B (80-89) = 3.0
  /// C (70-79) = 2.0
  /// D (60-69) = 1.0
  /// F (below 60) = 0.0
  static double percentageToGPA(double percentage) {
    if (percentage >= 90) return 4.0;
    if (percentage >= 80) return 3.0;
    if (percentage >= 70) return 2.0;
    if (percentage >= 60) return 1.0;
    return 0.0;
  }

  /// Get letter grade from percentage
  static String getLetterGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  /// Calculate GPA for a specific level
  static double calculateLevelGPA(String level) {
    final results = quizResults[level];
    if (results == null || results.isEmpty) return 0.0;

    final passedResults = results.where((r) => r.passed).toList();
    if (passedResults.isEmpty) return 0.0;

    double avgPercentage =
        passedResults.map((r) => r.percentage).reduce((a, b) => a + b) /
        passedResults.length;
    return percentageToGPA(avgPercentage);
  }

  /// Get detailed GPA information for certificate
  static Map<String, dynamic> getGPAInfo() {
    double overallGPA = calculateGPA();
    Map<String, double> levelGPAs = {};
    Map<String, int> passAttempts = {};

    for (var level in ['Beginner', 'Intermediate', 'Advanced']) {
      levelGPAs[level] = calculateLevelGPA(level);
      final results = quizResults[level] ?? [];
      passAttempts[level] = results.where((r) => r.passed).length;
    }

    return {
      'overallGPA': overallGPA,
      'letterGrade': getLetterGrade(overallGPA * 25), // Convert 4.0 scale to %
      'levelGPAs': levelGPAs,
      'passAttempts': passAttempts,
      'completionDate': DateTime.now(),
      'allLevelsPassed': quizPassed.values.every((p) => p),
    };
  }

  /// Check if user completed all levels
  static bool hasCompletedAllLevels() {
    return quizPassed['Beginner'] == true &&
        quizPassed['Intermediate'] == true &&
        quizPassed['Advanced'] == true;
  }

  /// Reset all progress (for testing/reset account)
  static void resetAllProgress() {
    completedLessons.updateAll((key, value) => 0);
    levelUnlocked.updateAll((key, value) => key == 'Beginner');
    quizResults.forEach((key, value) => value.clear());
    quizPassed.updateAll((key, value) => false);
  }

  /// Reset a specific level
  static void resetLevel(String level) {
    completedLessons[level] = 0;
    quizResults[level]?.clear();
    quizPassed[level] = false;

    if (level == 'Beginner') {
      levelUnlocked['Intermediate'] = false;
      levelUnlocked['Advanced'] = false;
    } else if (level == 'Intermediate') {
      levelUnlocked['Advanced'] = false;
    }
  }
}
