import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger.dart';

/// Utility class for handling errors and converting them to user-friendly messages
class ErrorHandler {
  /// Convert technical errors to user-friendly messages
  static String getErrorMessage(dynamic error) {
    AppLogger.error('Processing error for user message', error);

    if (error == null) {
      return 'Terjadi kesalahan yang tidak diketahui';
    }

    final errorString = error.toString().toLowerCase();

    // Authentication errors
    if (_isAuthError(error, errorString)) {
      return _getAuthErrorMessage(error, errorString);
    }

    // Network/Connection errors
    if (_isNetworkError(errorString)) {
      return _getNetworkErrorMessage(errorString);
    }

    // Database/Supabase errors
    if (_isDatabaseError(error, errorString)) {
      return _getDatabaseErrorMessage(error, errorString);
    }

    // Stock/Inventory errors
    if (_isStockError(errorString)) {
      return _getStockErrorMessage(errorString);
    }

    // Validation errors
    if (_isValidationError(errorString)) {
      return _getValidationErrorMessage(errorString);
    }

    // Permission errors
    if (_isPermissionError(errorString)) {
      return 'Anda tidak memiliki izin untuk melakukan tindakan ini. Silakan hubungi administrator.';
    }

    // Generic fallback
    return _getGenericErrorMessage(errorString);
  }

  // Authentication error detection and messages
  static bool _isAuthError(dynamic error, String errorString) {
    if (error is AuthException) return true;
    return errorString.contains('auth') ||
        errorString.contains('login') ||
        errorString.contains('password') ||
        errorString.contains('email') ||
        errorString.contains('invalid_credentials') ||
        errorString.contains('user_not_found') ||
        errorString.contains('invalid_grant');
  }

  static String _getAuthErrorMessage(dynamic error, String errorString) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
        case 'invalid_credentials':
          return 'Email atau password salah. Silakan periksa kembali dan coba lagi.';
        case 'user not found':
        case 'user_not_found':
          return 'Akun tidak ditemukan. Silakan periksa email Anda atau hubungi administrator.';
        case 'email not confirmed':
          return 'Email belum dikonfirmasi. Silakan cek email Anda untuk link konfirmasi.';
        case 'too many requests':
          return 'Terlalu banyak percobaan login. Silakan tunggu beberapa menit dan coba lagi.';
        default:
          return 'Gagal masuk. Silakan periksa email dan password Anda.';
      }
    }

    if (errorString.contains('invalid') &&
        errorString.contains('credentials')) {
      return 'Email atau password salah. Silakan periksa kembali dan coba lagi.';
    }

    return 'Gagal masuk. Silakan periksa email dan password Anda.';
  }

  // Network error detection and messages
  static bool _isNetworkError(String errorString) {
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable') ||
        errorString.contains('no internet') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('socketexception');
  }

  static String _getNetworkErrorMessage(String errorString) {
    if (errorString.contains('timeout')) {
      return 'Koneksi timeout. Silakan periksa koneksi internet Anda dan coba lagi.';
    }
    if (errorString.contains('no internet') ||
        errorString.contains('failed host lookup')) {
      return 'Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi.';
    }
    return 'Masalah koneksi internet. Silakan periksa koneksi Anda dan coba lagi.';
  }

  // Database error detection and messages
  static bool _isDatabaseError(dynamic error, String errorString) {
    return errorString.contains('supabase') ||
        errorString.contains('postgresql') ||
        errorString.contains('database') ||
        errorString.contains('constraint') ||
        errorString.contains('foreign key') ||
        errorString.contains('unique') ||
        errorString.contains('duplicate');
  }

  static String _getDatabaseErrorMessage(dynamic error, String errorString) {
    if (errorString.contains('unique') || errorString.contains('duplicate')) {
      if (errorString.contains('email')) {
        return 'Email sudah terdaftar. Silakan gunakan email lain atau login dengan akun yang ada.';
      }
      if (errorString.contains('sku')) {
        return 'SKU produk sudah ada. Silakan gunakan SKU yang berbeda.';
      }
      return 'Data sudah ada dalam sistem. Silakan gunakan data yang berbeda.';
    }

    if (errorString.contains('foreign key')) {
      return 'Data terkait tidak ditemukan. Silakan periksa data yang dipilih.';
    }

    if (errorString.contains('constraint')) {
      return 'Data tidak valid. Silakan periksa kembali informasi yang dimasukkan.';
    }

    return 'Terjadi masalah dengan database. Silakan coba lagi atau hubungi administrator.';
  }

  // Stock error detection and messages
  static bool _isStockError(String errorString) {
    return errorString.contains('stock') ||
        errorString.contains('inventory') ||
        errorString.contains('out of stock') ||
        errorString.contains('insufficient') ||
        errorString.contains('quantity');
  }

  static String _getStockErrorMessage(String errorString) {
    if (errorString.contains('out of stock') ||
        errorString.contains('insufficient')) {
      return 'Stok barang tidak mencukupi. Silakan kurangi jumlah atau lakukan restock terlebih dahulu.';
    }
    if (errorString.contains('quantity')) {
      return 'Jumlah yang diminta melebihi stok tersedia. Silakan sesuaikan jumlah pembelian.';
    }
    return 'Masalah dengan stok barang. Silakan periksa ketersediaan stok dan coba lagi.';
  }

  // Validation error detection and messages
  static bool _isValidationError(String errorString) {
    return errorString.contains('validation') ||
        errorString.contains('required') ||
        errorString.contains('invalid format') ||
        errorString.contains('must be') ||
        errorString.contains('cannot be empty');
  }

  static String _getValidationErrorMessage(String errorString) {
    if (errorString.contains('email') && errorString.contains('invalid')) {
      return 'Format email tidak valid. Silakan masukkan email yang benar.';
    }
    if (errorString.contains('password') && errorString.contains('too short')) {
      return 'Password terlalu pendek. Minimal 6 karakter.';
    }
    if (errorString.contains('required') ||
        errorString.contains('cannot be empty')) {
      return 'Harap lengkapi semua field yang wajib diisi.';
    }
    return 'Data yang dimasukkan tidak valid. Silakan periksa kembali.';
  }

  // Permission error detection
  static bool _isPermissionError(String errorString) {
    return errorString.contains('permission') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden') ||
        errorString.contains('access denied') ||
        errorString.contains('not allowed');
  }

  // Generic error message
  static String _getGenericErrorMessage(String errorString) {
    // Try to extract meaningful parts from technical errors
    if (errorString.contains('failed')) {
      return 'Operasi gagal. Silakan coba lagi atau hubungi administrator jika masalah berlanjut.';
    }
    if (errorString.contains('error')) {
      return 'Terjadi kesalahan. Silakan coba lagi dalam beberapa saat.';
    }
    if (errorString.contains('exception')) {
      return 'Terjadi masalah teknis. Silakan coba lagi atau hubungi administrator.';
    }

    return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi atau hubungi administrator jika masalah berlanjut.';
  }

  /// Get specific error message for common scenarios
  static String getStockInsufficientMessage(
    String productName,
    int available,
    int requested,
  ) {
    return 'Stok $productName tidak mencukupi. Tersedia: $available, diminta: $requested. Silakan kurangi jumlah atau lakukan restock.';
  }

  static String getLoginFailedMessage() {
    return 'Email atau password salah. Silakan periksa kembali dan coba lagi.';
  }

  static String getNetworkErrorMessage() {
    return 'Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi.';
  }

  static String getServerErrorMessage() {
    return 'Server sedang bermasalah. Silakan coba lagi dalam beberapa saat.';
  }

  static String getValidationErrorMessage(String field) {
    return '$field tidak boleh kosong. Silakan lengkapi data yang diperlukan.';
  }
}
