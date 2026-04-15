import 'package:flutter/material.dart';

class AppPalette {
  static const Color forest = Color(0xFF45624E);
  static const Color forestDark = Color(0xFF31483A);
  static const Color moss = Color(0xFF7D9B76);
  static const Color sage = Color(0xFFEAF1E6);
  static const Color olive = Color(0xFF99AF89);
  static const Color clay = Color(0xFFA28263);
  static const Color sand = Color(0xFFF5F1EB);
  static const Color textPrimary = Color(0xFF213126);
  static const Color textSecondary = Color(0xFF6B756E);
  static const Color border = Color(0xFFD9E1D7);
  static const Color surface = Colors.white;
  static const Color warning = Color(0xFFD88A2A);
  static const Color danger = Color(0xFFCC5A5A);
  static const Color info = Color(0xFF5C8D89);
  static const Color gold = Color(0xFFFFC64C);
  static const Color lightGreenAvatar = Color(0xFFB6D4A8);
}

extension HexColorParser on String {
  Color toColor() {
    final buffer = StringBuffer();
    if (replaceAll('#', '').length == 6) {
      buffer.write('ff');
    }
    buffer.write(replaceAll('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.forest,
          primary: AppPalette.forest,
          secondary: AppPalette.clay,
          surface: AppPalette.surface,
        ),
        scaffoldBackgroundColor: AppPalette.sand,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppPalette.border),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppPalette.sage,
          elevation: 6,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppPalette.forest : AppPalette.textSecondary,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppPalette.forest, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppPalette.danger),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: AppPalette.forest,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppPalette.border),
          ),
          side: const BorderSide(color: AppPalette.border),
          labelStyle: const TextStyle(color: AppPalette.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.forest,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.forest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            side: const BorderSide(color: AppPalette.forest),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppPalette.forestDark,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
