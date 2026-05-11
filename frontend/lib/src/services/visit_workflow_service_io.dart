import 'dart:convert';
import 'dart:io';

import '../models/carer_session.dart';
import '../models/visit_workflow.dart';
import 'visit_workflow_contract.dart';

class VisitWorkflowService implements VisitWorkflowPort {
  VisitWorkflowService({required String baseUrl, HttpClient? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<VisitWorkflow?> todayVisitForCarer(CarerSession session) async {
    final uri = _baseUri.replace(
      path: '/api/carer/today',
      queryParameters: {'carer_id': session.id.toString()},
    );
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseNullableVisit(statusCode: response.statusCode, body: body);
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
    final uri = _baseUri.replace(path: '/api/carer/visits/$visitId/notes');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(
      jsonEncode({
        'carer_id': session.id,
        'notes': notes,
        'recorded_at': DateTime.now().toIso8601String(),
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseVisit(statusCode: response.statusCode, body: body);
  }

  @override
  Future<VisitWorkflow> recordVisitTask({
    required CarerSession session,
    required int visitId,
    required VisitTaskRecord task,
  }) async {
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
  }) async {
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
  }) async {
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
    final uri = _baseUri.replace(
      path: '/api/carer/visits/$visitId/location-event',
    );
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(jsonEncode(event.toJson(carerId: session.id)));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseVisit(statusCode: response.statusCode, body: body);
  }

  @override
  Future<IssueReportReceipt> reportIssue({
    required CarerSession session,
    required IssueReport issue,
  }) async {
    final uri = _baseUri.replace(path: '/api/carer/issue-reports');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(jsonEncode(issue.toJson(carerId: session.id)));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseIssueReportReceipt(
      statusCode: response.statusCode,
      body: body,
    );
  }

  Future<VisitWorkflow> _postAction({
    required CarerSession session,
    required int visitId,
    required String action,
  }) async {
    final uri = _baseUri.replace(path: '/api/carer/visits/$visitId/$action');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(jsonEncode({'carer_id': session.id}));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseVisit(statusCode: response.statusCode, body: body);
  }

  Future<VisitWorkflow> _postVisitRecord({
    required int visitId,
    required String path,
    required Map<String, dynamic> payload,
  }) async {
    final uri = _baseUri.replace(path: '/api/carer/visits/$visitId/$path');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(jsonEncode(payload));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseVisit(statusCode: response.statusCode, body: body);
  }
}

IssueReportReceipt _parseIssueReportReceipt({
  required int statusCode,
  required String body,
}) {
  if (statusCode == HttpStatus.ok) {
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
  if (statusCode == HttpStatus.ok) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final visit = decoded['visit'] as Map<String, dynamic>?;

    return visit == null ? null : VisitWorkflow.fromJson(visit);
  }

  throw const VisitWorkflowException(
    'Today visit could not be loaded. Check the backend connection and try again.',
  );
}

VisitWorkflow _parseVisit({required int statusCode, required String body}) {
  if (statusCode == HttpStatus.ok) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;

    return VisitWorkflow.fromJson(decoded['visit'] as Map<String, dynamic>);
  }

  throw const VisitWorkflowException(
    'Visit action could not be saved. Check the backend connection and try again.',
  );
}
