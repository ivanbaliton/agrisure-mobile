import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class BarangayService {
  Future<List<Map<String, dynamic>>> fetchBarangays() async {
    final response = await http.get(
      Uri.parse(ApiConstants.barangays),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception(
      'Failed to load barangays. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}
