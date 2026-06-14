import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import '../services/storage_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider(this._storageService) {
    _loadData();
  }

  final StorageService _storageService;
  List<FocusSessionRecord> _history = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<FocusSessionRecord> get history => _history;

  int get totalSessions => _history.length;

  int get totalFocusSeconds => _history.fold(0, (sum, record) => sum + record.durationSeconds);

  String get totalFocusTimeFormatted {
    final m = totalFocusSeconds ~/ 60;
    final h = m ~/ 60;
    final remM = m % 60;
    if (h > 0) return '${h}h ${remM}m';
    return '${m}m';
  }

  double get averageCompletionPercentage {
    // In this app, a recorded session is typically 100% completed, 
    // but if we recorded partials, we could calculate it. 
    // Let's assume recorded ones in history are 100%.
    if (_history.isEmpty) return 0.0;
    return 100.0; 
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    _history = await _storageService.loadAnalyticsHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSession(FocusSessionRecord record) async {
    debugPrint('Session Completed');
    debugPrint('Session Count Before: ${_history.length}');
    
    _history = [record, ..._history];
    
    debugPrint('Session Count After: ${_history.length}');
    notifyListeners();
    
    await _storageService.saveAnalyticsHistory(_history);
    debugPrint('Analytics Saved');
  }
}
