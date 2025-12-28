import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/transaction_provider.dart';
import 'receipt_screen.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTier = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(todayTransactionsStreamProvider);

    final syncStatus = transactionsAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Riwayat Transaksi',
              syncStatus: syncStatus,
              lastSyncTime: 'Real-time',
            ),
            _buildFilterBar(),
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  // Filter transactions
                  var filtered = transactions;

                  if (_selectedTier != 'ALL') {
                    filtered = filtered
                        .where((t) => t.tier == _selectedTier)
                        .toList();
                  }

                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered
                        .where(
                          (t) =>
                              t.transactionNumber.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              (t.customerName?.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ??
                                  false),
                        )
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size:
                                ResponsiveUtils.getResponsiveIconSize(context) *
                                3,
                            color: AppColors.textGray,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Tidak ada transaksi',
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

                  return ListView.builder(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final transaction = filtered[index];
                      return _buildTransactionCard(context, transaction);
                    },
                  );
                },
                loading: () => const LoadingWidget(),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size:
                            ResponsiveUtils.getResponsiveIconSize(context) * 3,
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
                            ref.invalidate(todayTransactionsStreamProvider),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nomor transaksi atau nama pembeli...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 10,
                tabletValue: 12,
                desktopValue: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          SizedBox(height: AppSpacing.md),
          // Tier filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'Semua'),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip('UMUM', 'Orang Umum'),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip('BENGKEL', 'Bengkel'),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip('GROSSIR', 'Grossir'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedTier == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedTier = value);
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textGray,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
  ) {
    String _formatCurrency(int amount) {
      return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
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

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReceiptScreen(transactionId: transaction.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
          child: Padding(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: AppSpacing.md,
              tabletValue: AppSpacing.lg,
              desktopValue: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.transactionNumber,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 14,
                                tabletSize: 15,
                                desktopSize: 16,
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            '${transaction.formattedDate} ${transaction.formattedTime}',
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                      ),
                      child: Text(
                        _getTierLabel(transaction.tier),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 11,
                            tabletSize: 12,
                            desktopSize: 13,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
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
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profit:',
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
                      'Rp ${_formatCurrency(transaction.profit)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 13,
                          desktopSize: 14,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
