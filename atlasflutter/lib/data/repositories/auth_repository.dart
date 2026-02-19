import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/netwrok/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

// ── Result types ──────────────────────────────────────────────────────────────

/// Returned by preRegister — no token yet, just the user_id to carry forward
class PreRegisterResult {
  final int    userId;
  final String verificationMethod;
  const PreRegisterResult({required this.userId, required this.verificationMethod});
}

/// Returned by verify — account is now active, still no token
class VerifyResult {
  final int    userId;
  final String accountType;
  const VerifyResult({required this.userId, required this.accountType});
}

/// Returned by completeRegister and login — full token + user
class AuthResult {
  final String    token;
  final UserModel user;
  final int       userId;
  const AuthResult({required this.token, required this.user, required this.userId});
}

// ── Repository ────────────────────────────────────────────────────────────────

class AuthRepository {
  final _dio = ApiClient.instance;

  // ------------------------------------------------------------------
  // STEP 1 — pre-register
  // Sends: account_type, full_name, birth_date, email, phone,
  //        verification_method
  // Backend creates stub user + fires OTP
  // Returns: user_id (carry to verify screen)
  // ------------------------------------------------------------------
  Future<PreRegisterResult> preRegister({
    required String accountType,
    required String fullName,
    required String birthDate,
    required String email,
    required String phone,
    required String verificationMethod,
  }) async {
    final res = await _dio.post(ApiConstants.preRegister, data: {
      'account_type':         accountType,
      'full_name':            fullName,
      'birth_date':           birthDate,
      'email':                email,
      'phone':                phone,
      'verification_method':  verificationMethod,
    });
    return PreRegisterResult(
      userId:             res.data['user_id'] as int,
      verificationMethod: res.data['verification_method'] as String,
    );
  }

  // ------------------------------------------------------------------
  // STEP 2 — verify OTP
  // Sends: user_id, code
  // Backend marks is_active=true
  // Returns: user_id + account_type (no token yet)
  // ------------------------------------------------------------------
  Future<VerifyResult> verifyCode({
    required int    userId,
    required String code,
  }) async {
    final res = await _dio.post(ApiConstants.verify, data: {
      'user_id': userId,
      'code':    code,
    });
    return VerifyResult(
      userId:      res.data['user_id']      as int,
      accountType: res.data['account_type'] as String,
    );
  }

  // ------------------------------------------------------------------
  // STEP 3a — complete register for CLIENT
  // Sends: user_id, password, city, address
  // Returns: full token + user
  // ------------------------------------------------------------------
  Future<AuthResult> completeClient({
    required int    userId,
    required String password,
    required String passwordConfirmation,
    required String city,
    required String address,
  }) async {
    final res = await _dio.post(ApiConstants.completeRegister, data: {
      'user_id':              userId,
      'password':             password,
      'password_confirmation': passwordConfirmation,
      'city':                 city,
      'address':              address,
    });
    return _parseAuth(res.data);
  }

  // ------------------------------------------------------------------
  // STEP 3b — complete register for ARTISAN
  // Sends: user_id, password, service, serviceType, city, address,
  //        bio, diploma (file), photos (files)
  // Returns: full token + user
  // ------------------------------------------------------------------
  Future<AuthResult> completeArtisan({
    required int         userId,
    required String      password,
    required String      passwordConfirmation,
    required String      service,
    required String      serviceType,
    required String      city,
    required String      address,
    required String      bio,
    required XFile       diploma,
    required List<XFile> photos,
  }) async {
    // MultipartFile.fromBytes() works on BOTH web and mobile.
    // MultipartFile.fromFile() / fromPath() crash on web (dart:io not available).
    final diplomaBytes = await diploma.readAsBytes();
    final diplomaExt   = diploma.name.contains('.')
        ? diploma.name.split('.').last
        : 'jpg';

    final photoEntries = await Future.wait(
      photos.asMap().entries.map((e) async {
        final bytes = await e.value.readAsBytes();
        final ext   = e.value.name.contains('.')
            ? e.value.name.split('.').last
            : 'jpg';
        return MapEntry(
          'photos[${e.key}]',
          MultipartFile.fromBytes(bytes, filename: 'photo_${e.key}.$ext'),
        );
      }),
    );

    final fd = FormData.fromMap({
      'user_id':               userId,
      'password':              password,
      'password_confirmation': passwordConfirmation,
      'service':               service,
      'service_type':          serviceType,
      'city':                  city,
      'address':               address,
      'bio':                   bio,
      'diploma': MultipartFile.fromBytes(
          diplomaBytes, filename: 'diploma.$diplomaExt'),
      ...Map.fromEntries(photoEntries),
    });

    final res = await _dio.post(
      ApiConstants.completeRegister,
      data:    fd,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseAuth(res.data);
  }

  // ------------------------------------------------------------------
  // RESEND OTP
  // ------------------------------------------------------------------
  Future<void> resendCode(int userId) =>
      _dio.post(ApiConstants.resend, data: {'user_id': userId});

  // ------------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------------
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(ApiConstants.login,
        data: {'email': email, 'password': password});
    final r = _parseAuth(res.data);
    await SecureStorage.saveToken(r.token);
    await SecureStorage.saveUser(r.user.toJson());
    return r;
  }

  // ------------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------------
  Future<void> logout() async {
    try { await _dio.post(ApiConstants.logout); } catch (_) {}
    await SecureStorage.clear();
  }

  // ------------------------------------------------------------------
  // FORGOT / RESET PASSWORD
  // ------------------------------------------------------------------
  Future<int?> forgotPassword({
    required String method,
    required String value,
  }) async {
    final res = await _dio.post(ApiConstants.forgotPassword,
        data: {'method': method, 'value': value});
    return res.data['user_id'] as int?;
  }

  Future<void> resetPassword({
    required int    userId,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) =>
      _dio.post(ApiConstants.resetPassword, data: {
        'user_id':               userId,
        'code':                  code,
        'password':              password,
        'password_confirmation': passwordConfirmation,
      });

  // ------------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------------
  AuthResult _parseAuth(Map<String, dynamic> d) => AuthResult(
    token:  d['token']   as String,
    user:   UserModel.fromJson(d['user'] as Map<String, dynamic>),
    userId: d['user_id'] as int,
  );

  /// Converts a Laravel 422 validation response into a flat Map<field, message>
  static Map<String, String> parseErrors(DioException e) {
    final b = e.response?.data;
    if (b == null) return {'general': 'Erreur de connexion. Vérifiez votre réseau.'};
    if (b['errors'] is Map) {
      return (b['errors'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as List).first.toString()),
      );
    }
    return {
      'general': (b['message'] ?? b['error'] ?? 'Une erreur est survenue').toString(),
    };
  }
}