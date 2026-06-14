import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  final StorageService _storageService;

  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _loadSettings() async {
    _isDarkMode = await _storageService.loadIsDarkMode();
    _notificationsEnabled = await _storageService.loadNotificationsEnabled();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveIsDarkMode(_isDarkMode);
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    await _storageService.saveNotificationsEnabled(_notificationsEnabled);
  }
}
