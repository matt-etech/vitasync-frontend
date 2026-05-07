import '../models/care_client.dart';
import '../models/carer_session.dart';

abstract class ClientDirectoryPort {
  Future<List<CareClient>> clientsForCarer(CarerSession session);
}

class ClientDirectoryException implements Exception {
  const ClientDirectoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
