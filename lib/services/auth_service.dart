import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Accept': 'application/json'},
      body: {'login': login, 'password': password},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register({
    required Map<String, String> data,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.register),
    );

    request.headers.addAll({'Accept': 'application/json'});

    request.fields.addAll(data);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyLoginOtp({
    required int userId,
    required String otpCode,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyLoginOtp),
      headers: {'Accept': 'application/json'},
      body: {'user_id': userId.toString(), 'otp_code': otpCode},
    );

    return jsonDecode(response.body);
  }

  /// Requests a new OTP to be sent to the user's registered email or phone.
  /// Add ApiConstants.resendOtp pointing to your backend endpoint,
  /// e.g. '/api/otp/resend'
  Future<Map<String, dynamic>> resendOtp({required int userId}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.resendOtp), // add this to ApiConstants
      headers: {'Accept': 'application/json'},
      body: {'user_id': userId.toString()},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> forgotPassword({required String login}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.forgotPassword),
      headers: {'Accept': 'application/json'},
      body: {'login': login},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required int userId,
    required String otpCode,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyForgotPasswordOtp),
      headers: {'Accept': 'application/json'},
      body: {'user_id': userId.toString(), 'otp_code': otpCode},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.resetPassword),
      headers: {'Accept': 'application/json'},
      body: {
        'user_id': userId.toString(),
        'otp_code': otpCode,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return jsonDecode(response.body);
  }
}
