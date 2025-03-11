import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/error_handler.dart';
import '../services/secure_storage_service.dart';

enum UserRole { child, parent, teacher, admin }

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecureStorageService _storage = SecureStorageService();
  
  User? _user;
  UserRole? _userRole;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get user => _user;
  UserRole? get userRole => _userRole;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTeacher => _userRole == UserRole.teacher;
  bool get isParent => _userRole == UserRole.parent;
  bool get isChild => _userRole == UserRole.child;
  bool get isAdmin => _userRole == UserRole.admin;
  
  AuthService() {
    _initAuth();
  }
  
  // Initialize authentication state
  void _initAuth() {
    _isLoading = true;
    notifyListeners();
    
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      
      if (user != null) {
        // Store user credentials securely
        await _storage.storeUserCredential(user.uid, user.email ?? '');
        
        // Fetch user role from Firestore
        try {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          
          if (userDoc.exists) {
            String roleStr = (userDoc.data() as Map<String, dynamic>)['role'] ?? 'parent';
            _userRole = _stringToUserRole(roleStr);
          } else {
            _userRole = UserRole.parent; // Default role
          }
        } catch (e) {
          ErrorHandler.logError(e, null);
          _userRole = UserRole.parent; // Default role on error
        }
      } else {
        _userRole = null;
        await _storage.clearUserCredential();
      }
      
      _isLoading = false;
      notifyListeners();
    });
  }
  
  // Convert string to UserRole enum
  UserRole _stringToUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'child':
        return UserRole.child;
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.parent;
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = ErrorHandler.handleError(e);
      notifyListeners();
      return false;
    }
  }
  
  // Register with email and password
  Future<bool> registerWithEmailAndPassword(String email, String password, String name, UserRole role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': null,
        'studentIds': [],
      });
      
      // Update user profile
      await result.user!.updateDisplayName(name);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = ErrorHandler.handleError(e);
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _storage.clearUserCredential();
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError(e, null);
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = ErrorHandler.handleError(e);
      notifyListeners();
      return false;
    }
  }
}
