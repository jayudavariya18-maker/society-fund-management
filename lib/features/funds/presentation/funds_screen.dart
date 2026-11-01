import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../shared/models/fund_model.dart';
import '../../contributions/data/contributions_repository.dart';
import '../../expenses/data/expenses_repository.dart';
import '../data/funds_repository.dart';

class FundsScreen extends ConsumerWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fundsAsync = ref.watch(fundsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.funds),
        actions: [
          IconButton(
            tooltip: 'Refresh Ledger',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(fundsListProvider),
          ),
        ],
      ),
      body: fundsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading funds: $err')),
        data: (funds) {
          final generalFunds = funds.where((f) => f.isGeneral).toList();
          final festivalFunds = funds.where((f) => f.isFestival).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(fundsListProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GENERAL SOCIETY FUND SECTION
                  _buildSectionHeader(
                    context,
                    title: l10n.generalFund.toUpperCase(),
                    subtitle: 'Core operational balance for building upkeep, electricity, and water systems.',
                    icon: Icons.account_balance_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  ...generalFunds.map((fund) => _buildGeneralFundCard(context, fund)),
                  const SizedBox(height: 28),

                  // FESTIVAL FUNDS SECTION
                  _buildSectionHeader(
                    context,
                    title: l10n.festivalFund.toUpperCase() + 'S',
                    subtitle: 'Independent celebration accounts strictly isolated from general society funds.',
                    icon: Icons.celebration_rounded,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  if (festivalFunds.isEmpty)
                    EmptyStateView(
                      icon: Icons.celebration_outlined,
                      title: 'No Festival Funds Created Yet',
                      subtitle: 'When a new festival is scheduled, a dedicated fund is established automatically.',
                      actionLabel: l10n.createFestival,
                      onAction: () => context.push('/festivals/create'),
                    )
                  else
                    ...festivalFunds.map((fund) => _buildFestivalFundCard(context, fund)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contributions/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addContribution),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGeneralFundCard(BuildContext context, FundModel fund) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/funds/${fund.fundId}', extra: fund),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fund.fundName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.infoBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('GENERAL LEDGER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.infoBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                CurrencyFormatter.formatINR(fund.currentBalance),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricPill('Opening', CurrencyFormatter.formatINR(fund.openingBalance), AppColors.textSecondary),
                  _buildMetricPill('Income', CurrencyFormatter.formatINR(fund.totalContributions), AppColors.incomeGreen),
                  _buildMetricPill('Expenses', CurrencyFormatter.formatINR(fund.totalExpenses), AppColors.expenseRed),
                  _buildMetricPill('Entries', '${fund.contributionCount + fund.expenseCount}', AppColors.textPrimary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFestivalFundCard(BuildContext context, FundModel fund) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/funds/${fund.fundId}', extra: fund),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fund.fundName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('FESTIVAL ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Remaining Balance', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text(
                        CurrencyFormatter.formatINR(fund.currentBalance),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.incomeGreen),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Collection: ${CurrencyFormatter.formatINR(fund.totalContributions)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.incomeGreen)),
                      const SizedBox(height: 2),
                      Text('Expenses: ${CurrencyFormatter.formatINR(fund.totalExpenses)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.expenseRed)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class FundDetailsScreen extends ConsumerWidget {
  final String fundId;
  final FundModel? fundModel;

  const FundDetailsScreen({super.key, required this.fundId, this.fundModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contributionsAsync = ref.watch(contributionsListProvider(fundId));
    final expensesAsync = ref.watch(expensesListProvider(fundId));

    return Scaffold(
      appBar: AppBar(
        title: Text(fundModel?.fundName ?? l10n.funds),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fund Overview Card
            if (fundModel != null)
              Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentBalance.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.formatINR(fundModel!.currentBalance),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Opening: ${CurrencyFormatter.formatINR(fundModel!.openingBalance)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('Income: ${CurrencyFormatter.formatINR(fundModel!.totalContributions)}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Spent: ${CurrencyFormatter.formatINR(fundModel!.totalExpenses)}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Ledger Entries Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.transactions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.incomeGreen),
                      tooltip: l10n.addContribution,
                      onPressed: () => context.push('/contributions/add', extra: fundId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: AppColors.expenseRed),
                      tooltip: l10n.addExpense,
                      onPressed: () => context.push('/expenses/add', extra: fundId),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Contributions List
            contributionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
              data: (contribs) => Column(
                children: contribs.map((c) => TransactionTile(
                  title: c.memberName ?? 'Anonymous Donor',
                  subtitle: '${c.receiptNumber} • ${c.contributionType.replaceAll("_", " ")}',
                  amount: c.amount,
                  isIncome: true,
                  date: c.paymentDate,
                  status: c.status,
                  onTap: () => context.push('/receipts/${c.receiptNumber}', extra: c),
                )).toList(),
              ),
            ),

            // Expenses List
            expensesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
              data: (exps) => Column(
                children: exps.map((e) => TransactionTile(
                  title: e.description,
                  subtitle: '${e.vendorName ?? "Direct Expense"} • ${e.expenseCategory}',
                  amount: e.amount,
                  isIncome: false,
                  date: e.expenseDate,
                  status: e.status,
                  onTap: () {},
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
