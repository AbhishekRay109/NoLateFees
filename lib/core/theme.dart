// NoLateFees look: an indigo → pink brand gradient, an orange accent, and one
// colour per category so lists are easy to scan.
import 'package:flutter/material.dart';

class Brand {
  static const indigo = Color(0xFF6366F1);
  static const pink = Color(0xFFEC4899);
  static const orange = Color(0xFFFB923C);
  static const violet = Color(0xFF8B5CF6);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, violet, pink],
  );

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF2FF), Color(0xFFFDF2F8)],
  );

  static const darkSoftGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF3B0A2A)],
  );
}

/// Colour for a category key ("vehicle.insurance", "custom:…").
Color categoryColor(String key) {
  if (key.startsWith('custom:')) return const Color(0xFF14B8A6);
  return switch (key.split('.').first) {
    'vehicle' => const Color(0xFF3B82F6),
    'insurance' => const Color(0xFF10B981),
    'mobile' => const Color(0xFF8B5CF6),
    'finance' => const Color(0xFFF59E0B),
    'documents' => const Color(0xFFEF4444),
    'subscriptions' => const Color(0xFFEC4899),
    'home' => const Color(0xFF06B6D4),
    _ => const Color(0xFF64748B),
  };
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.indigo,
    brightness: brightness,
    secondary: Brand.pink,
    tertiary: Brand.orange,
  );
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF0F0E1A) : const Color(0xFFF8F7FF),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? const Color(0xFF1C1A2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      filled: true,
      fillColor: dark ? const Color(0xFF1C1A2E) : Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Brand.pink,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
    chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Brand.indigo.withValues(alpha: 0.18),
      backgroundColor: dark ? const Color(0xFF16142A) : Colors.white,
    ),
  );
}
