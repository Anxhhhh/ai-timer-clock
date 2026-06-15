import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/accent_button.dart';

/// Premium glassmorphic bottom-sheet for picking a custom focus duration.
///
/// Returns the chosen [Duration] via [Navigator.pop], or null if dismissed.
Future<Duration?> showCustomTimerModal(
  BuildContext context, {
  Duration? initialDuration,
}) {
  return showModalBottomSheet<Duration>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _CustomTimerModal(initialDuration: initialDuration),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _CustomTimerModal extends StatefulWidget {
  const _CustomTimerModal({this.initialDuration});
  final Duration? initialDuration;

  @override
  State<_CustomTimerModal> createState() => _CustomTimerModalState();
}

class _CustomTimerModalState extends State<_CustomTimerModal> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  bool _showError = false;

  late FixedExtentScrollController _hoursCtrl;
  late FixedExtentScrollController _minutesCtrl;
  late FixedExtentScrollController _secondsCtrl;

  static const _quickPresets = <int>[15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final d = widget.initialDuration ?? const Duration(minutes: 25);
    _hours = d.inHours.clamp(0, 12);
    _minutes = d.inMinutes.remainder(60).clamp(0, 59);
    _seconds = d.inSeconds.remainder(60).clamp(0, 59);

    _hoursCtrl = FixedExtentScrollController(initialItem: _hours);
    _minutesCtrl = FixedExtentScrollController(initialItem: _minutes);
    _secondsCtrl = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _minutesCtrl.dispose();
    _secondsCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    setState(() {
      _hours = h;
      _minutes = m;
      _seconds = 0;
      _showError = false;
    });
    _hoursCtrl.animateToItem(h,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _minutesCtrl.animateToItem(m,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _secondsCtrl.animateToItem(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  bool get _isValid => _hours > 0 || _minutes > 0 || _seconds > 0;

  void _start() {
    if (!_isValid) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pop(
      context,
      Duration(hours: _hours, minutes: _minutes, seconds: _seconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
        border: Border(
          top: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 2,
          ),
          left: BorderSide(
            color: AppColors.muted.withValues(alpha: 0.15),
            width: 1,
          ),
          right: BorderSide(
            color: AppColors.muted.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ────────────────────────────────────
              const SizedBox(height: 14),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──────────────────────────────────────────
              Text(
                'Create Custom Focus Session',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 19),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Choose your desired focus duration.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── Quick presets ──────────────────────────────────
              _QuickPresets(
                presets: _quickPresets,
                selectedMinutes: _hours * 60 + _minutes,
                onSelect: _applyPreset,
              ),
              const SizedBox(height: 28),

              // ── Wheel pickers ──────────────────────────────────
              _buildPickerRow(),
              const SizedBox(height: 8),

              // ── Error ──────────────────────────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _showError
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'Please select a valid duration.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                secondChild: const SizedBox(height: 0),
              ),

              const SizedBox(height: 16),

              // ── Start button ───────────────────────────────────
              AccentButton(
                label: 'Start Focus Session',
                icon: Icons.play_arrow_rounded,
                onPressed: _start,
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 350.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 250.ms);
  }

  Widget _buildPickerRow() {
    return Row(
      children: [
        Expanded(
          child: _WheelPicker(
            controller: _hoursCtrl,
            itemCount: 13, // 0–12
            selectedItem: _hours,
            label: 'Hours',
            onChanged: (v) => setState(() {
              _hours = v;
              _showError = false;
            }),
          ),
        ),
        const _PickerSeparator(),
        Expanded(
          child: _WheelPicker(
            controller: _minutesCtrl,
            itemCount: 60, // 0–59
            selectedItem: _minutes,
            label: 'Minutes',
            onChanged: (v) => setState(() {
              _minutes = v;
              _showError = false;
            }),
          ),
        ),
        const _PickerSeparator(),
        Expanded(
          child: _WheelPicker(
            controller: _secondsCtrl,
            itemCount: 60, // 0–59
            selectedItem: _seconds,
            label: 'Seconds',
            onChanged: (v) => setState(() {
              _seconds = v;
              _showError = false;
            }),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _QuickPresets extends StatelessWidget {
  const _QuickPresets({
    required this.presets,
    required this.selectedMinutes,
    required this.onSelect,
  });

  final List<int> presets;
  final int selectedMinutes;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK PICKS',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.4,
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((min) {
              final selected = selectedMinutes == min;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(min),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.elevatedSurface,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent
                            : AppColors.muted.withValues(alpha: 0.25),
                        width: selected ? 1.5 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.accent.withValues(alpha: 0.2),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      min >= 60
                          ? '${min ~/ 60}h${min % 60 > 0 ? ' ${min % 60}m' : ''}'
                          : '${min}m',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.accent
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _WheelPicker extends StatelessWidget {
  const _WheelPicker({
    required this.controller,
    required this.itemCount,
    required this.selectedItem,
    required this.label,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedItem;
  final String label;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center highlight band with glow
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.04),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Wheel
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 52,
                diameterRatio: 1.6,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  HapticFeedback.selectionClick();
                  onChanged(index);
                },
                perspective: 0.003,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: itemCount,
                  builder: (context, index) {
                    final isSelected = index == selectedItem;
                    return Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontSize: isSelected ? 30 : 20,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.muted.withValues(alpha: 0.5),
                        ),
                        child: Text(index.toString().padLeft(2, '0')),
                      ),
                    );
                  },
                ),
              ),
              // Top fade
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 55,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom fade
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 55,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _PickerSeparator extends StatelessWidget {
  const _PickerSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 36),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
