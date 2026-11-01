import 'package:flutter_test/flutter_test.dart';
import 'package:bajrang/core/services/csv_export_service.dart';
import 'package:bajrang/core/services/receipt_service.dart';
import 'package:bajrang/shared/models/contribution_model.dart';
import 'package:bajrang/shared/models/expense_model.dart';

void main() {
  group('Receipt Generation & CSV Export Tests', () {
    test('ReceiptService generates valid auditable receipt number format', () {
      final receiptNo = ReceiptService.generateReceiptNumber();
      expect(receiptNo, startsWith('REC-'));
      expect(receiptNo.length, equals(15)); // e.g. REC-202610-1234
    });

    test('CsvExportService exports contributions correctly', () {
      final contribs = [
        ContributionModel(
          contributionId: 'c1',
          fundId: 'f1',
          fundName: 'General Fund',
          memberId: 'm1',
          memberName: 'Rajeshbhai Patel',
          flatNumber: 'A-402',
          amount: 3000.00,
          contributionType: 'MONTHLY_MAINTENANCE',
          paymentMethod: 'UPI',
          transactionReference: 'UPI/123',
          paymentDate: DateTime(2026, 10, 1),
          receiptNumber: 'REC-202610-0001',
          createdBy: 'm1',
          createdAt: DateTime.now(),
          status: 'POSTED',
        ),
      ];

      final csv = CsvExportService.exportContributionsCsv(contribs);
      expect(csv, contains('Receipt Number,Date,Fund,Member / Donor'));
      expect(csv, contains('REC-202610-0001'));
      expect(csv, contains('3000.00'));
      expect(csv, contains('Rajeshbhai Patel'));
    });

    test('CsvExportService exports expenses correctly', () {
      final exps = [
        ExpenseModel(
          expenseId: 'e1',
          fundId: 'f1',
          fundName: 'General Fund',
          amount: 8500.00,
          expenseCategory: 'ELECTRICITY',
          description: 'Common meter bill',
          vendorName: 'Torrent Power',
          paymentMethod: 'UPI',
          expenseDate: DateTime(2026, 10, 4),
          createdBy: 'm1',
          createdAt: DateTime.now(),
          status: 'POSTED',
        ),
      ];

      final csv = CsvExportService.exportExpensesCsv(exps);
      expect(csv, contains('Expense ID,Date,Fund,Category,Description,Vendor,Amount'));
      expect(csv, contains('8500.00'));
      expect(csv, contains('Torrent Power'));
      expect(csv, contains('ELECTRICITY'));
    });
  });
}
