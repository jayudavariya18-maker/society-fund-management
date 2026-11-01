import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/localization/locale_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../data/auth_repository.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '+919825000001');
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
    setState(() { _isLoading = true; _inlineError = null; });
    try {
      final phone = Validators.formatPhoneE164(_phoneController.text.trim());
      await ref.read(authStateProvider.notifier).sendOtp(phone);
    } catch (e) {
      setState(() { _inlineError = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() { _inlineError = 'Please enter a valid 6-digit OTP code'; });
      return;
    }
    setState(() { _isLoading = true; _inlineError = null; });
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
      setState(() { _inlineError = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final isOtpSent = authState.status == AuthStatus.otpSent;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
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
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & Title
                      Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.apartment_rounded, size: 36, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loginTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isOtpSent ? 'Enter the 6-digit code sent to ${_phoneController.text}' : l10n.loginSubtitle,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      if (_inlineError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.expenseRed.withOpacity(0.3)),
                          ),
                          child: Text(
                            _inlineError!,
                            style: const TextStyle(fontSize: 12, color: AppColors.expenseRed),
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
                            prefixIcon: const Icon(Icons.phone_android, size: 20),
                            hintText: '+91 98250 00001',
                          ),
                          validator: (val) => Validators.validIndianPhone(val, l10n.validationValidPhone),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                          decoration: InputDecoration(
                            labelText: l10n.enterOtp,
                            counterText: '',
                            prefixIcon: const Icon(Icons.lock_clock_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerifyOtp,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(l10n.verifyOtp),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          child: Text(l10n.resendOtp),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Dev quick test options
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dev Quick Fill (Click to test):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: [
                                ActionChip(
                                  label: const Text('Active Member (+919825000001)', style: TextStyle(fontSize: 10)),
                                  onPressed: () {
                                    setState(() {
                                      _phoneController.text = '+919825000001';
                                      _otpController.text = '123456';
                                    });
                                  },
                                ),
                                ActionChip(
                                  label: const Text('Pending User (+919825000004)', style: TextStyle(fontSize: 10)),
                                  onPressed: () {
                                    setState(() {
                                      _phoneController.text = '+919825000004';
                                      _otpController.text = '123456';
                                    });
                                  },
                                ),
                              ],
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
