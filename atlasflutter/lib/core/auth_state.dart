import 'package:flutter/foundation.dart';
import 'storage/secure_storage.dart';

/// Global auth state. Listenable by GoRouter's [refreshListenable].
class AuthState extends ChangeNotifier {
  AuthState._();
  static final AuthState instance = AuthState._();

  bool    _isLoggedIn = false;
  String? _userRole;            // 'client' | 'artisan'

  bool    get isLoggedIn => _isLoggedIn;
  String? get userRole   => _userRole;
  bool    get isArtisan  => _userRole == 'artisan';
  bool    get isClient   => _userRole == 'client';

  /// Call once at startup to restore token + role from storage.
  Future<void> init() async {
    final token = await SecureStorage.getToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    if (_isLoggedIn) {
      final user = await SecureStorage.getUser();
      _userRole  = user?['account_type'] as String?;
    }
    notifyListeners();
  }

  void setLoggedIn(bool value, {String? role}) {
    _isLoggedIn = value;
    if (!value) {
      _userRole = null;
    } else if (role != null) {
      _userRole = role;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await SecureStorage.clear();
    _isLoggedIn = false;
    _userRole   = null;
    notifyListeners();
  }
}
