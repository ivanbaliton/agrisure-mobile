import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  String? token;
  int? userId;
  String? role;
  String? accountStatus;

  bool get isLoggedIn => token != null && userId != null;

  Future<Map<String, dynamic>> login(String login, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        login: login,
        password: password,
      );

      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(data: data);
      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyLoginOtp(
    int userId,
    String otpCode,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.verifyLoginOtp(
        userId: userId,
        otpCode: otpCode,
      );

      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resendOtp(int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.resendOtp(userId: userId);

      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String login) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(login: login);
      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required int userId,
    required String otpCode,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.verifyForgotPasswordOtp(
        userId: userId,
        otpCode: otpCode,
      );
      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        userId: userId,
        otpCode: otpCode,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAuthData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    token = response['token'];
    userId = response['user']?['id'];
    role = response['user']?['role'];
    accountStatus = response['user']?['account_status'];

    if (token == null || userId == null || role == null) {
      throw Exception('Invalid login response');
    }

    await prefs.setString('token', token!);
    await prefs.setInt('user_id', userId!);
    await prefs.setString('role', role!);

    if (accountStatus != null) {
      await prefs.setString('account_status', accountStatus!);
    }

    await NotificationService.saveFcmToken(authToken: token!);

    notifyListeners();
  }

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    userId = prefs.getInt('user_id');
    role = prefs.getString('role');
    accountStatus = prefs.getString('account_status');

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('role');
    await prefs.remove('account_status');

    token = null;
    userId = null;
    role = null;
    accountStatus = null;

    notifyListeners();
  }

  Future<void> updateAccountStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();

    accountStatus = status;
    await prefs.setString('account_status', status);

    notifyListeners();
  }
}
