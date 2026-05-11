import 'care_plan_task.dart';

class VisitWorkflow {
  const VisitWorkflow({
    required this.id,
    required this.clientName,
    required this.timeWindow,
    required this.status,
    required this.tasks,
    this.address,
    this.clientLatitude,
    this.clientLongitude,
    this.geofenceRadiusMeters,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.checkInTime,
    this.checkOutTime,
    this.allergies,
    this.criticalInformation,
  });

  final int id;
  final String clientName;
  final String? address;
  final double? clientLatitude;
  final double? clientLongitude;
  final int? geofenceRadiusMeters;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final String timeWindow;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? allergies;
  final String? criticalInformation;
  final List<CarePlanTask> tasks;

  factory VisitWorkflow.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] as List<dynamic>? ?? const [];

    return VisitWorkflow(
      id: (json['id'] as num).toInt(),
      clientName: json['client_name'] as String,
      address: json['address'] as String?,
      clientLatitude: (json['client_latitude'] as num?)?.toDouble(),
      clientLongitude: (json['client_longitude'] as num?)?.toDouble(),
      geofenceRadiusMeters: (json['geofence_radius_meters'] as num?)?.toInt(),
      scheduledStartAt: _parseDateTime(json['scheduled_start_at']),
      scheduledEndAt: _parseDateTime(json['scheduled_end_at']),
      timeWindow: json['time_window'] as String,
      status: json['status'] as String,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      allergies:
          _firstText(json, const ['allergies', 'client_allergies']) ??
          _nestedText(json, 'client', const ['allergies']) ??
          _nestedText(json, 'medical', const ['allergies']),
      criticalInformation:
          _firstText(json, const [
            'critical_information',
            'critical_info',
            'critical_notes',
            'client_critical_information',
            'client_critical_notes',
          ]) ??
          _nestedText(json, 'client', const [
            'critical_information',
            'critical_info',
            'critical_notes',
          ]) ??
          _nestedText(json, 'assessment', const [
            'critical_information',
            'critical_notes',
          ]),
      tasks: [
        for (final task in tasks)
          CarePlanTask.fromJson(task as Map<String, dynamic>),
      ],
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value)?.toLocal();
}

String? _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final text = _textValue(json[key]);
    if (text != null) {
      return text;
    }
  }

  return null;
}

String? _nestedText(
  Map<String, dynamic> json,
  String parentKey,
  List<String> keys,
) {
  final parent = json[parentKey];
  if (parent is! Map<String, dynamic>) {
    return null;
  }

  return _firstText(parent, keys);
}

String? _textValue(Object? value) {
  if (value is! String) {
    return null;
  }

  final text = value.trim();
  return text.isEmpty ? null : text;
}
