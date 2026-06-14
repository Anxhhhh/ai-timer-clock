import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Displays the current session type and duration below the timer ring.
/// Example: "Deep Work • 25m" or "AI Recommended • 45m"
class SessionInfoBadge extends StatelessWidget {
  const SessionInfoBadge({
    super.key,
    required this.label,
    this.isAiRecommended = false,
  });

  final String label;
  final bool isAiRecommended;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isAiRecommended
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
            : AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: isAiRecommended
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.5)
              : AppColors.muted.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAiRecommended) ...[
            const Icon(
              Icons.auto_awesome,
              size: 12,
              color: Color(0xFFA78BFA),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAiRecommended
                  ? const Color(0xFFA78BFA)
                  : AppColors.secondaryText,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
