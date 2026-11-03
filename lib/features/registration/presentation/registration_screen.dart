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
  bool _isCheckingBootstrap = true;
  bool _isFirstMember = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkFirstMemberBootstrap();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstMemberBootstrap() async {
    try {
      final hasActive = await ref.read(authRepositoryProvider).hasActiveMembers();
      if (mounted) {
        setState(() {
          _isFirstMember = !hasActive;
          _isCheckingBootstrap = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingBootstrap = false;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isFirstMember) {
        // Secure Bootstrap of the very first society member
        await ref.read(authStateProvider.notifier).completeFirstMemberBootstrap(
          fullName: _nameController.text.trim(),
          flatNumber: _flatController.text.trim(),
          email: _infoController.text.trim().isNotEmpty ? _infoController.text.trim() : null,
        );
        if (mounted) context.go('/');
      } else {
        // Normal Registration Request requiring approval from any active member
        await ref.read(registrationRepositoryProvider).submitRequest(
          fullName: _nameController.text.trim(),
          flatNumber: _flatController.text.trim(),
          additionalInfo: _infoController.text.trim().isNotEmpty ? _infoController.text.trim() : null,
        );
        await ref.read(authStateProvider.notifier).refreshStatus();
        if (mounted) context.go('/pending-approval');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = ref.watch(authStateProvider).phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registrationTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: l10n.logout,
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
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // RamSeva Logo
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.25),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        l10n.societyName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.goldDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      // First Member Bootstrap Banner or Normal Banner
                      if (!_isCheckingBootstrap && _isFirstMember) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.stars_rounded, color: AppColors.goldDark, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Founding Resident Setup',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.goldDark),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'You are activating the first member account for Ramdevra Society. Your account will be activated immediately to initialize society records.',
                                      style: TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Text(
                          l10n.registrationSubtitle,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.expenseRed.withValues(alpha: 0.3)),
                          ),
                          child: Text(_error!, style: const TextStyle(color: AppColors.expenseRed, fontSize: 12), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Verified Mobile Number (Read-only)
                      TextFormField(
                        initialValue: phone,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: const Icon(Icons.phone_android, size: 20, color: AppColors.primary),
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
                          hintText: 'Enter your genuine full name',
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
                          hintText: 'e.g. A-101, B-202',
                        ),
                        validator: (v) => Validators.requiredField(v, l10n.validationRequired),
                      ),
                      const SizedBox(height: 16),

                      // Additional Info or Email
                      TextFormField(
                        controller: _infoController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: _isFirstMember ? 'Email Address (Optional)' : l10n.additionalInfo,
                          alignLabelWithHint: true,
                          hintText: _isFirstMember ? 'e.g. resident@gmail.com' : 'Ownership details or possession date',
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isFirstMember ? 'Activate First Member & Open Dashboard' : l10n.submitRequest),
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
