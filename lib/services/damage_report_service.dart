import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class DamageReportService {
  static const String baseUrl = 'http://192.168.100.173:8000/api';

  Future<Map<String, dynamic>> submitDamageReport({
    required String token,
    required int farmId,
    required String damageCause,
    required String damageDate,
    required File damageImage,
    required String reportLatitude,
    required String reportLongitude,

    // Offline sync fields
    required String clientUuid,
    required String syncSource,
    required String capturedAt,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/damage-reports'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'farm_id': farmId.toString(),
      'damage_cause': damageCause,
      'damage_date': damageDate,
      'report_latitude': reportLatitude,
      'report_longitude': reportLongitude,

      // Offline sync fields
      'client_uuid': clientUuid,
      'sync_source': syncSource,
      'captured_at': capturedAt,
    });

    request.files.add(
      await http.MultipartFile.fromPath('damage_image', damageImage.path),
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

    throw Exception(data['message'] ?? 'Failed to submit damage report');
  }
}
