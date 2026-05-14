// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/family_portal_summary.dart';
import '../models/family_session.dart';
import 'family_access_contract.dart';

class FamilyAccessService implements FamilyAccessPort {
  FamilyAccessService({required String baseUrl})
    : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;

  @override
  Future<FamilySession> login({
    required String email,
    required String password,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.resolve('/api/family/login').toString(),
      method: 'POST',
      requestHeaders: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      sendData: jsonEncode(_loginPayload(email: email, password: password)),
    );

    if (request.status == 200) {
      return FamilySession.fromJson(
        jsonDecode(request.responseText ?? '{}') as Map<String, dynamic>,
      );
    }

    throw const FamilyAccessException('incorrect user or password');
  }

  @override
  Future<FamilyPortalSummary> portalSummary(FamilySession session) async {
    final request = await html.HttpRequest.request(
      _baseUri
          .replace(
            path: '/api/family/portal',
            queryParameters: {'family_member_id': session.id.toString()},
          )
          .toString(),
      method: 'GET',
      requestHeaders: const {'Accept': 'application/json'},
    );

    if (request.status == 200) {
      return FamilyPortalSummary.fromJson(
        jsonDecode(request.responseText ?? '{}') as Map<String, dynamic>,
      );
    }

    throw const FamilyAccessException(
      'Family portal could not be loaded. Check the backend connection and try again.',
    );
  }
}

Map<String, String> _loginPayload({
  required String email,
  required String password,
}) {
  final now = DateTime.now();

  return {
    'email': email.trim(),
    'password': password,
    'device_timezone': now.timeZoneName,
    'device_datetime': now.toIso8601String(),
  };
}
