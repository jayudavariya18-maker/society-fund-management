class FestivalEventModel {
  final String eventId;
  final String festivalId;
  final String eventName;
  final String? description;
  final DateTime eventDate;
  final String? eventLocation;
  final double estimatedBudget;
  final String createdBy;
  final DateTime createdAt;

  FestivalEventModel({
    required this.eventId,
    required this.festivalId,
    required this.eventName,
    this.description,
    required this.eventDate,
    this.eventLocation,
    this.estimatedBudget = 0.0,
    required this.createdBy,
    required this.createdAt,
  });

  factory FestivalEventModel.fromJson(Map<String, dynamic> json) {
    return FestivalEventModel(
      eventId: json['event_id'] as String,
      festivalId: json['festival_id'] as String,
      eventName: json['event_name'] as String? ?? 'Event',
      description: json['description'] as String?,
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'].toString())
          : DateTime.now(),
      eventLocation: json['event_location'] as String?,
      estimatedBudget: (json['estimated_budget'] as num?)?.toDouble() ?? 0.0,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'festival_id': festivalId,
      'event_name': eventName,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T').first,
      'event_location': eventLocation,
      'estimated_budget': estimatedBudget,
      'created_by': createdBy,
    };
  }
}
