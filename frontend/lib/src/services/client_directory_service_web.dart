// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/care_client.dart';
import '../models/carer_session.dart';
import 'client_directory_contract.dart';

class ClientDirectoryService implements ClientDirectoryPort {
  ClientDirectoryService({required String baseUrl})
    : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;

  @override
  Future<List<CareClient>> clientsForCarer(CarerSession session) async {
    final request = await html.HttpRequest.request(
      _baseUri
          .replace(
            path: '/api/carer/clients',
            queryParameters: {'carer_id': session.id.toString()},
          )
          .toString(),
      method: 'GET',
      requestHeaders: const {'Accept': 'application/json'},
    );

    return _parseClientsResponse(
      statusCode: request.status ?? 0,
      body: request.responseText ?? '',
    );
  }
}

List<CareClient> _parseClientsResponse({
  required int statusCode,
  required String body,
}) {
  if (statusCode == 200) {
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
