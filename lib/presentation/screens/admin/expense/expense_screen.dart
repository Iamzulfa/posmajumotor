import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import 'daily_expense_tab_v2.dart'; // 🔥 USE NEW WORKING VERSION
import 'fixed_expense_tab.dart';
import 'expense_form_modal.dart';
// 🔥 REMOVED: fixed_expense_form_modal.dart import (no longer used)

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
    _tabController = TabController(length: 2, vsync: this);
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
              title: 'Pengeluaran',
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
                tabs: const [
                  Tab(text: 'Pengeluaran Harian'),
                  Tab(text: 'Pengeluaran Tetap'),
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
                ],
              ),
            ),
          ],
        ),
      ),
      // 🔥 REMOVED: Floating action button - now using universal gradient "Tambah" button in headers
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showExpenseFormModal(context);
  }

  // 🔥 REMOVED: _showAddFixedExpenseDialog method since it's no longer used
  // Fixed expense tab now handles its own "Tambah" functionality
}
