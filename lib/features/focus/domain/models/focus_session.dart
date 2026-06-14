import 'package:flutter/foundation.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum TimerState { idle, running, paused, completed }

enum SessionType {
  deepWork,
  studySession,
  customFocus,
  aiRecommended,
  pomodoro,
  shortBreak,
}

extension SessionTypeX on SessionType {
  String get label {
    switch (this) {
      case SessionType.deepWork:
        return 'Deep Work';
      case SessionType.studySession:
        return 'Study Session';
      case SessionType.customFocus:
        return 'Custom Focus';
      case SessionType.aiRecommended:
        return 'AI Recommended';
      case SessionType.pomodoro:
        return 'Pomodoro';
      case SessionType.shortBreak:
        return 'Short Break';
    }
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class AiRecommendation {
  const AiRecommendation({
    required this.durationMinutes,
    required this.reason,
    required this.taskDescription,
  });

  final int durationMinutes;
  final String reason;
  final String taskDescription;
}

class FocusSessionResult {
  const FocusSessionResult({
    required this.totalDuration,
    required this.elapsedSeconds,
    required this.sessionType,
    required this.startTime,
  });

  final Duration totalDuration;
  final int elapsedSeconds;
  final SessionType sessionType;
  final DateTime startTime;

  double get completionPercent =>
      (elapsedSeconds / totalDuration.inSeconds.clamp(1, double.maxFinite))
          .clamp(0.0, 1.0);

  int get focusScore => (completionPercent * 100).round();

  String get formattedElapsed {
    final m = elapsedSeconds ~/ 60;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  String get formattedTotal {
    final m = totalDuration.inMinutes;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  String get aiSummary {
    if (completionPercent >= 0.95) {
      return 'Excellent session! You maintained deep focus for $formattedElapsed with remarkable consistency. Your concentration metrics are in the top tier.';
    } else if (completionPercent >= 0.75) {
      return 'Great effort! You completed ${(completionPercent * 100).round()}% of your planned session — that\'s solid progress. Keep building this habit.';
    } else if (completionPercent >= 0.5) {
      return 'Good start! You focused for $formattedElapsed. Even partial sessions strengthen your attention muscle. Try again when you\'re ready.';
    } else {
      return 'Every session counts. You took the first step by starting. Your next session will be stronger.';
    }
  }
}

// ── Global cross-screen notifiers ─────────────────────────────────────────────

/// Set by AI Session Setup screen; read by Focus screen.
final ValueNotifier<AiRecommendation?> aiRecommendationNotifier =
    ValueNotifier(null);
