import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/artisan_repository.dart';
import '../../../data/repositories/conversation_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ArtisanPublicProfileScreen extends StatefulWidget {
  final int? artisanId;
  final String artisanName;
  final String artisanRole;

  const ArtisanPublicProfileScreen({
    super.key,
    this.artisanId,
    this.artisanName = 'Artisan',
    this.artisanRole  = 'Artisan indépendant',
  });

  @override
  State<ArtisanPublicProfileScreen> createState() =>
      _ArtisanPublicProfileScreenState();
}

class _ArtisanPublicProfileScreenState
    extends State<ArtisanPublicProfileScreen> {
  final _repo     = ArtisanRepository();
  final _convRepo = ConversationRepository();

  bool           _isLoading = true;
  String?        _error;
  PublicArtisan? _artisan;
  bool           _messaging = false;
  bool           _statsExpanded   = false;
  bool           _ratingExpanded  = false;
  bool           _paymentExpanded = false;

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.artisanId != null) { _load(); }
    else { setState(() => _isLoading = false); }
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _repo.getArtisan(widget.artisanId!);
      if (mounted) { setState(() { _artisan = data; _isLoading = false; }); }
    } catch (e) {
      if (mounted) { setState(() {
        _error = ArtisanRepository.errorMessage(e);
        _isLoading = false;
      }); }
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  String get _name     => _artisan?.name     ?? widget.artisanName;
  String get _role     => _artisan?.specialty ?? widget.artisanRole;
  String get _city     => _artisan?.city      ?? '';
  double get _rating   => _artisan?.rating    ?? 0;
  int    get _reviews  => _artisan?.reviews   ?? 0;
  String? get _avatar  => _artisan?.avatarUrl;
  String? get _bio     => _artisan?.bio;
  List<String> get _skills  => _artisan?.skills          ?? [];
  List<String> get _photos  => _artisan?.portfolioPhotos ?? [];
  bool   get _verified      => _artisan?.isVerified      ?? false;
  int    get _years         => _artisan?.yearsExperience ?? 0;
  int    get _services      => _artisan?.completedServices ?? 0;
  int?   get _responseRate  => _artisan?.responseRate;
  int?   get _memberSince   => _artisan?.memberSince;
  Map<int, int> get _breakdown => _artisan?.ratingBreakdown ?? {};

  // ── open chat ──────────────────────────────────────────────────────────────
  Future<void> _openChat() async {
    if (widget.artisanId == null) return;
    setState(() => _messaging = true);
    try {
      final conv = await _convRepo.getOrCreate(artisanId: widget.artisanId);
      if (mounted) {
        context.push('/client/chat/${conv.id}', extra: {
          'name':      _name,
          'role':      _role,
          'avatar':    _avatar,
          'profileId': conv.otherProfileId,
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible d\'ouvrir la conversation.',
            style: TextStyle(fontFamily: 'Public Sans')),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _messaging = false);
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: const BackButton(color: Color(0xFF314158))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
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
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                // Action buttons  (overlapping area already provided by header height)
                _buildActionButtons(),
                const SizedBox(height: 20),
                // Content sections
                _buildAboutSection(),
                _buildSkillsSection(),
                _buildRatingSection(),
                _buildStatsAccordion(),
                _buildGallery(),
                _buildPaymentAccordion(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final coverPhoto = _photos.isNotEmpty ? _photos[0] : null;

    return SizedBox(
      height: 286,
      child: Stack(
        children: [
          // Cover photo / gradient background
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:  Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: SizedBox(
              height: 241,
              width: double.infinity,
              child: coverPhoto != null && coverPhoto.isNotEmpty
                  ? Image.network(coverPhoto, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder())
                  : (_avatar != null && _avatar!.isNotEmpty
                      ? Image.network(_avatar!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _coverPlaceholder())
                      : _coverPlaceholder()),
            ),
          ),

          // Dark gradient overlay on cover
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:  Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Container(
              height: 241,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Back + 3-dot buttons
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleBtn(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                    ),
                    _CircleBtn(
                      onTap: () => _showReportSheet(context),
                      child: const Icon(Icons.more_vert_rounded,
                        color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Avatar + name/city overlaid at bottom-left of cover
          Positioned(
            top: 150, left: 20, right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar with online dot
                Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: _avatar != null && _avatar!.isNotEmpty
                            ? Image.network(_avatar!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarPlaceholder())
                            : _avatarPlaceholder(),
                      ),
                    ),
                    Positioned(
                      bottom: 4, right: 4,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Name + specialty + verified + city
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(_name,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.white,
                            )),
                        ),
                        if (_verified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Vérifié',
                              style: TextStyle(fontFamily: 'Public Sans',
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 2),
                      Text(_role,
                        style: TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85))),
                      if (_city.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                            color: Colors.white70, size: 12),
                          const SizedBox(width: 2),
                          Text(_city,
                            style: const TextStyle(fontFamily: 'Public Sans',
                                fontSize: 11, color: Colors.white70)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF393C40), Color(0xFF62748E)],
      ),
    ),
  );

  Widget _avatarPlaceholder() => Container(
    color: const Color(0xFFE5E7EB),
    child: const Icon(Icons.person_rounded, size: 40, color: Color(0xFF9CA3AF)),
  );

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        // Message
        Expanded(
          child: GestureDetector(
            onTap: _messaging ? null : _openChat,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(33),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _messaging ? Icons.hourglass_top_rounded
                               : Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(_messaging ? 'Chargement…' : 'Message',
                    style: const TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600, fontSize: 14,
                        color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Appel
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(33),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Appel',
                    style: TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600, fontSize: 14,
                        color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── À propos section ───────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    final bio = _bio?.isNotEmpty == true
        ? _bio!
        : 'Aucune description disponible.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle('À propos'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(bio,
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13.5,
                color: Color(0xFF45556C), height: 1.6)),
        ),
      ]),
    );
  }

  // ── Compétences section ────────────────────────────────────────────────────
  Widget _buildSkillsSection() {
    if (_skills.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle('Compétences'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _skills.where((s) => s.isNotEmpty).map((skill) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(skill,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.primary)),
            )
          ).toList(),
        ),
      ]),
    );
  }

  // ── Rating section ─────────────────────────────────────────────────────────
  Widget _buildRatingSection() {
    // Build a custom title row with star + score + count inline
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: _Accordion(
        title: '${_rating > 0 ? _rating.toStringAsFixed(1) : "—"}  ·  $_reviews avis',
        titleIcon: Icons.star_rounded,
        titleIconColor: const Color(0xFFFF8904),
        expanded: _ratingExpanded,
        onToggle: () => setState(() => _ratingExpanded = !_ratingExpanded),
        child: Column(
          children: [
            for (int star = 5; star >= 1; star--)
              _StarBar(star: star, count: _breakdown[star] ?? 0, total: _reviews),
          ],
        ),
      ),
    );
  }

  // ── Statistiques accordion ─────────────────────────────────────────────────
  Widget _buildStatsAccordion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: _Accordion(
        title: 'Statistiques',
        expanded: _statsExpanded,
        onToggle: () => setState(() => _statsExpanded = !_statsExpanded),
        child: Column(children: [
          _StatRow(label: 'Taux de réponse',
            value: _responseRate != null ? '$_responseRate%' : '—'),
          _StatRow(label: 'Projets complétés', value: '$_services'),
          _StatRow(label: 'Années d\'expérience',
            value: _years > 0 ? '$_years ans' : '—'),
          _StatRow(label: 'Membre depuis',
            value: _memberSince != null ? '$_memberSince' : '—',
            isLast: true),
        ]),
      ),
    );
  }

  // ── Galerie de projets ─────────────────────────────────────────────────────
  Widget _buildGallery() {
    if (_photos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle('Galerie de projets'),
        const SizedBox(height: 10),
        // First photo large
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _photos[0].isNotEmpty
                ? Image.network(_photos[0], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _galPlaceholder(0))
                : _galPlaceholder(0),
          ),
        ),
        // Remaining thumbnails (up to 3)
        if (_photos.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              (_photos.length - 1).clamp(0, 3),
              (i) {
                final url = _photos[i + 1];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: url.isNotEmpty
                            ? Image.network(url, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _galPlaceholder(i + 1))
                            : _galPlaceholder(i + 1),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ]),
    );
  }

  Widget _galPlaceholder(int i) {
    const colors = [
      Color(0xFFE5E7EB), Color(0xFFDDD6FE), Color(0xFFBBF7D0),
      Color(0xFFFED7AA),
    ];
    return Container(
      color: colors[i % colors.length],
      child: const Center(child: Icon(Icons.image_outlined, color: Colors.white54)),
    );
  }

  // ── Paiement sécurisé accordion ────────────────────────────────────────────
  Widget _buildPaymentAccordion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: _Accordion(
        title: 'Paiement sécurisé',
        titleIcon: Icons.verified_user_outlined,
        titleIconColor: const Color(0xFF22C55E),
        expanded: _paymentExpanded,
        onToggle: () => setState(() => _paymentExpanded = !_paymentExpanded),
        child: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Votre paiement est protégé. Les fonds ne sont libérés à l\'artisan qu\'après validation des travaux par le client.',
            style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                color: Color(0xFF45556C), height: 1.5)),
        ),
      ),
    );
  }

  // ── Report bottom sheet ────────────────────────────────────────────────────
  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ReportSheet(),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
        fontSize: 15, color: Color(0xFF314158)));
}

class _StarBar extends StatelessWidget {
  final int star;
  final int count;
  final int total;
  const _StarBar({required this.star, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text('$star', style: const TextStyle(fontFamily: 'Public Sans',
            fontSize: 12, color: Color(0xFF62748E))),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, color: Color(0xFFFF8904), size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.toDouble(),
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF8904)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text('$count',
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11,
                color: Color(0xFF62748E))),
        ),
      ]),
    );
  }
}

class _Accordion extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Color? titleIconColor;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  const _Accordion({
    required this.title, this.titleIcon, this.titleIconColor,
    required this.expanded, required this.onToggle, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 18,
                    color: titleIconColor ?? AppColors.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(title,
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600, fontSize: 14,
                      color: Color(0xFF314158))),
              ),
              Icon(expanded ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF62748E), size: 22),
            ]),
          ),
        ),
        if (expanded) ...[
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _StatRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Public Sans',
              fontSize: 13, color: Color(0xFF62748E))),
          Text(value, style: const TextStyle(fontFamily: 'Public Sans',
              fontWeight: FontWeight.w600, fontSize: 13,
              color: Color(0xFF314158))),
        ],
      ),
    );
  }
}

// ── Report bottom sheet ────────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();
  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selected;

  static const _options = [
    'Comportement inapproprié',
    'Informations incorrectes',
    'Faux profil',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFD1D5DC),
                  borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Signaler un problème',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    fontSize: 16, color: Color(0xFF314158))),
              Text('Aidez-nous à maintenir la qualité',
                style: TextStyle(fontFamily: 'Public Sans',
                    fontSize: 12, color: Color(0xFF62748E))),
            ]),
          ]),
          const SizedBox(height: 20),

          const Text('Raison du signalement',
            style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                fontSize: 13, color: Color(0xFF314158))),
          const SizedBox(height: 10),

          ..._options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selected = opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _selected == opt
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : const Color(0xFFF9FAFB),
                  border: Border.all(
                    color: _selected == opt
                        ? AppColors.primary : const Color(0xFFE5E7EB),
                    width: _selected == opt ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(opt,
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                        fontWeight: _selected == opt
                            ? FontWeight.w600 : FontWeight.w400,
                        color: _selected == opt
                            ? AppColors.primary : const Color(0xFF314158))),
                  ),
                  if (_selected == opt)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 18),
                ]),
              ),
            ),
          )),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Signalement envoyé. Merci !',
                          style: TextStyle(fontFamily: 'Public Sans')),
                        backgroundColor: const Color(0xFF16A34A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      ));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                disabledBackgroundColor: const Color(0xFFD1D5DC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Envoyer le signalement',
                style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
