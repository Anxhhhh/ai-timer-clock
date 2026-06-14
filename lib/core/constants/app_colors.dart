import 'package:flutter/material.dart';

/// Design-system color palette from Stitch.
/// DO NOT change individual values — always update in this single source of truth.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFF06141B);
  static const Color surface = Color(0xFF11212D);
  static const Color elevatedSurface = Color(0xFF253745);

  // ── Text ─────────────────────────────────────────────────────
  static const Color primaryText = Color(0xFFCCD0CF);
  static const Color secondaryText = Color(0xFF9BA8AB);
  static const Color muted = Color(0xFF4A5C6A);

  // ── Accent (Amber) ────────────────────────────────────────────
  static const Color accent = Color(0xFFFFC857);
  static const Color accentDark = Color(0xFFFFB547);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF6B6B);

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
}
