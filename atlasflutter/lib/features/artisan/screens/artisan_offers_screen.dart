import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/atlas_logo.dart';
import '../../../data/repositories/artisan_job_repository.dart';
import 'artisan_home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanOffersScreen extends StatefulWidget {
  const ArtisanOffersScreen({super.key});
  @override
  State<ArtisanOffersScreen> createState() => _ArtisanOffersScreenState();
}

class _ArtisanOffersScreenState extends State<ArtisanOffersScreen> {
  final _repo = ArtisanJobRepository();

  List<ArtisanOffer> _all     = [];
  List<ArtisanOffer> _shown   = [];
  bool               _loading = true;
  String?            _error;
  String?            _activeFilter; // null = all, 'pending', 'accepted', 'rejected'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getMyOffers();
      if (mounted) {
        setState(() {
          _all    = data;
          _shown  = _applyFilter(data, _activeFilter);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ArtisanJobRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  List<ArtisanOffer> _applyFilter(List<ArtisanOffer> list, String? status) {
    if (status == null) return list;
    return list.where((o) => o.status == status).toList();
  }

  void _setFilter(String? status) {
    setState(() {
      _activeFilter = status;
      _shown = _applyFilter(_all, status);
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        current: _activeFilter,
        onSelect: (s) { Navigator.pop(context); _setFilter(s); },
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient bg
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
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),

          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 88,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 1)),
          ),
        ],
      ),
    );
  }

  // ── Orange header ──────────────────────────────────────────────────────────
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
            children: [
              // Logo + icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.push('/client/agenda'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today_outlined,
                            color: Color(0xFF393C40), size: 20),
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => context.push('/client/notifications'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Color(0xFF393C40), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16, right: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  const Icon(Icons.search_rounded,
                      color: Color(0xFF393C40), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Quelle demande recherchez-vous ?',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        letterSpacing: -0.01 * 14,
                        color: Color(0xFF494949),
                      )),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF393C40),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: const Icon(Icons.tune_rounded,
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

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mes demandes acceptées',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.273,
                          color: Color(0xFF191C24),
                        )),
                      const Icon(Icons.assignment_outlined,
                          color: AppColors.primary, size: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _loading
                        ? 'Chargement...'
                        : '${_shown.length} nouvelle${_shown.length > 1 ? 's' : ''} demande${_shown.length > 1 ? 's' : ''} disponible${_shown.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      color: Color(0xFF62748E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter button
                  Row(children: [
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeFilter != null
                              ? AppColors.primary
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.filter_list_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _activeFilter == null
                                ? 'Filtrer'
                                : _activeFilter == 'accepted'
                                    ? 'Confirmés'
                                    : _activeFilter == 'pending'
                                        ? 'En attente'
                                        : 'Refusés',
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    if (_activeFilter != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _setFilter(null),
                        child: const Icon(Icons.close_rounded,
                            color: Color(0xFF62748E), size: 18),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Content
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(
                  color: AppColors.primary)),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_shown.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _OfferCard(
                      offer: _shown[i],
                      onDetail: () => context.push(
                          '/artisan/request/${_shown[i].requestId}'),
                    ),
                  ),
                  childCount: _shown.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text('Aucune demande pour le moment.',
        style: TextStyle(fontFamily: 'Public Sans',
            fontSize: 14, color: Color(0xFF9CA3AF))),
    ]),
  );

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text(_error!, textAlign: TextAlign.center,
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
    ]),
  );
}

// ── Offer card ─────────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final ArtisanOffer offer;
  final VoidCallback onDetail;
  const _OfferCard({required this.offer, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + status ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFFE5D9),
                  backgroundImage: offer.clientAvatar != null
                      ? NetworkImage(offer.clientAvatar!)
                      : null,
                  child: offer.clientAvatar == null
                      ? Text(
                          (offer.clientName?.isNotEmpty == true)
                              ? offer.clientName![0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Name + date + tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.clientName ?? 'Client',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF191C24),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Soumis le ${_formatDate(offer.createdAt)}',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Tags
                      Wrap(spacing: 6, children: [
                        _Tag(offer.category),
                        if (offer.serviceType.isNotEmpty)
                          _Tag(offer.serviceType),
                      ]),
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(status: offer.status),
              ],
            ),
            const SizedBox(height: 12),

            // ── Description (orange title) ────────────────────────────────
            Text(
              offer.description.length > 80
                  ? '${offer.description.substring(0, 80)}…'
                  : offer.description,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.4,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // ── Info row ──────────────────────────────────────────────────
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF62748E)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(offer.city,
                  style: const TextStyle(
                    fontFamily: 'Public Sans', fontSize: 12,
                    color: Color(0xFF62748E)),
                  overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              if (offer.duration > 0) ...[
                const Icon(Icons.timer_outlined,
                    size: 14, color: Color(0xFF62748E)),
                const SizedBox(width: 3),
                Text('De fin: ${offer.durationLabel}',
                  style: const TextStyle(
                    fontFamily: 'Public Sans', fontSize: 12,
                    color: Color(0xFF62748E))),
              ],
            ]),
            const SizedBox(height: 12),

            // ── Price row ─────────────────────────────────────────────────
            Row(children: [
              Text(
                '${offer.price.toStringAsFixed(0)} DH',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Color(0xFF191C24),
                ),
              ),
              if (offer.duration > 0) ...[
                const SizedBox(width: 12),
                Text(offer.durationLabel,
                  style: const TextStyle(
                    fontFamily: 'Public Sans', fontSize: 12,
                    color: Color(0xFF62748E))),
              ],
            ]),
            const SizedBox(height: 14),

            // ── Action buttons ────────────────────────────────────────────
            Row(children: [
              // Annuler
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Annuler',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    )),
                ),
              ),
              const SizedBox(width: 8),
              // Contacter
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF62748E),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Contacter',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    )),
                ),
              ),
              const SizedBox(width: 8),
              // Profil
              Expanded(
                child: ElevatedButton(
                  onPressed: onDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303030),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Profil',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    )),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ── Status badge ───────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAccepted = status == 'accepted';
    final isRejected = status == 'rejected';

    final bg   = isAccepted ? const Color(0xFFDCFCE7)
                : isRejected ? const Color(0xFFFEE2E2)
                : const Color(0xFFFFF3E0);
    final fg   = isAccepted ? const Color(0xFF16A34A)
                : isRejected ? const Color(0xFFDC2626)
                : const Color(0xFFF97316);
    final label = isAccepted ? 'Confirmé'
                : isRejected ? 'Refusé'
                : 'En attente de confirmation';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: fg,
        )),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label,
      style: const TextStyle(
        fontFamily: 'Public Sans', fontSize: 10,
        color: Color(0xFF62748E),
        fontWeight: FontWeight.w500,
      )),
  );
}

// ── Filter bottom sheet ────────────────────────────────────────────────────────
class _FilterSheet extends StatelessWidget {
  final String? current;
  final ValueChanged<String?> onSelect;
  const _FilterSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [
      (null,       'Toutes les demandes', Icons.list_rounded),
      ('pending',  'En attente',          Icons.hourglass_empty_rounded),
      ('accepted', 'Confirmées',          Icons.check_circle_outline_rounded),
      ('rejected', 'Refusées',            Icons.cancel_outlined),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Filtrer par statut',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF191C24),
            )),
          const SizedBox(height: 16),
          ...options.map((o) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(o.$3,
                color: current == o.$1 ? AppColors.primary : const Color(0xFF62748E)),
            title: Text(o.$2,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: current == o.$1 ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
                color: current == o.$1 ? AppColors.primary : const Color(0xFF191C24),
              )),
            trailing: current == o.$1
                ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                : null,
            onTap: () => onSelect(o.$1),
          )),
        ],
      ),
    );
  }
}
