import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // From Figma: background: linear-gradient(180deg, rgba(252,90,21,0) 31.46%, rgba(252,90,21,0.3) 81.92%), #FFFFFF
  static const Color primary    = Color(0xFFFC5A15);
  static const Color dark       = Color(0xFF393939);  // "Bienvenue à nouveau" title
  static const Color darkCard   = Color(0xFF393C40);  // "S'inscrire avec l'application" button
  static const Color grey       = Color(0xFF62748E);
  static const Color lightGrey  = Color(0xFFD1D5DC);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color inputBg    = Color(0x1AF5F8F9);  // rgba(245,248,249,0.1)
  static const Color error      = Color(0xFFDC2626);
  static const Color textHint   = Color(0x99000000);  // black 60%

  // Figma gradient: transparent orange → 30% orange, white base
  static const LinearGradient bgGradient = LinearGradient(
    begin:  Alignment.topCenter,
    end:    Alignment.bottomCenter,
    stops:  [0.3146, 0.8192],
    colors: [
      Color(0x00FC5A15), // 0% opacity at top
      Color(0x4DFC5A15), // 30% opacity at bottom
    ],
  );
}