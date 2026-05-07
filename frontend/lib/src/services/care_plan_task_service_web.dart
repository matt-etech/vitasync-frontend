// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/care_plan_task.dart';
import '../models/carer_session.dart';
import 'care_plan_task_contract.dart';

class CarePlanTaskService implements CarePlanTaskPort {
  CarePlanTaskService({required String baseUrl})
    : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;

  @override
  Future<List<CarePlanTask>> tasksForCarer(CarerSession session) async {
    final request = await html.HttpRequest.request(
      _baseUri
          .replace(
            path: '/api/carer/tasks',
            queryParameters: {'carer_id': session.id.toString()},
          )
          .toString(),
      method: 'GET',
      requestHeaders: const {'Accept': 'application/json'},
    );

    return _parseTasksResponse(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }
}

List<CarePlanTask> _parseTasksResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
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
