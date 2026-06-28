import 'package:flutter/material.dart';
import '../info/progress_data.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'CertificateScreen.dart';

class LevelScreen extends StatefulWidget {
  final String mode; // 'learn' or 'quiz'

  const LevelScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late String _mode;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_slideController);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // 🔧 FIX: Refresh level screen when returning from quiz
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force rebuild when app returns to foreground
      setState(() {});
    }
  }

  // 🔧 FIX: Override the build to always check latest unlock state
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;

    return WillPopScope(
      onWillPop: () async {
        // 🔧 FIX: Rebuild when user presses back
        setState(() {});
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0618),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5A189A),
          elevation: 0,
          title: Text(
            _mode == 'learn'
                ? 'Select Level to Learn'
                : 'Select Level for Quiz',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(
                  isMobile
                      ? 16
                      : isTablet
                      ? 20
                      : 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isMobile ? 12 : 20),
                        Text(
                          'Choose Your Level',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(
                          _mode == 'learn'
                              ? 'Learn new concepts'
                              : 'Test your knowledge',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 48),
                        _buildLevelButton(
                          context,
                          level: 'Beginner',
                          icon: Icons.school_rounded,
                          description: 'Start from basics',
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildLevelButton(
                          context,
                          level: 'Intermediate',
                          icon: Icons.trending_up_rounded,
                          description: 'Improve your skills',
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildLevelButton(
                          context,
                          level: 'Advanced',
                          icon: Icons.rocket_launch_rounded,
                          description: 'Master the concepts',
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        // Certificate Button for Quiz Mode
                        if (_mode == 'quiz' &&
                            ProgressData.getGPAInfo()['allLevelsPassed'] ==
                                true)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isMobile ? 20 : 24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7B2CBF,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CertificateScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '🎉 Congratulations!',
                                        style: TextStyle(
                                          fontSize: isMobile ? 20 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'You\'ve completed all quizzes!',
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'View Certificate',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7B2CBF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: isMobile ? 32 : 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context, {
    required String level,
    required IconData icon,
    required String description,
    required bool isMobile,
    required bool isTablet,
  }) {
    // 🔧 FIX: Always read fresh unlock state
    bool isUnlocked = ProgressData.isLevelUnlocked(level);
    bool isQuizPassed = ProgressData.quizPassed[level] ?? false;

    // 🔧 FIX: Determine if button should be clickable
    bool canAccess = _mode == 'learn'
        ? isUnlocked
        : isUnlocked && !isQuizPassed;

    // Get progress
    int completedLessons = ProgressData.completedLessons[level] ?? 0;
    int totalLessons = ProgressData.totalLessons[level] ?? 10;
    double progress = totalLessons > 0 ? completedLessons / totalLessons : 0;

    return GestureDetector(
      onTap: canAccess
          ? () {
              if (_mode == 'learn') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LessonContentScreen(level: level, lessonNumber: 1),
                  ),
                ).then((_) {
                  setState(() {});
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizScreen(level: level, quizNumber: 1),
                  ),
                ).then((_) {
                  setState(() {});
                });
              }
            }
          : () {
              _showLockedDialog(context, level, isQuizPassed);
            },
      child: MouseRegion(
        cursor: canAccess
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: AnimatedOpacity(
          opacity: canAccess ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: canAccess
                    ? [const Color(0xFF7B2CBF), const Color(0xFF5A189A)]
                    : [const Color(0xFF3A1A5A), const Color(0xFF2A0F4A)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: canAccess
                    ? const Color(0xFF9D4EDD).withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: canAccess
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7B2CBF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 32,
                            color: canAccess ? Colors.white : Colors.grey[600],
                          ),
                          if (!canAccess)
                            Icon(Icons.lock, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                level,
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              // 🔧 FIX: Show status badge
                              if (isQuizPassed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '✓ Passed',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else if (!isUnlocked)
                                Text(
                                  '🔒 Locked',
                                  style: TextStyle(
                                    color: Colors.orange[300],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              else
                                Text(
                                  '🔓 Unlocked',
                                  style: TextStyle(
                                    color: Colors.green[300],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 4 : 6),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              color: Colors.grey[300],
                            ),
                          ),
                          SizedBox(height: isMobile ? 8 : 12),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                canAccess
                                    ? Colors.green[400]!
                                    : Colors.grey[600]!,
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 4 : 6),
                          Text(
                            'Progress: ${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
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

  void _showLockedDialog(
    BuildContext context,
    String level,
    bool isQuizPassed,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔒 Level Locked'),
        content: Text(
          isQuizPassed
              ? 'You\'ve already passed this level!'
              : _getLockMessage(level),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getLockMessage(String level) {
    switch (level) {
      case 'Intermediate':
        return 'Complete and pass the Beginner quiz to unlock Intermediate level.';
      case 'Advanced':
        return 'Complete and pass the Intermediate quiz to unlock Advanced level.';
      default:
        return 'This level is locked.';
    }
  }
}
