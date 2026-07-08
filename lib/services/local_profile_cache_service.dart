import 'package:hive_flutter/hive_flutter.dart';

class LocalProfileCacheService {
  static const String profileBoxName = 'profile_cache_box';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(profileBoxName)) {
      return Hive.box(profileBoxName);
    }

    return await Hive.openBox(profileBoxName);
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final box = await _openBox();

    await box.put('profile', Map<String, dynamic>.from(profile));
  }

  Future<Map<String, dynamic>?> getCachedProfile() async {
    final box = await _openBox();

    final profile = box.get('profile');

    if (profile == null) {
      return null;
    }

    return Map<String, dynamic>.from(profile);
  }

  Future<void> clearProfile() async {
    final box = await _openBox();

    await box.delete('profile');
  }
}
