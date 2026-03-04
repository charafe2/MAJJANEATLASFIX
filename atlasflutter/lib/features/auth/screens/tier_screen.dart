import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../core/widgets/auth_widgets.dart';

/// ARTISAN REGISTRATION – "Choisissez votre abonnement"
/// 4 horizontally scrollable plan cards: Basic, Pro, Premium, Business.
class TierScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const TierScreen({super.key, required this.data});

  @override
  State<TierScreen> createState() => _TierScreenState();
}

class _TierScreenState extends State<TierScreen> {
  String _billing  = 'annual';
  String _selected = 'basic';
  bool   _loading  = false;

  Future<void> _choosePlan(String plan) async {
    setState(() { _loading = true; _selected = plan; });
    try {
      final token = widget.data['token'] as String?;
      if (token != null) await SecureStorage.saveToken(token);
      // TODO: POST /api/auth/artisan/choose-tier when endpoint is ready
      if (!mounted) return;
      context.go('/artisan/dashboard');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasFixLogo(),
                    const SizedBox(height: 22),
                    const Text(
                      'Choisissez votre\nabonnement',
                      style: TextStyle(
                        fontFamily:  'Poppins',
                        fontSize:    26,
                        fontWeight:  FontWeight.w500,
                        color:       AppColors.dark,
                        height:      1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Développez votre activité avec nos plans adaptés',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize:   13,
                        color:      AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _BillingToggle(
                      value:    _billing,
                      onToggle: (v) => setState(() => _billing = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Horizontal card scroll ──────────────────────────────
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  children: [
                    _PlanCard(
                      name: 'Basic',
                      desc: 'Pour démarrer votre activité',
                      monthlyPrice: 0,
                      billing: _billing,
                      iconGrad: const LinearGradient(
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                        colors: [Color(0xFF6A7282), Color(0xFF4A5565)],
                      ),
                      iconData:    Icons.shield_outlined,
                      btnGrad: const LinearGradient(
                        colors: [Color(0xFF6A7282), Color(0xFF4A5565)],
                      ),
                      borderColor: const Color(0xFFD1D5DC),
                      featYes: const [
                        'Profil de base',
                        'Jusqu\'à 5 demandes/mois',
                        'Portfolio 3 photos',
                        'Badge vérifié',
                        'Support standard',
                      ],
                      featNo: const [
                        'Statistiques',
                        'Support prioritaire',
                        'Réponse automatique',
                      ],
                      onChoose: () => _choosePlan('basic'),
                      loading:  _loading && _selected == 'basic',
                    ),
                    const SizedBox(width: 14),
                    _PlanCard(
                      name: 'Pro',
                      desc: 'Pour les artisans indépendants',
                      monthlyPrice: 30,
                      billing: _billing,
                      iconGrad: const LinearGradient(
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                        colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                      ),
                      iconData:    Icons.trending_up_rounded,
                      btnGrad: const LinearGradient(
                        colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                      ),
                      borderColor: AppColors.primary,
                      hasShadow:   true,
                      featYes: const [
                        'Profil vérifié & badge Pro',
                        'Jusqu\'à 20 demandes/mois',
                        'Portfolio 10 photos',
                        'Statistiques de base',
                        'Support prioritaire',
                        'Visibilité locale améliorée',
                      ],
                      featNo: const [
                        'Réponse automatique',
                        'Publicité ciblée',
                      ],
                      onChoose: () => _choosePlan('pro'),
                      loading:  _loading && _selected == 'pro',
                    ),
                    const SizedBox(width: 14),
                    _PlanCard(
                      name: 'Premium',
                      desc: 'Le choix des professionnels',
                      monthlyPrice: 75,
                      billing: _billing,
                      iconGrad: const LinearGradient(
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFFE04A0F)],
                      ),
                      iconData:    Icons.star_rounded,
                      btnGrad: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFFE04A0F)],
                      ),
                      borderColor: AppColors.primary,
                      popular:     true,
                      featYes: const [
                        'Tout du plan Pro',
                        'Demandes illimitées',
                        'Portfolio 50 photos',
                        'Statistiques avancées',
                        'Support 24/7',
                        'Réponse automatique',
                        'Visibilité nationale',
                      ],
                      featNo: const [
                        'Gestionnaire dédié',
                      ],
                      onChoose: () => _choosePlan('premium'),
                      loading:  _loading && _selected == 'premium',
                    ),
                    const SizedBox(width: 14),
                    _PlanCard(
                      name: 'Business',
                      desc: 'Pour les entreprises & équipes',
                      monthlyPrice: 250,
                      billing: _billing,
                      iconGrad: const LinearGradient(
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                        colors: [Color(0xFF9810FA), Color(0xFF8200DB)],
                      ),
                      iconData:    Icons.business_center_rounded,
                      btnGrad: const LinearGradient(
                        colors: [Color(0xFF9810FA), Color(0xFF8200DB)],
                      ),
                      borderColor: const Color(0xFF8804E3),
                      hasShadow:   true,
                      featYes: const [
                        'Tout du plan Premium',
                        'Multi-utilisateurs (10)',
                        'Portfolio illimité',
                        'Publicité ciblée',
                        'Gestionnaire dédié',
                        'Badge Business exclusif',
                      ],
                      featNo: const [],
                      onChoose: () => _choosePlan('business'),
                      loading:  _loading && _selected == 'business',
                    ),
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

// ── Billing toggle pill ────────────────────────────────────────────────────────
class _BillingToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onToggle;
  const _BillingToggle({required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        border:       Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill('Mensuel', 'monthly'),
          const SizedBox(width: 2),
          _pill('Annuel', 'annual', badge: '-20%'),
        ],
      ),
    );
  }

  Widget _pill(String label, String val, {String? badge}) {
    final active = value == val;
    return GestureDetector(
      onTap: () => onToggle(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color:        active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
              style: TextStyle(
                fontFamily:  'Public Sans',
                fontSize:    13,
                fontWeight:  FontWeight.w600,
                color:       active ? Colors.white : AppColors.grey,
              )),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFFFA782),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(badge,
                  style: const TextStyle(
                    fontSize:   10,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Plan card ──────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final String         name;
  final String         desc;
  final int            monthlyPrice;
  final String         billing;
  final LinearGradient iconGrad;
  final IconData       iconData;
  final LinearGradient btnGrad;
  final Color          borderColor;
  final bool           popular;
  final bool           hasShadow;
  final List<String>   featYes;
  final List<String>   featNo;
  final VoidCallback   onChoose;
  final bool           loading;

  const _PlanCard({
    required this.name,         required this.desc,
    required this.monthlyPrice, required this.billing,
    required this.iconGrad,     required this.iconData,
    required this.btnGrad,      required this.borderColor,
    this.popular   = false,
    this.hasShadow = false,
    required this.featYes,      required this.featNo,
    required this.onChoose,     required this.loading,
  });

  int get _displayPrice {
    if (monthlyPrice == 0) return 0;
    return billing == 'annual' ? (monthlyPrice * 0.8).round() : monthlyPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Card container ───────────────────────────────────────────
        Container(
          width: 253,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: borderColor, width: 2),
            boxShadow: popular
                ? [BoxShadow(
                    color:        AppColors.primary.withValues(alpha: 0.35),
                    blurRadius:   14,
                    spreadRadius: 1,
                  )]
                : hasShadow
                    ? [BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                      )]
                    : null,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon badge
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient:     iconGrad,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconData, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),

                // Plan name
                Text(name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   22,
                    fontWeight: FontWeight.w500,
                    color:      Color(0xFF314158),
                  )),
                const SizedBox(height: 4),

                // Description
                Text(desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize:   12,
                    color:      AppColors.grey,
                  )),
                const SizedBox(height: 14),

                // Price
                Row(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline:       TextBaseline.alphabetic,
                  children: [
                    Text(
                      monthlyPrice == 0 ? '0' : '$_displayPrice',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize:   40,
                        fontWeight: FontWeight.w400,
                        color:      Color(0xFF314158),
                        height:     1,
                      )),
                    const SizedBox(width: 5),
                    Text(
                      monthlyPrice == 0 ? 'MAD/Gratuit' : 'MAD/mois',
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize:   15,
                        color:      AppColors.grey,
                      )),
                  ],
                ),
                const SizedBox(height: 16),

                // CTA button
                SizedBox(
                  width:  double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient:     btnGrad,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: loading ? null : onChoose,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                      child: loading
                          ? const SizedBox(
                              width:  20, height: 20,
                              child:  CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                          : Text('Choisir $name',
                              style: const TextStyle(
                                fontFamily:  'Public Sans',
                                fontSize:    14,
                                fontWeight:  FontWeight.w600,
                                color:       Colors.white,
                              )),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Features section
                const Divider(color: Color(0xFFE5E7EB), height: 1),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Ce plan inclut :',
                    style: TextStyle(
                      fontFamily:  'Public Sans',
                      fontSize:    12,
                      fontWeight:  FontWeight.w600,
                      color:       AppColors.primary,
                    )),
                ),
                const SizedBox(height: 8),
                ...featYes.map((f) => _FeatRow(text: f, yes: true)),
                ...featNo.map((f) => _FeatRow(text: f, yes: false)),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),

        // ── "Plus populaire" badge ───────────────────────────────────
        if (popular)
          Positioned(
            top: -14,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFE04A0F)]),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(
                    color:      Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset:     const Offset(0, 4),
                  )],
                ),
                child: const Text('⭐ Plus populaire',
                  style: TextStyle(
                    fontFamily:  'Public Sans',
                    fontSize:    12,
                    fontWeight:  FontWeight.w600,
                    color:       Colors.white,
                  )),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Feature row ───────────────────────────────────────────────────────────────
class _FeatRow extends StatelessWidget {
  final String text;
  final bool   yes;
  const _FeatRow({required this.text, required this.yes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color:  yes ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              shape:  BoxShape.circle,
            ),
            child: Icon(
              yes ? Icons.check_rounded : Icons.close_rounded,
              size:  11,
              color: yes ? const Color(0xFF00A63E) : const Color(0xFF99A1AF),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize:   12,
                color:      yes ? const Color(0xFF314158) : AppColors.grey,
              )),
          ),
        ],
      ),
    );
  }
}
