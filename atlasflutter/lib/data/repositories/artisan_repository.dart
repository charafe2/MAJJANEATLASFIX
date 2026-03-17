import 'package:dio/dio.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String? _fullUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  return '${ApiConstants.storageBaseUrl}$url';
}

// API returns rating as a number (e.g. 4.5) or string ("4.5" / "4.5/5")
double _parseRating(dynamic raw) {
  if (raw == null) return 0.0;
  if (raw is num) return raw.toDouble();
  final s = raw.toString().split('/').first.trim();
  return double.tryParse(s) ?? 0.0;
}

// ── Models ────────────────────────────────────────────────────────────────────

class PublicArtisan {
  final int    id;
  final String name;
  final String specialty;
  final String city;
  final double rating;
  final int    reviews;
  final String? avatarUrl;
  final String? bio;
  final List<String> skills;
  final List<String> portfolioPhotos;
  final bool   isVerified;
  final int?   yearsExperience;
  final int    completedServices;
  final String? subscriptionTier;
  final Map<int, int> ratingBreakdown; // star (5→1) → count
  final int?   responseRate;           // percent
  final int?   memberSince;            // year

  const PublicArtisan({
    required this.id, required this.name, required this.specialty,
    required this.city, required this.rating, required this.reviews,
    this.avatarUrl, this.bio,
    required this.skills, required this.portfolioPhotos,
    required this.isVerified, this.yearsExperience,
    required this.completedServices, this.subscriptionTier,
    this.ratingBreakdown = const {},
    this.responseRate,
    this.memberSince,
  });

  factory PublicArtisan.fromJson(Map<String, dynamic> j) {
    // portfolio: list endpoint uses 'portfolio_photos', detail uses 'portfolio'
    final photosRaw = (j['portfolio'] as List<dynamic>?
                    ?? j['portfolio_photos'] as List<dynamic>? ?? []);
    // skills: detail endpoint uses 'services', list may use 'skills'
    final servicesRaw = (j['services'] as List<dynamic>?
                      ?? j['skills']   as List<dynamic>? ?? []);
    // rating breakdown (detail endpoint only)
    final rawBreakdown = j['rating_breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <int, int>{};
    for (final entry in rawBreakdown.entries) {
      final star  = int.tryParse(entry.key) ?? 0;
      final count = (entry.value as Map<String, dynamic>?)?['count'] as int? ?? 0;
      breakdown[star] = count;
    }

    return PublicArtisan(
      id:                j['id']               as int,
      name:              j['name']             as String?  ?? 'Artisan',
      specialty:         j['specialty']        as String?  ??
                         j['service']          as String?  ??
                         j['category']         as String?  ?? '',
      city:              j['city']             as String?  ?? '',
      rating:            _parseRating(j['rating']),
      reviews:           j['reviews_count']    as int?
                      ?? j['reviews']          as int?     ?? 0,
      avatarUrl:         _fullUrl(j['avatar'] as String? ?? j['avatar_url'] as String?),
      bio:               j['bio']              as String?,
      skills:            servicesRaw.map((e) {
        if (e is Map) return e['name'] as String? ?? '';
        return e.toString();
      }).toList(),
      portfolioPhotos:   photosRaw.map((e) {
        if (e is Map) return _fullUrl(e['url'] as String?) ?? '';
        return _fullUrl(e.toString()) ?? '';
      }).toList(),
      isVerified:        j['verified']         as bool?    ?? false,
      yearsExperience:   j['experience_years'] as int?,
      completedServices: j['jobs_completed']   as int?
                      ?? j['completed_services'] as int?   ?? 0,
      subscriptionTier:  j['subscription_tier'] as String?,
      ratingBreakdown:   breakdown,
      responseRate:      j['response_rate']    as int?,
      memberSince:       j['member_since']     as int?,
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

class ArtisanRepository {
  final _dio = ApiClient.instance;

  Future<List<PublicArtisan>> getArtisans({
    String? search,
    String? city,
    String? category,
  }) async {
    final res = await _dio.get(ApiConstants.publicArtisans, queryParameters: {
      if (search   != null && search.isNotEmpty)   'search':   search,
      if (city     != null && city.isNotEmpty)     'city':     city,
      if (category != null && category.isNotEmpty) 'category': category,
    });
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw.map((e) => PublicArtisan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PublicArtisan> getArtisan(int id) async {
    final res = await _dio.get('${ApiConstants.publicArtisans}/$id');
    return PublicArtisan.fromJson(
        (res.data['data'] ?? res.data) as Map<String, dynamic>);
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
