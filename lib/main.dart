import 'package:flutter/material.dart';
import 'features/workspaces/providers/workspace_provider.dart';
import 'features/workspaces/widgets/workspace_list_view.dart';
import 'features/workspaces/widgets/add_workspace_dialog.dart';
import 'core/theme/app_colors.dart';
import 'features/workspaces/models/workspace.dart';

void main() {
  runApp(const WorkSpaceXApp());
}

class WorkSpaceXApp extends StatelessWidget {
  const WorkSpaceXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSpaceX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      home: const ExtensionContainer(),
    );
  }
}

class ExtensionContainer extends StatefulWidget {
  const ExtensionContainer({super.key});

  @override
  State<ExtensionContainer> createState() => _ExtensionContainerState();
}

class _ExtensionContainerState extends State<ExtensionContainer> {
  late final WorkspaceProvider _workspaceProvider;

  @override
  void initState() {
    super.initState();
    _workspaceProvider = WorkspaceProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 400,
        height: 550,
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: ListenableBuilder(
          listenable: _workspaceProvider,
          builder: (context, _) {
            if (_workspaceProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _workspaceProvider.workspaces.isEmpty
                      ? _buildEmptyState()
                      : WorkspaceListView(
                          workspaces: _workspaceProvider.workspaces,
                          onDelete: _workspaceProvider.deleteWorkspace,
                          onLaunch: (workspace, cleanSwitch) => 
                              _workspaceProvider.launchWorkspace(workspace, cleanSwitch: cleanSwitch),
                          onEdit: (workspace) => _showEditWorkspaceDialog(context, workspace),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddWorkspaceDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_motion_rounded, 
              color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WorkSpaceX',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'PREMIUM DASHBOARD',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Capture Current Tabs',
            onPressed: () => _handleCapture(context),
            icon: const Icon(Icons.camera_enhance_rounded, 
              color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 48, 
                color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Workspaces Found',
              style: TextStyle(
                color: AppColors.textPrimary, 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture your current session or create a new workspace to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary, 
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddWorkspaceDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Workspace'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.textPrimary,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkspaceDialog(BuildContext context, {String? name, List<String>? urls}) {
    showDialog(
      context: context,
      builder: (context) => AddWorkspaceDialog(
        initialName: name,
        initialUrls: urls,
        onSave: (name, urls, color) {
          _workspaceProvider.addWorkspace(name, urls, color: color);
        },
      ),
    );
  }

  void _showEditWorkspaceDialog(BuildContext context, Workspace workspace) {
    showDialog(
      context: context,
      builder: (context) => AddWorkspaceDialog(
        isEditing: true,
        initialName: workspace.name,
        initialUrls: workspace.urls,
        initialColor: workspace.color,
        onSave: (name, urls, color) {
          _workspaceProvider.updateWorkspace(workspace.id, name, urls, color: color);
        },
      ),
    );
  }

  Future<void> _handleCapture(BuildContext context) async {
    final urls = await _workspaceProvider.getCurrentSessionUrls();
    if (!mounted) return;
    
    if (urls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active tabs found to capture.'),
          backgroundColor: AppColors.surface,
        ),
      );
      return;
    }

    final defaultName = 'Captured ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _showAddWorkspaceDialog(context, name: defaultName, urls: urls);
  }
}
