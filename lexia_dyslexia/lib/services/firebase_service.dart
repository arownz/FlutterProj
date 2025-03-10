import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// A service class that manages Firebase services and provides utility functions
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  late final FirebaseAuth auth;
  late final FirebaseFirestore firestore;
  late final FirebaseStorage storage;

  bool _initialized = false;
  String? _error;

  bool get isInitialized => _initialized;
  String? get error => _error;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Initialize services
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;
      
      // Configure Firestore settings with persistence enabled
      firestore.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      _initialized = true;
      if (kDebugMode) {
        print('Firebase services initialized successfully');
      }
    } catch (e) {
      _error = 'Failed to initialize Firebase: ${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
      rethrow;
    }
  }

  // Firestore helpers

  /// Check if a document exists
  Future<bool> documentExists(String collection, String docId) async {
    final docSnapshot = await firestore.collection(collection).doc(docId).get();
    return docSnapshot.exists;
  }

  /// Create document with auto-generated ID and return the ID
  Future<String> createDocument(
      String collection, Map<String, dynamic> data) async {
    final docRef = await firestore.collection(collection).add(data);
    return docRef.id;
  }

  /// Set document with specific ID
  Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data,
      {bool merge = true}) async {
    await firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  /// Update document fields
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(docId).update(data);
  }

  /// Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  /// Get document by ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  /// Run a transaction
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction transaction) transactionHandler) async {
    return await firestore.runTransaction(transactionHandler);
  }

  /// Execute batch writes
  Future<void> executeBatch(void Function(WriteBatch batch) batchHandler) async {
    final batch = firestore.batch();
    batchHandler(batch);
    await batch.commit();
  }
}
