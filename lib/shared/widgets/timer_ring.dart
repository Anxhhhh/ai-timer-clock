import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Paints the circular gradient timer ring with tick marks, outer glow,
/// and a shimmer-trail leading dot.
class TimerRingPainter extends CustomPainter {
  const TimerRingPainter({
    required this.progress,
    required this.strokeWidth,
    this.showTickMarks = true,
  });

  final double progress;
  final double strokeWidth;
  final bool showTickMarks;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // 12 o'clock

    // ── Tick marks (removed for cleaner design) ─────────────────

    // ── Track (background ring) ──────────────────────────────────
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.muted.withValues(alpha: 0.18)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // ── Gradient progress arc ────────────────────────────────────
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

    // ── Leading dot ──────────────────────────────
    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    // Dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2.5, dotPaint);

    // Dot inner highlight
    final highlightPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 5, highlightPaint);
  }

  @override
  bool shouldRepaint(TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// The animated timer widget wrapping the custom painter.
/// Includes a pulsing ambient glow when a [glowController] is provided.
class TimerRing extends StatefulWidget {
  const TimerRing({
    super.key,
    required this.progress,
    required this.timeLabel,
    this.title = 'Focus Session',
    this.subtitle = 'Deep Work',
    this.size = AppDimensions.timerRingSize,
    this.strokeWidth = AppDimensions.timerRingStroke,
    this.isRunning = false,
  });

  final double progress;
  final String timeLabel;
  final String title;
  final String subtitle;
  final double size;
  final double strokeWidth;
  final bool isRunning;

  @override
  State<TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<TimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _trailAnim;

  @override
  void initState() {
    super.initState();
    _trailAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant TimerRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_trailAnim.isAnimating) {
      _trailAnim.repeat();
    } else if (!widget.isRunning && _trailAnim.isAnimating) {
      _trailAnim.stop();
    }
  }

  @override
  void dispose() {
    _trailAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final size = widget.size;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // (ambient glow removed)
            // Painter
            CustomPaint(
              size: Size(size, size),
              painter: TimerRingPainter(
                progress: widget.progress,
                strokeWidth: widget.strokeWidth,
              ),
            ),
            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: tt.labelMedium?.copyWith(
                    color: AppColors.secondaryText,
                    letterSpacing: 1.6,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.timeLabel,
                  style: tt.displayLarge?.copyWith(
                    fontSize: 54,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
