class SocietyModel {
  final String societyId;
  final String societyName;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String contactNumber;
  final String? email;
  final DateTime createdAt;

  SocietyModel({
    required this.societyId,
    required this.societyName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactNumber,
    this.email,
    required this.createdAt,
  });

  factory SocietyModel.fromJson(Map<String, dynamic> json) {
    return SocietyModel(
      societyId: json['society_id'] as String,
      societyName: json['society_name'] as String? ?? 'Ramdevra Society',
      address: json['address'] as String? ?? 'Ramdevra Society, Main Road',
      city: json['city'] as String? ?? 'Ahmedabad',
      state: json['state'] as String? ?? 'Gujarat',
      pincode: json['pincode'] as String? ?? '380015',
      contactNumber: json['contact_number'] as String? ?? '',
      email: json['email'] as String? ?? 'ramdevra.society@gmail.com',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'society_id': societyId,
      'society_name': societyName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contact_number': contactNumber,
      'email': email,
    };
  }
}
