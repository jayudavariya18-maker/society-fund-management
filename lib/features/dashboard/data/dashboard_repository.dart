import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/contribution_model.dart';
import '../../../shared/models/expense_model.dart';
import '../../../shared/models/festival_model.dart';
import '../../../shared/models/fund_model.dart';
import '../../../shared/models/society_model.dart';
import '../../contributions/data/contributions_repository.dart';
import '../../expenses/data/expenses_repository.dart';
import '../../festivals/data/festivals_repository.dart';
import '../../funds/data/funds_repository.dart';
import '../../members/data/members_repository.dart';

class DashboardData {
  final SocietyModel society;
  final double totalSocietyBalance;
  final double generalFundBalance;
  final double festivalFundBalance;
  final double totalContributions;
  final double totalExpenses;
  final int activeMembersCount;
  final List<FundModel> funds;
  final List<ContributionModel> recentContributions;
  final List<ExpenseModel> recentExpenses;
  final List<FestivalModel> upcomingFestivals;

  DashboardData({
    required this.society,
    required this.totalSocietyBalance,
    required this.generalFundBalance,
    required this.festivalFundBalance,
    required this.totalContributions,
    required this.totalExpenses,
    required this.activeMembersCount,
    required this.funds,
    required this.recentContributions,
    required this.recentExpenses,
    required this.upcomingFestivals,
  });
}

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final funds = await ref.watch(fundsListProvider.future);
  final contributions = await ref.watch(contributionsListProvider(null).future);
  final expenses = await ref.watch(expensesListProvider(null).future);
  final festivals = await ref.watch(festivalsListProvider.future);
  final members = await ref.watch(membersListProvider.future);

  double generalBal = 0.0;
  double festivalBal = 0.0;
  double totalBal = 0.0;
  double totalInc = 0.0;
  double totalExp = 0.0;

  for (final f in funds) {
    totalBal += f.currentBalance;
    totalInc += f.totalContributions;
    totalExp += f.totalExpenses;
    if (f.isGeneral) {
      generalBal += f.currentBalance;
    } else {
      festivalBal += f.currentBalance;
    }
  }

  final society = SocietyModel(
    societyId: '00000000-0000-0000-0000-000000000001',
    societyName: 'Bajrang Heights Co-Operative Housing Society',
    address: 'Plot 42-45, Maruti Nandan Marg, Satellite',
    city: 'Ahmedabad',
    state: 'Gujarat',
    pincode: '380015',
    contactNumber: '+919876543210',
    email: 'bajrang.heights.society@gmail.com',
    createdAt: DateTime(2025, 1, 1),
  );

  return DashboardData(
    society: society,
    totalSocietyBalance: totalBal,
    generalFundBalance: generalBal,
    festivalFundBalance: festivalBal,
    totalContributions: totalInc,
    totalExpenses: totalExp,
    activeMembersCount: members.length,
    funds: funds,
    recentContributions: contributions.take(5).toList(),
    recentExpenses: expenses.take(5).toList(),
    upcomingFestivals: festivals.take(3).toList(),
  );
});
