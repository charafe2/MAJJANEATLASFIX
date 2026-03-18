import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/atlas_logo.dart';
import '../../../data/repositories/artisan_job_repository.dart';
import '../../../data/repositories/artisan_repository.dart';
import '../../../data/repositories/conversation_repository.dart';

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
  if (n.contains('climatis') || n.contains('clim')) return Icons.ac_unit_outlined;
  if (n.contains('construct'))                       return Icons.construction_outlined;
  return Icons.build_outlined;
}

const _kFaq = [
  'Comment fonctionne AtlasFix ?',
  'Comment puis-je contacter un client ?',
  'Mes paiements sont-ils sécurisés ?',
  'Comment gérer mes disponibilités ?',
];
const _kFaqAnswer =
    'AtlasFix met en relation clients et artisans qualifiés. Répondez aux demandes, proposez vos offres et gérez vos missions directement depuis l\'application. Votre paiement est sécurisé et libéré uniquement après validation des travaux.';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});
  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  final _artisanRepo = ArtisanRepository();

  int _expandedFaq = 1;

  List<PublicArtisan>   _artisans      = [];
  bool _artisansLoading = true;

  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
    setState(() => _artisansLoading = true);
    try {
      final data = await _artisanRepo.getArtisans(
        search: _searchQuery,
      );
      if (mounted) setState(() { _artisans = data; _artisansLoading = false; });
    } catch (e) {
      debugPrint('[ArtisanHome] _loadArtisans error: $e');
      if (mounted) setState(() { _artisans = []; _artisansLoading = false; });
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
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.6238],
                  colors: [Color(0x4DFF8C5B), Color(0x00FF8C5B)],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),

                      // Promo card
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Annonce d'Aujourd'hui",
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.306545,
                                color: Color(0xFF191C24),
                              )),
                            SizedBox(height: 18),
                            _PromoCard(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Artisans list
                      const _SectionHeader(
                        title: 'Nos artisans les mieux notés',
                        onMore: null,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 345,
                        child: _artisansLoading
                            ? const Center(child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2))
                            : _artisans.isEmpty
                                ? const Center(child: Text('Aucun artisan disponible.',
                                    style: TextStyle(fontFamily: 'Public Sans',
                                        fontSize: 13, color: Color(0xFF9CA3AF))))
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 30, right: 8),
                                    itemCount: _artisans.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 18),
                                    itemBuilder: (_, i) => _ArtisanCard(artisan: _artisans[i]),
                                  ),
                      ),

                      // ── Artisan-only sections ─────────────────────────────
                      const SizedBox(height: 28),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: _AddServiceCard(),
                      ),
                      const SizedBox(height: 28),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: _ReferralSection(),
                      ),

                      const SizedBox(height: 28),

                      // FAQ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Questions fréquentes',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.273557,
                                color: Color(0xFF191C24),
                              )),
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

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          height: 158,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(29, 0, 29, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AtlasLogo(),
                    Row(children: [
                      GestureDetector(
                        onTap: () => context.push('/artisan/agenda'),
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
                // Search pills
                GestureDetector(
                  onTap: () => _showSearchDialog(context),
                  child: Container(
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
                      Expanded(
                        child: Text(
                          _searchQuery ?? 'Quelle service recherchez-vous ?',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Public Sans', fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _searchQuery != null
                                ? Colors.black : const Color(0xFF494949),
                            letterSpacing: -0.14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                            color: Color(0xFF393C40), shape: BoxShape.circle),
                        child: const Icon(Icons.manage_search,
                            color: Colors.white, size: 18),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Search dialog ──────────────────────────────────────────────────────────
  void _showSearchDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rechercher un service',
                style: TextStyle(fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700, fontSize: 16,
                    color: Color(0xFF314158))),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ex: Plomberie, Électricité…',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
                onSubmitted: (val) {
                  Navigator.pop(ctx);
                  setState(() => _searchQuery = val.trim().isEmpty ? null : val.trim());
                  _loadArtisans();
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_searchQuery != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _searchQuery = null);
                          _loadArtisans();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                        child: const Text('Effacer',
                          style: TextStyle(fontFamily: 'Public Sans',
                              fontSize: 13, color: Color(0xFF62748E))),
                      ),
                    ),
                  if (_searchQuery != null) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final val = ctrl.text.trim();
                        setState(() => _searchQuery = val.isEmpty ? null : val);
                        _loadArtisans();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                      child: const Text('Rechercher',
                        style: TextStyle(fontFamily: 'Public Sans',
                            fontSize: 13, color: Colors.white)),
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

}

// ── Bottom nav bar ─────────────────────────────────────────────────────────────
class ArtisanBottomNavBar extends StatelessWidget {
  final int activeIndex;
  const ArtisanBottomNavBar({super.key, required this.activeIndex});

  // null = center tools button (image asset)
  static const _imageAssets = [
    'assets/images/HomeIcone.png',
    'assets/images/ReservationIcone.png',
    'assets/images/pan.png',     // center: available requests
    'assets/images/ChatIcone.png',
    'assets/images/profileicone.png',
  ];

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    switch (index) {
      case 0: context.go('/artisan/home');                 break;
      case 1: context.go('/artisan/offers');               break;
      case 2: context.push('/artisan/available-requests'); break;
      case 3: context.go('/artisan/messages');             break;
      case 4: context.go('/artisan/profile');              break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342, height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (i) {
          final active = i == activeIndex;

          // Centre button — special orange/bordered circle
          if (i == 2) {
            return GestureDetector(
              onTap: () => _onTap(context, i),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: active ? null : Border.all(color: Colors.white, width: 1),
                ),
                child: const Center(
                  child: Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
                ),
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
              child: Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    active ? AppColors.primary : Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(_imageAssets[i], width: 22, height: 22),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  final EdgeInsetsGeometry padding;
  const _SectionHeader({required this.title, required this.onMore,
      this.padding = const EdgeInsets.symmetric(horizontal: 30)});

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Public Sans',
            fontWeight: FontWeight.w700, fontSize: 18,
            letterSpacing: -0.273557, color: Color(0xFF191C24))),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Row(children: [
              const Text('Voir plus', style: TextStyle(fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w500, fontSize: 10,
                  letterSpacing: -0.273557, color: Color(0xFF191C24))),
              const SizedBox(width: 2),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: const Color(0xFF393C40),
                    borderRadius: BorderRadius.circular(27.1429)),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 11),
              ),
            ]),
          )
        else
          const SizedBox.shrink(),
      ],
    ),
  );
}

// ── Promo card ────────────────────────────────────────────────────────────────
class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFC5A15);
    const radius = 20.0;
    const cardH  = 155.0;
    const imgOver = 24.0;
    const backShift = 7.0;

    return SizedBox(
      width: double.infinity,
      height: cardH + imgOver,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: imgOver, left: 0, right: 0, bottom: 0,
            child: Transform.rotate(
              angle: 0.035, // ~2 degrees clockwise — left side lifts up
              alignment: Alignment.bottomRight,
              child: Container(decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(radius))),
            ),
          ),
          Positioned(
            top: imgOver, left: 0, right: 0, bottom: backShift,
            child: Container(
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: const [BoxShadow(
                    color: Color(0x400B1324), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 130, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Populaire', style: TextStyle(
                          fontFamily: 'Public Sans', fontSize: 10,
                          color: Color(0xFF2B2B2B))),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trouvez de nouveaux\nclients facilement',
                          style: TextStyle(fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w700, fontSize: 18,
                              letterSpacing: -0.306545, color: Colors.white,
                              height: 1.35)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => context.push('/artisan/available-requests'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white,
                                borderRadius: BorderRadius.circular(25)),
                            child: const Text('Voir les demandes',
                              style: TextStyle(fontFamily: 'Public Sans',
                                  fontWeight: FontWeight.w500, fontSize: 12,
                                  color: Color(0xFF1A1A1A))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0, top: 0, bottom: backShift,
            child: SizedBox(
              width: 128,
              child: Image.asset('assets/images/plumber.png',
                  fit: BoxFit.contain, alignment: Alignment.bottomRight,
                  filterQuality: FilterQuality.high),
            ),
          ),
          const Positioned(left: 9, bottom: backShift + 8, child: _ScrewDot()),
          const Positioned(right: 9, bottom: backShift + 8, child: _ScrewDot()),
          const Positioned(right: 9, top: imgOver + 8,     child: _ScrewDot()),
        ],
      ),
    );
  }
}

class _ScrewDot extends StatelessWidget {
  const _ScrewDot();
  @override
  Widget build(BuildContext context) => Container(
    width: 6.13, height: 6.13,
    decoration: const BoxDecoration(
        color: Color(0xFFFC5A15), shape: BoxShape.circle),
    child: Center(child: Container(
      width: 3.5, height: 3.5,
      decoration: const BoxDecoration(
          color: Colors.white, shape: BoxShape.circle),
    )),
  );
}

// ── Artisan card ──────────────────────────────────────────────────────────────
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
          'name': widget.artisan.name, 'role': widget.artisan.specialty,
          'avatar': widget.artisan.avatarUrl, 'profileId': conv.otherProfileId,
        });
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Impossible d'ouvrir la conversation.",
            style: TextStyle(fontFamily: 'Public Sans')),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  PublicArtisan get a => widget.artisan;

  @override
  Widget build(BuildContext context) => Container(
    width: 210,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF3F4F6), width: 0.714744),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Color(0x1A000000), blurRadius: 4.29,
            offset: Offset(0, 2.86), spreadRadius: -0.71),
        BoxShadow(color: Color(0x1A000000), blurRadius: 2.86,
            offset: Offset(0, 1.43), spreadRadius: -1.43),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: a.avatarUrl != null && a.avatarUrl!.isNotEmpty
                ? Image.network(a.avatarUrl!, width: 208.71, height: 137.23,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _photoPlaceholder())
                : _photoPlaceholder(),
          ),
          Positioned(
            left: 11.5, top: 11.44,
            child: Container(
              width: 34.31, height: 34.31,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(_catIcon(a.specialty),
                  color: const Color(0xFFFC5A15), size: 17.15),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
          child: SizedBox(
            width: 139,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(a.name, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, fontSize: 16,
                        letterSpacing: -0.3125, color: Color(0xFF314158)))),
                  if (a.isVerified)
                    Container(width: 16, height: 16,
                      decoration: const BoxDecoration(
                          color: Color(0xFF155DFC), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 9)),
                ]),
                const SizedBox(height: 4),
                Text(a.yearsExperience != null
                    ? '${a.specialty} · ${a.yearsExperience} ans' : a.specialty,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                      color: Color(0xFF45556C))),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF62748E)),
                  const SizedBox(width: 4),
                  Expanded(child: Text(a.city, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: Color(0xFF62748E)))),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFF8904)),
                  const SizedBox(width: 6),
                  Text('${a.rating.toStringAsFixed(1)}/5 (${a.reviews} avis)',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                        letterSpacing: 0.117188, color: Color(0xFF314158))),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 12),
          child: Column(children: [
            SizedBox(
              width: 194, height: 34,
              child: ElevatedButton(
                onPressed: () => context.push('/artisans/profile/${a.id}',
                    extra: {'name': a.name, 'role': a.specialty}),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEFEFEF),
                    elevation: 0, shape: const StadiumBorder(), padding: EdgeInsets.zero),
                child: const Text('View Profile', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11.353,
                    letterSpacing: 0.04304, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 194, height: 34,
              child: ElevatedButton.icon(
                onPressed: _connecting ? null : _openChat,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC5A15), elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 10)),
                icon: _connecting
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.phone_outlined, color: Colors.white, size: 14),
                label: const Text('Connecter', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11.353,
                    letterSpacing: 0.04304, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ],
    ),
  );

  Widget _photoPlaceholder() => Container(
    width: 208.71, height: 137.23,
    decoration: const BoxDecoration(color: Color(0xFFE5E7EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    child: const Center(child: Icon(Icons.image_outlined,
        size: 48, color: Color(0xFFD1D5DC))),
  );
}

// ── FAQ accordion ─────────────────────────────────────────────────────────────
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;
  const _FaqItem({required this.question, required this.answer,
      required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF393C40) : Colors.white,
          border: isOpen ? null : Border.all(color: const Color(0xFFDADADA), width: 0.892655),
          borderRadius: BorderRadius.circular(16.9605),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28.56, 16, 16, 16),
              child: Row(children: [
                Expanded(child: Text(question,
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 14.2825,
                      letterSpacing: 14.2825 * 0.005,
                      color: isOpen ? Colors.white : Colors.black))),
                Icon(isOpen ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                    color: isOpen ? Colors.white : const Color(0xFFFC5A15), size: 20),
              ]),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(28.56, 0, 28.56, 20),
                child: Text(answer, style: const TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w300,
                    fontSize: 12.4972, height: 16 / 12.4972,
                    color: Color(0xC9FFFFFF))),
              ),
          ],
        ),
      ),
    ),
  );
}

// ── "Ajouter un service" card ─────────────────────────────────────────────────
class _AddServiceCard extends StatelessWidget {
  const _AddServiceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(9.8),
        boxShadow: const [BoxShadow(color: Color(0x1A000000),
            blurRadius: 1.84, offset: Offset(0, 0.61))],
      ),
      child: Stack(children: [
        // Background tools image at very low opacity
        Positioned.fill(
          child: Opacity(
            opacity: 0.06,
            child: Image.asset('assets/images/tools.png',
                fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
          child: Column(children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xCC393C40),
            borderRadius: BorderRadius.circular(8.6),
            boxShadow: const [BoxShadow(color: Color(0x40000000),
                blurRadius: 4, offset: Offset(0, 2))],
          ),
          padding: const EdgeInsets.fromLTRB(12, 20, 10, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 36, height: 35,
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.build_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "En tant qu'artisan, souhaitez-vous ajouter un autre service ?",
                  style: TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w600, fontSize: 16,
                      height: 1.25, letterSpacing: 0.242, color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            const Text(
              'Vorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400,
                  fontSize: 12, height: 1.5, letterSpacing: -0.3125, color: Colors.white),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 39,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/artisan/add-service'),
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 18),
            label: const Text('Ajouter un service', style: TextStyle(
                fontFamily: 'Public Sans', fontWeight: FontWeight.w500,
                fontSize: 12, letterSpacing: -0.191532, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                elevation: 0, shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16)),
          ),
        ),
        const SizedBox(height: 16),
           ]),        // Column children
        ),           // Padding
      ]),            // Stack children
    );               // Container
  }
}

// ── "Programme de Parrainage" section ─────────────────────────────────────────
class _ReferralSection extends StatefulWidget {
  const _ReferralSection();

  @override
  State<_ReferralSection> createState() => _ReferralSectionState();
}

class _ReferralSectionState extends State<_ReferralSection> {
  final _repo = ArtisanJobRepository();
  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    try {
      final p = await _repo.getMyProfile();
      if (mounted) setState(() => _referralCode = p.referralCode);
    } catch (_) {}
  }

  void _openReferralSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReferralSheet(referralCode: _referralCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Programme de Parrainage', style: TextStyle(
            fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
            fontSize: 18, letterSpacing: -0.273557, color: Color(0xFF191C24))),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [Color(0xFFFEFCE8), Color(0xFFFFF7ED)],
            ),
            border: Border.all(color: const Color(0xFFFFF085), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFFD08700), size: 20),
              SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gagnez 1 boost gratuit', style: TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w700,
                      fontSize: 12, height: 1.33, color: Color(0xFF733E0A))),
                  SizedBox(height: 4),
                  Text(
                    "(7 jours) pour chaque ami qui crée un compte artisan sur AtlasFix grâce à votre lien.",
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400,
                        fontSize: 12, height: 1.33, color: Color(0xFF733E0A))),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 39,
          child: ElevatedButton.icon(
            onPressed: _openReferralSheet,
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 17),
            label: const Text('Générer mon lien de parrainage', style: TextStyle(
                fontFamily: 'Public Sans', fontWeight: FontWeight.w500,
                fontSize: 12, letterSpacing: -0.191532, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                elevation: 0, shape: const StadiumBorder()),
          ),
        ),
      ],
    );
  }
}

// ── Referral bottom sheet ─────────────────────────────────────────────────────
class _ReferralSheet extends StatefulWidget {
  const _ReferralSheet({this.referralCode});
  final String? referralCode;

  @override
  State<_ReferralSheet> createState() => _ReferralSheetState();
}

class _ReferralSheetState extends State<_ReferralSheet> {
  bool _copied = false;

  String get _referralLink {
    final code = widget.referralCode ?? '';
    if (code.isEmpty) return '';
    return '${ApiConstants.webBaseUrl}/register/artisan?ref=$code';
  }

  Future<void> _copyLink() async {
    final link = _referralLink;
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lien de parrainage non disponible.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    await Clipboard.setData(ClipboardData(text: link));
    setState(() => _copied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lien copié dans le presse-papier !'),
        backgroundColor: Color(0xFF22C55E),
        duration: Duration(seconds: 2),
      ));
    }
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = (widget.referralCode ?? '').isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text('Programme de Parrainage',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Color(0xFF191C24),
                  )),
              ),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard_rounded,
                  color: AppColors.primary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Partagez AtlasFix avec vos amis et gagnez un boost gratuit pour chaque inscription !',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: Color(0xFF62748E),
              height: 1.55,
            )),
          if (hasCode) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _referralLink,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton.icon(
              onPressed: _copyLink,
              icon: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 18,
              ),
              label: Text(
                _copied ? 'Lien copié !' : 'Générer mon lien de parrainage',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                )),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copied
                    ? const Color(0xFF22C55E)
                    : AppColors.primary,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              border: Border.all(color: const Color(0xFFFFF085)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFFD08700), size: 20),
                SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gagnez 1 boost gratuit', style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w700,
                        fontSize: 13, height: 1.33, color: Color(0xFF733E0A))),
                    SizedBox(height: 4),
                    Text(
                      '(7 jours) pour chaque ami qui crée un compte artisan via votre lien !',
                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400,
                          fontSize: 12, height: 1.33, color: Color(0xFF733E0A))),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
