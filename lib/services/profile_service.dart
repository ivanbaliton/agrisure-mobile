import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = 'http://192.168.100.173:8000/api';

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Request failed');
  }

  Future<Map<String, dynamic>> getProfile({
    required String token,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/farmer/profile/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadProfilePhoto({
    required String token,
    required int userId,
    required String imagePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/farmer/profile/$userId/photo'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateRejectedProfile({
    required String token,
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/farmer/profile/$userId/update-rejected'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: data,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> resubmitVerification({
    required String token,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farmer/profile/$userId/resubmit'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required int userId,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farmer/profile/$userId/change-password'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );

    return _handleResponse(response);
  }
}
