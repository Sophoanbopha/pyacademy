import 'package:flutter/material.dart';
import '../info/progress_data.dart';
import '../info/progress_service.dart';
import 'lesson_screen.dart';
import 'CertificateScreen.dart';
import 'home_screen.dart';

class QuizScreen extends StatefulWidget {
  final String level;
  final int quizNumber;

  const QuizScreen({super.key, required this.level, required this.quizNumber});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int index = 0;
  int score = 0;
  final TextEditingController answerCtrl = TextEditingController();
  bool _hasSubmittedQuiz = false;
  late QuizResult _quizResult;
  late ProgressService _progressService;

  // ================= QUIZ DATA =================
  final Map<String, List<Map<String, dynamic>>> quizData = {
    'Beginner': [
      {
        'type': 'mcq',
        'question': 'What is Python?',
        'options': [
          'A snake',
          'A programming language',
          'A game',
          'A database',
        ],
        'answer': 1,
      },
      {
        'type': 'truefalse',
        'question': 'Python is case-sensitive.',
        'answer': true,
      },
      {
        'type': 'fill',
        'question': 'Which keyword is used to define a function?',
        'answer': 'def',
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code': 'print(2 + 3)',
        'answer': '5',
      },
      {
        'type': 'mcq',
        'question': 'Which symbol starts a comment in Python?',
        'options': ['#', '//', '/*', '--'],
        'answer': 0,
      },
      {
        'type': 'truefalse',
        'question': 'print() outputs text to the console.',
        'answer': true,
      },
      {
        'type': 'fill',
        'question': 'How do you create an empty list?',
        'answer': '[]',
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code': 'x = 5\nx += 2\nprint(x)',
        'answer': '7',
      },
      {
        'type': 'mcq',
        'question': 'Which function converts a string to an integer?',
        'options': ['int', 'str', 'float', 'input'],
        'answer': 0,
      },
      {
        'type': 'fill',
        'question': 'Keyword used to start a loop over a sequence?',
        'answer': 'for',
      },
    ],
    'Intermediate': [
      {
        'type': 'mcq',
        'question': 'Which data type stores key-value pairs?',
        'options': ['List', 'Tuple', 'Dictionary', 'Set'],
        'answer': 2,
      },
      {'type': 'truefalse', 'question': 'Tuples are mutable.', 'answer': false},
      {
        'type': 'fill',
        'question': 'Keyword used to handle errors?',
        'answer': 'try',
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code': 'nums = [1,2,3]\nprint(len(nums))',
        'answer': '3',
      },
      {
        'type': 'mcq',
        'question': 'Which method adds an item to the end of a list?',
        'options': ['append', 'add', 'insert', 'push'],
        'answer': 0,
      },
      {
        'type': 'truefalse',
        'question': 'Dictionary keys must be unique.',
        'answer': true,
      },
      {
        'type': 'fill',
        'question': 'Keyword used to define a class?',
        'answer': 'class',
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code': 'nums = [1,2,3,4]\nprint(nums[1])',
        'answer': '2',
      },
      {
        'type': 'mcq',
        'question': 'Which file mode opens a file for appending?',
        'options': ['a', 'w', 'r', 'x'],
        'answer': 0,
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code': "d = {'a':1,'b':2}\nprint(d.get('c', 0))",
        'answer': '0',
      },
    ],
    'Advanced': [
      {
        'type': 'mcq',
        'question': 'OOP stands for?',
        'options': [
          'Object Oriented Programming',
          'Open Object Protocol',
          'Order of Process',
          'None',
        ],
        'answer': 0,
      },
      {
        'type': 'truefalse',
        'question': 'Inheritance allows code reuse.',
        'answer': true,
      },
      {
        'type': 'fill',
        'question': 'Special method used as constructor?',
        'answer': '__init__',
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code': 'class A:\n  pass\nprint(type(A()))',
        'answer': "<class '__main__.A'>",
      },
      {
        'type': 'mcq',
        'question': 'A class that cannot be instantiated directly is called?',
        'options': [
          'Abstract class',
          'Final class',
          'Static class',
          'Private class',
        ],
        'answer': 0,
      },
      {
        'type': 'truefalse',
        'question':
            'Polymorphism allows a common interface for different types.',
        'answer': true,
      },
      {
        'type': 'fill',
        'question': 'Keyword used to create a generator?',
        'answer': 'yield',
      },
      {
        'type': 'code',
        'question': 'What is the output?',
        'code':
            'class A:\n  def __init__(self):\n    self.x = 1\na = A()\nprint(a.x)',
        'answer': '1',
      },
      {
        'type': 'mcq',
        'question':
            'Which decorator makes a method receive the class as first argument?',
        'options': [
          '@classmethod',
          '@staticmethod',
          '@property',
          '@abstractmethod',
        ],
        'answer': 0,
      },
      {
        'type': 'fill',
        'question': 'Method name used for user-friendly string representation?',
        'answer': '__str__',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _progressService = ProgressService();
  }

  void submitAnswer(dynamic userAnswer) {
    final correct = quizData[widget.level]![index]['answer'];

    if (userAnswer.toString().toLowerCase().trim() ==
        correct.toString().toLowerCase().trim()) {
      score++;
    }

    answerCtrl.clear();
    setState(() => index++);
  }

  void _finishQuiz() {
    final questions = quizData[widget.level]!;
    final percentage = (score / questions.length) * 100;
    final passed = percentage >= 60; // 60% pass threshold

    _quizResult = QuizResult(
      level: widget.level,
      score: score,
      totalQuestions: questions.length,
      takenDate: DateTime.now(),
      passed: passed,
    );

    // Save the quiz attempt
    _progressService.saveQuizAttempt(
      level: widget.level,
      score: score,
      totalQuestions: questions.length,
    );

    setState(() {
      _hasSubmittedQuiz = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = quizData[widget.level]!;

    // ===== RESULT SCREEN =====
    if (_hasSubmittedQuiz) {
      return _buildResultScreen(context, questions);
    }

    // ===== QUIZ IN PROGRESS =====
    if (index >= questions.length) {
      // Auto-show results
      _finishQuiz();
      return _buildResultScreen(context, questions);
    }

    final q = questions[index];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0618).withOpacity(0.8),
        elevation: 0,
        title: Text(
          '${widget.level} Quiz',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            LinearProgressIndicator(
              value: (index + 1) / questions.length,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7B2CBF)),
            ),
            const SizedBox(height: 16),

            Text(
              'Question ${index + 1}/${questions.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              q['question'],
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // ===== MCQ =====
            if (q['type'] == 'mcq')
              ...List.generate(q['options'].length, (i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => submitAnswer(i),
                    child: Text(q['options'][i]),
                  ),
                );
              }),

            // ===== TRUE / FALSE =====
            if (q['type'] == 'truefalse')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2CBF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => submitAnswer(true),
                      child: const Text('True'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A189A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => submitAnswer(false),
                      child: const Text('False'),
                    ),
                  ),
                ],
              ),

            // ===== FILL IN BLANK =====
            if (q['type'] == 'fill')
              Column(
                children: [
                  TextField(
                    controller: answerCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Your answer',
                      labelStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7B2CBF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7B2CBF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: () => submitAnswer(answerCtrl.text),
                    child: const Text('Submit'),
                  ),
                ],
              ),

            // ===== CODE OUTPUT =====
            if (q['type'] == 'code')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      q['code'],
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Color(0xFF90EE90),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: answerCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Expected output',
                      labelStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7B2CBF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7B2CBF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: () => submitAnswer(answerCtrl.text),
                    child: const Text('Submit'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ===== RESULT SCREEN =====
  Widget _buildResultScreen(
    BuildContext context,
    List<Map<String, dynamic>> questions,
  ) {
    final percentage = (_quizResult.percentage).toStringAsFixed(1);
    final isPassed = _quizResult.passed;
    final levelGPA = ProgressData.calculateLevelGPA(widget.level);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0618).withOpacity(0.8),
        elevation: 0,
        title: const Text('Quiz Result', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Result Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isPassed
                          ? [const Color(0xFF7B2CBF), const Color(0xFF5A189A)]
                          : [Colors.red.shade700, Colors.red.shade900],
                    ),
                  ),
                  child: Icon(
                    isPassed ? Icons.check_circle : Icons.error_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),

                // Status Text
                Text(
                  isPassed ? '🎉 Passed!' : '❌ Failed',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),

                // Score Display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF7B2CBF).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Score',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_quizResult.score} / ${_quizResult.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF7B2CBF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grade
                      Text(
                        'Grade: ${ProgressData.getLetterGrade(_quizResult.percentage)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GPA: ${levelGPA.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7B2CBF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pass/Fail Message
                if (isPassed)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '✨ Excellent Work!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSuccessMessage(widget.level),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '📚 Keep Learning!',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You need 60% to pass. Review the lessons and try again!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isPassed)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B2CBF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // Reset quiz to retake
                          setState(() {
                            index = 0;
                            score = 0;
                            _hasSubmittedQuiz = false;
                            answerCtrl.clear();
                          });
                        },
                        child: const Text(
                          'Retake Quiz',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    if (!isPassed) const SizedBox(height: 12),
                    if (isPassed)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B2CBF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (widget.level == 'Advanced') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CertificateScreen(),
                              ),
                            );
                            return;
                          }

                          final nextLevel = _getNextLevel(widget.level);
                          if (nextLevel == null) {
                            Navigator.pop(context);
                            return;
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonContentScreen(
                                level: nextLevel,
                                lessonNumber: 1,
                              ),
                            ),
                          );
                        },
                        child: _getNextButtonText(widget.level),
                      ),
                    if (isPassed) const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A189A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Back to Menu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSuccessMessage(String level) {
    switch (level) {
      case 'Beginner':
        return 'You\'ve mastered the basics! Intermediate level is now unlocked.';
      case 'Intermediate':
        return 'Great progress! Advanced level is now unlocked.';
      case 'Advanced':
        return 'Congratulations! You\'ve completed all levels. Your certificate is ready!';
      default:
        return 'Amazing performance!';
    }
  }

  Widget _getNextButtonText(String level) {
    switch (level) {
      case 'Beginner':
        return const Text('Learn Intermediate');
      case 'Intermediate':
        return const Text('Learn Advanced');
      case 'Advanced':
        return const Text('View Certificate');
      default:
        return const Text('Continue');
    }
  }

  String? _getNextLevel(String level) {
    switch (level) {
      case 'Beginner':
        return 'Intermediate';
      case 'Intermediate':
        return 'Advanced';
      case 'Advanced':
        return null;
      default:
        return null;
    }
  }
}
