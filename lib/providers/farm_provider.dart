import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/farm_model.dart';
import '../services/farm_service.dart';
import '../services/local_farm_cache_service.dart';
import '../services/local_pending_farm_service.dart';

class FarmProvider extends ChangeNotifier {
  final FarmService _farmService = FarmService();
  final LocalFarmCacheService _cacheService = LocalFarmCacheService();
  final LocalPendingFarmService _pendingFarmService = LocalPendingFarmService();

  bool isLoading = false;
  String? errorMessage;

  List<FarmModel> farms = [];
  List<Map<String, dynamic>> pendingFarms = [];

  Future<Map<String, dynamic>> registerFarm({
    required String token,
    required int farmerProfileId,
    required String farmName,
    required String cropType,
    required String farmArea,
    required String latitude,
    required String longitude,
    required File farmImage,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final clientUuid = const Uuid().v4();
    final capturedAt = DateTime.now().toIso8601String();

    try {
      final response = await _farmService.registerFarm(
        token: token,
        farmerProfileId: farmerProfileId,
        farmName: farmName,
        cropType: cropType,
        farmArea: farmArea,
        latitude: latitude,
        longitude: longitude,
        farmImage: farmImage,
        clientUuid: clientUuid,
        syncSource: 'online',
        capturedAt: capturedAt,
      );

      return response;
    } catch (e) {
      final pendingFarm = {
        'client_uuid': clientUuid,
        'farmer_profile_id': farmerProfileId,
        'farm_name': farmName,
        'crop_type': cropType,
        'farm_area': farmArea,
        'latitude': latitude,
        'longitude': longitude,
        'farm_image_path': farmImage.path,
        'insurance_status': 'not_insured',
        'sync_source': 'offline',
        'captured_at': capturedAt,
        'sync_status': 'pending',
      };

      await _pendingFarmService.savePendingFarm(pendingFarm);
      pendingFarms = await _pendingFarmService.getPendingFarms();

      return {
        'success': true,
        'offline': true,
        'message':
            'No internet connection. Farm saved offline and will be synced once connected.',
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFarms({required String token, required int userId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _farmService.getFarms(
        token: token,
        userId: userId,
      );

      farms = response
          .map<FarmModel>((json) => FarmModel.fromJson(json))
          .toList();

      await _cacheService.saveFarms(farms);
    } catch (e) {
      errorMessage = e.toString();
      farms = await _cacheService.getCachedFarms();
    }

    pendingFarms = await _pendingFarmService.getPendingFarms();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCachedFarms() async {
    farms = await _cacheService.getCachedFarms();
    pendingFarms = await _pendingFarmService.getPendingFarms();
    notifyListeners();
  }

  Future<void> loadPendingFarms() async {
    pendingFarms = await _pendingFarmService.getPendingFarms();
    notifyListeners();
  }

  Future<void> syncPendingFarms({required String token}) async {
    final farmsToSync = await _pendingFarmService.getPendingFarms();

    for (final farm in farmsToSync) {
      try {
        await _farmService.registerFarm(
          token: token,
          farmerProfileId: farm['farmer_profile_id'],
          farmName: farm['farm_name'],
          cropType: farm['crop_type'],
          farmArea: farm['farm_area'],
          latitude: farm['latitude'],
          longitude: farm['longitude'],
          farmImage: File(farm['farm_image_path']),
          clientUuid: farm['client_uuid'],
          syncSource: 'offline',
          capturedAt: farm['captured_at'],
        );

        await _pendingFarmService.removePendingFarm(farm['client_uuid']);
      } catch (_) {
        continue;
      }
    }

    pendingFarms = await _pendingFarmService.getPendingFarms();
    notifyListeners();
  }

  Future<void> clearCachedFarms() async {
    await _cacheService.clearFarms();
    farms = [];
    notifyListeners();
  }
}
