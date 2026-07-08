import 'package:hive_flutter/hive_flutter.dart';

class LocalInsuranceCacheService {
  static const String boxName = 'offline_insurance_applications';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return await Hive.openBox(boxName);
  }

  Future<void> savePendingApplication(Map<String, dynamic> application) async {
    final box = await _openBox();

    final applications = await getPendingApplications();

    applications.add(application);

    await box.put('pending_applications', applications);
  }

  Future<List<Map<String, dynamic>>> getPendingApplications() async {
    final box = await _openBox();

    final data = box.get('pending_applications');

    if (data == null) return [];

    return List<Map<String, dynamic>>.from(
      data.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> removePendingApplication(String clientUuid) async {
    final box = await _openBox();

    final applications = await getPendingApplications();

    applications.removeWhere((app) => app['client_uuid'] == clientUuid);

    await box.put('pending_applications', applications);
  }
}
