import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Small "Gemini AI" badge with a continuous shimmer sweep animation.
class GeminiBadge extends StatelessWidget {
  const GeminiBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM + 4,
        vertical: AppDimensions.spaceXS + 2,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.geminiGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'Gemini AI',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 2200.ms,
          delay: 800.ms,
          color: Colors.white.withValues(alpha: 0.25),
          angle: 0.5,
        );
  }
}
