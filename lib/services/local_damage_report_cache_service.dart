import 'package:hive_flutter/hive_flutter.dart';

class LocalDamageReportCacheService {
  static const String boxName = 'offline_damage_reports';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(boxName)) return Hive.box(boxName);
    return await Hive.openBox(boxName);
  }

  Future<void> savePendingReport(Map<String, dynamic> report) async {
    final box = await _openBox();
    final reports = await getPendingReports();

    reports.add(report);

    await box.put('pending_reports', reports);
  }

  Future<List<Map<String, dynamic>>> getPendingReports() async {
    final box = await _openBox();
    final data = box.get('pending_reports');

    if (data == null) return [];

    return List<Map<String, dynamic>>.from(
      data.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<void> removePendingReport(String clientUuid) async {
    final box = await _openBox();
    final reports = await getPendingReports();

    reports.removeWhere((report) => report['client_uuid'] == clientUuid);

    await box.put('pending_reports', reports);
  }

  Future<void> clearPendingReports() async {
    final box = await _openBox();
    await box.delete('pending_reports');
  }
}
