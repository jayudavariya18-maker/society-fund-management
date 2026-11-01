import 'package:flutter/material.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String? fundTag;
  final String? status;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.fundTag,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? "+" : "-"}${CurrencyFormatter.formatINR(amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormatter.formatShort(date),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            if (fundTag != null || status != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (fundTag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fundTag!,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  if (status != null && status != 'POSTED') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status!,
                        style: const TextStyle(fontSize: 10, color: AppColors.warningAmber, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
