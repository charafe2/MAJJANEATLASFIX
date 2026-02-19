import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/auth_widgets.dart';

/// STEP 3 – OTP verification.
/// Calls POST /auth/verify → VerifyResult (userId + accountType only, no token).
/// Token comes later from completeRegister in password_screen.dart.
class OtpScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const OtpScreen({super.key, required this.data});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _repo      = AuthRepository();
  final _ctrls     = List.generate(4, (_) => TextEditingController());
  final _nodes     = List.generate(4, (_) => FocusNode());
  bool   _loading   = false;
  bool   _resending = false;
  String? _error;
  int    _countdown = 60;

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

  // Safe int cast — handles both int and num coming through the router extra map
  int get _userId => (widget.data['user_id'] as num).toInt();

  String get _code => _ctrls.map((c) => c.text).join();

  // Called from onChanged — uses addPostFrameCallback so the controller's
  // text is fully committed before we read _code (fixes the auto-submit bug
  // where the 4th digit wasn't in the controller yet when _code was read)
  void _onDigitChanged(String value, int index) {
    setState(() => _error = null);
    if (value.isNotEmpty && index < 3) {
      _nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    // Auto-submit after the frame so all controllers are updated
    if (value.isNotEmpty && index == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_code.length == 4) _verify();
      });
    }
  }

  Future<void> _verify() async {
    final code = _code;
    if (code.length < 4) {
      setState(() => _error = 'Entrez les 4 chiffres du code');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _repo.verifyCode(userId: _userId, code: code);
      if (!mounted) return;

      final next = {
        ...widget.data,
        'user_id':      result.userId,
        'account_type': result.accountType,
      };

      if (result.accountType == 'client') {
        context.push('/register/client-details', extra: next);
      } else {
        context.push('/register/artisan-pro', extra: next);
      }
    } on DioException catch (e) {
      final errs = AuthRepository.parseErrors(e);
      setState(() => _error = errs['general'] ?? errs['code'] ?? 'Code invalide');
    } catch (e) {
      // Catch-all — surfaces any unexpected error (cast errors, network, etc.)
      setState(() => _error = 'Erreur inattendue: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_countdown > 0 || _resending) return;
    setState(() { _resending = true; _error = null; });
    try {
      await _repo.resendCode(_userId);
      setState(() => _countdown = 60);
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nouveau code envoyé ✓')));
      }
    } on DioException catch (e) {
      setState(() => _error = AuthRepository.parseErrors(e)['general']);
    } catch (e) {
      setState(() => _error = 'Erreur inattendue: $e');
    } finally {
      setState(() => _resending = false);
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final f in _nodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.data['verification_method'] == 'email';
    final contact = isEmail
        ? (widget.data['email'] as String? ?? '')
        : (widget.data['phone'] as String? ?? '');

    return Scaffold(
      body: GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AtlasFixLogo(),
              const SizedBox(height: 28),
              const Text('Entrez le code de\nvérification',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 28,
                    fontWeight: FontWeight.w500, color: AppColors.dark,
                    height: 1.3,
                  )),
              const SizedBox(height: 8),
              Text(
                isEmail ? 'Code envoyé à $contact' : 'Code envoyé au $contact',
                style: const TextStyle(
                  fontFamily: 'Public Sans', fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 36),

              // ── 4 OTP boxes ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) => _OtpBox(
                  controller: _ctrls[i],
                  focusNode:  _nodes[i],
                  hasError:   _error != null,
                  onChanged:  (v) => _onDigitChanged(v, i),
                )),
              ),
              const SizedBox(height: 28),

              // Read-only contact pill
              PillInput(
                label:      contact.isNotEmpty ? contact : (isEmail ? 'Email' : 'Téléphone'),
                controller: TextEditingController(text: contact),
                icon:       isEmail ? Icons.email_outlined : Icons.phone_outlined,
                readOnly:   true,
              ),
              const SizedBox(height: 20),

              // Renvoyer countdown / link
              Center(
                child: GestureDetector(
                  onTap: _resend,
                  child: _resending
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                    : RichText(text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Public Sans', fontSize: 14),
                        children: [TextSpan(
                          text: _countdown > 0
                              ? 'Renvoyer dans ${_countdown}s'
                              : 'Renvoyer',
                          style: TextStyle(
                            color: _countdown > 0
                                ? Colors.black.withOpacity(0.45)
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        )],
                      )),
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

// ── Single OTP digit box ───────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  hasError;
  final void Function(String) onChanged;
  const _OtpBox({required this.controller, required this.focusNode,
    required this.hasError, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    width: 64, height: 72,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: hasError ? AppColors.error
            : controller.text.isNotEmpty ? AppColors.primary : AppColors.lightGrey,
        width: controller.text.isNotEmpty ? 2 : 1,
      ),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
          blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: TextField(
      controller:   controller,
      focusNode:    focusNode,
      textAlign:    TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength:    1,
      onChanged:    onChanged,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 28,
          fontWeight: FontWeight.w700, color: AppColors.dark),
      decoration: const InputDecoration(
        counterText: '', border: InputBorder.none,
        enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
    ),
  );
}