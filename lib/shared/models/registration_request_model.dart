class RegistrationRequestModel {
  final String requestId;
  final String societyId;
  final String authUid;
  final String fullName;
  final String phoneNumber;
  final String flatNumber;
  final String? additionalInformation;
  final String requestStatus; // 'PENDING', 'APPROVED', 'REJECTED'
  final DateTime submittedAt;
  final String? reviewedBy;
  final String? reviewerName;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  RegistrationRequestModel({
    required this.requestId,
    required this.societyId,
    required this.authUid,
    required this.fullName,
    required this.phoneNumber,
    required this.flatNumber,
    this.additionalInformation,
    this.requestStatus = 'PENDING',
    required this.submittedAt,
    this.reviewedBy,
    this.reviewerName,
    this.reviewedAt,
    this.rejectionReason,
  });

  bool get isPending => requestStatus == 'PENDING';
  bool get isApproved => requestStatus == 'APPROVED';
  bool get isRejected => requestStatus == 'REJECTED';

  factory RegistrationRequestModel.fromJson(Map<String, dynamic> json) {
    return RegistrationRequestModel(
      requestId: json['request_id'] as String,
      societyId: json['society_id'] as String,
      authUid: json['auth_uid'] as String,
      fullName: json['full_name'] as String? ?? 'Applicant',
      phoneNumber: json['phone_number'] as String? ?? '',
      flatNumber: json['flat_number'] as String? ?? '',
      additionalInformation: json['additional_information'] as String?,
      requestStatus: json['request_status'] as String? ?? 'PENDING',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'].toString())
          : DateTime.now(),
      reviewedBy: json['reviewed_by'] as String?,
      reviewerName: json['reviewer'] != null ? json['reviewer']['full_name'] as String? : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'].toString())
          : null,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'society_id': societyId,
      'auth_uid': authUid,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'flat_number': flatNumber,
      'additional_information': additionalInformation,
      'request_status': requestStatus,
    };
  }
}
