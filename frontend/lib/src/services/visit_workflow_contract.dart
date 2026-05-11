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
    this.reportedAt,
  });

  final String category;
  final String severity;
  final String notes;
  final DateTime? reportedAt;

  Map<String, dynamic> toJson({required int carerId}) {
    return {
      'carer_id': carerId,
      'category': category,
      'severity': severity,
      'notes': notes,
      if (reportedAt != null) 'reported_at': reportedAt!.toIso8601String(),
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
