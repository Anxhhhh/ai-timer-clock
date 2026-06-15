import 'package:flutter/material.dart';

/// Design-system color palette.
/// DO NOT change individual values — always update in this single source of truth.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color elevatedSurface = Color(0xFFF1F5F9);

  // ── Text ─────────────────────────────────────────────────────
  static const Color primaryText = Color(0xFF050A30); // Oxford Blue
  static const Color secondaryText = Color(0xFF64748B);
  static const Color muted = Color(0xFF94A3B8);

  // ── Accent (Dark Orange) ──────────────────────────────────────
  static const Color accent = Color(0xFFFF8C00); // Dark Orange
  static const Color accentDark = Color(0xFFE67E00);

  // ── Secondary Accent (Teal) ───────────────────────────────────
  static const Color teal = Color(0xFF2DD4BF);
  static const Color tealDark = Color(0xFF14B8A6);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF60A5FA);

  // ── Glass / Highlight ─────────────────────────────────────────
  static const Color glassHighlight = Color(0x0A000000); // subtle dark highlight on white
  static const Color glassBorder = Color(0x1A000000); // 10% black border

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient timerRingGradient = LinearGradient(
    colors: [accentDark, accent, Color(0xFFFFF0B0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, elevatedSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient geminiGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [tealDark, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Radial glow for the focus screen background
  static const RadialGradient ambientGlow = RadialGradient(
    center: Alignment(0, -0.2),
    radius: 0.9,
    colors: [
      Color(0x11FF8C00), // very light orange
      Color(0x05FF8C00), // extremely light orange
      Color(0x00000000), // transparent
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Shimmer gradient used for animated badge sweeps.
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x33FFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.5, -0.3),
    end: Alignment(1.5, 0.3),
  );

  // ── Icon Tint Palette (for settings / tags) ───────────────────
  static const Color iconPalette = Color(0xFF8B5CF6);  // violet
  static const Color iconBlue = Color(0xFF3B82F6);
  static const Color iconAmber = Color(0xFFFF8C00);
  static const Color iconTeal = Color(0xFF2DD4BF);
  static const Color iconRose = Color(0xFFFB7185);
  static const Color iconGreen = Color(0xFF30D158);

  // ── Card Glow Shadow ──────────────────────────────────────────
  static List<BoxShadow> cardGlow(Color color, {double blur = 20, double spread = 0}) => [
    BoxShadow(
      color: color.withValues(alpha: 0.18),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];
}
