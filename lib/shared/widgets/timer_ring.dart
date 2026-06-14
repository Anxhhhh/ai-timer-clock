import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Paints the circular gradient timer ring with an outer amber glow.
class TimerRingPainter extends CustomPainter {
  const TimerRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  /// Progress from 0.0 (empty) to 1.0 (full).
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // Start at 12 o'clock

    // ── Track (background ring) ───────────────────────────────────
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.muted.withValues(alpha: 0.3)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // ── Outer glow ────────────────────────────────────────────────
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
      ..color = AppColors.accent.withValues(alpha: 0.25)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      glowPaint,
    );

    // ── Gradient progress arc ─────────────────────────────────────
    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [
          AppColors.accentDark,
          AppColors.accent,
          Color(0xFFFFF0B0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);

    // ── Leading dot ───────────────────────────────────────────────
    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2, dotPaint);
  }

  @override
  bool shouldRepaint(TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// The animated timer widget wrapping the custom painter.
class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.progress,
    required this.timeLabel,
    this.title = 'Focus Session',
    this.subtitle = 'Deep Work',
    this.size = AppDimensions.timerRingSize,
    this.strokeWidth = AppDimensions.timerRingStroke,
  });

  final double progress;
  final String timeLabel;
  final String title;
  final String subtitle;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient glow
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Painter
          CustomPaint(
            size: Size(size, size),
            painter: TimerRingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: tt.labelMedium?.copyWith(
                  color: AppColors.secondaryText,
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: tt.bodyMedium?.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 8),
              Text(
                timeLabel,
                style: tt.displayLarge?.copyWith(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
