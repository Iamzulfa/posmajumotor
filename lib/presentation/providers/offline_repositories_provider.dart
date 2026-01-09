import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline_provider.dart';
import '../../data/repositories/offline_transaction_repository.dart';
import '../../data/repositories/offline_expense_repository.dart';

/// Provider untuk offline transaction repository
final offlineTransactionRepositoryProvider =
    Provider<OfflineTransactionRepository>((ref) {
      final offlineService = ref.watch(offlineServiceProvider);
      return OfflineTransactionRepository(offlineService);
    });

/// Provider untuk offline expense repository
final offlineExpenseRepositoryProvider = Provider<OfflineExpenseRepository>((
  ref,
) {
  final offlineService = ref.watch(offlineServiceProvider);
  return OfflineExpenseRepository(offlineService);
});
