// ignore_for_file: avoid_web_libraries_in_flutter, uri_does_not_exist
import 'dart:convert';
import 'dart:js_util' as js_util;

/// Service for interacting with Chrome Extension APIs (Tabs, Windows, Groups)
class ChromeService {
  /// Launches a list of URLs and groups them under the workspace name.
  /// If [shouldCloseOthers] is true, closes existing tabs in the window.
  Future<void> launchWorkspace(String name, List<String> urls, {String? color, bool shouldCloseOthers = false}) async {
    try {
      final String jsonUrls = jsonEncode(urls);
      await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'launchUrls', [jsonUrls, name, color, shouldCloseOthers]),
      );
    } catch (e) {
      print('Error launching workspace: $e');
    }
  }

  /// Queries all open tabs in the current window
  Future<List<Map<String, String>>> getCurrentTabs() async {
    try {
      final String result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'getCurrentTabs', []),
      );
      final List<dynamic> decoded = jsonDecode(result);
      return decoded.map((item) => {
        'url': item['url'] as String,
        'title': item['title'] as String,
      }).toList();
    } catch (e) {
      print('Error getting current tabs: $e');
      return [];
    }
  }

  /// Triggers a JSON file download
  Future<void> downloadWorkspaceJson(String fileName, String jsonString) async {
    try {
      js_util.callMethod(js_util.globalThis, 'downloadJson', [fileName, jsonString]);
    } catch (e) {
      print('Error downloading JSON: $e');
    }
  }

  /// Opens file picker and returns file content
  Future<String?> pickWorkspaceJson() async {
    try {
      final dynamic result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'pickJsonFile', []),
      );
      return result as String?;
    } catch (e) {
      print('Error picking JSON file: $e');
      return null;
    }
  }

  /// Gets Tab Memory Diet settings
  Future<Map<String, dynamic>> getTabDietSettings() async {
    try {
      final String result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'getTabDietSettings', []),
      );
      return Map<String, dynamic>.from(jsonDecode(result));
    } catch (e) {
      print('Error getting Tab Diet settings: $e');
      return {'enabled': true, 'idleMinutes': 60};
    }
  }

  /// Saves Tab Memory Diet settings
  Future<bool> saveTabDietSettings(bool enabled, int idleMinutes) async {
    try {
      final bool success = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'saveTabDietSettings', [enabled, idleMinutes]),
      );
      return success;
    } catch (e) {
      print('Error saving Tab Diet settings: $e');
      return false;
    }
  }

  /// Gets open and sleeping tab statistics
  Future<Map<String, dynamic>> getTabStats() async {
    try {
      final String result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'getTabStats', []),
      );
      return Map<String, dynamic>.from(jsonDecode(result));
    } catch (e) {
      print('Error getting tab stats: $e');
      return {
        'total': 0,
        'sleeping': 0,
        'active': 0,
        'estimatedSavedMB': 0,
      };
    }
  }

  /// Triggers a stale tab discard cycle immediately
  Future<int> discardStaleTabsNow() async {
    try {
      final dynamic result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'discardStaleTabsNow', []),
      );
      return result as int;
    } catch (e) {
      print('Error triggering tab discard: $e');
      return -1;
    }
  }
}
