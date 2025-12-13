import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

enum SyncStatus { online, offline, syncing }

class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;
  final String? lastSyncTime;

  const SyncStatusWidget({Key? key, required this.status, this.lastSyncTime})
    : super(key: key);

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
        if (lastSyncTime != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '• Last sync: $lastSyncTime',
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
