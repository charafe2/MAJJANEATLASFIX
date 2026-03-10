import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/service_request_repository.dart';

// ── Icon mapping ──────────────────────────────────────────────────────────────

IconData _catIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('répar') && n.contains('général'))  return Icons.build_outlined;
  if (n.contains('plomb'))                            return Icons.water_drop_outlined;
  if (n.contains('élec') && n.contains('ménag'))      return Icons.kitchen_outlined;
  if (n.contains('élec') || n.contains('elec'))       return Icons.bolt_outlined;
  if (n.contains('peinture'))                         return Icons.format_paint_outlined;
  if (n.contains('nettoy'))                           return Icons.cleaning_services_outlined;
  if (n.contains('déménag'))                          return Icons.local_shipping_outlined;
  if (n.contains('chauff') || n.contains('ventil') || n.contains('climati')) {
    return Icons.thermostat_outlined;
  }
  if (n.contains('mécanicien'))                       return Icons.handyman_outlined;
  if (n.contains('vidange'))                          return Icons.oil_barrel_outlined;
  if (n.contains('assistance') && n.contains('rout')) return Icons.emergency_outlined;
  if (n.contains('organisation') || n.contains('événement')) {
    return Icons.event_outlined;
  }
  if (n.contains('photo'))                            return Icons.photo_camera_outlined;
  if (n.contains('vidéo') || n.contains('video'))     return Icons.videocam_outlined;
  if (n.contains('musique') || n.contains('animation')) {
    return Icons.music_note_outlined;
  }
  if (n.contains('beauté') || n.contains('style'))    return Icons.content_cut_outlined;
  if (n.contains('restaur'))                          return Icons.restaurant_outlined;
  if (n.contains('décoration'))                       return Icons.celebration_outlined;
  if (n.contains('location') && n.contains('matér'))  return Icons.hardware_outlined;
  if (n.contains('ordinateur'))                       return Icons.laptop_outlined;
  if (n.contains('réseau') || n.contains('wifi'))     return Icons.wifi_outlined;
  if (n.contains('maison') && n.contains('connect'))  return Icons.home_outlined;
  if (n.contains('support') || n.contains('tech'))    return Icons.headset_mic_outlined;
  if (n.contains('téléphone') || n.contains('tablette')) {
    return Icons.smartphone_outlined;
  }
  if (n.contains('menuiser'))                         return Icons.carpenter_outlined;
  if (n.contains('jardin'))                           return Icons.grass_outlined;
  if (n.contains('toiture'))                          return Icons.roofing_outlined;
  return Icons.build_outlined;
}

// ── Color mapping (from Figma) ────────────────────────────────────────────────

Color _catColor(String name) {
  final n = name.toLowerCase();
  if (n.contains('répar') && n.contains('général'))   return const Color(0xFFFB2C36);
  if (n.contains('plomb'))                             return const Color(0xFF2B7FFF);
  if (n.contains('élec') && n.contains('ménag'))       return const Color(0xFFFF2056);
  if (n.contains('élec') || n.contains('elec'))        return const Color(0xFFF0B100);
  if (n.contains('peinture'))                          return const Color(0xFFAD46FF);
  if (n.contains('nettoy'))                            return const Color(0xFF00B8DB);
  if (n.contains('déménag'))                           return const Color(0xFF615FFF);
  if (n.contains('chauff') || n.contains('ventil') || n.contains('climati')) {
    return const Color(0xFFF54900);
  }
  if (n.contains('mécanicien'))                        return const Color(0xFF364153);
  if (n.contains('vidange'))                           return const Color(0xFF00BBA7);
  if (n.contains('assistance') && n.contains('rout'))  return const Color(0xFF4A0083);
  if (n.contains('organisation') || (n.contains('événement') && !n.contains('décor'))) {
    return const Color(0xFF007824);
  }
  if (n.contains('photo'))                             return const Color(0xFFC7D200);
  if (n.contains('vidéo') || n.contains('video'))      return const Color(0xFF334AF6);
  if (n.contains('musique') || n.contains('animation'))return const Color(0xFFF4111C);
  if (n.contains('beauté') || n.contains('style'))     return const Color(0xFFF6339A);
  if (n.contains('restaur'))                           return const Color(0xFF00AA44);
  if (n.contains('décoration'))                        return const Color(0xFF8100CB);
  if (n.contains('location') && n.contains('matér'))   return const Color(0xFF36A0A0);
  if (n.contains('ordinateur'))                        return const Color(0xFFFF6900);
  if (n.contains('réseau') || n.contains('wifi'))      return const Color(0xFFFF434C);
  if (n.contains('maison') && n.contains('connect'))   return const Color(0xFF035BB9);
  if (n.contains('support') || n.contains('tech'))     return const Color(0xFF733E0A);
  if (n.contains('téléphone') || n.contains('tablette')) {
    return const Color(0xFFDA2976);
  }
  return const Color(0xFF364153);
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

              // ── Step progress bar ──────────────────────────────────
              const _StepProgressBar(currentStep: 1, totalSteps: 3),

              // ── Grid ───────────────────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),

          // ── Bottom nav ─────────────────────────────────────────────
          const Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 2)),
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
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 106 / 103,
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
              const Text('Sélectionnez le service dont vous avez besoin',
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
                        hintText: 'Quelle service recherchez-vous ?',
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

// ── Category tile (Figma design) ──────────────────────────────────────────────
// CSS: 106.12×103px, border 1.56px solid #FC5A15, radius 10.92px
// Inner: 50.72×50.72px colored container with radius 14.79px, white icon
// Label: Inter 400 12px #314158, centered

class _CategoryTile extends StatelessWidget {
  final ServiceCategory cat;
  final VoidCallback onTap;
  const _CategoryTile({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _catColor(cat.name);
    final icon  = _catIcon(cat.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFC5A15),
            width: 1.56,
          ),
          borderRadius: BorderRadius.circular(10.92),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Colored icon container — 50.72×50.72, radius 14.79
            Container(
              width: 50.72,
              height: 50.72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14.79),
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(height: 8),
            // Label — Inter 400 12px #314158, centered
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  letterSpacing: -0.15,
                  color: Color(0xFF314158),
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step progress bar ─────────────────────────────────────────────────────────
// Horizontal segmented progress bar showing current step in the service flow.

class _StepProgressBar extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i < currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
        }),
      ),
    );
  }
}
