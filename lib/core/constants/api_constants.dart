class ApiConstants {
  static const String baseUrl = 'http://192.168.254.121:8000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';

  static const String barangays = '$baseUrl/barangays/list';

  static const String verifyLoginOtp = '$baseUrl/verify-login-otp';
  static const String resendOtp = '$baseUrl/otp/resend';
  static const String forgotPassword = '$baseUrl/forgot-password';

  static const String verifyForgotPasswordOtp =
      '$baseUrl/forgot-password/verify-otp';

  static const String resetPassword = '$baseUrl/forgot-password/reset';

  static const String saveFcmToken = '$baseUrl/save-fcm-token';

  static const String notifications = '$baseUrl/notifications';
  static const String notificationUnreadCount =
      '$baseUrl/notifications/unread-count';

  static String markNotificationAsRead(int id) {
    return '$baseUrl/notifications/$id/read';
  }
}
