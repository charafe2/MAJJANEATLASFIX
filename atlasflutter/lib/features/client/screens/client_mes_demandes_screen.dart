import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/service_request_repository.dart';
import '../../../../data/repositories/conversation_repository.dart';

// ── Filter tabs ───────────────────────────────────────────────────────────────

const _kStatuses = [
  _Tab('all',         'Tous'),
  _Tab('open',        'En attente'),
  _Tab('in_progress', 'Accepté'),
  _Tab('cancelled',   'Annulé'),
  _Tab('completed',   'Terminé'),
];

IconData _categoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('plomb'))    return Icons.water_drop_outlined;
  if (n.contains('élec') || n.contains('elec')) return Icons.bolt_outlined;
  if (n.contains('peinture')) return Icons.format_paint_outlined;
  if (n.contains('menuiser')) return Icons.carpenter_outlined;
  if (n.contains('nettoy'))   return Icons.cleaning_services_outlined;
  if (n.contains('jardinage')|| n.contains('jardin')) return Icons.yard_outlined;
  if (n.contains('restaur'))  return Icons.restaurant_outlined;
  if (n.contains('beauté') || n.contains('coiff')) return Icons.face_outlined;
  if (n.contains('déménag'))  return Icons.local_shipping_outlined;
  if (n.contains('climatis') || n.contains('clim')) return Icons.ac_unit_outlined;
  return Icons.build_outlined;
}

// ─────────────────────────────────────────────────────────────────────────────

class ClientMesDemandesScreen extends StatefulWidget {
  const ClientMesDemandesScreen({super.key});
  @override
  State<ClientMesDemandesScreen> createState() => _ClientMesDemandesScreenState();
}

class _ClientMesDemandesScreenState extends State<ClientMesDemandesScreen> {
  final _repo     = ServiceRequestRepository();
  final _convRepo = ConversationRepository();

  String _activeFilter = 'all';
  final Set<int> _expanded = {};

  bool _isLoading = true;
  String? _error;
  List<ServiceRequest> _requests = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _repo.getRequests();
      if (mounted) {
        setState(() {
          _requests  = data;
          _isLoading = false;
          if (data.isNotEmpty && _expanded.isEmpty) _expanded.add(data.first.id);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ServiceRequestRepository.errorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  List<ServiceRequest> get _filtered {
    if (_activeFilter == 'all') return _requests;
    return _requests.where((r) => r.status == _activeFilter).toList();
  }

  Map<String, int> get _counts {
    final m = <String, int>{'all': _requests.length};
    for (final r in _requests) {
      m[r.status] = (m[r.status] ?? 0) + 1;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Warm gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.55],
                  colors: [Color(0x33FC5A15), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              _buildFilterBar(),
              Expanded(child: _buildBody()),
            ],
          ),

          // Busy overlay
          if (_busy)
            const Positioned.fill(child: ColoredBox(
              color: Color(0x44000000),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )),

          // Bottom nav
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: _BottomNavBar(activeIndex: 1)),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
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
                      onTap: () => context.push('/client/agenda'),
                      child: const _HeaderIconBtn(Icons.calendar_today_outlined),
                    ),
                    const SizedBox(width: 10),
                    const _HeaderIconBtn(Icons.notifications_none_rounded),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes demandes',
                        style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                          fontSize: 20, color: Colors.white,
                        )),
                      SizedBox(height: 2),
                      Text('Gérez vos demandes de service',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12, color: Colors.white70,
                        )),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/client/service-categories'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text('Nouvelle',
                            style: TextStyle(
                              fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                              fontSize: 12, color: AppColors.primary,
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filter tab bar ─────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    final counts = _counts;
    final tabs = _kStatuses.where((t) => t.key == 'all' || (counts[t.key] ?? 0) > 0).toList();

    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tab    = tabs[i];
          final active = _activeFilter == tab.key;
          final count  = counts[tab.key] ?? 0;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = tab.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: active ? [const BoxShadow(
                  color: Color(0x29FC5A15), blurRadius: 8, offset: Offset(0, 3),
                )] : [],
              ),
              child: Text('${tab.label} ($count)',
                style: TextStyle(
                  fontFamily: 'Public Sans', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF62748E),
                )),
            ),
          );
        },
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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

    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Aucune demande pour le moment.',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 15,
                  color: Color(0xFF9CA3AF))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/client/service-categories'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Text('Créer une demande',
                  style: TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final req    = filtered[i];
          final isOpen = _expanded.contains(req.id);
          return _RequestCard(
            request:    req,
            isExpanded: isOpen,
            onToggle:   () => setState(() {
              if (isOpen) { _expanded.remove(req.id); }
              else        { _expanded.add(req.id); }
            }),
            onCancel:   () => _showCancelDialog(req),
            onAccept:   (offer) => _handleAccept(req, offer),
            onReject:   (offer) => _handleReject(req, offer),
            onMessage:  (offer) => _handleMessage(offer),
            onProfile:  (offer) {
              if (offer.artisanId != null) {
                context.push('/artisans/profile/${offer.artisanId}',
                  extra: {'name': offer.artisanName, 'role': offer.artisanSpecialty});
              }
            },
          );
        },
      ),
    );
  }

  // ── Dialogs & actions ──────────────────────────────────────────────────────
  void _showCancelDialog(ServiceRequest req) {
    showDialog(
      context: context,
      builder: (_) => _CancelDialog(
        requestId:   req.id,
        category:    req.category,
        onConfirm:   (reason) async {
          setState(() => _busy = true);
          try {
            await _repo.cancelRequest(req.id);
            await _load();
            if (mounted) _showSnack('Demande annulée.', success: true);
          } catch (e) {
            if (mounted) _showSnack(ServiceRequestRepository.errorMessage(e), success: false);
          } finally {
            if (mounted) setState(() => _busy = false);
          }
        },
      ),
    );
  }

  Future<void> _handleAccept(ServiceRequest req, Offer offer) async {
    setState(() => _busy = true);
    try {
      await _repo.acceptOffer(req.id, offer.id);
      await _load();
      if (mounted) _showSnack('Offre acceptée ! L\'artisan sera notifié.', success: true);
    } catch (e) {
      if (mounted) _showSnack(ServiceRequestRepository.errorMessage(e), success: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleReject(ServiceRequest req, Offer offer) async {
    setState(() => _busy = true);
    try {
      await _repo.rejectOffer(req.id, offer.id);
      await _load();
      if (mounted) _showSnack('Offre refusée.', success: false);
    } catch (e) {
      if (mounted) _showSnack(ServiceRequestRepository.errorMessage(e), success: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleMessage(Offer offer) async {
    if (offer.artisanId == null) {
      _showSnack('Impossible d\'ouvrir la conversation.', success: false);
      return;
    }
    setState(() => _busy = true);
    try {
      final conv = await _convRepo.getOrCreate(artisanId: offer.artisanId);
      if (mounted) {
        context.push('/client/chat/${conv.id}', extra: {
          'name':      offer.artisanName,
          'role':      offer.artisanSpecialty,
          'profileId': conv.otherProfileId,
        });
      }
    } catch (e) {
      if (mounted) _showSnack('Impossible d\'ouvrir la conversation.', success: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
      backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    ));
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onCancel;
  final ValueChanged<Offer> onAccept;
  final ValueChanged<Offer> onReject;
  final ValueChanged<Offer> onMessage;
  final ValueChanged<Offer> onProfile;

  const _RequestCard({
    required this.request, required this.isExpanded,
    required this.onToggle, required this.onCancel,
    required this.onAccept, required this.onReject,
    required this.onMessage, required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          if (isExpanded) _buildCardBody(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon(request.category),
              color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(request.category,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                      fontSize: 15, color: Color(0xFF314158),
                    )),
                  if (request.offers.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${request.offers.length} réponse${request.offers.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontFamily: 'Public Sans', fontSize: 11,
                          fontWeight: FontWeight.w600, color: AppColors.primary,
                        )),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                _StatusPill(status: request.status),
              ],
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (request.status == 'open' || request.status == 'in_progress')
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 18),
                ),
              ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary, size: 22),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildCardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Description de la demande',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    color: Color(0xFF62748E))),
              const SizedBox(height: 4),
              Text(request.description,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                    color: Color(0xFF314158))),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF62748E)),
                const SizedBox(width: 4),
                Text(request.city,
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                      color: Color(0xFF62748E))),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF62748E)),
                const SizedBox(width: 4),
                Text(_formatDate(request.createdAt),
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                      color: Color(0xFF62748E))),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (request.offers.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Column(children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                    size: 30, color: Color(0xFFD1D5DC)),
                  SizedBox(height: 8),
                  Text('Aucune réponse d\'artisan pour le moment.',
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                        color: Color(0xFF9CA3AF))),
                ]),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Text(
              'Artisans ayant répondu (${request.offers.length})',
              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                  fontSize: 14, color: Color(0xFF314158))),
          ),
          ...request.offers.map((offer) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: _OfferCard(
              offer:     offer,
              onAccept:  () => onAccept(offer),
              onReject:  () => onReject(offer),
              onMessage: () => onMessage(offer),
              onProfile: () => onProfile(offer),
            ),
          )),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                    'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return '${dt.day} ${months[dt.month - 1]}. ${dt.year}';
  }
}

// ── Offer card ────────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onMessage;
  final VoidCallback onProfile;

  const _OfferCard({
    required this.offer,
    required this.onAccept,
    required this.onReject,
    required this.onMessage,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = offer.status == 'accepted';
    final isRejected = offer.status == 'rejected';

    return Opacity(
      opacity: isRejected ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAccepted ? const Color(0xFFF0FDF4) : Colors.white,
          border: Border.all(
            color: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFF3F4F6),
            width: 0.75,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            // Artisan row
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: _avatarColor(offer.artisanName),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(_initials(offer.artisanName),
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 13, height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C950),
                          border: Border.all(color: Colors.white, width: 1.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.artisanName,
                        style: const TextStyle(fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600, fontSize: 13,
                            color: Color(0xFF314158))),
                      const SizedBox(height: 2),
                      Text(offer.artisanSpecialty,
                        style: const TextStyle(fontFamily: 'Public Sans',
                            fontSize: 10, color: Color(0xFF62748E))),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEFCE8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                size: 11, color: Color(0xFFFDC700)),
                              const SizedBox(width: 3),
                              Text(offer.rating.toStringAsFixed(1),
                                style: const TextStyle(fontFamily: 'Public Sans',
                                    fontSize: 10, color: Color(0xFF314158))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('(${offer.reviews} avis)',
                          style: const TextStyle(fontFamily: 'Public Sans',
                              fontSize: 9, color: Color(0xFF62748E))),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Price box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prix proposé',
                          style: TextStyle(fontFamily: 'Public Sans', fontSize: 9,
                              color: Color(0xFF62748E))),
                        Text('${offer.price.toStringAsFixed(0)} DH',
                          style: const TextStyle(fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700, fontSize: 20,
                              color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Durée estimée',
                        style: TextStyle(fontFamily: 'Public Sans', fontSize: 9,
                            color: Color(0xFF62748E))),
                      Text(_formatDuration(offer.duration),
                        style: const TextStyle(fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600, fontSize: 13,
                            color: Color(0xFF314158))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Row(children: [
              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF62748E)),
              const SizedBox(width: 4),
              Text('Répondu ${_timeAgo(offer.respondedAt)}',
                style: const TextStyle(fontFamily: 'Public Sans',
                    fontSize: 10, color: Color(0xFF62748E))),
            ]),

            if (isAccepted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('✓ Offre acceptée',
                    style: TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600, fontSize: 13,
                        color: Color(0xFF16A34A))),
                ),
              ),
            ] else if (isRejected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('✗ Offre refusée',
                    style: TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600, fontSize: 13,
                        color: Color(0xFFC10007))),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Refuser',
                          style: TextStyle(fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600, fontSize: 12,
                              color: AppColors.primary)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Accepter',
                          style: TextStyle(fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600, fontSize: 12,
                              color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ]),
            ],

            const SizedBox(height: 8),
            Row(children: [
              _SecondaryBtn(icon: Icons.chat_bubble_outline_rounded,
                label: 'Message', onTap: onMessage),
              const SizedBox(width: 6),
              const _SecondaryBtn(icon: Icons.phone_outlined, label: 'Appel'),
              const SizedBox(width: 6),
              _SecondaryBtn(icon: Icons.person_outline_rounded,
                label: 'Profil', onTap: onProfile),
            ]),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(String name) {
    const palette = [
      Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF06B6D4),
    ];
    if (name.isEmpty) return palette[0];
    return palette[name.codeUnitAt(0) % palette.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  String _formatDuration(int mins) {
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '$h heure${h > 1 ? 's' : ''}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
  }
}

class _SecondaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SecondaryBtn({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.75),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF62748E)),
            const SizedBox(width: 4),
            Text(label,
              style: const TextStyle(fontFamily: 'Public Sans',
                  fontSize: 10, color: Color(0xFF62748E))),
          ],
        ),
      ),
    ),
  );
}

// ── Cancel dialog ─────────────────────────────────────────────────────────────

class _CancelDialog extends StatefulWidget {
  final int requestId;
  final String category;
  final Future<void> Function(String reason) onConfirm;
  const _CancelDialog({
    required this.requestId,
    required this.category,
    required this.onConfirm,
  });

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _ctrl    = TextEditingController();
  bool _loading  = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Supprimer la demande',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  fontSize: 17, color: Color(0xFF314158))),
            const SizedBox(height: 6),
            const Text('Souhaitez-vous vraiment supprimer cette demande ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                  color: Color(0xFF62748E), height: 1.4)),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Raison de l\'annulation (optionnel)',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                      color: Color(0xFF314158), fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  enabled: !_loading,
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFF314158)),
                  decoration: InputDecoration(
                    hintText: 'Expliquez la raison…',
                    hintStyle: const TextStyle(fontFamily: 'Public Sans',
                        fontSize: 13, color: Color(0xFF9CA3AF)),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Annuler',
                    style: TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600, fontSize: 13,
                        color: Color(0xFF62748E))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : () async {
                    setState(() => _loading = true);
                    Navigator.pop(context);
                    await widget.onConfirm(_ctrl.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Text('Supprimer',
                          style: TextStyle(fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600, fontSize: 13,
                              color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

// ── Status pill ───────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'open'        => ('En attente', const Color(0xFFFEFCE8), const Color(0xFFA65F00)),
      'in_progress' => ('En cours',   const Color(0xFFF0FDF4), const Color(0xFF008236)),
      'completed'   => ('Terminé',    const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
      'cancelled'   => ('Annulé',     const Color(0xFFFEF2F2), const Color(0xFFC10007)),
      _             => (status,       const Color(0xFFF3F4F6), const Color(0xFF62748E)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
        style: TextStyle(fontFamily: 'Public Sans', fontSize: 11,
            fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Shared header widgets ─────────────────────────────────────────────────────

class _WhiteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Atlas',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 20,
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
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
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
    width: 38, height: 38,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(icon, color: const Color(0xFF393C40), size: 19),
  );
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  const _BottomNavBar({required this.activeIndex});

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    switch (index) {
      case 0: context.go('/client/dashboard');            break;
      case 1: context.go('/client/mes-demandes');         break;
      case 2: context.push('/client/service-categories'); break;
      case 3: context.go('/client/messages');             break;
      case 4: context.go('/client/profile');              break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_outlined,
      Icons.list_alt_outlined,
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

// ── Filter tab ─────────────────────────────────────────────────────────────────

class _Tab {
  final String key;
  final String label;
  const _Tab(this.key, this.label);
}
