import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class ExpenseModel with _$ExpenseModel {
  const ExpenseModel._();

  const factory ExpenseModel({
    required String id,
    required String category,
    required int amount,
    String? description,
    @JsonKey(name: 'expense_date') required DateTime expenseDate,

    // Metadata
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    // Relations (optional)
    UserModel? creator,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  /// Get formatted date
  String get formattedDate {
    return '${expenseDate.day}/${expenseDate.month}/${expenseDate.year}';
  }

  /// Get category display name
  String get categoryDisplayName {
    return ExpenseCategoryX.fromString(category).displayName;
  }
}

/// Expense categories enum
enum ExpenseCategory {
  @JsonValue('LISTRIK')
  listrik,
  @JsonValue('GAJI')
  gaji,
  @JsonValue('PLASTIK')
  plastik,
  @JsonValue('MAKAN_SIANG')
  makanSiang,
  @JsonValue('PEMBELIAN_STOK')
  pembelianStok,
  @JsonValue('LAINNYA')
  lainnya,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get value {
    switch (this) {
      case ExpenseCategory.listrik:
        return 'LISTRIK';
      case ExpenseCategory.gaji:
        return 'GAJI';
      case ExpenseCategory.plastik:
        return 'PLASTIK';
      case ExpenseCategory.makanSiang:
        return 'MAKAN_SIANG';
      case ExpenseCategory.pembelianStok:
        return 'PEMBELIAN_STOK';
      case ExpenseCategory.lainnya:
        return 'LAINNYA';
    }
  }

  String get displayName {
    switch (this) {
      case ExpenseCategory.listrik:
        return 'Listrik';
      case ExpenseCategory.gaji:
        return 'Gaji';
      case ExpenseCategory.plastik:
        return 'Plastik';
      case ExpenseCategory.makanSiang:
        return 'Makan Siang';
      case ExpenseCategory.pembelianStok:
        return 'Pembelian Stok';
      case ExpenseCategory.lainnya:
        return 'Lainnya';
    }
  }

  static ExpenseCategory fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LISTRIK':
        return ExpenseCategory.listrik;
      case 'GAJI':
        return ExpenseCategory.gaji;
      case 'PLASTIK':
        return ExpenseCategory.plastik;
      case 'MAKAN_SIANG':
        return ExpenseCategory.makanSiang;
      case 'PEMBELIAN_STOK':
        return ExpenseCategory.pembelianStok;
      default:
        return ExpenseCategory.lainnya;
    }
  }
}
