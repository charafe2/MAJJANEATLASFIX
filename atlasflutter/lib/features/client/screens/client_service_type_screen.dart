import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

// ── Service types per category ────────────────────────────────────────────────

const _kServiceTypes = <String, List<String>>{
  'Réparations générales': [
    'Montage TV',
    'Appareils',
    'Meubles / Réparation plats & terrasse',
    'Portes & fenêtres',
    'Arbres & clôture',
  ],
  'Plomberie': [
    'Fuite d\'eau',
    'Installation sanitaire',
    'Débouchage canalisation',
    'Chauffe-eau & ballon',
    'Robinetterie',
  ],
  'Électricité': [
    'Tableau électrique',
    'Prises & interrupteurs',
    'Éclairage',
    'Câblage & installation',
    'Dépannage urgence',
  ],
  'Peinture': [
    'Peinture intérieure',
    'Peinture extérieure',
    'Revêtement mural',
    'Enduit & crépi',
    'Décoration murale',
  ],
  'Technologie': [
    'Installation réseau',
    'Configuration PC',
    'Sécurité & caméras',
    'Domotique',
    'Antenne & TV',
  ],
  'Nettoyage': [
    'Nettoyage appartement',
    'Nettoyage bureau',
    'Nettoyage après travaux',
    'Désinfection',
    'Vitres & surfaces',
  ],
  'Déménagement': [
    'Déménagement local',
    'Déménagement longue distance',
    'Emballage & conditionnement',
    'Transport de meubles',
    'Stockage temporaire',
  ],
  'Chauffeur & Installation': [
    'Chauffeur privé',
    'Livraison express',
    'Transport médical',
    'Courses & commissions',
    'Accompagnement',
  ],
  'Mécanique totale': [
    'Révision & entretien',
    'Réparation moteur',
    'Changement de pneus',
    'Climatisation auto',
    'Électronique auto',
  ],
  'Vitrerie': [
    'Vitrage simple',
    'Double vitrage',
    'Miroirs',
    'Remplacement vitre',
    'Baie vitrée',
  ],
  'Assurance de Toiture': [
    'Réparation toiture',
    'Étanchéité',
    'Gouttières',
    'Isolation toiture',
    'Charpente',
  ],
  'Fitness & Sport': [
    'Coach sportif',
    'Yoga & pilates',
    'Musculation',
    'Arts martiaux',
    'Natation',
  ],
  'Photo': [
    'Mariage',
    'Portrait professionnel',
    'Événement',
    'Produits & publicité',
    'Photo d\'intérieur',
  ],
  'Vidéo': [
    'Clip vidéo',
    'Film d\'entreprise',
    'Mariage & événement',
    'Drone & aérien',
    'Montage vidéo',
  ],
  'Mesure & Livraison': [
    'Métreur',
    'Livraison rapide',
    'Livraison programmée',
    'Transport spécialisé',
    'Coursier moto',
  ],
  'Beauté & Style': [
    'Coiffure à domicile',
    'Maquillage',
    'Soins esthétiques',
    'Manucure & pédicure',
    'Massage bien-être',
  ],
  'Service de Restauration': [
    'Traiteur événementiel',
    'Chef à domicile',
    'Livraison repas',
    'Pâtisserie & gâteaux',
    'Service de bar',
  ],
  'Organisation d\'évènements': [
    'Mariage',
    'Anniversaire',
    'Conférence & séminaire',
    'Soirée d\'entreprise',
    'Décoration & scénographie',
  ],
  'Location de Matériel': [
    'Outillage',
    'Échafaudage',
    'Matériel audiovisuel',
    'Mobilier événementiel',
    'Matériel de chantier',
  ],
  'Réparations Ordinateur': [
    'Réparation écran',
    'Changement batterie',
    'Virus & logiciels',
    'Récupération données',
    'Mise à niveau',
  ],
  'Impression': [
    'Impression numérique',
    'Sérigraphie',
    'Cartes de visite',
    'Banderoles & affiches',
    'Impression textile',
  ],
  'Construction Manuel': [
    'Maçonnerie',
    'Carrelage & faïence',
    'Faux plafond',
    'Parquet & stratifié',
    'Isolation thermique',
  ],
  'Support Technique': [
    'Assistance à distance',
    'Installation logiciels',
    'Sauvegarde & sécurité',
    'Formation informatique',
    'Maintenance préventive',
  ],
  'Appareils & Énergie': [
    'Réparation électroménager',
    'Installation climatiseur',
    'Panneau solaire',
    'Chaudière & chauffage',
    'Réfrigération',
  ],
};

// ── Screen ────────────────────────────────────────────────────────────────────

class ClientServiceTypeScreen extends StatefulWidget {
  final String categoryName;
  const ClientServiceTypeScreen({super.key, required this.categoryName});

  @override
  State<ClientServiceTypeScreen> createState() =>
      _ClientServiceTypeScreenState();
}

class _ClientServiceTypeScreenState extends State<ClientServiceTypeScreen> {
  final Set<String> _selected = {};

  List<String> get _types {
    // Try exact match first, then partial
    final key = _kServiceTypes.keys.firstWhere(
      (k) => k.toLowerCase() == widget.categoryName.toLowerCase(),
      orElse: () => _kServiceTypes.keys.firstWhere(
        (k) => widget.categoryName
            .toLowerCase()
            .contains(k.toLowerCase().split(' ').first),
        orElse: () => _kServiceTypes.keys.first,
      ),
    );
    return _kServiceTypes[key] ?? [];
  }

  void _onContinue() {
    if (_selected.isEmpty) return;
    // Navigate to the new request/booking flow with selected services
    context.push('/client/nouvelle-demande', extra: {
      'category': widget.categoryName,
      'services': _selected.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final types = _types;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Warm gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              _buildHeader(context),

              // ── Service list ────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  itemCount: types.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final type = types[i];
                    final checked = _selected.contains(type);
                    return _ServiceTypeRow(
                      label: type,
                      checked: checked,
                      onTap: () => setState(() {
                        if (checked) {
                          _selected.remove(type);
                        } else {
                          _selected.add(type);
                        }
                      }),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Bottom action buttons ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
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
              // Back
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

              Text(widget.categoryName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                  )),
              const SizedBox(height: 4),
              const Text('Sélectionner un ou plusieurs services',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Colors.white70,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(children: [
        // Précédent
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Précédent',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.primary,
                  )),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Continuer
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _selected.isEmpty ? null : _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFD1D5DC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continuer',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Service type row ──────────────────────────────────────────────────────────

class _ServiceTypeRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _ServiceTypeRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: checked
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.white,
            border: Border.all(
              color: checked ? AppColors.primary : const Color(0xFFE5E7EB),
              width: checked ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: checked
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight:
                        checked ? FontWeight.w600 : FontWeight.w400,
                    color: checked
                        ? AppColors.primary
                        : const Color(0xFF314158),
                  )),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: checked ? AppColors.primary : const Color(0xFFD1D5DC),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ]),
        ),
      );
}
