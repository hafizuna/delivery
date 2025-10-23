import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  late FlutterSecureStorage _secureStorage;
  
  StorageService._internal() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }
  
  /// Write data to secure storage
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      if (kDebugMode) {
        print('💾 Saved to storage: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage write error: $e');
      }
    }
  }
  
  /// Read data from secure storage
  Future<String?> read(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (kDebugMode && value != null) {
        print('📖 Read from storage: $key');
      }
      return value;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage read error: $e');
      }
      return null;
    }
  }
  
  /// Delete data from secure storage
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      if (kDebugMode) {
        print('🗑️ Deleted from storage: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage delete error: $e');
      }
    }
  }
  
  /// Clear all data from secure storage
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      if (kDebugMode) {
        print('🗑️ Cleared all storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage clear error: $e');
      }
    }
  }
  
  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage contains key error: $e');
      }
      return false;
    }
  }
  
  /// Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage read all error: $e');
      }
      return {};
    }
  }
  
  // ============== HELPER METHODS ==============
  
  /// Save JSON object
  Future<void> writeJson(String key, Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    await write(key, jsonString);
  }
  
  /// Read JSON object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final jsonString = await read(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ JSON decode error: $e');
      }
      return null;
    }
  }
  
  /// Parse JSON string
  Map<String, dynamic> parseJsonString(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ JSON parse error: $e');
      }
      return {};
    }
  }
  
  // ============== AUTH SPECIFIC ==============
  
  /// Save authentication tokens
  Future<void> saveAuthTokens({
    required String token,
    required String refreshToken,
  }) async {
    await write('token', token);
    await write('refreshToken', refreshToken);
  }
  
  /// Get authentication token
  Future<String?> getAuthToken() async {
    return await read('token');
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await read('refreshToken');
  }
  
  /// Clear authentication tokens
  Future<void> clearAuthTokens() async {
    await delete('token');
    await delete('refreshToken');
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await read('token');
    return token != null && token.isNotEmpty;
  }
  
  // ============== USER DATA ==============
  
  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await writeJson('userData', userData);
  }
  
  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await readJson('userData');
  }
  
  /// Clear user data
  Future<void> clearUserData() async {
    await delete('userData');
  }
  
  // ============== SETTINGS ==============
  
  /// Save app settings
  Future<void> saveSetting(String key, String value) async {
    await write('setting_$key', value);
  }
  
  /// Get app setting
  Future<String?> getSetting(String key) async {
    return await read('setting_$key');
  }
  
  /// Delete app setting
  Future<void> deleteSetting(String key) async {
    await delete('setting_$key');
  }
}
