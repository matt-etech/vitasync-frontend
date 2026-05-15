class FamilyPortalSummary {
  const FamilyPortalSummary({
    required this.client,
    required this.permissions,
    required this.visitNotesSummary,
    required this.upcomingVisits,
    required this.pastVisits,
    required this.incidentNotifications,
    required this.appointments,
    required this.medicationRecords,
    this.carePlanSummary,
    this.medicationSummary,
    this.invoices,
    this.messages,
    this.documents,
  });

  final FamilyClientProfile client;
  final Map<String, dynamic> permissions;
  final Map<String, dynamic>? carePlanSummary;
  final List<Map<String, dynamic>> upcomingVisits;
  final List<Map<String, dynamic>> pastVisits;
  final List<Map<String, dynamic>> visitNotesSummary;
  final Map<String, dynamic>? medicationSummary;
  final List<Map<String, dynamic>> medicationRecords;
  final List<Map<String, dynamic>> incidentNotifications;
  final List<Map<String, dynamic>> appointments;
  final List<dynamic>? invoices;
  final List<dynamic>? messages;
  final List<dynamic>? documents;

  factory FamilyPortalSummary.fromJson(Map<String, dynamic> json) {
    return FamilyPortalSummary(
      client: FamilyClientProfile.fromJson(
        json['client'] as Map<String, dynamic>,
      ),
      permissions: json['permissions'] as Map<String, dynamic>? ?? const {},
      carePlanSummary: json['care_plan_summary'] as Map<String, dynamic>?,
      upcomingVisits: _mapList(json['upcoming_visits']),
      pastVisits: _mapList(json['past_visits']),
      visitNotesSummary: _mapList(json['visit_notes_summary']),
      medicationSummary: json['medication_summary'] as Map<String, dynamic>?,
      medicationRecords: _mapList(json['medication_records']),
      incidentNotifications: _mapList(json['incident_notifications']),
      appointments: _mapList(json['appointments']),
      invoices: json['invoices'] as List<dynamic>?,
      messages: json['messages'] as List<dynamic>?,
      documents: json['documents'] as List<dynamic>?,
    );
  }
}

class FamilyClientProfile {
  const FamilyClientProfile({
    required this.id,
    required this.name,
    required this.status,
    this.homeName,
  });

  final int id;
  final String name;
  final String status;
  final String? homeName;

  factory FamilyClientProfile.fromJson(Map<String, dynamic> json) {
    return FamilyClientProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      status: json['status'] as String,
      homeName: json['home_name'] as String?,
    );
  }
}

List<Map<String, dynamic>> _mapList(Object? value) {
  final rows = value as List<dynamic>? ?? const [];

  return [for (final row in rows) row as Map<String, dynamic>];
}
