import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/contribution_model.dart';
import '../../../shared/models/society_model.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final String receiptNumber;
  final ContributionModel? contribution;

  const ReceiptPreviewScreen({
    super.key,
    required this.receiptNumber,
    this.contribution,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = contribution;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptTitle),
        actions: [
          IconButton(
            tooltip: l10n.shareReceipt,
            icon: const Icon(Icons.share),
            onPressed: () async {
              if (c != null) {
                final pdfBytes = await PdfService.generateReceiptPdf(society: society, contribution: c);
                await Printing.sharePdf(bytes: pdfBytes, filename: '${c.receiptNumber}.pdf');
              }
            },
          ),
          IconButton(
            tooltip: l10n.printReceipt,
            icon: const Icon(Icons.print),
            onPressed: () async {
              if (c != null) {
                await Printing.layoutPdf(
                  onLayout: (format) => PdfService.generateReceiptPdf(society: society, contribution: c),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Society Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            society.societyName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${society.address}, ${society.city} - ${society.pincode}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.incomeGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'OFFICIAL PAYMENT RECEIPT',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.incomeGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Receipt Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Receipt No: $receiptNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          DateFormatter.formatShort(c?.paymentDate ?? DateTime.now()),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Key-Value Grid
                    _buildReceiptRow(l10n.member, c?.memberName ?? 'Anonymous Donor'),
                    if (c?.flatNumber != null) _buildReceiptRow(l10n.flatNumber, c!.flatNumber!),
                    _buildReceiptRow(l10n.fundName, c?.fundName ?? 'General Society Fund'),
                    _buildReceiptRow(l10n.contributionType, c?.contributionType.replaceAll('_', ' ') ?? 'Payment'),
                    _buildReceiptRow(l10n.paymentMethod, c?.paymentMethod ?? 'UPI'),
                    if (c?.transactionReference != null)
                      _buildReceiptRow(l10n.transactionReference, c!.transactionReference!),
                    if (c?.notes != null)
                      _buildReceiptRow(l10n.notes, c!.notes!),

                    const SizedBox(height: 20),

                    // Amount Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.incomeGreen.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.incomeGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('AMOUNT RECEIVED:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.incomeGreen)),
                          Text(
                            CurrencyFormatter.formatINR(c?.amount ?? 0),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.incomeGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Signature footnote
                    Text(
                      'Recorded By: ${c?.createdByName ?? "Active Member"} • Verified On Ledger',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              if (c != null) {
                                await Printing.layoutPdf(
                                  onLayout: (format) => PdfService.generateReceiptPdf(society: society, contribution: c),
                                );
                              }
                            },
                            icon: const Icon(Icons.print, size: 18),
                            label: Text(l10n.printReceipt),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
