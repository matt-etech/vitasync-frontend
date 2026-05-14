import 'dart:convert';
import 'dart:io';

import '../models/carer_session.dart';
import 'carer_auth_contract.dart';

class CarerAuthService implements CarerAuthPort {
  CarerAuthService({required String baseUrl, HttpClient? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    final request = await _httpClient.postUrl(
      _baseUri.resolve('/api/carer/login'),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(_payload(email: email, password: password)));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseLoginResponse(statusCode: response.statusCode, body: body);
  }

  @override
  Future<void> changePassword({
    required CarerSession session,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final request = await _httpClient.postUrl(
      _baseUri.resolve('/api/carer/change-password'),
    );
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(
      jsonEncode({
        'carer_id': session.id,
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    _parsePasswordChangeResponse(statusCode: response.statusCode, body: body);
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
  if (statusCode == HttpStatus.ok) {
    return CarerSession.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  if (statusCode == HttpStatus.unprocessableEntity) {
    throw const CarerAuthException('incorrect user or password');
  }

  if (statusCode == HttpStatus.forbidden) {
    throw const CarerAuthException('incorrect user or password');
  }

  throw const CarerAuthException('incorrect user or password');
}

void _parsePasswordChangeResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == HttpStatus.ok) {
    return;
  }

  if (statusCode == HttpStatus.unprocessableEntity ||
      statusCode == HttpStatus.forbidden) {
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
