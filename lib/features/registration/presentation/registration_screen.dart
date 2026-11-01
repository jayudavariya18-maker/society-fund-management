import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../authentication/data/auth_repository.dart';
import '../data/registration_repository.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _infoController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await ref.read(registrationRepositoryProvider).submitRequest(
        fullName: _nameController.text.trim(),
        flatNumber: _flatController.text.trim(),
        additionalInfo: _infoController.text.trim().isNotEmpty ? _infoController.text.trim() : null,
      );
      await ref.read(authStateProvider.notifier).refreshStatus();
      if (mounted) context.go('/pending-approval');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = ref.watch(authStateProvider).phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registrationTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.secondary.withOpacity(0.12),
                          child: const Icon(Icons.person_add_rounded, size: 32, color: AppColors.secondary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.registrationTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.registrationSubtitle,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

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

                      // Verified Mobile Number (Read-only)
                      TextFormField(
                        initialValue: phone,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: const Icon(Icons.phone_android, size: 20),
                          suffixIcon: const Icon(Icons.verified, color: AppColors.incomeGreen, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          hintText: 'e.g. Bhavikbhai Joshi',
                        ),
                        validator: (v) => Validators.requiredField(v, l10n.validationRequired),
                      ),
                      const SizedBox(height: 16),

                      // Flat Number
                      TextFormField(
                        controller: _flatController,
                        decoration: InputDecoration(
                          labelText: l10n.flatNumber,
                          prefixIcon: const Icon(Icons.meeting_room_outlined, size: 20),
                          hintText: 'e.g. B-503',
                        ),
                        validator: (v) => Validators.requiredField(v, l10n.validationRequired),
                      ),
                      const SizedBox(height: 16),

                      // Additional Info
                      TextFormField(
                        controller: _infoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.additionalInfo,
                          alignLabelWithHint: true,
                          hintText: 'Ownership details, possession date, or landlord name',
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.submitRequest),
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
