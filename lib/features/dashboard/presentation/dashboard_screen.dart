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
                // Prominent Welcome Banner with RamSeva Identity & Tagline
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
                            accentColor: AppColors.saffron,
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
                            accentColor: AppColors.goldDark,
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

                // Festivals Section (Empty or Populated)
                _buildFestivalsSection(context, data),
                const SizedBox(height: 24),

                // Recent Transactions (Empty or Populated)
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
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F1E36), // Deep Navy
            Color(0xFF1E3A5F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Official RamSeva Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.appTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'OFFICIAL',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.society.societyName,
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.society.city}, ${data.society.state} • ${data.society.pincode}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Prominent Official Society Tagline
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.saffron.withValues(alpha: 0.4), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote_rounded, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${l10n.dashboardTagline}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
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
                minimumSize: const Size(150, 44),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.push('/expenses/add'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: Text(l10n.addExpense),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
                minimumSize: const Size(140, 44),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/festivals/create'),
              icon: const Icon(Icons.celebration, size: 18, color: AppColors.saffron),
              label: Text(l10n.createFestival, style: const TextStyle(color: AppColors.saffronDark)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.saffron),
                minimumSize: const Size(150, 44),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/funds'),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(l10n.funds),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(130, 44),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/members'),
              icon: const Icon(Icons.people_outline, size: 18),
              label: Text(l10n.members),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(130, 44),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/reports'),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(l10n.reports),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(130, 44),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialChartSection(BuildContext context, DashboardData data) {
    final bool hasData = data.totalSocietyBalance > 0 || data.totalContributions > 0 || data.totalExpenses > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Financial Fund Allocation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Live segregation of General Society operational capital vs Festival reserves.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (!hasData) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_outlined, color: AppColors.incomeGreen, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Clean Starting Ledger • ₹0 Opening Balance',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No entries recorded yet. Contributions and expenses will reflect dynamically here in real-time across all devices.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ] else ...[
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
                              value: data.generalFundBalance > 0 ? data.generalFundBalance : 0.01,
                              color: AppColors.infoBlue,
                              title: '',
                              radius: 36,
                            ),
                            PieChartSectionData(
                              value: data.festivalFundBalance > 0 ? data.festivalFundBalance : 0.01,
                              color: AppColors.saffron,
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
                          _buildLegendRow('Festival Funds', CurrencyFormatter.formatINR(data.festivalFundBalance), AppColors.saffron),
                          const Divider(height: 20),
                          _buildLegendRow('Net Society Balance', CurrencyFormatter.formatINR(data.totalSocietyBalance), AppColors.primary, isBold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildFestivalsSection(BuildContext context, DashboardData data) {
    final l10n = context.l10n;
    if (data.upcomingFestivals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.saffron.withValues(alpha: 0.12),
                radius: 24,
                child: const Icon(Icons.celebration_outlined, color: AppColors.saffron, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.noFestivalsYet, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    const Text('Schedule upcoming celebrations with dedicated fund tracking.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/festivals/create'),
                child: Text(l10n.createFestival),
              ),
            ],
          ),
        ),
      );
    }

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
              backgroundColor: AppColors.saffron.withValues(alpha: 0.12),
              child: const Icon(Icons.celebration, color: AppColors.saffron, size: 20),
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
    final hasTransactions = data.recentContributions.isNotEmpty || data.recentExpenses.isNotEmpty;

    if (!hasTransactions) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noContributionsYet,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.financialJourneyStarts,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/contributions/add'),
                icon: const Icon(Icons.add, size: 16),
                label: Text(l10n.addContribution),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.incomeGreen,
                  minimumSize: const Size(180, 40),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
