import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Format numeric amounts into Indian Currency notation:
  /// Examples:
  /// 150000 -> ₹1,50,000.00
  /// 5000   -> ₹5,000.00
  static String formatINR(num amount, {bool showDecimals = true}) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: showDecimals ? 2 : 0,
    );
    return format.format(amount);
  }

  /// Compact Indian notation (e.g. ₹1.5 L, ₹25 K) for dashboard stat cards
  static String formatCompactINR(num amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      final crStr = cr.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return '₹$crStr Cr';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      final lakhStr = lakh.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return '₹$lakhStr L';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      final kStr = k.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '');
      return '₹$kStr K';
    }
    return formatINR(amount, showDecimals: false);
  }

  /// Exact addition ensuring no IEEE 754 floating point inaccuracies
  static double add(double a, double b) {
    return ((a * 100).round() + (b * 100).round()) / 100.0;
  }

  /// Exact subtraction
  static double subtract(double a, double b) {
    return ((a * 100).round() - (b * 100).round()) / 100.0;
  }
}
