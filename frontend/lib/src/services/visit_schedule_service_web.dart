// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/carer_session.dart';
import '../models/scheduled_visit.dart';
import 'visit_schedule_contract.dart';

class VisitScheduleService implements VisitSchedulePort {
  VisitScheduleService({required String baseUrl})
    : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;

  @override
  Future<List<ScheduledVisit>> visitsForCarer(CarerSession session) async {
    final request = await html.HttpRequest.request(
      _baseUri
          .replace(
            path: '/api/carer/visits',
            queryParameters: {'carer_id': session.id.toString()},
          )
          .toString(),
      method: 'GET',
      requestHeaders: const {'Accept': 'application/json'},
    );

    return _parseVisitsResponse(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }
}

List<ScheduledVisit> _parseVisitsResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final visits = decoded['visits'] as List<dynamic>? ?? const [];

    return [
      for (final visit in visits)
        ScheduledVisit.fromJson(visit as Map<String, dynamic>),
    ];
  }

  throw const VisitScheduleException(
    'Visits could not be loaded. Check the backend connection and try again.',
  );
}
