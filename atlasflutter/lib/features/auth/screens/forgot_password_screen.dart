import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _repo    = AuthRepository();
  final _value   = TextEditingController();
  String _method = 'email';
  bool   _loading = false;
  String? _error;

  // Reset step
  bool   _showReset = false;
  int?   _userId;
  final _code     = TextEditingController();
  final _password = TextEditingController();
  final _confirm  = TextEditingController();
  bool  _resetting = false;

  Future<void> _sendCode() async {
    setState(() { _loading = true; _error = null; });
    try {
      final id = await _repo.forgotPassword(
        method: _method, value: _value.text.trim());
      setState(() { _userId = id; _showReset = true; });
    } on DioException catch (e) {
      setState(() => _error = AuthRepository.parseErrors(e)['general']);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    setState(() { _resetting = true; _error = null; });
    try {
      await _repo.resetPassword(
        userId:               _userId!,
        code:                 _code.text.trim(),
        password:             _password.text,
        passwordConfirmation: _confirm.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe réinitialisé ✓')));
      context.go('/login');
    } on DioException catch (e) {
      setState(() => _error = AuthRepository.parseErrors(e)['general']);
    } finally {
      setState(() => _resetting = false);
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
              // Figma title: "Sécurisez votre compte"
              const AuthTitle(title: 'Sécurisez votre compte'),
              const SizedBox(height: 32),

              if (!_showReset) ...[
                // Method toggle
                _VerifRow(selected: _method, onChanged: (v) => setState(() => _method = v)),
                const SizedBox(height: 20),
                PillInput(
                  label:       _method == 'email' ? 'Email' : 'Téléphone',
                  controller:  _value,
                  icon:        _method == 'email' ? Icons.email_outlined : Icons.phone_outlined,
                  keyboardType: _method == 'email'
                    ? TextInputType.emailAddress : TextInputType.phone,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  ErrBanner(_error!),
                ],
                const SizedBox(height: 28),
                OrangeBtn(label: 'Envoyer le code', onPressed: _sendCode, loading: _loading),

              ] else ...[
                // Figma image 1 screen 5: two password fields + "Créer" button
                PillInput(
                  label:      'Entrez le code reçu',
                  controller: _code,
                  icon:       Icons.key_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                PillInput(
                  label:      'Entrer un mot de passe',
                  controller: _password,
                  isPassword: true,
                ),
                const SizedBox(height: 14),
                PillInput(
                  label:      'Confirme le mot de passe',
                  controller: _confirm,
                  isPassword: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  ErrBanner(_error!),
                ],
                const SizedBox(height: 28),
                // Figma button label: "Créer"
                OrangeBtn(label: 'Créer', onPressed: _reset, loading: _resetting),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _VerifRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    _Chip(label: 'SMS',   value: 'phone', selected: selected, onChanged: onChanged),
    const SizedBox(width: 10),
    _Chip(label: 'Email', value: 'email', selected: selected, onChanged: onChanged),
  ]);
}

class _Chip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onChanged;
  const _Chip({required this.label, required this.value,
    required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final on = value == selected;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color:        on ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: AppColors.primary),
        ),
        child: Text(label,
          style: TextStyle(
            fontFamily: 'Public Sans', fontWeight: FontWeight.w600, fontSize: 13,
            color: on ? Colors.white : AppColors.primary,
          )),
      ),
    );
  }
}