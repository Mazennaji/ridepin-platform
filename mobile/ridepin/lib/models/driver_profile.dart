class DriverProfile {
  final int id;
  final int userId;
  final String licenseNumber;
  final String vehicleType;
  final String vehicleModel;
  final String plateNumber;
  final bool isAvailable;
  final bool verificationStatus;

  DriverProfile({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.vehicleType,
    required this.vehicleModel,
    required this.plateNumber,
    required this.isAvailable,
    required this.verificationStatus,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      licenseNumber: json['license_number'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
      plateNumber: json['plate_number'] as String? ?? '',
      isAvailable: _toBool(json['is_available']),
      verificationStatus: _toBool(json['verification_status']),
    );
  }
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}
