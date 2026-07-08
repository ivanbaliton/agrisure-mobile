import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../services/damage_report_service.dart';
import '../services/local_damage_report_cache_service.dart';

class DamageReportProvider extends ChangeNotifier {
  final DamageReportService _damageReportService = DamageReportService();
  final LocalDamageReportCacheService _cacheService =
      LocalDamageReportCacheService();

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> pendingReports = [];

  Future<Map<String, dynamic>> submitDamageReport({
    required String token,
    required int farmId,
    required String damageCause,
    required String damageDate,
    required File damageImage,
    required String reportLatitude,
    required String reportLongitude,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final clientUuid = const Uuid().v4();
    final capturedAt = DateTime.now().toIso8601String();

    try {
      final connectivity = await Connectivity().checkConnectivity();

      final isOffline = connectivity == ConnectivityResult.none;

      if (isOffline) {
        final offlineReport = {
          'client_uuid': clientUuid,
          'farm_id': farmId,
          'damage_cause': damageCause,
          'damage_date': damageDate,
          'damage_image_path': damageImage.path,
          'report_latitude': reportLatitude,
          'report_longitude': reportLongitude,
          'sync_source': 'offline',
          'captured_at': capturedAt,
          'sync_status': 'pending',
        };

        await _cacheService.savePendingReport(offlineReport);
        pendingReports = await _cacheService.getPendingReports();

        return {
          'success': true,
          'offline': true,
          'message':
              'No internet connection. Damage report saved offline and will be submitted once connected.',
        };
      }

      return await _damageReportService.submitDamageReport(
        token: token,
        farmId: farmId,
        damageCause: damageCause,
        damageDate: damageDate,
        damageImage: damageImage,
        reportLatitude: reportLatitude,
        reportLongitude: reportLongitude,
        clientUuid: clientUuid,
        syncSource: 'online',
        capturedAt: capturedAt,
      );
    } catch (e) {
      final offlineReport = {
        'client_uuid': clientUuid,
        'farm_id': farmId,
        'damage_cause': damageCause,
        'damage_date': damageDate,
        'damage_image_path': damageImage.path,
        'report_latitude': reportLatitude,
        'report_longitude': reportLongitude,
        'sync_source': 'offline',
        'captured_at': capturedAt,
        'sync_status': 'pending',
      };

      await _cacheService.savePendingReport(offlineReport);
      pendingReports = await _cacheService.getPendingReports();

      return {
        'success': true,
        'offline': true,
        'message':
            'No internet connection. Damage report saved offline and will be submitted once connected.',
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingReports() async {
    pendingReports = await _cacheService.getPendingReports();
    notifyListeners();
  }

  Future<void> syncPendingReports({required String token}) async {
    final reports = await _cacheService.getPendingReports();

    for (final report in reports) {
      try {
        await _damageReportService.submitDamageReport(
          token: token,
          farmId: report['farm_id'],
          damageCause: report['damage_cause'],
          damageDate: report['damage_date'],
          damageImage: File(report['damage_image_path']),
          reportLatitude: report['report_latitude'],
          reportLongitude: report['report_longitude'],
          clientUuid: report['client_uuid'],
          syncSource: 'offline',
          capturedAt: report['captured_at'],
        );

        await _cacheService.removePendingReport(report['client_uuid']);
      } catch (_) {
        continue;
      }
    }

    pendingReports = await _cacheService.getPendingReports();
    notifyListeners();
  }
}
