import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import 'daily_expense_tab_v2.dart';
import 'fixed_expense_tab.dart';
import 'transaction_history_tab.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late DateTime _selectedDate;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true; // Keep tabs alive when switching

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Keuangan',
              syncStatus: SyncStatus.online,
              lastSyncTime: 'Real-time',
            ),
            // Tab Bar
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textGray,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(fontSize: 12),
                tabs: const [
                  Tab(text: 'Pengeluaran'),
                  Tab(text: 'Biaya Tetap'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DailyExpenseTabV2(
                    // 🔥 USE NEW WORKING VERSION
                    selectedDate: _selectedDate,
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                  const FixedExpenseTab(),
                  const TransactionHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      // 🔥 REMOVED: Floating action button - now using universal gradient "Tambah" button in headers
    );
  }

  // 🔥 REMOVED: _showAddFixedExpenseDialog method since it's no longer used
  // Fixed expense tab now handles its own "Tambah" functionality
}
