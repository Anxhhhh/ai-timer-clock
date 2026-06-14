import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// A glassmorphic card with backdrop blur and a thin muted border.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 12.0,
    this.fillOpacity = 0.35,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double blurSigma;
  final double fillOpacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppDimensions.radiusLG);
    final border = borderColor ?? AppColors.muted.withValues(alpha: 0.4);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMD),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface.withValues(alpha: fillOpacity),
            borderRadius: radius,
            border: Border.all(color: border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
