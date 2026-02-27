import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/service_request_repository.dart';

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
  if (n.contains('chauffeur'))                       return Icons.directions_car_outlined;
  if (n.contains('mécanique'))                       return Icons.settings_outlined;
  if (n.contains('vitrerie'))                        return Icons.window_outlined;
  if (n.contains('toiture'))                         return Icons.roofing_outlined;
  if (n.contains('fitness') || n.contains('sport')) return Icons.fitness_center_outlined;
  if (n.contains('photo'))                           return Icons.photo_camera_outlined;
  if (n.contains('vidéo') || n.contains('video'))   return Icons.videocam_outlined;
  if (n.contains('beauté') || n.contains('coiff'))  return Icons.content_cut_outlined;
  if (n.contains('restaur'))                         return Icons.restaurant_outlined;
  if (n.contains('évènem') || n.contains('event'))  return Icons.event_outlined;
  if (n.contains('location') || n.contains('matér'))return Icons.hardware_outlined;
  if (n.contains('ordinateur') || n.contains('laptop')) return Icons.laptop_outlined;
  if (n.contains('impression'))                      return Icons.print_outlined;
  if (n.contains('construct'))                       return Icons.construction_outlined;
  if (n.contains('support') || n.contains('tech'))  return Icons.headset_mic_outlined;
  if (n.contains('énergie') || n.contains('appare'))return Icons.electrical_services_outlined;
  if (n.contains('technologie'))                     return Icons.computer_outlined;
  return Icons.build_outlined;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ClientServiceCategoryScreen extends StatefulWidget {
  const ClientServiceCategoryScreen({super.key});

  @override
  State<ClientServiceCategoryScreen> createState() =>
      _ClientServiceCategoryScreenState();
}

class _ClientServiceCategoryScreenState
    extends State<ClientServiceCategoryScreen> {
  final _repo       = ServiceRequestRepository();
  final _searchCtrl = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<ServiceCategory> _all      = [];
  List<ServiceCategory> _filtered = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final cats = await _repo.getCategories();
      if (mounted) {
        setState(() {
          _all      = cats;
          _filtered = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error     = ServiceRequestRepository.errorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  void _onCategoryTap(ServiceCategory cat) {
    context.push('/client/service-types', extra: {
      'categoryId': cat.id,
      'category':   cat.name,
    });
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
              Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (_isLoading) {
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
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text('Aucune catégorie trouvée',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
              color: AppColors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
  final ServiceCategory cat;
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
              child: Icon(_catIcon(cat.name), color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              cat.name,
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
