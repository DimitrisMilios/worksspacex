import 'package:flutter/foundation.dart';
import '../../../core/chrome/chrome_service.dart';

class TabDietProvider extends ChangeNotifier {
  final ChromeService _chromeService = ChromeService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _enabled = true;
  bool get enabled => _enabled;

  int _idleMinutes = 60;
  int get idleMinutes => _idleMinutes;

  int _totalTabs = 0;
  int get totalTabs => _totalTabs;

  int _sleepingTabs = 0;
  int get sleepingTabs => _sleepingTabs;

  int _activeTabs = 0;
  int get activeTabs => _activeTabs;

  int _estimatedSavedMB = 0;
  int get estimatedSavedMB => _estimatedSavedMB;

  TabDietProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final settings = await _chromeService.getTabDietSettings();
      _enabled = settings['enabled'] as bool? ?? true;
      _idleMinutes = settings['idleMinutes'] as int? ?? 60;

      await refreshStats();
    } catch (e) {
      print('Error loading tab diet data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    try {
      final stats = await _chromeService.getTabStats();
      _totalTabs = stats['total'] as int? ?? 0;
      _sleepingTabs = stats['sleeping'] as int? ?? 0;
      _activeTabs = stats['active'] as int? ?? 0;
      _estimatedSavedMB = stats['estimatedSavedMB'] as int? ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error refreshing tab stats: $e');
    }
  }

  Future<void> toggleEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    await _chromeService.saveTabDietSettings(_enabled, _idleMinutes);
    if (_enabled) {
      await hibernateNow();
    }
  }

  Future<void> setIdleMinutes(int minutes) async {
    _idleMinutes = minutes;
    notifyListeners();
    await _chromeService.saveTabDietSettings(_enabled, _idleMinutes);
  }

  Future<bool> hibernateNow() async {
    final success = await _chromeService.discardStaleTabsNow();
    if (success) {
      await refreshStats();
    }
    return success;
  }
}
