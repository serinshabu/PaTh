import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/life_os_palette.dart';
import '../../data/database/life_os_database.dart';
import '../../data/sync/sync_api_client.dart';
import '../../data/sync/sync_credentials.dart';
import '../../data/sync/sync_conflict_presentation.dart';
import '../../data/sync/sync_crypto.dart';
import '../../data/sync/sync_runtime.dart';

class SyncSettingsPanel extends ConsumerStatefulWidget {
  const SyncSettingsPanel({required this.palette, super.key});
  final LifeOsPalette palette;

  @override
  ConsumerState<SyncSettingsPanel> createState() => _SyncSettingsPanelState();
}

class _SyncSettingsPanelState extends ConsumerState<SyncSettingsPanel> {
  final TextEditingController _uri = TextEditingController();
  final TextEditingController _name = TextEditingController(text: 'My device');
  final TextEditingController _pairing = TextEditingController();
  final TextEditingController _recovery = TextEditingController();
  bool _busy = false;
  SyncCredentials? _credentials;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final SyncCredentials? credentials = await ref
        .read(syncCredentialsStoreProvider)
        .read();
    if (!mounted || credentials == null) return;
    setState(() {
      _credentials = credentials;
      _uri.text = credentials.serverUrl;
      _recovery.text = credentials.recoverySecret;
    });
  }

  @override
  void dispose() {
    _uri.dispose();
    _name.dispose();
    _pairing.dispose();
    _recovery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SyncStatus status = ref.watch(syncStatusProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(_iconFor(status.phase), color: _colorFor(status.phase)),
          title: Text(syncPhaseLabel(status.phase)),
          subtitle: Text(_statusDescription(status)),
          trailing: IconButton(
            tooltip: 'Sync now',
            onPressed: _busy
                ? null
                : () => ref.read(syncRunnerProvider).runNow(),
            icon: const Icon(Icons.sync_rounded),
          ),
        ),
        if (status.pending > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${status.pending} local change${status.pending == 1 ? '' : 's'} waiting to sync.',
            ),
          ),
        TextField(
          controller: _uri,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Self-hosted HTTPS server URL',
            hintText: 'https://lifeos.example.com',
          ),
        ),
        if (_credentials == null) ...<Widget>[
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Device name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pairing,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Server pairing code'),
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: _recovery,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'Private recovery phrase',
            helperText:
                'Use the same phrase on every device. It is never sent to the server. Losing it means encrypted records cannot be recovered.',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.icon(
              onPressed: _busy ? null : _pairOrSave,
              icon: Icon(
                _credentials == null ? Icons.link_rounded : Icons.save_outlined,
              ),
              label: Text(
                _credentials == null
                    ? 'Pair this device'
                    : 'Save sync settings',
              ),
            ),
            if (_credentials != null)
              OutlinedButton.icon(
                onPressed: _busy ? null : _showDevices,
                icon: const Icon(Icons.devices_outlined),
                label: const Text('Linked devices'),
              ),
            if (_credentials != null)
              OutlinedButton.icon(
                onPressed: _busy ? null : _showConflicts,
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('Review conflicts'),
              ),
            if (_credentials != null)
              TextButton(
                onPressed: _busy ? null : _disconnect,
                child: const Text('Disconnect'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Record contents are encrypted on this device with AES-GCM before upload. The server stores opaque encrypted payloads and metadata needed to order sync; HTTPS is still required.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: widget.palette.secondaryText),
        ),
      ],
    );
  }

  Future<void> _pairOrSave() async {
    if (_uri.text.trim().isEmpty || _recovery.text.trim().length < 16) {
      _message(
        'Enter a server URL and a recovery phrase of at least 16 characters.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      if (_credentials == null) {
        final SyncApiClient api = SyncApiClient(_uri.text.trim());
        try {
          final Map<String, dynamic> pair = await api.pair(
            code: _pairing.text.trim(),
            deviceName: _name.text.trim(),
          );
          await SyncCrypto.fromRecoverySecret(
            recoverySecret: _recovery.text,
            saltBase64: pair['keySalt'] as String,
            iterations: pair['kdfIterations'] as int,
          );
          final SyncCredentials credentials = SyncCredentials(
            serverUrl: _uri.text.trim(),
            deviceToken: pair['token'] as String,
            recoverySecret: _recovery.text,
            deviceId: pair['deviceId'] as String,
          );
          await ref.read(syncCredentialsStoreProvider).save(credentials);
          if (!mounted) return;
          setState(() => _credentials = credentials);
          _pairing.clear();
          await ref.read(syncRunnerProvider).runNow();
        } finally {
          api.close();
        }
      } else {
        if (_recovery.text != _credentials!.recoverySecret) {
          throw const FormatException(
            'The recovery phrase is the encryption key. Key rotation is not available yet; keep using the existing phrase.',
          );
        }
        await ref
            .read(syncCredentialsStoreProvider)
            .save(
              SyncCredentials(
                serverUrl: _uri.text.trim(),
                deviceToken: _credentials!.deviceToken,
                recoverySecret: _recovery.text,
                deviceId: _credentials!.deviceId,
              ),
            );
        setState(
          () => _credentials = SyncCredentials(
            serverUrl: _uri.text.trim(),
            deviceToken: _credentials!.deviceToken,
            recoverySecret: _recovery.text,
            deviceId: _credentials!.deviceId,
          ),
        );
        await ref.read(syncRunnerProvider).runNow();
      }
      _message('Sync settings saved securely on this device.');
    } catch (error) {
      _message('Could not configure sync: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Disconnect this device?'),
        content: const Text(
          'Local records stay on this device. The device token and saved recovery phrase will be removed here. Revoke this device on the server to prevent future access.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await ref.read(syncCredentialsStoreProvider).clear();
    if (mounted) setState(() => _credentials = null);
    _message('Sync disconnected. Local records were kept.');
  }

  Future<void> _showDevices() async {
    if (_credentials == null) return;
    final SyncApiClient api = SyncApiClient(
      _credentials!.serverUrl,
      token: _credentials!.deviceToken,
    );
    try {
      final List<dynamic> devices =
          (await api.devices())['devices'] as List<dynamic>;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialog) => AlertDialog(
          title: const Text('Linked devices'),
          content: SizedBox(
            width: 480,
            child: devices.isEmpty
                ? const Text('No devices paired.')
                : ListView(
                    shrinkWrap: true,
                    children: devices.map((dynamic value) {
                      final Map<String, dynamic> item =
                          value as Map<String, dynamic>;
                      final bool revoked = item['revoked_at'] != null;
                      final bool current = item['id'] == _credentials!.deviceId;
                      return ListTile(
                        title: Text(
                          '${item['name']}${current ? ' · This device' : ''}',
                        ),
                        subtitle: Text(revoked ? 'Revoked' : 'Active'),
                        trailing: revoked || current
                            ? null
                            : IconButton(
                                tooltip: 'Revoke device',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () async {
                                  await api.revokeDevice(item['id'] as String);
                                  if (dialog.mounted) Navigator.pop(dialog);
                                  await _showDevices();
                                },
                              ),
                      );
                    }).toList(),
                  ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      _message('Could not load linked devices: $error');
    } finally {
      api.close();
    }
  }

  Future<void> _showConflicts() async {
    final List<SyncConflict> conflicts = await ref
        .read(syncEngineProvider)
        .watchOpenConflicts()
        .first;
    if (!mounted) return;
    if (conflicts.isEmpty) {
      _message('There are no unresolved sync conflicts.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialog) => AlertDialog(
        title: const Text('Resolve sync conflicts'),
        content: SizedBox(
          width: 520,
          child: ListView(
            shrinkWrap: true,
            children: conflicts
                .map(
                  (SyncConflict conflict) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _conflictTitle(conflict),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Both devices changed this record. Choose which version to use; both encrypted versions remain in local conflict history.',
                          ),
                          Wrap(
                            children: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    _resolve(conflict, 'local', dialog),
                                child: const Text('Keep this device'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _resolve(conflict, 'remote', dialog),
                                child: const Text('Use server version'),
                              ),
                              if (conflict.entityType == 'activity' &&
                                  _isJournal(conflict))
                                TextButton(
                                  onPressed: () =>
                                      _resolve(conflict, 'both', dialog),
                                  child: const Text(
                                    'Keep both journal entries',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isJournal(SyncConflict conflict) {
    try {
      return (jsonDecode(conflict.localPayloadJson)
              as Map<String, dynamic>)['kind'] ==
          'journal';
    } catch (_) {
      return false;
    }
  }

  String _conflictTitle(SyncConflict conflict) {
    return syncConflictTitle(conflict);
  }

  Future<void> _resolve(
    SyncConflict conflict,
    String choice,
    BuildContext dialog,
  ) async {
    final SyncCredentials? credentials = _credentials;
    if (credentials == null) return;
    final SyncApiClient api = SyncApiClient(
      credentials.serverUrl,
      token: credentials.deviceToken,
    );
    try {
      final Map<String, dynamic> config = await api.config();
      final SyncCrypto crypto = await SyncCrypto.fromRecoverySecret(
        recoverySecret: credentials.recoverySecret,
        saltBase64: config['keySalt'] as String,
        iterations: config['kdfIterations'] as int,
      );
      await ref
          .read(syncEngineProvider)
          .resolveConflict(conflict, choice, crypto);
      await ref.read(syncRunnerProvider).runNow();
      if (dialog.mounted) Navigator.pop(dialog);
      await _showConflicts();
    } catch (error) {
      _message('Could not resolve this conflict: $error');
    } finally {
      api.close();
    }
  }

  void _message(String text) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  IconData _iconFor(SyncPhase phase) => switch (phase) {
    SyncPhase.synced => Icons.cloud_done_outlined,
    SyncPhase.syncing => Icons.sync_rounded,
    SyncPhase.offline => Icons.cloud_off_outlined,
    SyncPhase.pending => Icons.cloud_upload_outlined,
    SyncPhase.error => Icons.error_outline,
    SyncPhase.conflict => Icons.compare_arrows_rounded,
    SyncPhase.notConfigured => Icons.cloud_outlined,
  };
  Color _colorFor(SyncPhase phase) => switch (phase) {
    SyncPhase.synced => widget.palette.positive,
    SyncPhase.offline || SyncPhase.pending => widget.palette.warning,
    SyncPhase.error || SyncPhase.conflict => widget.palette.negative,
    _ => widget.palette.lavender,
  };
  String _statusDescription(SyncStatus s) {
    if (s.message != null) return s.message!;
    if (s.lastSyncedAt != null)
      return 'Last successful sync: ${s.lastSyncedAt!.toLocal()}';
    return 'Pair devices to synchronize encrypted records.';
  }
}
