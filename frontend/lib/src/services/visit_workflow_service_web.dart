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
