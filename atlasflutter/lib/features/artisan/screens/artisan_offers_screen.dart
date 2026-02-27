import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/artisan_job_repository.dart';
import 'artisan_home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanOffersScreen extends StatefulWidget {
  const ArtisanOffersScreen({super.key});
  @override
  State<ArtisanOffersScreen> createState() => _ArtisanOffersScreenState();
}

class _ArtisanOffersScreenState extends State<ArtisanOffersScreen>
    with SingleTickerProviderStateMixin {
  final _repo = ArtisanJobRepository();
  late final TabController _tabCtrl;

  List<ArtisanOffer> _all      = [];
  bool               _loading  = true;
  String?            _error;

  static const _tabs = ['Toutes', 'En attente', 'Acceptées', 'Refusées'];
  static const _statuses = [null, 'pending', 'accepted', 'rejected'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getMyOffers();
      if (mounted) setState(() { _all = data; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ArtisanJobRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  List<ArtisanOffer> _filtered(String? status) {
    if (status == null) return _all;
    return _all.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Row(
                          children: [
                            const Text('Mes offres',
                              style: TextStyle(fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, fontSize: 20,
                                color: Colors.white)),
                            const Spacer(),
                            GestureDetector(
                              onTap: _load,
                              child: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TabBar(
                        controller: _tabCtrl,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicator: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                        labelStyle: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        tabs: _tabs.map((t) => Tab(text: t)).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.primary))
                    : _error != null
                        ? _buildError()
                        : TabBarView(
                            controller: _tabCtrl,
                            children: List.generate(_tabs.length, (i) =>
                              _OffersList(
                                offers: _filtered(_statuses[i]),
                                onTap: (o) => context.push(
                                  '/artisan/request/${o.requestId}'),
                              ),
                            ),
                          ),
              ),
            ],
          ),

          // ── Bottom nav ────────────────────────────────────────
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Public Sans',
              fontSize: 14, color: Color(0xFF62748E))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Offers list ───────────────────────────────────────────────────────────────
class _OffersList extends StatelessWidget {
  final List<ArtisanOffer> offers;
  final void Function(ArtisanOffer) onTap;
  const _OffersList({required this.offers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Color(0xFFD1D5DC)),
            SizedBox(height: 12),
            Text('Aucune offre dans cette catégorie.',
              style: TextStyle(fontFamily: 'Public Sans',
                fontSize: 13, color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OfferCard(offer: offers[i], onTap: onTap),
    );
  }
}

// ── Offer card ────────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final ArtisanOffer offer;
  final void Function(ArtisanOffer) onTap;
  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = _statusColors(offer.status);

    return GestureDetector(
      onTap: () => onTap(offer),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.serviceType.isNotEmpty
                        ? offer.serviceType : offer.category,
                    style: const TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600, fontSize: 14,
                      color: Color(0xFF314158)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(offer.statusLabel,
                    style: TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w600, fontSize: 11,
                      color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(offer.description,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Public Sans',
                fontSize: 12.5, color: Color(0xFF45556C), height: 1.4)),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFF3F4F6), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.attach_money_rounded,
                  label: '${offer.price.toStringAsFixed(0)} MAD',
                ),
                const SizedBox(width: 12),
                if (offer.durationLabel.isNotEmpty)
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: offer.durationLabel,
                  ),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                    size: 13, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 3),
                  Text(offer.city,
                    style: const TextStyle(fontFamily: 'Public Sans',
                      fontSize: 11, color: Color(0xFF9CA3AF))),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'accepted':
        return (const Color(0xFF16A34A), const Color(0xFFDCFCE7));
      case 'rejected':
        return (const Color(0xFFDC2626), const Color(0xFFFEE2E2));
      default:
        return (const Color(0xFFD97706), const Color(0xFFFEF3C7));
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.primary),
      const SizedBox(width: 4),
      Text(label,
        style: const TextStyle(fontFamily: 'Public Sans',
          fontWeight: FontWeight.w600, fontSize: 12,
          color: Color(0xFF314158))),
    ],
  );
}
