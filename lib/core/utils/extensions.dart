import 'package:intl/intl.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }
}

extension IntExtensions on int {
  String toCurrency() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  String toFormattedString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

extension DoubleExtensions on double {
  String toCurrency() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  String toPercentage({int decimals = 2}) {
    return '${toStringAsFixed(decimals)}%';
  }
}

extension DateTimeExtensions on DateTime {
  String toFormattedDate() {
    final formatter = DateFormat('dd/MM/yyyy', 'id_ID');
    return formatter.format(this);
  }

  String toFormattedTime() {
    final formatter = DateFormat('HH:mm:ss', 'id_ID');
    return formatter.format(this);
  }

  String toFormattedDateTime() {
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss', 'id_ID');
    return formatter.format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension ListExtensions<T> on List<T> {
  List<T> removeDuplicates() {
    return toSet().toList();
  }

  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
