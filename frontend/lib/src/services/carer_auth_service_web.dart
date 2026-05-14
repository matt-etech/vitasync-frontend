// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/carer_session.dart';
import 'carer_auth_contract.dart';

class CarerAuthService implements CarerAuthPort {
  CarerAuthService({required String baseUrl}) : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;

  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.resolve('/api/carer/login').toString(),
      method: 'POST',
      requestHeaders: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      sendData: jsonEncode(_payload(email: email, password: password)),
    );

    return _parseLoginResponse(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }

  @override
  Future<void> changePassword({
    required CarerSession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final request = await html.HttpRequest.request(
      _baseUri.resolve('/api/carer/change-password').toString(),
      method: 'POST',
      requestHeaders: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      sendData: jsonEncode({
        'carer_id': session.id,
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    _parsePasswordChangeResponse(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }
}

Map<String, String> _payload({
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

CarerSession _parseLoginResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
    return CarerSession.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  if (statusCode == 422) {
    throw const CarerAuthException('incorrect user or password');
  }

  if (statusCode == 403) {
    throw const CarerAuthException('incorrect user or password');
  }

  throw const CarerAuthException('incorrect user or password');
}

void _parsePasswordChangeResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
    return;
  }

  if (statusCode == 422 || statusCode == 403) {
    final decoded = jsonDecode(body) as Map<String, dynamic>?;
    final message = decoded?['message'] as String?;

    throw CarerAuthException(
      message ??
          'Password could not be changed. Check the details and try again.',
    );
  }

  throw const CarerAuthException(
    'Password could not be changed. Check the backend connection and try again.',
  );
}
