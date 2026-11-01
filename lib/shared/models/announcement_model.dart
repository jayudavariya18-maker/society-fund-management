class AnnouncementModel {
  final String announcementId;
  final String societyId;
  final String title;
  final String message;
  final String? attachmentUrl;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;

  AnnouncementModel({
    required this.announcementId,
    required this.societyId,
    required this.title,
    required this.message,
    this.attachmentUrl,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcementId: json['announcement_id'] as String,
      societyId: json['society_id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdByName: json['creator'] != null ? json['creator']['full_name'] as String? : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcement_id': announcementId,
      'society_id': societyId,
      'title': title,
      'message': message,
      'attachment_url': attachmentUrl,
      'created_by': createdBy,
    };
  }
}
