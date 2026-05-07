class ScheduledVisit {
  const ScheduledVisit({
    required this.id,
    required this.date,
    required this.dayLabel,
    required this.clientName,
    required this.timeWindow,
    required this.status,
    this.assignedWorkerName,
  });

  final int id;
  final DateTime date;
  final String dayLabel;
  final String clientName;
  final String? assignedWorkerName;
  final String timeWindow;
  final String status;

  factory ScheduledVisit.fromJson(Map<String, dynamic> json) {
    return ScheduledVisit(
      id: (json['id'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      dayLabel: json['day'] as String,
      clientName: json['client_name'] as String,
      assignedWorkerName: json['assigned_worker_name'] as String?,
      timeWindow: json['time_window'] as String,
      status: json['status'] as String,
    );
  }
}
