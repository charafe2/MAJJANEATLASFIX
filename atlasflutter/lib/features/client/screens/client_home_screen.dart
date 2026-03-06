import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/service_request_repository.dart';
import '../../../../data/repositories/artisan_repository.dart';
import '../../../../data/repositories/conversation_repository.dart';

// ── FAQ (static) ──────────────────────────────────────────────────────────────
const _kFaq = [
  'Comment fonctionne AtlasFix ?',
  'Comment puis-je contacter un artisan ?',
  'Mes paiements sont-ils sécurisés ?',
  'Puis-je annuler une demande ?',
];
const _kFaqAnswer =
    'AtlasFix met en relation clients et artisans qualifiés. Publiez votre demande, recevez des offres et choisissez l\'artisan qui vous convient. Votre paiement est sécurisé et libéré uniquement après validation des travaux.';

// ── Icon mapping ──────────────────────────────────────────────────────────────
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
  if (n.contains('restaur'))                         return Icons.restaurant_outlined;
  if (n.contains('construct'))                       return Icons.construction_outlined;
  if (n.contains('climatis') || n.contains('clim')) return Icons.ac_unit_outlined;
  return Icons.build_outlined;
}

// ─────────────────────────────────────────────────────────────────────────────
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});
  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _catRepo     = ServiceRequestRepository();
  final _artisanRepo = ArtisanRepository();

  int _expandedFaq = 1;

  List<ServiceCategory> _categories    = [];
  List<PublicArtisan>   _artisans      = [];
  bool _catsLoading     = true;
  bool _artisansLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadArtisans();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _catRepo.getCategories();
      if (mounted) setState(() { _categories = data; _catsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _catsLoading = false);
    }
  }

  Future<void> _loadArtisans() async {
    try {
      final data = await _artisanRepo.getArtisans();
      if (mounted) setState(() { _artisans = data; _artisansLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _artisansLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page background: white with soft orange gradient from bottom
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Page background gradient (bottom-to-top orange fade)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.6238],
                  colors: [
                    Color(0x4DFF8C5B), // rgba(255,140,91,0.3)
                    Color(0x00FF8C5B), // transparent
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // ── Orange header ──────────────────────────────────────
              _HomeHeader(),

              // ── Scrollable body ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CSS: Frame 1597881095 top:230px (25px below header end ≈ 22px gap)
                      const SizedBox(height: 22),

                      // Categories section — total 110px: header 24px + gap 16px + scroll 70px
                      // CSS: header Frame left:30px, width:336px
                      _SectionHeader(title: 'Catégories de services', onMore: () {}),
                      // gap = top(scroll 40) - height(header 24) = 16px
                      const SizedBox(height: 16),
                      _catsLoading
                          ? const SizedBox(
                              height: 80,
                              child: Center(child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2)))
                          : _ServiceCategories(categories: _categories),

                      const SizedBox(height: 28),

                      // Annonce d'Aujourd'hui
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title — Public Sans 700 18px #191C24 letter-spacing -0.306545px
                            Text(
                              "Annonce d'Aujourd'hui",
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.306545,
                                color: Color(0xFF191C24),
                              ),
                            ),
                            SizedBox(height: 18),
                            _PromoCard(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Nos artisans les mieux notés
                      const _SectionHeader(
                        title: 'Nos artisans les mieux notés',
                        onMore: null,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 343,
                        child: _artisansLoading
                            ? const Center(child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2))
                            : _artisans.isEmpty
                                ? const Center(
                                    child: Text('Aucun artisan disponible.',
                                      style: TextStyle(fontFamily: 'Public Sans',
                                          fontSize: 13, color: Color(0xFF9CA3AF))))
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    // left: 30.07px from CSS
                                    padding: const EdgeInsets.only(left: 30, right: 8),
                                    itemCount: _artisans.length,
                                    // gap: 18px from CSS
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 18),
                                    itemBuilder: (_, i) =>
                                        _ArtisanCard(artisan: _artisans[i]),
                                  ),
                      ),

                      const SizedBox(height: 28),

                      // Questions fréquentes
                      Padding(
                        // left: 30px from CSS
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title — Public Sans 700 18px #191C24 letter-spacing -0.273557px
                            const Text(
                              'Questions fréquentes',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.273557,
                                color: Color(0xFF191C24),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(_kFaq.length, (i) => _FaqItem(
                              question: _kFaq[i],
                              answer:   _kFaqAnswer,
                              isOpen:   _expandedFaq == i,
                              onTap: () => setState(() =>
                                  _expandedFaq = _expandedFaq == i ? -1 : i),
                            )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom nav (floating pill) ────────────────────────────
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: _BottomNavBar(activeIndex: 0)),
          ),
        ],
      ),
    );
  }
}

// ── Orange header ─────────────────────────────────────────────────────────────
// CSS: width 393px, height 205px, bg #FC5A15, border-radius: 0 0 20 20
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Full screen width, fixed 205px height
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFC5A15),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          // CSS: total 205px. SafeArea top (≈47px on iPhone) consumed above.
          // Remaining content inside safe area ≈ 158px, padded 20px bottom → 138px.
          height: 158,
          child: Padding(
            // horizontal: 29px = (393-335)/2
            padding: const EdgeInsets.fromLTRB(29, 0, 29, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Row 1: logo + icon buttons ─────────────────────
                // CSS: Frame 1597881083, top:69px from screen ≈ 22px from SafeArea
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    _WhiteLogo(),
                    // Icon buttons — CSS: gap:15px
                    Row(children: [
                      _HeaderIconBtn(
                        icon: Icons.calendar_today_outlined,
                        onTap: () => context.push('/client/agenda'),
                      ),
                      const SizedBox(width: 15),
                      const _HeaderIconBtn(
                        icon: Icons.notifications_none_rounded,
                      ),
                    ]),
                  ],
                ),

                // ── Row 2: search pills ────────────────────────────
                // CSS: top:130px from screen ≈ bottom of header area
                const _SearchRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// AtlasFix logo — forced white so it shows on the orange header
class _WhiteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColorFiltered(
    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    child: Image.asset(
      'assets/images/AtlasFix.png',
      height: 36,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  );
}

// Header icon buttons
// CSS: Frame 1597881071 — 40x40, bg #FFFFFF, border-radius 125px, icon #393C40
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _HeaderIconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(125),
      ),
      child: Icon(icon, color: const Color(0xFF393C40), size: 20),
    ),
  );
}

// Search row — two pills side by side, total width 335px
// CSS: left pill 216px (translucent), right pill 112px (solid), gap 7px
class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      // Pill 1 — CSS: 216x48, bg rgba(255,255,255,0.8), radius 100px
      _SearchPill(
        hint: 'Quelle service recherc…',
        width: 216,
        translucent: true,
        icon: Icons.manage_search,
      ),
      SizedBox(width: 7), // gap = 335 - 216 - 112
      // Pill 2 — CSS: 112x48, bg #FFFFFF, radius 100px
      _SearchPill(
        hint: 'Ville…',
        width: 112,
        translucent: false,
        icon: Icons.keyboard_arrow_down_rounded,
      ),
    ],
  );
}

// Search pill
// CSS: h:48, padding: 12px 7px 12px 16px, radius 100px
// Inner dark button: 36x36, bg #393C40, shape circle
class _SearchPill extends StatelessWidget {
  final String hint;
  final double width;
  final bool translucent;
  final IconData icon;
  const _SearchPill({
    required this.hint,
    required this.width,
    required this.translucent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 48,
    // CSS: padding: 12 7 12 16
    padding: const EdgeInsets.fromLTRB(16, 12, 7, 12),
    decoration: BoxDecoration(
      color: translucent
          ? Colors.white.withValues(alpha: 0.8) // rgba(255,255,255,0.8)
          : Colors.white,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(children: [
      // Hint text — CSS: Public Sans 400 14px #494949 ls:-0.01em
      Expanded(
        child: Text(
          hint,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF494949),
            letterSpacing: -0.14,
          ),
        ),
      ),
      const SizedBox(width: 4),
      // Dark button — CSS: 36x36, bg #393C40, border-radius 1000px
      Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF393C40),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    ]),
  );
}

// ── Section header ────────────────────────────────────────────────────────────
// CSS: Frame 1597881092 — left:30px, width:336px, height:24px
// Title: Public Sans 700 18px #191C24 ls:-0.273557px
// "Voir plus": Public Sans 500 10px #191C24
// Arrow circle: 24x24 bg:#393C40 radius:27.14px, white chevron 5x10
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  final EdgeInsetsGeometry padding;

  const _SectionHeader({
    required this.title,
    required this.onMore,
    this.padding = const EdgeInsets.symmetric(horizontal: 30),
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title — Public Sans 700 18px #191C24 letter-spacing:-0.273557px
        Text(title,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.273557,
            color: Color(0xFF191C24),
          ),
        ),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Row(
              children: [
                // "Voir plus" — Public Sans 500 10px #191C24
                const Text('Voir plus',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    letterSpacing: -0.273557,
                    color: Color(0xFF191C24),
                  ),
                ),
                const SizedBox(width: 2),
                // Arrow circle — CSS: 24x24, bg #393C40, radius 27.14px
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF393C40),
                    borderRadius: BorderRadius.circular(27.1429),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    ),
  );
}

// ── Service categories ────────────────────────────────────────────────────────
// CSS: Frame 1597881087 — 393x70px, overflow-x scroll
// CSS: Frame 1597881085 — row, gap:26px, left:29px
// Each item (Frame 554 etc.): Column gap:2px, circle 48x48 + label

// Color per category name — from Figma CSS
Color _catCircleColor(String name) {
  final n = name.toLowerCase();
  if (n.contains('répar') || n.contains('repar') || n.contains('général')) {
    return const Color(0xFFFB2C36);
  }
  if (n.contains('plomb')) { return const Color(0xFF2B7FFF); }
  if (n.contains('élec') || n.contains('elec')) { return const Color(0xFFF0B100); }
  if (n.contains('peint')) { return const Color(0xFFAD46FF); }
  if (n.contains('électro') || n.contains('electro') || n.contains('ménager')) {
    return const Color(0xFFFF2056);
  }
  if (n.contains('nettoy')) { return const Color(0xFF00B8DB); }
  if (n.contains('déménag') || n.contains('demenag')) { return const Color(0xFF615FFF); }
  if (n.contains('chauff') || n.contains('climati') || n.contains('ventil')) {
    return const Color(0xFFF54900);
  }
  return const Color(0xFF393C40);
}

class _ServiceCategories extends StatelessWidget {
  final List<ServiceCategory> categories;
  const _ServiceCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox(height: 70);
    return SizedBox(
      height: 80, // 48 circle + 2 gap + 2×14 label = 78px
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // CSS: items start at left:29px
        padding: const EdgeInsets.only(left: 29, right: 16),
        itemCount: categories.length,
        // CSS: gap:26px between items
        separatorBuilder: (_, __) => const SizedBox(width: 26),
        itemBuilder: (_, i) => _CategoryChip(cat: categories[i]),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ServiceCategory cat;
  const _CategoryChip({required this.cat});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/client/service-types', extra: {
      'categoryId': cat.id,
      'category':   cat.name,
    }),
    // CSS: Frame 554 — Column, gap:2px, height:70px
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circle — CSS: 48x48, border-radius:26px, colored bg
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _catCircleColor(cat.name),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(
            _catIcon(cat.name),
            color: Colors.white,
            // CSS: icon ~24x24 inside 48x48 circle
            size: 24,
          ),
        ),
        // CSS: gap:2px
        const SizedBox(height: 2),
        // Label — CSS: Inter 400 12px #314158 ls:-0.150391px, centered, max 2 lines
        SizedBox(
          width: 61,
          child: Text(
            cat.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.150391,
              color: Color(0xFF314158),
              height: 1.17, // line-height: 14px / 12px
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Promo card ────────────────────────────────────────────────────────────────
// Two stacked orange cards creating a depth/shadow effect.
// Character image overflows the top of the card.
class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    const Color orange     = Color(0xFFFC5A15);
    const double radius    = 20.0;
    const double cardH     = 148.0;
    const double imgOver   = 24.0;  // character overflows above card top
    const double backShift = 7.0;   // back card down/right offset

    return SizedBox(
      width: double.infinity,
      height: cardH + imgOver,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Back card — shifted 6px right+down, contained within parent ─
          Positioned(
            top:    imgOver + backShift,
            left:   6,
            right:  0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color:        orange,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),

          // ── Front card ──────────────────────────────────────────────────
          Positioned(
            top:    imgOver,
            left:   0,
            right:  0,
            bottom: backShift,
            child: Container(
              decoration: BoxDecoration(
                color:        orange,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: const [
                  BoxShadow(
                    color:      Color(0x400B1324),
                    blurRadius: 12,
                    offset:     Offset(0, 4),
                  ),
                ],
              ),
              // Right padding leaves room for the overflowing character
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 130, 16),
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  mainAxisAlignment:   MainAxisAlignment.spaceBetween,
                  children: [
                    // "Populaire" badge — white pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Populaire',
                        style: TextStyle(
                          fontFamily:    'Public Sans',
                          fontSize:      10,
                          fontWeight:    FontWeight.w400,
                          letterSpacing: -0.126,
                          color:         Color(0xFF2B2B2B),
                        ),
                      ),
                    ),

                    // Title + CTA button (bottom-left area)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lorem ipsum dolor sit\namet, consectetur',
                          style: TextStyle(
                            fontFamily:    'Public Sans',
                            fontWeight:    FontWeight.w700,
                            fontSize:      18,
                            letterSpacing: -0.306545,
                            color:         Colors.white,
                            height:        1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // White pill button with dark text
                        GestureDetector(
                          onTap: () => context.push('/client/nouvelle-demande'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:        Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text('Demander maintenant',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w500,
                                fontSize:   12,
                                color:      Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Character image — right side, overflowing card top ──────────
          Positioned(
            right:  0,
            top:    0,
            bottom: backShift,
            child: SizedBox(
              width: 128,
              child: Image.asset(
                'assets/images/plumber.png',
                fit:           BoxFit.contain,
                alignment:     Alignment.bottomRight,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          // ── Corner screw dots ───────────────────────────────────────────
          const Positioned(left:  9, bottom: backShift + 8,         child: _ScrewDot()),
          const Positioned(right: 9, bottom: backShift + 8,         child: _ScrewDot()),
          const Positioned(right: 9, top:    imgOver   + 8,         child: _ScrewDot()),
        ],
      ),
    );
  }
}

class _ScrewDot extends StatelessWidget {
  const _ScrewDot();

  @override
  Widget build(BuildContext context) => Container(
    width:  6.13,
    height: 6.13,
    decoration: const BoxDecoration(
      color: Color(0xFFFC5A15),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Container(
        width:  3.5,
        height: 3.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

// ── Artisan card ──────────────────────────────────────────────────────────────
// CSS: 210x343, bg #FFFFFF, border 0.714744px solid #F3F4F6, radius 12px
// Shadow: 0px 2.86px 4.29px -0.71px rgba(0,0,0,0.1), 0px 1.43px 2.86px -1.43px rgba(0,0,0,0.1)
class _ArtisanCard extends StatefulWidget {
  final PublicArtisan artisan;
  const _ArtisanCard({required this.artisan});
  @override
  State<_ArtisanCard> createState() => _ArtisanCardState();
}

class _ArtisanCardState extends State<_ArtisanCard> {
  final _convRepo = ConversationRepository();
  bool _connecting = false;

  Future<void> _openChat() async {
    setState(() => _connecting = true);
    try {
      final conv = await _convRepo.getOrCreate(artisanId: widget.artisan.id);
      if (mounted) {
        context.push('/client/chat/${conv.id}', extra: {
          'name':      widget.artisan.name,
          'role':      widget.artisan.specialty,
          'avatar':    widget.artisan.avatarUrl,
          'profileId': conv.otherProfileId,
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Impossible d'ouvrir la conversation.",
              style: TextStyle(fontFamily: 'Public Sans')),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  PublicArtisan get a => widget.artisan;

  @override
  Widget build(BuildContext context) => Container(
    // CSS: 210x343
    width: 210,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF3F4F6), width: 0.714744),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 4.28846,
          offset: Offset(0, 2.85897),
          spreadRadius: -0.714744,
        ),
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 2.85897,
          offset: Offset(0, 1.42949),
          spreadRadius: -1.42949,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Photo section — CSS: 208.57x137.23, radius 12 top ──────
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: a.avatarUrl != null && a.avatarUrl!.isNotEmpty
                  ? Image.network(
                      a.avatarUrl!,
                      // CSS: 208.71x137.23
                      width: 208.71, height: 137.23,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _photoPlaceholder(),
                    )
                  : _photoPlaceholder(),
            ),
            // Category badge — CSS: 34.31x34.31, bg rgba(255,255,255,0.9)
            // radius:10, left:11.5 top:11.44, icon 17.15x17.15 #FC5A15
            Positioned(
              left: 11.5, top: 11.44,
              child: Container(
                width: 34.31, height: 34.31,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10.0064),
                ),
                child: Icon(_catIcon(a.specialty),
                    color: const Color(0xFFFC5A15), size: 17.15),
              ),
            ),
          ],
        ),

        // ── Info section ───────────────────────────────────────────
        // CSS: info container 139x87 at left:16 top:13, gap:4
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
          child: SizedBox(
            width: 139,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row — Inter 400 16px #314158 letter-spacing -0.3125px
                Row(children: [
                  Expanded(
                    child: Text(a.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        letterSpacing: -0.3125,
                        color: Color(0xFF314158),
                      ),
                    ),
                  ),
                  // Verified badge — CSS: 16x16 circle #155DFC
                  if (a.isVerified)
                    Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF155DFC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 9),
                    ),
                ]),
                // CSS: gap 4px
                const SizedBox(height: 4),
                // Specialty — Inter 400 12px #45556C
                Text(a.specialty,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF45556C),
                  ),
                ),
                const SizedBox(height: 4),
                // City — icon 14x14 #62748E, text Inter 400 12px #62748E
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF62748E)),
                  const SizedBox(width: 4),
                  Text(a.city,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF62748E),
                    ),
                  ),
                ]),
                const SizedBox(height: 4),
                // Rating — star 14x14 #FF8904, Inter 400 10px #314158 ls:0.117px
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 14, color: Color(0xFFFF8904)),
                  const SizedBox(width: 6),
                  Text(
                    '${a.rating.toStringAsFixed(1)}/5 (${a.reviews} avis)',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      letterSpacing: 0.117188,
                      color: Color(0xFF314158),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),

        // ── Buttons section ───────────────────────────────────────
        // CSS: 194x76 at left:7 top:114.05, gap:8
        // gap from info bottom (13+87=100) to buttons top (114.05) = 14px
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 12),
          child: Column(children: [
            // View Profile — CSS: 194x34 bg #EFEFEF radius huge
            // Text: Inter 400 11.353px #000000
            SizedBox(
              width: 194, height: 34,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/artisans/profile/${a.id}',
                  extra: {'name': a.name, 'role': a.specialty},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFEFEF),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('View Profile',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.353,
                    letterSpacing: 0.04304,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // CSS: gap 8px
            const SizedBox(height: 8),
            // Connecter — CSS: 194x34 bg #FC5A15 radius huge
            // Text: Inter 400 11.353px #FFFFFF + phone icon 14x14
            SizedBox(
              width: 194, height: 34,
              child: ElevatedButton.icon(
                onPressed: _connecting ? null : _openChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5A15),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: _connecting
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.phone_outlined,
                        color: Colors.white, size: 14),
                label: const Text('Connecter',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.353,
                    letterSpacing: 0.04304,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    ),
  );

  Widget _photoPlaceholder() => Container(
    // CSS: 208.71x137.23
    width: 208.71, height: 137.23,
    decoration: const BoxDecoration(
      color: Color(0xFFE5E7EB),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: const Center(
      child: Icon(Icons.image_outlined, size: 48, color: Color(0xFFD1D5DC))),
  );
}

// ── FAQ accordion ─────────────────────────────────────────────────────────────
// CSS: item width 332.96px (~333), collapsed h:53.56px
// Border: 0.892655px solid #DADADA, radius:16.9605px, bg white
// Expanded: bg #393C40, h:128.54px
// Text: Public Sans 400 14.2825px letter-spacing 0.005em
// Left padding: 28.56px, answer: Public Sans 300 12.4972px rgba(255,255,255,0.79)
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;
  const _FaqItem({
    required this.question, required this.answer,
    required this.isOpen,   required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    // CSS: gap between items ~9px
    padding: const EdgeInsets.only(bottom: 9),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF393C40) : Colors.white,
          border: isOpen
              ? null
              : Border.all(
                  color: const Color(0xFFDADADA),
                  width: 0.892655,
                ),
          borderRadius: BorderRadius.circular(16.9605),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — padding: left 28.56px, vertical ~16px
            Padding(
              padding: const EdgeInsets.fromLTRB(28.56, 16, 16, 16),
              child: Row(children: [
                Expanded(
                  child: Text(question,
                    // CSS: Public Sans 400 14.2825px letter-spacing 0.005em
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14.2825,
                      letterSpacing: 14.2825 * 0.005,
                      color: isOpen ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                // CSS: arrow color #FC5A15 (closed) or #FFFFFF (open)
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isOpen ? Colors.white : const Color(0xFFFC5A15),
                  size: 20,
                ),
              ]),
            ),
            // Answer (expanded only)
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(28.56, 0, 28.56, 20),
                child: Text(answer,
                  // CSS: Public Sans 300 12.4972px lh:16px rgba(255,255,255,0.79)
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w300,
                    fontSize: 12.4972,
                    height: 16 / 12.4972, // line-height: 16px
                    color: Color(0xC9FFFFFF), // rgba(255,255,255,0.79)
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────
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
                color: active ? AppColors.primary : Colors.white,
                size: 22),
            ),
          );
        }),
      ),
    );
  }
}
