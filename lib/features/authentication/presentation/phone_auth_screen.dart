import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/localization/locale_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/validators.dart';
import '../data/auth_repository.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _inlineError;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _inlineError = null;
    });
    try {
      final phone = Validators.formatPhoneE164(_phoneController.text.trim());
      await ref.read(authStateProvider.notifier).sendOtp(phone);
    } catch (e) {
      setState(() {
        _inlineError = e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _inlineError = 'Please enter a valid 6-digit OTP code.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _inlineError = null;
    });
    try {
      await ref.read(authStateProvider.notifier).verifyOtp(otp);
      final authState = ref.read(authStateProvider);
      if (authState.status == AuthStatus.activeMember) {
        if (mounted) context.go('/');
      } else if (authState.status == AuthStatus.pendingApproval) {
        if (mounted) context.go('/pending-approval');
      } else if (authState.status == AuthStatus.unregistered) {
        if (mounted) context.go('/register');
      }
    } catch (e) {
      setState(() {
        _inlineError = e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final isOtpSent = authState.status == AuthStatus.otpSent;
    final isMockMode = SupabaseService.instance.isMockDevMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Official RamSeva Logo
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.25),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.societyName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Society Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"${l10n.dashboardTagline}"',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.loginTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOtpSent
                            ? 'Enter the 6-digit verification code sent to ${_phoneController.text.trim()}'
                            : l10n.loginSubtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      if (_inlineError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.expenseRed.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _inlineError!,
                            style: const TextStyle(fontSize: 12, color: AppColors.expenseRed, height: 1.3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Phone Input
                      if (!isOtpSent) ...[
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.phoneNumber,
                            prefixIcon: const Icon(Icons.phone_android, size: 20, color: AppColors.primary),
                            hintText: '+91 98765 43210',
                            helperText: 'Enter 10-digit mobile number with or without +91',
                          ),
                          validator: (val) => Validators.validIndianPhone(val, l10n.validationValidPhone),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(l10n.sendOtp),
                        ),
                      ],

                      // OTP Input
                      if (isOtpSent) ...[
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                          decoration: InputDecoration(
                            labelText: l10n.enterOtp,
                            counterText: '',
                            prefixIcon: const Icon(Icons.lock_clock_outlined, size: 20, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(l10n.verifyOtp),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _otpController.clear();
                                  _inlineError = null;
                                });
                                ref.read(authStateProvider.notifier).signOut();
                              },
                              child: const Text('Change Number', style: TextStyle(fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : _handleSendOtp,
                              child: Text(l10n.resendOtp, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],

                      if (isMockMode) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Development Evaluation Mode: Enter any valid mobile number. Verification OTP code is 123456.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
