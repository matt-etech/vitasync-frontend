import 'dart:convert';
import 'dart:io';

import '../models/carer_session.dart';
import 'carer_auth_contract.dart';

class CarerAuthService implements CarerAuthPort {
  CarerAuthService({
    required String baseUrl,
    HttpClient? httpClient,
  })  : _baseUri = Uri.parse(baseUrl),
        _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<CarerSession> login({
    required String email,
    required String password,
  }) async {
    final request = await _httpClient.postUrl(_baseUri.resolve('/api/carer/login'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(_payload(email: email, password: password)));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseLoginResponse(statusCode: response.statusCode, body: body);
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
    throw const CarerAuthException('Email or password was not recognised for a carer account.');
  }

  if (statusCode == HttpStatus.forbidden) {
    throw const CarerAuthException('This login is only available to active carers.');
  }

  throw const CarerAuthException('Login could not be completed. Check the backend connection and try again.');
}
