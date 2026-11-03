import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/member_model.dart';
import '../../../shared/models/registration_request_model.dart';
import '../../members/data/members_repository.dart';
import '../../registration/data/registration_repository.dart';

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

  // In-memory store for fallback (Zero hardcoded members)
  static String? _devMockPhone;
  static bool _devMockOtpSent = false;

  /// Check whether any active members already exist in the society
  Future<bool> hasActiveMembers() async {
    if (_supabaseService.isMockDevMode) {
      return MembersRepository.mockMembers.isNotEmpty;
    }
    try {
      final res = await _supabaseService.client
          .from('members')
          .select('member_id')
          .eq('membership_status', 'ACTIVE')
          .limit(1);
      return (res as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Bootstrap the founding first member of Ramdevra Society
  Future<MemberModel> bootstrapFirstMember({
    required String fullName,
    required String flatNumber,
    String? email,
  }) async {
    final phone = _devMockPhone ?? _supabaseService.currentUserPhone ?? '+919876543210';
    final authUid = _supabaseService.currentAuthUid ?? 'bootstrap-${DateTime.now().millisecondsSinceEpoch}';

    if (_supabaseService.isMockDevMode) {
      final member = MemberModel(
        memberId: 'mem-${DateTime.now().millisecondsSinceEpoch}',
        societyId: '00000000-0000-0000-0000-000000000001',
        authUid: authUid,
        fullName: fullName,
        phoneNumber: phone,
        flatNumber: flatNumber,
        email: email,
        membershipStatus: 'ACTIVE',
        joinedAt: DateTime.now(),
      );
      MembersRepository.addMockMember(member);
      return member;
    }

    try {
      final res = await _supabaseService.client.rpc('bootstrap_first_society_member', params: {
        'p_full_name': fullName,
        'p_flat_number': flatNumber,
        'p_email': email,
      });
      return MemberModel.fromJson(res as Map<String, dynamic>);
    } on PostgrestException {
      // Direct insertion fallback if stored function isn't applied yet
      final memberRes = await _supabaseService.client.from('members').insert({
        'society_id': '00000000-0000-0000-0000-000000000001',
        'auth_uid': authUid,
        'full_name': fullName,
        'phone_number': phone,
        'flat_number': flatNumber,
        'email': email,
        'membership_status': 'ACTIVE',
      }).select().single();
      return MemberModel.fromJson(memberRes);
    }
  }

  /// Send Phone OTP
  Future<void> sendOtp(String phoneNumber) async {
    if (_supabaseService.isMockDevMode) {
      _devMockPhone = phoneNumber;
      _devMockOtpSent = true;
      debugPrint('[AuthRepository] Running in local evaluation mode. OTP for $phoneNumber is 123456');
      return;
    }

    try {
      await _supabaseService.client.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('sms') || msg.contains('provider') || msg.contains('unsupported') || msg.contains('twilio') || e.statusCode == '400') {
        throw AuthException(
          'SMS Provider is not configured in your Supabase project.\n\n'
          'To receive production OTPs, configure an SMS Provider (Twilio/MessageBird/Textlocal) in Supabase Dashboard -> Authentication -> Providers -> Phone.\n\n'
          'For test phone numbers without SMS charges, add them under Phone Provider -> Test Phone Numbers in Supabase console.',
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  /// Verify Phone OTP
  Future<void> verifyOtp(String phoneNumber, String token) async {
    if (_supabaseService.isMockDevMode) {
      if (!_devMockOtpSent) {
        throw const AuthException('Please request an OTP first.');
      }
      if (token == '123456') {
        _devMockPhone = phoneNumber;
        _devMockOtpSent = false;
        debugPrint('[AuthRepository] OTP Verified for $phoneNumber');
        return;
      } else {
        throw const AuthException('Invalid 6-digit OTP code entered. In local test mode, use 123456.');
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
      // Check if this phone belongs to an active member in memory
      final active = MembersRepository.mockMembers.where((m) => m.phoneNumber == phoneNumber).firstOrNull;
      if (active != null) {
        return AuthUserState(
          status: AuthStatus.activeMember,
          phoneNumber: phoneNumber,
          activeMember: active,
        );
      }

      // Check if there is a pending request
      final pending = RegistrationRepository.mockRequests.where((r) => r.phoneNumber == phoneNumber).firstOrNull;
      if (pending != null) {
        if (pending.isPending) {
          return AuthUserState(
            status: AuthStatus.pendingApproval,
            phoneNumber: phoneNumber,
            pendingRequest: pending,
          );
        } else if (pending.isRejected) {
          return AuthUserState(
            status: AuthStatus.rejected,
            phoneNumber: phoneNumber,
            pendingRequest: pending,
            errorMessage: pending.rejectionReason ?? 'Registration request was rejected.',
          );
        }
      }

      // Unregistered new phone
      return AuthUserState(
        status: AuthStatus.unregistered,
        phoneNumber: phoneNumber,
      );
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

  Future<void> completeFirstMemberBootstrap({
    required String fullName,
    required String flatNumber,
    String? email,
  }) async {
    state = state.copyWith(errorMessage: null);
    try {
      final member = await _repo.bootstrapFirstMember(
        fullName: fullName,
        flatNumber: flatNumber,
        email: email,
      );
      state = state.copyWith(
        status: AuthStatus.activeMember,
        activeMember: member,
        pendingRequest: null,
      );
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
