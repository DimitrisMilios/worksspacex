import 'package:flutter/material.dart';
import '../providers/tab_diet_provider.dart';
import '../../../core/theme/app_colors.dart';

class TabDietView extends StatefulWidget {
  final TabDietProvider provider;

  const TabDietView({super.key, required this.provider});

  @override
  State<TabDietView> createState() => _TabDietViewState();
}

class _TabDietViewState extends State<TabDietView> {
  bool _isHibernating = false;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final double sleepRatio = provider.totalTabs > 0 
            ? provider.sleepingTabs / provider.totalTabs 
            : 0.0;

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => provider.refreshStats(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Memory Savings Glassmorphic Card
              _buildMemorySavingsCard(provider),
              const SizedBox(height: 20),

              // Configuration Card
              _buildSettingsCard(provider),
              const SizedBox(height: 20),

              // Stats Card
              _buildStatsCard(provider, sleepRatio),
              const SizedBox(height: 24),

              // Action Button
              _buildActionButton(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemorySavingsCard(TabDietProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          // RAM Saved Icon with glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED RAM RECOVERED',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.estimatedSavedMB} MB',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(TabDietProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppColors.accent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Memory Diet Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Switch(
                value: provider.enabled,
                onChanged: (val) => provider.toggleEnabled(val),
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.2),
                inactiveThumbColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.border,
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discard idle tabs after',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tabs freeze to free RAM',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: AppColors.surface,
                ),
                child: DropdownButton<int>(
                  value: provider.idleMinutes,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: provider.enabled
                      ? (val) {
                          if (val != null) provider.setIdleMinutes(val);
                        }
                      : null,
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 Min')),
                    DropdownMenuItem(value: 30, child: Text('30 Min')),
                    DropdownMenuItem(value: 60, child: Text('1 Hour')),
                    DropdownMenuItem(value: 120, child: Text('2 Hours')),
                    DropdownMenuItem(value: 240, child: Text('4 Hours')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(TabDietProvider provider, double sleepRatio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tab Statistics',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => provider.refreshStats(),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: 'Refresh stats',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: sleepRatio,
                backgroundColor: AppColors.border,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatSubItem('Active', '${provider.activeTabs}', AppColors.primary),
              _buildStatSubItem('Sleeping', '${provider.sleepingTabs}', AppColors.accent),
              _buildStatSubItem('Total Tabs', '${provider.totalTabs}', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSubItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(TabDietProvider provider) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: provider.enabled && !_isHibernating
            ? AppColors.primaryGradient
            : null,
        color: !provider.enabled || _isHibernating ? AppColors.border : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: provider.enabled && !_isHibernating
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: provider.enabled && !_isHibernating
            ? () async {
                setState(() => _isHibernating = true);
                final success = await provider.hibernateNow();
                if (mounted) {
                  setState(() => _isHibernating = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success 
                          ? 'Stale tabs hibernated successfully!' 
                          : 'No stale tabs matched the idle time limit.',
                      ),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isHibernating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Hibernate Stale Tabs Now',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
