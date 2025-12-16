import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/tax_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class TaxRepositoryImpl implements TaxRepository {
  final SupabaseClient _client;

  TaxRepositoryImpl(this._client);

  @override
  Future<TaxPaymentModel?> getTaxPayment({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _client
          .from('tax_payments')
          .select('*, users(*)')
          .eq('period_month', month)
          .eq('period_year', year)
          .maybeSingle();

      if (response == null) return null;
      return TaxPaymentModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching tax payment', e);
      rethrow;
    }
  }

  @override
  Future<List<TaxPaymentModel>> getTaxPayments({int? year, int? limit}) async {
    try {
      var query = _client.from('tax_payments').select('*, users(*)');

      if (year != null) {
        query = query.eq('period_year', year);
      }

      // Execute with order and limit
      final response = await query
          .order('period_year', ascending: false)
          .order('period_month', ascending: false)
          .limit(limit ?? 12);

      return response.map((json) => TaxPaymentModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching tax payments', e);
      rethrow;
    }
  }

  @override
  Future<TaxCalculation> calculateTax({
    required int month,
    required int year,
  }) async {
    try {
      // Get start and end of month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      // Get total omset from transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('total')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      int totalOmset = 0;
      for (final row in transactionResponse) {
        totalOmset += (row['total'] as num).toInt();
      }

      // Calculate tax (0.5%)
      final taxAmount = (totalOmset * 0.005).round();

      // Check if already paid
      final existingPayment = await getTaxPayment(month: month, year: year);
      final isPaid = existingPayment?.isPaid ?? false;

      return TaxCalculation(
        month: month,
        year: year,
        totalOmset: totalOmset,
        taxAmount: taxAmount,
        isPaid: isPaid,
      );
    } catch (e) {
      AppLogger.error('Error calculating tax', e);
      rethrow;
    }
  }

  @override
  Future<TaxPaymentModel> markAsPaid({
    required int month,
    required int year,
    String? paymentProof,
  }) async {
    try {
      // Calculate tax first
      final calculation = await calculateTax(month: month, year: year);

      // Check if record exists
      final existing = await getTaxPayment(month: month, year: year);

      if (existing != null) {
        // Update existing
        final response = await _client
            .from('tax_payments')
            .update({
              'is_paid': true,
              'paid_at': DateTime.now().toIso8601String(),
              'payment_proof': paymentProof,
              'total_omset': calculation.totalOmset,
              'tax_amount': calculation.taxAmount,
            })
            .eq('id', existing.id)
            .select()
            .single();

        AppLogger.info('Tax payment updated: $month/$year');
        return TaxPaymentModel.fromJson(response);
      } else {
        // Create new
        final response = await _client
            .from('tax_payments')
            .insert({
              'period_month': month,
              'period_year': year,
              'total_omset': calculation.totalOmset,
              'tax_amount': calculation.taxAmount,
              'is_paid': true,
              'paid_at': DateTime.now().toIso8601String(),
              'payment_proof': paymentProof,
              'created_by': _client.auth.currentUser?.id,
            })
            .select()
            .single();

        AppLogger.info('Tax payment created: $month/$year');
        return TaxPaymentModel.fromJson(response);
      }
    } catch (e) {
      AppLogger.error('Error marking tax as paid', e);
      rethrow;
    }
  }

  @override
  Future<ProfitLossReport> getProfitLossReport({
    required int month,
    required int year,
  }) async {
    try {
      // Get start and end of month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      final startDateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      // Get transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('tier, total, total_hpp, profit')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Get expenses
      final expenseResponse = await _client
          .from('expenses')
          .select('amount')
          .gte('expense_date', startDateStr)
          .lte('expense_date', endDateStr);

      // Calculate totals
      int totalOmset = 0;
      int totalHpp = 0;

      final Map<String, TierReportDetail> tierBreakdown = {};

      // Initialize tier breakdown
      for (final tier in ['UMUM', 'BENGKEL', 'GROSSIR']) {
        tierBreakdown[tier] = TierReportDetail(
          tier: tier,
          transactionCount: 0,
          omset: 0,
          hpp: 0,
          profit: 0,
        );
      }

      // Process transactions
      for (final row in transactionResponse) {
        final tier = row['tier'] as String;
        final omset = (row['total'] as num).toInt();
        final hpp = (row['total_hpp'] as num).toInt();
        final profit = (row['profit'] as num).toInt();

        totalOmset += omset;
        totalHpp += hpp;

        final existing = tierBreakdown[tier]!;
        tierBreakdown[tier] = TierReportDetail(
          tier: tier,
          transactionCount: existing.transactionCount + 1,
          omset: existing.omset + omset,
          hpp: existing.hpp + hpp,
          profit: existing.profit + profit,
        );
      }

      // Calculate expenses
      int totalExpenses = 0;
      for (final row in expenseResponse) {
        totalExpenses += (row['amount'] as num).toInt();
      }

      final grossProfit = totalOmset - totalHpp;
      final netProfit = grossProfit - totalExpenses;

      return ProfitLossReport(
        month: month,
        year: year,
        totalOmset: totalOmset,
        totalHpp: totalHpp,
        totalExpenses: totalExpenses,
        grossProfit: grossProfit,
        netProfit: netProfit,
        tierBreakdown: tierBreakdown,
      );
    } catch (e) {
      AppLogger.error('Error getting profit/loss report', e);
      rethrow;
    }
  }

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  @override
  Stream<TaxCalculation> calculateTaxStream({
    required int month,
    required int year,
  }) {
    // Get start and end of month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    // Stream transactions for the month
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .asyncMap((data) async {
          // Filter transactions for the month
          final transactions = data.where((row) {
            final createdAt = DateTime.tryParse(row['created_at'] ?? '');
            if (createdAt == null) return false;
            return createdAt.isAfter(startDate) &&
                createdAt.isBefore(endDate) &&
                row['payment_status'] == 'COMPLETED';
          }).toList();

          int totalOmset = 0;
          for (final row in transactions) {
            totalOmset += (row['total'] as num).toInt();
          }

          // Calculate tax (0.5%)
          final taxAmount = (totalOmset * 0.005).round();

          // Check if already paid
          final existingPayment = await getTaxPayment(month: month, year: year);
          final isPaid = existingPayment?.isPaid ?? false;

          return TaxCalculation(
            month: month,
            year: year,
            totalOmset: totalOmset,
            taxAmount: taxAmount,
            isPaid: isPaid,
          );
        })
        .handleError((error) {
          AppLogger.error('Error streaming tax calculation', error);
        });
  }

  @override
  Stream<ProfitLossReport> getProfitLossReportStream({
    required int month,
    required int year,
  }) {
    // Get start and end of month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    // Stream transactions for the month
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .asyncMap((data) async {
          // Filter transactions for the month
          final transactions = data.where((row) {
            final createdAt = DateTime.tryParse(row['created_at'] ?? '');
            if (createdAt == null) return false;
            return createdAt.isAfter(startDate) &&
                createdAt.isBefore(endDate) &&
                row['payment_status'] == 'COMPLETED';
          }).toList();

          // Calculate totals
          int totalOmset = 0;
          int totalHpp = 0;

          final Map<String, TierReportDetail> tierBreakdown = {};

          // Initialize tier breakdown
          for (final tier in ['UMUM', 'BENGKEL', 'GROSSIR']) {
            tierBreakdown[tier] = TierReportDetail(
              tier: tier,
              transactionCount: 0,
              omset: 0,
              hpp: 0,
              profit: 0,
            );
          }

          // Process transactions
          for (final row in transactions) {
            final tier = row['tier'] as String;
            final omset = (row['total'] as num).toInt();
            final hpp = (row['total_hpp'] as num).toInt();
            final profit = (row['profit'] as num).toInt();

            totalOmset += omset;
            totalHpp += hpp;

            final existing = tierBreakdown[tier]!;
            tierBreakdown[tier] = TierReportDetail(
              tier: tier,
              transactionCount: existing.transactionCount + 1,
              omset: existing.omset + omset,
              hpp: existing.hpp + hpp,
              profit: existing.profit + profit,
            );
          }

          // Get expenses (need to fetch separately)
          final startDateStr =
              '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
          final endDateStr =
              '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

          final expenseResponse = await _client
              .from('expenses')
              .select('amount')
              .gte('expense_date', startDateStr)
              .lte('expense_date', endDateStr);

          int totalExpenses = 0;
          for (final row in expenseResponse) {
            totalExpenses += (row['amount'] as num).toInt();
          }

          final grossProfit = totalOmset - totalHpp;
          final netProfit = grossProfit - totalExpenses;

          return ProfitLossReport(
            month: month,
            year: year,
            totalOmset: totalOmset,
            totalHpp: totalHpp,
            totalExpenses: totalExpenses,
            grossProfit: grossProfit,
            netProfit: netProfit,
            tierBreakdown: tierBreakdown,
          );
        })
        .handleError((error) {
          AppLogger.error('Error streaming profit/loss report', error);
        });
  }

  @override
  Stream<List<TaxPaymentModel>> getTaxPaymentsStream({int? year, int? limit}) {
    try {
      return _client
          .from('tax_payments')
          .stream(primaryKey: ['id'])
          .map((data) {
            var payments = data
                .map((json) => TaxPaymentModel.fromJson(json))
                .toList();

            // Apply filters
            if (year != null) {
              payments = payments.where((p) => p.periodYear == year).toList();
            }

            // Sort by period descending
            payments.sort((a, b) {
              final yearCompare = b.periodYear.compareTo(a.periodYear);
              if (yearCompare != 0) return yearCompare;
              return b.periodMonth.compareTo(a.periodMonth);
            });

            // Apply limit
            if (limit != null && payments.length > limit) {
              payments = payments.take(limit).toList();
            }

            return payments;
          })
          .handleError((error) {
            AppLogger.error('Error streaming tax payments', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up tax payments stream', e);
      rethrow;
    }
  }
}
