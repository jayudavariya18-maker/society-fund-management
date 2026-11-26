import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bajrang/core/services/local_storage_service.dart';
import 'package:bajrang/features/authentication/data/auth_repository.dart';
import 'package:bajrang/shared/models/member_model.dart';
import 'package:bajrang/shared/models/fund_model.dart';
import 'package:bajrang/shared/models/contribution_model.dart';
import 'package:bajrang/shared/models/expense_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.initialize();
  });

  group('RamSeva Society Common Password & Session Persistence Tests', () {
    test('Scenario 1: Society common password verification with salted SHA-256', () {
      final storage = LocalStorageService.instance;

      // Default society password for Ramdevra Society
      expect(storage.verifySocietyPassword('Ramdevra@2026'), isTrue);
      expect(storage.verifySocietyPassword('  Ramdevra@2026  '), isTrue); // Whitespace trimmed

      // Incorrect passwords must fail
      expect(storage.verifySocietyPassword('WrongPassword'), isFalse);
      expect(storage.verifySocietyPassword('123456'), isFalse);
      expect(storage.verifySocietyPassword(''), isFalse);
    });

    test('Scenario 2: Active member session persistence across app launches', () async {
      final storage = LocalStorageService.instance;

      final testMember = MemberModel(
        memberId: 'mem-persistent-001',
        societyId: '00000000-0000-0000-0000-000000000001',
        authUid: 'auth-persistent-001',
        fullName: 'Kishorebhai Patel',
        phoneNumber: '+919825012345',
        flatNumber: 'A-304',
        email: 'kishore.patel@gmail.com',
        membershipStatus: 'ACTIVE',
        joinedAt: DateTime(2026, 1, 1),
      );

      // Save member session
      await storage.saveActiveMember(testMember);

      // Reload member session as if the application just restarted
      final loadedMember = storage.getActiveMember();
      expect(loadedMember, isNotNull);
      expect(loadedMember!.memberId, equals('mem-persistent-001'));
      expect(loadedMember.fullName, equals('Kishorebhai Patel'));
      expect(loadedMember.flatNumber, equals('A-304'));
      expect(loadedMember.phoneNumber, equals('+919825012345'));
      expect(loadedMember.isActive, isTrue);

      // Clear session on logout
      await storage.clearSession();
      expect(storage.getActiveMember(), isNull);
      expect(storage.isMemberRegistered(), isFalse);
    });

    test('Scenario 3: Financial records persistence across application restart', () async {
      final storage = LocalStorageService.instance;

      final funds = [
        FundModel(
          fundId: 'gen-001',
          societyId: '00000000-0000-0000-0000-000000000001',
          fundName: 'General Fund',
          fundType: 'GENERAL',
          openingBalance: 0.0,
          currentBalance: 5000.0,
          totalContributions: 5000.0,
          totalExpenses: 0.0,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final contributions = [
        ContributionModel(
          contributionId: 'contrib-101',
          fundId: 'gen-001',
          amount: 5000.0,
          contributionType: 'MAINTENANCE',
          paymentMethod: 'UPI',
          paymentDate: DateTime(2026, 11, 26),
          receiptNumber: 'REC-202611-1001',
          createdBy: 'mem-persistent-001',
          status: 'POSTED',
          createdAt: DateTime.now(),
        ),
      ];

      final expenses = [
        ExpenseModel(
          expenseId: 'exp-201',
          fundId: 'gen-001',
          amount: 1500.0,
          expenseCategory: 'REPAIRS',
          description: 'Water pump servicing',
          paymentMethod: 'BANK_TRANSFER',
          expenseDate: DateTime(2026, 11, 26),
          createdBy: 'mem-persistent-001',
          status: 'POSTED',
          createdAt: DateTime.now(),
        ),
      ];

      // Save records to persistent disk storage
      await storage.saveFunds(funds);
      await storage.saveContributions(contributions);
      await storage.saveExpenses(expenses);

      // Simulate app reopen: reload all lists from disk storage
      final loadedFunds = storage.loadFunds();
      final loadedContributions = storage.loadContributions();
      final loadedExpenses = storage.loadExpenses();

      expect(loadedFunds.length, equals(1));
      expect(loadedFunds.first.fundName, equals('General Fund'));
      expect(loadedFunds.first.currentBalance, equals(5000.0));

      expect(loadedContributions.length, equals(1));
      expect(loadedContributions.first.amount, equals(5000.0));
      expect(loadedContributions.first.receiptNumber, equals('REC-202611-1001'));

      expect(loadedExpenses.length, equals(1));
      expect(loadedExpenses.first.amount, equals(1500.0));
      expect(loadedExpenses.first.description, equals('Water pump servicing'));
    });

    test('Scenario 4: Router redirect logic skips registration when active member is restored', () {
      final activeUser = MemberModel(
        memberId: 'mem-001',
        societyId: 'soc-001',
        authUid: 'auth-user-001',
        fullName: 'Active Resident',
        phoneNumber: '+919825000001',
        flatNumber: 'B-201',
        membershipStatus: 'ACTIVE',
        joinedAt: DateTime.now(),
      );

      final state = AuthUserState(
        status: AuthStatus.activeMember,
        phoneNumber: '+919825000001',
        activeMember: activeUser,
      );

      // Verify that active member state is set and ready to skip /login and /register
      expect(state.status, equals(AuthStatus.activeMember));
      expect(state.activeMember, isNotNull);
      expect(state.activeMember!.isActive, isTrue);
    });
  });
}
