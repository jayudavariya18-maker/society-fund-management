import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/fund_model.dart';
import '../../festivals/data/festivals_repository.dart';
import '../../funds/data/funds_repository.dart';
import '../data/expenses_repository.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? initialFundId;

  const AddExpenseScreen({super.key, this.initialFundId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _vendorController = TextEditingController();
  final _refController = TextEditingController();

  String? _selectedFundId;
  String? _selectedEventId;
  String _category = 'MAINTENANCE';
  String _paymentMethod = 'UPI';
  DateTime _expenseDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedFundId = widget.initialFundId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _vendorController.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFundId == null) {
      setState(() { _error = 'Please select a fund'; });
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      final amount = double.parse(_amountController.text.trim());
      await ref.read(expensesRepositoryProvider).addExpense(
        fundId: _selectedFundId!,
        eventId: _selectedEventId,
        amount: amount,
        expenseCategory: _category,
        description: _descController.text.trim(),
        vendorName: _vendorController.text.trim().isNotEmpty ? _vendorController.text.trim() : null,
        paymentMethod: _paymentMethod,
        expenseDate: _expenseDate,
        receiptReference: _refController.text.trim().isNotEmpty ? _refController.text.trim() : null,
      );

      // Invalidate providers
      ref.invalidate(fundsListProvider);
      ref.invalidate(expensesListProvider(null));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.successRecorded), backgroundColor: AppColors.incomeGreen),
        );
        context.go('/funds');
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fundsAsync = ref.watch(fundsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addExpense),
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
                        l10n.addExpense,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.expenseRed),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Outgoing society disbursements are recorded in real-time with full member audit visibility.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.expenseRed.withOpacity(0.3)),
                          ),
                          child: Text(_error!, style: const TextStyle(color: AppColors.expenseRed, fontSize: 12)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Select Fund
                      fundsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Error loading funds'),
                        data: (funds) {
                          _selectedFundId ??= funds.firstOrNull?.fundId;
                          final selectedFund = funds.firstWhere((f) => f.fundId == _selectedFundId, orElse: () => funds.first);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedFundId,
                                decoration: InputDecoration(
                                  labelText: l10n.fundName,
                                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                                ),
                                items: funds.map((f) => DropdownMenuItem(
                                  value: f.fundId,
                                  child: Text('${f.fundName} (${f.fundType})', maxLines: 1, overflow: TextOverflow.ellipsis),
                                )).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedFundId = val;
                                    _selectedEventId = null; // reset event if fund changes
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              // Live Available Balance Indicator
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${l10n.availableBalance}:', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text(
                                      CurrencyFormatter.formatINR(selectedFund.currentBalance),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: selectedFund.currentBalance > 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          labelText: l10n.expenseCategory,
                          prefixIcon: const Icon(Icons.category_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'MAINTENANCE', child: Text('General Maintenance')),
                          DropdownMenuItem(value: 'ELECTRICITY', child: Text('Electricity')),
                          DropdownMenuItem(value: 'CLEANING', child: Text('Cleaning & Sanitation')),
                          DropdownMenuItem(value: 'SECURITY', child: Text('Security Guard')),
                          DropdownMenuItem(value: 'REPAIRS', child: Text('Repairs & Civil Work')),
                          DropdownMenuItem(value: 'DECORATION', child: Text('Decoration & Lighting')),
                          DropdownMenuItem(value: 'FOOD', child: Text('Food & Mahaprasad')),
                          DropdownMenuItem(value: 'SOUND_SYSTEM', child: Text('Sound System & Orchestra')),
                          DropdownMenuItem(value: 'TRANSPORTATION', child: Text('Transportation')),
                          DropdownMenuItem(value: 'EVENT_ARRANGEMENTS', child: Text('Event Arrangements')),
                          DropdownMenuItem(value: 'PRINTING', child: Text('Printing & Stationery')),
                          DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _category = v ?? 'MAINTENANCE'),
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
                            child: Text('₹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.expenseRed)),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '2500',
                        ),
                        validator: (v) => Validators.positiveAmount(v, l10n.validationPositiveAmount),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          prefixIcon: const Icon(Icons.description_outlined, size: 20),
                          hintText: 'e.g. Common hallway tube light replacements',
                        ),
                        validator: (v) => Validators.requiredField(v, l10n.validationRequired),
                      ),
                      const SizedBox(height: 16),

                      // Vendor Name & Payment Method
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _vendorController,
                              decoration: InputDecoration(
                                labelText: l10n.vendorName,
                                prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
                                hintText: 'Vendor / Payee',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _paymentMethod,
                              decoration: InputDecoration(labelText: l10n.paymentMethod),
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

                      // Expense Date Picker
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        leading: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                        title: Text(
                          '${l10n.expenseDate}: ${DateFormatter.formatShort(_expenseDate)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _expenseDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) setState(() => _expenseDate = picked);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bill / Receipt Reference
                      TextFormField(
                        controller: _refController,
                        decoration: InputDecoration(
                          labelText: 'Bill / Invoice Number (optional)',
                          prefixIcon: const Icon(Icons.receipt_outlined, size: 20),
                          hintText: 'e.g. INV-99812',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Expense
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.expenseRed,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.addExpense),
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
