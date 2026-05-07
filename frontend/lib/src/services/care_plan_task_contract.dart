import '../models/care_plan_task.dart';
import '../models/carer_session.dart';

abstract class CarePlanTaskPort {
  Future<List<CarePlanTask>> tasksForCarer(CarerSession session);
}

class CarePlanTaskException implements Exception {
  const CarePlanTaskException(this.message);

  final String message;

  @override
  String toString() => message;
}
