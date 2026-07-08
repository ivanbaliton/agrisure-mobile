import 'dart:convert';

import 'package:http/http.dart' as http;

class ClaimService {
  static const String baseUrl = 'http://192.168.100.173:8000/api';

  Future<List<dynamic>> getMyClaims({
    required String token,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/farmers/$userId/claims'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map && decoded['claims'] is List) {
      return decoded['claims'];
    }

    throw Exception(decoded['message'] ?? 'Failed to load claims');
  }

  Future<Map<String, dynamic>> getClaimDetails({
    required String token,
    required int claimId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/$claimId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }
}
