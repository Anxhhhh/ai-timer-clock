import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/models/focus_session.dart';

/// Card that shows an incoming AI recommendation with Accept / Edit actions.
class AiRecommendationBanner extends StatelessWidget {
  const AiRecommendationBanner({
    super.key,
    required this.recommendation,
    required this.onAccept,
    required this.onEdit,
    required this.onDismiss,
  });

  final AiRecommendation recommendation;
  final VoidCallback onAccept;
  final VoidCallback onEdit;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      gradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: AppColors.geminiGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gemini Recommendation',
                  style: tt.headlineSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA78BFA),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close,
                      size: 14, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Task
          Text(
            recommendation.taskDescription,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Duration
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 13, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                'Recommended: ${recommendation.durationMinutes} Minutes',
                style: tt.bodyMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.reason,
            style: tt.bodyMedium?.copyWith(
              height: 1.45,
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Accept',
                  icon: Icons.check_rounded,
                  isPrimary: true,
                  onTap: onAccept,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              Expanded(
                child: _ActionButton(
                  label: 'Edit Duration',
                  icon: Icons.edit_outlined,
                  isPrimary: false,
                  onTap: onEdit,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.elevatedSurface,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isPrimary
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.muted.withValues(alpha: 0.3),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: isPrimary
                    ? AppColors.accent
                    : AppColors.secondaryText),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? AppColors.accent
                    : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
