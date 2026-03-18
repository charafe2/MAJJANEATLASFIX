import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/service_request_repository.dart';
import '../../../../data/repositories/conversation_repository.dart';
import '../../artisan/screens/artisan_home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ClientRequestViewScreen extends StatefulWidget {
  final int             requestId;
  final ServiceRequest? initialRequest;
  final bool            isArtisan;

  const ClientRequestViewScreen({
    super.key,
    required this.requestId,
    this.initialRequest,
    this.isArtisan = false,
  });

  @override
  State<ClientRequestViewScreen> createState() =>
      _ClientRequestViewScreenState();
}

class _ClientRequestViewScreenState extends State<ClientRequestViewScreen> {
  final _repo     = ServiceRequestRepository();
  final _convRepo = ConversationRepository();

  ServiceRequest? _request;
  bool    _loading = true;
  String? _error;
  bool    _busy    = false;

  // Collapsible section states
  bool _paymentExpanded  = false;
  bool _historyExpanded  = false;
  bool _photosExpanded   = false;

  // Star rating (for completed)
  int _starRating = 0;
  final _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRequest != null) {
      _request = widget.initialRequest;
      _loading = false;
    }
    _load();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  bool get _isArtisan => widget.isArtisan;

  Future<void> _load() async {
    if (_request == null) setState(() { _loading = true; _error = null; });
    try {
      final req = _isArtisan
          ? await _repo.getArtisanRequest(widget.requestId)
          : await _repo.getRequest(widget.requestId);
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

  Future<void> _markCompleted() async {
    setState(() => _busy = true);
    try {
      // Using the cancel endpoint pattern — backend may differ
      // Replace with actual complete endpoint when available
      _snack('Demande marquée comme terminée.', ok: true);
      await _load();
    } catch (e) {
      _snack(ServiceRequestRepository.errorMessage(e), ok: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openChat() async {
    if (_isArtisan) {
      // Artisan chatting with client
      final req = _request;
      if (req == null || req.clientId == null) return;
      setState(() => _busy = true);
      try {
        final conv = await _convRepo.getOrCreate(clientId: req.clientId);
        if (mounted) {
          context.push('/artisan/chat/${conv.id}', extra: {
            'name':      req.clientName ?? 'Client',
            'profileId': conv.otherProfileId,
          });
        }
      } catch (_) {
        _snack('Impossible d\'ouvrir la conversation.', ok: false);
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    } else {
      // Client chatting with artisan
      final offer = _acceptedOffer;
      if (offer == null || offer.artisanId == null) return;
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
        _snack('Impossible d\'ouvrir la conversation.', ok: false);
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  Offer? get _acceptedOffer => _request?.offers
      .where((o) => o.status == 'accepted')
      .firstOrNull;

  bool get _isCompleted => _request?.status == 'completed';

  void _snack(String msg, {required bool ok}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
        backgroundColor: ok ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ));

  String _fmtDate(DateTime d) {
    const months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
                  stops: [0.0, 0.55],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody()),
            ],
          ),

          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x44000000),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),

          Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(
              child: _isArtisan
                  ? const ArtisanBottomNavBar(activeIndex: 1)
                  : const ClientBottomNavBar(activeIndex: 1),
            ),
          ),
        ],
      ),
    );
  }

  // ── Orange header ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final req = _request;
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
              // Top row
              Row(children: [
                const AtlasLogo(),
                const Spacer(),
                _CircleBtn(icon: Icons.calendar_today_outlined,
                    onTap: () => context.push(
                        _isArtisan ? '/artisan/agenda' : '/client/agenda')),
                const SizedBox(width: 8),
                _CircleBtn(icon: Icons.notifications_outlined,
                    onTap: () => context.push('/client/notifications')),
              ]),
              const SizedBox(height: 16),

              // Back + badges row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF393C40), size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status badge
                  _StatusBadge(status: req?.status ?? 'in_progress'),
                  const Spacer(),
                  if (req != null)
                    Text('#${req.id}',
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 13,
                        color: Colors.white70,
                        letterSpacing: -0.2,
                      )),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                req?.category ?? '...',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),

              // Date / time / city row
              if (req != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Text(_fmtDate(req.createdAt),
                      style: const TextStyle(
                          fontFamily: 'Public Sans', fontSize: 12,
                          color: Colors.white70)),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Text(_fmtTime(req.createdAt),
                      style: const TextStyle(
                          fontFamily: 'Public Sans', fontSize: 12,
                          color: Colors.white70)),
                    if (req.city.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 13),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(req.city,
                          style: const TextStyle(
                              fontFamily: 'Public Sans', fontSize: 12,
                              color: Colors.white70),
                          overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final req    = _request!;
    final offer  = _acceptedOffer;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Description card ───────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  icon: Icons.description_outlined,
                  label: 'Description du travail',
                ),
                const SizedBox(height: 10),
                Text(
                  req.description.isNotEmpty
                      ? req.description
                      : 'Aucune description fournie.',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    height: 1.55,
                    color: Color(0xFF62748E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Person card (Artisan or Client) ──────────────────────────────
          if (_isArtisan && req.clientName != null) ...[
            _buildClientCard(req),
            const SizedBox(height: 14),
          ] else if (!_isArtisan && offer != null) ...[
            _buildArtisanCard(offer),
            const SizedBox(height: 14),
          ],

          // ── Collapsible: Informations de paiement ─────────────────────────
          _CollapsibleCard(
            icon:     Icons.account_balance_wallet_outlined,
            label:    'Informations de paiement',
            expanded: _paymentExpanded,
            onToggle: () =>
                setState(() => _paymentExpanded = !_paymentExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Méthode', value: 'Carte bancaire'),
                _InfoRow(label: 'Statut',
                    value: _isCompleted ? 'Payé' : 'En attente'),
                if (offer != null)
                  _InfoRow(label: 'Montant',
                      value: '${offer.price.toStringAsFixed(0)} DH'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Collapsible: Historique de la demande ─────────────────────────
          _CollapsibleCard(
            icon:     Icons.history_rounded,
            label:    'Historique de la demande',
            expanded: _historyExpanded,
            onToggle: () =>
                setState(() => _historyExpanded = !_historyExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HistoryItem(
                    date: _request!.createdAt,
                    label: 'Demande créée',
                    color: AppColors.primary),
                if (offer != null)
                  _HistoryItem(
                    date: offer.respondedAt,
                    label: 'Offre acceptée',
                    color: const Color(0xFF16A34A),
                  ),
                if (_isCompleted)
                  _HistoryItem(
                    date: _request!.createdAt,
                    label: 'Travail terminé',
                    color: const Color(0xFF16A34A),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Collapsible: Photos du problème ───────────────────────────────
          _CollapsibleCard(
            icon:     Icons.photo_library_outlined,
            label:    'Photos du problème',
            expanded: _photosExpanded,
            onToggle: () =>
                setState(() => _photosExpanded = !_photosExpanded),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucune photo jointe.',
                  style: TextStyle(
                    fontFamily: 'Public Sans', fontSize: 13,
                    color: Color(0xFF9CA3AF))),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Actions rapides ────────────────────────────────────────────────
          const _SectionTitle(label: 'Actions rapides'),
          const SizedBox(height: 12),

          if (!_isCompleted)
            _ActionBtn(
              label:   'Marquer comme complété',
              icon:    Icons.check_circle_outline_rounded,
              color:   const Color(0xFF16A34A),
              onTap:   _markCompleted,
            ),
          if (!_isCompleted)
            const SizedBox(height: 10),

          _ActionBtn(
            label:   'Envoyer un message',
            icon:    Icons.chat_bubble_outline_rounded,
            color:   AppColors.primary,
            onTap:   _openChat,
          ),
          const SizedBox(height: 10),

          _ActionBtn(
            label:    'Appeler le client',
            icon:     Icons.phone_outlined,
            outlined: true,
            onTap:    () => _snack('Fonctionnalité bientôt disponible.', ok: false),
          ),
          const SizedBox(height: 10),

          _ActionBtn(
            label:    'Signaler un problème',
            icon:     Icons.flag_outlined,
            outlined: true,
            onTap:    () => _snack('Fonctionnalité bientôt disponible.', ok: false),
          ),
          const SizedBox(height: 20),

          // ── Rating section (completed only) ───────────────────────────────
          if (_isCompleted) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon:  Icons.star_border_rounded,
                    label: 'Donner votre avis',
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Comment s\'est passée votre expérience avec l\'artisan ?',
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFF62748E), height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stars
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < _starRating;
                      return GestureDetector(
                        onTap: () => setState(() => _starRating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            filled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: filled
                                ? const Color(0xFFFDC700)
                                : const Color(0xFFD1D5DC),
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Comment field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _reviewCtrl,
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'Public Sans', fontSize: 13,
                        color: Color(0xFF191C24)),
                      decoration: const InputDecoration(
                        hintText: 'Partagez votre expérience...',
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans', fontSize: 13,
                          color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _starRating == 0
                          ? null
                          : () => _snack('Avis envoyé ! Merci.', ok: true),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Envoyer l\'avis',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        disabledForegroundColor: const Color(0xFF9CA3AF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Besoin d'aide (in_progress only) ──────────────────────────────
          if (!_isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Besoin d\'aide ?',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 15, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('Notre équipe support est disponible 24/7.',
                          style: TextStyle(
                            fontFamily: 'Public Sans', fontSize: 12,
                            color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  String _fmtDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60, m = minutes % 60;
    return m > 0 ? '${h}h${m}min' : '${h}h';
  }

  // ── Artisan card (client viewing) ──────────────────────────────────────
  Widget _buildArtisanCard(Offer offer) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(icon: Icons.engineering_outlined, label: 'Artisan assigné'),
          const SizedBox(height: 14),
          Row(
            children: [
              _PersonAvatar(name: offer.artisanName, avatarUrl: offer.artisanAvatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.artisanName,
                      style: const TextStyle(
                        fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                        fontSize: 15, letterSpacing: -0.2, color: Color(0xFF191C24))),
                    const SizedBox(height: 2),
                    if (offer.artisanSpecialty.isNotEmpty)
                      Text(offer.artisanSpecialty,
                        style: const TextStyle(
                          fontFamily: 'Public Sans', fontSize: 12, color: Color(0xFF62748E))),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFDC700), size: 14),
                      const SizedBox(width: 3),
                      Text(offer.rating.toStringAsFixed(1),
                        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Color(0xFF314158))),
                      Text(' (${offer.reviews} avis)',
                        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: Color(0xFF9CA3AF))),
                    ]),
                  ],
                ),
              ),
              if (offer.artisanId != null)
                GestureDetector(
                  onTap: () => context.push('/artisans/profile/${offer.artisanId}',
                    extra: {'name': offer.artisanName, 'role': offer.artisanSpecialty}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF393C40), borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.person_outline_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Profil', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: Colors.white)),
                    ]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceBar(offer),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 42,
            child: ElevatedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text('Contacter l\'artisan',
                style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
            ),
          ),
        ],
      ),
    );
  }

  // ── Client card (artisan viewing) ──────────────────────────────────────
  Widget _buildClientCard(ServiceRequest req) {
    final offer = _acceptedOffer;
    final name = req.clientName ?? 'Client';
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(icon: Icons.person_outline_rounded, label: 'Client'),
          const SizedBox(height: 14),
          Row(
            children: [
              _PersonAvatar(name: name, avatarUrl: req.clientAvatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                      style: const TextStyle(
                        fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                        fontSize: 15, letterSpacing: -0.2, color: Color(0xFF191C24))),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF9CA3AF), size: 12),
                      const SizedBox(width: 4),
                      Text(_fmtDate(req.createdAt),
                        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Color(0xFF62748E))),
                    ]),
                  ],
                ),
              ),
              if (req.clientId != null)
                GestureDetector(
                  onTap: () => context.push('/artisan/client-profile/${req.clientId}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF393C40), borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.person_outline_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Profil', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: Colors.white)),
                    ]),
                  ),
                ),
            ],
          ),
          if (offer != null) ...[
            const SizedBox(height: 14),
            _buildPriceBar(offer),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 42,
            child: ElevatedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text('Contactez',
                style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared price/duration bar ──────────────────────────────────────────
  Widget _buildPriceBar(Offer offer) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFE8), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prix accepté',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: Color(0xFF62748E))),
                const SizedBox(height: 2),
                Text('${offer.price.toStringAsFixed(0)} DH',
                  style: const TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                    fontSize: 22, letterSpacing: 0.2, color: AppColors.primary)),
              ],
            ),
          ),
          if (offer.duration > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Durée estimée',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: Color(0xFF62748E))),
                const SizedBox(height: 2),
                Text(_fmtDuration(offer.duration),
                  style: const TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                    fontSize: 15, color: Color(0xFF314158))),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (status) {
      'completed'   => ('Terminé', const Color(0xFF16A34A)),
      'in_progress' => ('En cours', const Color(0xFF2B7FFF)),
      'open'        => ('En attente', const Color(0xFFF59E0B)),
      'cancelled'   => ('Annulé', const Color(0xFFEF4444)),
      _             => ('Inconnu', const Color(0xFF9CA3AF)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withValues(alpha: 0.5)),
      ),
      child: Text(label,
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: bg,
        )),
    );
  }
}

// ── Section card ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: const [
        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: child,
  );
}

// ── Card header ────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _CardHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 16),
      ),
      const SizedBox(width: 10),
      Text(label,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Color(0xFF191C24),
        )),
    ],
  );
}

// ── Collapsible card ───────────────────────────────────────────────────────────

class _CollapsibleCard extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final bool         expanded;
  final VoidCallback onToggle;
  final Widget       child;

  const _CollapsibleCard({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: const [
        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF191C24),
                    )),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF62748E), size: 22),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: child,
          ),
      ],
    ),
  );
}

// ── Info row ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
            style: const TextStyle(
              fontFamily: 'Public Sans', fontSize: 13,
              color: Color(0xFF9CA3AF))),
        ),
        Expanded(
          flex: 3,
          child: Text(value,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF191C24),
            )),
        ),
      ],
    ),
  );
}

// ── History item ───────────────────────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  final DateTime date;
  final String   label;
  final Color    color;
  const _HistoryItem({required this.date, required this.label, required this.color});

  String _fmt(DateTime d) {
    const months = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
            style: const TextStyle(
              fontFamily: 'Public Sans', fontSize: 13,
              color: Color(0xFF191C24))),
        ),
        Text(_fmt(date),
          style: const TextStyle(
            fontFamily: 'Public Sans', fontSize: 11,
            color: Color(0xFF9CA3AF))),
      ],
    ),
  );
}

// ── Section title ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
    style: const TextStyle(
      fontFamily: 'Public Sans',
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Color(0xFF191C24),
    ));
}

// ── Action button ──────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final bool         outlined;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: outlined
        ? OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              foregroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
          ),
  );
}

// ── Artisan avatar ─────────────────────────────────────────────────────────────

class _PersonAvatar extends StatelessWidget {
  final String  name;
  final String? avatarUrl;
  const _PersonAvatar({required this.name, this.avatarUrl});

  Color _color() {
    const p = [
      Color(0xFFFC5A15), Color(0xFF3B82F6), Color(0xFF8B5CF6),
      Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444),
    ];
    if (name.isEmpty) return p[0];
    int h = 0;
    for (final c in name.codeUnits) { h = (h * 31 + c) % p.length; }
    return p[h];
  }

  String _initials() {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 54, height: 54,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 3)),
      ],
    ),
    child: ClipOval(
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? Image.network(avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback())
          : _fallback(),
    ),
  );

  Widget _fallback() => Container(
    color: _color(),
    child: Center(
      child: Text(_initials(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        )),
    ),
  );
}

// ── Circle button ──────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

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
