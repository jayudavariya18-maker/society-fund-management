import '../../shared/models/contribution_model.dart';
import '../../shared/models/expense_model.dart';
import '../utils/date_formatter.dart';

class CsvExportService {
  /// Converts contributions list into CSV string
  static String exportContributionsCsv(List<ContributionModel> contributions) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('Receipt Number,Date,Fund,Member / Donor,Flat No,Amount,Contribution Type,Payment Method,Transaction Reference,Status');

    for (final c in contributions) {
      final line = [
        _escape(c.receiptNumber),
        _escape(DateFormatter.formatShort(c.paymentDate)),
        _escape(c.fundName ?? ''),
        _escape(c.memberName ?? 'Anonymous'),
        _escape(c.flatNumber ?? ''),
        c.amount.toStringAsFixed(2),
        _escape(c.contributionType),
        _escape(c.paymentMethod),
        _escape(c.transactionReference ?? ''),
        _escape(c.status),
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Converts expenses list into CSV string
  static String exportExpensesCsv(List<ExpenseModel> expenses) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('Expense ID,Date,Fund,Category,Description,Vendor,Amount,Payment Method,Status,Receipt Reference');

    for (final e in expenses) {
      final line = [
        _escape(e.expenseId),
        _escape(DateFormatter.formatShort(e.expenseDate)),
        _escape(e.fundName ?? ''),
        _escape(e.expenseCategory),
        _escape(e.description),
        _escape(e.vendorName ?? ''),
        e.amount.toStringAsFixed(2),
        _escape(e.paymentMethod),
        _escape(e.status),
        _escape(e.receiptReference ?? ''),
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  static String _escape(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }
}
