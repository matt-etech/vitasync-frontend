// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/carer_session.dart';
import '../models/visit_workflow.dart';
import 'visit_workflow_contract.dart';

class VisitWorkflowService implements VisitWorkflowPort {
  VisitWorkflowService({required String baseUrl})
    : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;

  @override
  Future<VisitWorkflow?> todayVisitForCarer(CarerSession session) async {
    final request = await html.HttpRequest.request(
      _baseUri
          .replace(
            path: '/api/carer/today',
            queryParameters: {'carer_id': session.id.toString()},
          )
          .toString(),
      method: 'GET',
      requestHeaders: const {'Accept': 'application/json'},
    );

    return _parseNullableVisit(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }

  @override
  Future<VisitWorkflow> checkIn({
    required CarerSession session,
    required int visitId,
  }) {
    return _postAction(session: session, visitId: visitId, action: 'check-in');
  }

  @override
  Future<VisitWorkflow> checkOut({
    required CarerSession session,
    required int visitId,
  }) {
    return _postAction(session: session, visitId: visitId, action: 'check-out');
  }

  @override
  Future<VisitWorkflow> recordVisitNotes({
    required CarerSession session,
    required int visitId,
    required String notes,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.replace(path: '/api/carer/visits/$visitId/notes').toString(),
      method: 'POST',
      requestHeaders: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      sendData: jsonEncode({
        'carer_id': session.id,
        'notes': notes,
        'recorded_at': DateTime.now().toIso8601String(),
      }),
    );

    return _parseVisit(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }

  @override
  Future<VisitWorkflow> recordVisitTask({
    required CarerSession session,
    required int visitId,
    required VisitTaskRecord task,
  }) {
    return _postVisitRecord(
      visitId: visitId,
      path: 'tasks',
      payload: task.toJson(carerId: session.id),
    );
  }

  @override
  Future<VisitWorkflow> recordVisitVitals({
    required CarerSession session,
    required int visitId,
    required VisitVitalsRecord vitals,
  }) {
    return _postVisitRecord(
      visitId: visitId,
      path: 'vitals',
      payload: vitals.toJson(carerId: session.id),
    );
  }

  @override
  Future<VisitWorkflow> recordVisitEvidence({
    required CarerSession session,
    required int visitId,
    required VisitEvidenceRecord evidence,
  }) {
    return _postVisitRecord(
      visitId: visitId,
      path: 'evidence',
      payload: evidence.toJson(carerId: session.id),
    );
  }

  @override
  Future<VisitWorkflow> recordLocationEvent({
    required CarerSession session,
    required int visitId,
    required VisitLocationEvent event,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri
          .replace(path: '/api/carer/visits/$visitId/location-event')
          .toString(),
      method: 'POST',
      requestHeaders: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      sendData: jsonEncode(event.toJson(carerId: session.id)),
    );

    return _parseVisit(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }

  @override
  Future<IssueReportReceipt> reportIssue({
    required CarerSession session,
    required IssueReport issue,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.replace(path: '/api/carer/issue-reports').toString(),
      method: 'POST',
      requestHeaders: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      sendData: jsonEncode(issue.toJson(carerId: session.id)),
    );

    return _parseIssueReportReceipt(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }

  Future<VisitWorkflow> _postAction({
    required CarerSession session,
    required int visitId,
    required String action,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.replace(path: '/api/carer/visits/$visitId/$action').toString(),
      method: 'POST',
      requestHeaders: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      sendData: jsonEncode({'carer_id': session.id}),
    );

    return _parseVisit(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }

  Future<VisitWorkflow> _postVisitRecord({
    required int visitId,
    required String path,
    required Map<String, dynamic> payload,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.replace(path: '/api/carer/visits/$visitId/$path').toString(),
      method: 'POST',
      requestHeaders: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      sendData: jsonEncode(payload),
    );

    return _parseVisit(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }
}

IssueReportReceipt _parseIssueReportReceipt({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
    return IssueReportReceipt.fromJson(
      jsonDecode(body) as Map<String, dynamic>,
    );
  }

  throw const VisitWorkflowException(
    'Issue report could not be sent. It remains queued for follow-up.',
  );
}

VisitWorkflow? _parseNullableVisit({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final visit = decoded['visit'] as Map<String, dynamic>?;

    return visit == null ? null : VisitWorkflow.fromJson(visit);
  }

  throw const VisitWorkflowException(
    'Today visit could not be loaded. Check the backend connection and try again.',
  );
}

VisitWorkflow _parseVisit({required int statusCode, required String body}) {
  if (statusCode == 200) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;

    return VisitWorkflow.fromJson(decoded['visit'] as Map<String, dynamic>);
  }

  throw const VisitWorkflowException(
    'Visit action could not be saved. Check the backend connection and try again.',
  );
}
