import 'dart:convert';
import 'dart:js_util' as js_util;

/// Service responsible for persisting and retrieving workspace data
/// using the Chrome Storage API via the JavaScript bridge.
class StorageService {
  static const String _workspacesKey = 'workspacex_data';

  /// Saves the list of workspaces as a JSON string.
  /// 
  /// Complex structures are encoded to JSON strings before being passed
  /// across the JS bridge to ensure compatibility.
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
  /// 
  /// Returns an empty list if no data is found or if an error occurs.
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
}
