import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../shared/models/festival_model.dart';
import '../data/festivals_repository.dart';

class FestivalsScreen extends ConsumerWidget {
  const FestivalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final festivalsAsync = ref.watch(festivalsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.festivals),
      ),
      body: festivalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (festivals) {
          if (festivals.isEmpty) {
            return EmptyStateView(
              icon: Icons.celebration_outlined,
              title: 'No Society Festivals Created',
              subtitle: 'Plan upcoming Navratri, Diwali, Ganesh Chaturthi or community events.',
              actionLabel: l10n.createFestival,
              onAction: () => context.push('/festivals/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(festivalsListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: festivals.length,
              itemBuilder: (context, index) {
                final fest = festivals[index];
                return _buildFestivalCard(context, fest);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/festivals/create'),
        icon: const Icon(Icons.add),
        label: Text(l10n.createFestival),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildFestivalCard(BuildContext context, FestivalModel fest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/festivals/${fest.festivalId}', extra: fest),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondary.withOpacity(0.12),
                    child: const Icon(Icons.celebration, color: AppColors.secondary, size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      fest.status,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                fest.festivalName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (fest.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  fest.description!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormatter.formatShort(fest.startDate)} to ${DateFormatter.formatShort(fest.endDate)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFinancialStat('Collected', CurrencyFormatter.formatINR(fest.totalContributions), AppColors.incomeGreen),
                  _buildFinancialStat('Expenses', CurrencyFormatter.formatINR(fest.totalExpenses), AppColors.expenseRed),
                  _buildFinancialStat('Fund Balance', CurrencyFormatter.formatINR(fest.remainingBalance), AppColors.primary, isBold: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialStat(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class CreateFestivalScreen extends ConsumerStatefulWidget {
  const CreateFestivalScreen({super.key});

  @override
  ConsumerState<CreateFestivalScreen> createState() => _CreateFestivalScreenState();
}

class _CreateFestivalScreenState extends ConsumerState<CreateFestivalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 16));
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final openingBal = double.tryParse(_openingBalanceController.text.trim()) ?? 0.0;
      await ref.read(festivalsRepositoryProvider).createFestival(
        festivalName: _nameController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        startDate: _startDate,
        endDate: _endDate,
        openingFundBalance: openingBal,
      );

      ref.invalidate(festivalsListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.successRecorded), backgroundColor: AppColors.incomeGreen),
        );
        context.pop();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createFestival),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
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
                        l10n.createFestival,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Creating a festival automatically establishes an isolated dedicated festival fund in the society ledger.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_error!, style: const TextStyle(color: AppColors.expenseRed, fontSize: 12)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Festival Name (e.g. Navratri Mahotsav 2026)',
                          prefixIcon: const Icon(Icons.celebration, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? l10n.validationRequired : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description & Community Notice',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              title: const Text('Start Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              subtitle: Text(DateFormatter.formatShort(_startDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onTap: () async {
                                final p = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2025), lastDate: DateTime(2030));
                                if (p != null) setState(() => _startDate = p);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              title: const Text('End Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              subtitle: Text(DateFormatter.formatShort(_endDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onTap: () async {
                                final p = await showDatePicker(context: context, initialDate: _endDate, firstDate: _startDate, lastDate: DateTime(2030));
                                if (p != null) setState(() => _endDate = p);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _openingBalanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fund Opening Balance (₹)',
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text('₹', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.createFestival),
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
