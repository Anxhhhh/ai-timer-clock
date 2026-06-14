import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../services/gemini_service.dart';
import '../../../../services/tts_service.dart';
import '../../domain/models/focus_session.dart';

/// Manages the lifecycle of a single focus timer session.
/// Uses plain Dart [Timer] and callback-driven notifications so the owning
/// [State] can call [setState] without needing ChangeNotifier / Provider.
class FocusTimerController {
  FocusTimerController({
    required Duration initialDuration,
    required SessionType initialType,
    required this.onTick,
    required this.onComplete,
    bool autoStart = false,
  })  : _totalDuration = initialDuration,
        _sessionType = initialType,
        _startTime = DateTime.now() {
    if (autoStart) start();
  }

  // ── State ──────────────────────────────────────────────────────
  Duration _totalDuration;
  SessionType _sessionType;
  int _elapsedSeconds = 0;
  TimerState _state = TimerState.idle;
  DateTime _startTime;
  Timer? _periodicTimer;

  bool _halfwayTriggered = false;
  bool _tenSecondsTriggered = false;
  bool _completedTriggered = false;

  bool _halfwayPreGenTriggered = false;
  bool _tenSecPreGenTriggered = false;
  bool _compPreGenTriggered = false;

  final Map<String, String> _announcementCache = {};

  final _geminiService = GeminiService();
  final _ttsService = TtsService();

  // ── Callbacks ─────────────────────────────────────────────────
  final void Function() onTick;
  final void Function(FocusSessionResult) onComplete;

  // ── Getters ───────────────────────────────────────────────────
  TimerState get state => _state;
  SessionType get sessionType => _sessionType;
  Duration get totalDuration => _totalDuration;
  int get elapsedSeconds => _elapsedSeconds;

  int get remainingSeconds =>
      (_totalDuration.inSeconds - _elapsedSeconds).clamp(0, _totalDuration.inSeconds);

  /// Progress from 0.0 (start) → 1.0 (complete).
  double get progress =>
      (_elapsedSeconds / _totalDuration.inSeconds.clamp(1, double.maxFinite))
          .clamp(0.0, 1.0);

  /// Formatted countdown string — shows h:mm:ss when ≥ 1 hour.
  String get timeLabel {
    final s = remainingSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// Human-readable total duration, e.g. "25m" or "1h 30m".
  String get durationLabel {
    final m = _totalDuration.inMinutes;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  /// Badge label shown below the timer ring: "Deep Work • 25m".
  String get sessionBadgeLabel =>
      '${_sessionType.label} • $durationLabel';

  int get completionPercent => (progress * 100).round();
  int get elapsedMinutes => _elapsedSeconds ~/ 60;

  // ── Timer control ─────────────────────────────────────────────

  void start() {
    if (_state == TimerState.running || _state == TimerState.completed) return;
    _state = TimerState.running;
    _startTime = DateTime.now();
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
    onTick();
  }

  void pause() {
    if (_state != TimerState.running) return;
    _periodicTimer?.cancel();
    _state = TimerState.paused;
    onTick();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    _state = TimerState.running;
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
    onTick();
  }

  void reset() {
    _periodicTimer?.cancel();
    _elapsedSeconds = 0;
    _state = TimerState.idle;
    _halfwayTriggered = false;
    _tenSecondsTriggered = false;
    _completedTriggered = false;
    _halfwayPreGenTriggered = false;
    _tenSecPreGenTriggered = false;
    _compPreGenTriggered = false;
    _announcementCache.clear();
    onTick();
  }

  /// Switch to a new session type/duration. Resets the timer.
  void updateSession({
    required Duration duration,
    required SessionType type,
  }) {
    _periodicTimer?.cancel();
    _totalDuration = duration;
    _sessionType = type;
    _elapsedSeconds = 0;
    _state = TimerState.idle;
    _halfwayTriggered = false;
    _tenSecondsTriggered = false;
    _completedTriggered = false;
    _halfwayPreGenTriggered = false;
    _tenSecPreGenTriggered = false;
    _compPreGenTriggered = false;
    _announcementCache.clear();
    onTick();
  }

  void dispose() {
    _periodicTimer?.cancel();
  }

  // ── Internal ──────────────────────────────────────────────────

  void _onTick(Timer timer) {
    _elapsedSeconds++;

    final remaining = remainingSeconds;
    final total = _totalDuration.inSeconds;

    // --- PRE-GENERATION TRIGGERS ---

    // Halfway Pre-Gen (At 45% elapsed)
    if (total > 0 && _elapsedSeconds == (total * 0.45).toInt() && !_halfwayPreGenTriggered) {
      _halfwayPreGenTriggered = true;
      _preGenerate('halfway', remaining);
    }

    // 10 Seconds Pre-Gen (At 15s remaining)
    if (remaining == 15 && !_tenSecPreGenTriggered) {
      _tenSecPreGenTriggered = true;
      _preGenerate('10seconds', remaining);
    }

    // Completion Pre-Gen (At 3s remaining)
    if (remaining == 3 && !_compPreGenTriggered) {
      _compPreGenTriggered = true;
      _preGenerate('completed', remaining);
    }

    // --- ACTUAL CHECKPOINT TRIGGERS ---

    // Halfway Speak (At 50% elapsed)
    if (total > 0 && _elapsedSeconds == total ~/ 2 && !_halfwayTriggered) {
      _halfwayTriggered = true;
      _speakCachedMessage('halfway');
    }

    // 10 Seconds Speak (At 10s remaining)
    if (remaining == 10 && !_tenSecondsTriggered) {
      _tenSecondsTriggered = true;
      _speakCachedMessage('10seconds');
    }

    // Completed Speak (At 0s remaining)
    if (remaining <= 0 && !_completedTriggered) {
      _completedTriggered = true;
      _speakCachedMessage('completed');
    }

    if (_elapsedSeconds >= _totalDuration.inSeconds) {
      _elapsedSeconds = _totalDuration.inSeconds;
      _state = TimerState.completed;
      timer.cancel();
      onComplete(FocusSessionResult(
        totalDuration: _totalDuration,
        elapsedSeconds: _elapsedSeconds,
        sessionType: _sessionType,
        startTime: _startTime,
      ));
    }
    onTick();
  }

  /// Async fire-and-forget: fetches from Gemini and saves to cache.
  Future<void> _preGenerate(String type, int remainingTime) async {
    debugPrint('Timer: Pre-generating message for $type checkpoint...');
    try {
      final msg = await _geminiService.generateMotivationalMessage(
        remainingTime: Duration(seconds: remainingTime),
        checkpointType: type,
        sessionType: _sessionType.label,
      );
      _announcementCache[type] = msg;
      debugPrint('Timer: Cached Message Ready for $type: "$msg"');
    } catch (e) {
      debugPrint('Timer Error: Pre-gen failed for $type - $e');
    }
  }

  /// Instantly retrieves cached string and plays it, or uses fallback if Gemini was slow.
  void _speakCachedMessage(String type) {
    debugPrint('Timer: Checkpoint Triggered -> $type');
    final cachedMsg = _announcementCache[type];
    if (cachedMsg != null && cachedMsg.isNotEmpty) {
      debugPrint('Timer: Speaking Message (Cached)');
      _ttsService.speak(cachedMsg);
    } else {
      debugPrint('Timer: Cache miss for $type. Using fallback message.');
      final fallbackMsg = _geminiService.getFallbackMessage(type);
      _ttsService.speak(fallbackMsg);
    }
  }
}
