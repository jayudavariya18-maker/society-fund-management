import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/responsive_scaffold.dart';
import '../features/announcements/presentation/announcements_screen.dart';
import '../features/audit_logs/presentation/audit_logs_screen.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/presentation/phone_auth_screen.dart';
import '../features/contributions/presentation/add_contribution_screen.dart';
import '../features/contributions/presentation/receipt_preview_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/expenses/presentation/add_expense_screen.dart';
import '../features/festivals/presentation/festivals_screen.dart';
import '../features/funds/presentation/funds_screen.dart';
import '../features/members/presentation/approval_requests_screen.dart';
import '../features/members/presentation/member_directory_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/registration/presentation/pending_approval_screen.dart';
import '../features/registration/presentation/registration_screen.dart';
import '../shared/models/contribution_model.dart';
import '../shared/models/fund_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final status = authState.status;
      final path = state.uri.path;

      final isAuthFlow = path == '/login' || path == '/register' || path == '/pending-approval';

      // 1. Unauthenticated or waiting for OTP
      if (status == AuthStatus.unauthenticated || status == AuthStatus.otpSent) {
        return path == '/login' ? null : '/login';
      }

      // 2. Unregistered phone (verified OTP, needs to submit flat & name)
      if (status == AuthStatus.unregistered) {
        return path == '/register' ? null : '/register';
      }

      // 3. Pending verification or rejected
      if (status == AuthStatus.pendingApproval || status == AuthStatus.rejected) {
        return path == '/pending-approval' ? null : '/pending-approval';
      }

      // 4. Active Member accessing login screens -> redirect to dashboard
      if (status == AuthStatus.activeMember && isAuthFlow) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),

      // Shell Route with Responsive Multi-Platform Scaffold
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final p = state.uri.path;
          if (p == '/') index = 0;
          else if (p.startsWith('/funds')) index = 1;
          else if (p.startsWith('/festivals')) index = 2;
          else if (p.startsWith('/reports')) index = 3;
          else if (p.startsWith('/profile')) index = 4;

          return ResponsiveScaffold(
            selectedIndex: index,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/funds',
            builder: (context, state) => const FundsScreen(),
          ),
          GoRoute(
            path: '/festivals',
            builder: (context, state) => const FestivalsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Modals and Details Routes
      GoRoute(
        path: '/funds/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final fund = state.extra as FundModel?;
          return FundDetailsScreen(fundId: id, fundModel: fund);
        },
      ),
      GoRoute(
        path: '/festivals/create',
        builder: (context, state) => const CreateFestivalScreen(),
      ),
      GoRoute(
        path: '/contributions/add',
        builder: (context, state) {
          final fundId = state.extra as String?;
          return AddContributionScreen(initialFundId: fundId);
        },
      ),
      GoRoute(
        path: '/expenses/add',
        builder: (context, state) {
          final fundId = state.extra as String?;
          return AddExpenseScreen(initialFundId: fundId);
        },
      ),
      GoRoute(
        path: '/receipts/:receiptNo',
        builder: (context, state) {
          final rNo = state.pathParameters['receiptNo'] ?? '';
          final contrib = state.extra as ContributionModel?;
          return ReceiptPreviewScreen(receiptNumber: rNo, contribution: contrib);
        },
      ),
      GoRoute(
        path: '/members',
        builder: (context, state) => const MemberDirectoryScreen(),
      ),
      GoRoute(
        path: '/approvals',
        builder: (context, state) => const ApprovalRequestsScreen(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: '/audit-logs',
        builder: (context, state) => const AuditLogsScreen(),
      ),
    ],
  );
});
