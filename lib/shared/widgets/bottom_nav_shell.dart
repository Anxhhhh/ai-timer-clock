import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/ai_session/presentation/pages/ai_session_setup_screen.dart';
import '../../features/analytics/presentation/pages/analytics_dashboard_screen.dart';
import '../../features/focus/presentation/pages/premium_active_focus_session_screen.dart';
import '../../features/settings/presentation/pages/settings_dashboard_screen.dart';
import '../navigation/navigation_notifier.dart';

/// Root shell that owns the bottom navigation bar.
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key, this.initialIndex = 0});

  /// 0=Focus, 1=AI Setup, 2=Analytics, 3=Settings
  final int initialIndex;

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  late int _currentIndex;

  static const _screens = <Widget>[
    PremiumActiveFocusSessionScreen(),
    AiSessionSetupScreen(),
    AnalyticsDashboardScreen(),
    SettingsDashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    activeTabNotifier.addListener(_onTabNotifier);
  }

  @override
  void dispose() {
    activeTabNotifier.removeListener(_onTabNotifier);
    super.dispose();
  }

  void _onTabNotifier() {
    final tab = activeTabNotifier.value;
    if (tab != _currentIndex && mounted) {
      setState(() => _currentIndex = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

/// Custom premium bottom navigation bar with accent indicator.
class _PremiumNavBar extends StatelessWidget {
  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.timer_outlined, activeIcon: Icons.timer_rounded, label: 'Focus'),
    _NavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'AI Setup'),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: 'Analytics'),
    _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
              color: AppColors.muted.withValues(alpha: 0.25), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final selected = i == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                highlightColor: Colors.transparent,
                splashColor: AppColors.accent.withValues(alpha: 0.1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          key: ValueKey(selected),
                          color: selected ? AppColors.accent : AppColors.muted,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppColors.accent : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected ? 18 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
