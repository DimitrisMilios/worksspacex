import 'package:flutter/material.dart';
import '../models/workspace.dart';

class WorkspaceListView extends StatelessWidget {
  final List<Workspace> workspaces;
  final Function(String) onDelete;
  final Function(Workspace) onLaunch;

  const WorkspaceListView({
    super.key,
    required this.workspaces,
    required this.onDelete,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workspaces.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, index) {
        final workspace = workspaces[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onLaunch(workspace),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xff6200ee).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Color(0xff03dac6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workspace.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${workspace.urls.length} resources linked',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButton(
                    icon: Icons.launch_rounded,
                    color: const Color(0xff03dac6),
                    onPressed: () => onLaunch(workspace),
                    tooltip: 'Launch',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent.withOpacity(0.7),
                    onPressed: () => _confirmDelete(context, workspace),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Workspace workspace) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1e1e1e),
        title: const Text('Delete Workspace?'),
        content: Text('Are you sure you want to delete "${workspace.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(workspace.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
