import 'dart:convert';
import 'dart:js_util' as js_util;

/// Service for interacting with Chrome Extension APIs (Tabs, Windows, Groups)
class ChromeService {
  /// Launches a list of URLs and groups them under the workspace name
  Future<void> launchWorkspace(String name, List<String> urls) async {
    try {
      final String jsonUrls = jsonEncode(urls);
      await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'launchUrls', [jsonUrls, name]),
      );
    } catch (e) {
      print('Error launching workspace: $e');
    }
  }
}
