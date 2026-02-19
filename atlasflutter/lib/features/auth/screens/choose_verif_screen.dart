import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/auth_widgets.dart';

/// STEP 2 – Choose verification method
/// ► Calls preRegister API here ◄
/// The backend creates the stub user and fires the OTP immediately.
/// On success we carry user_id forward to the OTP screen.
class ChooseVerifScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ChooseVerifScreen({super.key, required this.data});
  @override
  State<ChooseVerifScreen> createState() => _ChooseVerifScreenState();
}

class _ChooseVerifScreenState extends State<ChooseVerifScreen> {
  final _repo    = AuthRepository();
  String _method = 'email';
  bool   _loading = false;
  String? _error;

  Future<void> _next() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _repo.preRegister(
        accountType:        widget.data['account_type'] as String,
        fullName:           widget.data['full_name']    as String,
        birthDate:          widget.data['birth_date']   as String,
        email:              widget.data['email']        as String,
        phone:              widget.data['phone']        as String,
        verificationMethod: _method,
      );
      if (!mounted) return;
      // Carry user_id + chosen method forward; OTP screen needs both
      context.push('/register/otp', extra: {
        ...widget.data,
        'user_id':             result.userId,
        'verification_method': result.verificationMethod,
      });
    } on DioException catch (e) {
      setState(() => _error = AuthRepository.parseErrors(e)['general']
          ?? 'Une erreur est survenue');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.data['email'] as String? ?? '';
    final phone = widget.data['phone'] as String? ?? '';

    return Scaffold(
      body: GradientBg(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthTitle(title: 'Vérification du compte'),
              const SizedBox(height: 40),

              // Email row
              _VerifRow(
                icon:     Icons.email_outlined,
                label:    email.isNotEmpty ? email : 'Email',
                tag:      'EMAIL',
                selected: _method == 'email',
                onTap:    () => setState(() => _method = 'email'),
              ),
              const SizedBox(height: 20),

              // Phone row
              _VerifRow(
                icon:     Icons.phone_outlined,
                label:    phone.isNotEmpty ? phone : 'Téléphone',
                tag:      'TELEPHONE',
                selected: _method == 'phone',
                onTap:    () => setState(() => _method = 'phone'),
              ),

              if (_error != null) ...[
                const SizedBox(height: 20),
                ErrBanner(_error!),
              ],

              const Spacer(),

              OrangeBtn(label: 'Suivant', onPressed: _next, loading: _loading),
              const SizedBox(height: 20),
              FooterLink(
                prefix: 'J\'ai un compte ?  ',
                link:   'Connexion',
                onTap:  () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Verification option row (Image 1 exact) ───────────────────────────────────
class _VerifRow extends StatelessWidget {
  final IconData icon;
  final String   label, tag;
  final bool     selected;
  final VoidCallback onTap;
  const _VerifRow({required this.icon, required this.label, required this.tag,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color:        AppColors.inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label,
              style: TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
                color: selected ? AppColors.dark : AppColors.textHint,
              ))),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color:  selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.lightGrey,
                    width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                  : null,
              ),
            ),
          ]),
        ),
        // Orange tag chip at top-left (Figma)
        Positioned(
          top: -10, left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tag,
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 9,
                fontWeight: FontWeight.w700, color: Colors.white,
                letterSpacing: 0.5,
              )),
          ),
        ),
      ],
    ),
  );
}