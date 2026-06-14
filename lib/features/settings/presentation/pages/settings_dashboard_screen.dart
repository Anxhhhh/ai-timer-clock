import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../debug/presentation/pages/debug_tts_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/glass_card.dart';

class SettingsDashboardScreen extends StatelessWidget {
  const SettingsDashboardScreen({super.key});

  List<_SettingSection> _buildSections(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return [
      _SettingSection(
        title: 'Preferences',
        items: [
          _SettingItem(
            icon: Icons.palette_outlined,
            label: 'Theme',
            trailing: settings.isDarkMode ? 'Dark' : 'Light',
            onTap: settings.toggleTheme,
          ),
          _SettingItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: settings.notificationsEnabled ? 'On' : 'Off',
            onTap: settings.toggleNotifications,
          ),
        ],
      ),
      _SettingSection(
        title: 'AI & Focus',
        items: [
          _SettingItem(icon: Icons.auto_awesome_outlined, label: 'AI Preferences'),
          _SettingItem(icon: Icons.track_changes_outlined, label: 'Focus Goals'),
        ],
      ),
      _SettingSection(
        title: 'Account',
        items: [
          _SettingItem(icon: Icons.lock_outline, label: 'Privacy'),
          _SettingItem(icon: Icons.info_outline, label: 'About'),
        ],
      ),
      _SettingSection(
        title: 'Developer Tools',
        items: [
          _SettingItem(
            icon: Icons.bug_report_outlined,
            label: 'TTS & Gemini Debug',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebugTtsScreen()));
            },
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Settings', style: Theme.of(context).textTheme.headlineMedium)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.2),
              const SizedBox(height: AppDimensions.spaceXL),
              _buildProfileCard(context)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: AppDimensions.spaceLG),
              ..._buildSections(context).asMap().entries.map((entry) {
                final delay = Duration(milliseconds: 200 + entry.key * 100);
                return _buildSection(context, entry.value)
                    .animate()
                    .fadeIn(delay: delay, duration: 400.ms)
                    .slideY(begin: 0.1);
              }),
              const SizedBox(height: AppDimensions.spaceLG),
              _buildLogoutButton(context)
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: AppDimensions.spaceMD),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ansh', style: tt.headlineMedium?.copyWith(fontSize: 20)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: const Text(
                    'Premium Member',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.secondaryText, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, _SettingSection section) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              section.title.toUpperCase(),
              style: tt.labelMedium?.copyWith(letterSpacing: 1.2, fontSize: 11),
            ),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: section.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _SettingTile(item: item),
                    if (i < section.items.length - 1)
                      Divider(
                        height: 1,
                        indent: 52,
                        color: AppColors.muted.withValues(alpha: 0.3),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
        label: const Text('Log Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────────────────────

class _SettingSection {
  const _SettingSection({required this.title, required this.items});
  final String title;
  final List<_SettingItem> items;
}

class _SettingItem {
  const _SettingItem({required this.icon, required this.label, this.trailing, this.onTap});
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.item});
  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: item.onTap ?? () {},
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceMD - 2,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppColors.secondaryText, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label, style: tt.bodyLarge?.copyWith(fontSize: 15)),
            ),
            if (item.trailing != null)
              Text(
                item.trailing!,
                style: tt.bodyMedium?.copyWith(color: AppColors.accent, fontSize: 13),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}
