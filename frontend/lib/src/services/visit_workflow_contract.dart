import '../models/carer_session.dart';
import '../models/visit_workflow.dart';

abstract class VisitWorkflowPort {
  Future<VisitWorkflow?> todayVisitForCarer(CarerSession session);

  Future<VisitWorkflow> checkIn({
    required CarerSession session,
    required int visitId,
  });

  Future<VisitWorkflow> checkOut({
    required CarerSession session,
    required int visitId,
  });

  Future<VisitWorkflow> recordVisitNotes({
    required CarerSession session,
    required int visitId,
    required String notes,
  });

  Future<VisitWorkflow> recordVisitTask({
    required CarerSession session,
    required int visitId,
    required VisitTaskRecord task,
  });

  Future<VisitWorkflow> recordVisitVitals({
    required CarerSession session,
    required int visitId,
    required VisitVitalsRecord vitals,
  });

  Future<VisitWorkflow> recordVisitEvidence({
    required CarerSession session,
    required int visitId,
    required VisitEvidenceRecord evidence,
  });

  Future<VisitWorkflow> recordLocationEvent({
    required CarerSession session,
    required int visitId,
    required VisitLocationEvent event,
  });

  Future<IssueReportReceipt> reportIssue({
    required CarerSession session,
    required IssueReport issue,
  });
}

class VisitLocationEvent {
  const VisitLocationEvent({
    required this.type,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.distanceMeters,
    this.geofenceRadiusMeters,
    this.recordedAt,
  });

  final String type;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? distanceMeters;
  final int? geofenceRadiusMeters;
  final DateTime? recordedAt;

  Map<String, dynamic> toJson({required int carerId}) {
    return {
      'carer_id': carerId,
      'event_type': type,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (geofenceRadiusMeters != null)
        'geofence_radius_meters': geofenceRadiusMeters,
      if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
    };
  }
}

class IssueReport {
  const IssueReport({
    required this.category,
    required this.severity,
    required this.notes,
    this.visitId,
    this.reportedAt,
  });

  final String category;
  final String severity;
  final String notes;
  final int? visitId;
  final DateTime? reportedAt;

  IssueReport withVisitId(int? visitId) {
    return IssueReport(
      category: category,
      severity: severity,
      notes: notes,
      visitId: visitId,
      reportedAt: reportedAt,
    );
  }

  Map<String, dynamic> toJson({required int carerId}) {
    return {
      'carer_id': carerId,
      if (visitId != null) 'visit_id': visitId,
      'category': category,
      'severity': severity,
      'notes': notes,
      if (reportedAt != null) 'reported_at': reportedAt!.toIso8601String(),
    };
  }
}

class VisitTaskRecord {
  const VisitTaskRecord({
    required this.taskKey,
    required this.title,
    required this.status,
    this.detail,
    this.completedAt,
  });

  final String taskKey;
  final String title;
  final String? detail;
  final String status;
  final DateTime? completedAt;

  Map<String, dynamic> toJson({required int carerId}) {
    return {
      'carer_id': carerId,
      'task_key': taskKey,
      'title': title,
      if (detail != null && detail!.trim().isNotEmpty) 'detail': detail,
      'status': status,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }
}

class VisitVitalsRecord {
  const VisitVitalsRecord({
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.pulse,
    required this.temperature,
    required this.bloodOxygen,
    this.recordedAt,
  });

  final int bpSystolic;
  final int bpDiastolic;
  final int pulse;
  final double temperature;
  final int bloodOxygen;
  final DateTime? recordedAt;

  Map<String, dynamic> toJson({required int carerId}) {
    return {
      'carer_id': carerId,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'pulse': pulse,
      'temperature': temperature,
      'blood_oxygen': bloodOxygen,
      if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
    };
  }
}

class VisitEvidenceRecord {
  const VisitEvidenceRecord({
    required this.evidenceType,
    required this.label,
    this.fileName,
    this.metadata = const <String, dynamic>{},
    this.capturedAt,
  });

  final String evidenceType;
  final String label;
  final String? fileName;
  final Map<String, dynamic> metadata;
  final DateTime? capturedAt;

  Map<String, dynamic> toJson({required int carerId}) {
    return {
      'carer_id': carerId,
      'evidence_type': evidenceType,
      'label': label,
      if (fileName != null && fileName!.trim().isNotEmpty)
        'file_name': fileName,
      if (metadata.isNotEmpty) 'metadata': metadata,
      if (capturedAt != null) 'captured_at': capturedAt!.toIso8601String(),
    };
  }
}

class IssueReportReceipt {
  const IssueReportReceipt({
    required this.status,
    required this.syncStatus,
    required this.reportedAt,
  });

  final String status;
  final String syncStatus;
  final String reportedAt;

  factory IssueReportReceipt.fromJson(Map<String, dynamic> json) {
    return IssueReportReceipt(
      status: json['status'] as String,
      syncStatus: json['sync_status'] as String,
      reportedAt: json['reported_at'] as String,
    );
  }
}

class VisitWorkflowException implements Exception {
  const VisitWorkflowException(this.message);

  final String message;

  @override
  String toString() => message;
}
