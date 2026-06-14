import 'dart:convert';

/// Represents a single completed focus session.
class FocusSessionRecord {
  FocusSessionRecord({
    required this.durationSeconds,
    required this.sessionType,
    required this.timestamp,
  });

  final int durationSeconds;
  final String sessionType;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'durationSeconds': durationSeconds,
      'sessionType': sessionType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FocusSessionRecord.fromMap(Map<String, dynamic> map) {
    return FocusSessionRecord(
      durationSeconds: map['durationSeconds']?.toInt() ?? 0,
      sessionType: map['sessionType'] ?? 'Deep Work',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FocusSessionRecord.fromJson(String source) => FocusSessionRecord.fromMap(json.decode(source));
}
