class RegistrationApprovalModel {
  final String approvalId;
  final String requestId;
  final String approvedBy;
  final String? approverName;
  final String decision; // 'APPROVED' or 'REJECTED'
  final String? comments;
  final DateTime decidedAt;

  RegistrationApprovalModel({
    required this.approvalId,
    required this.requestId,
    required this.approvedBy,
    this.approverName,
    required this.decision,
    this.comments,
    required this.decidedAt,
  });

  factory RegistrationApprovalModel.fromJson(Map<String, dynamic> json) {
    return RegistrationApprovalModel(
      approvalId: json['approval_id'] as String,
      requestId: json['request_id'] as String,
      approvedBy: json['approved_by'] as String,
      approverName: json['members'] != null ? json['members']['full_name'] as String? : null,
      decision: json['decision'] as String? ?? 'APPROVED',
      comments: json['comments'] as String?,
      decidedAt: json['decided_at'] != null
          ? DateTime.parse(json['decided_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approval_id': approvalId,
      'request_id': requestId,
      'approved_by': approvedBy,
      'decision': decision,
      'comments': comments,
      'decided_at': decidedAt.toIso8601String(),
    };
  }
}
