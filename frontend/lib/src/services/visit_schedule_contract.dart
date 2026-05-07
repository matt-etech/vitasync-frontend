import '../models/carer_session.dart';
import '../models/scheduled_visit.dart';

abstract class VisitSchedulePort {
  Future<List<ScheduledVisit>> visitsForCarer(CarerSession session);
}

class VisitScheduleException implements Exception {
  const VisitScheduleException(this.message);

  final String message;

  @override
  String toString() => message;
}
