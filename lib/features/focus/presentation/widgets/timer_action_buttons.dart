import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/models/focus_session.dart';

/// Pause / Resume / Reset action row, adapts to current [TimerState].
class TimerActionButtons extends StatelessWidget {
  const TimerActionButtons({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
  });

  final TimerState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary action
        _PrimaryButton(
            state: state,
            onStart: onStart,
            onPause: onPause,
            onResume: onResume),
        const SizedBox(height: AppDimensions.spaceMD),
        // Reset — always visible except idle
        if (state != TimerState.idle)
          _ResetButton(onTap: onReset)
              .animate()
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.2),
      ],
    );
  }
}

// ── Primary button ─────────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
  });

  final TimerState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = widget.state == TimerState.paused;
    final isCompleted = widget.state == TimerState.completed;

    final label = switch (widget.state) {
      TimerState.running => 'Pause Session',
      TimerState.paused => 'Resume Session',
      TimerState.completed => 'Session Complete',
      TimerState.idle => 'Start Session',
    };

    final icon = switch (widget.state) {
      TimerState.running => Icons.pause_rounded,
      TimerState.paused => Icons.play_arrow_rounded,
      TimerState.completed => Icons.check_circle_outline,
      TimerState.idle => Icons.play_arrow_rounded,
    };

    final primaryColor = isCompleted
        ? AppColors.success
        : isPaused
            ? const Color(0xFF3B82F6)
            : AppColors.accent;

    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedContainer(
        duration: 300.ms,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.8),
                    AppColors.success
                  ],
                )
              : isPaused
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF60A5FA).withValues(alpha: 0.8),
                        const Color(0xFF3B82F6),
                      ],
                    )
                  : AppColors.accentGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: isCompleted ? null : (_) => _pressCtrl.forward(),
            onTapUp: isCompleted
                ? null
                : (_) {
                    _pressCtrl.reverse();
                    final action = widget.state == TimerState.idle
                        ? widget.onStart
                        : (widget.state == TimerState.paused
                            ? widget.onResume
                            : widget.onPause);
                    action();
                  },
            onTapCancel: isCompleted ? null : () => _pressCtrl.reverse(),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.background, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reset button ───────────────────────────────────────────────────────────────

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.replay_rounded, size: 18),
        label: const Text('Reset Timer'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryText,
          side: BorderSide(
              color: AppColors.muted.withValues(alpha: 0.4), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
