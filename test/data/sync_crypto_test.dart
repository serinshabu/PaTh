import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/sync/sync_crypto.dart';

void main() {
  test(
    'AES-GCM sync envelopes round-trip and reject modified ciphertext',
    () async {
      final SyncCrypto crypto = await SyncCrypto.fromRecoverySecret(
        recoverySecret: 'violet-river-moonlight-2026-safe',
        saltBase64: base64.encode(List<int>.generate(16, (int i) => i)),
        iterations: 100000,
      );
      final Map<String, dynamic> payload = <String, dynamic>{
        'kind': 'journal',
        'title': 'Private',
        'notes': 'Must stay opaque on server',
      };
      final String envelope = await crypto.encrypt(payload);
      final Map<String, dynamic> outer =
          jsonDecode(envelope) as Map<String, dynamic>;
      expect(
        outer.keys,
        containsAll(<String>['v', 'nonce', 'ciphertext', 'mac']),
      );
      expect(outer['ciphertext'], isNot(contains('Private')));
      expect(await crypto.decrypt(envelope), payload);
      final List<int> bytes = base64.decode(outer['ciphertext'] as String);
      bytes[0] ^= 1;
      outer['ciphertext'] = base64.encode(bytes);
      await expectLater(crypto.decrypt(jsonEncode(outer)), throwsA(anything));
    },
  );
}
