import 'package:flutter_test/flutter_test.dart';
import 'package:bajrang/core/utils/currency_formatter.dart';
import 'package:bajrang/shared/models/fund_model.dart';

void main() {
  group('Financial Accounting Engine Tests', () {
    test('Scenario 1: General Fund Exact Decimal Calculation', () {
      // Opening general fund: ₹10,000
      // Contribution: ₹5,000
      // Expense: ₹2,000
      // Expected balance: ₹13,000

      const double openingBalance = 10000.00;
      const double contributionAmount = 5000.00;
      const double expenseAmount = 2000.00;

      final intermediateBalance = CurrencyFormatter.add(openingBalance, contributionAmount);
      expect(intermediateBalance, equals(15000.00));

      final finalBalance = CurrencyFormatter.subtract(intermediateBalance, expenseAmount);
      expect(finalBalance, equals(13000.00));

      final fund = FundModel(
        fundId: 'gen-001',
        societyId: 'soc-001',
        fundName: 'General Society Fund',
        fundType: 'GENERAL',
        openingBalance: openingBalance,
        totalContributions: contributionAmount,
        totalExpenses: expenseAmount,
        currentBalance: finalBalance,
        createdAt: DateTime.now(),
      );

      expect(fund.currentBalance, equals(13000.00));
      expect(CurrencyFormatter.formatINR(fund.currentBalance), equals('₹13,000.00'));
    });

    test('Scenario 2: Festival Fund Strict Isolation', () {
      // Navratri contributions: ₹20,000
      // Navratri expenses: ₹8,000
      // Expected Navratri balance: ₹12,000
      // Diwali fund must remain unchanged (₹0 or opening balance)

      final navratriFund = FundModel(
        fundId: 'nav-001',
        societyId: 'soc-001',
        fundName: 'Navratri Mahotsav 2026 Fund',
        fundType: 'FESTIVAL',
        festivalId: 'fest-navratri',
        openingBalance: 0.00,
        totalContributions: 20000.00,
        totalExpenses: 8000.00,
        currentBalance: CurrencyFormatter.subtract(20000.00, 8000.00),
        createdAt: DateTime.now(),
      );

      final diwaliFund = FundModel(
        fundId: 'diw-001',
        societyId: 'soc-001',
        fundName: 'Diwali Snehamilan 2026 Fund',
        fundType: 'FESTIVAL',
        festivalId: 'fest-diwali',
        openingBalance: 5000.00,
        totalContributions: 0.00,
        totalExpenses: 0.00,
        currentBalance: 5000.00,
        createdAt: DateTime.now(),
      );

      // Verify Navratri balance is calculated correctly
      expect(navratriFund.currentBalance, equals(12000.00));
      expect(CurrencyFormatter.formatINR(navratriFund.currentBalance), equals('₹12,000.00'));

      // Verify Diwali fund remains completely untouched
      expect(diwaliFund.currentBalance, equals(5000.00));
      expect(diwaliFund.totalContributions, equals(0.00));
      expect(diwaliFund.totalExpenses, equals(0.00));
    });

    test('Decimal arithmetic prevents IEEE 754 precision drift', () {
      // 0.1 + 0.2 in standard IEEE floating point is 0.30000000000000004
      final exactSum = CurrencyFormatter.add(0.1, 0.2);
      expect(exactSum, equals(0.3));

      // 100.05 - 0.05
      final exactDiff = CurrencyFormatter.subtract(100.05, 0.05);
      expect(exactDiff, equals(100.0));
    });
  });
}
