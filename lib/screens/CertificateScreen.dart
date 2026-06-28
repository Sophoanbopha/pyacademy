import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart'; // For kIsWeb
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../info/progress_data.dart';
import '../services/auth_service.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  late Map<String, dynamic> _gpaInfo;
  String _userName = 'Student';
  final GlobalKey _certificateKey = GlobalKey();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _gpaInfo = ProgressData.getGPAInfo();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await AuthService().getUserProfile();
      final firstName = profile.firstName.trim();
      final surname = profile.surname.trim();
      final username = profile.username.trim();

      if (!mounted) return;

      String fullName = '';
      if (firstName.isNotEmpty && surname.isNotEmpty) {
        fullName = '$firstName $surname';
      } else if (firstName.isNotEmpty) {
        fullName = firstName;
      } else if (username.isNotEmpty) {
        fullName = username;
      } else {
        fullName = 'Student';
      }

      setState(() {
        _userName = fullName;
      });
    } catch (e) {
      debugPrint('Error loading user name: $e');
      setState(() {
        _userName = 'Student';
      });
    }
  }

  Future<void> _saveCertificate() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      RenderRepaintBoundary boundary =
          _certificateKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final fileName = 'certificate_${_userName.replaceAll(' ', '_')}.png';

      // ================== WEB ==================
      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();

        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate downloaded'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      // ================= MOBILE =================
      else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pngBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Certificate saved: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving certificate: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    if (!_gpaInfo['allLevelsPassed']) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0618),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0618).withOpacity(0.8),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Certificate',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Certificate Not Available',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Complete and pass all three levels to generate your certificate.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildProgressOverview(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0618).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Certificate',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B2CBF).withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isSaving ? null : _saveCertificate,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                RepaintBoundary(
                  key: _certificateKey,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF7B2CBF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B2CBF).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/certificate.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Image Error: $error');
                              return Container(
                                width: double.infinity,
                                height: 400,
                                color: Colors.grey[800],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.white70,
                                        size: 60,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Certificate image not found',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Expected path: assets/images/certificate.jpg',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error: $error',
                                        style: TextStyle(
                                          color: Colors.red[300],
                                          fontSize: 11,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: const Alignment(0, 0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                _userName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PlaywriteAUNSW',
                                  fontSize: isMobile ? 20 : 36,
                                  fontWeight:
                                      FontWeight.w400, // Use 400 (Regular)
                                  color: Colors.black,
                                  letterSpacing: isMobile ? 1.0 : 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildDetailedResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedResults() {
    final levelGPAs = _gpaInfo['levelGPAs'] as Map<String, double>;
    final passAttempts = _gpaInfo['passAttempts'] as Map<String, int>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildLevelResultCard(
          level: 'Beginner',
          gpa: levelGPAs['Beginner'] ?? 0.0,
          attempts: passAttempts['Beginner'] ?? 0,
          color: const Color(0xFF7B2CBF),
        ),
        const SizedBox(height: 12),
        _buildLevelResultCard(
          level: 'Intermediate',
          gpa: levelGPAs['Intermediate'] ?? 0.0,
          attempts: passAttempts['Intermediate'] ?? 0,
          color: const Color(0xFF5A189A),
        ),
        const SizedBox(height: 12),
        _buildLevelResultCard(
          level: 'Advanced',
          gpa: levelGPAs['Advanced'] ?? 0.0,
          attempts: passAttempts['Advanced'] ?? 0,
          color: const Color(0xFF7B2CBF),
        ),
      ],
    );
  }

  Widget _buildLevelResultCard({
    required String level,
    required double gpa,
    required int attempts,
    required Color color,
  }) {
    final bestResult = ProgressData.getBestQuizResult(level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GPA: ${gpa.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Score: ${bestResult != null ? "${bestResult.score}/${bestResult.totalQuestions} (${bestResult.percentage.toStringAsFixed(1)}%)" : "N/A"}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                'Attempts: $attempts',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLevelProgressItem(
                'Beginner',
                ProgressData.quizPassed['Beginner'] ?? false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLevelProgressItem(
                'Intermediate',
                ProgressData.quizPassed['Intermediate'] ?? false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLevelProgressItem(
                'Advanced',
                ProgressData.quizPassed['Advanced'] ?? false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelProgressItem(String level, bool passed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: passed
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: passed
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.pending,
            color: passed ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
