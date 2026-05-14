import 'dart:convert';
import 'dart:io';

import '../models/family_portal_summary.dart';
import '../models/family_session.dart';
import 'family_access_contract.dart';

class FamilyAccessService implements FamilyAccessPort {
  FamilyAccessService({required String baseUrl, HttpClient? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<FamilySession> login({
    required String email,
    required String password,
  }) async {
    final request = await _httpClient.postUrl(
      _baseUri.resolve('/api/family/login'),
    );
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.write(jsonEncode(_loginPayload(email: email, password: password)));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == HttpStatus.ok) {
      return FamilySession.fromJson(jsonDecode(body) as Map<String, dynamic>);
    }

    throw const FamilyAccessException('incorrect user or password');
  }

  @override
  Future<FamilyPortalSummary> portalSummary(FamilySession session) async {
    final uri = _baseUri.replace(
      path: '/api/family/portal',
      queryParameters: {'family_member_id': session.id.toString()},
    );
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == HttpStatus.ok) {
      return FamilyPortalSummary.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
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
