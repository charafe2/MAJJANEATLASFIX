class ApiConstants {
  ApiConstants._();
  static const String baseUrl          = 'http://127.0.0.1:8000/api';

  // ── 2-step mobile registration ────────────────────────────
  static const String preRegister      = '/pre-register';      // Step 1: create stub + send OTP
  static const String verify           = '/verify';            // Step 2: confirm OTP → is_active=true
  static const String completeRegister = '/complete-register'; // Step 3: password + profile fields

  // ── Shared ────────────────────────────────────────────────
  static const String resend           = '/resend';
  static const String login            = '/login';
  static const String logout           = '/logout';
  static const String forgotPassword   = '/forgot-password';
  static const String resetPassword    = '/reset-password';
}