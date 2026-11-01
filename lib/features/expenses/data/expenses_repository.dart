import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/expense_model.dart';
import '../../authentication/data/auth_repository.dart';
import '../../funds/data/funds_repository.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(SupabaseService.instance, ref);
});

final expensesListProvider = FutureProvider.family<List<ExpenseModel>, String?>((ref, fundId) async {
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.fetchExpenses(fundId: fundId);
});

class ExpensesRepository {
  final SupabaseService _supabase;
  final Ref _ref;

  ExpensesRepository(this._supabase, this._ref);

  // In-memory mock expenses
  static final List<ExpenseModel> _mockExpenses = [
    ExpenseModel(
      expenseId: '66666666-6666-6666-6666-666666666001',
      fundId: '22222222-2222-2222-2222-222222222001',
      fundName: 'General Society Maintenance Fund',
      eventId: null,
      amount: 8500.00,
      expenseCategory: 'ELECTRICITY',
      description: 'Torrent Power Common meter billing for September 2026',
      vendorName: 'Torrent Power Ltd',
      paymentMethod: 'UPI',
      expenseDate: DateTime(2026, 10, 4),
      receiptReference: 'BILL-TP-9921',
      createdBy: '11111111-1111-1111-1111-111111111001',
      createdByName: 'Rajeshbhai Patel',
      createdAt: DateTime(2026, 10, 4, 15, 30),
      status: 'POSTED',
    ),
    ExpenseModel(
      expenseId: '66666666-6666-6666-6666-666666666002',
      fundId: '22222222-2222-2222-2222-222222222002',
      fundName: 'Navratri Mahotsav 2026 Fund',
      eventId: '44444444-4444-4444-4444-444444444001',
      eventName: 'Grand Garba Night & Orchestra',
      amount: 4000.00,
      expenseCategory: 'SOUND_SYSTEM',
      description: 'Advance payment for 9-channel sound mixer & speakers for Garba night',
      vendorName: 'Shiv Sound Services',
      paymentMethod: 'UPI',
      expenseDate: DateTime(2026, 10, 8),
      receiptReference: 'SHIV-ADV-01',
      createdBy: '11111111-1111-1111-1111-111111111002',
      createdByName: 'Amitkumar Shah',
      createdAt: DateTime(2026, 10, 8, 12, 00),
      status: 'POSTED',
    ),
  ];

  Future<List<ExpenseModel>> fetchExpenses({
    String? fundId,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_supabase.isMockDevMode) {
      var list = List<ExpenseModel>.from(_mockExpenses);
      if (fundId != null) list = list.where((e) => e.fundId == fundId).toList();
      if (category != null) list = list.where((e) => e.expenseCategory == category).toList();
      if (fromDate != null) list = list.where((e) => e.expenseDate.isAfter(fromDate.subtract(const Duration(days: 1)))).toList();
      if (toDate != null) list = list.where((e) => e.expenseDate.isBefore(toDate.add(const Duration(days: 1)))).toList();
      list.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      return list;
    }

    var query = _supabase.client
        .from('expenses')
        .select('*, funds(fund_name), festival_events(event_name)');

    if (fundId != null) query = query.eq('fund_id', fundId);
    if (category != null) query = query.eq('expense_category', category);
    if (fromDate != null) query = query.gte('expense_date', fromDate.toIso8601String().split('T').first);
    if (toDate != null) query = query.lte('expense_date', toDate.toIso8601String().split('T').first);

    final res = await query.order('expense_date', ascending: false);
    return (res as List).map((e) => ExpenseModel.fromJson(e)).toList();
  }

  Future<ExpenseModel> addExpense({
    required String fundId,
    String? eventId,
    required double amount,
    required String expenseCategory,
    required String description,
    String? vendorName,
    required String paymentMethod,
    required DateTime expenseDate,
    String? billImageUrl,
    String? receiptReference,
    String? correctionReference,
  }) async {
    final activeMember = _ref.read(authStateProvider).activeMember;
    final createdBy = activeMember?.memberId ?? '11111111-1111-1111-1111-111111111001';

    if (_supabase.isMockDevMode) {
      final newModel = ExpenseModel(
        expenseId: 'exp-${DateTime.now().millisecondsSinceEpoch}',
        fundId: fundId,
        eventId: eventId,
        amount: amount,
        expenseCategory: expenseCategory,
        description: description,
        vendorName: vendorName,
        paymentMethod: paymentMethod,
        expenseDate: expenseDate,
        billImageUrl: billImageUrl,
        receiptReference: receiptReference,
        createdBy: createdBy,
        createdByName: activeMember?.fullName ?? 'Resident',
        createdAt: DateTime.now(),
        status: 'POSTED',
        correctionReference: correctionReference,
      );

      _mockExpenses.insert(0, newModel);
      FundsRepository.recordMockExpense(fundId, amount);
      return newModel;
    }

    final res = await _supabase.client.from('expenses').insert({
      'fund_id': fundId,
      'event_id': eventId,
      'amount': amount,
      'expense_category': expenseCategory,
      'description': description,
      'vendor_name': vendorName,
      'payment_method': paymentMethod,
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'bill_image_url': billImageUrl,
      'receipt_reference': receiptReference,
      'created_by': createdBy,
      'status': 'POSTED',
      'correction_reference': correctionReference,
    }).select('*, funds(fund_name), festival_events(event_name)').single();

    return ExpenseModel.fromJson(res);
  }

  /// Create an Auditable Correction or Reversal for an existing Expense
  Future<ExpenseModel> correctExpense({
    required ExpenseModel originalExpense,
    required double adjustedAmount,
    required String reason,
  }) async {
    // 1. Mark original status as ADJUSTED or REVERSED
    final diff = adjustedAmount - originalExpense.amount;
    final correctionDesc = 'Correction for [${originalExpense.expenseId}]: $reason (Delta: ₹${diff.toStringAsFixed(2)})';

    // 2. Add adjustment expense entry linked via correctionReference
    return addExpense(
      fundId: originalExpense.fundId,
      eventId: originalExpense.eventId,
      amount: diff.abs(),
      expenseCategory: originalExpense.expenseCategory,
      description: correctionDesc,
      vendorName: originalExpense.vendorName,
      paymentMethod: originalExpense.paymentMethod,
      expenseDate: DateTime.now(),
      correctionReference: originalExpense.expenseId,
    );
  }
}
