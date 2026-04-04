import 'package:flutter/material.dart';

/// Psychology-based color palette for calm, trust, and growth
class AppColors {
  AppColors._();

  // ── Primary Backgrounds ──
  static const Color primaryBg = Color(0xFF06080F);      // Deep dark – focus & calm
  static const Color secondaryBg = Color(0xFF0F172A);     // Dark blue-gray – depth

  // ── Accents ──
  static const Color primaryAccent = Color(0xFF22C55E);   // Green – growth, positivity
  static const Color secondaryAccent = Color(0xFF3B82F6); // Blue – trust, intelligence
  static const Color highlight = Color(0xFFF59E0B);       // Amber – attention, action (CTA)

  // ── Text ──
  static const Color textPrimary = Color(0xFFF8FAFC);     // Near white
  static const Color textSecondary = Color(0xFF94A3B8);   // Muted gray

  // ── Indicators ──
  static const Color negative = Color(0xFFEF4444);        // Soft red
  static const Color positive = Color(0xFF10B981);        // Emerald

  // ── Surface / Card ──
  static const Color cardBg = Color(0xFF1E293B);
  static const Color cardBgLight = Color(0xFF334155);
  static const Color surfaceLight = Color(0xFF475569);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAccent, Color(0xFF059669)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryAccent, Color(0xFF6366F1)],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [highlight, Color(0xFFF97316)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondaryBg, primaryBg],
  );

  // ── Glassmorphism ──
  static Color glassWhite = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
}
