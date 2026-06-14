import 'package:shared_preferences/shared_preferences.dart';
import '../models/analytics_model.dart';

class StorageService {
  static const _kAnalyticsKey = 'analytics_history';
  static const _kThemeKey = 'theme_preference';
  static const _kNotificationsKey = 'notifications_preference';

  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();

  // ── Analytics ──────────────────────────────────────────────────────────

  Future<List<FocusSessionRecord>> loadAnalyticsHistory() async {
    final prefs = await _getPrefs();
    final List<String> historyStrings = prefs.getStringList(_kAnalyticsKey) ?? [];
    return historyStrings.map((str) => FocusSessionRecord.fromJson(str)).toList();
  }

  Future<void> saveAnalyticsHistory(List<FocusSessionRecord> history) async {
    final prefs = await _getPrefs();
    final historyStrings = history.map((record) => record.toJson()).toList();
    await prefs.setStringList(_kAnalyticsKey, historyStrings);
  }

  // ── Settings ───────────────────────────────────────────────────────────

  Future<bool> loadIsDarkMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_kThemeKey) ?? true; // Default dark
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_kThemeKey, isDark);
  }

  Future<bool> loadNotificationsEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_kNotificationsKey) ?? true;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_kNotificationsKey, enabled);
  }
}
