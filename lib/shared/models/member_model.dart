class MemberModel {
  final String memberId;
  final String societyId;
  final String authUid;
  final String fullName;
  final String phoneNumber;
  final String flatNumber;
  final String? email;
  final String? profileImageUrl;
  final String membershipStatus; // 'ACTIVE', 'INACTIVE', 'SUSPENDED'
  final DateTime joinedAt;

  MemberModel({
    required this.memberId,
    required this.societyId,
    required this.authUid,
    required this.fullName,
    required this.phoneNumber,
    required this.flatNumber,
    this.email,
    this.profileImageUrl,
    this.membershipStatus = 'ACTIVE',
    required this.joinedAt,
  });

  bool get isActive => membershipStatus == 'ACTIVE';

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      memberId: json['member_id'] as String,
      societyId: json['society_id'] as String,
      authUid: json['auth_uid'] as String,
      fullName: json['full_name'] as String? ?? 'Resident',
      phoneNumber: json['phone_number'] as String? ?? '',
      flatNumber: json['flat_number'] as String? ?? '',
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      membershipStatus: json['membership_status'] as String? ?? 'ACTIVE',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'society_id': societyId,
      'auth_uid': authUid,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'flat_number': flatNumber,
      'email': email,
      'profile_image_url': profileImageUrl,
      'membership_status': membershipStatus,
    };
  }
}
