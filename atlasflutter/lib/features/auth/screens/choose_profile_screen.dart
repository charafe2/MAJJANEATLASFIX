import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';

class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});
  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  String? _choice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              const AtlasFixLogo(),
              const SizedBox(height: 28),
              const Text('Choisissez votre profil',
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 28,
                  fontWeight: FontWeight.w500, color: AppColors.dark,
                  letterSpacing: -0.45,
                )),
              const SizedBox(height: 28),

              _ProfileCard(
                icon:     Icons.person_outline_rounded,
                title:    'Je suis un Client',
                subtitle: 'Trouvez des artisans qualifiés pour tous vos projets de rénovation et d\'installation',
                selected: _choice == 'client',
                onTap:    () => setState(() => _choice = 'client'),
              ),
              const SizedBox(height: 16),

              _ProfileCard(
                icon:     Icons.build_outlined,
                title:    'Je suis un Artisan',
                subtitle: 'Développez votre activité et trouvez de nouveaux clients en rejoignant notre plateforme',
                selected: _choice == 'artisan',
                onTap:    () => setState(() => _choice = 'artisan'),
              ),

              const Spacer(),

              OrangeBtn(
                label: 'Suivant',
                // Passes account_type into the data map from the very first step
                onPressed: _choice == null ? null : () => context.push(
                  '/register/basic',
                  extra: {'account_type': _choice},
                ),
              ),
              const SizedBox(height: 20),

              FooterLink(
                prefix: "j'ai un compte ?  ",
                link:   'Connexion',
                onTap:  () => context.go('/login'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  final bool selected; final VoidCallback onTap;
  const _ProfileCard({required this.icon, required this.title,
    required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontFamily: 'Public Sans',
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontFamily: 'Public Sans',
            fontSize: 12, color: AppColors.grey, height: 1.4)),
        ])),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightGrey, width: 2),
          ),
          child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
            : null,
        ),
      ]),
    ),
  );
}