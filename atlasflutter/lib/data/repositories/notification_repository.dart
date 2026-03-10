import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AppNotification {
  final int    id;
  final String senderName;
  final String message;
  final String type;    // e.g. 'offer', 'request', 'system'
  final bool   isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.senderName,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    return AppNotification(
      id:         j['id'] as int? ?? 0,
      senderName: j['title'] as String? ?? 'AtlasFix',
      message:    j['message'] as String? ?? '',
      type:       j['type'] as String? ?? 'system',
      isRead:     j['is_read'] as bool? ?? false,
      createdAt:  DateTime.tryParse(j['created_at'] as String? ?? '')
                  ?? DateTime.now(),
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

class NotificationRepository {
  final _dio = ApiClient.instance;

  Future<List<AppNotification>> getNotifications() async {
    final res = await _dio.get(ApiConstants.notifications);
    final raw = (res.data['notifications'] ?? res.data['data'] ?? res.data) as List<dynamic>;
    return raw
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    await _dio.post('${ApiConstants.notifications}/read-all');
  }

  static String errorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'Connexion impossible. Vérifiez votre réseau.';
    }
    if (msg.contains('401')) return 'Session expirée. Reconnectez-vous.';
    return 'Une erreur est survenue.';
  }
}
