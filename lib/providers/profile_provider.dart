import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/local_profile_cache_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final LocalProfileCacheService _cacheService = LocalProfileCacheService();

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? profile;

  Future<void> fetchProfile({
    required String token,
    required int userId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _profileService.getProfile(token: token, userId: userId);

      await _cacheService.saveProfile(profile!);
    } catch (e) {
      final cachedProfile = await _cacheService.getCachedProfile();

      if (cachedProfile != null) {
        profile = cachedProfile;
        errorMessage = null; // important
      } else {
        errorMessage = 'No internet connection and no cached profile found.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int? get farmerProfileId {
    if (profile == null) return null;
    return profile!['id'];
  }

  Future<void> uploadPhoto({
    required String token,
    required int userId,
    required String imagePath,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _profileService.uploadProfilePhoto(
        token: token,
        userId: userId,
        imagePath: imagePath,
      );

      profile = await _profileService.getProfile(token: token, userId: userId);

      await _cacheService.saveProfile(profile!);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRejectedProfile({
    required String token,
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _profileService.updateRejectedProfile(
        token: token,
        userId: userId,
        data: data,
      );

      profile = await _profileService.getProfile(token: token, userId: userId);

      await _cacheService.saveProfile(profile!);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resubmitVerification({
    required String token,
    required int userId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _profileService.resubmitVerification(token: token, userId: userId);

      profile = await _profileService.getProfile(token: token, userId: userId);

      await _cacheService.saveProfile(profile!);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String token,
    required int userId,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _profileService.changePassword(
        token: token,
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCachedProfile() async {
    profile = await _cacheService.getCachedProfile();
    notifyListeners();
  }

  Future<void> clearCachedProfile() async {
    await _cacheService.clearProfile();
    profile = null;
    notifyListeners();
  }
}
