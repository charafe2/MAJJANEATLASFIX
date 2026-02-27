import 'package:dio/dio.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

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

  const PublicArtisan({
    required this.id, required this.name, required this.specialty,
    required this.city, required this.rating, required this.reviews,
    this.avatarUrl, this.bio,
    required this.skills, required this.portfolioPhotos,
    required this.isVerified, this.yearsExperience,
    required this.completedServices, this.subscriptionTier,
  });

  factory PublicArtisan.fromJson(Map<String, dynamic> j) {
    final user     = j['user'] as Map<String, dynamic>? ?? {};
    final skillsRaw  = j['skills'] as List<dynamic>? ?? [];
    final photosRaw  = j['portfolio_photos'] as List<dynamic>? ?? [];

    return PublicArtisan(
      id:                j['id']          as int,
      name:              user['full_name'] as String?  ?? 'Artisan',
      specialty:         j['business_name'] as String? ??
                         j['service']       as String? ?? '',
      city:              j['city']         as String?  ?? '',
      rating:            double.tryParse('${j['rating_average'] ?? 0}') ?? 0,
      reviews:           j['total_reviews'] as int?    ?? 0,
      avatarUrl:         user['avatar_url'] as String?,
      bio:               j['bio']          as String?,
      skills:            skillsRaw.map((e) => e.toString()).toList(),
      portfolioPhotos:   photosRaw.map((e) {
        if (e is Map) return e['url'] as String? ?? '';
        return e.toString();
      }).toList(),
      isVerified:        j['is_verified']  as bool?    ?? false,
      yearsExperience:   j['years_experience'] as int?,
      completedServices: j['completed_services'] as int? ?? 0,
      subscriptionTier:  j['subscription_tier'] as String?,
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
