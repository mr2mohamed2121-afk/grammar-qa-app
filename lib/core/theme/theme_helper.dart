import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مساعد الثيم - Light/Dark Theme متقدم
class ThemeHelper {
  // ==================== Colors ====================
  
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryGoldLight = Color(0xFFF4E4BC);
  static const Color primaryGoldDark = Color(0xFF8B6914);
  
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2A2A2A);
  
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFFFFFFF);

  // ==================== Dark Theme ====================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: Colors.black,
        secondary: primaryGold,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: Colors.white,
        background: darkBackground,
        onBackground: Colors.white,
        error: Color(0xFFE94560),
        onError: Colors.white,
        outline: primaryGold,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE94560)),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIconColor: primaryGold,
        suffixIconColor: primaryGold,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF0D0D0D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryGold,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGold,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryGold;
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGold.withOpacity(0.5);
          }
          return Colors.grey[700];
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryGold;
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.black),
        side: const BorderSide(color: Colors.white54),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryGold;
          return Colors.white54;
        }),
      ),
    );
  }

  // ==================== Light Theme ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryGoldDark,
        onPrimary: Colors.white,
        secondary: primaryGold,
        onSecondary: Colors.black,
        surface: lightSurface,
        onSurface: Colors.black87,
        background: lightBackground,
        onBackground: Colors.black87,
        error: Color(0xFFE94560),
        onError: Colors.white,
        outline: primaryGoldDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGoldDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGoldDark, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  // ==================== Helpers ====================

  /// التحقق من الوضع الحالي
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// لون النص حسب الوضع
  static Color textColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black87;
  }

  /// لون الخلفية حسب الوضع
  static Color backgroundColor(BuildContext context) {
    return isDarkMode(context) ? darkBackground : lightBackground;
  }

  /// لون السطح حسب الوضع
  static Color surfaceColor(BuildContext context) {
    return isDarkMode(context) ? darkSurface : lightSurface;
  }

  /// لون البطاقة حسب الوضع
  static Color cardColor(BuildContext context) {
    return isDarkMode(context) ? darkCard : lightCard;
  }

  /// تدرج ذهبي
  static LinearGradient goldGradient = const LinearGradient(
    colors: [primaryGold, primaryGoldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج داكن
  static LinearGradient darkGradient = const LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}