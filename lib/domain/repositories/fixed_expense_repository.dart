import 'package:posfelix/data/models/fixed_expense_model.dart';

abstract class FixedExpenseRepository {
  Future<List<FixedExpenseModel>> getFixedExpenses();
  Future<FixedExpenseModel?> getFixedExpenseById(String id);
  Future<FixedExpenseModel> createFixedExpense(FixedExpenseModel expense);
  Future<FixedExpenseModel> updateFixedExpense(FixedExpenseModel expense);
  Future<void> deleteFixedExpense(String id);
  Future<int> getTotalFixedExpenses();
  Stream<List<FixedExpenseModel>> getFixedExpensesStream();
}
