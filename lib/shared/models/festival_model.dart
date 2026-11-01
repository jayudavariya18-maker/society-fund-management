class FestivalModel {
  final String festivalId;
  final String societyId;
  final String festivalName;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED'
  final String? coverImageUrl;
  final String createdBy;
  final DateTime createdAt;
  final double totalContributions;
  final double totalExpenses;
  final double remainingBalance;

  FestivalModel({
    required this.festivalId,
    required this.societyId,
    required this.festivalName,
    this.description,
    required this.startDate,
    required this.endDate,
    this.status = 'UPCOMING',
    this.coverImageUrl,
    required this.createdBy,
    required this.createdAt,
    this.totalContributions = 0.0,
    this.totalExpenses = 0.0,
    this.remainingBalance = 0.0,
  });

  factory FestivalModel.fromJson(Map<String, dynamic> json) {
    return FestivalModel(
      festivalId: json['festival_id'] as String,
      societyId: json['society_id'] as String,
      festivalName: json['festival_name'] as String? ?? 'Festival',
      description: json['description'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : DateTime.now(),
      status: json['status'] as String? ?? 'UPCOMING',
      coverImageUrl: json['cover_image_url'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      totalContributions: (json['total_contributions'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (json['remaining_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'festival_id': festivalId,
      'society_id': societyId,
      'festival_name': festivalName,
      'description': description,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'status': status,
      'cover_image_url': coverImageUrl,
      'created_by': createdBy,
    };
  }
}
