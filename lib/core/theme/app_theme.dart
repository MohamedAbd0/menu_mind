import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      chipTheme: _chipTheme,
      floatingActionButtonTheme: _fabTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarThemeDark,
      cardTheme: _cardThemeDark,
      elevatedButtonTheme: _elevatedButtonTheme,
      chipTheme: _chipThemeDark,
      floatingActionButtonTheme: _fabTheme,
      inputDecorationTheme: _inputDecorationThemeDark,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: AppConstants.titleTextSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: AppConstants.subtitleTextSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: AppConstants.bodyTextSize,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: AppConstants.captionTextSize,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: AppConstants.smallTextSize,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppConstants.defaultIconSize,
      ),
    );
  }

  static AppBarTheme get _appBarThemeDark {
    return _appBarTheme.copyWith(
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: AppConstants.defaultIconSize,
      ),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.cardBackground,
      elevation: AppConstants.cardElevation,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
    );
  }

  static CardThemeData get _cardThemeDark {
    return _cardTheme.copyWith(
      color: const Color(0xFF2D2D2D),
      shadowColor: Colors.black26,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: AppConstants.bodyTextSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.poppins(
        fontSize: AppConstants.captionTextSize,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
    );
  }

  static ChipThemeData get _chipThemeDark {
    return _chipTheme.copyWith(
      backgroundColor: const Color(0xFF3D3D3D),
      labelStyle: GoogleFonts.poppins(
        fontSize: AppConstants.captionTextSize,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  static FloatingActionButtonThemeData get _fabTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: AppColors.textDisabled),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: AppColors.textDisabled),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      labelStyle: GoogleFonts.poppins(
        fontSize: AppConstants.bodyTextSize,
        color: AppColors.textSecondary,
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationThemeDark {
    return _inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF2D2D2D),
      labelStyle: GoogleFonts.poppins(
        fontSize: AppConstants.bodyTextSize,
        color: Colors.white70,
      ),
    );
  }
}
