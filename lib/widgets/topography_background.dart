import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Background pola garis topografi, otomatis nge-tint warnanya sesuai
/// tema aktif (light/dark) dan opacity-nya dibikin tipis supaya
/// gak ganggu keterbacaan konten di atasnya.
class TopographyBackground extends StatelessWidget {
  const TopographyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: context.colors.background,
        child: Opacity(
          opacity: context.colors.isDark ? 0.07 : 0.05,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn),
            child: Image.asset(
              'assets/background/topography.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }
}