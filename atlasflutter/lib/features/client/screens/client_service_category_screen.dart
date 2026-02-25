import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

// ── Category data ─────────────────────────────────────────────────────────────

class _ServiceCategory {
  final String label;
  final IconData icon;
  const _ServiceCategory(this.label, this.icon);
}

const _kAllCategories = [
  _ServiceCategory('Réparations\ngénérales',        Icons.build_outlined),
  _ServiceCategory('Plomberie',                      Icons.water_drop_outlined),
  _ServiceCategory('Électricité',                    Icons.bolt_outlined),
  _ServiceCategory('Peinture',                       Icons.format_paint_outlined),
  _ServiceCategory('Technologie',                    Icons.computer_outlined),
  _ServiceCategory('Nettoyage',                      Icons.cleaning_services_outlined),
  _ServiceCategory('Déménagement',                   Icons.local_shipping_outlined),
  _ServiceCategory('Chauffeur &\nInstallation',      Icons.directions_car_outlined),
  _ServiceCategory('Mécanique\ntotale',              Icons.settings_outlined),
  _ServiceCategory('Vitrerie',                       Icons.window_outlined),
  _ServiceCategory('Assurance de\nToiture',          Icons.roofing_outlined),
  _ServiceCategory('Fitness &\nSport',               Icons.fitness_center_outlined),
  _ServiceCategory('Photo',                          Icons.photo_camera_outlined),
  _ServiceCategory('Vidéo',                          Icons.videocam_outlined),
  _ServiceCategory('Mesure &\nLivraison',            Icons.straighten_outlined),
  _ServiceCategory('Beauté &\nStyle',                Icons.content_cut_outlined),
  _ServiceCategory('Service de\nRestauration',       Icons.restaurant_outlined),
  _ServiceCategory('Organisation\nd\'évènements',    Icons.event_outlined),
  _ServiceCategory('Location de\nMatériel',          Icons.hardware_outlined),
  _ServiceCategory('Réparations\nOrdinateur',        Icons.laptop_outlined),
  _ServiceCategory('Impression',                     Icons.print_outlined),
  _ServiceCategory('Construction\nManuel',           Icons.construction_outlined),
  _ServiceCategory('Support\nTechnique',             Icons.headset_mic_outlined),
  _ServiceCategory('Appareils &\nÉnergie',           Icons.electrical_services_outlined),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ClientServiceCategoryScreen extends StatefulWidget {
  const ClientServiceCategoryScreen({super.key});

  @override
  State<ClientServiceCategoryScreen> createState() =>
      _ClientServiceCategoryScreenState();
}

class _ClientServiceCategoryScreenState
    extends State<ClientServiceCategoryScreen> {
  final _searchCtrl = TextEditingController();
  List<_ServiceCategory> _filtered = List.of(_kAllCategories);

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.of(_kAllCategories)
          : _kAllCategories
              .where((c) => c.label.toLowerCase().contains(q))
              .toList();
    });
  }

  void _onCategoryTap(_ServiceCategory cat) {
    // Strip newlines for query param
    final name = cat.label.replaceAll('\n', ' ');
    context.push('/client/service-types', extra: {'category': name});
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
                  stops: [0.0, 0.55],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // ── Orange header ───────────────────────────────────────
              _buildHeader(context),

              // ── Grid ───────────────────────────────────────────────
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text('Aucune catégorie trouvée',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              color: AppColors.grey,
                            )),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _CategoryTile(
                          cat: _filtered[i],
                          onTap: () => _onCategoryTap(_filtered[i]),
                        ),
                      ),
              ),
            ],
          ),

          // ── Bottom nav ─────────────────────────────────────────────
          const Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(child: _BottomNavBar()),
          ),
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('Retour',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white70,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Title
              const Text('Choisissez un service',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                  )),
              const SizedBox(height: 4),
              const Text('Sélectionnez la catégorie qui correspond à votre besoin',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Colors.white70,
                  )),
              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        color: Color(0xFF314158),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un service…',
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final _ServiceCategory cat;
  final VoidCallback onTap;
  const _CategoryTile({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(cat.icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              cat.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 9,
                color: Color(0xFF191C24),
                height: 1.3,
              ),
            ),
          ],
        ),
      );
}

// ── Bottom nav bar ────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

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
      width: 342,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (i) {
          // + button (center) — active/highlighted on this screen
          if (i == 2) {
            return const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add, color: Colors.white, size: 22),
              ),
            );
          }
          return GestureDetector(
            onTap: () {
              if (i == 0) context.go('/client/dashboard');
              if (i == 4) context.go('/client/profile');
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icons[i], color: Colors.white, size: 22),
            ),
          );
        }),
      ),
    );
  }
}
