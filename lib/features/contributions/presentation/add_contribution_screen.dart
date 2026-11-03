import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../funds/data/funds_repository.dart';
import '../../members/data/members_repository.dart';
import '../data/contributions_repository.dart';

class AddContributionScreen extends ConsumerStatefulWidget {
  final String? initialFundId;

  const AddContributionScreen({super.key, this.initialFundId});

  @override
  ConsumerState<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends ConsumerState<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedFundId;
  String? _selectedMemberId;
  String _contributionType = 'MONTHLY_MAINTENANCE';
  String _paymentMethod = 'UPI';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedFundId = widget.initialFundId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFundId == null) {
      setState(() { _errorMessage = 'Please select a fund'; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final amount = double.parse(_amountController.text.trim());
      final newContrib = await ref.read(contributionsRepositoryProvider).addContribution(
        fundId: _selectedFundId!,
        memberId: _selectedMemberId,
        amount: amount,
        contributionType: _contributionType,
        paymentMethod: _paymentMethod,
        transactionReference: _refController.text.trim().isNotEmpty ? _refController.text.trim() : null,
        paymentDate: _paymentDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      // Refresh ledgers
      ref.invalidate(fundsListProvider);
      ref.invalidate(contributionsListProvider(null));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.successRecorded), backgroundColor: AppColors.incomeGreen),
        );
        context.pushReplacement('/receipts/${newContrib.receiptNumber}', extra: newContrib);
      }
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fundsAsync = ref.watch(fundsListProvider);
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addContribution),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.addContribution,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Every rupee deposited is credited to the society fund and automatically issues a digital receipt.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.expenseRed.withOpacity(0.3)),
                          ),
                          child: Text(_errorMessage!, style: const TextStyle(color: AppColors.expenseRed, fontSize: 12)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Select Fund
                      fundsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Error loading funds'),
                        data: (funds) {
                          _selectedFundId ??= funds.firstOrNull?.fundId;
                          return DropdownButtonFormField<String>(
                            value: _selectedFundId,
                            decoration: InputDecoration(
                              labelText: l10n.fundName,
                              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                            ),
                            items: funds.map((f) => DropdownMenuItem(
                              value: f.fundId,
                              child: Text('${f.fundName} (${f.fundType})', maxLines: 1, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedFundId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Select Member / Donor
                      membersAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (members) {
                          return DropdownButtonFormField<String?>(
                            value: _selectedMemberId,
                            decoration: InputDecoration(
                              labelText: l10n.member,
                              prefixIcon: const Icon(Icons.person_outline, size: 20),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Anonymous / Non-resident Donor'),
                              ),
                              ...members.map((m) => DropdownMenuItem<String?>(
                                value: m.memberId,
                                child: Text('${m.flatNumber} - ${m.fullName}'),
                              )),
                            ],
                            onChanged: (val) => setState(() => _selectedMemberId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount (₹)
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: l10n.amount,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text('₹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '5000',
                        ),
                        validator: (v) => Validators.positiveAmount(v, l10n.validationPositiveAmount),
                      ),
                      const SizedBox(height: 16),

                      // Contribution Type & Payment Method
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _contributionType,
                              decoration: InputDecoration(
                                labelText: l10n.contributionType,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'MONTHLY_MAINTENANCE', child: Text('Maintenance')),
                                DropdownMenuItem(value: 'FESTIVAL_CONTRIBUTION', child: Text('Festival')),
                                DropdownMenuItem(value: 'GENERAL_DONATION', child: Text('General')),
                                DropdownMenuItem(value: 'SPECIAL_CONTRIBUTION', child: Text('Special')),
                                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                              ],
                              onChanged: (v) => setState(() => _contributionType = v ?? 'MONTHLY_MAINTENANCE'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _paymentMethod,
                              decoration: InputDecoration(
                                labelText: l10n.paymentMethod,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'UPI', child: Text('UPI / QR')),
                                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                                DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank NEFT')),
                                DropdownMenuItem(value: 'CHEQUE', child: Text('Cheque')),
                                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                              ],
                              onChanged: (v) => setState(() => _paymentMethod = v ?? 'UPI'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Transaction Reference
                      TextFormField(
                        controller: _refController,
                        decoration: InputDecoration(
                          labelText: l10n.transactionReference,
                          prefixIcon: const Icon(Icons.tag, size: 20),
                          hintText: 'UPI UTR / Bank Ref / Cheque No.',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Date Picker
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        leading: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                        title: Text(
                          '${l10n.paymentDate}: ${DateFormatter.formatShort(_paymentDate)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _paymentDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) setState(() => _paymentDate = picked);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.notes,
                          alignLabelWithHint: true,
                          hintText: 'e.g. October month maintenance + Navratri sponsorship',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.incomeGreen,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.addContribution),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
