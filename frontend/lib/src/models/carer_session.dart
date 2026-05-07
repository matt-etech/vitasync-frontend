class CarerSession {
  const CarerSession({
    required this.id,
    required this.name,
    required this.email,
    this.homeId,
    this.jobTitle,
    this.homeName,
    this.profileStatus,
    this.accountStatus,
  });

  final int id;
  final String name;
  final String email;
  final int? homeId;
  final String? jobTitle;
  final String? homeName;
  final String? profileStatus;
  final String? accountStatus;

  factory CarerSession.fromJson(Map<String, dynamic> json) {
    final carer = json['carer'] as Map<String, dynamic>? ?? json;
    final home = carer['home'] as Map<String, dynamic>?;
    final profile = carer['profile'] as Map<String, dynamic>?;

    return CarerSession(
      id: (carer['id'] as num).toInt(),
      name: carer['name'] as String,
      email: carer['email'] as String,
      homeId: (home?['id'] as num?)?.toInt(),
      jobTitle: carer['job_title'] as String?,
      homeName: home?['name'] as String?,
      profileStatus: profile?['status'] as String?,
      accountStatus: profile?['account_status'] as String?,
    );
  }
}
