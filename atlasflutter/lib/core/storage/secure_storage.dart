import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static const _s        = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey  = 'user_json';

  static Future<void>   saveToken(String t)            => _s.write(key: _tokenKey, value: t);
  static Future<String?> getToken()                    => _s.read(key: _tokenKey);
  static Future<void>   saveUser(Map<String, dynamic> u) =>
      _s.write(key: _userKey, value: jsonEncode(u));
  static Future<Map<String, dynamic>?> getUser() async {
    final raw = await _s.read(key: _userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
  static Future<void> clear() => _s.deleteAll();
}