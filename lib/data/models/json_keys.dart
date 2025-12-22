/// JSON field name mappings for Supabase database columns
class JsonKeys {
  // Common fields
  static const String id = 'id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String createdBy = 'created_by';
  static const String isActive = 'is_active';

  // User fields
  static const String fullName = 'full_name';

  // Product fields
  static const String categoryId = 'category_id';
  static const String brandId = 'brand_id';
  static const String minStock = 'min_stock';
  static const String hargaUmum = 'harga_umum';
  static const String hargaBengkel = 'harga_bengkel';
  static const String hargaGrossir = 'harga_grossir';

  // Transaction fields
  static const String transactionNumber = 'transaction_number';
  static const String customerName = 'customer_name';
  static const String discountAmount = 'discount_amount';
  static const String totalHpp = 'total_hpp';
  static const String paymentMethod = 'payment_method';
  static const String paymentStatus = 'payment_status';
  static const String cashierId = 'cashier_id';
  static const String transactionItems = 'transaction_items';

  // Transaction Item fields
  static const String transactionId = 'transaction_id';
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String productSku = 'product_sku';
  static const String unitPrice = 'unit_price';
  static const String unitHpp = 'unit_hpp';

  // Expense fields
  static const String expenseDate = 'expense_date';

  // Inventory Log fields
  static const String stockBefore = 'stock_before';
  static const String stockAfter = 'stock_after';
  static const String referenceType = 'reference_type';
  static const String referenceId = 'reference_id';

  // Tax Payment fields
  static const String periodMonth = 'period_month';
  static const String periodYear = 'period_year';
  static const String totalOmset = 'total_omset';
  static const String taxAmount = 'tax_amount';
  static const String isPaid = 'is_paid';
  static const String paidAt = 'paid_at';
  static const String paymentProof = 'payment_proof';

  // Relation fields
  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String brands = 'brands';
}
