import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/announcements_repository.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _showCreateNoticeDialog() async {
    final l10n = context.l10n;
    _titleController.clear();
    _messageController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.createAnnouncement),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Notice Title', hintText: 'e.g. Water Tank Cleaning Schedule'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Message Body', alignLabelWithHint: true, hintText: 'Detailed notice information for residents...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Publish Notice'),
          ),
        ],
      ),
    );

    if (result == true && _titleController.text.trim().isNotEmpty) {
      await ref.read(announcementsRepositoryProvider).createAnnouncement(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );
      ref.invalidate(announcementsListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final noticesAsync = ref.watch(announcementsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.announcements),
      ),
      body: noticesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (notices) {
          if (notices.isEmpty) {
            return EmptyStateView(
              icon: Icons.campaign_outlined,
              title: 'No Active Announcements',
              subtitle: 'Any active resident can publish community notices here.',
              actionLabel: l10n.createAnnouncement,
              onAction: _showCreateNoticeDialog,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(announcementsListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.campaign, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${notice.createdByName ?? "Resident Member"} • ${DateFormatter.formatDateTime(notice.createdAt)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notice.message,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateNoticeDialog,
        icon: const Icon(Icons.edit),
        label: Text(l10n.createAnnouncement),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
