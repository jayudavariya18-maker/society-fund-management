import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/localization/locale_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../authentication/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final member = authState.activeMember;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Member Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Text(
                            member?.fullName.isNotEmpty == true ? member!.fullName[0] : 'R',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          member?.fullName ?? 'Resident Member',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.incomeGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Flat ${member?.flatNumber ?? "N/A"} • Active Resident',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.incomeGreen),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildProfileField('Phone Number', member?.phoneNumber ?? authState.phoneNumber ?? ''),
                        if (member?.email != null) _buildProfileField('Email Address', member!.email!),
                        if (member != null) _buildProfileField('Joined Society', DateFormatter.formatMedium(member.joinedAt)),
                        _buildProfileField('Governance Model', 'NO ROLES • Equal Member Transparency'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Language Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.language, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Switch application interface language. Changes persist across sessions.',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        RadioListTile<String>(
                          title: const Text('English (Default)'),
                          subtitle: const Text('Standard financial terms and numbers'),
                          value: 'en',
                          groupValue: currentLocale.languageCode,
                          onChanged: (v) => ref.read(localeProvider.notifier).setLocale('en'),
                        ),
                        RadioListTile<String>(
                          title: const Text('ગુજરાતી (Gujarati)'),
                          subtitle: const Text('સોસાયટી ખાતાવહી અને ઉત્સવ વ્યવસ્થાપન'),
                          value: 'gu',
                          groupValue: currentLocale.languageCode,
                          onChanged: (v) => ref.read(localeProvider.notifier).setLocale('gu'),
                        ),
                        RadioListTile<String>(
                          title: const Text('हिन्दी (Hindi)'),
                          subtitle: const Text('सोसाइटी वित्त एवं लेखा प्रबंधन'),
                          value: 'hi',
                          groupValue: currentLocale.languageCode,
                          onChanged: (v) => ref.read(localeProvider.notifier).setLocale('hi'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Society Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About Society Deployment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        const Text(
                          'Bajrang Heights Co-Operative Housing Society is configured as an autonomous single-society deployment. Every verified flat owner possesses identical permissions to record, inspect, audit, and approve society affairs.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text('Registered Society ID: 00000000-0000-0000-0000-000000000001', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.expenseRed),
                  label: Text(l10n.logout, style: const TextStyle(color: AppColors.expenseRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.expenseRed),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
