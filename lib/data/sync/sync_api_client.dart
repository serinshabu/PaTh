import 'dart:convert';
import 'dart:io';

class SyncApiException implements Exception {
  const SyncApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class SyncApiClient {
  SyncApiClient(this.baseUrl, {this.token});

  final String baseUrl;
  final String? token;
  final HttpClient _http = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  static Uri validateBaseUrl(String value) {
    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      throw const FormatException('Enter a complete sync server URL.');
    }
    final bool loopback =
        uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '::1';
    if (uri.scheme != 'https' && !(loopback && uri.scheme == 'http')) {
      throw const FormatException(
        'Sync requires HTTPS. HTTP is allowed only for localhost testing.',
      );
    }
    return uri.replace(path: uri.path.replaceFirst(RegExp(r'/$'), ''));
  }

  Future<Map<String, dynamic>> pair({
    required String code,
    required String deviceName,
  }) => _request(
    'POST',
    '/v1/devices/pair',
    body: <String, dynamic>{'code': code, 'name': deviceName},
  );

  Future<Map<String, dynamic>> config() => _request('GET', '/v1/sync/config');

  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) =>
      _request(
        'POST',
        '/v1/changes',
        body: <String, dynamic>{'changes': changes},
      );

  Future<Map<String, dynamic>> pull({
    required String cursor,
    int limit = 100,
  }) => _request(
    'GET',
    '/v1/changes?cursor=${Uri.encodeQueryComponent(cursor)}&limit=$limit',
  );

  Future<Map<String, dynamic>> devices() => _request('GET', '/v1/devices');

  Future<void> revokeDevice(String id) async =>
      _request('DELETE', '/v1/devices/$id');

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final Uri base = validateBaseUrl(baseUrl);
    final Uri uri = Uri.parse('${base.toString()}$path');
    final HttpClientRequest request = await _http
        .openUrl(method, uri)
        .timeout(const Duration(seconds: 20));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null)
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final HttpClientResponse response = await request.close().timeout(
      const Duration(seconds: 30),
    );
    final String text = await utf8.decoder.bind(response).join();
    final dynamic decoded = text.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(text);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = decoded is Map<String, dynamic>
          ? (decoded['error'] as String? ?? 'Sync server rejected the request.')
          : 'Sync server rejected the request.';
      throw SyncApiException(message, statusCode: response.statusCode);
    }
    if (decoded is! Map<String, dynamic>)
      throw const SyncApiException('Invalid response from sync server.');
    return decoded;
  }

  void close() => _http.close(force: true);
}
