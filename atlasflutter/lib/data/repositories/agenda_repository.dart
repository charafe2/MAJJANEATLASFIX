import 'package:dio/dio.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class Appointment {
  final String  id;           // may be "sr-{n}" for service-request items
  final String  type;         // manual | service_request
  final String  title;
  final DateTime scheduledAt;
  final int?    durationMinutes;
  final String? city;
  final String  status;       // scheduled | completed | cancelled
  final String? contactName;
  final String? contactPhone;
  final String? rdvType;
  final String? notes;

  const Appointment({
    required this.id, required this.type, required this.title,
    required this.scheduledAt, this.durationMinutes, this.city,
    required this.status, this.contactName, this.contactPhone,
    this.rdvType, this.notes,
  });

  bool get isCompleted => status == 'completed';

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
    id:              '${j['id']}',
    type:            j['type'] as String? ?? 'manual',
    title:           j['title'] as String? ?? 'Rendez-vous',
    scheduledAt:     DateTime.tryParse(j['scheduled_at'] as String? ?? '')
                     ?? DateTime.now(),
    durationMinutes: j['duration_minutes'] as int?,
    city:            j['city'] as String?,
    status:          j['status'] as String? ?? 'scheduled',
    contactName:     j['contact_name'] as String?,
    contactPhone:    j['contact_phone'] as String?,
    rdvType:         j['rdv_type'] as String?,
    notes:           j['notes'] as String?,
  );

  String get durationLabel {
    if (durationMinutes == null || durationMinutes == 0) return '';
    final h = durationMinutes! ~/ 60;
    final m = durationMinutes! % 60;
    if (h == 0) return '${m}min';
    return m > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '${h}h';
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

class AgendaRepository {
  final _dio = ApiClient.instance;

  Future<List<Appointment>> getAppointments() async {
    final res = await _dio.get(ApiConstants.agenda);
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Appointment> createAppointment({
    required String title,
    required String date,    // Y-m-d
    required String time,    // H:i
    String? clientName,
    String? clientPhone,
    String? duration,        // 30min | 1h | 2h | 3h
    String? city,
    String? notes,
  }) async {
    final res = await _dio.post(ApiConstants.agenda, data: {
      'title':        title,
      'date':         date,
      'time':         time,
      if (clientName  != null) 'client_name':  clientName,
      if (clientPhone != null) 'client_phone': clientPhone,
      if (duration    != null) 'duration':     duration,
      if (city        != null) 'city':         city,
      if (notes       != null) 'notes':        notes,
    });
    return Appointment.fromJson(
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
