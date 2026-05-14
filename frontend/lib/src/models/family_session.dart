class FamilySession {
  const FamilySession({
    required this.id,
    required this.name,
    required this.email,
    required this.clientId,
    required this.clientName,
    required this.permissions,
    this.relationship,
    this.homeName,
  });

  final int id;
  final String name;
  final String email;
  final int clientId;
  final String clientName;
  final String? relationship;
  final String? homeName;
  final FamilyAccessPermissions permissions;

  factory FamilySession.fromJson(Map<String, dynamic> json) {
    final member = json['family_member'] as Map<String, dynamic>? ?? json;
    final client = member['client'] as Map<String, dynamic>;

    return FamilySession(
      id: (member['id'] as num).toInt(),
      name: member['name'] as String,
      email: member['email'] as String,
      relationship: member['relationship'] as String?,
      clientId: (client['id'] as num).toInt(),
      clientName: client['name'] as String,
      homeName: client['home_name'] as String?,
      permissions: FamilyAccessPermissions.fromJson(
        member['permissions'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class FamilyAccessPermissions {
  const FamilyAccessPermissions({
    required this.canViewCareUpdates,
    required this.canViewMedication,
    required this.canViewInvoices,
    required this.canReceiveIncidentAlerts,
    required this.canViewAppointments,
    required this.canViewVisits,
    required this.canUploadDocuments,
    required this.canViewStaffMessages,
    required this.canViewSharedDocuments,
    required this.canViewSensitiveDocuments,
    required this.canViewSafeguarding,
  });

  final bool canViewCareUpdates;
  final bool canViewMedication;
  final bool canViewInvoices;
  final bool canReceiveIncidentAlerts;
  final bool canViewAppointments;
  final bool canViewVisits;
  final bool canUploadDocuments;
  final bool canViewStaffMessages;
  final bool canViewSharedDocuments;
  final bool canViewSensitiveDocuments;
  final bool canViewSafeguarding;

  factory FamilyAccessPermissions.fromJson(Map<String, dynamic> json) {
    return FamilyAccessPermissions(
      canViewCareUpdates: json['can_view_care_updates'] == true,
      canViewMedication: json['can_view_medication'] == true,
      canViewInvoices: json['can_view_invoices'] == true,
      canReceiveIncidentAlerts: json['can_receive_incident_alerts'] == true,
      canViewAppointments: json['can_view_appointments'] == true,
      canViewVisits: json['can_view_visits'] == true,
      canUploadDocuments: json['can_upload_documents'] == true,
      canViewStaffMessages: json['can_view_staff_messages'] == true,
      canViewSharedDocuments: json['can_view_shared_documents'] == true,
      canViewSensitiveDocuments: json['can_view_sensitive_documents'] == true,
      canViewSafeguarding: json['can_view_safeguarding'] == true,
    );
  }
}
