import 'package:dio/dio.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Model ──────────────────────────────────────────────────────────────────────

class UserProfile {
  final int     id;
  final String  name;
  final String  email;
  final String  phone;
  final String? birthdate;
  final String? city;
  final String? address;
  final String? postalCode;
  final String? avatarUrl;
  final int     demandesCount;
  final int     completedCount;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthdate,
    this.city,
    this.address,
    this.postalCode,
    this.avatarUrl,
    this.demandesCount = 0,
    this.completedCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    // Support nested 'profile' or 'client_profile' sub-object
    final p = (j['profile'] ?? j['client_profile'] ?? {}) as Map<String, dynamic>;
    return UserProfile(
      id:             j['id'] as int? ?? 0,
      name:           j['name'] as String? ?? '',
      email:          j['email'] as String? ?? '',
      phone:          (j['phone'] ?? p['phone']) as String? ?? '',
      birthdate:      (j['birthdate'] ?? p['birthdate']) as String?,
      city:           (j['city'] ?? p['city']) as String?,
      address:        (j['address'] ?? p['address']) as String?,
      postalCode:     (j['postal_code'] ?? p['postal_code']) as String?,
      avatarUrl:      (j['avatar_url'] ?? p['avatar_url'] ??
                       j['avatar']    ?? p['avatar']) as String?,
      demandesCount:  j['demandes_count'] as int? ?? 0,
      completedCount: j['completed_count'] as int? ?? 0,
    );
  }
}

// ── Repository ─────────────────────────────────────────────────────────────────

class ProfileRepository {
  final _dio = ApiClient.instance;

  Future<UserProfile> getProfile() async {
    final res  = await _dio.get(ApiConstants.me);
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? phone,
    String? birthdate,
    String? city,
    String? address,
    String? postalCode,
  }) async {
    final res = await _dio.put(ApiConstants.me, data: {
      if (name       != null) 'name':        name,
      if (phone      != null) 'phone':       phone,
      if (birthdate  != null) 'birthdate':   birthdate,
      if (city       != null) 'city':        city,
      if (address    != null) 'address':     address,
      if (postalCode != null) 'postal_code': postalCode,
    });
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  static String errorMessage(Object e) {
    if (e is DioException) {
      final b = e.response?.data;
      if (b is Map) {
        return (b['message'] ?? b['error'] ?? 'Une erreur est survenue').toString();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Impossible de se connecter au serveur.';
      }
    }
    return 'Une erreur est survenue.';
  }
}
