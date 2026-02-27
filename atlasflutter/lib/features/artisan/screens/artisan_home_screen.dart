import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/repositories/artisan_job_repository.dart';

// ── Icon mapping (same as client side) ───────────────────────────────────────
IconData _catIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('plomb'))                           return Icons.water_drop_outlined;
  if (n.contains('élec') || n.contains('elec'))     return Icons.bolt_outlined;
  if (n.contains('peinture'))                        return Icons.format_paint_outlined;
  if (n.contains('menuiser'))                        return Icons.carpenter_outlined;
  if (n.contains('nettoy'))                          return Icons.cleaning_services_outlined;
  if (n.contains('jardin'))                          return Icons.grass_outlined;
  if (n.contains('déménag'))                         return Icons.local_shipping_outlined;
  if (n.contains('beauté') || n.contains('coiff'))  return Icons.content_cut_outlined;
  if (n.contains('climatis') || n.contains('clim')) return Icons.ac_unit_outlined;
  if (n.contains('construct'))                       return Icons.construction_outlined;
  return Icons.build_outlined;
}

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});
  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  final _repo = ArtisanJobRepository();

  String _artisanName = 'Artisan';
  String _specialty   = '';

  ArtisanStats          _stats    = ArtisanStats.empty();
  List<AvailableRequest> _requests = [];

  bool _statsLoading    = true;
  bool _requestsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
    _loadRequests();
  }

  Future<void> _loadUser() async {
    final user = await SecureStorage.getUser();
    if (user != null && mounted) {
      setState(() {
        _artisanName = user['full_name'] as String? ?? 'Artisan';
        // specialty comes from artisan profile — use stored fallback
        _specialty   = user['specialty'] as String?
                    ?? user['service']   as String? ?? '';
      });
    }
  }

  Future<void> _loadStats() async {
    final s = await _repo.getStats();
    if (mounted) setState(() { _stats = s; _statsLoading = false; });
  }

  Future<void> _loadRequests() async {
    try {
      final data = await _repo.getAvailableRequests();
      if (mounted) setState(() { _requests = data; _requestsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _requestsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  stops: [0.0, 0.55],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStatsRow()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildSectionTitle(
                'Nouvelles demandes',
                onTap: () => context.push('/artisan/available-requests'),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _buildRequestsList()),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 0)),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WhiteLogo(),
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.push('/artisan/agenda'),
                      child: const _HeaderIconBtn(Icons.calendar_today_outlined),
                    ),
                    const SizedBox(width: 15),
                    const _HeaderIconBtn(Icons.notifications_none_rounded),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Bonjour, ${_artisanName.split(' ').first} 👋',
                style: const TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  fontSize: 20, color: Colors.white),
              ),
              if (_specialty.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _specialty,
                  style: TextStyle(
                    fontFamily: 'Public Sans', fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: _statsLoading
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2)))
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000),
                    blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  _StatItem(
                    value: _stats.rating > 0
                        ? _stats.rating.toStringAsFixed(1)
                        : '—',
                    label: 'Note',
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFF8904),
                  ),
                  _divider(),
                  _StatItem(
                    value: '${_stats.completedServices}',
                    label: 'Terminés',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF16A34A),
                  ),
                  _divider(),
                  _StatItem(
                    value: '${_stats.activeOffers}',
                    label: 'Actives',
                    icon: Icons.pending_actions_outlined,
                    iconColor: AppColors.primary,
                  ),
                  _divider(),
                  _StatItem(
                    value: '${_stats.pendingOffers}',
                    label: 'En attente',
                    icon: Icons.hourglass_bottom_rounded,
                    iconColor: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 40, color: const Color(0xFFE5E7EB));

  // ── Section title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: const TextStyle(fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700, fontSize: 18,
              letterSpacing: -0.31, color: Color(0xFF191C24))),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
                child: SizedBox(width: 24, height: 24,
                  child: Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 12)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Requests list ──────────────────────────────────────────────────────────
  Widget _buildRequestsList() {
    if (_requestsLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(
          color: AppColors.primary, strokeWidth: 2)));
    }

    if (_requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 40, color: Color(0xFFD1D5DC)),
                SizedBox(height: 10),
                Text('Aucune nouvelle demande.',
                  style: TextStyle(fontFamily: 'Public Sans',
                    fontSize: 13, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _requests.length > 8 ? 8 : _requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _RequestCard(
        request: _requests[i],
        onTap: () => context.push('/artisan/request/${_requests[i].id}',
          extra: {'request': _requests[i]}),
      ),
    );
  }
}

// ── White logo ─────────────────────────────────────────────────────────────────
class _WhiteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Atlas',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
            fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white),
        ),
        child: const Text('Fix',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
              fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ],
  );
}

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

// ── Stat item ─────────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  const _StatItem({
    required this.value, required this.label,
    required this.icon, required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
              fontSize: 14, color: Color(0xFF314158))),
        Text(label,
          style: const TextStyle(fontFamily: 'Public Sans',
              fontSize: 10, color: Color(0xFF62748E))),
      ],
    ),
  );
}

// ── Request card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final AvailableRequest request;
  final VoidCallback onTap;
  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _timeAgo(request.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000),
              blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_catIcon(request.category),
                color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        request.serviceType.isNotEmpty
                            ? request.serviceType : request.category,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600, fontSize: 14,
                          color: Color(0xFF314158)),
                      ),
                    ),
                    Text(timeAgo,
                      style: const TextStyle(fontFamily: 'Public Sans',
                        fontSize: 11, color: Color(0xFF9CA3AF))),
                  ]),
                  const SizedBox(height: 4),
                  Text(request.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Public Sans',
                      fontSize: 12.5, color: Color(0xFF45556C), height: 1.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                      size: 13, color: Color(0xFF62748E)),
                    const SizedBox(width: 3),
                    Text(request.city,
                      style: const TextStyle(fontFamily: 'Public Sans',
                        fontSize: 11.5, color: Color(0xFF62748E))),
                    const SizedBox(width: 12),
                    const Icon(Icons.groups_outlined,
                      size: 13, color: Color(0xFF62748E)),
                    const SizedBox(width: 3),
                    Text('${request.offersCount} offre(s)',
                      style: const TextStyle(fontFamily: 'Public Sans',
                        fontSize: 11.5, color: Color(0xFF62748E))),
                  ]),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DC), size: 20),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60)  return 'il y a ${diff.inMinutes}min';
    if (diff.inHours   < 24)  return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }
}

// ── Bottom nav bar ────────────────────────────────────────────────────────────
class ArtisanBottomNavBar extends StatelessWidget {
  final int activeIndex;
  const ArtisanBottomNavBar({super.key, required this.activeIndex});

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    switch (index) {
      case 0: context.go('/artisan/dashboard');          break;
      case 1: context.go('/artisan/offers');             break;
      case 2: context.push('/artisan/available-requests'); break;
      case 3: context.go('/artisan/messages');           break;
      case 4: context.go('/artisan/profile');            break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_outlined,
      Icons.assignment_outlined,
      Icons.add,
      Icons.chat_bubble_outline_rounded,
      Icons.person_outline_rounded,
    ];

    return Container(
      width: 342, height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (i) {
          final active = i == activeIndex;
          if (i == 2) {
            return GestureDetector(
              onTap: () => _onTap(context, i),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _onTap(context, i),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icons[i],
                color: active ? AppColors.primary : Colors.white, size: 22),
            ),
          );
        }),
      ),
    );
  }
}
