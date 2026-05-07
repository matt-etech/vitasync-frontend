import 'care_plan_task.dart';

class VisitWorkflow {
  const VisitWorkflow({
    required this.id,
    required this.clientName,
    required this.timeWindow,
    required this.status,
    required this.tasks,
    this.address,
    this.checkInTime,
    this.checkOutTime,
  });

  final int id;
  final String clientName;
  final String? address;
  final String timeWindow;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final List<CarePlanTask> tasks;

  factory VisitWorkflow.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] as List<dynamic>? ?? const [];

    return VisitWorkflow(
      id: (json['id'] as num).toInt(),
      clientName: json['client_name'] as String,
      address: json['address'] as String?,
      timeWindow: json['time_window'] as String,
      status: json['status'] as String,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      tasks: [
        for (final task in tasks)
          CarePlanTask.fromJson(task as Map<String, dynamic>),
      ],
    );
  }
}
