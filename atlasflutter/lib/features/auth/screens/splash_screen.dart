import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../core/widgets/auth_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _decide();
  }

  Future<void> _decide() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final token = await SecureStorage.getToken();
    if (token != null) {
      final user = await SecureStorage.getUser();
      context.go(user?['account_type'] == 'artisan'
          ? '/artisan/dashboard' : '/client/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GradientBg(
      child: FadeTransition(
        opacity: _fade,
        child: const Center(child: AtlasFixLogo()),
      ),
    ),
  );
}