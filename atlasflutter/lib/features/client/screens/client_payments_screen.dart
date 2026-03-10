import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/payment_repository.dart';

class ClientPaymentsScreen extends StatefulWidget {
  const ClientPaymentsScreen({super.key});

  @override
  State<ClientPaymentsScreen> createState() => _ClientPaymentsScreenState();
}

class _ClientPaymentsScreenState extends State<ClientPaymentsScreen> {
  final _repo          = PaymentRepository();
  final _pageCtrl      = PageController();

  List<Payment> _payments  = [];
  bool          _loading   = true;
  String?       _error;
  String        _filter    = 'all'; // all | completed | in_progress
  int           _cardPage  = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getPayments();
      if (mounted) setState(() { _payments = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error   = PaymentRepository.errorMessage(e);
        _loading = false;
      });
    }
  }

  List<Payment> get _filtered {
    if (_filter == 'all')        return _payments;
    if (_filter == 'completed')  return _payments.where((p) => p.status == 'completed').toList();
    return _payments.where((p) => p.status != 'completed').toList();
  }

  PaymentStats get _stats => PaymentStats.fromList(_payments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6238],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _error != null
                        ? _buildError()
                        : _buildBody(),
              ),
            ],
          ),

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 4)),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.push('/client/agenda'),
                      child: const _HeaderIconBtn(Icons.calendar_today_outlined),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => context.push('/client/notifications'),
                      child: const _HeaderIconBtn(Icons.notifications_none_rounded),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded, color: Color(0xFF393C40), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Que recherchez-vous ?',
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                          color: Color(0xFF494949))),
                  ),
                  Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF393C40),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final stats    = _stats;
    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
        children: [
          // ── Dashboard title ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(29, 20, 29, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tableau de bord des paiements',
                        style: TextStyle(
                          fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                          fontSize: 18, letterSpacing: -0.31, color: Color(0xFF191C24),
                        )),
                      SizedBox(height: 4),
                      Text(
                        'Suivez l\'historique de vos paiements pour les services demandés',
                        style: TextStyle(
                          fontFamily: 'Public Sans', fontWeight: FontWeight.w400,
                          fontSize: 14, height: 1.5, letterSpacing: -0.01,
                          color: Color(0xFF494949),
                        )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.primary, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats cards (horizontal scroll / PageView) ────────────────────
          SizedBox(
            height: 164,
            child: PageView(
              controller: _pageCtrl,
              padEnds: false,
              onPageChanged: (i) => setState(() => _cardPage = i),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 29, right: 8),
                  child: _TotalCard(stats: stats),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: _CompletedCard(stats: stats),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 29),
                  child: _PendingCard(stats: stats),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Pagination dots ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width:  _cardPage == i ? 25 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: _cardPage == i ? AppColors.primary : const Color(0xFFB3B9C1),
                borderRadius: BorderRadius.circular(50),
              ),
            )),
          ),
          const SizedBox(height: 24),

          // ── Historique title ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Historique des paiements',
                  style: TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                    fontSize: 18, letterSpacing: -0.31, color: Color(0xFF191C24),
                  )),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.download_rounded, color: Colors.white, size: 15),
                      SizedBox(width: 4),
                      Text('Exporter',
                        style: TextStyle(
                          fontFamily: 'Public Sans', fontSize: 12,
                          color: Colors.white, fontWeight: FontWeight.w600,
                        )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(29, 4, 29, 0),
            child: Text('${_payments.length} résultat${_payments.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF494949), height: 1.5,
              )),
          ),
          const SizedBox(height: 12),

          // ── Filter tabs ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(95),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(children: [
                _FilterTab(label: 'Tous',      active: _filter == 'all',         onTap: () => setState(() => _filter = 'all')),
                _FilterTab(label: 'Complétés', active: _filter == 'completed',   onTap: () => setState(() => _filter = 'completed')),
                _FilterTab(label: 'En cours',  active: _filter == 'in_progress', onTap: () => setState(() => _filter = 'in_progress')),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // ── Payment rows ──────────────────────────────────────────────────
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Aucun paiement.',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                      color: Color(0xFF9CA3AF))),
              ),
            )
          else
            ...filtered.map((p) => _PaymentRow(
              payment: p,
              onTap:   () => context.push(
                '/client/request-view/${p.id}',
              ),
            )),

          const SizedBox(height: 24),

          // ── Relevé mensuel ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Relevé mensuel',
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                      fontSize: 15, color: Color(0xFF191C24),
                    )),
                  const SizedBox(height: 4),
                  const Text(
                    'Téléchargez votre relevé de paiements du mois\nen cours',
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFF62748E), height: 1.4,
                    )),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.white, size: 18),
                      label: const Text('Télécharger le relevé',
                        style: TextStyle(
                          fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                          fontSize: 14, color: Colors.white,
                        )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Configuration bancaire ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configuration bancaire',
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                      fontSize: 15, color: Color(0xFF191C24),
                    )),
                  const SizedBox(height: 4),
                  const Text('Mettez à jour vos informations de paiement',
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFF62748E), height: 1.4,
                    )),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                      icon: const Icon(Icons.attach_money_rounded,
                          color: Colors.white, size: 18),
                      label: const Text('Gérer mes coordonnées',
                        style: TextStyle(
                          fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                          fontSize: 14, color: Colors.white,
                        )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                  color: Color(0xFF62748E))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats cards ────────────────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final PaymentStats stats;
  const _TotalCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEC4A04), Color(0xFFFF9264)],
        ),
        borderRadius: BorderRadius.circular(12.9),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 39, height: 39,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(11.3),
                ),
                child: const Icon(Icons.attach_money_rounded,
                    color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  const Icon(Icons.trending_up_rounded,
                      color: Colors.white, size: 13),
                  const SizedBox(width: 3),
                  Text('+${stats.changePercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 11.3,
                      color: Colors.white, letterSpacing: -0.12,
                    )),
                ]),
              ),
            ],
          ),
          const Spacer(),
          Text('Total dépensé',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8), letterSpacing: -0.12,
            )),
          Text('${stats.totalSpent.toStringAsFixed(0)} MAD',
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 24,
              color: Colors.white, letterSpacing: 0.3,
            )),
          Text('Ce mois-ci',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7), letterSpacing: -0.12,
            )),
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final PaymentStats stats;
  const _CompletedCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
        borderRadius: BorderRadius.circular(12.9),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 39, height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(11.3),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF00A63E), size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('${stats.completedCount} paiements',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 9.6,
                    color: Color(0xFF00A63E),
                  )),
              ),
            ],
          ),
          const Spacer(),
          const Text('Paiements effectués',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12, letterSpacing: -0.12,
              color: Color(0xFF62748E),
            )),
          Text('${stats.completedAmount.toStringAsFixed(0)} MAD',
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 24,
              color: Color(0xFF314158), letterSpacing: 0.3,
            )),
          Row(children: const [
            Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF02BB05), size: 15),
            SizedBox(width: 6),
            Text('Services terminés',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                color: Color(0xFF00A63E), letterSpacing: -0.12,
              )),
          ]),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PaymentStats stats;
  const _PendingCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
        borderRadius: BorderRadius.circular(12.9),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 39, height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD4),
                  borderRadius: BorderRadius.circular(11.3),
                ),
                child: const Icon(Icons.access_time_rounded,
                    color: Color(0xFFF54900), size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('${stats.pendingCount} paiements',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 9.6,
                    color: Color(0xFFF54900),
                  )),
              ),
            ],
          ),
          const Spacer(),
          const Text('Paiements en attente',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12, letterSpacing: -0.12,
              color: Color(0xFF62748E),
            )),
          Text('${stats.pendingAmount.toStringAsFixed(0)} MAD',
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 24,
              color: Color(0xFF314158), letterSpacing: 0.3,
            )),
          Row(children: const [
            Icon(Icons.access_time_rounded, color: Color(0xFFF54900), size: 13),
            SizedBox(width: 6),
            Text('En cours de traitement',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                color: Color(0xFFF54900), letterSpacing: -0.12,
              )),
          ]),
        ],
      ),
    );
  }
}

// ── Filter tab ─────────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  const _FilterTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(90),
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13.3,
              letterSpacing: -0.01,
              color: active ? Colors.white : AppColors.primary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            )),
        ),
      ),
    );
  }
}

// ── Payment row ────────────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final Payment      payment;
  final VoidCallback onTap;
  const _PaymentRow({required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = payment.status == 'completed';
    final dateStr = '${payment.date.day.toString().padLeft(2, '0')}/'
        '${payment.date.month.toString().padLeft(2, '0')}/'
        '${payment.date.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      child: Column(
        children: [
          // Row 1: avatar + name + service
          Row(
            children: [
              // Avatar
              Container(
                width: 33, height: 33,
                decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(payment.artisanInitial,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11.5,
                    color: Colors.white, letterSpacing: -0.12,
                  )),
              ),
              const SizedBox(width: 10),
              // Name
              Expanded(
                child: Text(payment.artisanName,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13.2,
                    color: Color(0xFF314158), letterSpacing: -0.26,
                  )),
              ),
              // Service type
              Text(payment.serviceType,
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 12,
                  color: Color(0xFF314158), letterSpacing: -0.26,
                )),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: amount + method + date + status
          Row(
            children: [
              const SizedBox(width: 43), // align under name
              // Amount icon
              const Icon(Icons.attach_money_rounded,
                  color: AppColors.primary, size: 13),
              const SizedBox(width: 2),
              Text('${payment.amount.toStringAsFixed(0)} MAD',
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 10.7,
                  color: Color(0xFF314158), letterSpacing: -0.21,
                )),
              const SizedBox(width: 14),
              // Payment method icon
              const Icon(Icons.credit_card_rounded,
                  color: AppColors.primary, size: 13),
              const SizedBox(width: 2),
              Text(payment.paymentMethod,
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 9.4,
                  color: Color(0xFF62748E), letterSpacing: -0.10,
                )),
              const SizedBox(width: 14),
              // Date icon
              const Icon(Icons.calendar_today_outlined,
                  color: AppColors.primary, size: 11),
              const SizedBox(width: 2),
              Text(dateStr,
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 9.4,
                  color: Color(0xFF62748E), letterSpacing: -0.10,
                )),
              const Spacer(),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFEDD4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_outline_rounded
                        : Icons.access_time_rounded,
                    size: 10.7,
                    color: isCompleted
                        ? const Color(0xFF008236)
                        : const Color(0xFFCA3500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCompleted ? 'Complété' : 'En cours',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 9.4,
                      color: isCompleted
                          ? const Color(0xFF008236)
                          : const Color(0xFFCA3500),
                    )),
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

// ── Header icon button ─────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 40,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(icon, color: const Color(0xFF393C40), size: 20),
  );
}
