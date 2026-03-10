import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class Payment {
  final int    id;
  final String artisanName;
  final String artisanInitial;
  final String serviceType;
  final double amount;
  final String paymentMethod;
  final DateTime date;
  final String status; // 'completed' | 'in_progress'

  const Payment({
    required this.id,
    required this.artisanName,
    required this.artisanInitial,
    required this.serviceType,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> j) {
    final artisan = (j['artisan'] as Map<String, dynamic>?) ?? {};
    final name    = artisan['name'] as String? ?? j['artisan_name'] as String? ?? 'Artisan';
    return Payment(
      id:             j['id'] as int? ?? 0,
      artisanName:    name,
      artisanInitial: name.isNotEmpty ? name[0].toUpperCase() : 'A',
      serviceType:    j['service_type'] as String?
                      ?? j['description'] as String?
                      ?? 'Service',
      amount:         double.tryParse('${j['amount'] ?? j['proposed_price'] ?? 0}') ?? 0,
      paymentMethod:  j['payment_method'] as String? ?? 'Carte bancaire',
      date:           DateTime.tryParse(j['paid_at'] as String? ?? j['created_at'] as String? ?? '')
                      ?? DateTime.now(),
      status:         j['status'] as String? ?? 'completed',
    );
  }
}

class PaymentStats {
  final double totalSpent;
  final double completedAmount;
  final int    completedCount;
  final double pendingAmount;
  final int    pendingCount;
  final double changePercent; // e.g. 12 for +12%

  const PaymentStats({
    required this.totalSpent,
    required this.completedAmount,
    required this.completedCount,
    required this.pendingAmount,
    required this.pendingCount,
    required this.changePercent,
  });

  factory PaymentStats.fromList(List<Payment> payments) {
    final completed = payments.where((p) => p.status == 'completed').toList();
    final pending   = payments.where((p) => p.status != 'completed').toList();
    final total     = payments.fold(0.0, (s, p) => s + p.amount);
    return PaymentStats(
      totalSpent:       total,
      completedAmount:  completed.fold(0.0, (s, p) => s + p.amount),
      completedCount:   completed.length,
      pendingAmount:    pending.fold(0.0, (s, p) => s + p.amount),
      pendingCount:     pending.length,
      changePercent:    12,
    );
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

class PaymentRepository {
  final _dio = ApiClient.instance;

  /// Derives payments from service requests that have accepted offers.
  /// Uses the existing /client/service-requests endpoint — no new backend needed.
  Future<List<Payment>> getPayments() async {
    final res = await _dio.get(ApiConstants.clientRequests);
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;

    final payments = <Payment>[];
    for (final item in raw) {
      final j       = item as Map<String, dynamic>;
      final reqId   = j['id'] as int? ?? 0;
      final status  = j['status'] as String? ?? '';
      final desc    = j['description'] as String? ?? 'Service';
      final createdAt = DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now();

      // Only show requests that have an accepted offer or are completed/in_progress
      final offersRaw = (j['offers'] as List<dynamic>?) ?? [];
      final accepted  = offersRaw
          .map((o) => o as Map<String, dynamic>)
          .where((o) => (o['status'] as String?) == 'accepted')
          .toList();

      if (accepted.isNotEmpty) {
        final offer   = accepted.first;
        final artisan = (offer['artisan'] as Map<String, dynamic>?) ?? {};
        final user    = (artisan['user']  as Map<String, dynamic>?) ?? {};
        final name    = user['full_name'] as String? ?? 'Artisan';
        final price   = double.tryParse('${offer['proposed_price'] ?? 0}') ?? 0;

        payments.add(Payment(
          id:             reqId,
          artisanName:    name,
          artisanInitial: name.isNotEmpty ? name[0].toUpperCase() : 'A',
          serviceType:    desc.length > 30 ? '${desc.substring(0, 30)}…' : desc,
          amount:         price,
          paymentMethod:  'Carte bancaire',
          date:           createdAt,
          status:         status == 'completed' ? 'completed' : 'in_progress',
        ));
      } else if (status == 'completed' || status == 'in_progress') {
        // No accepted offer yet but request is active — show with 0 amount
        payments.add(Payment(
          id:             reqId,
          artisanName:    'En attente',
          artisanInitial: '?',
          serviceType:    desc.length > 30 ? '${desc.substring(0, 30)}…' : desc,
          amount:         0,
          paymentMethod:  'Carte bancaire',
          date:           createdAt,
          status:         'in_progress',
        ));
      }
    }
    return payments;
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
