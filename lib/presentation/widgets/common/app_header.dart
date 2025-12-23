import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/routes/app_routes.dart';
import 'sync_status_widget.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final SyncStatus syncStatus;
  final String? lastSyncTime;
  final VoidCallback? onLogout;
  final bool showLogout;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.syncStatus = SyncStatus.online,
    this.lastSyncTime,
    this.onLogout,
    this.showLogout = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Back button (if needed) + Title
              Expanded(
                child: Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed:
                            onBackPressed ?? () => Navigator.of(context).pop(),
                        color: AppColors.textDark,
                        tooltip: 'Kembali',
                      ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right side: Logout button
              if (showLogout)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: onLogout ?? () => context.go(AppRoutes.login),
                  color: AppColors.textGray,
                  tooltip: 'Logout',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SyncStatusWidget(status: syncStatus, lastSyncTime: lastSyncTime),
        ],
      ),
    );
  }
}
