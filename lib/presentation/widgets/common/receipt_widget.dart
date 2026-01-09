import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/transaction_model.dart';

class ReceiptWidget extends StatelessWidget {
  final TransactionModel transaction;
  final bool isCompact;

  const ReceiptWidget({
    super.key,
    required this.transaction,
    this.isCompact = false,
  });

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
        return 'Tunai';
      case 'TRANSFER':
        return 'Transfer';
      case 'QRIS':
        return 'QRIS';
      default:
        return method;
    }
  }

  String _getTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'UMUM':
        return 'Orang Umum';
      case 'BENGKEL':
        return 'Bengkel';
      case 'GROSSIR':
        return 'Grossir';
      default:
        return tier;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: AppSpacing.md,
      tabletValue: AppSpacing.lg,
      desktopValue: 16,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
                topRight: Radius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STRUK TRANSAKSI',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 14,
                      tabletSize: 16,
                      desktopSize: 18,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'No. ${transaction.transactionNumber}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 12,
                      tabletSize: 13,
                      desktopSize: 14,
                    ),
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.md),

                // Date & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.formattedDate,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                    Text(
                      transaction.formattedTime,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),
                Divider(color: AppColors.border),
                SizedBox(height: AppSpacing.md),

                // Customer Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tipe Pembeli:',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                    Text(
                      _getTierLabel(transaction.tier),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                if (transaction.customerName != null &&
                    transaction.customerName!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Pembeli:',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 12,
                            tabletSize: 13,
                            desktopSize: 14,
                          ),
                          color: AppColors.textGray,
                        ),
                      ),
                      Text(
                        transaction.customerName!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 12,
                            tabletSize: 13,
                            desktopSize: 14,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: AppSpacing.md),
                Divider(color: AppColors.border),
                SizedBox(height: AppSpacing.md),

                // Items
                if (!isCompact && transaction.items != null)
                  ...transaction.items!.map((item) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.productName,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                          context,
                                          phoneSize: 12,
                                          tabletSize: 13,
                                          desktopSize: 14,
                                        ),
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Rp ${_formatCurrency(item.subtotal)}',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        phoneSize: 12,
                                        tabletSize: 13,
                                        desktopSize: 14,
                                      ),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${item.quantity}x @ Rp ${_formatCurrency(item.unitPrice)}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 11,
                                tabletSize: 12,
                                desktopSize: 13,
                              ),
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                SizedBox(height: AppSpacing.md),
                Divider(color: AppColors.border),
                SizedBox(height: AppSpacing.md),

                // Totals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                    Text(
                      'Rp ${_formatCurrency(transaction.subtotal)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),

                if (transaction.discountAmount > 0) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diskon:',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 12,
                            tabletSize: 13,
                            desktopSize: 14,
                          ),
                          color: AppColors.textGray,
                        ),
                      ),
                      Text(
                        '- Rp ${_formatCurrency(transaction.discountAmount)}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 12,
                            tabletSize: 13,
                            desktopSize: 14,
                          ),
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: AppSpacing.md),
                Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: AppSpacing.md),
                        child: Text(
                          'TOTAL:',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 14,
                              tabletSize: 15,
                              desktopSize: 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: AppSpacing.md),
                        child: Text(
                          'Rp ${_formatCurrency(transaction.total)}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 14,
                              tabletSize: 15,
                              desktopSize: 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Payment Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metode Pembayaran:',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                    Text(
                      _getPaymentMethodLabel(transaction.paymentMethod),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        color: AppColors.textGray,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                      ),
                      child: Text(
                        transaction.paymentStatus,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 11,
                            tabletSize: 12,
                            desktopSize: 13,
                          ),
                          fontWeight: FontWeight.w600,
                          color: transaction.isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
