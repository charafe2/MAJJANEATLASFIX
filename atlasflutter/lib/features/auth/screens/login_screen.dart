import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/auth_state.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _repo     = AuthRepository();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _errors   = <String, String>{};
  bool  _loading  = false;

  Future<void> _login() async {
    setState(() { _errors.clear(); _loading = true; });
    try {
      final r = await _repo.login(email: _email.text.trim(), password: _password.text);
      await SecureStorage.saveToken(r.token);
      await SecureStorage.saveUser(r.user.toJson());
      AuthState.instance.setLoggedIn(true, role: r.user.accountType);
      if (!mounted) return;
      context.go(r.user.accountType == 'client' ? '/client/dashboard' : '/artisan/dashboard');
    } on DioException catch (e) {
      setState(() => _errors.addAll(AuthRepository.parseErrors(e)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: Column(
          children: [
            // ── Scrollable top content ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    const AtlasFixLogo(),
                    const SizedBox(height: 28),

                    // Title — Figma: Poppins 500 28px #393939
                    const Text('Bienvenue à nouveau',
                      style: TextStyle(
                        fontFamily:  'Poppins',
                        fontSize:    28,
                        fontWeight:  FontWeight.w500,
                        color:       AppColors.dark,
                        letterSpacing: -0.45,
                      )),
                    const SizedBox(height: 44),

                    // Email input
                    PillInput(
                      label:       'Email',
                      controller:  _email,
                      keyboardType: TextInputType.emailAddress,
                      error:       _errors['email'],
                    ),
                    const SizedBox(height: 20),

                    // Password input
                    PillInput(
                      label:      'Mot de passe',
                      controller: _password,
                      isPassword: true,
                      error:      _errors['password'],
                    ),
                    const SizedBox(height: 12),

                    // Forgot password — Figma: center, Public Sans 500 10px underline
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: const Text('Mot de passe oublié ?',
                          style: TextStyle(
                            fontFamily:     'Public Sans',
                            fontWeight:     FontWeight.w500,
                            fontSize:       10,
                            color:          Colors.black,
                            decoration:     TextDecoration.underline,
                            decorationColor: Colors.black,
                          )),
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (_errors['general'] != null) ...[
                      ErrBanner(_errors['general']!),
                      const SizedBox(height: 12),
                    ],

                    // Login button
                    OrangeBtn(label: 'Login', onPressed: _login, loading: _loading),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── White bottom card ────────────────────────────────
            // Figma: border-radius 40px 40px 0 0, white bg
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.fromLTRB(33, 30, 33, 32),
              decoration: const BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(children: [
                // S'inscrire avec l'application — dark pill
                DarkBtn(
                  label:    "S'inscrire avec l'application",
                  leading:  const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 22),
                  onPressed: () => context.push('/choose-profile'),
                ),
                const SizedBox(height: 14),

                // Gmail
                WhiteBtn(
                  label:   'Se connecter avec Gmail',
                  logo:    _SocialCircle(label: 'G', color: const Color(0xFFEA4335)),
                  onPressed: () {},
                ),
                const SizedBox(height: 14),

                // Facebook
                WhiteBtn(
                  label:   'Se connecter avec Facebook',
                  logo:    _SocialCircle(label: 'f', color: const Color(0xFF1877F2)),
                  onPressed: () {},
                ),
                const SizedBox(height: 22),

                // Footer link
                FooterLink(
                  prefix: 'Je nais pas un compte ?  ',
                  link:   "S'inscrire",
                  onTap:  () => context.push('/choose-profile'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final String label;
  final Color  color;
  const _SocialCircle({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 12,
    backgroundColor: color,
    child: Text(label,
      style: const TextStyle(
        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
  );
}