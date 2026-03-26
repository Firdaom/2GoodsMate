import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors (Navy Blue) ──────────────────────────────
  static const Color accent      = Color(0xFF1B3D6E);
  static const Color accentDark  = Color(0xFF162D52);
  static const Color accentLight = Color(0xFFE8EEF7); // soft navy tint for backgrounds

  // ─── Light Mode Surfaces ──────────────────────────────────
  static const Color background  = Color(0xFFF7F9FC);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color card        = Color(0xFFF0F4F8);

  // ─── Text ─────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFFAAAAAA);

  // ─── Border ───────────────────────────────────────────────
  static const Color border = Color(0xFFE5E9F0);

  // ─── Status ───────────────────────────────────────────────
  static const Color danger   = Color(0xFFFF5F6B);
  static const Color success = Color(0xFF4ADE80);
  static const Color heart    = Color(0xFFFF5F6B);
  static const Color condNew      = Color(0xFF4ADE80);
  static const Color condLikeNew  = Color(0xFF60A5FA);
  static const Color condGood     = Color(0xFFFBBF24);

  // ─── Rarity ───────────────────────────────────────────────
  static const Color rarityLimited = Color(0xFFFBBF24);
  static const Color rarityRare    = Color(0xFF1B3D6E);
  static const Color rarityCommon  = Color(0xFF9CA3AF);

  // ─── Theme ────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: accent,
      secondary: accentDark,
      surface: surface,
      background: background,
      error: danger,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary, fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

Color rarityColor(String rarity) {
  switch (rarity) {
    case 'Limited': return AppTheme.rarityLimited;
    case 'Rare':    return AppTheme.rarityRare;
    default:        return AppTheme.rarityCommon;
  }
}

Color conditionColor(String condition) {
  switch (condition) {
    case 'New':      return AppTheme.condNew;
    case 'Like New': return AppTheme.condLikeNew;
    default:         return AppTheme.condGood;
  }
}
