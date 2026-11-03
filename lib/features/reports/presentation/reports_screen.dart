import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/csv_export_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/society_model.dart';
import '../../contributions/data/contributions_repository.dart';
import '../../expenses/data/expenses_repository.dart';
import '../../funds/data/funds_repository.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _fromDate = DateTime(2026, 1, 1);
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));
  String _selectedReportType = 'STATEMENT'; // 'STATEMENT', 'CONTRIBUTIONS', 'EXPENSES'

  final SocietyModel _society = SocietyModel(
    societyId: '00000000-0000-0000-0000-000000000001',
    societyName: 'Ramdevra Society',
    address: 'Near Temple, Main Road',
    city: 'Ahmedabad',
    state: 'Gujarat',
    pincode: '380015',
    contactNumber: '+919876543210',
    email: 'ramdevra.society@gmail.com',
    createdAt: DateTime(2025, 1, 1),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fundsAsync = ref.watch(fundsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        actions: [
          IconButton(
            tooltip: l10n.exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final funds = await ref.read(fundsListProvider.future);
              double totalSocietyBalance = 0;
              double totalIncome = 0;
              double totalExpense = 0;
              for (final f in funds) {
                totalSocietyBalance += f.currentBalance;
                totalIncome += f.totalContributions;
                totalExpense += f.totalExpenses;
              }
              await Printing.layoutPdf(
                onLayout: (format) => PdfService.generateFinancialReportPdf(
                  society: _society,
                  funds: funds,
                  totalSocietyBalance: totalSocietyBalance,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                  fromDate: _fromDate,
                  toDate: _toDate,
                ),
              );
            },
          ),
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.table_view_outlined),
            onPressed: () async {
              if (_selectedReportType == 'EXPENSES') {
                final exps = await ref.read(expensesListProvider(null).future);
                final csv = CsvExportService.exportExpensesCsv(exps);
                await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'expenses_report.csv');
              } else {
                final contribs = await ref.read(contributionsListProvider(null).future);
                final csv = CsvExportService.exportContributionsCsv(contribs);
                await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'contributions_report.csv');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Scope & Date Filter', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedReportType,
                            decoration: const InputDecoration(labelText: 'Report Type'),
                            items: const [
                              DropdownMenuItem(value: 'STATEMENT', child: Text('Financial Fund Statement')),
                              DropdownMenuItem(value: 'CONTRIBUTIONS', child: Text('Member Contributions Ledger')),
                              DropdownMenuItem(value: 'EXPENSES', child: Text('Expense Breakdown Ledger')),
                            ],
                            onChanged: (v) => setState(() => _selectedReportType = v ?? 'STATEMENT'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                            title: Text(l10n.dateFrom, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            subtitle: Text(DateFormatter.formatShort(_fromDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onTap: () async {
                              final p = await showDatePicker(context: context, initialDate: _fromDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                              if (p != null) setState(() => _fromDate = p);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                            title: Text(l10n.dateTo, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            subtitle: Text(DateFormatter.formatShort(_toDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onTap: () async {
                              final p = await showDatePicker(context: context, initialDate: _toDate, firstDate: _fromDate, lastDate: DateTime(2030));
                              if (p != null) setState(() => _toDate = p);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Fund Table
            fundsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
              data: (funds) {
                double totalBal = 0;
                double totalInc = 0;
                double totalExp = 0;
                for (final f in funds) {
                  totalBal += f.currentBalance;
                  totalInc += f.totalContributions;
                  totalExp += f.totalExpenses;
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.financialStatement, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              'Net: ${CurrencyFormatter.formatINR(totalBal)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Fund Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Opening', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Received', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Spent', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Current Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            ],
                            rows: [
                              ...funds.map((f) => DataRow(cells: [
                                DataCell(Text(f.fundName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(f.fundType)),
                                DataCell(Text(CurrencyFormatter.formatINR(f.openingBalance))),
                                DataCell(Text(CurrencyFormatter.formatINR(f.totalContributions), style: const TextStyle(color: AppColors.incomeGreen))),
                                DataCell(Text(CurrencyFormatter.formatINR(f.totalExpenses), style: const TextStyle(color: AppColors.expenseRed))),
                                DataCell(Text(CurrencyFormatter.formatINR(f.currentBalance), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                              ])),
                              DataRow(
                                selected: true,
                                cells: [
                                  const DataCell(Text('TOTALS', style: TextStyle(fontWeight: FontWeight.bold))),
                                  const DataCell(Text('ALL')),
                                  DataCell(Text(CurrencyFormatter.formatINR(funds.fold(0.0, (s, f) => s + f.openingBalance)), style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(CurrencyFormatter.formatINR(totalInc), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.incomeGreen))),
                                  DataCell(Text(CurrencyFormatter.formatINR(totalExp), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.expenseRed))),
                                  DataCell(Text(CurrencyFormatter.formatINR(totalBal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
