import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

// ── Static placeholder data ───────────────────────────────────────────────────
const _kCategories = [
  _Category('Réparations\ngénérales', Icons.build_outlined),
  _Category('Plomberie',              Icons.water_drop_outlined),
  _Category('Électricité',            Icons.bolt_outlined),
  _Category('Peinture',               Icons.format_paint_outlined),
  _Category('Menuiserie',             Icons.carpenter_outlined),
  _Category('Jardinage',              Icons.grass_outlined),
];

const _kArtisans = [
  _Artisan('Ahmed Bennani',  'Plomberie & Sanitaire', 'Casablanca', 4.9, 127, Icons.water_drop_outlined),
  _Artisan('Omar Berrada',   'Dépannage Urgence',      'Marrakech',  4.5, 127, Icons.bolt_outlined),
  _Artisan('Samir Tahiri',   'Peinture intérieure\net extérieure', 'Tanger', 4.9, 127, Icons.format_paint_outlined),
  _Artisan('Driss Mansouri', 'Travaux de menuiserie', 'Casablanca', 4.9, 127, Icons.carpenter_outlined),
];

const _kFaq = [
  'Lorem ipsum dolor sit amet, cons',
  'Lorem ipsum dolor sit amet, cons',
  'Lorem ipsum dolor sit amet, cons',
  'Lorem ipsum dolor sit amet, cons',
];

const _kFaqAnswer =
    'Korem ipsum dolor sit amet, consectetur adipis cing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis. Class aptent taciti sociosqu.';

// ─────────────────────────────────────────────────────────────────────────────
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});
  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _expandedFaq = 1; // second FAQ open by default (as in design)

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

          // Main scrollable content
          CustomScrollView(
            slivers: [
              // ── Orange header with search ─────────────────────────
              SliverToBoxAdapter(child: _HomeHeader()),

              // ── Service categories ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: _ServiceCategories(),
                ),
              ),

              // ── "Lorem ipsum" section label (section heading) ─────
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Promo banner ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Annonce d\'Aujourd\'hui',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.31,
                          color: Color(0xFF191C24),
                        )),
                      const SizedBox(height: 18),
                      _PromoCard(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── "Nos artisans les mieux notés" ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nos artisans les mieux notés',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.31,
                          color: Color(0xFF191C24),
                        )),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Horizontal artisan cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 343,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 30, right: 8),
                    itemCount: _kArtisans.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 18),
                    itemBuilder: (_, i) => _ArtisanCard(artisan: _kArtisans[i]),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── FAQ section ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Questions fréquentes',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.27,
                          color: Color(0xFF191C24),
                        )),
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

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // ── Bottom navigation bar ─────────────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
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
              // Top row: logo + icon buttons
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
                    _HeaderIconBtn(Icons.notifications_none_rounded),
                  ]),
                ],
              ),
              const SizedBox(height: 18),

              // Search + city row
              Row(children: [
                // Search field
                Expanded(
                  flex: 55,
                  child: _SearchPill(
                    hint:   'Quelle service recherc…',
                    darkIcon: Icons.search,
                    translucent: true,
                  ),
                ),
                const SizedBox(width: 8),
                // City filter
                _SearchPill(
                  hint:   'Ville…',
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
  final String  hint;
  final IconData darkIcon;
  final bool    translucent;
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
        color: translucent
            ? Colors.white.withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(children: [
        Expanded(
          child: Text(hint,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize:   14,
              color:      Color(0xFF494949),
              letterSpacing: -0.14,
            )),
        ),
        const SizedBox(width: 8),
        Container(
          width:  36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF393C40),
            shape: BoxShape.circle,
          ),
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
        style: TextStyle(
          fontFamily: 'Poppins', fontSize: 22,
          fontWeight: FontWeight.w700, color: Colors.white,
        )),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white),
        ),
        child: const Text('Fix',
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 16,
            fontWeight: FontWeight.w700, color: Colors.white,
          )),
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
    child: Icon(icon, color: Color(0xFF393C40), size: 20),
  );
}

// ── Service categories ────────────────────────────────────────────────────────
class _ServiceCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 80,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: _kCategories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => _CategoryChip(cat: _kCategories[i]),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  final _Category cat;
  const _CategoryChip({required this.cat});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(cat.icon, color: AppColors.primary, size: 22),
      ),
      const SizedBox(height: 6),
      Text(cat.label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Public Sans', fontSize: 9,
          color: Color(0xFF191C24),
        )),
    ],
  );
}

// ── Promo / announcement card ─────────────────────────────────────────────────
class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 161,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14.7),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end:   Alignment.bottomCenter,
        colors: [Color(0xFFFC5A15), Color(0xFF96360D)],
      ),
      boxShadow: const [
        BoxShadow(color: Color(0x29FC5A15), blurRadius: 12, offset: Offset(0, 6)),
      ],
    ),
    child: Stack(
      children: [
        // Subtle concentric circles decoration
        Positioned(
          right: -60, bottom: -60,
          child: _CircleDecoration(),
        ),

        // "Populaire" badge
        Positioned(
          top: 12, left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Populaire',
              style: TextStyle(
                fontFamily: 'Public Sans', fontSize: 8,
                color: Color(0xFF2B2B2B),
              )),
          ),
        ),

        // Headline text
        const Positioned(
          left: 15, top: 40,
          child: SizedBox(
            width: 176,
            child: Text('Lorem ipsum dolor sit amet, consectetur',
              style: TextStyle(
                fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                fontSize: 18, color: Colors.white,
                letterSpacing: -0.31,
              )),
          ),
        ),

        // "Demander maintenant" button
        Positioned(
          left: 15, bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: 0.9),
              borderRadius: BorderRadius.circular(26.8),
            ),
            child: const Text('Demander maintenant',
              style: TextStyle(
                fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
                fontSize: 10, color: AppColors.primary,
              )),
          ),
        ),

        // Artisan illustration placeholder
        Positioned(
          right: 16, bottom: 0,
          child: Container(
            width: 93, height: 137,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
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
            color: Colors.white.withOpacity(0.25 - i * 0.03),
            width: 9.25,
          ),
        ),
      )),
    ),
  );
}

// ── Artisan card ──────────────────────────────────────────────────────────────
class _ArtisanCard extends StatelessWidget {
  final _Artisan artisan;
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
        // Image placeholder
        Stack(
          children: [
            Container(
              height: 137,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined,
                  size: 48, color: Color(0xFFD1D5DC)),
              ),
            ),
            // Service icon badge (top-left)
            Positioned(
              top: 11, left: 11,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(artisan.icon, color: AppColors.primary, size: 17),
              ),
            ),
          ],
        ),

        // Info section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + verified badge
              Row(children: [
                Expanded(
                  child: Text(artisan.name,
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 16,
                      color: Color(0xFF314158), letterSpacing: -0.31,
                    )),
                ),
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
              const SizedBox(height: 4),
              // Service type
              Text(artisan.service,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  color: Color(0xFF45556C),
                )),
              const SizedBox(height: 4),
              // City
              Row(children: [
                const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF62748E)),
                const SizedBox(width: 4),
                Text(artisan.city,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    color: Color(0xFF62748E),
                  )),
              ]),
              const SizedBox(height: 4),
              // Rating
              Row(children: [
                const Icon(Icons.star_rounded,
                  size: 14, color: Color(0xFFFF8904)),
                const SizedBox(width: 6),
                Text('${artisan.rating}/5 (${artisan.reviews} reviews)',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: Color(0xFF314158), letterSpacing: 0.12,
                  )),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 12),
          child: Column(children: [
            // View Profile
            SizedBox(
              width: double.infinity, height: 34,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFEFEF),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text('View Profile',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11.4,
                    color: Colors.black,
                  )),
              ),
            ),
            const SizedBox(height: 8),
            // Connecter
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
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11.4,
                    color: Colors.white,
                  )),
              ),
            ),
          ]),
        ),
      ],
    ),
  );
}

// ── FAQ accordion ─────────────────────────────────────────────────────────────
class _FaqItem extends StatelessWidget {
  final String    question;
  final String    answer;
  final bool      isOpen;
  final VoidCallback onTap;
  const _FaqItem({
    required this.question, required this.answer,
    required this.isOpen,   required this.onTap,
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
            // Question row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(children: [
                Expanded(
                  child: Text(question,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize:   14.3,
                      letterSpacing: 0.005,
                      color: isOpen ? Colors.white : Colors.black,
                    )),
                ),
                Icon(
                  isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                  color: isOpen ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ]),
            ),
            // Answer (visible when open)
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                child: Text(answer,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize:   12.5,
                    fontWeight: FontWeight.w300,
                    color:      Color(0xC9FFFFFF),
                    height:     1.3,
                  )),
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
      case 0: context.go('/client/dashboard'); break;
      case 4: context.go('/client/profile');   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
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
            return Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
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
                size: 22,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────
class _Category {
  final String  label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

class _Artisan {
  final String  name;
  final String  service;
  final String  city;
  final double  rating;
  final int     reviews;
  final IconData icon;
  const _Artisan(this.name, this.service, this.city,
      this.rating, this.reviews, this.icon);
}
