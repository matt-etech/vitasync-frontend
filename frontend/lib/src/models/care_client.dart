class CareClient {
  const CareClient({
    required this.id,
    required this.name,
    required this.status,
    this.address,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.geofenceRadiusMeters,
    this.homeName,
    this.onboardingStatus,
  });

  final int id;
  final String name;
  final String status;
  final String? address;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final int? geofenceRadiusMeters;
  final String? homeName;
  final String? onboardingStatus;

  factory CareClient.fromJson(Map<String, dynamic> json) {
    return CareClient(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      status: json['status'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geofenceRadiusMeters: (json['geofence_radius_meters'] as num?)?.toInt(),
      homeName: json['home_name'] as String?,
      onboardingStatus: json['onboarding_status'] as String?,
    );
  }
}
