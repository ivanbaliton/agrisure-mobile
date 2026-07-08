import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveLoginData({
    required String token,
    required String userId,
    required String role,
    required String accountStatus,
  }) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'user_id', value: userId);
    await _storage.write(key: 'role', value: role);
    await _storage.write(key: 'account_status', value: accountStatus);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<String?> getFarmerProfileId() async {
    return await _storage.read(key: 'farmer_profile_id');
  }

  static Future<void> saveFarmerProfileId(String farmerProfileId) async {
    await _storage.write(key: 'farmer_profile_id', value: farmerProfileId);
  }

  static Future<String?> getAccountStatus() async {
    return await _storage.read(key: 'account_status');
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('role');
    await prefs.remove('account_status');
    await prefs.remove('farmer_profile_id');
  }
}
