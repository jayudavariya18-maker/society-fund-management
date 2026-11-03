import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/audit_repository.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final logsAsync = ref.watch(auditLogsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditLogs),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyStateView(
              icon: Icons.history_outlined,
              title: 'No Audit Records Available',
              subtitle: 'Database triggers automatically log all financial transactions, approvals and amendments here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(auditLogsListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isContribution = log.action.contains('CONTRIBUTION');
                final isExpense = log.action.contains('EXPENSE');
                final isApproval = log.action.contains('REGISTRATION');

                Color actionColor = AppColors.primary;
                IconData icon = Icons.receipt_long;
                if (isContribution) {
                  actionColor = AppColors.incomeGreen;
                  icon = Icons.add_circle_outline;
                } else if (isExpense) {
                  actionColor = AppColors.expenseRed;
                  icon = Icons.remove_circle_outline;
                } else if (isApproval) {
                  actionColor = AppColors.secondary;
                  icon = Icons.verified_user_outlined;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: actionColor.withOpacity(0.12),
                      child: Icon(icon, color: actionColor, size: 20),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.action.replaceAll('_', ' '),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.recordType.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Actor: ${log.memberName ?? "Resident Member"} • ${DateFormatter.formatDateTime(log.timestamp)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Record ID: ${log.recordId}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            if (log.newValues != null) ...[
                              const Text('Logged Payload Values:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  const JsonEncoder.withIndent('  ').convert(log.newValues),
                                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
