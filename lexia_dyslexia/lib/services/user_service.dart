import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role; // "child", "parent", "teacher", "admin"
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> studentIds; // For teachers
  final String? parentId; // For children
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.studentIds,
    this.parentId,
  });
  
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'parent',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      studentIds: List<String>.from(data['studentIds'] ?? []),
      parentId: data['parentId'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'studentIds': studentIds,
      'parentId': parentId,
    };
  }
}

// GameProgress represents a child's progress in the Unity game
class GameProgress {
  final String id;
  final String userId;
  final int level;
  final int score;
  final double accuracyRate;
  final int completedChallenges;
  final DateTime lastActivity;
  final Map<String, dynamic> skillsProgress; // Dictionary of skills and their progress levels
  
  GameProgress({
    required this.id,
    required this.userId,
    required this.level,
    required this.score,
    required this.accuracyRate,
    required this.completedChallenges,
    required this.lastActivity,
    required this.skillsProgress,
  });
  
  factory GameProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return GameProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      level: data['level'] ?? 0,
      score: data['score'] ?? 0,
      accuracyRate: (data['accuracyRate'] ?? 0.0).toDouble(),
      completedChallenges: data['completedChallenges'] ?? 0,
      lastActivity: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      skillsProgress: data['skillsProgress'] ?? {},
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'level': level,
      'score': score,
      'accuracyRate': accuracyRate,
      'completedChallenges': completedChallenges,
      'lastActivity': FieldValue.serverTimestamp(),
      'skillsProgress': skillsProgress,
    };
  }
}

class UserService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      _isLoading = false;
      notifyListeners();
      
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching user profile: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile(String userId, String name, String? photoUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'photoUrl': photoUrl,
      });
      
      // Update Auth display name if this is the current user
      if (_auth.currentUser?.uid == userId) {
        await _auth.currentUser!.updateDisplayName(name);
        if (photoUrl != null) {
          await _auth.currentUser!.updatePhotoURL(photoUrl);
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Get children for parent
  Future<List<UserProfile>> getChildrenForParent(String parentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('parentId', isEqualTo: parentId)
          .where('role', isEqualTo: 'child')
          .get();
      
      _isLoading = false;
      notifyListeners();
      
      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching children: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Get students for teacher
  Future<List<UserProfile>> getStudentsForTeacher(String teacherId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Get teacher profile to access their studentIds
      DocumentSnapshot teacherDoc = await _firestore.collection('users').doc(teacherId).get();
      if (!teacherDoc.exists) {
        _isLoading = false;
        _error = 'Teacher profile not found';
        notifyListeners();
        return [];
      }
      
      UserProfile teacher = UserProfile.fromFirestore(teacherDoc);
      List<String> studentIds = teacher.studentIds;
      
      if (studentIds.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return [];
      }
      
      // Fetch all students in batches (Firestore has limitations on query size)
      List<UserProfile> students = [];
      for (int i = 0; i < studentIds.length; i += 10) {
        int end = (i + 10 < studentIds.length) ? i + 10 : studentIds.length;
        List<String> batch = studentIds.sublist(i, end);
        
        QuerySnapshot batchSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
            
        students.addAll(batchSnapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
      }
      
      _isLoading = false;
      notifyListeners();
      return students;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching students: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Link a child to a teacher
  Future<bool> linkChildToTeacher(String childId, String teacherId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Add child ID to teacher's studentIds array
      await _firestore.collection('users').doc(teacherId).update({
        'studentIds': FieldValue.arrayUnion([childId]),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error linking child to teacher: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Remove a child from a teacher's students
  Future<bool> unlinkChildFromTeacher(String childId, String teacherId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Remove child ID from teacher's studentIds array
      await _firestore.collection('users').doc(teacherId).update({
        'studentIds': FieldValue.arrayRemove([childId]),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error unlinking child from teacher: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Get game progress for a child
  Future<GameProgress?> getGameProgressForChild(String childId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('gameProgress')
          .where('userId', isEqualTo: childId)
          .limit(1)
          .get();
      
      _isLoading = false;
      notifyListeners();
      
      if (querySnapshot.docs.isNotEmpty) {
        return GameProgress.fromFirestore(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching game progress: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
  
  // Register a new child account linked to a parent
  Future<String?> registerChildAccount(String name, String parentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Create user document in Firestore with child role and parent link
      DocumentReference docRef = await _firestore.collection('users').add({
        'name': name,
        'role': 'child',
        'parentId': parentId,
        'createdAt': FieldValue.serverTimestamp(),
        'studentIds': [],
      });
      
      _isLoading = false;
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _isLoading = false;
      _error = 'Error registering child account: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
