import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../screens/profile_screen.dart'; // ← ADD THIS IMPORT

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  Future<String?> registerUser({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String surname,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'firstName': firstName,
        'surname': surname,
        'email': email,
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'score': 0,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('registerUser FirebaseAuthException: ${e.code} ${e.message}');
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else {
        return e.message ?? 'Registration failed (${e.code})';
      }
    } on FirebaseException catch (e) {
      debugPrint('registerUser FirebaseException: ${e.code} ${e.message}');
      return e.message ?? 'Registration failed (${e.code})';
    } catch (e) {
      debugPrint('registerUser error: $e');
      return 'An error occurred: ${e.toString()}';
    }
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('usernameExists error: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('signIn FirebaseAuthException: ${e.code} ${e.message}');
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      } else {
        return e.message ?? 'Login failed (${e.code})';
      }
    } on FirebaseException catch (e) {
      debugPrint('signIn FirebaseException: ${e.code} ${e.message}');
      return e.message ?? 'Login failed (${e.code})';
    } catch (e) {
      debugPrint('signIn error: $e');
      return 'An error occurred: ${e.toString()}';
    }
  }

  // Alias for signInWithEmailAndPassword
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    return signInWithEmailAndPassword(email: email, password: password);
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('getUserData error: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser!.uid).update(data);
  }

  // ============================================================================
  // NEW METHOD - Copy everything below this line into your AuthService
  // ============================================================================

  /// Fetch the currently logged-in user's profile as a UserProfile object
  /// This is used after successful login to populate the ProfileScreen
  Future<UserProfile> getUserProfile() async {
    try {
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found in database');
      }

      // Convert Firestore document to UserProfile object
      final data = userDoc.data() ?? {};

      return UserProfile(
        surname: data['surname'] as String? ?? '',
        firstName: data['firstName'] as String? ?? '',
        username: data['username'] as String? ?? '',
        email: data['email'] as String? ?? '',
        profileImage: data['profileImage'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('getUserProfile error: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // ============================================================================
  // END NEW METHOD
  // ============================================================================

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
