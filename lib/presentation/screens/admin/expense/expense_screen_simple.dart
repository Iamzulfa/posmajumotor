import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';

class ExpenseScreenSimple extends ConsumerStatefulWidget {
  const ExpenseScreenSimple({super.key});

  @override
  ConsumerState<ExpenseScreenSimple> createState() =>
      _ExpenseScreenSimpleState();
}

class _ExpenseScreenSimpleState extends ConsumerState<ExpenseScreenSimple>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                children: [_buildDailyExpenseTab(), _buildFixedExpenseTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Simple action for now
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _tabController.index == 0
                    ? 'Tambah Pengeluaran Harian'
                    : 'Tambah Pengeluaran Tetap',
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0
              ? 'Tambah Pengeluaran'
              : 'Tambah Pengeluaran Tetap',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDailyExpenseTab() {
    return const Center(
      child: Text(
        'Daily Expenses Tab - Working',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFixedExpenseTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple Total Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pengeluaran Tetap (Bulanan)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rp 25.000.000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Simple Header
          const Text(
            'Rincian Pengeluaran Tetap',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Simple List
          Expanded(
            child: ListView(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.people, color: Colors.blue),
                    ),
                    title: const Text(
                      'Gaji Sinot',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Gaji bulanan karyawan'),
                    trailing: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp 25.000.000',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
