import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../core/widgets/auth_widgets.dart';

/// ARTISAN FINAL STEP – "Choisissez votre abonnement"
/// Matches Figma image 2 screen 5: single "Basic" card, 0 MAD/Gratuit,
/// orange "Choisir Basic" CTA, feature list with checkmarks.
/// After choosing, saves token and navigates to artisan dashboard.
class TierScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const TierScreen({super.key, required this.data});

  @override
  State<TierScreen> createState() => _TierScreenState();
}

class _TierScreenState extends State<TierScreen> {
  String _selected = 'basic';
  bool   _loading  = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final token = widget.data['token'] as String?;
      if (token != null) await SecureStorage.saveToken(token);
      // TODO: call /api/auth/artisan/choose-tier when endpoint is re-enabled
      if (!mounted) return;
      context.go('/artisan/dashboard');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AtlasFixLogo(),
              const SizedBox(height: 8),

              // "Gratuit" orange chip at top-right of the title area (Figma)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Choisissez votre\nabonnement',
                    style: TextStyle(
                      fontFamily:  'Poppins',
                      fontSize:    26,
                      fontWeight:  FontWeight.w500,
                      color:       AppColors.dark,
                      height:      1.3,
                    )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color:        AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Gratuit',
                      style: TextStyle(
                        fontFamily:  'Public Sans',
                        fontWeight:  FontWeight.w700,
                        fontSize:    12,
                        color:       Colors.white,
                      )),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Pour démarrer votre activité',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize:   13,
                  color:      AppColors.grey,
                )),
              const SizedBox(height: 28),

              // ── Basic tier card ───────────────────────────────────
              _TierCard(
                name:     'Basic',
                price:    '0 MAD/Gratuit',
                selected: _selected == 'basic',
                features: const [
                  'Profil Artisan',
                  '5 demandes au mois',
                  'Mise en avant',
                  'Portfolio, jusqu\'à 3 photos',
                  'Badge vérification',
                  'Chat basé',
                  'SMS basé',
                  'Alertes automatique',
                ],
                onTap: () => setState(() => _selected = 'basic'),
                onChoose: _confirm,
                loading:  _loading,
              ),

              const SizedBox(height: 16),

              // ── Pro tier card (coming soon) ───────────────────────
              _TierCard(
                name:     'Pro',
                price:    '99 MAD/mois',
                selected: _selected == 'pro',
                features: const [
                  'Tout ce qui est dans Basic',
                  'Demandes illimitées',
                  'Priorité dans la recherche',
                  'Portfolio illimité',
                  'Badge Pro',
                  'Support prioritaire',
                ],
                onTap:    () => setState(() => _selected = 'pro'),
                onChoose: _confirm,
                loading:  _loading,
                comingSoon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tier card ─────────────────────────────────────────────────────────────────
class _TierCard extends StatelessWidget {
  final String       name;
  final String       price;
  final bool         selected;
  final List<String> features;
  final VoidCallback onTap;
  final VoidCallback onChoose;
  final bool         loading;
  final bool         comingSoon;

  const _TierCard({
    required this.name,     required this.price,
    required this.selected, required this.features,
    required this.onTap,    required this.onChoose,
    this.loading    = false,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: comingSoon ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightGrey,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: checkmark (if selected) + name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  if (selected) ...[
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(name,
                    style: TextStyle(
                      fontFamily:  'Poppins',
                      fontSize:    20,
                      fontWeight:  FontWeight.w700,
                      color:       selected ? AppColors.primary : AppColors.dark,
                    )),
                ]),
                if (comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Bientôt',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.grey)),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Price
            Text(price,
              style: const TextStyle(
                fontFamily:  'Public Sans',
                fontSize:    22,
                fontWeight:  FontWeight.w700,
                color:       AppColors.dark,
              )),
            const SizedBox(height: 16),

            // CTA button
            if (!comingSoon)
              OrangeBtn(
                label:    'Choisir $name',
                onPressed: onChoose,
                loading:  loading && selected,
              ),
            const SizedBox(height: 16),

            // Feature divider
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            const Text('Ce plan inclut :',
              style: TextStyle(
                fontFamily:  'Public Sans',
                fontSize:    12,
                fontWeight:  FontWeight.w600,
                color:       AppColors.grey,
              )),
            const SizedBox(height: 8),

            // Features list
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize:   12,
                    color:      AppColors.dark,
                  ))),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}