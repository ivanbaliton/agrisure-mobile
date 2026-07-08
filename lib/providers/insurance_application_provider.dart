import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/insurance_application_service.dart';
import '../services/local_insurance_cache_service.dart';

class InsuranceProvider extends ChangeNotifier {
  final InsuranceService _insuranceService = InsuranceService();
  final LocalInsuranceCacheService _cacheService = LocalInsuranceCacheService();

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> pendingApplications = [];

  Future<Map<String, dynamic>> getFreeCoverage({
    required String token,
    required int userId,
  }) async {
    return await _insuranceService.getFreeCoverage(
      token: token,
      userId: userId,
    );
  }

  Future<Map<String, dynamic>> applyInsurance({
    required String token,
    required int farmId,

    required double insuredArea,
    required String civilStatus,
    required String beneficiaryName,
    required String spouseName,
    required String parentGuardianName,
    required String variety,
    required String farmType,
    required String sowingDate,
    required String transplantingDate,
    required String northBoundary,
    required String eastBoundary,
    required String westBoundary,
    required String southBoundary,
    required bool isLandOwner,
    required String tenureStatus,
    required File signature,
    File? paymentProof,
    String? gcashReferenceNumber,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final clientUuid = const Uuid().v4();
    final capturedAt = DateTime.now().toIso8601String();

    final offlineApplication = {
      'client_uuid': clientUuid,
      'farm_id': farmId,

      'insured_area': insuredArea,
      'civil_status': civilStatus,
      'beneficiary_name': beneficiaryName,
      'spouse_name': spouseName,
      'parent_guardian_name': parentGuardianName,
      'variety': variety,
      'farm_type': farmType,
      'sowing_date': sowingDate,
      'transplanting_date': transplantingDate,
      'north_boundary': northBoundary,
      'east_boundary': eastBoundary,
      'west_boundary': westBoundary,
      'south_boundary': southBoundary,
      'is_land_owner': isLandOwner,
      'tenure_status': tenureStatus,
      'signature_path': signature.path,
      'payment_proof_path': paymentProof?.path,
      'gcash_reference_number': gcashReferenceNumber,
      'sync_source': 'offline',
      'captured_at': capturedAt,
    };

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity == ConnectivityResult.none;

      if (isOffline) {
        await _saveOfflineApplication(offlineApplication);

        return {
          'success': true,
          'offline': true,
          'message':
              'No internet connection. Insurance application saved offline.',
        };
      }

      return await _insuranceService.applyInsurance(
        token: token,
        farmId: farmId,

        insuredArea: insuredArea,
        civilStatus: civilStatus,
        beneficiaryName: beneficiaryName,
        spouseName: spouseName,
        parentGuardianName: parentGuardianName,
        variety: variety,
        farmType: farmType,
        sowingDate: sowingDate,
        transplantingDate: transplantingDate,
        northBoundary: northBoundary,
        eastBoundary: eastBoundary,
        westBoundary: westBoundary,
        southBoundary: southBoundary,
        isLandOwner: isLandOwner,
        tenureStatus: tenureStatus,
        signature: signature,
        paymentProof: paymentProof,
        gcashReferenceNumber: gcashReferenceNumber,
        clientUuid: clientUuid,
        syncSource: 'online',
        capturedAt: capturedAt,
      );
    } catch (e) {
      await _saveOfflineApplication(offlineApplication);

      return {
        'success': true,
        'offline': true,
        'message': 'Connection failed. Insurance application saved offline.',
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveOfflineApplication(Map<String, dynamic> application) async {
    await _cacheService.savePendingApplication(application);
    pendingApplications = await _cacheService.getPendingApplications();
  }

  Future<void> syncPendingApplications({required String token}) async {
    final applications = await _cacheService.getPendingApplications();

    for (final app in applications) {
      try {
        final paymentProofPath = app['payment_proof_path'];

        await _insuranceService.applyInsurance(
          token: token,
          farmId: app['farm_id'],

          insuredArea: double.tryParse(app['insured_area'].toString()) ?? 0,
          civilStatus: app['civil_status'],
          beneficiaryName: app['beneficiary_name'],
          spouseName: app['spouse_name'],
          parentGuardianName: app['parent_guardian_name'],
          variety: app['variety'],
          farmType: app['farm_type'],
          sowingDate: app['sowing_date'],
          transplantingDate: app['transplanting_date'],
          northBoundary: app['north_boundary'],
          eastBoundary: app['east_boundary'],
          westBoundary: app['west_boundary'],
          southBoundary: app['south_boundary'],
          isLandOwner: app['is_land_owner'] == true,
          tenureStatus: app['tenure_status'],
          signature: File(app['signature_path']),
          paymentProof: paymentProofPath == null
              ? null
              : File(paymentProofPath),
          gcashReferenceNumber: app['gcash_reference_number'],
          clientUuid: app['client_uuid'],
          syncSource: 'offline',
          capturedAt: app['captured_at'],
        );

        await _cacheService.removePendingApplication(app['client_uuid']);
      } catch (_) {
        continue;
      }
    }

    pendingApplications = await _cacheService.getPendingApplications();
    notifyListeners();
  }

  Future<void> loadPendingApplications() async {
    pendingApplications = await _cacheService.getPendingApplications();
    notifyListeners();
  }
}
