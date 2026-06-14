import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/accent_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/models/focus_session.dart';

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({super.key, this.result});

  /// Real session data; when null, falls back to demo values.
  final FocusSessionResult? result;

  // ── Computed helpers ──────────────────────────────────────────
  int get _focusScore => result?.focusScore ?? 98;
  String get _timeFocused => result?.formattedElapsed ?? '45m';
  int get _completionPct => ((result?.completionPercent ?? 1.0) * 100).round();
  String get _sessionLabel => result?.sessionType.label ?? 'Deep Work';
  String get _aiSummary =>
      result?.aiSummary ??
      'Excellent session! You maintained deep focus throughout the entire session.';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      // Back button (when pushed as a route)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.secondaryText, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical: AppDimensions.spaceSM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.spaceLG),
              _buildCelebrationHero()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scaleXY(begin: 0.7, curve: Curves.easeOutBack),
              const SizedBox(height: AppDimensions.spaceXL),
              Text(
                'Session Complete 🎉',
                style: tt.displayMedium?.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                _completionPct >= 95
                    ? 'Exceptional focus achieved.'
                    : _completionPct >= 75
                        ? 'Great session — well done!'
                        : 'Good effort — keep building the habit.',
                style: tt.bodyMedium?.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              // Session type badge
              const SizedBox(height: AppDimensions.spaceSM),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _sessionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
              const SizedBox(height: AppDimensions.spaceXL),
              _buildStatsGrid(context)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildAiAnalysisCard(context)
                  .animate()
                  .fadeIn(delay: 550.ms, duration: 500.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: AppDimensions.spaceXL),
              AccentButton(
                label: 'Share Progress',
                icon: Icons.share_rounded,
                onPressed: () {},
              ).animate().fadeIn(delay: 650.ms, duration: 400.ms),
              const SizedBox(height: AppDimensions.spaceMD),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationHero() {
    final emoji = _completionPct >= 95 ? '🏆' : _completionPct >= 75 ? '⭐' : '💪';
    final glowColor = _completionPct >= 95 ? AppColors.accent : AppColors.success;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glowColor.withValues(alpha: 0.1),
        border: Border.all(color: glowColor.withValues(alpha: 0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 64))),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      _StatItem(
          value: '$_focusScore',
          label: 'Focus Score',
          icon: Icons.star_rounded,
          color: AppColors.accent),
      _StatItem(
          value: _timeFocused,
          label: 'Time Focused',
          icon: Icons.timer_rounded,
          color: AppColors.success),
      _StatItem(
          value: '0',
          label: 'Distractions',
          icon: Icons.shield_rounded,
          color: const Color(0xFF60A5FA)),
      _StatItem(
          value: '$_completionPct%',
          label: 'Completion',
          icon: Icons.check_circle_rounded,
          color: AppColors.success),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.spaceMD,
      mainAxisSpacing: AppDimensions.spaceMD,
      childAspectRatio: 1.5,
      children: stats.map((s) => _StatCard(item: s)).toList(),
    );
  }

  Widget _buildAiAnalysisCard(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Analysis',
                style: tt.headlineSmall
                    ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          _AnalysisRow(
              label: 'Flow State',
              value: 'Achieved after 8 min',
              color: AppColors.success),
          const SizedBox(height: 8),
          _AnalysisRow(
              label: 'Peak Focus',
              value: '14–32 min window',
              color: AppColors.accent),
          const SizedBox(height: 8),
          _AnalysisRow(
              label: 'Next Session',
              value: 'In ~20 min',
              color: const Color(0xFF60A5FA)),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            _aiSummary,
            style:
                tt.bodyMedium?.copyWith(height: 1.55, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _StatItem {
  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 24),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: tt.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(item.label, style: tt.labelMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}
