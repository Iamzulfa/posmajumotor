class AppConstants {
  // App Info
  static const String appName = 'MotoParts POS';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userKey = 'user';
  static const String productsKey = 'products';
  static const String transactionsKey = 'transactions';
  static const String expensesKey = 'expenses';
  static const String cartKey = 'cart';

  // Pagination
  static const int pageSize = 20;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxNoteLength = 500;

  // Tax Configuration
  static const double taxPercentage = 0.005; // 0.5%

  // Buyer Tiers
  static const String tierUmum = 'UMUM';
  static const String tierBengkel = 'BENGKEL';
  static const String tierGrossir = 'GROSSIR';

  // Payment Methods
  static const String paymentCash = 'CASH';
  static const String paymentTransfer = 'TRANSFER';
  static const String paymentQris = 'QRIS';

  // Expense Categories
  static const String expenseListrik = 'LISTRIK';
  static const String expenseGaji = 'GAJI';
  static const String expensePlastik = 'PLASTIK';
  static const String expenseMakanSiang = 'MAKAN_SIANG';
  static const String expenseLainnya = 'LAINNYA';

  // Refund Categories
  static const String refundRusak = 'RUSAK';
  static const String refundTidakSesuai = 'TIDAK_SESUAI';
  static const String refundTidakDiperlukan = 'TIDAK_DIPERLUKAN';

  // Date Format
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
}
