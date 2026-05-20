import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AddWorkspaceDialog extends StatefulWidget {
  final Function(String, List<String>, String?) onSave;
  final String? initialName;
  final List<String>? initialUrls;
  final String? initialColor;
  final bool isEditing;

  const AddWorkspaceDialog({
    super.key,
    required this.onSave,
    this.initialName,
    this.initialUrls,
    this.initialColor,
    this.isEditing = false,
  });

  @override
  State<AddWorkspaceDialog> createState() => _AddWorkspaceDialogState();
}

class _AddWorkspaceDialogState extends State<AddWorkspaceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlsController;
  String? _selectedColor;

  // Chrome Tab Group Colors
  final List<Map<String, dynamic>> _chromeColors = [
    {'name': 'Grey', 'color': Color(0xFF5F6368)},
    {'name': 'Blue', 'color': Color(0xFF1A73E8)},
    {'name': 'Red', 'color': Color(0xFFD93025)},
    {'name': 'Yellow', 'color': Color(0xFFE37400)},
    {'name': 'Green', 'color': Color(0xFF188038)},
    {'name': 'Pink', 'color': Color(0xFFD01884)},
    {'name': 'Purple', 'color': Color(0xFF9334E6)},
    {'name': 'Cyan', 'color': Color(0xFF007B83)},
    {'name': 'Orange', 'color': Color(0xFFFA903E)},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _urlsController = TextEditingController(
      text: widget.initialUrls?.join('\n'),
    );
    _selectedColor = widget.initialColor ?? 'purple';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEditing ? 'Edit Workspace' : 'New Workspace',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'WORKSPACE NAME',
                hint: 'e.g. Project Apollo',
                icon: Icons.label_important_outline_rounded,
                autofocus: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'GROUP COLOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chromeColors.length,
                  itemBuilder: (context, index) {
                    final colorData = _chromeColors[index];
                    final colorKey = colorData['name'].toString().toLowerCase();
                    final isSelected = _selectedColor == colorKey;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorKey),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorData['color'] as Color,
                          shape: BoxShape.circle,
                          border: isSelected 
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: (colorData['color'] as Color).withOpacity(0.5),
                              blurRadius: 8,
                            )
                          ] : null,
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _urlsController,
                label: 'URL LIST (ONE PER LINE)',
                hint: 'https://...',
                icon: Icons.link_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL', 
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textPrimary,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(widget.isEditing ? 'UPDATE' : 'CREATE', 
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          autofocus: autofocus,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.3)),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
      widget.onSave(name, urls, _selectedColor);
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
