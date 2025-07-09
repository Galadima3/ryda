import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ryda/src/auth/service/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  // Register a new user with email and password.
  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      log("Registration failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("An unexpected error occurred during registration: $e");
      rethrow;
    }
  }

  // Log in an existing user with email and password.
  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      log("Login failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("An unexpected error occurred during login: $e");
      rethrow;
    }
  }

  // Log out the current user.
  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      log("Logout failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("An unexpected error occurred during logout: $e");
      rethrow;
    }
  }
}


// --- Helper for User-Friendly Error Messages ---
String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found for that email.';
    case 'wrong-password':
      return 'Wrong password provided for that user.';
    case 'email-already-in-use':
      return 'The email address is already in use by another account.';
    case 'weak-password':
      return 'The password provided is too weak.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled. Enable email/password in the Firebase console.';
    case 'network-request-failed':
      return 'A network error occurred. Please check your internet connection.';
    case 'invalid-credential':
      return 'Check Login credentials';  
    default:
      return 'An unknown authentication error occurred: ${e.message}';
  }
}
