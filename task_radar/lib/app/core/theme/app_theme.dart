import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color green;
  final Color purple;
  final Color pink;
  final Color grayDark;
  final Color grayLight;
  final Color colorCardList;

  const AppColors({
    required this.green,
    required this.purple,
    required this.pink,
    required this.grayDark,
    required this.grayLight,
    required this.colorCardList,
  });

  @override
  AppColors copyWith({
    Color? green,
    Color? purple,
    Color? pink,
    Color? grayDark,
    Color? grayLight,
    Color? colorCardList,
  }) {
    return AppColors(
      green: green ?? this.green,
      purple: purple ?? this.purple,
      pink: pink ?? this.pink,
      grayDark: grayDark ?? this.grayDark,
      grayLight: grayLight ?? this.grayLight,
      colorCardList: colorCardList ?? this.colorCardList,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      green: Color.lerp(green, other.green, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      grayDark: Color.lerp(grayDark, other.grayDark, t)!,
      grayLight: Color.lerp(grayLight, other.grayLight, t)!,
      colorCardList: Color.lerp(colorCardList, other.colorCardList, t)!,
    );
  }

  static const dark = AppColors(
    green: Color(0xFF32D583),
    purple: Color(0xFF4F378B),
    pink: Color(0xFFF1DEDC),
    grayDark: Color(0xFF2B2930),
    grayLight: Color(0xFF4A4458),
    colorCardList: Color(0xFF121418),
  );

  static const light = AppColors(
    green: Color(0xFF32D583),
    purple: Color(0xFF6750A4),
    pink: Color(0xFFF1DEDC),
    grayDark: Color(0xFFE8E0F0),
    grayLight: Color(0xFFE8DEF8),
    colorCardList: Color(0xFFF3EDF7),
  );
}

extension AppColorsExtension on ThemeData {
  AppColors get appColors => extension<AppColors>() ?? AppColors.dark;
}

class AppTheme {
  AppTheme._();

  static const Color _primaryLight = Color(0xFF6750A4);
  static const Color _primaryDark = Color(0xFFD0BCFF);
  static const Color _backgroundDark = Color(0xFF0F0D13);
  static const Color _surfaceDark = Color(0xFF211F26);
  static const Color _backgroundLight = Color(0xFFFfffFF);
  static const Color _surfaceLight = Color(0xFFF3EDF7);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      extensions: const [AppColors.dark],
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: Colors.black,
        surface: _surfaceDark,
        onSurface: Colors.white,
        error: Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _backgroundDark,
        selectedItemColor: _primaryDark,
        unselectedItemColor: Colors.grey,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryDark;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        side: BorderSide(color: Colors.grey.shade600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
      extensions: const [AppColors.light],
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.black,
        surface: _surfaceLight,
        onSurface: Colors.black87,
        error: Color(0xFFB00020),
      ),
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundLight,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceLight,
        selectedItemColor: _primaryLight,
        unselectedItemColor: Colors.grey,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
