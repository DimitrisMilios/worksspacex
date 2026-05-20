// ignore_for_file: avoid_web_libraries_in_flutter, uri_does_not_exist
import 'dart:convert';
import 'dart:js_util' as js_util;

/// Service responsible for persisting and retrieving workspace data
/// using the Chrome Storage API via the JavaScript bridge.
class StorageService {
  static const String _workspacesKey = 'workspacex_data';
  static const String _globalUrlsKey = 'workspacex_global_urls';

  /// Saves the list of workspaces as a JSON string.
  Future<bool> saveWorkspaces(List<dynamic> workspaces) async {
    try {
      final String jsonString = jsonEncode(workspaces);
      final bool success = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'saveToStorage', [_workspacesKey, jsonString]),
      );
      return success;
    } catch (e) {
      print('Error saving workspaces: $e');
      return false;
    }
  }

  /// Retrieves the list of workspaces from storage.
  Future<List<dynamic>> getWorkspaces() async {
    try {
      final dynamic result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'getFromStorage', [_workspacesKey]),
      );
      
      if (result == null || result is! String) {
        return [];
      }
      
      final List<dynamic> workspaces = jsonDecode(result) as List<dynamic>;
      return workspaces;
    } catch (e) {
      print('Error loading workspaces: $e');
      return [];
    }
  }

  /// Saves the list of global sticky URLs.
  Future<bool> saveGlobalUrls(List<String> urls) async {
    try {
      final String jsonString = jsonEncode(urls);
      final bool success = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'saveToStorage', [_globalUrlsKey, jsonString]),
      );
      return success;
    } catch (e) {
      print('Error saving global URLs: $e');
      return false;
    }
  }

  /// Retrieves the list of global sticky URLs.
  Future<List<String>> getGlobalUrls() async {
    try {
      final dynamic result = await js_util.promiseToFuture(
        js_util.callMethod(js_util.globalThis, 'getFromStorage', [_globalUrlsKey]),
      );
      
      if (result == null || result is! String) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(result);
      return decoded.cast<String>();
    } catch (e) {
      print('Error loading global URLs: $e');
      return [];
    }
  }
}
