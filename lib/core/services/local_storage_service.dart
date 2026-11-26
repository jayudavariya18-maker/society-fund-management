import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/announcement_model.dart';
import '../../shared/models/contribution_model.dart';
import '../../shared/models/expense_model.dart';
import '../../shared/models/festival_event_model.dart';
import '../../shared/models/festival_model.dart';
import '../../shared/models/fund_model.dart';
import '../../shared/models/member_model.dart';
import '../../shared/models/registration_request_model.dart';

/// Central Persistent Storage Service
/// Ensures all society financial data, records, and member sessions
/// survive application restarts, device reboots, and network disconnects.
class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();

  LocalStorageService._();

  SharedPreferences? _prefs;

  // Salt for hashing common society password
  static const String passwordSalt = 'ramseva_salt_ramdevra_2026';
  // SHA-256 hash of 'ramseva_salt_ramdevra_2026Ramdevra@2026'
  static const String defaultPasswordHash = '89377b5825c22ad3f3e720211e35cccd7970904f60267f1708c3bd2eb8b770fb';

  // Storage Keys
  static const String _keyActiveMember = 'ramseva_active_member_session';
  static const String _keyPasswordHash = 'ramseva_society_password_hash';
  static const String _keyFunds = 'ramseva_storage_funds';
  static const String _keyContributions = 'ramseva_storage_contributions';
  static const String _keyExpenses = 'ramseva_storage_expenses';
  static const String _keyFestivals = 'ramseva_storage_festivals';
  static const String _keyEvents = 'ramseva_storage_festival_events';
  static const String _keyAnnouncements = 'ramseva_storage_announcements';
  static const String _keyMembers = 'ramseva_storage_members';
  static const String _keyRequests = 'ramseva_storage_registration_requests';

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    debugPrint('[LocalStorageService] Initialized persistent disk storage.');
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('LocalStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // ====================================================================
  // 1. SOCIETY COMMON PASSWORD VERIFICATION
  // ====================================================================

  /// Compute salted SHA-256 hash for a given plaintext password
  static String hashPassword(String password) {
    final bytes = utf8.encode(passwordSalt + password.trim());
    return sha256.convert(bytes).toString();
  }

  /// Verify entered society password against stored or default hash
  bool verifySocietyPassword(String password) {
    final enteredHash = hashPassword(password);
    final storedHash = prefs.getString(_keyPasswordHash) ?? defaultPasswordHash;
    return enteredHash.toLowerCase() == storedHash.toLowerCase();
  }

  /// Update stored society password hash (e.g. from backend sync)
  Future<void> updateSocietyPasswordHash(String hash) async {
    await prefs.setString(_keyPasswordHash, hash);
  }

  // ====================================================================
  // 2. MEMBER AUTHENTICATION SESSION PERSISTENCE
  // ====================================================================

  /// Save authenticated member profile to permanent disk storage
  Future<void> saveActiveMember(MemberModel member) async {
    final jsonStr = jsonEncode(member.toJson());
    await prefs.setString(_keyActiveMember, jsonStr);
    debugPrint('[LocalStorageService] Saved active member session: ${member.fullName} (${member.flatNumber})');
  }

  /// Load authenticated member profile from disk
  MemberModel? getActiveMember() {
    try {
      final jsonStr = prefs.getString(_keyActiveMember);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return MemberModel.fromJson(map);
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading active member: $e');
      return null;
    }
  }

  /// Check whether an active member is registered on this device
  bool isMemberRegistered() {
    return getActiveMember() != null;
  }

  /// Clear active session on explicit sign out
  Future<void> clearSession() async {
    await prefs.remove(_keyActiveMember);
    debugPrint('[LocalStorageService] Active member session cleared.');
  }

  // ====================================================================
  // 3. FUNDS PERSISTENCE
  // ====================================================================

  Future<void> saveFunds(List<FundModel> funds) async {
    final list = funds.map((f) => f.toJson()).toList();
    await prefs.setString(_keyFunds, jsonEncode(list));
  }

  List<FundModel> loadFunds() {
    try {
      final jsonStr = prefs.getString(_keyFunds);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => FundModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading funds: $e');
      return [];
    }
  }

  // ====================================================================
  // 4. CONTRIBUTIONS PERSISTENCE
  // ====================================================================

  Future<void> saveContributions(List<ContributionModel> items) async {
    final list = items.map((c) => c.toJson()).toList();
    await prefs.setString(_keyContributions, jsonEncode(list));
  }

  List<ContributionModel> loadContributions() {
    try {
      final jsonStr = prefs.getString(_keyContributions);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => ContributionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading contributions: $e');
      return [];
    }
  }

  // ====================================================================
  // 5. EXPENSES PERSISTENCE
  // ====================================================================

  Future<void> saveExpenses(List<ExpenseModel> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyExpenses, jsonEncode(list));
  }

  List<ExpenseModel> loadExpenses() {
    try {
      final jsonStr = prefs.getString(_keyExpenses);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading expenses: $e');
      return [];
    }
  }

  // ====================================================================
  // 6. FESTIVALS & EVENTS PERSISTENCE
  // ====================================================================

  Future<void> saveFestivals(List<FestivalModel> items) async {
    final list = items.map((f) => f.toJson()).toList();
    await prefs.setString(_keyFestivals, jsonEncode(list));
  }

  List<FestivalModel> loadFestivals() {
    try {
      final jsonStr = prefs.getString(_keyFestivals);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => FestivalModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading festivals: $e');
      return [];
    }
  }

  Future<void> saveFestivalEvents(List<FestivalEventModel> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyEvents, jsonEncode(list));
  }

  List<FestivalEventModel> loadFestivalEvents() {
    try {
      final jsonStr = prefs.getString(_keyEvents);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => FestivalEventModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading festival events: $e');
      return [];
    }
  }

  // ====================================================================
  // 7. ANNOUNCEMENTS PERSISTENCE
  // ====================================================================

  Future<void> saveAnnouncements(List<AnnouncementModel> items) async {
    final list = items.map((a) => a.toJson()).toList();
    await prefs.setString(_keyAnnouncements, jsonEncode(list));
  }

  List<AnnouncementModel> loadAnnouncements() {
    try {
      final jsonStr = prefs.getString(_keyAnnouncements);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading announcements: $e');
      return [];
    }
  }

  // ====================================================================
  // 8. MEMBERS & REGISTRATIONS PERSISTENCE
  // ====================================================================

  Future<void> saveMembers(List<MemberModel> items) async {
    final list = items.map((m) => m.toJson()).toList();
    await prefs.setString(_keyMembers, jsonEncode(list));
  }

  List<MemberModel> loadMembers() {
    try {
      final jsonStr = prefs.getString(_keyMembers);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => MemberModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading members: $e');
      return [];
    }
  }

  Future<void> saveRegistrationRequests(List<RegistrationRequestModel> items) async {
    final list = items.map((r) => r.toJson()).toList();
    await prefs.setString(_keyRequests, jsonEncode(list));
  }

  List<RegistrationRequestModel> loadRegistrationRequests() {
    try {
      final jsonStr = prefs.getString(_keyRequests);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => RegistrationRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[LocalStorageService] Error loading registration requests: $e');
      return [];
    }
  }
}
