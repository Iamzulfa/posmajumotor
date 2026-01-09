import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/receipt_widget.dart';
import '../../../providers/transaction_provider.dart';

class ReceiptScreen extends ConsumerWidget {
  final String transactionId;

  const ReceiptScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(
      transactionDetailProvider(transactionId),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: transactionAsync.when(
          data: (transaction) {
            if (transaction == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: ResponsiveUtils.getResponsiveIconSize(context) * 3,
                      color: AppColors.textGray,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Transaksi tidak ditemukan',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 14,
                          tabletSize: 16,
                          desktopSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  AppHeader(
                    title: 'Detail Transaksi',
                    syncStatus: SyncStatus.online,
                    lastSyncTime: 'Real-time',
                  ),
                  Padding(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    child: Column(
                      children: [
                        ReceiptWidget(transaction: transaction),
                        SizedBox(height: AppSpacing.lg),
                        _buildActionButtons(context, transaction),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 3,
                  color: AppColors.error,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  '$error',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 14,
                      tabletSize: 16,
                      desktopSize: 18,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(transactionDetailProvider(transactionId)),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: AppSpacing.md,
      tabletSpacing: AppSpacing.lg,
      desktopSpacing: 16,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => _printReceipt(context, transaction),
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => _shareReceipt(context, transaction),
                  icon: const Icon(Icons.share),
                  label: const Text('Bagikan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Tutup'),
          ),
        ),
      ],
    );
  }

  void _printReceipt(BuildContext context, TransactionModel transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur cetak akan segera tersedia'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement print functionality using pdf package
  }

  void _shareReceipt(BuildContext context, TransactionModel transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur bagikan akan segera tersedia'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement share functionality
  }
}
