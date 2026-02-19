import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/auth_widgets.dart';

class VerifyScreen extends StatefulWidget {
  final int    userId;
  final String accountType;
  final String verificationMethod; // 'email' | 'phone'

  const VerifyScreen({
    super.key,
    required this.userId,
    required this.accountType,
    required this.verificationMethod,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _repo     = AuthRepository();
  final _ctrls    = List.generate(4, (_) => TextEditingController());
  final _nodes    = List.generate(4, (_) => FocusNode());
  bool  _loading  = false;
  bool  _resending = false;
  String? _error;
  int   _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nodes[0].requestFocus());
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown = (_countdown - 1).clamp(0, 60));
      return _countdown > 0;
    });
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 4) {
      setState(() => _error = 'Entrez les 4 chiffres');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _repo.verifyCode(userId: widget.userId, code: _code);
      if (!mounted) return;
      context.go(widget.accountType == 'client' ? '/client/dashboard' : '/artisan/dashboard');
    } on DioException catch (e) {
      final errs = AuthRepository.parseErrors(e);
      setState(() => _error = errs['general'] ?? errs['code'] ?? 'Code invalide');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_countdown > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      await _repo.resendCode(widget.userId);
      setState(() => _countdown = 60);
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nouveau code envoyé ✓')));
      }
    } catch (_) {
      setState(() => _error = 'Impossible de renvoyer le code');
    } finally {
      setState(() => _resending = false);
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final f in _nodes)  f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Figma shows two variants:
    // Variant A (email): shows email field + phone field, label = "Vérification du compte"
    // Variant B (after entering): shows "Entrez le code de vérification" + big OTP boxes
    // We unify: show "Entrez le code de vérification" title, OTP boxes, then the contact field

    final isEmail = widget.verificationMethod == 'email';

    return Scaffold(
      body: GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AtlasFixLogo(),
              const SizedBox(height: 28),

              // Title — Figma: Poppins 28px varies
              const Text('Entrez le code de\nvérification',
                style: TextStyle(
                  fontFamily:  'Poppins',
                  fontSize:    28,
                  fontWeight:  FontWeight.w500,
                  color:       AppColors.dark,
                  letterSpacing: -0.45,
                  height: 1.3,
                )),
              const SizedBox(height: 36),

              // ── 4 OTP boxes ───────────────────────────────────────
              // Figma: large digits "0 2 3 4" style boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) => _OtpBox(
                  controller: _ctrls[i],
                  focusNode:  _nodes[i],
                  hasError:   _error != null,
                  onChanged:  (v) {
                    setState(() {});
                    if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
                    if (v.isEmpty   && i > 0)  _nodes[i - 1].requestFocus();
                    if (_code.length == 4)     _verify();
                  },
                )),
              ),
              const SizedBox(height: 28),

              // Contact field below boxes (Figma shows email or phone input)
              PillInput(
                label:       isEmail ? 'Email@gmail.com' : '06 xx xx xx xx',
                controller:  TextEditingController(),
                icon:        isEmail ? Icons.email_outlined : Icons.phone_outlined,
                readOnly:    true,
              ),
              const SizedBox(height: 20),

              // Renvoyer link
              Center(
                child: GestureDetector(
                  onTap: _resend,
                  child: _resending
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                    : RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: _countdown > 0
                                ? 'Renvoyer dans ${_countdown}s'
                                : 'Renvoyer',
                              style: TextStyle(
                                color:      _countdown > 0
                                  ? Colors.black.withOpacity(0.5)
                                  : AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrBanner(_error!),
              ],
              const SizedBox(height: 32),

              OrangeBtn(label: 'Suivant', onPressed: _verify, loading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OTP digit box ─────────────────────────────────────────────────────────────
// Figma: large "0 2 3 4" bold digits in plain boxes
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  hasError;
  final void Function(String) onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  64,
      height: 72,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
            ? AppColors.error
            : controller.text.isNotEmpty
              ? AppColors.primary
              : AppColors.lightGrey,
          width: controller.text.isNotEmpty ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller:  controller,
        focusNode:   focusNode,
        textAlign:   TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength:   1,
        onChanged:   onChanged,
        style: const TextStyle(
          fontFamily:  'Poppins',
          fontSize:    28,
          fontWeight:  FontWeight.w700,
          color:       AppColors.dark,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border:       InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}