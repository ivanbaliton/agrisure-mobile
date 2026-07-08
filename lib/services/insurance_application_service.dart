import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class InsuranceService {
  static const String baseUrl = 'http://192.168.100.173:8000/api';

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
    required String clientUuid,
    required String syncSource,
    required String capturedAt,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/insurance-applications'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'farm_id': farmId.toString(),

      'insured_area': insuredArea.toString(),
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
      'is_land_owner': isLandOwner ? '1' : '0',
      'tenure_status': tenureStatus,
      'client_uuid': clientUuid,
      'sync_source': syncSource,
      'captured_at': capturedAt,
    });

    if (gcashReferenceNumber != null &&
        gcashReferenceNumber.trim().isNotEmpty) {
      request.fields['gcash_reference_number'] = gcashReferenceNumber.trim();
    }

    request.files.add(
      await http.MultipartFile.fromPath('signature', signature.path),
    );

    if (paymentProof != null) {
      request.files.add(
        await http.MultipartFile.fromPath('payment_proof', paymentProof.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to submit insurance application',
    );
  }

  Future<Map<String, dynamic>> getFreeCoverage({
    required String token,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/insurance/free-coverage/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to load free coverage');
  }
}
