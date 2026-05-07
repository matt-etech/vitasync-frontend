import 'dart:convert';
import 'dart:html' as html;

import '../models/carer_session.dart';
import 'carer_auth_contract.dart';

class CarerAuthService implements CarerAuthPort {
  CarerAuthService({
    required String baseUrl,
  }) : _baseUri = Uri.parse(baseUrl);

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
    throw const CarerAuthException('Email or password was not recognised for a carer account.');
  }

  if (statusCode == 403) {
    throw const CarerAuthException('This login is only available to active carers.');
  }

  throw const CarerAuthException('Login could not be completed. Check the backend connection and try again.');
}
