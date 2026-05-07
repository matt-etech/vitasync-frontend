class CarePlanTask {
  const CarePlanTask({
    required this.id,
    required this.clientName,
    required this.carePlanTitle,
    required this.section,
    required this.title,
    required this.instructions,
    required this.status,
    this.riskLevel,
  });

  final String id;
  final String clientName;
  final String carePlanTitle;
  final String section;
  final String title;
  final String instructions;
  final String status;
  final String? riskLevel;

  factory CarePlanTask.fromJson(Map<String, dynamic> json) {
    return CarePlanTask(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      carePlanTitle: json['care_plan_title'] as String,
      section: json['section'] as String,
      title: json['title'] as String,
      instructions: json['instructions'] as String,
      status: json['status'] as String,
      riskLevel: json['risk_level'] as String?,
    );
  }
}
