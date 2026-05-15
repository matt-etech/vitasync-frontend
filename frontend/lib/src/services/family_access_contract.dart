import '../models/family_portal_summary.dart';
import '../models/family_session.dart';

abstract class FamilyAccessPort {
  Future<FamilySession> login({
    required String email,
    required String password,
  });

  Future<FamilyPortalSummary> portalSummary(
    FamilySession session, {
    int? clientId,
  });

  Future<void> changePassword({
    required FamilySession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}

class FamilyAccessException implements Exception {
  const FamilyAccessException(this.message);

  final String message;

  @override
  String toString() => message;
}
