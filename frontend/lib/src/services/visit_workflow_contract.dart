import '../models/carer_session.dart';
import '../models/visit_workflow.dart';

abstract class VisitWorkflowPort {
  Future<VisitWorkflow?> todayVisitForCarer(CarerSession session);

  Future<VisitWorkflow> checkIn({
    required CarerSession session,
    required int visitId,
  });

  Future<VisitWorkflow> checkOut({
    required CarerSession session,
    required int visitId,
  });
}

class VisitWorkflowException implements Exception {
  const VisitWorkflowException(this.message);

  final String message;

  @override
  String toString() => message;
}
