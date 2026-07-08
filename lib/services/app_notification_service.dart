import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class AppNotificationService {
  Future<List<dynamic>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.notifications),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }

  Future<void> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    await http.post(
      Uri.parse(ApiConstants.markNotificationAsRead(notificationId)),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }
}
