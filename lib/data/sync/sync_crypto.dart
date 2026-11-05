import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Client-side authenticated encryption for all payloads sent to the sync API.
/// The server stores and returns this envelope without decrypting it.
class SyncCrypto {
  SyncCrypto._(this._key);

  final SecretKey _key;
  static const int kdfIterations = 310000;
  static final AesGcm _cipher = AesGcm.with256bits();

  static Future<SyncCrypto> fromRecoverySecret({
    required String recoverySecret,
    required String saltBase64,
    int iterations = kdfIterations,
  }) async {
    if (recoverySecret.trim().length < 16) {
      throw ArgumentError('Use a recovery phrase with at least 16 characters.');
    }
    final Pbkdf2 kdf = Pbkdf2.hmacSha256(iterations: iterations, bits: 256);
    final SecretKey key = await kdf.deriveKeyFromPassword(
      password: recoverySecret,
      nonce: base64.decode(saltBase64),
    );
    return SyncCrypto._(key);
  }

  Future<String> encrypt(Map<String, dynamic> payload) async {
    final SecretBox box = await _cipher.encrypt(
      utf8.encode(jsonEncode(payload)),
      secretKey: _key,
      aad: utf8.encode('lifeos.sync.v1'),
    );
    return jsonEncode(<String, Object>{
      'v': 1,
      'nonce': base64.encode(box.nonce),
      'ciphertext': base64.encode(box.cipherText),
      'mac': base64.encode(box.mac.bytes),
    });
  }

  Future<Map<String, dynamic>> decrypt(String envelope) async {
    final Map<String, dynamic> value =
        jsonDecode(envelope) as Map<String, dynamic>;
    if (value['v'] != 1)
      throw const FormatException('Unsupported sync payload version.');
    final List<int> clear = await _cipher.decrypt(
      SecretBox(
        base64.decode(value['ciphertext'] as String),
        nonce: base64.decode(value['nonce'] as String),
        mac: Mac(base64.decode(value['mac'] as String)),
      ),
      secretKey: _key,
      aad: utf8.encode('lifeos.sync.v1'),
    );
    final dynamic result = jsonDecode(utf8.decode(clear));
    if (result is! Map<String, dynamic>)
      throw const FormatException('Invalid PaTh sync record.');
    return result;
  }
}
