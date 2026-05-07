import 'dart:convert';
import 'dart:io';

import '../models/carer_session.dart';
import '../models/scheduled_visit.dart';
import 'visit_schedule_contract.dart';

class VisitScheduleService implements VisitSchedulePort {
  VisitScheduleService({required String baseUrl, HttpClient? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<List<ScheduledVisit>> visitsForCarer(CarerSession session) async {
    final uri = _baseUri.replace(
      path: '/api/carer/visits',
      queryParameters: {'carer_id': session.id.toString()},
    );
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseVisitsResponse(statusCode: response.statusCode, body: body);
  }
}

List<ScheduledVisit> _parseVisitsResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == HttpStatus.ok) {
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
