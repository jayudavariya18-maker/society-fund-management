import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardDataProvider.future),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                _buildWelcomeHeader(context, data),
                const SizedBox(height: 20),

                // Top Metrics Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                          child: StatCard(
                            title: l10n.totalSocietyBalance,
                            value: CurrencyFormatter.formatINR(data.totalSocietyBalance),
                            subtitle: '${data.funds.length} Active Funds',
                            icon: Icons.account_balance_rounded,
                            accentColor: AppColors.primary,
                            onTap: () => context.go('/funds'),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                          child: StatCard(
                            title: l10n.generalFundBalance,
                            value: CurrencyFormatter.formatINR(data.generalFundBalance),
                            subtitle: 'Maintenance & Ops',
                            icon: Icons.domain_rounded,
                            accentColor: AppColors.infoBlue,
                            onTap: () => context.go('/funds'),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                          child: StatCard(
                            title: l10n.festivalFundBalance,
                            value: CurrencyFormatter.formatINR(data.festivalFundBalance),
                            subtitle: 'Dedicated Celebrations',
                            icon: Icons.celebration_rounded,
                            accentColor: AppColors.secondary,
                            onTap: () => context.go('/festivals'),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                          child: StatCard(
                            title: l10n.totalContributions,
                            value: CurrencyFormatter.formatINR(data.totalContributions),
                            subtitle: 'Posted Collections',
                            icon: Icons.arrow_downward_rounded,
                            accentColor: AppColors.incomeGreen,
                            onTap: () => context.push('/reports'),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                          child: StatCard(
                            title: l10n.totalExpenses,
                            value: CurrencyFormatter.formatINR(data.totalExpenses),
                            subtitle: 'Verified Outgoing',
                            icon: Icons.arrow_upward_rounded,
                            accentColor: AppColors.expenseRed,
                            onTap: () => context.push('/reports'),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                          child: StatCard(
                            title: l10n.activeMembers,
                            value: '${data.activeMembersCount} Residents',
                            subtitle: 'Equal Voting Access',
                            icon: Icons.people_rounded,
                            accentColor: AppColors.textPrimary,
                            onTap: () => context.push('/members'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // Financial Overview Chart & Fund Split
                _buildFinancialChartSection(context, data),
                const SizedBox(height: 24),

                // Upcoming Festivals
                if (data.upcomingFestivals.isNotEmpty) ...[
                  _buildUpcomingFestivalsSection(context, data),
                  const SizedBox(height: 24),
                ],

                // Recent Transactions
                _buildRecentTransactionsSection(context, data),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, DashboardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.society.societyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.society.city}, ${data.society.state} • ${data.society.pincode}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Equal Member Access • Zero Admin Hierarchy',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.push('/contributions/add'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addContribution),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.incomeGreen,
                minimumSize: const Size(160, 44),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.push('/expenses/add'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: Text(l10n.addExpense),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
                minimumSize: const Size(160, 44),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/festivals/create'),
              icon: const Icon(Icons.celebration, size: 18),
              label: Text(l10n.createFestival),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(160, 44),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/reports'),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(l10n.reports),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(140, 44),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialChartSection(BuildContext context, DashboardData data) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Fund Allocation', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Live segregation of General Society operational capital vs Festival reserves.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        sections: [
                          PieChartSectionData(
                            value: data.generalFundBalance > 0 ? data.generalFundBalance : 1,
                            color: AppColors.infoBlue,
                            title: '',
                            radius: 36,
                          ),
                          PieChartSectionData(
                            value: data.festivalFundBalance > 0 ? data.festivalFundBalance : 1,
                            color: AppColors.secondary,
                            title: '',
                            radius: 36,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendRow('General Fund', CurrencyFormatter.formatINR(data.generalFundBalance), AppColors.infoBlue),
                        const SizedBox(height: 12),
                        _buildLegendRow('Festival Funds', CurrencyFormatter.formatINR(data.festivalFundBalance), AppColors.secondary),
                        const Divider(height: 20),
                        _buildLegendRow('Net Society Balance', CurrencyFormatter.formatINR(data.totalSocietyBalance), AppColors.primary, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String title, String amount, Color color, {bool isBold = false}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildUpcomingFestivalsSection(BuildContext context, DashboardData data) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.upcomingFestivals, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/festivals'),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...data.upcomingFestivals.map((fest) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary.withOpacity(0.12),
              child: const Icon(Icons.celebration, color: AppColors.secondary, size: 20),
            ),
            title: Text(fest.festivalName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '${DateFormatter.formatShort(fest.startDate)} - ${DateFormatter.formatShort(fest.endDate)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Remaining', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                Text(
                  CurrencyFormatter.formatINR(fest.remainingBalance),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.incomeGreen),
                ),
              ],
            ),
            onTap: () => context.push('/festivals/${fest.festivalId}'),
          ),
        )),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context, DashboardData data) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentTransactions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/funds'),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...data.recentContributions.map((c) => TransactionTile(
          title: c.memberName ?? 'Anonymous Donor',
          subtitle: '${c.receiptNumber} • ${c.contributionType.replaceAll("_", " ")}',
          amount: c.amount,
          isIncome: true,
          date: c.paymentDate,
          fundTag: c.fundName,
          status: c.status,
          onTap: () => context.push('/receipts/${c.receiptNumber}', extra: c),
        )),
        ...data.recentExpenses.map((e) => TransactionTile(
          title: e.description,
          subtitle: '${e.vendorName ?? "Direct Expense"} • ${e.expenseCategory.replaceAll("_", " ")}',
          amount: e.amount,
          isIncome: false,
          date: e.expenseDate,
          fundTag: e.fundName,
          status: e.status,
          onTap: () {},
        )),
      ],
    );
  }
}
