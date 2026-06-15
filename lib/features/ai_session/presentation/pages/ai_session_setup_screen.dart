import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/accent_button.dart';
import '../../../../shared/widgets/gemini_badge.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../focus/domain/models/focus_session.dart';
import '../../../../shared/navigation/navigation_notifier.dart';

class AiSessionSetupScreen extends StatefulWidget {
  const AiSessionSetupScreen({super.key});

  @override
  State<AiSessionSetupScreen> createState() => _AiSessionSetupScreenState();
}

class _AiSessionSetupScreenState extends State<AiSessionSetupScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _isThinking = false;
  bool _hasRecommendation = false;
  final Set<String> _selectedTags = {'Deep Focus'};

  static const _tags = [
    _TagData('Deep Focus', Icons.psychology_outlined),
    _TagData('No Interruptions', Icons.do_not_disturb_on_outlined),
    _TagData('Light Work', Icons.wb_sunny_outlined),
    _TagData('Creative', Icons.palette_outlined),
  ];
  static const _durations = ['15 Minutes', '25 Minutes', '45 Minutes', '60 Minutes'];
  String _selectedDuration = '45 Minutes';

  // The AI generates this recommendation
  AiRecommendation? _recommendation;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _onTaskSubmitted(String value) async {
    if (value.trim().isEmpty) return;
    setState(() {
      _isThinking = true;
      _hasRecommendation = false;
    });
    // Simulate Gemini thinking
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Generate a recommendation based on tags
    final isDeepWork = _selectedTags.contains('Deep Focus');
    final recMinutes = isDeepWork ? 45 : 25;
    _recommendation = AiRecommendation(
      durationMinutes: recMinutes,
      taskDescription: value.trim(),
      reason: isDeepWork
          ? 'Deep coding tasks benefit from uninterrupted focus cycles. 45 minutes aligns with your peak cognitive window.'
          : 'Shorter, focused bursts work best for lighter tasks. A 25-minute session will keep you sharp.',
    );

    setState(() {
      _isThinking = false;
      _hasRecommendation = true;
      _selectedDuration = '$recMinutes Minutes';
    });
  }

  void _startFocusSession() {
    if (_recommendation == null) {
      // Create a basic recommendation from selected duration
      final minutes = int.tryParse(_selectedDuration.split(' ').first) ?? 25;
      _recommendation = AiRecommendation(
        durationMinutes: minutes,
        taskDescription: _taskController.text.trim().isNotEmpty
            ? _taskController.text.trim()
            : 'Focus Session',
        reason: 'Custom session based on your preferences.',
      );
    }
    // Publish recommendation to focus screen
    aiRecommendationNotifier.value = _recommendation;
    // Switch to Focus tab (now at index 0)
    activeTabNotifier.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical: AppDimensions.spaceLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2),
              const SizedBox(height: AppDimensions.spaceXL),
              Text(
                'What would you like\nto work on?',
                style: tt.displayMedium
                    ?.copyWith(fontSize: 26, height: 1.25),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildInput(context)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: AppDimensions.spaceMD),
              if (_isThinking)
                _buildThinkingState()
                    .animate()
                    .fadeIn(duration: 300.ms),
              if (!_isThinking && _hasRecommendation) ...[
                _buildRecommendationCard(context)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: AppDimensions.spaceLG),
              ],
              if (!_isThinking) ...[
                _buildFocusTags(context)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: AppDimensions.spaceXXL),
                AccentButton(
                  label: 'Start Deep Focus',
                  icon: Icons.bolt_rounded,
                  onPressed: _startFocusSession,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ],
              // Extra padding for floating nav
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'AI Session Setup',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const GeminiBadge(),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _taskController,
        onSubmitted: _onTaskSubmitted,
        maxLines: 3,
        minLines: 2,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText:
              'e.g. Write the project proposal, study algorithms...',
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded,
                  color: AppColors.accent, size: 20),
              onPressed: () => _onTaskSubmitted(_taskController.text),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingState() {
    return GlassCard(
      gradientBorder: true,
      child: Row(
        children: [
          // Animated pulsing dots
          SizedBox(
            width: 36,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA78BFA),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      begin: 0.5,
                      end: 1.0,
                      delay: Duration(milliseconds: i * 180),
                      duration: 500.ms,
                      curve: Curves.easeInOut,
                    )
                    .fadeIn(
                      begin: 0.4,
                      delay: Duration(milliseconds: i * 180),
                      duration: 500.ms,
                    );
              }),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gemini is thinking...',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFFA78BFA),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analysing your task to recommend the optimal focus strategy',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      borderColor: AppColors.accent.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.accent, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Gemini Recommends',
                style: tt.labelMedium?.copyWith(
                    color: AppColors.accent,
                    fontSize: 12,
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text('Session Duration',
              style: tt.headlineSmall?.copyWith(fontSize: 15)),
          const SizedBox(height: AppDimensions.spaceMD),
          Wrap(
            spacing: 8,
            children: _durations.map((d) {
              final selected = d == _selectedDuration;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : AppColors.muted.withValues(alpha: 0.3),
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.accent
                                  .withValues(alpha: 0.18),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.accent
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_recommendation != null) ...[
            const SizedBox(height: 8),
            Text(
              _recommendation!.reason,
              style: tt.bodyMedium?.copyWith(
                  height: 1.5,
                  color: AppColors.secondaryText,
                  fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFocusTags(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus Type',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppDimensions.spaceSM + 2),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _tags.map((tag) {
            final selected = _selectedTags.contains(tag.label);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedTags.remove(tag.label);
                } else {
                  _selectedTags.add(tag.label);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: selected
                        ? AppColors.accent
                        : AppColors.muted.withValues(alpha: 0.4),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.accent
                                .withValues(alpha: 0.15),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tag.icon,
                      size: 14,
                      color: selected
                          ? AppColors.accent
                          : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? AppColors.accent
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TagData {
  const _TagData(this.label, this.icon);
  final String label;
  final IconData icon;
}
