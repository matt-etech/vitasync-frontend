import 'dart:convert';
import 'dart:io';

import '../models/care_client.dart';
import '../models/carer_session.dart';
import 'client_directory_contract.dart';

class ClientDirectoryService implements ClientDirectoryPort {
  ClientDirectoryService({required String baseUrl, HttpClient? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<List<CareClient>> clientsForCarer(CarerSession session) async {
    final uri = _baseUri.replace(
      path: '/api/carer/clients',
      queryParameters: {'carer_id': session.id.toString()},
    );
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return _parseClientsResponse(statusCode: response.statusCode, body: body);
  }
}

List<CareClient> _parseClientsResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == HttpStatus.ok) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final clients = decoded['clients'] as List<dynamic>? ?? const [];

    return [
      for (final client in clients)
        CareClient.fromJson(client as Map<String, dynamic>),
    ];
  }

  throw const ClientDirectoryException(
    'Clients could not be loaded. Check the backend connection and try again.',
  );
}
