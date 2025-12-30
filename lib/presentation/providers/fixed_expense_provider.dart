import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/fixed_expense_model.dart';
import 'package:posfelix/domain/repositories/fixed_expense_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'package:posfelix/core/utils/logger.dart';

/// Fixed expense list state
class FixedExpenseListState {
  final List<FixedExpenseModel> expenses;
  final int totalAmount;
  final bool isLoading;
  final String? error;

  const FixedExpenseListState({
    this.expenses = const [],
    this.totalAmount = 0,
    this.isLoading = false,
    this.error,
  });

  FixedExpenseListState copyWith({
    List<FixedExpenseModel>? expenses,
    int? totalAmount,
    bool? isLoading,
    String? error,
  }) {
    return FixedExpenseListState(
      expenses: expenses ?? this.expenses,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Fixed expense list notifier
class FixedExpenseListNotifier extends StateNotifier<FixedExpenseListState> {
  final FixedExpenseRepository? _repository;

  FixedExpenseListNotifier(this._repository)
    : super(const FixedExpenseListState());

  Future<void> loadFixedExpenses() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await _repository.getFixedExpenses();
      final total = expenses.fold<int>(0, (sum, e) => sum + e.amount);

      state = state.copyWith(
        expenses: expenses,
        totalAmount: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createFixedExpense(FixedExpenseModel expense) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createFixedExpense(expense);
      // Immediately refresh data after creation
      await loadFixedExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateFixedExpense(FixedExpenseModel expense) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateFixedExpense(expense);
      // Immediately refresh data after update
      await loadFixedExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteFixedExpense(String id) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteFixedExpense(id);
      // Immediately refresh data after deletion
      await loadFixedExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Fixed expense list provider
final fixedExpenseListProvider =
    StateNotifierProvider<FixedExpenseListNotifier, FixedExpenseListState>((
      ref,
    ) {
      final repository = SupabaseConfig.isConfigured
          ? getIt<FixedExpenseRepository>()
          : null;
      return FixedExpenseListNotifier(repository);
    });

/// Real-time fixed expenses stream provider using Supabase Realtime
final fixedExpensesStreamProvider =
    StreamProvider.autoDispose<List<FixedExpenseModel>>((ref) {
      AppLogger.info(
        '🔧 fixedExpensesStreamProvider called - Using Supabase Realtime',
      );

      if (!SupabaseConfig.isConfigured) {
        AppLogger.info('🔧 Supabase not configured, returning empty stream');
        return Stream.value([]);
      }

      try {
        final supabase = Supabase.instance.client;

        return supabase
            .from('fixed_expenses')
            .stream(primaryKey: ['id'])
            .eq('is_active', true)
            .order('created_at')
            .map((rows) {
              AppLogger.info(
                '🔧 Realtime update: ${rows.length} fixed expenses',
              );
              return rows
                  .map((json) => FixedExpenseModel.fromJson(json))
                  .toList();
            })
            .handleError((error) {
              AppLogger.error('Error in fixed expenses realtime stream', error);
              return <FixedExpenseModel>[];
            });
      } catch (e) {
        AppLogger.error(
          'Failed to initialize fixed expense realtime stream',
          e,
        );
        return Stream.value([]);
      }
    });
