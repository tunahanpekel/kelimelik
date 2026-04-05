// lib/core/theme/app_theme.dart
//
// Kelimelik design system — dark-first, Turkish game aesthetic.
// Primary red (#E63946) evokes energy and Turkish flag.
// Accent gold (#F4D35E) for scores and achievements.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Palette ────────────────────────────────────────────────────────

  // Backgrounds
  static const Color bgDeep        = Color(0xFF0D1117); // Scaffold — near black
  static const Color bgMid         = Color(0xFF161B22); // Cards
  static const Color bgSurface     = Color(0xFF21262D); // Elevated / tiles
  static const Color bgBorder      = Color(0xFF30363D); // Borders / dividers

  // Primary — Kelimelik Red
  static const Color primary       = Color(0xFFE63946);
  static const Color primaryDark   = Color(0xFFC1121F);
  static const Color primaryLight  = Color(0xFFFF6B6B);

  // Accent — Gold (scores, achievements)
  static const Color accent        = Color(0xFFF4D35E);
  static const Color accentDark    = Color(0xFFD4A017);

  // Game colors
  static const Color correct       = Color(0xFF06D6A0); // Green — correct position
  static const Color misplaced     = Color(0xFFF77F00); // Orange — wrong position
  static const Color wrong         = Color(0xFF44475A); // Gray — not in word
  static const Color empty         = Color(0xFF21262D); // Empty tile

  // Supporting
  static const Color accentPurple  = Color(0xFF9B8FD4);
  static const Color accentTeal    = Color(0xFF5BC8C0);

  // Text
  static const Color textPrimary   = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textHint      = Color(0xFF484F58);

  // Semantic
  static const Color success       = Color(0xFF06D6A0);
  static const Color warning       = Color(0xFFF4D35E);
  static const Color error         = Color(0xFFE63946);

  // ─── Gradients ────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE63946), Color(0xFFC1121F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF4D35E), Color(0xFFD4A017)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1117), Color(0xFF0A0D12)],
  );

  // ─── Typography ───────────────────────────────────────────────────────────

  static TextStyle get displayLarge  => GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, color: textPrimary,   letterSpacing: -1.5, height: 1.0);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary,   letterSpacing: -1.0, height: 1.1);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,   letterSpacing: -0.5, height: 1.2);
  static TextStyle get headlineMedium=> GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.3);
  static TextStyle get titleLarge    => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.35);
  static TextStyle get titleMedium   => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,   height: 1.4);
  static TextStyle get bodyLarge     => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,   height: 1.5);
  static TextStyle get bodyMedium    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5);
  static TextStyle get labelLarge    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,   letterSpacing: 0.5);
  static TextStyle get labelMedium   => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.3);
  static TextStyle get labelSmall    => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textHint,      letterSpacing: 0.5);

  // Game-specific typography
  static TextStyle get gameTile      => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary,   letterSpacing: 2.0);
  static TextStyle get gameTimer     => GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: primary,       letterSpacing: -1.0);
  static TextStyle get scoreDisplay  => GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w800, color: accent,        letterSpacing: -2.0);

  // ─── ThemeData ────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,

      colorScheme: const ColorScheme.dark(
        primary:                  primary,
        primaryContainer:         Color(0xFF3D0A10),
        onPrimary:                textPrimary,
        secondary:                accent,
        secondaryContainer:       Color(0xFF3D3000),
        onSecondary:              bgDeep,
        tertiary:                 accentTeal,
        surface:                  bgMid,
        surfaceContainerHighest:  bgSurface,
        onSurface:                textPrimary,
        onSurfaceVariant:         textSecondary,
        outline:                  bgBorder,
        error:                    error,
        onError:                  textPrimary,
        // ignore: deprecated_member_use
        background:               bgDeep,
      ),

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge:   displayLarge,
        displayMedium:  displayMedium,
        headlineLarge:  headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge:     titleLarge,
        titleMedium:    titleMedium,
        bodyLarge:      bodyLarge,
        bodyMedium:     bodyMedium,
        labelLarge:     labelLarge,
        labelMedium:    labelMedium,
        labelSmall:     labelSmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: titleLarge.copyWith(letterSpacing: 0.5),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: bgMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: bgBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: labelLarge.copyWith(fontSize: 15),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bgDeep,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: labelLarge.copyWith(fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: bgBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgBorder)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgBorder)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
        labelStyle: bodyMedium,
        hintStyle:  labelMedium,
      ),

      dividerTheme: const DividerThemeData(color: bgBorder, thickness: 1, space: 1),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgMid,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSurface,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: bgMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: bgBorder),
        ),
        titleTextStyle:   headlineMedium,
        contentTextStyle: bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgMid,
        modalBackgroundColor: bgMid,
        showDragHandle: true,
        dragHandleColor: bgBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: bgBorder,
        circularTrackColor: bgBorder,
      ),
    );
  }
}
