import 'package:flutter/material.dart';

/// Menyimpan mode tema aktif (light/dark) secara global.
/// Didengarkan oleh MaterialApp lewat ValueListenableBuilder di main.dart.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

void toggleThemeMode() {
  themeModeNotifier.value =
      themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}
