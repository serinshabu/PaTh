import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show OrderClauseGenerator, OrderingTerm;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/app_providers.dart';
import '../../data/backup/life_os_backup.dart';
import '../../data/database/life_os_database.dart';

class BackupRestorePanel extends ConsumerStatefulWidget {
  const BackupRestorePanel({super.key});

  @override
  ConsumerState<BackupRestorePanel> createState() => _BackupRestorePanelState();
}

class _BackupRestorePanelState extends ConsumerState<BackupRestorePanel> {
  bool _busy = false;
  String? _message;
  String _search = '';
  List<ActivityRecord> _results = <ActivityRecord>[];

  LifeOsBackup get _backup => LifeOsBackup(ref.read(lifeOsDatabaseProvider));

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'JSON includes your records, history, preferences, and dashboard layout. CSV files are created for the record datasets. Sync credentials and pairing secrets are never included.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Create backup & CSV exports'),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore JSON backup'),
          ),
        ],
      ),
      if (_busy) const LinearProgressIndicator(),
      if (_message != null) ...<Widget>[
        const SizedBox(height: 8),
        SelectableText(_message!, key: const ValueKey<String>('backup-result')),
      ],
      const Divider(height: 28),
      Text(
        'Find historical records',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
      TextField(
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Search titles, notes, and journal entries',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: 'Search records',
            onPressed: _find,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
        onChanged: (String value) => _search = value,
        onSubmitted: (_) => _find(),
      ),
      for (final ActivityRecord record in _results)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history_rounded),
          title: Text(record.title),
          subtitle: Text(
            '${record.kind} · ${record.recordDate.toLocal().toString().split(' ').first}${record.notes.isEmpty ? '' : ' · ${record.notes}'}',
          ),
          isThreeLine: record.notes.isNotEmpty,
        ),
      if (_search.trim().isNotEmpty && _results.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('No matching records. Try another search.'),
        ),
    ],
  );

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final String json = await _backup.createJson();
      final Directory root = await getApplicationDocumentsDirectory();
      final Directory folder = Directory(
        '${root.path}${Platform.pathSeparator}PaTh-Exports',
      );
      await folder.create(recursive: true);
      final String stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final File backupFile = File(
        '${folder.path}${Platform.pathSeparator}path-backup-$stamp.json',
      );
      await backupFile.writeAsString(json, flush: true);
      final Map<String, dynamic> data =
          jsonDecode(json)['data'] as Map<String, dynamic>;
      const Map<String, List<String>> headers = <String, List<String>>{
        'activities': <String>[
          'id',
          'kind',
          'recordDate',
          'title',
          'value',
          'unit',
          'status',
          'notes',
          'metadataJson',
          'createdAt',
          'updatedAt',
          'isDeleted',
        ],
        'habits': <String>[
          'id',
          'name',
          'description',
          'category',
          'trackingType',
          'unit',
          'scheduleDays',
          'target',
          'isReduction',
          'isArchived',
          'startDate',
          'createdAt',
        ],
        'habitOccurrences': <String>[
          'id',
          'habitId',
          'occurrenceDate',
          'status',
          'numericValue',
          'notes',
          'updatedAt',
        ],
        'goals': <String>[
          'id',
          'name',
          'timeframe',
          'target',
          'progress',
          'unit',
          'dueDate',
          'status',
          'notes',
          'createdAt',
          'updatedAt',
          'isDeleted',
        ],
        'budgets': <String>[
          'id',
          'category',
          'amountMinor',
          'period',
          'createdAt',
          'updatedAt',
        ],
      };
      for (final MapEntry<String, List<String>> entry in headers.entries) {
        final List<Map<String, dynamic>> rows =
            (data[entry.key] as List<dynamic>).cast<Map<String, dynamic>>();
        final String csv = LifeOsCsv.export(
          entry.key,
          rows,
          headers: entry.value,
          columnLabels: entry.key == 'activities'
              ? const <String, String>{
                  'recordDate': 'recordDate (local time)',
                  'value': 'value (see unit column; money uses minor units)',
                }
              : entry.key == 'budgets'
              ? const <String, String>{
                  'amountMinor': 'amountMinor (paise/cents)',
                }
              : const <String, String>{},
        );
        await File(
          '${folder.path}${Platform.pathSeparator}path-${entry.key}-$stamp.csv',
        ).writeAsString(csv, flush: true);
      }
      if (mounted)
        setState(() {
          _message = 'Backup and five CSV files saved in:\n${folder.path}';
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _message =
              'Export could not be completed. Your existing records were not changed.';
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  Future<void> _restore() async {
    final TextEditingController controller = TextEditingController();
    BackupPreview? preview;
    BackupRestoreMode mode = BackupRestoreMode.merge;
    bool confirmedReplace = false;
    final bool? done = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          title: const Text('Restore a PaTh backup'),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Paste the contents of a PaTh .json backup below. Preview validates it before any database changes.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Backup JSON',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ClipboardData? clip = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      if (clip?.text != null) {
                        controller.text = clip!.text!;
                        setDialogState(() {
                          preview = null;
                        });
                      }
                    },
                    icon: const Icon(Icons.content_paste),
                    label: const Text('Paste from clipboard'),
                  ),
                  if (preview == null)
                    TextButton(
                      onPressed: () async {
                        try {
                          final BackupPreview result = await _backup.preview(
                            controller.text,
                          );
                          setDialogState(() {
                            preview = result;
                          });
                        } catch (e) {
                          setDialogState(() {
                            preview = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst(
                                  'FormatException: ',
                                  '',
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Validate and preview'),
                    ),
                  if (preview != null) ...<Widget>[
                    Text(
                      '${preview!.total} records across ${preview!.counts.values.where((int n) => n > 0).length} datasets. ${preview!.duplicateIds} matching IDs already exist.',
                    ),
                    const SizedBox(height: 8),
                    for (final MapEntry<String, int> entry
                        in preview!.counts.entries)
                      Text('${_datasetName(entry.key)}: ${entry.value}'),
                    const SizedBox(height: 8),
                    SegmentedButton<BackupRestoreMode>(
                      segments: const <ButtonSegment<BackupRestoreMode>>[
                        ButtonSegment(
                          value: BackupRestoreMode.merge,
                          label: Text('Merge'),
                        ),
                        ButtonSegment(
                          value: BackupRestoreMode.replace,
                          label: Text('Replace'),
                        ),
                      ],
                      selected: <BackupRestoreMode>{mode},
                      onSelectionChanged: (Set<BackupRestoreMode> value) =>
                          setDialogState(() {
                            mode = value.first;
                            confirmedReplace = false;
                          }),
                    ),
                    if (mode == BackupRestoreMode.merge)
                      const Text(
                        'Merge adds records with new IDs. Existing IDs are kept as they are.',
                      ),
                    if (mode == BackupRestoreMode.replace)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: confirmedReplace,
                        title: const Text(
                          'I understand this replaces current records',
                        ),
                        subtitle: const Text(
                          'A copy is not created automatically. Export a backup first if you may need the current data.',
                        ),
                        onChanged: (bool? value) => setDialogState(() {
                          confirmedReplace = value ?? false;
                        }),
                      ),
                  ],
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  preview != null &&
                      (mode == BackupRestoreMode.merge || confirmedReplace)
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: Text(
                mode == BackupRestoreMode.merge
                    ? 'Merge records'
                    : 'Replace records',
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (done != true) {
      controller.dispose();
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final BackupPreview result = await _backup.restore(controller.text, mode);
      if (mounted)
        setState(() {
          _message = mode == BackupRestoreMode.merge
              ? 'Restore complete. ${result.duplicateIds} existing records were preserved; matching IDs were not overwritten.'
              : 'Restore complete. Imported records are queued for synchronization.';
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _message =
              'Restore failed. The transaction was rolled back and existing records were preserved.';
        });
    } finally {
      controller.dispose();
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  Future<void> _find() async {
    final String query = _search.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _results = <ActivityRecord>[];
      });
      return;
    }
    final List<ActivityRecord> rows =
        await (ref
                .read(lifeOsDatabaseProvider)
                .select(ref.read(lifeOsDatabaseProvider).activityRecords)
              ..where((ActivityRecords r) => r.isDeleted.equals(false))
              ..orderBy(<OrderClauseGenerator<ActivityRecords>>[
                (ActivityRecords r) => OrderingTerm.desc(r.recordDate),
              ]))
            .get();
    if (mounted)
      setState(() {
        _results = rows
            .where(
              (ActivityRecord r) => '${r.title} ${r.notes} ${r.kind}'
                  .toLowerCase()
                  .contains(query),
            )
            .take(50)
            .toList();
      });
  }

  String _datasetName(String value) => switch (value) {
    'activities' => 'Activity records',
    'habits' => 'Habits',
    'habitOccurrences' => 'Habit history',
    'goals' => 'Goals',
    'budgets' => 'Budgets',
    _ => value,
  };
}
