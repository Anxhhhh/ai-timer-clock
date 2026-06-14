import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/focus_session.dart';

/// Public result type returned by [SessionPrefsRepository.loadSession].
class SavedSessionPrefs {
  const SavedSessionPrefs({
    required this.durationSeconds,
    required this.sessionType,
  });
  final int durationSeconds;
  final SessionType sessionType;
}

/// Persists and restores the user's last focus session preferences.
class SessionPrefsRepository {
  static const _keyDurationSeconds = 'pref_duration_seconds';
  static const _keySessionTypeIndex = 'pref_session_type_index';

  /// Save the last-used session configuration.
  Future<void> saveSession({
    required int durationSeconds,
    required SessionType sessionType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_keyDurationSeconds, durationSeconds),
      prefs.setInt(_keySessionTypeIndex, sessionType.index),
    ]);
  }

  /// Load the last-used session configuration.
  /// Returns a default of 25 minutes / Deep Work when nothing is saved.
  Future<SavedSessionPrefs> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_keyDurationSeconds) ?? 25 * 60;
    final typeIndex = prefs.getInt(_keySessionTypeIndex) ?? 0;
    final type = SessionType.values[typeIndex.clamp(0, SessionType.values.length - 1)];
    return SavedSessionPrefs(durationSeconds: seconds, sessionType: type);
  }
}
