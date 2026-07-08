import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class FarmService {
  Future<Map<String, dynamic>> registerFarm({
    required String token,
    required int farmerProfileId,
    required String farmName,
    required String cropType,
    required String farmArea,
    required String latitude,
    required String longitude,
    required File farmImage,

    // Offline sync support
    required String clientUuid,
    required String syncSource,
    required String capturedAt,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/farms'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'farmer_profile_id': farmerProfileId.toString(),
      'farm_name': farmName,
      'crop_type': cropType,
      'farm_area': farmArea,
      'latitude': latitude,
      'longitude': longitude,

      // Offline sync fields
      'client_uuid': clientUuid,
      'sync_source': syncSource,
      'captured_at': capturedAt,
    });

    request.files.add(
      await http.MultipartFile.fromPath('farm_image', farmImage.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to register farm');
  }

  Future<List<dynamic>> getFarms({
    required String token,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/farms/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to load farms');
  }
}
