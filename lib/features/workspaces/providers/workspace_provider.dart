import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/chrome/chrome_service.dart';
import '../models/workspace.dart';

class WorkspaceProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ChromeService _chromeService = ChromeService();
  List<Workspace> _workspaces = [];
  List<String> _globalUrls = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<Workspace> get workspaces {
    if (_searchQuery.isEmpty) return _workspaces;
    return _workspaces.where((w) {
      final nameMatch = w.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final urlMatch = w.urls.any((u) => u.toLowerCase().contains(_searchQuery.toLowerCase()));
      return nameMatch || urlMatch;
    }).toList();
  }

  List<String> get globalUrls => _globalUrls;
  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  WorkspaceProvider() {
    loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    _isLoading = true;
    notifyListeners();

    final workspaceData = await _storageService.getWorkspaces();
    _workspaces = workspaceData.map((item) => Workspace.fromJson(item as Map<String, dynamic>)).toList();
    
    _globalUrls = await _storageService.getGlobalUrls();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateGlobalUrls(List<String> urls) async {
    _globalUrls = urls;
    notifyListeners();
    await _storageService.saveGlobalUrls(urls);
  }

  Future<void> addWorkspace(String name, List<String> urls, {String? color}) async {
    final newWorkspace = Workspace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      urls: urls,
      color: color,
    );
    _workspaces.add(newWorkspace);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateWorkspace(String id, String name, List<String> urls, {String? color}) async {
    final index = _workspaces.indexWhere((w) => w.id == id);
    if (index != -1) {
      _workspaces[index] = _workspaces[index].copyWith(
        name: name,
        urls: urls,
        color: color,
      );
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteWorkspace(String id) async {
    _workspaces.removeWhere((w) => w.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> launchWorkspace(Workspace workspace, {bool cleanSwitch = false}) async {
    // Merge workspace URLs with global sticky URLs
    final allUrls = [..._globalUrls, ...workspace.urls];
    
    await _chromeService.launchWorkspace(
      workspace.name, 
      allUrls,
      color: workspace.color,
      shouldCloseOthers: cleanSwitch,
    );
  }

  Future<List<String>> getCurrentSessionUrls() async {
    final tabs = await _chromeService.getCurrentTabs();
    return tabs.map((t) => t['url']!).toList();
  }

  Future<void> exportWorkspace(Workspace workspace) async {
    final jsonString = jsonEncode(workspace.toJson());
    final fileName = '${workspace.name.replaceAll(' ', '_')}_workspace.json';
    await _chromeService.downloadWorkspaceJson(fileName, jsonString);
  }

  Future<void> importWorkspace() async {
    final jsonString = await _chromeService.pickWorkspaceJson();
    if (jsonString != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        final importedWorkspace = Workspace.fromJson(data);
        
        // Check if ID already exists, if so generate a new one
        if (_workspaces.any((w) => w.id == importedWorkspace.id)) {
          final newWorkspace = importedWorkspace.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: '${importedWorkspace.name} (Imported)',
          );
          _workspaces.add(newWorkspace);
        } else {
          _workspaces.add(importedWorkspace);
        }
        
        notifyListeners();
        await _saveToStorage();
      } catch (e) {
        print('Error importing workspace: $e');
      }
    }
  }

  Future<void> _saveToStorage() async {
    await _storageService.saveWorkspaces(_workspaces.map((w) => w.toJson()).toList());
  }
}
