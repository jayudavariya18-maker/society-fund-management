import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../authentication/data/auth_repository.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() { _isRefreshing = true; });
    try {
      await ref.read(authStateProvider.notifier).refreshStatus();
      final authState = ref.read(authStateProvider);
      if (authState.status == AuthStatus.activeMember) {
        if (mounted) context.go('/');
      }
    } finally {
      if (mounted) setState(() { _isRefreshing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final req = authState.pendingRequest;
    final isRejected = authState.status == AuthStatus.rejected;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
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
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // RamSeva Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 1.8),
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.societyName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isRejected ? AppColors.expenseRed.withValues(alpha: 0.12) : AppColors.warningAmber.withValues(alpha: 0.12),
                      child: Icon(
                        isRejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded,
                        size: 30,
                        color: isRejected ? AppColors.expenseRed : AppColors.warningAmber,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isRejected ? l10n.rejectedTitle : l10n.pendingTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isRejected ? AppColors.expenseRed : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRejected
                          ? (authState.errorMessage ?? 'Your registration request could not be verified by society members.')
                          : l10n.pendingMessage,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Submitted Details Summary
                    if (req != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(l10n.fullName, req.fullName),
                            const Divider(height: 12),
                            _buildInfoRow(l10n.flatNumber, req.flatNumber),
                            const Divider(height: 12),
                            _buildInfoRow(l10n.phoneNumber, req.phoneNumber),
                            const Divider(height: 12),
                            _buildInfoRow(l10n.status, req.requestStatus),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (!isRejected) ...[
                      ElevatedButton.icon(
                        onPressed: _isRefreshing ? null : _handleRefresh,
                        icon: _isRefreshing
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.refresh, size: 20),
                        label: Text(l10n.checkStatus),
                      ),
                    ] else ...[
                      OutlinedButton(
                        onPressed: () {
                          ref.read(authStateProvider.notifier).signOut();
                          context.go('/login');
                        },
                        child: Text(l10n.logout),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
