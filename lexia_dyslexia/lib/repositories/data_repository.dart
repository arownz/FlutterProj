import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class DataRepository {
  final FirebaseService _firebaseService;
  
  DataRepository(this._firebaseService);
  
  // User-related methods
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firebaseService.getDocument('users', userId);
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firebaseService.updateDocument('users', userId, data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Game progress methods
  Future<Map<String, dynamic>?> getGameProgress(String userId) async {
    try {
      QuerySnapshot snapshot = await _firebaseService.firestore
          .collection('gameProgress')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
          
      return snapshot.docs.isNotEmpty 
          ? snapshot.docs.first.data() as Map<String, dynamic>
          : null;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateGameProgress(String progressId, Map<String, dynamic> data) async {
    try {
      await _firebaseService.updateDocument('gameProgress', progressId, data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Forum methods
  Future<List<Map<String, dynamic>>> getForumPosts() async {
    try {
      QuerySnapshot snapshot = await _firebaseService.firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();
          
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
