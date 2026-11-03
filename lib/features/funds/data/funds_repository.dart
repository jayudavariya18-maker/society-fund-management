import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/fund_model.dart';

final fundsRepositoryProvider = Provider<FundsRepository>((ref) {
  return FundsRepository(SupabaseService.instance, ref);
});

final fundsListProvider = FutureProvider<List<FundModel>>((ref) async {
  final repo = ref.watch(fundsRepositoryProvider);
  return repo.fetchAllFunds();
});

class FundsRepository {
  final SupabaseService _supabase;
  final Ref _ref;

  FundsRepository(this._supabase, this._ref);

  // Clean initial state: General Fund opening balance ₹0, zero demo festivals
  static final List<FundModel> _mockFunds = [
    FundModel(
      fundId: '22222222-2222-2222-2222-222222222001',
      societyId: '00000000-0000-0000-0000-000000000001',
      fundName: 'General Society Maintenance Fund',
      fundType: 'GENERAL',
      description: 'Primary operational fund for society maintenance.',
      openingBalance: 0.00,
      totalContributions: 0.00,
      totalExpenses: 0.00,
      currentBalance: 0.00,
      contributionCount: 0,
      expenseCount: 0,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  Future<List<FundModel>> fetchAllFunds() async {
    if (_supabase.isMockDevMode) {
      return _mockFunds;
    }

    final res = await _supabase.client
        .from('vw_fund_balances')
        .select()
        .eq('is_active', true)
        .order('fund_type', ascending: true);

    return (res as List).map((e) => FundModel.fromJson(e)).toList();
  }

  Future<FundModel?> fetchFundById(String fundId) async {
    final all = await fetchAllFunds();
    return all.firstWhere((f) => f.fundId == fundId);
  }

  Future<FundModel> createFestivalFund({
    required String fundName,
    required String festivalId,
    String? description,
    double openingBalance = 0.0,
  }) async {
    if (_supabase.isMockDevMode) {
      final newFund = FundModel(
        fundId: 'fund-${DateTime.now().millisecondsSinceEpoch}',
        societyId: '00000000-0000-0000-0000-000000000001',
        fundName: fundName,
        fundType: 'FESTIVAL',
        festivalId: festivalId,
        description: description,
        openingBalance: openingBalance,
        currentBalance: openingBalance,
        createdAt: DateTime.now(),
      );
      _mockFunds.add(newFund);
      _ref.invalidate(fundsListProvider);
      _supabase.notifyLocalChange('funds');
      return newFund;
    }

    final res = await _supabase.client.from('funds').insert({
      'society_id': '00000000-0000-0000-0000-000000000001',
      'fund_name': fundName,
      'fund_type': 'FESTIVAL',
      'festival_id': festivalId,
      'description': description,
      'opening_balance': openingBalance,
      'is_active': true,
    }).select().single();

    _ref.invalidate(fundsListProvider);
    _supabase.notifyLocalChange('funds');
    return FundModel.fromJson(res);
  }

  // Update in-memory balances during mock transactions
  static void recordMockContribution(String fundId, double amount) {
    final idx = _mockFunds.indexWhere((f) => f.fundId == fundId);
    if (idx != -1) {
      final f = _mockFunds[idx];
      _mockFunds[idx] = FundModel(
        fundId: f.fundId,
        societyId: f.societyId,
        fundName: f.fundName,
        fundType: f.fundType,
        festivalId: f.festivalId,
        festivalName: f.festivalName,
        description: f.description,
        openingBalance: f.openingBalance,
        totalContributions: f.totalContributions + amount,
        totalExpenses: f.totalExpenses,
        currentBalance: f.currentBalance + amount,
        contributionCount: f.contributionCount + 1,
        expenseCount: f.expenseCount,
        createdAt: f.createdAt,
      );
    }
  }

  static void recordMockExpense(String fundId, double amount) {
    final idx = _mockFunds.indexWhere((f) => f.fundId == fundId);
    if (idx != -1) {
      final f = _mockFunds[idx];
      _mockFunds[idx] = FundModel(
        fundId: f.fundId,
        societyId: f.societyId,
        fundName: f.fundName,
        fundType: f.fundType,
        festivalId: f.festivalId,
        festivalName: f.festivalName,
        description: f.description,
        openingBalance: f.openingBalance,
        totalContributions: f.totalContributions,
        totalExpenses: f.totalExpenses + amount,
        currentBalance: f.currentBalance - amount,
        contributionCount: f.contributionCount,
        expenseCount: f.expenseCount + 1,
        createdAt: f.createdAt,
      );
    }
  }
}
