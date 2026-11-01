import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/localization/locale_provider.dart';
import '../../app/theme/app_colors.dart';
import '../../features/authentication/data/auth_repository.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final Widget child;
  final int selectedIndex;

  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;
    final authState = ref.watch(authStateProvider);
    final member = authState.activeMember;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Desktop Sidebar Navigation
            Container(
              width: 240,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  // Header Logo & Society Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.divider)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 18,
                          child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.appTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                member?.flatNumber != null ? '${member!.flatNumber} • ${member.fullName}' : 'Resident Member',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        _buildNavItem(context, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: l10n.home, index: 0, route: '/'),
                        _buildNavItem(context, icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: l10n.funds, index: 1, route: '/funds'),
                        _buildNavItem(context, icon: Icons.celebration_outlined, activeIcon: Icons.celebration, label: l10n.festivals, index: 2, route: '/festivals'),
                        _buildNavItem(context, icon: Icons.assessment_outlined, activeIcon: Icons.assessment, label: l10n.reports, index: 3, route: '/reports'),
                        const Divider(height: 24, indent: 16, endIndent: 16),
                        _buildNavItem(context, icon: Icons.people_outline, activeIcon: Icons.people, label: l10n.members, index: 5, route: '/members'),
                        _buildNavItem(context, icon: Icons.campaign_outlined, activeIcon: Icons.campaign, label: l10n.announcements, index: 6, route: '/announcements'),
                        _buildNavItem(context, icon: Icons.how_to_reg_outlined, activeIcon: Icons.how_to_reg, label: l10n.approvals, index: 7, route: '/approvals'),
                        _buildNavItem(context, icon: Icons.history_outlined, activeIcon: Icons.history, label: l10n.auditLogs, index: 8, route: '/audit-logs'),
                        const Divider(height: 24, indent: 16, endIndent: 16),
                        _buildNavItem(context, icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.profile, index: 4, route: '/profile'),
                      ],
                    ),
                  ),

                  // Language Selector Pill
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildLanguageToggle(context, ref),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Android Layout
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (member != null)
              Text('${member.flatNumber} • ${member.fullName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.announcements,
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () => context.push('/announcements'),
          ),
          IconButton(
            tooltip: l10n.language,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => _showLanguageSheet(context, ref),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.apartment_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    member?.fullName ?? l10n.appTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    member?.flatNumber ?? l10n.tagline,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(l10n.home),
              onTap: () { Navigator.pop(context); context.go('/'); },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(l10n.funds),
              onTap: () { Navigator.pop(context); context.go('/funds'); },
            ),
            ListTile(
              leading: const Icon(Icons.celebration_outlined),
              title: Text(l10n.festivals),
              onTap: () { Navigator.pop(context); context.go('/festivals'); },
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: Text(l10n.reports),
              onTap: () { Navigator.pop(context); context.go('/reports'); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(l10n.members),
              onTap: () { Navigator.pop(context); context.push('/members'); },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: Text(l10n.announcements),
              onTap: () { Navigator.pop(context); context.push('/announcements'); },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_reg_outlined),
              title: Text(l10n.approvals),
              onTap: () { Navigator.pop(context); context.push('/approvals'); },
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: Text(l10n.auditLogs),
              onTap: () { Navigator.pop(context); context.push('/audit-logs'); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.profile),
              onTap: () { Navigator.pop(context); context.go('/profile'); },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.expenseRed),
              title: Text(l10n.logout, style: const TextStyle(color: AppColors.expenseRed)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, 4),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/funds'); break;
            case 2: context.go('/festivals'); break;
            case 3: context.go('/reports'); break;
            case 4: context.go('/profile'); break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.funds,
          ),
          NavigationDestination(
            icon: const Icon(Icons.celebration_outlined),
            selectedIcon: const Icon(Icons.celebration),
            label: l10n.festivals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assessment_outlined),
            selectedIcon: const Icon(Icons.assessment),
            label: l10n.reports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        onTap: () {
          if (route == '/' || route == '/funds' || route == '/festivals' || route == '/reports' || route == '/profile') {
            context.go(route);
          } else {
            context.push(route);
          }
        },
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLangButton(ref, 'en', 'EN', currentLocale.languageCode == 'en'),
          _buildLangButton(ref, 'gu', 'ગુજરાતી', currentLocale.languageCode == 'gu'),
          _buildLangButton(ref, 'hi', 'हिन्दी', currentLocale.languageCode == 'hi'),
        ],
      ),
    );
  }

  Widget _buildLangButton(WidgetRef ref, String code, String label, bool isSelected) {
    return InkWell(
      onTap: () => ref.read(localeProvider.notifier).setLocale(code),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.selectLanguage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              title: const Text('English'),
              trailing: ref.watch(localeProvider).languageCode == 'en' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('en');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('ગુજરાતી (Gujarati)'),
              trailing: ref.watch(localeProvider).languageCode == 'gu' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('gu');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('हिन्दी (Hindi)'),
              trailing: ref.watch(localeProvider).languageCode == 'hi' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('hi');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
