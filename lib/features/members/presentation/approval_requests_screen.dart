import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../shared/models/registration_request_model.dart';
import '../../authentication/data/auth_repository.dart';
import '../../registration/data/registration_repository.dart';
import '../data/members_repository.dart';

class ApprovalRequestsScreen extends ConsumerStatefulWidget {
  const ApprovalRequestsScreen({super.key});

  @override
  ConsumerState<ApprovalRequestsScreen> createState() => _ApprovalRequestsScreenState();
}

class _ApprovalRequestsScreenState extends ConsumerState<ApprovalRequestsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleDecision(RegistrationRequestModel req, String decision) async {
    final l10n = context.l10n;
    final activeMember = ref.read(authStateProvider).activeMember;

    // Self-approval check
    if (activeMember != null && activeMember.authUid == req.authUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selfApprovalError), backgroundColor: AppColors.expenseRed),
      );
      return;
    }

    _commentController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(decision == 'APPROVED' ? l10n.approve : l10n.reject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm $decision decision for ${req.fullName} (${req.flatNumber}).'),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: l10n.approvalNotes,
                hintText: decision == 'APPROVED' ? 'e.g. Possession letter verified' : 'Reason for rejection',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: decision == 'APPROVED' ? AppColors.incomeGreen : AppColors.expenseRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(decision == 'APPROVED' ? l10n.approve : l10n.reject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(registrationRepositoryProvider).reviewRequest(
          requestId: req.requestId,
          decision: decision,
          comments: _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        );
        ref.invalidate(pendingRegistrationsProvider);
        ref.invalidate(membersListProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decision == 'APPROVED' ? l10n.approvalSuccess : l10n.rejectionSuccess),
              backgroundColor: decision == 'APPROVED' ? AppColors.incomeGreen : AppColors.expenseRed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.expenseRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final requestsAsync = ref.watch(pendingRegistrationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.approvals),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyStateView(
              icon: Icons.how_to_reg_outlined,
              title: 'No Pending Registration Requests',
              subtitle: 'When new residents join society and verify their phone number, their applications appear here for verification.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(pendingRegistrationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.warningAmber.withOpacity(0.12),
                              child: const Icon(Icons.person_outline, color: AppColors.warningAmber, size: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warningAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('PENDING APPROVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warningAmber)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(req.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Flat: ${req.flatNumber} • Phone: ${req.phoneNumber}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        if (req.additionalInformation != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              req.additionalInformation!,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Submitted: ${DateFormatter.formatDateTime(req.submittedAt)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleDecision(req, 'REJECTED'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.expenseRed,
                                  side: const BorderSide(color: AppColors.expenseRed),
                                ),
                                child: Text(l10n.reject),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleDecision(req, 'APPROVED'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.incomeGreen,
                                ),
                                child: Text(l10n.approve),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
