import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/member_model.dart';
import '../../../shared/models/registration_request_model.dart';

enum AuthStatus {
  unauthenticated,
  otpSent,
  activeMember,
  pendingApproval,
  rejected,
  unregistered,
}

class AuthUserState {
  final AuthStatus status;
  final String? phoneNumber;
  final MemberModel? activeMember;
  final RegistrationRequestModel? pendingRequest;
  final String? errorMessage;

  const AuthUserState({
    this.status = AuthStatus.unauthenticated,
    this.phoneNumber,
    this.activeMember,
    this.pendingRequest,
    this.errorMessage,
  });

  AuthUserState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    MemberModel? activeMember,
    RegistrationRequestModel? pendingRequest,
    String? errorMessage,
  }) {
    return AuthUserState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      activeMember: activeMember ?? this.activeMember,
      pendingRequest: pendingRequest ?? this.pendingRequest,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.instance);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUserState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository(this._supabaseService);

  // In-memory mock store for dev fallback
  static String? _devMockPhone;
  static bool _devMockOtpSent = false;
  static MemberModel _mockActiveMember = MemberModel(
    memberId: '11111111-1111-1111-1111-111111111001',
    societyId: '00000000-0000-0000-0000-000000000001',
    authUid: 'aaaaaaa1-0000-0000-0000-000000000001',
    fullName: 'Rajeshbhai Patel',
    phoneNumber: '+919825000001',
    flatNumber: 'A-402',
    email: 'rajesh.patel@gmail.com',
    membershipStatus: 'ACTIVE',
    joinedAt: DateTime(2025, 1, 1),
  );

  /// Send Phone OTP
  Future<void> sendOtp(String phoneNumber) async {
    if (_supabaseService.isMockDevMode) {
      _devMockPhone = phoneNumber;
      _devMockOtpSent = true;
      debugPrint('[AuthRepository-Mock] OTP sent to $phoneNumber. Use code 123456');
      return;
    }

    await _supabaseService.client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  /// Verify Phone OTP
  Future<void> verifyOtp(String phoneNumber, String token) async {
    if (_supabaseService.isMockDevMode) {
      if (token == '123456') {
        _devMockPhone = phoneNumber;
        debugPrint('[AuthRepository-Mock] OTP Verified for $phoneNumber');
        return;
      } else {
        throw const AuthException('Invalid 6-digit OTP entered. For Dev Mode, use 123456');
      }
    }

    final response = await _supabaseService.client.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );

    if (response.user == null) {
      throw const AuthException('OTP verification failed: User session not returned.');
    }
  }

  /// Check Membership Status for authenticated user
  Future<AuthUserState> checkMembershipStatus(String phoneNumber) async {
    if (_supabaseService.isMockDevMode) {
      // In dev mode:
      if (phoneNumber.contains('9825000001')) {
        return AuthUserState(
          status: AuthStatus.activeMember,
          phoneNumber: phoneNumber,
          activeMember: _mockActiveMember,
        );
      } else if (phoneNumber.contains('9825000004')) {
        return AuthUserState(
          status: AuthStatus.pendingApproval,
          phoneNumber: phoneNumber,
          pendingRequest: RegistrationRequestModel(
            requestId: '88888888-8888-8888-8888-888888888001',
            societyId: '00000000-0000-0000-0000-000000000001',
            authUid: 'aaaaaaa4-0000-0000-0000-000000000004',
            fullName: 'Bhavikbhai Joshi',
            phoneNumber: phoneNumber,
            flatNumber: 'B-503',
            requestStatus: 'PENDING',
            submittedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        );
      } else {
        // Unregistered new phone
        return AuthUserState(
          status: AuthStatus.unregistered,
          phoneNumber: phoneNumber,
        );
      }
    }

    final authUid = _supabaseService.currentAuthUid;
    if (authUid == null) {
      return const AuthUserState(status: AuthStatus.unauthenticated);
    }

    // 1. Check if user is an active member
    final memberRes = await _supabaseService.client
        .from('members')
        .select()
        .eq('auth_uid', authUid)
        .maybeSingle();

    if (memberRes != null) {
      final member = MemberModel.fromJson(memberRes);
      if (member.isActive) {
        return AuthUserState(
          status: AuthStatus.activeMember,
          phoneNumber: phoneNumber,
          activeMember: member,
        );
      } else if (member.membershipStatus == 'SUSPENDED') {
        return AuthUserState(
          status: AuthStatus.rejected,
          phoneNumber: phoneNumber,
          errorMessage: 'Membership is currently suspended by society.',
        );
      }
    }

    // 2. Check if user has a pending or rejected registration request
    final reqRes = await _supabaseService.client
        .from('registration_requests')
        .select()
        .eq('auth_uid', authUid)
        .order('submitted_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (reqRes != null) {
      final req = RegistrationRequestModel.fromJson(reqRes);
      if (req.isPending) {
        return AuthUserState(
          status: AuthStatus.pendingApproval,
          phoneNumber: phoneNumber,
          pendingRequest: req,
        );
      } else if (req.isRejected) {
        return AuthUserState(
          status: AuthStatus.rejected,
          phoneNumber: phoneNumber,
          pendingRequest: req,
          errorMessage: req.rejectionReason ?? 'Registration request was rejected.',
        );
      }
    }

    // 3. User is verified by phone but has not submitted registration details
    return AuthUserState(
      status: AuthStatus.unregistered,
      phoneNumber: phoneNumber,
    );
  }

  Future<void> signOut() async {
    if (_supabaseService.isMockDevMode) {
      _devMockPhone = null;
      _devMockOtpSent = false;
      return;
    }
    await _supabaseService.client.auth.signOut();
  }
}

class AuthNotifier extends StateNotifier<AuthUserState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthUserState()) {
    _initCheck();
  }

  Future<void> _initCheck() async {
    try {
      // Auto-check existing session on app launch
      final currentPhone = SupabaseService.instance.currentUserPhone;
      if (currentPhone != null) {
        final stateRes = await _repo.checkMembershipStatus(currentPhone);
        state = stateRes;
      }
    } catch (_) {}
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(errorMessage: null);
    try {
      await _repo.sendOtp(phone);
      state = state.copyWith(status: AuthStatus.otpSent, phoneNumber: phone);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String token) async {
    if (state.phoneNumber == null) return;
    state = state.copyWith(errorMessage: null);
    try {
      await _repo.verifyOtp(state.phoneNumber!, token);
      final checkRes = await _repo.checkMembershipStatus(state.phoneNumber!);
      state = checkRes;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> refreshStatus() async {
    if (state.phoneNumber == null) return;
    try {
      final checkRes = await _repo.checkMembershipStatus(state.phoneNumber!);
      state = checkRes;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthUserState(status: AuthStatus.unauthenticated);
  }
}
