# User-Friendly Error Handling Examples

## Before vs After Comparison

### 1. Login Errors

#### Before (Technical)
```
❌ "Exception: invalid_credentials"
❌ "AuthException: user_not_found"
❌ "SocketException: Failed host lookup"
```

#### After (User-Friendly)
```
✅ "Email atau password salah. Silakan periksa kembali dan coba lagi."
✅ "Akun tidak ditemukan. Silakan periksa email Anda atau hubungi administrator."
✅ "Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi."
```

### 2. Transaction Errors

#### Before (Technical)
```
❌ "type 'Null' is not a subtype of type 'String' in type cast"
❌ "PostgresException: constraint violation"
❌ "Exception: insufficient_stock"
```

#### After (User-Friendly)
```
✅ "Terjadi masalah dengan data transaksi. Silakan coba lagi atau hubungi administrator."
✅ "Data tidak valid. Silakan periksa kembali informasi yang dimasukkan."
✅ "Stok barang tidak mencukupi. Silakan kurangi jumlah atau lakukan restock terlebih dahulu."
```

### 3. Product Management Errors

#### Before (Technical)
```
❌ "duplicate key value violates unique constraint \"products_sku_key\""
❌ "foreign key constraint fails"
❌ "validation error: required field missing"
```

#### After (User-Friendly)
```
✅ "SKU produk sudah ada. Silakan gunakan SKU yang berbeda."
✅ "Data terkait tidak ditemukan. Silakan periksa data yang dipilih."
✅ "Harap lengkapi semua field yang wajib diisi."
```

### 4. Network/Connection Errors

#### Before (Technical)
```
❌ "TimeoutException after 0:00:30.000000"
❌ "SocketException: Connection refused"
❌ "HandshakeException: Handshake error"
```

#### After (User-Friendly)
```
✅ "Koneksi timeout. Silakan periksa koneksi internet Anda dan coba lagi."
✅ "Masalah koneksi internet. Silakan periksa koneksi Anda dan coba lagi."
✅ "Masalah koneksi internet. Silakan periksa koneksi Anda dan coba lagi."
```

## Specific Scenarios

### Stock Management
```dart
// When user tries to add more items than available
ErrorHandler.getStockInsufficientMessage(
  'Aki Kering GTZ5S', 
  available: 5, 
  requested: 10
);
// Result: "Stok Aki Kering GTZ5S tidak mencukupi. Tersedia: 5, diminta: 10. Silakan kurangi jumlah atau lakukan restock."
```

### Authentication
```dart
// When login fails
ErrorHandler.getLoginFailedMessage();
// Result: "Email atau password salah. Silakan periksa kembali dan coba lagi."
```

### Network Issues
```dart
// When offline
ErrorHandler.getNetworkErrorMessage();
// Result: "Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi."
```

### Validation
```dart
// When required field is empty
ErrorHandler.getValidationErrorMessage('Nama Produk');
// Result: "Nama Produk tidak boleh kosong. Silakan lengkapi data yang diperlukan."
```

## UI Implementation Examples

### Error Display Widget
```dart
// Full error display with retry button
ErrorMessageWidget(
  message: 'Stok barang tidak mencukupi. Silakan lakukan restock terlebih dahulu.',
  onRetry: () => _loadProducts(),
  icon: Icons.inventory_2_outlined,
)
```

### Inline Form Error
```dart
// Compact error for forms
InlineErrorWidget(
  message: 'Email tidak boleh kosong',
  icon: Icons.warning_amber_rounded,
)
```

### Success Message
```dart
// Success feedback
SuccessMessageWidget(
  message: 'Produk berhasil ditambahkan ke inventory',
  icon: Icons.check_circle_outline,
)
```

### Snackbar Messages
```dart
// Error snackbar
UserFriendlySnackBar.showError(
  context, 
  'Gagal menyimpan data. Silakan coba lagi.'
);

// Success snackbar
UserFriendlySnackBar.showSuccess(
  context, 
  'Transaksi berhasil disimpan!'
);

// Info snackbar
UserFriendlySnackBar.showInfo(
  context, 
  'Sedang memproses transaksi...'
);
```

## Real-World Usage in App

### Login Screen
When user enters wrong credentials:
- **Before**: "Exception: invalid_credentials"
- **After**: "Email atau password salah. Silakan periksa kembali dan coba lagi."

### Transaction Screen
When trying to buy more than available stock:
- **Before**: "Exception: insufficient stock"
- **After**: "Stok Aki Kering GTZ5S tidak mencukupi. Tersedia: 5, diminta: 10. Silakan kurangi jumlah atau lakukan restock."

### Product Edit Screen
When SKU already exists:
- **Before**: "duplicate key value violates unique constraint"
- **After**: "SKU produk sudah ada. Silakan gunakan SKU yang berbeda."

### Network Issues
When internet connection is lost:
- **Before**: "SocketException: Failed host lookup"
- **After**: "Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi."

## Benefits for Users

1. **Clear Understanding**: Users know exactly what went wrong
2. **Actionable Instructions**: Users know what to do next
3. **No Technical Jargon**: Messages are in plain Indonesian
4. **Professional Feel**: App feels polished and user-friendly
5. **Reduced Frustration**: Users can self-resolve many issues

## Benefits for Developers

1. **Centralized Handling**: All error logic in one place
2. **Easy Maintenance**: Add new error types easily
3. **Consistent Experience**: Same error handling across app
4. **Reduced Support**: Fewer user confusion tickets
5. **Better UX**: Professional error handling

The error handling system now provides a professional, user-friendly experience that helps users understand and resolve issues quickly! 🎉