class AuthError {
  final String code;
  final String message;

  AuthError({required this.code, required this.message});

  factory AuthError.fromFirebaseError(String errorCode) {
    String message;

    switch (errorCode) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'The password is invalid.';
        break;
      case 'email-already-in-use':
        message = 'This email address is already registered.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Check your internet connection.';
        break;
      default:
        message = 'An unknown error occurred.';
    }

    return AuthError(code: errorCode, message: message);
  }
}

enum AuthMethod {
  emailPassword,
  google,
  apple,
  anonymous
}

class AuthRequest {
  final String? email;
  final String? password;
  final String? name;
  final AuthMethod method;

  AuthRequest({
    this.email,
    this.password,
    this.name,
    required this.method,
  });
}

class AuthResult {
  final bool success;
  final AuthError? error;
  final String? userId;

  AuthResult({
    required this.success,
    this.error,
    this.userId,
  });
}
