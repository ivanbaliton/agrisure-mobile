import 'package:hive_flutter/hive_flutter.dart';

class LocalPendingFarmService {
  static const String boxName = 'pending_farms_box';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return await Hive.openBox(boxName);
  }

  Future<void> savePendingFarm(Map<String, dynamic> farm) async {
    final box = await _openBox();

    final farms = await getPendingFarms();

    farms.add(farm);

    await box.put('pending_farms', farms);
  }

  Future<List<Map<String, dynamic>>> getPendingFarms() async {
    final box = await _openBox();

    final data = box.get('pending_farms');

    if (data == null) return [];

    return List<Map<String, dynamic>>.from(
      data.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> removePendingFarm(String clientUuid) async {
    final box = await _openBox();

    final farms = await getPendingFarms();

    farms.removeWhere((farm) => farm['client_uuid'] == clientUuid);

    await box.put('pending_farms', farms);
  }
}
