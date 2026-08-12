import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color primaryLight = Color(0xFF7B9BF5);
  static const Color primaryDark = Color(0xFF2D46C4);

  static const Color secondaryColor = Color(0xFF7209B7);
  static const Color accentColor = Color(0xFFF72585);
  static const Color successColor = Color(0xFF06D6A0);
  static const Color warningColor = Color(0xFFFFB703);
  static const Color errorColor = Color(0xFFEF233C);

  // Neutral
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
  );

  // Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: Colors.white,
      background: grey50,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      scaffoldBackgroundColor: grey50,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: grey900,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: grey200,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        iconTheme: IconThemeData(color: grey700),
      ),

      // Card
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: grey200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grey200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: grey400,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        labelStyle: const TextStyle(
          color: grey500,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: grey100,
        selectedColor: primaryColor.withOpacity(0.15),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: grey200,
        thickness: 1,
        space: 1,
      ),

      // Text Theme
      textTheme: _textTheme(grey900),

      // Icon
      iconTheme: const IconThemeData(color: grey600, size: 24),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: secondaryColor,
      error: errorColor,
      surface: const Color(0xFF1E1E2E),
      background: const Color(0xFF12121A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF12121A),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      cardTheme: CardTheme(
        color: const Color(0xFF1E1E2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D2D3F), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D3F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D3D5C), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: grey500,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: _textTheme(Colors.white),
    );
  }

  static TextTheme _textTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
    );
  }
}
