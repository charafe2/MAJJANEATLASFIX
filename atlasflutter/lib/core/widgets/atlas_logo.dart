import 'package:flutter/material.dart';

class AtlasLogo extends StatelessWidget {
  final Color color;
  final double height;
  const AtlasLogo({super.key, this.color = Colors.white, this.height = 36});

  @override
  Widget build(BuildContext context) => ColorFiltered(
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    child: Image.asset(
      'assets/images/Atlaslogo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  );
}
