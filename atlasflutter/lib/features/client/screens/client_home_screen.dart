import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/service_request_repository.dart';
import '../../../../data/repositories/artisan_repository.dart';

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

  List<ServiceCategory> _categories = [];
  List<PublicArtisan>   _artisans   = [];
  bool _catsLoading    = true;
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

          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader()),

              // ── Categories strip ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: _catsLoading
                      ? const SizedBox(height: 80,
                          child: Center(child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2)))
                      : _ServiceCategories(categories: _categories),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Promo banner ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Annonce d\'Aujourd\'hui',
                        style: TextStyle(fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700, fontSize: 18,
                          letterSpacing: -0.31, color: Color(0xFF191C24))),
                      const SizedBox(height: 18),
                      _PromoCard(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Top artisans ──────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nos artisans les mieux notés',
                        style: TextStyle(fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700, fontSize: 18,
                          letterSpacing: -0.31, color: Color(0xFF191C24))),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                        child: SizedBox(width: 24, height: 24,
                          child: Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 12)),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              SliverToBoxAdapter(
                child: SizedBox(
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
                              padding: const EdgeInsets.only(left: 30, right: 8),
                              itemCount: _artisans.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 18),
                              itemBuilder: (_, i) =>
                                  _ArtisanCard(artisan: _artisans[i]),
                            ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── FAQ ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Questions fréquentes',
                        style: TextStyle(fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700, fontSize: 18,
                          letterSpacing: -0.27, color: Color(0xFF191C24))),
                      const SizedBox(height: 16),
                      ...List.generate(_kFaq.length, (i) => _FaqItem(
                        question: _kFaq[i],
                        answer:   _kFaqAnswer,
                        isOpen:   _expandedFaq == i,
                        onTap:    () => setState(() =>
                            _expandedFaq = _expandedFaq == i ? -1 : i),
                      )),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // ── Bottom nav ────────────────────────────────────────────
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
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 15),
                    const _HeaderIconBtn(Icons.notifications_none_rounded),
                  ]),
                ],
              ),
              const SizedBox(height: 18),
              const Row(children: [
                Expanded(
                  flex: 55,
                  child: _SearchPill(
                    hint: 'Quelle service recherc…',
                    darkIcon: Icons.search,
                    translucent: true,
                  ),
                ),
                SizedBox(width: 8),
                _SearchPill(
                  hint: 'Ville…',
                  darkIcon: Icons.keyboard_arrow_down_rounded,
                  translucent: false,
                  width: 112,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final String hint;
  final IconData darkIcon;
  final bool translucent;
  final double? width;
  const _SearchPill({
    required this.hint, required this.darkIcon,
    required this.translucent, this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 48,
      padding: const EdgeInsets.fromLTRB(16, 12, 7, 12),
      decoration: BoxDecoration(
        color: translucent ? Colors.white.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(children: [
        Expanded(
          child: Text(hint,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF494949), letterSpacing: -0.14)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF393C40), shape: BoxShape.circle),
          child: Icon(darkIcon, color: Colors.white, size: 18),
        ),
      ]),
    );
    if (width != null) return SizedBox(width: width, child: child);
    return child;
  }
}

class _WhiteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Atlas',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
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
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
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
    width: 40, height: 40,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(icon, color: const Color(0xFF393C40), size: 20),
  );
}

// ── Service categories strip ───────────────────────────────────────────────────
class _ServiceCategories extends StatelessWidget {
  final List<ServiceCategory> categories;
  const _ServiceCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox(height: 80);
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_catIcon(cat.name), color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(cat.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 9,
              color: Color(0xFF191C24))),
      ],
    ),
  );
}

// ── Promo card ────────────────────────────────────────────────────────────────
class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 161,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14.7),
      gradient: const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFFC5A15), Color(0xFF96360D)],
      ),
      boxShadow: const [
        BoxShadow(color: Color(0x29FC5A15), blurRadius: 12, offset: Offset(0, 6)),
      ],
    ),
    child: Stack(
      children: [
        Positioned(right: -60, bottom: -60, child: _CircleDecoration()),
        Positioned(
          top: 12, left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Populaire',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 8,
                  color: Color(0xFF2B2B2B))),
          ),
        ),
        const Positioned(
          left: 15, top: 40,
          child: SizedBox(
            width: 176,
            child: Text('Trouvez l\'artisan parfait pour vos besoins',
              style: TextStyle(fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700, fontSize: 18,
                  color: Colors.white, letterSpacing: -0.31)),
          ),
        ),
        Positioned(
          left: 15, bottom: 16,
          child: GestureDetector(
            onTap: () => context.push('/client/service-categories'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 0.9),
                borderRadius: BorderRadius.circular(26.8),
              ),
              child: const Text('Demander maintenant',
                style: TextStyle(fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700, fontSize: 10,
                    color: AppColors.primary)),
            ),
          ),
        ),
        Positioned(
          right: 16, bottom: 0,
          child: Container(
            width: 93, height: 137,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

class _CircleDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240, height: 240,
    child: Stack(
      alignment: Alignment.center,
      children: List.generate(6, (i) => Container(
        width: 60.0 + i * 36,
        height: 60.0 + i * 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25 - i * 0.03),
            width: 9.25,
          ),
        ),
      )),
    ),
  );
}

// ── Artisan card ──────────────────────────────────────────────────────────────
class _ArtisanCard extends StatelessWidget {
  final PublicArtisan artisan;
  const _ArtisanCard({required this.artisan});

  @override
  Widget build(BuildContext context) => Container(
    width: 210,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF3F4F6), width: 0.71),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Color(0x1A000000), blurRadius: 4.3,
            offset: Offset(0, 2.9), spreadRadius: -0.7),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar / cover
        Stack(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: artisan.avatarUrl != null &&
                      artisan.avatarUrl!.isNotEmpty
                  ? Image.network(
                      artisan.avatarUrl!,
                      height: 137,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _photoPlaceholder(),
                    )
                  : _photoPlaceholder(),
            ),
            Positioned(
              top: 11, left: 11,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_catIcon(artisan.specialty),
                    color: AppColors.primary, size: 17),
              ),
            ),
          ],
        ),

        // Info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(artisan.name,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 16,
                        color: Color(0xFF314158), letterSpacing: -0.31)),
                ),
                if (artisan.isVerified)
                  Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF155DFC), shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 9),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(artisan.specialty,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                    color: Color(0xFF45556C))),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF62748E)),
                const SizedBox(width: 4),
                Text(artisan.city,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                      color: Color(0xFF62748E))),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star_rounded,
                  size: 14, color: Color(0xFFFF8904)),
                const SizedBox(width: 6),
                Text('${artisan.rating.toStringAsFixed(1)}/5 (${artisan.reviews} avis)',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                      color: Color(0xFF314158), letterSpacing: 0.12)),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 12),
          child: Column(children: [
            SizedBox(
              width: double.infinity, height: 34,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/artisans/profile/${artisan.id}',
                  extra: {'name': artisan.name, 'role': artisan.specialty},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFEFEF),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Voir profil',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11.4,
                      color: Colors.black)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity, height: 34,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.phone_outlined,
                  color: Colors.white, size: 14),
                label: const Text('Connecter',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11.4,
                      color: Colors.white)),
              ),
            ),
          ]),
        ),
      ],
    ),
  );

  Widget _photoPlaceholder() => Container(
    height: 137,
    decoration: const BoxDecoration(
      color: Color(0xFFE5E7EB),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: const Center(
      child: Icon(Icons.image_outlined, size: 48, color: Color(0xFFD1D5DC))),
  );
}

// ── FAQ accordion ─────────────────────────────────────────────────────────────
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;
  const _FaqItem({
    required this.question, required this.answer,
    required this.isOpen, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF393C40) : Colors.white,
          border: Border.all(
            color: isOpen ? Colors.transparent : const Color(0xFFDADADA),
            width: 0.89,
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(children: [
                Expanded(
                  child: Text(question,
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontSize: 14.3,
                      letterSpacing: 0.005,
                      color: isOpen ? Colors.white : Colors.black,
                    )),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up_rounded
                         : Icons.keyboard_arrow_down_rounded,
                  color: isOpen ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ]),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                child: Text(answer,
                  style: const TextStyle(fontFamily: 'Public Sans',
                    fontSize: 12.5, fontWeight: FontWeight.w300,
                    color: Color(0xC9FFFFFF), height: 1.3)),
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
                color: active ? AppColors.primary : Colors.white, size: 22),
            ),
          );
        }),
      ),
    );
  }
}
