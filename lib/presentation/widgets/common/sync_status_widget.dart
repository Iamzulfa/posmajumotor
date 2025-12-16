import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

enum SyncStatus { online, offline, syncing }

class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;
  final String? lastSyncTime;
  final int pendingCount;

  const SyncStatusWidget({
    super.key,
    required this.status,
    this.lastSyncTime,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusIndicator(),
        const SizedBox(width: AppSpacing.xs),
        Text(
          _getStatusText(),
          style: TextStyle(fontSize: 12, color: _getStatusColor()),
        ),
        if (pendingCount > 0) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$pendingCount pending',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
        if (lastSyncTime != null && pendingCount == 0) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '• $lastSyncTime',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (status == SyncStatus.syncing) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
        ),
      );
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case SyncStatus.online:
        return 'Online';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.syncing:
        return 'Syncing...';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case SyncStatus.online:
        return AppColors.success;
      case SyncStatus.offline:
        return AppColors.error;
      case SyncStatus.syncing:
        return AppColors.warning;
    }
  }
}
