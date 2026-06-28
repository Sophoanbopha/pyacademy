import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../info/progress_data.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ProfileScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late UserProfile _userProfile;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _userProfile = UserProfile(
      surname: widget.userProfile.surname,
      firstName: widget.userProfile.firstName,
      username: widget.userProfile.username,
      email: widget.userProfile.email,
      profileImage: widget.userProfile.profileImage,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0618),
      appBar: _buildAppBar(isMobile, isTablet),
      body: FadeTransition(
        opacity: _fadeAnimation,
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
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isMobile ? 20 : 30),

                    // Profile Header
                    _buildProfileHeader(isMobile, isTablet),
                    SizedBox(height: isMobile ? 32 : 40),

                    // Profile Info Card
                    _buildProfileCard(isMobile, isTablet),
                    SizedBox(height: isMobile ? 32 : 40),

                    // Stats Card
                    _buildStatsCard(isMobile, isTablet),
                    SizedBox(height: isMobile ? 32 : 40),

                    // Action Buttons
                    _buildActionButtons(isMobile, isTablet),
                    SizedBox(height: isMobile ? 32 : 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // App Bar
  PreferredSizeWidget _buildAppBar(bool isMobile, bool isTablet) {
    return AppBar(
      backgroundColor: const Color(0xFF0F0618).withOpacity(0.9),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: isMobile ? 24 : 28,
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ),
      ),
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: isMobile ? 20 : 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // Profile Header with Avatar
  Widget _buildProfileHeader(bool isMobile, bool isTablet) {
    return Column(
      children: [
        // Large Avatar
        Container(
          width: isMobile
              ? 100
              : isTablet
              ? 120
              : 140,
          height: isMobile
              ? 100
              : isTablet
              ? 120
              : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B2CBF).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
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
                      fontSize: isMobile ? 48 : 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        SizedBox(height: isMobile ? 20 : 24),

        // Name
        Text(
          '${_userProfile.firstName} ${_userProfile.surname}',
          style: TextStyle(
            fontSize: isMobile
                ? 24
                : isTablet
                ? 28
                : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),

        // Username
        Text(
          '@${_userProfile.username}',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: const Color(0xFF7B2CBF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Profile Info Card
  Widget _buildProfileCard(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile
            ? 20
            : isTablet
            ? 24
            : 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B2CBF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2CBF).withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: '${_userProfile.firstName} ${_userProfile.surname}',
            isMobile: isMobile,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
          ),
          _buildInfoRow(
            icon: Icons.alternate_email_outlined,
            label: 'Username',
            value: _userProfile.username,
            isMobile: isMobile,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
          ),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _userProfile.email,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  // Info Row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF7B2CBF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7B2CBF), size: 20),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stats Card
  Widget _buildStatsCard(bool isMobile, bool isTablet) {
    double overallGPA = ProgressData.calculateGPA();
    int levelsCompleted =
        (ProgressData.completedLessons['Beginner'] ?? 0) +
        (ProgressData.completedLessons['Intermediate'] ?? 0) +
        (ProgressData.completedLessons['Advanced'] ?? 0);
    int quizzesCompleted =
        (ProgressData.quizResults['Beginner']?.length ?? 0) +
        (ProgressData.quizResults['Intermediate']?.length ?? 0) +
        (ProgressData.quizResults['Advanced']?.length ?? 0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile
            ? 16
            : isTablet
            ? 20
            : 24,
      ),
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
            label: 'Lessons',
            value: levelsCompleted.toString(),
            icon: Icons.school_rounded,
            isMobile: isMobile,
          ),
          Container(
            width: 1,
            height: isMobile ? 40 : 50,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildStatItem(
            label: 'Quizzes',
            value: quizzesCompleted.toString(),
            icon: Icons.emoji_events_rounded,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  // Stat Item
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required bool isMobile,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: isMobile ? 24 : 28,
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons(bool isMobile, bool isTablet) {
    return Column(
      children: [
        // Edit Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  userProfile: _userProfile,
                  onSave: (updatedProfile) {
                    setState(() {
                      _userProfile = updatedProfile;
                    });
                    Navigator.pop(context, updatedProfile);
                  },
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B2CBF).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 22,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Edit Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),

        // Logout Button
        GestureDetector(
          onTap: () {
            _showLogoutDialog(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: isMobile ? 20 : 22,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Logout',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF7B2CBF).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B2CBF).withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Logout?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF7B2CBF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B2CBF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// UserProfile class
class UserProfile {
  final String surname;
  final String firstName;
  final String username;
  final String email;
  final String profileImage;

  UserProfile({
    required this.surname,
    required this.firstName,
    required this.username,
    required this.email,
    required this.profileImage,
  });

  UserProfile copyWith({
    String? surname,
    String? firstName,
    String? username,
    String? email,
    String? profileImage,
  }) {
    return UserProfile(
      surname: surname ?? this.surname,
      firstName: firstName ?? this.firstName,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surname': surname,
      'firstName': firstName,
      'username': username,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      surname: json['surname'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
    );
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onSave;

  const EditProfileScreen({
    Key? key,
    required this.userProfile,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _surnameController;
  late TextEditingController _firstNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _surnameController = TextEditingController(
      text: widget.userProfile.surname,
    );
    _firstNameController = TextEditingController(
      text: widget.userProfile.firstName,
    );
    _usernameController = TextEditingController(
      text: widget.userProfile.username,
    );
    _emailController = TextEditingController(text: widget.userProfile.email);
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _firstNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateInput() {
    if (_surnameController.text.isEmpty) {
      return 'Surname cannot be empty';
    }
    if (_firstNameController.text.isEmpty) {
      return 'First name cannot be empty';
    }
    if (_usernameController.text.isEmpty) {
      return 'Username cannot be empty';
    }
    if (_emailController.text.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!_emailController.text.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _saveChanges() async {
    final validation = _validateInput();
    if (validation != null) {
      setState(() {
        _errorMessage = validation;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedProfile = UserProfile(
        surname: _surnameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: widget.userProfile.profileImage,
      );

      widget.onSave(updatedProfile);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save changes: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0618).withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: isMobile ? 24 : 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildTextField('Surname', controller: _surnameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'First Name',
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Username', controller: _usernameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B2CBF).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _saveChanges,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String labelText, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7B2CBF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
