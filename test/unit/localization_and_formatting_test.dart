import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bajrang/app/localization/app_localizations.dart';
import 'package:bajrang/core/utils/currency_formatter.dart';
import 'package:bajrang/core/utils/date_formatter.dart';
import 'package:bajrang/core/utils/validators.dart';

void main() {
  group('Multilingual & Formatting Unit Tests', () {
    test('Scenario 7: Multilingual switching EN -> GU -> HI with immutable financial figures', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locGu = AppLocalizations(const Locale('gu'));
      final locHi = AppLocalizations(const Locale('hi'));

      const testBalance = 150000.00;
      final formattedBalance = CurrencyFormatter.formatINR(testBalance);

      // Verify English interface strings
      expect(locEn.appTitle, equals('Bajrang Society'));
      expect(locEn.generalFund, equals('General Society Fund'));
      expect(locEn.addContribution, equals('Add Contribution'));

      // Verify Gujarati interface strings
      expect(locGu.appTitle, equals('બજરંગ સોસાયટી'));
      expect(locGu.generalFund, equals('સામાન્ય સોસાયટી ફંડ'));
      expect(locGu.addContribution, equals('આવક / ફાળો ઉમેરો'));

      // Verify Hindi interface strings
      expect(locHi.appTitle, equals('बजरंग सोसाइटी'));
      expect(locHi.generalFund, equals('सामान्य सोसाइटी फंड'));
      expect(locHi.addContribution, equals('योगदान / शुल्क जोड़ें'));

      // Financial figures remain consistent across all language changes!
      expect(formattedBalance, equals('₹1,50,000.00'));
    });

    test('Indian Currency Formatter properly displays thousands, lakhs and crores', () {
      expect(CurrencyFormatter.formatINR(5000), equals('₹5,000.00'));
      expect(CurrencyFormatter.formatINR(75000), equals('₹75,000.00'));
      expect(CurrencyFormatter.formatINR(150000), equals('₹1,50,000.00'));
      expect(CurrencyFormatter.formatCompactINR(150000), equals('₹1.5 L'));
      expect(CurrencyFormatter.formatCompactINR(2500000), equals('₹25 L'));
      expect(CurrencyFormatter.formatCompactINR(10000000), equals('₹1 Cr'));
    });

    test('Date Formatter formats Indian short format dd/MM/yyyy', () {
      final date = DateTime(2026, 10, 15, 18, 30);
      expect(DateFormatter.formatShort(date), equals('15/10/2026'));
      expect(DateFormatter.formatMedium(date), equals('15 Oct 2026'));
    });

    test('Validators validate Indian phone numbers and non-zero positive amounts', () {
      expect(Validators.validIndianPhone('9825000001', 'Invalid'), isNull);
      expect(Validators.validIndianPhone('+919825000001', 'Invalid'), isNull);
      expect(Validators.validIndianPhone('12345', 'Invalid'), equals('Invalid'));
      expect(Validators.validIndianPhone('0825000001', 'Invalid'), equals('Invalid'));

      expect(Validators.positiveAmount('100', 'Invalid'), isNull);
      expect(Validators.positiveAmount('0', 'Invalid'), equals('Invalid'));
      expect(Validators.positiveAmount('-50', 'Invalid'), equals('Invalid'));
      expect(Validators.positiveAmount('abc', 'Invalid'), equals('Invalid'));
    });
  });
}
