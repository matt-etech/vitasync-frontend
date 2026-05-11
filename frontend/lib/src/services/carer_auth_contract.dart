import '../models/carer_session.dart';

abstract class CarerAuthPort {
  Future<CarerSession> login({required String email, required String password});

  Future<void> changePassword({
    required CarerSession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}

class CarerAuthException implements Exception {
  const CarerAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
