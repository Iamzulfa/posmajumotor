import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/tax_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';

/// Tax center state
class TaxCenterState {
  final int selectedMonth;
  final int selectedYear;
  final TaxCalculation? taxCalculation;
  final ProfitLossReport? profitLossReport;
  final List<TaxPaymentModel> paymentHistory;
  final bool isLoading;
  final String? error;

  TaxCenterState({
    int? selectedMonth,
    int? selectedYear,
    this.taxCalculation,
    this.profitLossReport,
    this.paymentHistory = const [],
    this.isLoading = false,
    this.error,
  }) : selectedMonth = selectedMonth ?? DateTime.now().month,
       selectedYear = selectedYear ?? DateTime.now().year;

  TaxCenterState copyWith({
    int? selectedMonth,
    int? selectedYear,
    TaxCalculation? taxCalculation,
    ProfitLossReport? profitLossReport,
    List<TaxPaymentModel>? paymentHistory,
    bool? isLoading,
    String? error,
  }) {
    return TaxCenterState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      taxCalculation: taxCalculation ?? this.taxCalculation,
      profitLossReport: profitLossReport ?? this.profitLossReport,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get period string
  String get periodString {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[selectedMonth - 1]} $selectedYear';
  }
}

/// Tax center notifier
class TaxCenterNotifier extends StateNotifier<TaxCenterState> {
  final TaxRepository? _repository;

  TaxCenterNotifier(this._repository) : super(TaxCenterState());

  Future<void> loadTaxData() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load tax calculation
      final taxCalculation = await _repository.calculateTax(
        month: state.selectedMonth,
        year: state.selectedYear,
      );

      // Load profit/loss report
      final profitLossReport = await _repository.getProfitLossReport(
        month: state.selectedMonth,
        year: state.selectedYear,
      );

      // Load payment history
      final paymentHistory = await _repository.getTaxPayments(
        year: state.selectedYear,
        limit: 12,
      );

      state = state.copyWith(
        taxCalculation: taxCalculation,
        profitLossReport: profitLossReport,
        paymentHistory: paymentHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSelectedPeriod(int month, int year) {
    state = state.copyWith(selectedMonth: month, selectedYear: year);
    loadTaxData();
  }

  Future<void> markAsPaid({String? paymentProof}) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.markAsPaid(
        month: state.selectedMonth,
        year: state.selectedYear,
        paymentProof: paymentProof,
      );
      await loadTaxData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Tax center provider
final taxCenterProvider =
    StateNotifierProvider<TaxCenterNotifier, TaxCenterState>((ref) {
      final repository = SupabaseConfig.isConfigured
          ? getIt<TaxRepository>()
          : null;
      return TaxCenterNotifier(repository);
    });
