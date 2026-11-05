import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncCredentials {
  const SyncCredentials({
    required this.serverUrl,
    required this.deviceToken,
    required this.recoverySecret,
    required this.deviceId,
  });

  final String serverUrl;
  final String deviceToken;
  final String recoverySecret;
  final String deviceId;
}

/// Tokens and the user-held E2EE recovery secret are stored using platform secure storage.
class SyncCredentialsStore {
  const SyncCredentialsStore(this._storage);

  final FlutterSecureStorage _storage;
  static const String _urlKey = 'sync.serverUrl';
  static const String _tokenKey = 'sync.deviceToken';
  static const String _recoveryKey = 'sync.recoverySecret';
  static const String _deviceKey = 'sync.deviceId';

  Future<SyncCredentials?> read() async {
    final String? url = await _storage.read(key: _urlKey);
    final String? token = await _storage.read(key: _tokenKey);
    final String? secret = await _storage.read(key: _recoveryKey);
    final String? deviceId = await _storage.read(key: _deviceKey);
    if (url == null || token == null || secret == null || deviceId == null)
      return null;
    return SyncCredentials(
      serverUrl: url,
      deviceToken: token,
      recoverySecret: secret,
      deviceId: deviceId,
    );
  }

  Future<void> save(SyncCredentials credentials) async {
    await _storage.write(
      key: _urlKey,
      value: credentials.serverUrl.trim().replaceFirst(RegExp(r'/$'), ''),
    );
    await _storage.write(key: _tokenKey, value: credentials.deviceToken.trim());
    await _storage.write(key: _recoveryKey, value: credentials.recoverySecret);
    await _storage.write(key: _deviceKey, value: credentials.deviceId);
  }

  Future<void> clear() async {
    await _storage.delete(key: _urlKey);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _recoveryKey);
    await _storage.delete(key: _deviceKey);
  }
}
