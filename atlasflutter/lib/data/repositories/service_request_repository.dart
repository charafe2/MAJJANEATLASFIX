import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class ServiceCategory {
  final int    id;
  final String name;
  final String? icon;
  const ServiceCategory({required this.id, required this.name, this.icon});

  factory ServiceCategory.fromJson(Map<String, dynamic> j) => ServiceCategory(
    id:   j['id']   as int,
    name: j['name'] as String,
    icon: j['icon'] as String?,
  );
}

class ServiceType {
  final int    id;
  final String name;
  const ServiceType({required this.id, required this.name});

  factory ServiceType.fromJson(Map<String, dynamic> j) => ServiceType(
    id:   j['id']   as int,
    name: j['name'] as String,
  );
}

class Offer {
  final int    id;
  final String artisanName;
  final String artisanSpecialty;
  final int?   artisanId;
  final double rating;
  final int    reviews;
  final double price;
  final int    duration;   // minutes
  final String status;     // pending | accepted | rejected
  final DateTime respondedAt;
  final String? artisanAvatar;

  const Offer({
    required this.id, required this.artisanName, required this.artisanSpecialty,
    this.artisanId, required this.rating, required this.reviews,
    required this.price, required this.duration, required this.status,
    required this.respondedAt, this.artisanAvatar,
  });

  factory Offer.fromJson(Map<String, dynamic> j) {
    final artisan = j['artisan'] as Map<String, dynamic>? ?? {};
    final user    = artisan['user'] as Map<String, dynamic>? ?? {};
    return Offer(
      id:              j['id'] as int,
      artisanName:     user['full_name'] as String? ?? 'Artisan',
      artisanSpecialty: artisan['business_name'] as String?
                       ?? artisan['service']  as String? ?? '',
      artisanId:       artisan['id'] as int?,
      rating:          double.tryParse('${artisan['rating_average'] ?? 0}') ?? 0,
      reviews:         artisan['total_reviews'] as int? ?? 0,
      price:           double.tryParse('${j['proposed_price'] ?? 0}') ?? 0,
      duration:        j['estimated_duration'] as int? ?? 0,
      status:          j['status'] as String? ?? 'pending',
      respondedAt:     DateTime.tryParse(j['created_at'] as String? ?? '')
                       ?? DateTime.now(),
      artisanAvatar:   user['avatar_url'] as String?,
    );
  }
}

class ServiceRequest {
  final int    id;
  final String category;
  final int?   categoryId;
  final String status;
  final String city;
  final String description;
  final DateTime createdAt;
  final List<Offer> offers;

  const ServiceRequest({
    required this.id, required this.category, this.categoryId,
    required this.status, required this.city, required this.description,
    required this.createdAt, required this.offers,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> j) {
    final cat = j['category'] as Map<String, dynamic>?;
    final st  = j['service_type'] as Map<String, dynamic>?;
    final offersRaw = j['offers'] as List<dynamic>? ?? [];
    return ServiceRequest(
      id:          j['id'] as int,
      category:    cat?['name'] as String? ?? st?['name'] as String? ?? 'Demande',
      categoryId:  cat?['id'] as int?,
      status:      j['status'] as String? ?? 'open',
      city:        j['city'] as String? ?? '',
      description: j['description'] as String? ?? '',
      createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '')
                   ?? DateTime.now(),
      offers:      offersRaw.map((o) => Offer.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

class ServiceRequestRepository {
  final _dio = ApiClient.instance;

  // ── Categories ──────────────────────────────────────────────────────────────
  Future<List<ServiceCategory>> getCategories() async {
    final res = await _dio.get(ApiConstants.categories);
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceType>> getServiceTypes(int categoryId) async {
    final res = await _dio.get('${ApiConstants.categories}/$categoryId/service-types');
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw.map((e) => ServiceType.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Client service requests ─────────────────────────────────────────────────
  Future<List<ServiceRequest>> getRequests({String? status}) async {
    final res = await _dio.get(
      ApiConstants.clientRequests,
      queryParameters: status != null ? {'status': status} : null,
    );
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ServiceRequest> getRequest(int id) async {
    final res = await _dio.get('${ApiConstants.clientRequests}/$id');
    return ServiceRequest.fromJson((res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<ServiceRequest> createRequest({
    required int    categoryId,
    required int    serviceTypeId,
    required String description,
    required String city,
    required String address,
    String?         additionalInfo,
    List<XFile>?    photos,
  }) async {
    final fd = FormData.fromMap({
      'category_id':     categoryId,
      'service_type_id': serviceTypeId,
      'description':     description,
      'city':            city,
      'address':         address,
      if (additionalInfo != null && additionalInfo.isNotEmpty)
        'additional_info': additionalInfo,
    });

    if (photos != null) {
      for (var i = 0; i < photos.length; i++) {
        final bytes = await photos[i].readAsBytes();
        final ext   = photos[i].name.contains('.')
            ? photos[i].name.split('.').last : 'jpg';
        fd.files.add(MapEntry(
          'photos[]',
          MultipartFile.fromBytes(bytes, filename: 'photo_$i.$ext'),
        ));
      }
    }

    final res = await _dio.post(
      ApiConstants.clientRequests,
      data:    fd,
      options: Options(contentType: 'multipart/form-data'),
    );
    return ServiceRequest.fromJson((res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<void> cancelRequest(int id) =>
      _dio.patch('${ApiConstants.clientRequests}/$id/cancel');

  Future<ServiceRequest> acceptOffer(int requestId, int offerId, {String? address}) async {
    final res = await _dio.post(
      '${ApiConstants.clientRequests}/$requestId/offers/$offerId/accept',
      data: address != null && address.isNotEmpty ? {'address': address} : {},
    );
    return ServiceRequest.fromJson((res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<void> rejectOffer(int requestId, int offerId) =>
      _dio.post('${ApiConstants.clientRequests}/$requestId/offers/$offerId/reject');

  // ── Error helper ────────────────────────────────────────────────────────────
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
