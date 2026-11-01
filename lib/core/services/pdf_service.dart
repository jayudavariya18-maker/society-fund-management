import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../shared/models/contribution_model.dart';
import '../../shared/models/fund_model.dart';
import '../../shared/models/society_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class PdfService {
  /// Generates and previews a digital PDF receipt for a contribution
  static Future<Uint8List> generateReceiptPdf({
    required SocietyModel society,
    required ContributionModel contribution,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey800, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        society.societyName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${society.address}, ${society.city} - ${society.pincode}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Phone: ${society.contactNumber}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Divider(thickness: 1, color: PdfColors.grey400),
                      pw.Text(
                        'OFFICIAL PAYMENT RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ),

                // Receipt Metadata
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Receipt No: ${contribution.receiptNumber}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('Date: ${DateFormatter.formatShort(contribution.paymentDate)}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 12),

                // Details Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    _buildTableRow('Member / Donor', contribution.memberName ?? 'Anonymous'),
                    _buildTableRow('Flat / Unit No.', contribution.flatNumber ?? 'N/A'),
                    _buildTableRow('Credited Fund', contribution.fundName ?? 'General Society Fund'),
                    _buildTableRow('Contribution Type', contribution.contributionType.replaceAll('_', ' ')),
                    _buildTableRow('Payment Method', contribution.paymentMethod),
                    if (contribution.transactionReference != null && contribution.transactionReference!.isNotEmpty)
                      _buildTableRow('Ref / UTR No.', contribution.transactionReference!),
                    if (contribution.notes != null && contribution.notes!.isNotEmpty)
                      _buildTableRow('Notes / Purpose', contribution.notes!),
                  ],
                ),

                pw.SizedBox(height: 16),

                // Amount Highlight Box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green700, width: 1.5),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL AMOUNT RECEIVED:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.green900),
                      ),
                      pw.Text(
                        CurrencyFormatter.formatINR(contribution.amount),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.green900),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Signatures & Audit Footnote
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Verified By Society Ledger',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                        pw.Text('Recorded By: ${contribution.createdByName ?? "Resident Member"}',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.SizedBox(height: 20),
                        pw.Container(width: 90, height: 1, color: PdfColors.grey600),
                        pw.SizedBox(height: 2),
                        pw.Text('Authorized Signature',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'This is a computer-generated society receipt. All records are verifiable in society audit logs.',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates a comprehensive Financial Statement Report in PDF format
  static Future<Uint8List> generateFinancialReportPdf({
    required SocietyModel society,
    required List<FundModel> funds,
    required double totalSocietyBalance,
    required double totalIncome,
    required double totalExpense,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // Header
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  society.societyName,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
                pw.Text(
                  '${society.address}, ${society.city} - ${society.pincode}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'FINANCIAL SUMMARY & FUND STATEMENT',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                ),
                pw.Text(
                  'Period: ${DateFormatter.formatShort(fromDate)} to ${DateFormatter.formatShort(toDate)}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blueGrey300),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Overview Stats
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCard('Total Society Balance', CurrencyFormatter.formatINR(totalSocietyBalance), PdfColors.blue800),
              _buildMetricCard('Total Contributions', CurrencyFormatter.formatINR(totalIncome), PdfColors.green800),
              _buildMetricCard('Total Expenses', CurrencyFormatter.formatINR(totalExpense), PdfColors.red800),
            ],
          ),
          pw.SizedBox(height: 18),

          // Funds Breakdown Table
          pw.Text('FUNDS BREAKDOWN (EXACT BALANCES)',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Fund Name', 'Type', 'Opening', 'Received', 'Spent', 'Current Balance'],
            data: funds.map((f) => [
              f.fundName,
              f.fundType,
              CurrencyFormatter.formatINR(f.openingBalance),
              CurrencyFormatter.formatINR(f.totalContributions),
              CurrencyFormatter.formatINR(f.totalExpenses),
              CurrencyFormatter.formatINR(f.currentBalance),
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 24),

          // Audit confirmation text
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Text(
              'Certified that the above statement has been computed directly from posted ledger records. Every active society member holds equal auditing access under the society constitution.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
        ),
      ],
    );
  }

  static pw.Widget _buildMetricCard(String label, String value, PdfColor color) {
    return pw.Container(
      width: 155,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
