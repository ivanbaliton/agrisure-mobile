import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> saveFcmToken({required String authToken}) async {
    await _messaging.requestPermission();

    final fcmToken = await _messaging.getToken();

    if (fcmToken == null) return;

    await http.post(
      Uri.parse(ApiConstants.saveFcmToken),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: {'fcm_token': fcmToken},
    );
  }
}
