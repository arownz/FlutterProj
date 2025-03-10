import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  SecureStorageService._internal();
  
  Future<void> writeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  Future<String?> readValue(String key) async {
    return await _storage.read(key: key);
  }
  
  Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }
  
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
  
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
  
  // Store user credential
  Future<void> storeUserCredential(String userId, String email) async {
    await writeValue('user_id', userId);
    await writeValue('user_email', email);
  }
  
  // Retrieve stored user id
  Future<String?> getUserId() async {
    return await readValue('user_id');
  }
  
  // Clear stored user credential
  Future<void> clearUserCredential() async {
    await deleteValue('user_id');
    await deleteValue('user_email');
  }
}
