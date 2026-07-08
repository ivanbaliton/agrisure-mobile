import 'package:hive_flutter/hive_flutter.dart';

import '../models/farm_model.dart';

class LocalFarmCacheService {
  static const String farmBoxName = 'farm_cache_box';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(farmBoxName)) {
      return Hive.box(farmBoxName);
    }

    return await Hive.openBox(farmBoxName);
  }

  Future<void> saveFarms(List<FarmModel> farms) async {
    final box = await _openBox();

    final farmList = farms.map((farm) => farm.toJson()).toList();

    await box.put('farms', farmList);
  }

  Future<List<FarmModel>> getCachedFarms() async {
    final box = await _openBox();

    final data = box.get('farms');

    if (data == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      data.map((item) => Map<String, dynamic>.from(item)),
    ).map((json) => FarmModel.fromJson(json)).toList();
  }

  Future<void> clearFarms() async {
    final box = await _openBox();
    await box.delete('farms');
  }
}
