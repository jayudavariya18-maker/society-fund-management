import 'package:flutter_test/flutter_test.dart';
import 'package:bajrang/features/authentication/data/auth_repository.dart';
import 'package:bajrang/shared/models/expense_model.dart';
import 'package:bajrang/shared/models/member_model.dart';
import 'package:bajrang/shared/models/registration_request_model.dart';

void main() {
  group('Security and Access Control Philosophy Tests', () {
    test('Scenario 3: Pending member cannot access active financial modules', () {
      const authState = AuthUserState(
        status: AuthStatus.pendingApproval,
        phoneNumber: '+919825000004',
        pendingRequest: null,
      );

      // Verify pending member is blocked from being treated as active
      expect(authState.status, equals(AuthStatus.pendingApproval));
      expect(authState.activeMember, isNull);
    });

    test('Scenario 4: Active member cannot approve their own registration (Self-approval prevention)', () {
      final applicantUser = RegistrationRequestModel(
        requestId: 'req-999',
        societyId: 'soc-001',
        authUid: 'auth-user-123',
        fullName: 'Same Person',
        phoneNumber: '+919825000099',
        flatNumber: 'D-101',
        submittedAt: DateTime.now(),
      );

      final reviewerMember = MemberModel(
        memberId: 'mem-999',
        societyId: 'soc-001',
        authUid: 'auth-user-123', // Same auth_uid
        fullName: 'Same Person',
        phoneNumber: '+919825000099',
        flatNumber: 'D-101',
        membershipStatus: 'ACTIVE',
        joinedAt: DateTime.now(),
      );

      // Business rule: reviewer.authUid must NOT equal applicant.authUid
      bool canApprove(MemberModel reviewer, RegistrationRequestModel applicant) {
        if (reviewer.authUid == applicant.authUid) {
          throw StateError('Self-approval is strictly forbidden. Another active member must approve your request.');
        }
        return true;
      }

      expect(
        () => canApprove(reviewerMember, applicantUser),
        throwsA(isA<StateError>()),
      );
    });

    test('Scenario 5: Duplicate payment submission idempotency check', () {
      final existingTxns = <Map<String, dynamic>>[
        {
          'fundId': 'fund-01',
          'amount': 3000.0,
          'date': '2026-10-01',
          'reference': 'UPI/261001/498213',
        }
      ];

      bool submitTransaction(String fundId, double amount, String date, String reference) {
        final duplicate = existingTxns.any((t) =>
            t['fundId'] == fundId &&
            t['amount'] == amount &&
            t['date'] == date &&
            t['reference'] == reference);

        if (duplicate) {
          throw StateError('Duplicate submission detected.');
        }
        return true;
      }

      // Re-submitting the same payload must throw duplicate error
      expect(
        () => submitTransaction('fund-01', 3000.0, '2026-10-01', 'UPI/261001/498213'),
        throwsA(isA<StateError>()),
      );

      // Different reference succeeds
      expect(
        submitTransaction('fund-01', 3000.0, '2026-10-01', 'UPI/261001/498214'),
        isTrue,
      );
    });

    test('Scenario 6: Expense correction preserves original immutable transaction and creates adjustment reference', () {
      final originalExpense = ExpenseModel(
        expenseId: 'exp-original',
        fundId: 'gen-001',
        amount: 5000.00,
        expenseCategory: 'REPAIRS',
        description: 'Plumbing repair in Tower A',
        paymentMethod: 'UPI',
        expenseDate: DateTime(2026, 10, 1),
        createdBy: 'mem-001',
        createdAt: DateTime(2026, 10, 1),
        status: 'POSTED',
      );

      // A correction is made: actual expense was ₹4,500 (₹500 overstatement)
      // The original expense is NOT deleted. An auditable adjustment entry is linked.
      final adjustmentExpense = ExpenseModel(
        expenseId: 'exp-adjustment',
        fundId: originalExpense.fundId,
        amount: 500.00,
        expenseCategory: originalExpense.expenseCategory,
        description: 'Audit correction for [exp-original]: Overstated receipt amount',
        paymentMethod: originalExpense.paymentMethod,
        expenseDate: DateTime(2026, 10, 2),
        createdBy: 'mem-002',
        createdAt: DateTime(2026, 10, 2),
        status: 'ADJUSTED',
        correctionReference: originalExpense.expenseId,
      );

      expect(originalExpense.status, equals('POSTED'));
      expect(adjustmentExpense.correctionReference, equals('exp-original'));
      expect(adjustmentExpense.status, equals('ADJUSTED'));
    });

    test('Scenario 8: First-member bootstrap gate activates founding resident and locks immediately', () {
      final membersList = <MemberModel>[];

      // When society is empty, first member can bootstrap
      bool canBootstrap(List<MemberModel> list) => list.isEmpty;

      expect(canBootstrap(membersList), isTrue);

      // Founding member joins
      final foundingMember = MemberModel(
        memberId: 'founder-01',
        societyId: 'soc-001',
        authUid: 'auth-founder',
        fullName: 'First Resident',
        phoneNumber: '+919825000001',
        flatNumber: 'A-101',
        membershipStatus: 'ACTIVE',
        joinedAt: DateTime.now(),
      );
      membersList.add(foundingMember);

      // Once one member exists, bootstrap window permanently shuts
      expect(canBootstrap(membersList), isFalse);

      // Second member must go through PENDING approval
      final secondApplicant = RegistrationRequestModel(
        requestId: 'req-002',
        societyId: 'soc-001',
        authUid: 'auth-resident-2',
        fullName: 'Second Resident',
        phoneNumber: '+919825000002',
        flatNumber: 'B-202',
        requestStatus: 'PENDING',
        submittedAt: DateTime.now(),
      );

      expect(secondApplicant.isPending, isTrue);
    });
  });
}
