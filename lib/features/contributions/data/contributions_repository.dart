import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/receipt_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/contribution_model.dart';
import '../../authentication/data/auth_repository.dart';
import '../../funds/data/funds_repository.dart';

final contributionsRepositoryProvider = Provider<ContributionsRepository>((ref) {
  return ContributionsRepository(SupabaseService.instance, ref);
});

final contributionsListProvider = FutureProvider.family<List<ContributionModel>, String?>((ref, fundId) async {
  final repo = ref.watch(contributionsRepositoryProvider);
  return repo.fetchContributions(fundId: fundId);
});

class ContributionsRepository {
  final SupabaseService _supabase;
  final Ref _ref;

  ContributionsRepository(this._supabase, this._ref);

  // In-memory mock contributions
  static final List<ContributionModel> _mockContributions = [
    ContributionModel(
      contributionId: '55555555-5555-5555-5555-555555555001',
      fundId: '22222222-2222-2222-2222-222222222001',
      fundName: 'General Society Maintenance Fund',
      memberId: '11111111-1111-1111-1111-111111111001',
      memberName: 'Rajeshbhai Patel',
      flatNumber: 'A-402',
      amount: 3000.00,
      contributionType: 'MONTHLY_MAINTENANCE',
      paymentMethod: 'UPI',
      transactionReference: 'UPI/261001/498213',
      paymentDate: DateTime(2026, 10, 1),
      notes: 'October 2026 monthly maintenance for Flat A-402',
      receiptNumber: 'REC-202610-0001',
      createdBy: '11111111-1111-1111-1111-111111111001',
      createdByName: 'Rajeshbhai Patel',
      createdAt: DateTime(2026, 10, 1, 11, 15),
      status: 'POSTED',
    ),
    ContributionModel(
      contributionId: '55555555-5555-5555-5555-555555555002',
      fundId: '22222222-2222-2222-2222-222222222001',
      fundName: 'General Society Maintenance Fund',
      memberId: '11111111-1111-1111-1111-111111111002',
      memberName: 'Amitkumar Shah',
      flatNumber: 'B-201',
      amount: 3000.00,
      contributionType: 'MONTHLY_MAINTENANCE',
      paymentMethod: 'BANK_TRANSFER',
      transactionReference: 'NEFT/AXIS/998124',
      paymentDate: DateTime(2026, 10, 2),
      notes: 'October 2026 monthly maintenance for Flat B-201',
      receiptNumber: 'REC-202610-0002',
      createdBy: '11111111-1111-1111-1111-111111111002',
      createdByName: 'Amitkumar Shah',
      createdAt: DateTime(2026, 10, 2, 14, 30),
      status: 'POSTED',
    ),
    ContributionModel(
      contributionId: '55555555-5555-5555-5555-555555555003',
      fundId: '22222222-2222-2222-2222-222222222002',
      fundName: 'Navratri Mahotsav 2026 Fund',
      memberId: '11111111-1111-1111-1111-111111111001',
      memberName: 'Rajeshbhai Patel',
      flatNumber: 'A-402',
      amount: 5000.00,
      contributionType: 'FESTIVAL_CONTRIBUTION',
      paymentMethod: 'UPI',
      transactionReference: 'UPI/261005/778120',
      paymentDate: DateTime(2026, 10, 5),
      notes: 'Navratri voluntary contribution from Flat A-402',
      receiptNumber: 'REC-202610-0003',
      createdBy: '11111111-1111-1111-1111-111111111001',
      createdByName: 'Rajeshbhai Patel',
      createdAt: DateTime(2026, 10, 5, 10, 00),
      status: 'POSTED',
    ),
    ContributionModel(
      contributionId: '55555555-5555-5555-5555-555555555004',
      fundId: '22222222-2222-2222-2222-222222222002',
      fundName: 'Navratri Mahotsav 2026 Fund',
      memberId: '11111111-1111-1111-1111-111111111003',
      memberName: 'Meenaben Trivedi',
      flatNumber: 'C-104',
      amount: 5000.00,
      contributionType: 'FESTIVAL_CONTRIBUTION',
      paymentMethod: 'CASH',
      transactionReference: 'CASH-REC-01',
      paymentDate: DateTime(2026, 10, 6),
      notes: 'Navratri voluntary contribution from Flat C-104',
      receiptNumber: 'REC-202610-0004',
      createdBy: '11111111-1111-1111-1111-111111111003',
      createdByName: 'Meenaben Trivedi',
      createdAt: DateTime(2026, 10, 6, 17, 45),
      status: 'POSTED',
    ),
  ];

  Future<List<ContributionModel>> fetchContributions({
    String? fundId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_supabase.isMockDevMode) {
      var list = List<ContributionModel>.from(_mockContributions);
      if (fundId != null) list = list.where((c) => c.fundId == fundId).toList();
      if (fromDate != null) list = list.where((c) => c.paymentDate.isAfter(fromDate.subtract(const Duration(days: 1)))).toList();
      if (toDate != null) list = list.where((c) => c.paymentDate.isBefore(toDate.add(const Duration(days: 1)))).toList();
      list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      return list;
    }

    var query = _supabase.client
        .from('contributions')
        .select('*, funds(fund_name), members(full_name, flat_number)');

    if (fundId != null) query = query.eq('fund_id', fundId);
    if (fromDate != null) query = query.gte('payment_date', fromDate.toIso8601String().split('T').first);
    if (toDate != null) query = query.lte('payment_date', toDate.toIso8601String().split('T').first);

    final res = await query.order('payment_date', ascending: false);
    return (res as List).map((e) => ContributionModel.fromJson(e)).toList();
  }

  Future<ContributionModel> addContribution({
    required String fundId,
    String? memberId,
    required double amount,
    required String contributionType,
    required String paymentMethod,
    String? transactionReference,
    required DateTime paymentDate,
    String? notes,
    String? attachmentUrl,
  }) async {
    final activeMember = _ref.read(authStateProvider).activeMember;
    final createdBy = activeMember?.memberId ?? '11111111-1111-1111-1111-111111111001';
    final receiptNo = ReceiptService.generateReceiptNumber();

    if (_supabase.isMockDevMode) {
      // Duplicate idempotency check
      final duplicate = _mockContributions.any((c) =>
          c.fundId == fundId &&
          c.amount == amount &&
          c.paymentDate.year == paymentDate.year &&
          c.paymentDate.month == paymentDate.month &&
          c.paymentDate.day == paymentDate.day &&
          transactionReference != null &&
          c.transactionReference == transactionReference);

      if (duplicate) {
        throw StateError('Duplicate payment submission detected for reference $transactionReference.');
      }

      final newModel = ContributionModel(
        contributionId: 'contrib-${DateTime.now().millisecondsSinceEpoch}',
        fundId: fundId,
        memberId: memberId,
        memberName: memberId != null ? activeMember?.fullName : 'Anonymous Donor',
        flatNumber: memberId != null ? activeMember?.flatNumber : null,
        amount: amount,
        contributionType: contributionType,
        paymentMethod: paymentMethod,
        transactionReference: transactionReference,
        paymentDate: paymentDate,
        notes: notes,
        receiptNumber: receiptNo,
        attachmentUrl: attachmentUrl,
        createdBy: createdBy,
        createdByName: activeMember?.fullName ?? 'Resident',
        createdAt: DateTime.now(),
        status: 'POSTED',
      );

      _mockContributions.insert(0, newModel);
      FundsRepository.recordMockContribution(fundId, amount);
      return newModel;
    }

    final res = await _supabase.client.from('contributions').insert({
      'fund_id': fundId,
      'member_id': memberId,
      'amount': amount,
      'contribution_type': contributionType,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'payment_date': paymentDate.toIso8601String().split('T').first,
      'notes': notes,
      'receipt_number': receiptNo,
      'attachment_url': attachmentUrl,
      'created_by': createdBy,
      'status': 'POSTED',
    }).select('*, funds(fund_name), members(full_name, flat_number)').single();

    return ContributionModel.fromJson(res);
  }
}
