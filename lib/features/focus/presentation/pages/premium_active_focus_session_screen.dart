import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/analytics_model.dart';
import '../../../../providers/analytics_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/gemini_badge.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/timer_ring.dart';
import '../../data/repositories/session_prefs_repository.dart';
import '../../domain/models/focus_session.dart';
import '../controllers/focus_timer_controller.dart';
import '../widgets/ai_recommendation_banner.dart';
import '../widgets/custom_timer_modal.dart';
import '../widgets/session_info_badge.dart';
import '../widgets/timer_action_buttons.dart';
import 'session_complete_screen.dart';

// ── Preset chip data ──────────────────────────────────────────────────────────

class _PresetChip {
  const _PresetChip({required this.label, required this.minutes});
  final String label;
  final int minutes;
}

const _presets = <_PresetChip>[
  _PresetChip(label: '15m', minutes: 15),
  _PresetChip(label: '25m', minutes: 25),
  _PresetChip(label: '45m', minutes: 45),
  _PresetChip(label: '60m', minutes: 60),
  _PresetChip(label: 'Custom', minutes: -1), // -1 = open modal
];

// ─────────────────────────────────────────────────────────────────────────────

class PremiumActiveFocusSessionScreen extends StatefulWidget {
  const PremiumActiveFocusSessionScreen({super.key});

  @override
  State<PremiumActiveFocusSessionScreen> createState() =>
      _PremiumActiveFocusSessionScreenState();
}

class _PremiumActiveFocusSessionScreenState
    extends State<PremiumActiveFocusSessionScreen> {
  late final FocusTimerController _controller = FocusTimerController(
    initialDuration: const Duration(minutes: 25),
    initialType: SessionType.deepWork,
    onTick: _onTick,
    onComplete: _onSessionComplete,
  );

  final _prefsRepo = SessionPrefsRepository();

  // Which chip is "selected" — index into _presets, or -1 for custom.
  int _selectedPresetIndex = 1; // 25m default
  bool _isCustomDuration = false;

  // AI recommendation state
  AiRecommendation? _pendingAiRec;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    // Listen for recommendations from AI Setup screen
    aiRecommendationNotifier.addListener(_onAiRecommendation);
  }

  @override
  void dispose() {
    _controller.dispose();
    aiRecommendationNotifier.removeListener(_onAiRecommendation);
    super.dispose();
  }

  // ── Callbacks ─────────────────────────────────────────────────

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _onAiRecommendation() {
    final rec = aiRecommendationNotifier.value;
    if (rec != null && mounted) {
      setState(() => _pendingAiRec = rec);
    }
  }

  void _onSessionComplete(FocusSessionResult result) {
    if (!mounted) return;
    
    // Save to analytics
    context.read<AnalyticsProvider>().addSession(FocusSessionRecord(
      durationSeconds: result.totalDuration.inSeconds,
      sessionType: result.sessionType.label,
      timestamp: DateTime.now(),
    ));

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SessionCompleteScreen(result: result),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Preferences ───────────────────────────────────────────────

  Future<void> _loadPreferences() async {
    try {
      final saved = await _prefsRepo.loadSession();
      if (!mounted) return;
      final savedDuration = Duration(seconds: saved.durationSeconds);
      // Find matching preset
      final presetIdx = _presets.indexWhere(
          (p) => p.minutes != -1 && p.minutes * 60 == saved.durationSeconds);
      setState(() {
        _selectedPresetIndex = presetIdx >= 0 ? presetIdx : -1;
        _isCustomDuration = presetIdx < 0;
      });
      _controller.updateSession(
          duration: savedDuration, type: saved.sessionType);
    } catch (_) {
      // Use defaults on error
    }
  }

  Future<void> _savePreferences() async {
    await _prefsRepo.saveSession(
      durationSeconds: _controller.totalDuration.inSeconds,
      sessionType: _controller.sessionType,
    );
  }

  // ── UI actions ────────────────────────────────────────────────

  void _onPresetTap(int index, _PresetChip chip) async {
    if (chip.minutes == -1) {
      // Custom
      final result = await showCustomTimerModal(
        context,
        initialDuration: _isCustomDuration ? _controller.totalDuration : null,
      );
      if (result != null && mounted) {
        setState(() {
          _selectedPresetIndex = index;
          _isCustomDuration = true;
          _pendingAiRec = null;
        });
        _controller.updateSession(
            duration: result, type: SessionType.customFocus);
        await _savePreferences();
        _controller.start();
      }
    } else {
      setState(() {
        _selectedPresetIndex = index;
        _isCustomDuration = false;
        _pendingAiRec = null;
      });
      _controller.updateSession(
        duration: Duration(minutes: chip.minutes),
        type: index == 1 ? SessionType.deepWork : SessionType.studySession,
      );
      await _savePreferences();
      _controller.start();
    }
  }

  void _acceptAiRecommendation() {
    final rec = _pendingAiRec;
    if (rec == null) return;
    setState(() {
      _selectedPresetIndex = -1;
      _isCustomDuration = false;
      _pendingAiRec = null;
    });
    _controller.updateSession(
      duration: Duration(minutes: rec.durationMinutes),
      type: SessionType.aiRecommended,
    );
    _savePreferences();
    _controller.start();
    // Clear global notifier
    aiRecommendationNotifier.value = null;
  }

  void _editAiRecommendation() async {
    final rec = _pendingAiRec;
    if (rec == null) return;
    final result = await showCustomTimerModal(
      context,
      initialDuration: Duration(minutes: rec.durationMinutes),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedPresetIndex = -1;
        _isCustomDuration = true;
        _pendingAiRec = null;
      });
      _controller.updateSession(
          duration: result, type: SessionType.aiRecommended);
      await _savePreferences();
      _controller.start();
      aiRecommendationNotifier.value = null;
    }
  }

  void _dismissAiRecommendation() {
    setState(() => _pendingAiRec = null);
    aiRecommendationNotifier.value = null;
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAiSession =
        _controller.sessionType == SessionType.aiRecommended;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical: AppDimensions.spaceLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _FocusHeader()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2),
              const SizedBox(height: AppDimensions.spaceXL),

              // AI Recommendation Banner
              if (_pendingAiRec != null) ...[
                AiRecommendationBanner(
                  recommendation: _pendingAiRec!,
                  onAccept: _acceptAiRecommendation,
                  onEdit: _editAiRecommendation,
                  onDismiss: _dismissAiRecommendation,
                ),
                const SizedBox(height: AppDimensions.spaceLG),
              ],

              // Timer ring + badge
              Center(
                child: Column(
                  children: [
                    TimerRing(
                      progress: _controller.progress,
                      timeLabel: _controller.timeLabel,
                      title: 'FOCUS SESSION',
                      subtitle: _controller.sessionType.label,
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 600.ms)
                        .scaleXY(
                          begin: 0.85,
                          end: 1.0,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    SessionInfoBadge(
                      label: _controller.sessionBadgeLabel,
                      isAiRecommended: isAiSession,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLG),

              // Duration chips
              _buildDurationChips()
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: AppDimensions.spaceLG),

              // Progress stats (shown when active)
              if (_controller.state != TimerState.idle)
                _buildProgressRow()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.15),
              if (_controller.state != TimerState.idle)
                const SizedBox(height: AppDimensions.spaceLG),

              // Stats cards
              _buildStatsRow(context)
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: AppDimensions.spaceLG),

              // Gemini insight card
              _buildGeminiCard()
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 500.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: AppDimensions.spaceLG),
            ],
          ),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            0,
            AppDimensions.screenPadding,
            AppDimensions.spaceLG,
          ),
          child: TimerActionButtons(
            state: _controller.state,
            onStart: _controller.start,
            onPause: _controller.pause,
            onResume: _controller.resume,
            onReset: _controller.reset,
          ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
        ),
      ],
    ),
  ),
    );
  }

  // ── Section builders ──────────────────────────────────────────

  Widget _buildDurationChips() {
    return Center(
      child: Wrap(
        spacing: AppDimensions.spaceSM,
        runSpacing: AppDimensions.spaceSM,
        alignment: WrapAlignment.center,
        children: _presets.asMap().entries.map((entry) {
          final i = entry.key;
          final chip = entry.value;
          final isSelected = i == _selectedPresetIndex;
          return _DurationChip(
            label: chip.minutes == -1 && _isCustomDuration && isSelected
                ? 'Custom • ${_controller.durationLabel}'
                : chip.label,
            selected: isSelected,
            isCustom: chip.minutes == -1,
            onTap: () => _onPresetTap(i, chip),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressRow() {
    final pct = _controller.completionPercent;
    final elapsed = _controller.elapsedSeconds;
    final elapsedMin = elapsed ~/ 60;
    final elapsedSec = elapsed % 60;
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Elapsed',
              value:
                  '${elapsedMin.toString().padLeft(2, '0')}:${elapsedSec.toString().padLeft(2, '0')}',
              icon: Icons.timelapse_rounded,
              color: AppColors.accent,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.muted.withValues(alpha: 0.3)),
          Expanded(
            child: _MiniStat(
              label: 'Completion',
              value: '$pct%',
              icon: Icons.donut_large_rounded,
              color: AppColors.success,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.muted.withValues(alpha: 0.3)),
          Expanded(
            child: _MiniStat(
              label: 'Score',
              value: '$pct',
              icon: Icons.star_rounded,
              color: const Color(0xFFA78BFA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'Focus Time', value: analytics.totalFocusTimeFormatted, icon: Icons.timer_outlined)),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
            child: _StatCard(
                label: 'Sessions', value: '${analytics.totalSessions}', icon: Icons.repeat_rounded)),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
            child: _StatCard(
                label: 'Completion', value: '${analytics.averageCompletionPercentage.toInt()}%', icon: Icons.check_circle_outline)),
      ],
    );
  }

  Widget _buildGeminiCard() {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: const Icon(Icons.auto_awesome,
                color: AppColors.accent, size: AppDimensions.iconMD),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gemini Assistant',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _geminiInsight,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _geminiInsight {
    switch (_controller.state) {
      case TimerState.running:
        return 'You\'re in peak cognitive state. Your focus patterns show a 23% improvement this week. Keep going — the next 10 minutes are your most productive window.';
      case TimerState.paused:
        return 'Session paused. Take a mindful breath and refocus. You\'ve made great progress — resume when ready.';
      case TimerState.completed:
        return 'Outstanding work! Session complete. Your concentration metrics rank in the top 15% of sessions this month.';
      case TimerState.idle:
        return 'Select a duration and start your session. I\'ll track your focus patterns and provide personalised insights.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FocusHeader extends StatelessWidget {
  const _FocusHeader();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready for deep focus?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        const GeminiBadge(),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.isCustom,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isCustom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.muted.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom) ...[
              Icon(
                Icons.tune_rounded,
                size: 12,
                color: selected ? AppColors.accent : AppColors.secondaryText,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.accent : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: AppDimensions.spaceMD,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: AppDimensions.iconMD),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
