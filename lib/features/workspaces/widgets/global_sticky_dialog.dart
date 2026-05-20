import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GlobalStickyDialog extends StatefulWidget {
  final List<String> initialUrls;
  final Function(List<String>) onSave;

  const GlobalStickyDialog({
    super.key,
    required this.initialUrls,
    required this.onSave,
  });

  @override
  State<GlobalStickyDialog> createState() => _GlobalStickyDialogState();
}

class _GlobalStickyDialogState extends State<GlobalStickyDialog> {
  late final TextEditingController _urlsController;

  @override
  void initState() {
    super.initState();
    _urlsController = TextEditingController(text: widget.initialUrls.join('\n'));
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.push_pin_rounded, color: AppColors.secondary, size: 24),
                SizedBox(width: 12),
                Text(
                  'Global Sticky Tabs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'These URLs will automatically launch alongside EVERY workspace you open (e.g., Slack, Gmail, Music).',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'STICKY URL LIST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlsController,
              maxLines: 5,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textSecondary, size: 20),
                hintText: 'https://slack.com\nhttps://mail.google.com',
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
                  borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                ),
              ),
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
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, Color(0xFF7209B7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final urls = _urlsController.text
                          .split('\n')
                          .where((u) => u.trim().isNotEmpty)
                          .map((u) => u.trim())
                          .toList();
                      widget.onSave(urls);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.textPrimary,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('SAVE STICKY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlsController.dispose();
    super.dispose();
  }
}
