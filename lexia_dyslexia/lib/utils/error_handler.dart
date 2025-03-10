import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  // Generic error handler
  static String handleError(dynamic error) {
    if (kDebugMode) {
      print('Error caught: $error');
    }
    
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }
  
  // Handle Firebase Authentication errors
  static String _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication error: ${error.message}';
    }
  }
  
  // Handle Firestore errors
  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Permission denied. Please check your access rights.';
      case 'unavailable':
        return 'The service is currently unavailable. Please check your internet connection.';
      case 'not-found':
        return 'The requested document was not found.';
      default:
        return 'Database error: ${error.message}';
    }
  }
  
  // Log error to analytics or remote logging service
  static void logError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('ERROR: $error');
      if (stackTrace != null) {
        print('STACK TRACE: $stackTrace');
      }
    }
    
    // In a real app, you would send this to Firebase Crashlytics or other error reporting service
  }
}
