import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/service_request_repository.dart';
import '../../../../data/repositories/conversation_repository.dart';

class ClientRequestOffersScreen extends StatefulWidget {
  final int             requestId;
  final ServiceRequest? initialRequest;

  const ClientRequestOffersScreen({
    super.key,
    required this.requestId,
    this.initialRequest,
  });

  @override
  State<ClientRequestOffersScreen> createState() =>
      _ClientRequestOffersScreenState();
}

class _ClientRequestOffersScreenState
    extends State<ClientRequestOffersScreen> {
  final _repo     = ServiceRequestRepository();
  final _convRepo = ConversationRepository();

  ServiceRequest? _request;
  bool    _loading = true;
  String? _error;
  bool    _busy    = false;
  String? _filterStatus; // null = all, 'pending', 'accepted', 'rejected'

  @override
  void initState() {
    super.initState();
    if (widget.initialRequest != null) {
      _request = widget.initialRequest;
      _loading = false;
    }
    _load();
  }

  Future<void> _load() async {
    if (_request == null) setState(() { _loading = true; _error = null; });
    try {
      final req = await _repo.getRequest(widget.requestId);
      if (mounted) setState(() { _request = req; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ServiceRequestRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _reject(Offer offer) async {
    setState(() => _busy = true);
    try {
      await _repo.rejectOffer(_request!.id, offer.id);
      await _load();
      if (mounted) _snack('Offre annulée.', ok: true);
    } catch (e) {
      if (mounted) _snack(ServiceRequestRepository.errorMessage(e), ok: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _message(Offer offer) async {
    if (offer.artisanId == null) return;
    setState(() => _busy = true);
    try {
      final conv = await _convRepo.getOrCreate(artisanId: offer.artisanId);
      if (mounted) {
        context.push('/client/chat/${conv.id}', extra: {
          'name':      offer.artisanName,
          'role':      offer.artisanSpecialty,
          'avatar':    offer.artisanAvatar,
          'profileId': conv.otherProfileId,
        });
      }
    } catch (_) {
      if (mounted) _snack('Impossible d\'ouvrir la conversation.', ok: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg, {required bool ok}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
        backgroundColor: ok ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ));

  List<Offer> get _filteredOffers {
    final offers = _request?.offers ?? [];
    if (_filterStatus == null) return offers;
    return offers.where((o) => o.status == _filterStatus).toList();
  }

  Map<String, int> get _statusCounts {
    final offers = _request?.offers ?? [];
    return {
      'all':      offers.length,
      'pending':  offers.where((o) => o.status == 'pending').length,
      'accepted': offers.where((o) => o.status == 'accepted').length,
      'rejected': offers.where((o) => o.status == 'rejected').length,
    };
  }

  void _showFilterSheet() {
    final counts = _statusCounts;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        currentFilter: _filterStatus,
        counts: counts,
        onApply: (status) {
          setState(() => _filterStatus = status);
          Navigator.pop(context);
        },
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
          // Warm gradient background
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildFilterRow(),
              _buildDescription(),
              Expanded(child: _buildBody()),
            ],
          ),

          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x44000000),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 1)),
          ),
        ],
      ),
    );
  }

  // ── Orange header ──────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: AtlasLogo + icon buttons
              Row(children: [
                const AtlasLogo(),
                const Spacer(),
                _CircleIconBtn(icon: Icons.calendar_today_outlined, onTap: () {}),
                const SizedBox(width: 8),
                _CircleIconBtn(icon: Icons.notifications_outlined,
                    onTap: () => context.push('/client/notifications')),
              ]),
              const SizedBox(height: 16),

              // Back button row
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF393C40), size: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Search bar (full width)
              Container(
                height: 48,
                padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
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
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF393C40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_vert_rounded,
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

  // ── Filter row (below header) ───────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: _showFilterSheet,
        child: Container(
          height: 48,
          padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1000),
                ),
                alignment: Alignment.center,
                child: Text(
                  _filterStatus == null
                      ? 'Filtrer'
                      : 'Filtre: ${_statusLabel(_filterStatus!)}',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: -0.01 * 14,
                    color: Colors.white,
                  )),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'pending':  return 'En attente';
      case 'accepted': return 'Accepté';
      case 'rejected': return 'Refusé';
      default:         return status;
    }
  }

  // ── Description ────────────────────────────────────────────────────────────
  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        'Gorem ipsum dolor sit amet, consectetur adipiscing elit dolor sit amet.',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 14,
          height: 1.5,
          letterSpacing: -0.01 * 14,
          color: Color(0xFF494949),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
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
                  style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: Color(0xFF62748E))),
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

    final offers = _filteredOffers;
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFD1D5DC)),
            const SizedBox(height: 12),
            Text(
              _filterStatus != null
                  ? 'Aucune offre ${_statusLabel(_filterStatus!).toLowerCase()}.'
                  : 'Aucune offre reçue pour le moment.',
              style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final offer = offers[i];
          return _OfferCard(
            offer:   offer,
            request: _request!,
            onCancel:  offer.status == 'pending' ? () => _reject(offer) : null,
            onMessage: () => _message(offer),
            onProfile: offer.artisanId != null
                ? () => context.push(
                    '/artisans/profile/${offer.artisanId}',
                    extra: {
                      'name': offer.artisanName,
                      'role': offer.artisanSpecialty,
                    })
                : null,
          );
        },
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final String? currentFilter;
  final Map<String, int> counts;
  final ValueChanged<String?> onApply;

  const _FilterSheet({
    required this.currentFilter,
    required this.counts,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // All
          _FilterOption(
            icon: Icons.list_rounded,
            iconColor: AppColors.primary,
            label: 'Tous (${widget.counts['all'] ?? 0})',
            selected: _selected == null,
            onTap: () => setState(() => _selected = null),
          ),
          const SizedBox(height: 10),
          // Pending
          _FilterOption(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFD08700),
            label: 'En attente (${widget.counts['pending'] ?? 0})',
            selected: _selected == 'pending',
            onTap: () => setState(() => _selected = 'pending'),
          ),
          const SizedBox(height: 10),
          // Accepted
          _FilterOption(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF16A34A),
            label: 'Accepté (${widget.counts['accepted'] ?? 0})',
            selected: _selected == 'accepted',
            onTap: () => setState(() => _selected = 'accepted'),
          ),
          const SizedBox(height: 10),
          // Rejected
          _FilterOption(
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFEF4444),
            label: 'Refusé (${widget.counts['rejected'] ?? 0})',
            selected: _selected == 'rejected',
            onTap: () => setState(() => _selected = 'rejected'),
          ),
          const SizedBox(height: 20),
          // Apply button
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text('Appliquer',
                style: TextStyle(fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF7ED) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                  color: const Color(0xFF314158),
                )),
            ),
            // Radio circle
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFD1D5DC),
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.circle, color: Colors.white, size: 10)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offer card ─────────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  final Offer          offer;
  final ServiceRequest request;
  final VoidCallback?  onCancel;
  final VoidCallback?  onMessage;
  final VoidCallback?  onProfile;

  const _OfferCard({
    required this.offer,
    required this.request,
    this.onCancel,
    this.onMessage,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = offer.status == 'rejected';
    final isAccepted = offer.status == 'accepted';

    return Opacity(
      opacity: isRejected ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary, width: 0.61),
          borderRadius: BorderRadius.circular(9.81),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 1.84,
              offset: Offset(0, 0.61),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: artisan info + status badge ────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + status badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(offer.artisanName,
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: -0.27,
                                color: Color(0xFF314158),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          _statusBadge(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Date
                      Text(
                        'Complété le ${_fmtDate(offer.respondedAt)}',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          color: isAccepted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF62748E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Category + specialty
                      Text(
                        '${request.category} · ${offer.artisanSpecialty}',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          color: Color(0xFF62748E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Section 2: description (peach bg) ────────────────────────
            if (request.description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFE8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(request.description,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF314158),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 10),

            // ── Section 3: date/time/duration/location ───────────────────
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: Color(0xFF62748E)),
                const SizedBox(width: 4),
                Text(_fmtDateTime(offer.respondedAt),
                  style: const TextStyle(fontFamily: 'Public Sans',
                      fontSize: 10, color: Color(0xFF62748E))),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_rounded,
                    size: 12, color: Color(0xFF62748E)),
                const SizedBox(width: 4),
                Text('Durée: ${_fmtDuration(offer.duration)}',
                  style: const TextStyle(fontFamily: 'Public Sans',
                      fontSize: 10, color: Color(0xFF62748E))),
                if (request.city.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on_outlined,
                      size: 12, color: Color(0xFF62748E)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(request.city,
                      style: const TextStyle(fontFamily: 'Public Sans',
                          fontSize: 10, color: Color(0xFF62748E)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ── Section 4: price + duration ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Votre proposition',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 10,
                          color: Color(0xFF62748E),
                        )),
                      const SizedBox(height: 2),
                      Text('${offer.price.toStringAsFixed(0)} DH',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          letterSpacing: 0.24,
                          color: Color(0xFF16A34A),
                        )),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Durée estimée',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 10,
                        color: Color(0xFF62748E),
                      )),
                    const SizedBox(height: 2),
                    Text(
                      offer.duration > 0 ? _fmtDuration(offer.duration) : '-',
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF314158),
                      )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Section 5: 3 action buttons ──────────────────────────────
            Row(children: [
              // Annuler
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: Icon(Icons.cancel_outlined,
                        size: 14,
                        color: onCancel != null
                            ? const Color(0xFFEF4444) : const Color(0xFFD1D5DC)),
                    label: Text('Annuler',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: onCancel != null
                            ? const Color(0xFFEF4444) : const Color(0xFFD1D5DC),
                      )),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: onCancel != null
                            ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Contacter
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 14, color: Colors.white),
                    label: const Text('Contacter',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Profil
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: onProfile,
                    icon: const Icon(Icons.person_outline_rounded,
                        size: 14, color: Colors.white),
                    label: const Text('Profil',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF393C40),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    Color bg, fg;
    IconData icon;
    String text;
    switch (offer.status) {
      case 'accepted':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        icon = Icons.check_circle_outline_rounded;
        text = 'Confirmé';
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFEF4444);
        icon = Icons.cancel_outlined;
        text = 'Refusé';
        break;
      default:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFD08700);
        icon = Icons.access_time_rounded;
        text = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(text,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: fg,
            )),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final child = offer.artisanAvatar != null && offer.artisanAvatar!.isNotEmpty
        ? ClipOval(
            child: Image.network(
              offer.artisanAvatar!,
              width: 56, height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsCircle(),
            ),
          )
        : _initialsCircle();

    return Stack(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 7.15,
                spreadRadius: -1.43,
                offset: Offset(0, 4.77),
              ),
            ],
          ),
          child: ClipOval(child: child),
        ),
        Positioned(
          bottom: 2, right: 2,
          child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF00C950),
              border: Border.all(color: Colors.white, width: 1.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsCircle() => Container(
    width: 56, height: 56,
    decoration: BoxDecoration(
      color: _avatarColor(offer.artisanName),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(_initials(offer.artisanName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        )),
    ),
  );

  Color _avatarColor(String name) {
    const p = [
      Color(0xFFFC5A15), Color(0xFF3B82F6), Color(0xFF8B5CF6),
      Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444),
    ];
    if (name.isEmpty) return p[0];
    int h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) % p.length;
    }
    return p[h];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _fmtDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60, m = minutes % 60;
    return m > 0 ? '${h}h${m}min' : '${h}h';
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _fmtDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Circle icon button ─────────────────────────────────────────────────────────

class _CircleIconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: const BoxDecoration(
          color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: const Color(0xFF393C40)),
    ),
  );
}
