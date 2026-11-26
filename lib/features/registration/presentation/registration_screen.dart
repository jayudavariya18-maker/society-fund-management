import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/localization/locale_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../authentication/data/auth_repository.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authStateProvider.notifier).registerWithSocietyPassword(
        fullName: _nameController.text.trim(),
        flatNumber: _flatController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        password: _passwordController.text.trim(),
      );

      final authState = ref.read(authStateProvider);
      if (authState.status == AuthStatus.activeMember && mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _error = e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('AuthException: ', '');
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registrationTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.selectLanguage,
            onSelected: (code) => ref.read(localeProvider.notifier).setLocale(code),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'gu', child: Text('ગુજરાતી (Gujarati)')),
              const PopupMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // RamSeva Emblem Logo
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.28),
                                blurRadius: 10,
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
                      const SizedBox(height: 10),

                      // Instruction header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user, color: AppColors.goldDark, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Register as a society resident with the common society password. Your account will be activated permanently.',
                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

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

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          hintText: 'e.g. Ramesh Patel',
                        ),
                        validator: (v) => Validators.requiredField(v, l10n.validationRequired),
                      ),
                      const SizedBox(height: 14),

                      // Flat Number
                      TextFormField(
                        controller: _flatController,
                        decoration: InputDecoration(
                          labelText: l10n.flatNumber,
                          prefixIcon: const Icon(Icons.meeting_room_outlined, size: 20),
                          hintText: 'e.g. A-402, B-101',
                        ),
                        validator: (v) => Validators.requiredField(v, l10n.validationRequired),
                      ),
                      const SizedBox(height: 14),

                      // Mobile Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: const Icon(Icons.phone_android, size: 20),
                          hintText: 'e.g. 9825012345',
                        ),
                        validator: (v) => Validators.validIndianPhone(v, l10n.validationValidPhone),
                      ),
                      const SizedBox(height: 14),

                      // Email (Optional)
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address (Optional)',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                          hintText: 'e.g. resident@gmail.com',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Common Society Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Common Society Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                          hintText: 'Enter society password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Common society password is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Register & Open Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),

                      // Already registered prompt
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already registered?',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: const Text(
                              'Login Here',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.key, size: 16, color: AppColors.goldDark),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ramdevra Society common access password: Ramdevra@2026',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
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
