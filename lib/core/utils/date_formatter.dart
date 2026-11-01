import 'package:intl/intl.dart';

class DateFormatter {
  /// Format date to Indian standard format: DD/MM/YYYY
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date to readable standard: 15 Oct 2026
  static String formatMedium(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date and time: 15 Oct 2026, 04:30 PM
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  /// Parse ISO date string safely
  static DateTime parseSafe(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    if (dateStr is DateTime) return dateStr;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
