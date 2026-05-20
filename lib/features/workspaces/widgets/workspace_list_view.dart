import 'package:flutter/material.dart';
import '../models/workspace.dart';
import '../../../core/theme/app_colors.dart';

class WorkspaceListView extends StatelessWidget {
  final List<Workspace> workspaces;
  final Function(String) onDelete;
  final Function(Workspace, bool) onLaunch;
  final Function(Workspace) onEdit;
  final Function(Workspace) onShare;

  const WorkspaceListView({
    super.key,
    required this.workspaces,
    required this.onDelete,
    required this.onLaunch,
    required this.onEdit,
    required this.onShare,
  });

  Color _getWorkspaceColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'grey': return const Color(0xFF5F6368);
      case 'blue': return const Color(0xFF1A73E8);
      case 'red': return const Color(0xFFD93025);
      case 'yellow': return const Color(0xFFE37400);
      case 'green': return const Color(0xFF188038);
      case 'pink': return const Color(0xFFD01884);
      case 'purple': return const Color(0xFF9334E6);
      case 'cyan': return const Color(0xFF007B83);
      case 'orange': return const Color(0xFFFA903E);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workspaces.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, index) {
        final workspace = workspaces[index];
        final displayColor = _getWorkspaceColor(workspace.color);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onLaunch(workspace, false),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: displayColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: displayColor.withOpacity(0.5)),
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: displayColor,
                      size: 22,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildFaviconRow(workspace.urls),
                            if (workspace.urls.length > 4) ...[
                              const SizedBox(width: 8),
                              Text(
                                '+${workspace.urls.length - 4}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: displayColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (workspace.color ?? 'Purple').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: displayColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.share_rounded,
                            color: AppColors.accent,
                            onPressed: () => onShare(workspace),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: AppColors.textSecondary,
                            onPressed: () => onEdit(workspace),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.redAccent.withOpacity(0.7),
                            onPressed: () => _confirmDelete(context, workspace),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.published_with_changes_rounded,
                            color: AppColors.accent,
                            onPressed: () => onLaunch(workspace, true), // Clean Switch
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.play_arrow_rounded,
                            color: displayColor,
                            onPressed: () => onLaunch(workspace, false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaviconRow(List<String> urls) {
    final displayUrls = urls.take(4).toList();
    return Row(
      children: displayUrls.map((url) {
        final domain = _getDomain(url);
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              'https://www.google.com/s2/favicons?sz=64&domain=$domain',
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.language_rounded,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDomain(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return '';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Workspace', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to remove "${workspace.name}"?', 
          style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete(workspace.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
