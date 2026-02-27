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
    extends State<ArtisanPublicProfileScreen>
    with SingleTickerProviderStateMixin {
  final _repo     = ArtisanRepository();
  final _convRepo = ConversationRepository();

  late final TabController _tabCtrl;

  bool           _isLoading  = true;
  String?        _error;
  PublicArtisan? _artisan;
  bool           _messaging  = false;

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    if (widget.artisanId != null) { _load(); }
    else { setState(() => _isLoading = false); }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _repo.getArtisan(widget.artisanId!);
      if (mounted) setState(() { _artisan = data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ArtisanRepository.errorMessage(e);
          _isLoading = false;
        });
      }
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
  List<String> get _skills   => _artisan?.skills          ?? [];
  List<String> get _photos   => _artisan?.portfolioPhotos ?? [];
  bool   get _verified => _artisan?.isVerified     ?? false;
  int    get _years    => _artisan?.yearsExperience ?? 0;
  int    get _services => _artisan?.completedServices ?? 0;

  // ── open chat ──────────────────────────────────────────────────────────────
  Future<void> _openChat() async {
    if (widget.artisanId == null) return;
    setState(() => _messaging = true);
    try {
      final conv = await _convRepo.getOrCreate(artisanId: widget.artisanId);
      if (mounted) {
        context.push('/client/chat/${conv.id}', extra: {
          'name':  _name,
          'role':  _role,
          'avatar': _avatar,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildPhotoHeader(context)),
          SliverToBoxAdapter(child: _buildIdentity()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabCtrl: _tabCtrl),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 1000,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildAboutTab(),
                  _buildPortfolioTab(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── Photo header ───────────────────────────────────────────────────────────
  Widget _buildPhotoHeader(BuildContext context) {
    return Stack(
      children: [
        // Cover / avatar area
        if (_avatar != null && _avatar!.isNotEmpty)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Image.network(
              _avatar!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderCover(),
            ),
          )
        else
          _placeholderCover(),

        // Gradient overlay at bottom
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),

        // Top buttons (back + report)
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showReportSheet(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert_rounded,
                        color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Name overlay at bottom
        Positioned(
          bottom: 16, left: 20, right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(_name,
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, fontSize: 22,
                          color: Colors.white)),
                  ),
                  if (_verified) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF155DFC), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 11),
                    ),
                  ],
                ],
              ),
              Text(
                _city.isNotEmpty ? '$_role · $_city' : _role,
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholderCover() => Container(
    height: 260,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF393C40), Color(0xFF62748E)],
      ),
    ),
    child: Center(
      child: Icon(Icons.person_rounded,
        size: 100, color: Colors.white.withValues(alpha: 0.4)),
    ),
  );

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _buildIdentity() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(
          child: _ActionBtn(
            icon:   _messaging ? Icons.hourglass_top_rounded
                               : Icons.chat_bubble_outline_rounded,
            label:  _messaging ? 'Chargement…' : 'Message',
            filled: false,
            onTap:  _messaging ? null : _openChat,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBtn(
            icon: Icons.phone_outlined,
            label: 'Appel',
            filled: true,
            onTap: () {},
          ),
        ),
      ]),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            _StatItem(
              value: _rating > 0
                  ? '${_rating.toStringAsFixed(1)} ($_reviews)'
                  : '—',
              label: 'Note',
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFF8904),
            ),
            _divider(),
            _StatItem(
              value: _years > 0 ? '$_years ans' : '—',
              label: 'Expérience',
              icon: Icons.work_outline_rounded,
              iconColor: AppColors.primary,
            ),
            _divider(),
            _StatItem(
              value: '$_services',
              label: 'Services',
              icon: Icons.handyman_outlined,
              iconColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 36, color: const Color(0xFFE5E7EB));

  // ── About tab ──────────────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          const Text('À propos',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                fontSize: 16, color: Color(0xFF314158))),
          const SizedBox(height: 8),
          Text(
            _bio?.isNotEmpty == true
                ? _bio!
                : 'Aucune description disponible.',
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13.5,
                color: Color(0xFF45556C), height: 1.6),
          ),
          const SizedBox(height: 20),

          // Skills
          if (_skills.isNotEmpty) ...[
            const Text('Compétences',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  fontSize: 16, color: Color(0xFF314158))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _skills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(skill,
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                      fontWeight: FontWeight.w600, color: AppColors.primary)),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Secure payment badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFF86EFAC)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(children: [
              Icon(Icons.verified_user_outlined,
                color: Color(0xFF16A34A), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paiement sécurisé',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, fontSize: 13,
                          color: Color(0xFF16A34A))),
                    SizedBox(height: 2),
                    Text(
                      'Votre paiement est protégé. Fonds libérés uniquement après validation des travaux.',
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5,
                          color: Color(0xFF166534), height: 1.4)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Reviews placeholder
          const Text('Avis clients',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                fontSize: 16, color: Color(0xFF314158))),
          const SizedBox(height: 10),
          if (_reviews == 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Aucun avis pour le moment.',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFF9CA3AF))),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                border: Border.all(color: const Color(0xFFFDBA74)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFF8904), size: 22),
                const SizedBox(width: 8),
                Text('$_rating sur 5  ·  $_reviews avis',
                  style: const TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w600, fontSize: 14,
                      color: Color(0xFF314158))),
              ]),
            ),
        ],
      ),
    );
  }

  // ── Portfolio tab ──────────────────────────────────────────────────────────
  Widget _buildPortfolioTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Galerie de projets',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                fontSize: 16, color: Color(0xFF314158))),
          const SizedBox(height: 12),

          if (_photos.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(children: [
                  Icon(Icons.photo_library_outlined,
                    size: 40, color: Color(0xFFD1D5DC)),
                  SizedBox(height: 10),
                  Text('Aucune photo dans le portfolio.',
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                        color: Color(0xFF9CA3AF))),
                ]),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: _photos.length,
              itemBuilder: (_, i) {
                final url = _photos[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: url.isNotEmpty
                      ? Image.network(url, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _photoPlaceholder(i))
                      : _photoPlaceholder(i),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(int i) {
    const colors = [
      Color(0xFFE5E7EB), Color(0xFFDDD6FE), Color(0xFFBBF7D0),
      Color(0xFFFED7AA), Color(0xFFBFDBFE), Color(0xFFFECACA),
    ];
    return Container(
      decoration: BoxDecoration(
        color: colors[i % colors.length],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(Icons.image_outlined,
          size: 36, color: Colors.white.withValues(alpha: 0.7)),
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

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  const _ActionBtn({
    required this.icon, required this.label,
    required this.filled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary
            : onTap == null ? const Color(0xFFF3F4F6) : Colors.white,
        border: Border.all(
          color: filled ? AppColors.primary : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
            color: filled ? Colors.white : const Color(0xFF314158), size: 18),
          const SizedBox(width: 8),
          Text(label,
            style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14,
              color: filled ? Colors.white : const Color(0xFF314158),
            )),
        ],
      ),
    ),
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
              fontSize: 13, color: Color(0xFF314158))),
        Text(label,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11,
              color: Color(0xFF62748E))),
      ],
    ),
  );
}

// ── Tab bar delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabCtrl;
  const _TabBarDelegate({required this.tabCtrl});

  @override double get minExtent => 48;
  @override double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabCtrl,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF62748E),
        labelStyle: const TextStyle(fontFamily: 'Poppins',
            fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14),
        tabs: const [
          Tab(text: 'À propos'),
          Tab(text: 'Portfolio'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabCtrl != tabCtrl;
}

// ── Report bottom sheet ───────────────────────────────────────────────────────

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
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signaler un problème',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700, fontSize: 16,
                      color: Color(0xFF314158))),
                Text('Aidez-nous à maintenir la qualité',
                  style: TextStyle(fontFamily: 'Public Sans',
                      fontSize: 12, color: Color(0xFF62748E))),
              ],
            ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(opt,
                        style: TextStyle(
                          fontFamily: 'Public Sans', fontSize: 13,
                          fontWeight: _selected == opt
                              ? FontWeight.w600 : FontWeight.w400,
                          color: _selected == opt
                              ? AppColors.primary : const Color(0xFF314158),
                        )),
                    ),
                    if (_selected == opt)
                      const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 18),
                  ],
                ),
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
