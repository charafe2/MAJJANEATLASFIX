import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/auth_widgets.dart';

/// FINAL STEP – "Sécurisez votre compte"
/// No dart:io imports — uses XFile throughout so it works on web + mobile.
class PasswordScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const PasswordScreen({super.key, required this.data});
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _repo     = AuthRepository();
  final _password = TextEditingController();
  final _confirm  = TextEditingController();
  final _errors   = <String, String>{};
  bool  _loading  = false;

  bool _validate() {
    _errors.clear();
    if (_password.text.length < 8)
      _errors['password'] = 'Min 8 caractères';
    if (_password.text != _confirm.text)
      _errors['confirm'] = 'Les mots de passe ne correspondent pas';
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() { _errors.clear(); _loading = true; });

    final d           = widget.data;
    final accountType = d['account_type'] as String? ?? 'client';
    final userId      = (d['user_id'] as num).toInt();

    try {
      if (accountType == 'client') {
        final r = await _repo.completeClient(
          userId:               userId,
          password:             _password.text,
          passwordConfirmation: _confirm.text,
          city:                 d['city']    as String,
          address:              d['address'] as String,
        );
        await SecureStorage.saveToken(r.token);
        await SecureStorage.saveUser(r.user.toJson());
        if (!mounted) return;
        context.go('/client/dashboard');

      } else {
        // ── XFile — no dart:io, works on web + mobile ───────────
        final diploma    = d['diploma_xfile'] as XFile;
        final photoFiles = (d['photo_xfiles'] as List<dynamic>).cast<XFile>();

        final r = await _repo.completeArtisan(
          userId:               userId,
          password:             _password.text,
          passwordConfirmation: _confirm.text,
          service:              d['service']      as String,
          serviceType:          d['service_type'] as String,
          city:                 d['city']         as String,
          address:              d['address']      as String,
          bio:                  d['bio']          as String,
          diploma:              diploma,
          photos:               photoFiles,
        );
        await SecureStorage.saveToken(r.token);
        await SecureStorage.saveUser(r.user.toJson());
        if (!mounted) return;
        context.go('/register/tier', extra: {
          'user_id':      r.userId,
          'account_type': 'artisan',
        });
      }

    } on DioException catch (e) {
      setState(() => _errors.addAll(AuthRepository.parseErrors(e)));
    } catch (e) {
      setState(() => _errors['general'] = 'Erreur inattendue: $e');
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
              const AuthTitle(title: 'Sécurisez votre compte'),
              const SizedBox(height: 32),

              PillInput(
                label:      'Créer un mot de passe',
                controller: _password,
                isPassword: true,
                error:      _errors['password'],
              ),
              const SizedBox(height: 16),

              PillInput(
                label:      'Confirmer le mot de passe',
                controller: _confirm,
                isPassword: true,
                error:      _errors['confirm'],
              ),

              if (_errors['general'] != null) ...[
                const SizedBox(height: 14),
                ErrBanner(_errors['general']!),
              ],
              const SizedBox(height: 32),

              NavRow(
                showPrev:  true,
                nextLabel: 'Créer',
                loading:   _loading,
                onPrev:    () => context.pop(),
                onNext:    _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _password.dispose(); _confirm.dispose(); super.dispose(); }
}