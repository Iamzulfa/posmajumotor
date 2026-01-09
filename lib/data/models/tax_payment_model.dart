import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'tax_payment_model.freezed.dart';
part 'tax_payment_model.g.dart';

@freezed
class TaxPaymentModel with _$TaxPaymentModel {
  const TaxPaymentModel._();

  const factory TaxPaymentModel({
    required String id,
    @JsonKey(name: 'period_month') required int periodMonth,
    @JsonKey(name: 'period_year') required int periodYear,

    // Amounts
    @JsonKey(name: 'total_omset') @Default(0) int totalOmset,
    @JsonKey(name: 'tax_amount') @Default(0) int taxAmount,

    // Payment info
    @JsonKey(name: 'is_paid') @Default(false) bool isPaid,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
    @JsonKey(name: 'payment_proof') String? paymentProof,

    // Metadata
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    // Relations (optional)
    @JsonKey(name: 'users') UserModel? creator,
  }) = _TaxPaymentModel;

  factory TaxPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$TaxPaymentModelFromJson(json);

  /// Get period as string (e.g., "Desember 2025")
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
    return '${months[periodMonth - 1]} $periodYear';
  }

  /// Get formatted paid date
  String get formattedPaidDate {
    if (paidAt == null) return '-';
    return '${paidAt!.day}/${paidAt!.month}/${paidAt!.year}';
  }

  /// Calculate tax from omset (0.5%)
  static int calculateTax(int omset) {
    return (omset * 0.005).round();
  }
}
