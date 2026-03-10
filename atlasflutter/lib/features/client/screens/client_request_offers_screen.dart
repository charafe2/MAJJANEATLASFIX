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

  Future<void> _accept(Offer offer) async {
    setState(() => _busy = true);
    try {
      await _repo.acceptOffer(_request!.id, offer.id);
      await _load();
      if (mounted) _snack('Offre acceptée ! L\'artisan sera notifié.', ok: true);
    } catch (e) {
      if (mounted) _snack(ServiceRequestRepository.errorMessage(e), ok: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(Offer offer) async {
    setState(() => _busy = true);
    try {
      await _repo.rejectOffer(_request!.id, offer.id);
      await _load();
      if (mounted) _snack('Offre refusée.', ok: false);
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

              // Search row: two pills side by side
              Row(children: [
                // Left search pill
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 16, right: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(children: [
                      const Expanded(
                        child: Text('Quelle demande recher...',
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
                ),
                const SizedBox(width: 8),

                // Right city pill
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(left: 16, right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ville...',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          letterSpacing: -0.01 * 14,
                          color: Color(0xFF494949),
                        )),
                      const SizedBox(width: 6),
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF393C40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ]),
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
              child: const Text('Filtrer',
                style: TextStyle(
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
    );
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

    final offers = _request?.offers ?? [];
    if (offers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFD1D5DC)),
            SizedBox(height: 12),
            Text(
              'Aucune offre reçue pour le moment.',
              style: TextStyle(
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
            offer:     offer,
            onAccept:  offer.status == 'pending' ? () => _accept(offer) : null,
            onReject:  offer.status == 'pending' ? () => _reject(offer) : null,
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

// ── Offer card ─────────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  final Offer          offer;
  final VoidCallback?  onAccept;
  final VoidCallback?  onReject;
  final VoidCallback?  onMessage;
  final VoidCallback?  onProfile;

  const _OfferCard({
    required this.offer,
    this.onAccept,
    this.onReject,
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
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
            // ── Section 1: artisan info ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 10),
                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Profil button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(offer.artisanName,
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                letterSpacing: -0.27,
                                color: Color(0xFF314158),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          if (onProfile != null)
                            GestureDetector(
                              onTap: onProfile,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF393C40),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_outline_rounded,
                                        color: Colors.white, size: 11),
                                    SizedBox(width: 3),
                                    Text('Profil',
                                      style: TextStyle(
                                        fontFamily: 'Public Sans',
                                        fontSize: 9,
                                        letterSpacing: -0.09,
                                        color: Colors.white,
                                      )),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Specialty
                      Text(offer.artisanSpecialty,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 9,
                          letterSpacing: -0.09,
                          color: Color(0xFF62748E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      // Stars + review count + response time
                      Row(
                        children: [
                          // Yellow star badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEFCE8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFFDC700), size: 9),
                                const SizedBox(width: 2),
                                Text(offer.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontSize: 8,
                                    letterSpacing: -0.09,
                                    color: Color(0xFF314158),
                                  )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('(${offer.reviews} avis)',
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 7,
                              color: Color(0xFF62748E),
                            )),
                          const Spacer(),
                          Text(_timeAgo(offer.respondedAt),
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 8,
                              letterSpacing: -0.09,
                              color: Color(0xFF62748E),
                            )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Section 2: price + duration (salmon bg) ──────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE8),
                borderRadius: BorderRadius.circular(8.58),
              ),
              child: Row(
                children: [
                  // Left: price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prix proposé',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 8,
                            color: Color(0xFF62748E),
                          )),
                        const SizedBox(height: 2),
                        Text('${offer.price.toStringAsFixed(0)} DH',
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 20,
                            letterSpacing: 0.24,
                            color: AppColors.primary,
                          )),
                      ],
                    ),
                  ),
                  // Right: duration
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Durée estimée',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 8,
                          color: Color(0xFF62748E),
                        )),
                      const SizedBox(height: 2),
                      Text(
                        offer.duration > 0 ? _fmtDuration(offer.duration) : 'None',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 13,
                          letterSpacing: -0.27,
                          color: Color(0xFF314158),
                        )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Section 3: action buttons ────────────────────────────────────
            if (!isRejected)
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary, width: 0.41),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.zero,
                        shadowColor: const Color(0x1A000000),
                        elevation: 1,
                      ),
                      child: const Text('Refuser l\'offre',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 10,
                          letterSpacing: -0.19,
                          color: AppColors.primary,
                        )),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAccepted
                            ? const Color(0xFF16A34A)
                            : AppColors.primary,
                        elevation: 1,
                        shadowColor: const Color(0x1A000000),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        isAccepted ? 'Acceptée' : 'Accepter l\'offre',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 10,
                          letterSpacing: -0.19,
                          color: Colors.white,
                        )),
                    ),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final child = offer.artisanAvatar != null && offer.artisanAvatar!.isNotEmpty
        ? ClipOval(
            child: Image.network(
              offer.artisanAvatar!,
              width: 61, height: 61,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsCircle(),
            ),
          )
        : _initialsCircle();

    return Stack(
      children: [
        Container(
          width: 61, height: 61,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.91),
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
        // Online dot
        Positioned(
          bottom: 2, right: 2,
          child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF00C950),
              border: Border.all(color: Colors.white, width: 0.66),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsCircle() => Container(
    width: 61, height: 61,
    decoration: BoxDecoration(
      color: _avatarColor(offer.artisanName),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(_initials(offer.artisanName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 22,
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
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
