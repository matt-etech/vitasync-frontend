import 'dart:convert';
import 'dart:io';

import '../models/care_plan_task.dart';
import '../models/carer_session.dart';
import 'care_plan_task_contract.dart';

class CarePlanTaskService implements CarePlanTaskPort {
  CarePlanTaskService({required String baseUrl, HttpClient? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<List<CarePlanTask>> tasksForCarer(CarerSession session) async {
    final uri = _baseUri.replace(
      path: '/api/carer/tasks',
      queryParameters: {'carer_id': session.id.toString()},
    );
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseTasksResponse(statusCode: response.statusCode, body: body);
  }
}

List<CarePlanTask> _parseTasksResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == HttpStatus.ok) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final tasks = decoded['tasks'] as List<dynamic>? ?? const [];

    return [
      for (final task in tasks)
        CarePlanTask.fromJson(task as Map<String, dynamic>),
    ];
  }

  throw const CarePlanTaskException(
    'Care plan tasks could not be loaded. Check the backend connection and try again.',
  );
}
