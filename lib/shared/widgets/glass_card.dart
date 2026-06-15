import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// A glassmorphic card with backdrop blur, a thin muted border,
/// and a subtle top-edge highlight simulating a light source.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 12.0,
    this.fillOpacity = 0.35,
    this.borderColor,
    this.gradientBorder = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double blurSigma;
  final double fillOpacity;
  final Color? borderColor;

  /// When true, renders a purple→blue gradient border (for AI/Gemini cards).
  final bool gradientBorder;

  /// Optional tap handler — adds a subtle press animation.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppDimensions.radiusLG);
    final border = borderColor ?? AppColors.muted.withValues(alpha: 0.3);

    Widget card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMD),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface.withValues(alpha: gradientBorder ? 1.0 : fillOpacity),
            borderRadius: radius,
            border: gradientBorder ? null : Border.all(color: border, width: 1),
            // Top-edge highlight for light-source realism
            gradient: gradientBorder ? null : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.glassHighlight,
                AppColors.elevatedSurface.withValues(alpha: fillOpacity),
              ],
              stops: const [0.0, 0.12],
            ),
          ),
          child: child,
        ),
      ),
    );

    // Gradient border wrapper
    if (gradientBorder) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: AppColors.geminiGradient,
        ),
        child: Container(
          margin: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            borderRadius: (radius as BorderRadius).subtract(BorderRadius.circular(1.2)),
          ),
          child: card,
        ),
      );
    }

    if (onTap != null) {
      return _TappableCard(onTap: onTap!, child: card);
    }
    return card;
  }
}

/// Adds a subtle scale-down press animation to a card.
class _TappableCard extends StatefulWidget {
  const _TappableCard({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
