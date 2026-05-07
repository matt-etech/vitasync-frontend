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
