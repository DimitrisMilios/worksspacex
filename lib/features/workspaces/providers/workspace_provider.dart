import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/chrome/chrome_service.dart';
import '../models/workspace.dart';

class WorkspaceProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ChromeService _chromeService = ChromeService();
  List<Workspace> _workspaces = [];
  bool _isLoading = true;

  List<Workspace> get workspaces => _workspaces;
  bool get isLoading => _isLoading;

  WorkspaceProvider() {
    loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    _isLoading = true;
    notifyListeners();

    final data = await _storageService.getWorkspaces();
    _workspaces = data.map((item) => Workspace.fromJson(item as Map<String, dynamic>)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWorkspace(String name, List<String> urls) async {
    final newWorkspace = Workspace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      urls: urls,
    );
    _workspaces.add(newWorkspace);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> deleteWorkspace(String id) async {
    _workspaces.removeWhere((w) => w.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> launchWorkspace(Workspace workspace) async {
    await _chromeService.launchWorkspace(workspace.name, workspace.urls);
  }

  Future<void> _saveToStorage() async {
    await _storageService.saveWorkspaces(_workspaces.map((w) => w.toJson()).toList());
  }
}
