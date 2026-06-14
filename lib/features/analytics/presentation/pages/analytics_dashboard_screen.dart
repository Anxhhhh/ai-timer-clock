import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/analytics_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/glass_card.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  // ── Sample weekly data ─────────────────────────────────────────
  static const _weeklyData = <double>[3.5, 2.0, 4.5, 5.0, 3.8, 1.5, 4.2];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
              Text('Analytics', style: tt.headlineMedium)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2),
              const SizedBox(height: 4),
              Text('Your productivity at a glance', style: tt.bodyMedium)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: AppDimensions.spaceXL),
              _buildTopStats(context)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildAiInsightCard(context)
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildWeeklyChart(context)
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: AppDimensions.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final stats = [
      _Stat(label: 'Total Focus', value: analytics.totalFocusTimeFormatted, icon: Icons.timer_outlined, color: AppColors.accent),
      _Stat(label: 'Sessions', value: '${analytics.totalSessions}', icon: Icons.loop_rounded, color: AppColors.success),
      _Stat(label: 'Completion', value: '${analytics.averageCompletionPercentage.toInt()}%', icon: Icons.star_outline_rounded, color: const Color(0xFFA78BFA)),
      _Stat(label: 'Best Time', value: '9–11 AM', icon: Icons.wb_sunny_outlined, color: const Color(0xFF60A5FA)),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.spaceMD,
      mainAxisSpacing: AppDimensions.spaceMD,
      childAspectRatio: 1.6,
      children: stats.map((s) => _StatTile(stat: s)).toList(),
    );
  }

  Widget _buildAiInsightCard(BuildContext context) {
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
                child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Productivity Insight',
                style: tt.headlineSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your focus is 32% above average this week 🚀. Thursday was your peak performance day. Morning sessions (9–11 AM) yield your highest concentration — try scheduling critical tasks then.',
            style: tt.bodyMedium?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Focus Trend',
            style: tt.headlineSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('Hours focused per day', style: tt.bodyMedium?.copyWith(fontSize: 12)),
          const SizedBox(height: AppDimensions.spaceLG),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.muted.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _days[idx],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}h',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(_weeklyData.length, (i) {
                  final isToday = i == 3; // Thursday highlighted
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _weeklyData[i],
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [AppColors.accent.withValues(alpha: 0.6), AppColors.accent]
                              : [
                                  AppColors.elevatedSurface,
                                  AppColors.muted.withValues(alpha: 0.7),
                                ],
                        ),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.elevatedSurface,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      '${rod.toY}h',
                      const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _Stat {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat.icon, color: stat.color, size: 22),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: tt.headlineSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(stat.label, style: tt.labelMedium?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
