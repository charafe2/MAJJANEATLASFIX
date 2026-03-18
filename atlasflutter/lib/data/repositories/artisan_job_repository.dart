import 'package:dio/dio.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

String? _fullUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  return '${ApiConstants.storageBaseUrl}$url';
}

// ── Models ────────────────────────────────────────────────────────────────────

class ArtisanStats {
  final double rating;
  final int    totalReviews;
  final int    completedServices;
  final int    activeOffers;
  final int    pendingOffers;

  const ArtisanStats({
    required this.rating,
    required this.totalReviews,
    required this.completedServices,
    required this.activeOffers,
    required this.pendingOffers,
  });

  factory ArtisanStats.fromJson(Map<String, dynamic> j) => ArtisanStats(
    rating:             double.tryParse('${j['rating_average'] ?? 0}') ?? 0,
    totalReviews:       j['total_reviews']       as int? ?? 0,
    completedServices:  j['completed_services']  as int? ?? 0,
    activeOffers:       j['active_offers']       as int? ?? 0,
    pendingOffers:      j['pending_offers']      as int? ?? 0,
  );

  factory ArtisanStats.empty() => const ArtisanStats(
    rating: 0, totalReviews: 0, completedServices: 0,
    activeOffers: 0, pendingOffers: 0,
  );
}

class AvailableRequest {
  final int    id;
  final String category;
  final String serviceType;
  final String city;
  final String description;
  final String status;
  final DateTime createdAt;
  final int    offersCount;
  final int?    clientId;
  final String? clientName;
  final String? clientAvatar;
  final String? clientCity;
  final List<String> photos;

  const AvailableRequest({
    required this.id,
    required this.category,
    required this.serviceType,
    required this.city,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.offersCount,
    this.clientId,
    this.clientName,
    this.clientAvatar,
    this.clientCity,
    required this.photos,
  });

  factory AvailableRequest.fromJson(Map<String, dynamic> j) {
    final cat    = j['category']     as Map<String, dynamic>?;
    final st     = j['service_type'] as Map<String, dynamic>?;
    final client = j['client']       as Map<String, dynamic>?;
    final user   = client?['user']   as Map<String, dynamic>?;
    final photosRaw = j['photos']    as List<dynamic>? ?? [];

    return AvailableRequest(
      id:           j['id'] as int,
      category:     cat?['name']     as String? ?? 'Service',
      serviceType:  st?['name']      as String? ?? '',
      city:         j['city']        as String? ?? '',
      description:  j['description'] as String? ?? '',
      status:       j['status']      as String? ?? 'open',
      createdAt:    DateTime.tryParse(j['created_at'] as String? ?? '')
                    ?? DateTime.now(),
      offersCount:  j['offers_count'] as int? ?? 0,
      clientId:     client?['id']      as int?,
      clientName:   user?['full_name'] as String?,
      clientAvatar: user?['resolved_avatar'] as String? ?? _fullUrl(user?['avatar_url'] as String?),
      clientCity:   user?['city']      as String?,
      photos: photosRaw.map((e) {
        if (e is Map) {
          final raw = e['photo_url'] as String? ?? e['url'] as String? ?? '';
          if (raw.isEmpty) return '';
          if (raw.startsWith('http')) return raw;
          return '${ApiConstants.storageBaseUrl}$raw';
        }
        return e.toString();
      }).toList(),
    );
  }
}

class ArtisanOffer {
  final int    id;
  final int    requestId;
  final String category;
  final String serviceType;
  final String city;
  final String description;
  final double price;
  final int    duration;    // minutes
  final String status;      // pending | accepted | rejected
  final DateTime createdAt;
  final String? clientName;
  final String? clientAvatar;

  const ArtisanOffer({
    required this.id,
    required this.requestId,
    required this.category,
    required this.serviceType,
    required this.city,
    required this.description,
    required this.price,
    required this.duration,
    required this.status,
    required this.createdAt,
    this.clientName,
    this.clientAvatar,
  });

  factory ArtisanOffer.fromJson(Map<String, dynamic> j) {
    final req    = j['service_request'] as Map<String, dynamic>? ?? j;
    final cat    = req['category']      as Map<String, dynamic>?;
    final st     = req['service_type']  as Map<String, dynamic>?;
    final client = req['client']        as Map<String, dynamic>?;
    final user   = client?['user']      as Map<String, dynamic>?;

    return ArtisanOffer(
      id:          j['id'] as int,
      requestId:   req['id'] as int? ?? j['service_request_id'] as int? ?? 0,
      category:    cat?['name']           as String? ?? 'Service',
      serviceType: st?['name']            as String? ?? '',
      city:        req['city']            as String? ?? '',
      description: req['description']     as String? ?? '',
      price:       double.tryParse('${j['proposed_price'] ?? 0}') ?? 0,
      duration:    j['estimated_duration'] as int? ?? 0,
      status:      j['status']            as String? ?? 'pending',
      createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '')
                   ?? DateTime.now(),
      clientName:  user?['full_name']     as String?,
      clientAvatar: user?['avatar_url']   as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'accepted': return 'Acceptée';
      case 'rejected': return 'Refusée';
      default:         return 'En attente';
    }
  }

  String get durationLabel {
    if (duration == 0) return '';
    final h = duration ~/ 60;
    final m = duration % 60;
    if (h == 0) return '${m}min';
    return m > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '${h}h';
  }
}

// ── Artisan own profile model ─────────────────────────────────────────────────

class ArtisanMyProfile {
  final int    id;
  final String name;
  final String specialty;
  final String city;
  final String? avatarUrl;
  final String? bio;
  final double  rating;
  final int     totalReviews;
  final int     completedServices;
  final int     activeOffers;
  final int     pendingOffers;
  final String? referralCode;

  const ArtisanMyProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
    this.avatarUrl,
    this.bio,
    required this.rating,
    required this.totalReviews,
    required this.completedServices,
    required this.activeOffers,
    required this.pendingOffers,
    this.referralCode,
  });

  factory ArtisanMyProfile.fromJson(Map<String, dynamic> j) {
    // /me returns a flat structure — all fields at root level
    return ArtisanMyProfile(
      id:                j['id']               as int?    ?? 0,
      name:              j['name']             as String? ?? '',
      specialty:         j['business_name']    as String?
                      ?? j['service_category'] as String? ?? '',
      city:              j['city']             as String? ?? '',
      avatarUrl:         _fullUrl(j['avatar']  as String?),
      bio:               j['bio']              as String?,
      rating:            (j['rating_average']  as num?)?.toDouble() ?? 0.0,
      totalReviews:      j['total_reviews']    as int?    ?? 0,
      completedServices: j['total_jobs_completed'] as int? ?? 0,
      activeOffers:      j['active_offers']    as int?    ?? 0,
      pendingOffers:     j['pending_offers']   as int?    ?? 0,
      referralCode:      j['referral_code']    as String?,
    );
  }

  ArtisanStats get stats => ArtisanStats(
    rating:            rating,
    totalReviews:      totalReviews,
    completedServices: completedServices,
    activeOffers:      activeOffers,
    pendingOffers:     pendingOffers,
  );
}

// ── Repository ────────────────────────────────────────────────────────────────

class ArtisanJobRepository {
  final _dio = ApiClient.instance;

  /// Fetch the authenticated artisan's own profile (name, rating, stats…)
  Future<ArtisanMyProfile> getMyProfile() async {
    final res  = await _dio.get(ApiConstants.me);
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    return ArtisanMyProfile.fromJson(data);
  }

  Future<ArtisanStats> getStats() async {
    try {
      final res  = await _dio.get(ApiConstants.artisanStats);
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return ArtisanStats.fromJson(data);
    } catch (_) {
      return ArtisanStats.empty();
    }
  }

  Future<List<AvailableRequest>> getAvailableRequests({String? city}) async {
    final res = await _dio.get(
      ApiConstants.artisanRequests,
      queryParameters: city != null && city.isNotEmpty ? {'city': city} : null,
    );
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw
        .map((e) => AvailableRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AvailableRequest> getRequest(int id) async {
    final res  = await _dio.get('${ApiConstants.artisanRequests}/$id');
    return AvailableRequest.fromJson(
        (res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<void> submitOffer(
    int requestId, {
    required double price,
    required int    estimatedDuration,
    String?         note,
  }) async {
    await _dio.post(
      '${ApiConstants.artisanRequests}/$requestId/offers',
      data: {
        'proposed_price':      price,
        'estimated_duration':  estimatedDuration,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
  }

  Future<List<ArtisanOffer>> getMyOffers({String? status}) async {
    final res = await _dio.get(
      ApiConstants.artisanOffers,
      queryParameters: status != null ? {'status': status} : null,
    );
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw
        .map((e) => ArtisanOffer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String errorMessage(Object e) {
    if (e is DioException) {
      final b = e.response?.data;
      if (b is Map) {
        if (b['errors'] is Map) {
          return (b['errors'] as Map).values.first is List
              ? ((b['errors'] as Map).values.first as List).first.toString()
              : (b['errors'] as Map).values.first.toString();
        }
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
