import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './core/netwrok/api_client.dart';
import './core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.dark,
  ));
  ApiClient.init();
  runApp(const AtlasFixApp());
}

class AtlasFixApp extends StatelessWidget {
  const AtlasFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                    'AtlasFix',
      debugShowCheckedModeBanner: false,
      routerConfig:             appRouter,
      theme: ThemeData(
        useMaterial3:        true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor:  const Color(0xFFFC5A15),
          brightness: Brightness.light,
        ),
        // Remove default input borders — our widgets handle their own styling
        inputDecorationTheme: const InputDecorationTheme(
          border:             InputBorder.none,
          enabledBorder:      InputBorder.none,
          focusedBorder:      InputBorder.none,
          errorBorder:        InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        // Remove AppBar shadow
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation:       0,
          centerTitle:     true,
        ),
        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
              ? const Color(0xFFFC5A15) : null),
        ),
      ),
    );
  }
}