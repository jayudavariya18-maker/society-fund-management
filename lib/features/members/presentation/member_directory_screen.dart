import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/member_model.dart';
import '../data/members_repository.dart';

class MemberDirectoryScreen extends ConsumerStatefulWidget {
  const MemberDirectoryScreen({super.key});

  @override
  ConsumerState<MemberDirectoryScreen> createState() => _MemberDirectoryScreenState();
}

class _MemberDirectoryScreenState extends ConsumerState<MemberDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.members),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by resident name or flat (e.g. A-402)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Members List
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (members) {
                final filtered = members.where((m) {
                  if (_searchQuery.isEmpty) return true;
                  return m.fullName.toLowerCase().contains(_searchQuery) ||
                      m.flatNumber.toLowerCase().contains(_searchQuery) ||
                      m.phoneNumber.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No society members found matching query.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            member.flatNumber.split('-').last,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.incomeGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                member.membershipStatus,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeGreen),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text('Flat: ${member.flatNumber} • Joined: ${DateFormatter.formatShort(member.joinedAt)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(member.phoneNumber, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                if (member.email != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.email_outlined, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(member.email!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
