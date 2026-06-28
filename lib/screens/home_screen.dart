import 'package:flutter/material.dart';
import 'level_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../info/progress_service.dart';
import '../info/progress_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late UserProfile _userProfile = UserProfile(
    surname: '',
    firstName: 'User',
    username: '',
    email: '',
    profileImage: '',
  );
  late ProgressService _progressService;
  bool _isLoadingProgress = true;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _progressService = ProgressService();
    _loadProgressAndProfile();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressAndProfile() async {
    try {
      // Load progress from Firestore
      await _progressService.loadProgressData();

      // Load user profile
      await _loadUserProfile();

      if (mounted) {
        setState(() {
          _isLoadingProgress = false;
        });
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          _scaleController.forward();
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (mounted) {
        setState(() {
          _isLoadingProgress = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService().getUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _userProfile = UserProfile(
          surname: '',
          firstName: 'User',
          username: '',
          email: '',
          profileImage: '',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProgress) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0618),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF7B2CBF)),
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0618),
      appBar: _buildAppBar(isMobile, isTablet),
      body: _buildBody(isMobile, isTablet),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile, bool isTablet) {
    return AppBar(
      backgroundColor: const Color(0xFF0F0618).withOpacity(0.8),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: isMobile ? 32 : 40,
            height: isMobile ? 32 : 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: isMobile ? 18 : 22,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Text(
            'Pyacademy',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          child: GestureDetector(
            onTap: () async {
              final updatedProfile = await Navigator.push<UserProfile>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(userProfile: _userProfile),
                ),
              );
              if (updatedProfile != null) {
                setState(() => _userProfile = updatedProfile);
              }
            },
            child: Container(
              width: isMobile ? 40 : 44,
              height: isMobile ? 40 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B2CBF).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
                image: _userProfile.profileImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_userProfile.profileImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _userProfile.profileImage.isEmpty
                  ? Center(
                      child: Text(
                        _userProfile.firstName.isNotEmpty
                            ? _userProfile.firstName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isMobile, bool isTablet) {
    final padding = isMobile
        ? 16.0
        : isTablet
        ? 20.0
        : 28.0;
    final spacing = isMobile
        ? 28.0
        : isTablet
        ? 32.0
        : 40.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isMobile ? 20 : 40),

                  _buildGreetingSection(isMobile, isTablet, padding),
                  SizedBox(height: spacing),

                  // Learn Card
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildActionCard(
                      context: context,
                      label: 'Learn',
                      icon: Icons.school_rounded,
                      description: 'Master Python Step by Step',
                      primaryColor: const Color(0xFF7B2CBF),
                      secondaryColor: const Color(0xFF5A189A),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LevelScreen(mode: 'learn'),
                        ),
                      ),
                      isMobile: isMobile,
                      isTablet: isTablet,
                      padding: padding,
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Quiz Card
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildActionCard(
                      context: context,
                      label: 'Quiz',
                      icon: Icons.emoji_events_rounded,
                      description: 'Test Your Knowledge',
                      primaryColor: const Color(0xFF5A189A),
                      secondaryColor: const Color(0xFF7B2CBF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelScreen(mode: 'quiz'),
                        ),
                      ),
                      isMobile: isMobile,
                      isTablet: isTablet,
                      padding: padding,
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Stats Card
                  _buildStatsCard(isMobile, isTablet, padding),
                  SizedBox(height: spacing),

                  // Progress Overview
                  _buildProgressOverviewCard(isMobile, isTablet, padding),
                  SizedBox(height: spacing),

                  // Quote Card
                  _buildQuoteCard(isMobile, isTablet, padding),
                  SizedBox(height: isMobile ? 40 : 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(bool isMobile, bool isTablet, double padding) {
    double overallProgress = ProgressData.hasCompletedAllLevels()
        ? 1.0
        : (ProgressData.getProgress('Beginner') +
                  ProgressData.getProgress('Intermediate') +
                  ProgressData.getProgress('Advanced')) /
              3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hello, ',
                style: TextStyle(
                  fontSize: isMobile
                      ? 28
                      : isTablet
                      ? 32
                      : 40,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              TextSpan(
                text: _userProfile.firstName,
                style: TextStyle(
                  fontSize: isMobile
                      ? 28
                      : isTablet
                      ? 32
                      : 40,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF7B2CBF),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        Text(
          ProgressData.hasCompletedAllLevels()
              ? '🎓 All levels completed! View your certificate'
              : 'Let\'s continue learning Python',
          style: TextStyle(
            fontSize: isMobile
                ? 14
                : isTablet
                ? 15
                : 16,
            color: Colors.white54,
            height: 1.6,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: isMobile ? 20 : 28),

        // Overall Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: overallProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B2CBF).withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(overallProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: const Color(0xFF7B2CBF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String description,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onTap,
    required bool isMobile,
    required bool isTablet,
    required double padding,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isMobile
                      ? 56
                      : isTablet
                      ? 64
                      : 72,
                  height: isMobile
                      ? 56
                      : isTablet
                      ? 64
                      : 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isMobile
                        ? 32
                        : isTablet
                        ? 36
                        : 40,
                  ),
                ),
                SizedBox(width: isMobile ? 16 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 32
                              : isTablet
                              ? 36
                              : 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),

            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: isMobile ? 40 : 48,
                height: isMobile ? 40 : 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isMobile, bool isTablet, double padding) {
    double overallGPA = ProgressData.calculateGPA();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B2CBF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'GPA',
            value: overallGPA.toStringAsFixed(2),
            icon: Icons.trending_up_rounded,
            isMobile: isMobile,
          ),
          Container(
            width: 1,
            height: isMobile ? 40 : 50,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildStatItem(
            label: 'Level',
            value: _getCurrentLevel(),
            icon: Icons.school_rounded,
            isMobile: isMobile,
          ),
          Container(
            width: 1,
            height: isMobile ? 40 : 50,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildStatItem(
            label: 'Status',
            value: ProgressData.hasCompletedAllLevels() ? '✓' : '...',
            icon: Icons.star_rounded,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  String _getCurrentLevel() {
    if (ProgressData.quizPassed['Advanced'] ?? false) return 'Advanced';
    if (ProgressData.quizPassed['Intermediate'] ?? false) return 'Int';
    if (ProgressData.quizPassed['Beginner'] ?? false) return 'Begin';
    return 'Start';
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required bool isMobile,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7B2CBF), size: isMobile ? 24 : 28),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverviewCard(
    bool isMobile,
    bool isTablet,
    double padding,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B2CBF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLevelProgressBar(
                  level: 'Beginner',
                  isPassed: ProgressData.quizPassed['Beginner'] ?? false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLevelProgressBar(
                  level: 'Intermediate',
                  isPassed: ProgressData.quizPassed['Intermediate'] ?? false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLevelProgressBar(
                  level: 'Advanced',
                  isPassed: ProgressData.quizPassed['Advanced'] ?? false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar({
    required String level,
    required bool isPassed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPassed
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            isPassed ? Icons.check_circle : Icons.pending,
            size: 20,
            color: isPassed ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          level,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuoteCard(bool isMobile, bool isTablet, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2CBF).withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.amber,
              size: isMobile ? 28 : 32,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),

          Text(
            '"Every master was once a beginner."',
            style: TextStyle(
              fontSize: isMobile
                  ? 16
                  : isTablet
                  ? 17
                  : 18,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.8,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 20),

          const Text(
            '— Keep Learning',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
