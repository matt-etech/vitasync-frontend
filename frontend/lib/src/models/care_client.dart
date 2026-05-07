class CareClient {
  const CareClient({
    required this.id,
    required this.name,
    required this.status,
    this.address,
    this.phone,
    this.email,
    this.homeName,
    this.onboardingStatus,
  });

  final int id;
  final String name;
  final String status;
  final String? address;
  final String? phone;
  final String? email;
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
      homeName: json['home_name'] as String?,
      onboardingStatus: json['onboarding_status'] as String?,
    );
  }
}
