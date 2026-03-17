import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/netwrok/api_client.dart';
import '../../../core/widgets/atlas_logo.dart';
import 'artisan_home_screen.dart';

class ArtisanMyServicesScreen extends StatefulWidget {
  const ArtisanMyServicesScreen({super.key});
  @override
  State<ArtisanMyServicesScreen> createState() => _ArtisanMyServicesScreenState();
}

class _ArtisanMyServicesScreenState extends State<ArtisanMyServicesScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _boostPackages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/me'),
        ApiClient.instance.get('/artisan/boost/packages'),
      ]);
      final meData = (results[0].data['data'] ?? results[0].data) as Map<String, dynamic>;
      final pkgData = (results[1].data['data'] ?? results[1].data) as List<dynamic>;
      if (mounted) {
        setState(() {
          _services = (meData['services'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ?? [];
          _boostPackages = pkgData
              .map((e) => e as Map<String, dynamic>)
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showBoostSheet(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BoostSheet(
        packages: _boostPackages,
        serviceName: service['category'] as String? ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        children: [
                          // Title row
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Booster un service',
                                  style: TextStyle(fontFamily: 'Public Sans',
                                      fontWeight: FontWeight.w700, fontSize: 20,
                                      color: Color(0xFF191C24))),
                              ),
                              Icon(Icons.rocket_launch_outlined,
                                  color: AppColors.primary, size: 24),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Gorem ipsum dolor sit amet, consectetur adipiscing elit.',
                            style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                                color: Color(0xFF62748E), height: 1.4)),
                          const SizedBox(height: 20),

                          // Service list
                          ..._services.map((s) {
                            final isBoosted = s['is_boosted'] == true ||
                                (s['active_boost'] != null);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => _showBoostSheet(s),
                                child: _ServiceItem(
                                  category: s['category'] as String? ?? '',
                                  isBoosted: isBoosted,
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Cliquez sur un service pour modifier ses informations.\n'
                              'Les compétences, certifications et photos ci-dessous\n'
                              'sont liées au service actif.',
                              style: TextStyle(fontFamily: 'Public Sans', fontSize: 11,
                                  color: Color(0xFF9CA3AF), height: 1.5)),
                          ),
                          const SizedBox(height: 24),

                          // Add service button
                          SizedBox(
                            width: double.infinity, height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/artisan/add-service'),
                              icon: const Icon(Icons.add_circle_outline_rounded,
                                  color: Colors.white, size: 20),
                              label: const Text('Ajouter un service',
                                style: TextStyle(fontFamily: 'Public Sans',
                                    fontWeight: FontWeight.w600, fontSize: 14,
                                    color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ],
          ),

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 4)),
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
            children: [
              Row(children: [
                const AtlasLogo(),
                const Spacer(),
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
                const SizedBox(width: 10),
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xFF393C40), size: 20),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search_rounded, color: Color(0xFF393C40), size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Quelle service recherchez-vous ?',
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                          color: Color(0xFF494949)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Service item ────────────────────────────────────────────────────────────

class _ServiceItem extends StatelessWidget {
  final String category;
  final bool isBoosted;

  const _ServiceItem({required this.category, this.isBoosted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Storefront icon
          const Icon(Icons.storefront_outlined, color: Color(0xFF62748E), size: 22),
          const SizedBox(width: 12),
          // Category name
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(category,
                    style: const TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w500, fontSize: 15,
                        color: Color(0xFF314158)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (isBoosted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: AppColors.primary, size: 12),
                        const SizedBox(width: 2),
                        Text('Boosté',
                          style: TextStyle(fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600, fontSize: 11,
                              color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Trending icon
          Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

// ── Boost bottom sheet ──────────────────────────────────────────────────────

class _BoostSheet extends StatefulWidget {
  final List<Map<String, dynamic>> packages;
  final String serviceName;
  const _BoostSheet({required this.packages, this.serviceName = ''});

  @override
  State<_BoostSheet> createState() => _BoostSheetState();
}

class _BoostSheetState extends State<_BoostSheet> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
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
            children: [
              const Expanded(
                child: Text('Booster votre service',
                  style: TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700, fontSize: 22,
                      color: Color(0xFF191C24))),
              ),
              Icon(Icons.bolt_rounded, color: AppColors.primary, size: 26),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Qu'est-ce que le Boost ?",
            style: TextStyle(fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600, fontSize: 14,
                color: Color(0xFF314158))),
          const SizedBox(height: 6),
          const Text(
            'Le boost permet de placer votre service en tête des résultats '
            'de recherche pour attirer plus de clients. Votre service sera '
            'mis en avant avec un badge spécial.',
            style: TextStyle(fontFamily: 'Public Sans', fontSize: 12,
                color: Color(0xFF62748E), height: 1.5)),
          const SizedBox(height: 20),
          const Text('Choisissez un boost pour plus de visibilité',
            style: TextStyle(fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600, fontSize: 13,
                color: Color(0xFF314158))),
          const SizedBox(height: 14),

          ...widget.packages.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final selected = _selectedIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: _BoostOption(
                  name: p['name'] as String? ?? '',
                  price: (p['price'] as num?)?.toDouble() ?? 0,
                  selected: selected,
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _selectedIndex != null
                  ? () => Navigator.pop(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFFFD5C2),
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text('Suivant',
                style: TextStyle(fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoostOption extends StatelessWidget {
  final String name;
  final double price;
  final bool selected;
  const _BoostOption({
    required this.name,
    required this.price,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF7ED) : const Color(0xFFFFF9F6),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFFFD5C2),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFD08700), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: const TextStyle(
              fontFamily: 'Public Sans', fontWeight: FontWeight.w500,
              fontSize: 14, color: Color(0xFF314158))),
          ),
          Text('${price.toStringAsFixed(0)} MAD',
            style: const TextStyle(fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600, fontSize: 14,
                color: Color(0xFF314158))),
          const SizedBox(width: 10),
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFD1D5DC),
                width: 2,
              ),
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
        ],
      ),
    );
  }
}
