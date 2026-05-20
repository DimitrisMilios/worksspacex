import 'package:flutter/material.dart';

class AddWorkspaceDialog extends StatefulWidget {
  final Function(String, List<String>) onAdd;

  const AddWorkspaceDialog({super.key, required this.onAdd});

  @override
  State<AddWorkspaceDialog> createState() => _AddWorkspaceDialogState();
}

class _AddWorkspaceDialogState extends State<AddWorkspaceDialog> {
  final _nameController = TextEditingController();
  final _urlsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xff1e1e1e),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Workspace',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Workspace Name',
              hint: 'e.g. WorkSpaceX Mobile',
              icon: Icons.label_outline_rounded,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _urlsController,
              label: 'URLs (one per line)',
              hint: 'https://github.com\nhttps://linear.app',
              icon: Icons.link_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6200ee),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xff03dac6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          autofocus: autofocus,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff6200ee), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final urls = _urlsController.text
        .split('\n')
        .where((u) => u.trim().isNotEmpty)
        .map((u) => u.trim())
        .toList();

    if (name.isNotEmpty && urls.isNotEmpty) {
      widget.onAdd(name, urls);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlsController.dispose();
    super.dispose();
  }
}
