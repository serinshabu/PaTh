// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_os_database.dart';

// ignore_for_file: type=lint
class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeIdMeta = const VerificationMeta(
    'themeId',
  );
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
    'theme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('midnightRose'),
  );
  static const VerificationMeta _accentIdMeta = const VerificationMeta(
    'accentId',
  );
  @override
  late final GeneratedColumn<String> accentId = GeneratedColumn<String>(
    'accent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rose'),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _dateFormatMeta = const VerificationMeta(
    'dateFormat',
  );
  @override
  late final GeneratedColumn<String> dateFormat = GeneratedColumn<String>(
    'date_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DD/MM/YYYY'),
  );
  static const VerificationMeta _timeFormatMeta = const VerificationMeta(
    'timeFormat',
  );
  @override
  late final GeneratedColumn<String> timeFormat = GeneratedColumn<String>(
    'time_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('12-hour'),
  );
  static const VerificationMeta _sidebarCollapsedMeta = const VerificationMeta(
    'sidebarCollapsed',
  );
  @override
  late final GeneratedColumn<bool> sidebarCollapsed = GeneratedColumn<bool>(
    'sidebar_collapsed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sidebar_collapsed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeId,
    accentId,
    currencyCode,
    dateFormat,
    timeFormat,
    sidebarCollapsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_id')) {
      context.handle(
        _themeIdMeta,
        themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta),
      );
    }
    if (data.containsKey('accent_id')) {
      context.handle(
        _accentIdMeta,
        accentId.isAcceptableOrUnknown(data['accent_id']!, _accentIdMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('date_format')) {
      context.handle(
        _dateFormatMeta,
        dateFormat.isAcceptableOrUnknown(data['date_format']!, _dateFormatMeta),
      );
    }
    if (data.containsKey('time_format')) {
      context.handle(
        _timeFormatMeta,
        timeFormat.isAcceptableOrUnknown(data['time_format']!, _timeFormatMeta),
      );
    }
    if (data.containsKey('sidebar_collapsed')) {
      context.handle(
        _sidebarCollapsedMeta,
        sidebarCollapsed.isAcceptableOrUnknown(
          data['sidebar_collapsed']!,
          _sidebarCollapsedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_id'],
      )!,
      accentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      dateFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_format'],
      )!,
      timeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_format'],
      )!,
      sidebarCollapsed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sidebar_collapsed'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final int id;
  final String themeId;
  final String accentId;
  final String currencyCode;
  final String dateFormat;
  final String timeFormat;
  final bool sidebarCollapsed;
  const AppPreference({
    required this.id,
    required this.themeId,
    required this.accentId,
    required this.currencyCode,
    required this.dateFormat,
    required this.timeFormat,
    required this.sidebarCollapsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_id'] = Variable<String>(themeId);
    map['accent_id'] = Variable<String>(accentId);
    map['currency_code'] = Variable<String>(currencyCode);
    map['date_format'] = Variable<String>(dateFormat);
    map['time_format'] = Variable<String>(timeFormat);
    map['sidebar_collapsed'] = Variable<bool>(sidebarCollapsed);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      id: Value(id),
      themeId: Value(themeId),
      accentId: Value(accentId),
      currencyCode: Value(currencyCode),
      dateFormat: Value(dateFormat),
      timeFormat: Value(timeFormat),
      sidebarCollapsed: Value(sidebarCollapsed),
    );
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      id: serializer.fromJson<int>(json['id']),
      themeId: serializer.fromJson<String>(json['themeId']),
      accentId: serializer.fromJson<String>(json['accentId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      dateFormat: serializer.fromJson<String>(json['dateFormat']),
      timeFormat: serializer.fromJson<String>(json['timeFormat']),
      sidebarCollapsed: serializer.fromJson<bool>(json['sidebarCollapsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeId': serializer.toJson<String>(themeId),
      'accentId': serializer.toJson<String>(accentId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'dateFormat': serializer.toJson<String>(dateFormat),
      'timeFormat': serializer.toJson<String>(timeFormat),
      'sidebarCollapsed': serializer.toJson<bool>(sidebarCollapsed),
    };
  }

  AppPreference copyWith({
    int? id,
    String? themeId,
    String? accentId,
    String? currencyCode,
    String? dateFormat,
    String? timeFormat,
    bool? sidebarCollapsed,
  }) => AppPreference(
    id: id ?? this.id,
    themeId: themeId ?? this.themeId,
    accentId: accentId ?? this.accentId,
    currencyCode: currencyCode ?? this.currencyCode,
    dateFormat: dateFormat ?? this.dateFormat,
    timeFormat: timeFormat ?? this.timeFormat,
    sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
  );
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      id: data.id.present ? data.id.value : this.id,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      accentId: data.accentId.present ? data.accentId.value : this.accentId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      dateFormat: data.dateFormat.present
          ? data.dateFormat.value
          : this.dateFormat,
      timeFormat: data.timeFormat.present
          ? data.timeFormat.value
          : this.timeFormat,
      sidebarCollapsed: data.sidebarCollapsed.present
          ? data.sidebarCollapsed.value
          : this.sidebarCollapsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('id: $id, ')
          ..write('themeId: $themeId, ')
          ..write('accentId: $accentId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dateFormat: $dateFormat, ')
          ..write('timeFormat: $timeFormat, ')
          ..write('sidebarCollapsed: $sidebarCollapsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeId,
    accentId,
    currencyCode,
    dateFormat,
    timeFormat,
    sidebarCollapsed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.id == this.id &&
          other.themeId == this.themeId &&
          other.accentId == this.accentId &&
          other.currencyCode == this.currencyCode &&
          other.dateFormat == this.dateFormat &&
          other.timeFormat == this.timeFormat &&
          other.sidebarCollapsed == this.sidebarCollapsed);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<int> id;
  final Value<String> themeId;
  final Value<String> accentId;
  final Value<String> currencyCode;
  final Value<String> dateFormat;
  final Value<String> timeFormat;
  final Value<bool> sidebarCollapsed;
  const AppPreferencesCompanion({
    this.id = const Value.absent(),
    this.themeId = const Value.absent(),
    this.accentId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.dateFormat = const Value.absent(),
    this.timeFormat = const Value.absent(),
    this.sidebarCollapsed = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.themeId = const Value.absent(),
    this.accentId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.dateFormat = const Value.absent(),
    this.timeFormat = const Value.absent(),
    this.sidebarCollapsed = const Value.absent(),
  });
  static Insertable<AppPreference> custom({
    Expression<int>? id,
    Expression<String>? themeId,
    Expression<String>? accentId,
    Expression<String>? currencyCode,
    Expression<String>? dateFormat,
    Expression<String>? timeFormat,
    Expression<bool>? sidebarCollapsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeId != null) 'theme_id': themeId,
      if (accentId != null) 'accent_id': accentId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (dateFormat != null) 'date_format': dateFormat,
      if (timeFormat != null) 'time_format': timeFormat,
      if (sidebarCollapsed != null) 'sidebar_collapsed': sidebarCollapsed,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String>? themeId,
    Value<String>? accentId,
    Value<String>? currencyCode,
    Value<String>? dateFormat,
    Value<String>? timeFormat,
    Value<bool>? sidebarCollapsed,
  }) {
    return AppPreferencesCompanion(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      accentId: accentId ?? this.accentId,
      currencyCode: currencyCode ?? this.currencyCode,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (accentId.present) {
      map['accent_id'] = Variable<String>(accentId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (dateFormat.present) {
      map['date_format'] = Variable<String>(dateFormat.value);
    }
    if (timeFormat.present) {
      map['time_format'] = Variable<String>(timeFormat.value);
    }
    if (sidebarCollapsed.present) {
      map['sidebar_collapsed'] = Variable<bool>(sidebarCollapsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('themeId: $themeId, ')
          ..write('accentId: $accentId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dateFormat: $dateFormat, ')
          ..write('timeFormat: $timeFormat, ')
          ..write('sidebarCollapsed: $sidebarCollapsed')
          ..write(')'))
        .toString();
  }
}

class $DashboardCardsTable extends DashboardCards
    with TableInfo<$DashboardCardsTable, DashboardCardSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibleMeta = const VerificationMeta(
    'visible',
  );
  @override
  late final GeneratedColumn<bool> visible = GeneratedColumn<bool>(
    'visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _desktopSpanMeta = const VerificationMeta(
    'desktopSpan',
  );
  @override
  late final GeneratedColumn<int> desktopSpan = GeneratedColumn<int>(
    'desktop_span',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    position,
    visible,
    desktopSpan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboard_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<DashboardCardSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('visible')) {
      context.handle(
        _visibleMeta,
        visible.isAcceptableOrUnknown(data['visible']!, _visibleMeta),
      );
    }
    if (data.containsKey('desktop_span')) {
      context.handle(
        _desktopSpanMeta,
        desktopSpan.isAcceptableOrUnknown(
          data['desktop_span']!,
          _desktopSpanMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  DashboardCardSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardCardSetting(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      visible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}visible'],
      )!,
      desktopSpan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}desktop_span'],
      )!,
    );
  }

  @override
  $DashboardCardsTable createAlias(String alias) {
    return $DashboardCardsTable(attachedDatabase, alias);
  }
}

class DashboardCardSetting extends DataClass
    implements Insertable<DashboardCardSetting> {
  final String cardId;
  final int position;
  final bool visible;
  final int desktopSpan;
  const DashboardCardSetting({
    required this.cardId,
    required this.position,
    required this.visible,
    required this.desktopSpan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['position'] = Variable<int>(position);
    map['visible'] = Variable<bool>(visible);
    map['desktop_span'] = Variable<int>(desktopSpan);
    return map;
  }

  DashboardCardsCompanion toCompanion(bool nullToAbsent) {
    return DashboardCardsCompanion(
      cardId: Value(cardId),
      position: Value(position),
      visible: Value(visible),
      desktopSpan: Value(desktopSpan),
    );
  }

  factory DashboardCardSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardCardSetting(
      cardId: serializer.fromJson<String>(json['cardId']),
      position: serializer.fromJson<int>(json['position']),
      visible: serializer.fromJson<bool>(json['visible']),
      desktopSpan: serializer.fromJson<int>(json['desktopSpan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'position': serializer.toJson<int>(position),
      'visible': serializer.toJson<bool>(visible),
      'desktopSpan': serializer.toJson<int>(desktopSpan),
    };
  }

  DashboardCardSetting copyWith({
    String? cardId,
    int? position,
    bool? visible,
    int? desktopSpan,
  }) => DashboardCardSetting(
    cardId: cardId ?? this.cardId,
    position: position ?? this.position,
    visible: visible ?? this.visible,
    desktopSpan: desktopSpan ?? this.desktopSpan,
  );
  DashboardCardSetting copyWithCompanion(DashboardCardsCompanion data) {
    return DashboardCardSetting(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      position: data.position.present ? data.position.value : this.position,
      visible: data.visible.present ? data.visible.value : this.visible,
      desktopSpan: data.desktopSpan.present
          ? data.desktopSpan.value
          : this.desktopSpan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardCardSetting(')
          ..write('cardId: $cardId, ')
          ..write('position: $position, ')
          ..write('visible: $visible, ')
          ..write('desktopSpan: $desktopSpan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, position, visible, desktopSpan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardCardSetting &&
          other.cardId == this.cardId &&
          other.position == this.position &&
          other.visible == this.visible &&
          other.desktopSpan == this.desktopSpan);
}

class DashboardCardsCompanion extends UpdateCompanion<DashboardCardSetting> {
  final Value<String> cardId;
  final Value<int> position;
  final Value<bool> visible;
  final Value<int> desktopSpan;
  final Value<int> rowid;
  const DashboardCardsCompanion({
    this.cardId = const Value.absent(),
    this.position = const Value.absent(),
    this.visible = const Value.absent(),
    this.desktopSpan = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DashboardCardsCompanion.insert({
    required String cardId,
    required int position,
    this.visible = const Value.absent(),
    this.desktopSpan = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       position = Value(position);
  static Insertable<DashboardCardSetting> custom({
    Expression<String>? cardId,
    Expression<int>? position,
    Expression<bool>? visible,
    Expression<int>? desktopSpan,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (position != null) 'position': position,
      if (visible != null) 'visible': visible,
      if (desktopSpan != null) 'desktop_span': desktopSpan,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DashboardCardsCompanion copyWith({
    Value<String>? cardId,
    Value<int>? position,
    Value<bool>? visible,
    Value<int>? desktopSpan,
    Value<int>? rowid,
  }) {
    return DashboardCardsCompanion(
      cardId: cardId ?? this.cardId,
      position: position ?? this.position,
      visible: visible ?? this.visible,
      desktopSpan: desktopSpan ?? this.desktopSpan,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (visible.present) {
      map['visible'] = Variable<bool>(visible.value);
    }
    if (desktopSpan.present) {
      map['desktop_span'] = Variable<int>(desktopSpan.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardCardsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('position: $position, ')
          ..write('visible: $visible, ')
          ..write('desktopSpan: $desktopSpan, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String key;
  final String value;
  const SyncMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetadataData copyWith({String? key, String? value}) =>
      SyncMetadataData(key: key ?? this.key, value: value ?? this.value);
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPendingChangesTable extends SyncPendingChanges
    with TableInfo<$SyncPendingChangesTable, SyncPendingChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPendingChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enqueuedAtMeta = const VerificationMeta(
    'enqueuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> enqueuedAt = GeneratedColumn<DateTime>(
    'enqueued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    changeId,
    payloadJson,
    baseRevision,
    enqueuedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_pending_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPendingChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('enqueued_at')) {
      context.handle(
        _enqueuedAtMeta,
        enqueuedAt.isAcceptableOrUnknown(data['enqueued_at']!, _enqueuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enqueuedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncPendingChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPendingChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
      enqueuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enqueued_at'],
      )!,
    );
  }

  @override
  $SyncPendingChangesTable createAlias(String alias) {
    return $SyncPendingChangesTable(attachedDatabase, alias);
  }
}

class SyncPendingChange extends DataClass
    implements Insertable<SyncPendingChange> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String changeId;
  final String payloadJson;
  final int? baseRevision;
  final DateTime enqueuedAt;
  const SyncPendingChange({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.changeId,
    required this.payloadJson,
    this.baseRevision,
    required this.enqueuedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['change_id'] = Variable<String>(changeId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    map['enqueued_at'] = Variable<DateTime>(enqueuedAt);
    return map;
  }

  SyncPendingChangesCompanion toCompanion(bool nullToAbsent) {
    return SyncPendingChangesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      changeId: Value(changeId),
      payloadJson: Value(payloadJson),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
      enqueuedAt: Value(enqueuedAt),
    );
  }

  factory SyncPendingChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPendingChange(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      changeId: serializer.fromJson<String>(json['changeId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
      enqueuedAt: serializer.fromJson<DateTime>(json['enqueuedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'changeId': serializer.toJson<String>(changeId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'baseRevision': serializer.toJson<int?>(baseRevision),
      'enqueuedAt': serializer.toJson<DateTime>(enqueuedAt),
    };
  }

  SyncPendingChange copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? changeId,
    String? payloadJson,
    Value<int?> baseRevision = const Value.absent(),
    DateTime? enqueuedAt,
  }) => SyncPendingChange(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    changeId: changeId ?? this.changeId,
    payloadJson: payloadJson ?? this.payloadJson,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
    enqueuedAt: enqueuedAt ?? this.enqueuedAt,
  );
  SyncPendingChange copyWithCompanion(SyncPendingChangesCompanion data) {
    return SyncPendingChange(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      enqueuedAt: data.enqueuedAt.present
          ? data.enqueuedAt.value
          : this.enqueuedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPendingChange(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('changeId: $changeId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('enqueuedAt: $enqueuedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    changeId,
    payloadJson,
    baseRevision,
    enqueuedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPendingChange &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.changeId == this.changeId &&
          other.payloadJson == this.payloadJson &&
          other.baseRevision == this.baseRevision &&
          other.enqueuedAt == this.enqueuedAt);
}

class SyncPendingChangesCompanion extends UpdateCompanion<SyncPendingChange> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> changeId;
  final Value<String> payloadJson;
  final Value<int?> baseRevision;
  final Value<DateTime> enqueuedAt;
  final Value<int> rowid;
  const SyncPendingChangesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.changeId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.enqueuedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPendingChangesCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    this.changeId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.baseRevision = const Value.absent(),
    required DateTime enqueuedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       enqueuedAt = Value(enqueuedAt);
  static Insertable<SyncPendingChange> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? changeId,
    Expression<String>? payloadJson,
    Expression<int>? baseRevision,
    Expression<DateTime>? enqueuedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (changeId != null) 'change_id': changeId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (enqueuedAt != null) 'enqueued_at': enqueuedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPendingChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? changeId,
    Value<String>? payloadJson,
    Value<int?>? baseRevision,
    Value<DateTime>? enqueuedAt,
    Value<int>? rowid,
  }) {
    return SyncPendingChangesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      changeId: changeId ?? this.changeId,
      payloadJson: payloadJson ?? this.payloadJson,
      baseRevision: baseRevision ?? this.baseRevision,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (enqueuedAt.present) {
      map['enqueued_at'] = Variable<DateTime>(enqueuedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPendingChangesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('changeId: $changeId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadJsonMeta = const VerificationMeta(
    'localPayloadJson',
  );
  @override
  late final GeneratedColumn<String> localPayloadJson = GeneratedColumn<String>(
    'local_payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePayloadJsonMeta = const VerificationMeta(
    'remotePayloadJson',
  );
  @override
  late final GeneratedColumn<String> remotePayloadJson =
      GeneratedColumn<String>(
        'remote_payload_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    localPayloadJson,
    remotePayloadJson,
    remoteRevision,
    detectedAt,
    resolution,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_payload_json')) {
      context.handle(
        _localPayloadJsonMeta,
        localPayloadJson.isAcceptableOrUnknown(
          data['local_payload_json']!,
          _localPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadJsonMeta);
    }
    if (data.containsKey('remote_payload_json')) {
      context.handle(
        _remotePayloadJsonMeta,
        remotePayloadJson.isAcceptableOrUnknown(
          data['remote_payload_json']!,
          _remotePayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remotePayloadJsonMeta);
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteRevisionMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload_json'],
      )!,
      remotePayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_payload_json'],
      )!,
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String entityType;
  final String entityId;
  final String localPayloadJson;
  final String remotePayloadJson;
  final int remoteRevision;
  final DateTime detectedAt;
  final String? resolution;
  final DateTime? resolvedAt;
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localPayloadJson,
    required this.remotePayloadJson,
    required this.remoteRevision,
    required this.detectedAt,
    this.resolution,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_payload_json'] = Variable<String>(localPayloadJson);
    map['remote_payload_json'] = Variable<String>(remotePayloadJson);
    map['remote_revision'] = Variable<int>(remoteRevision);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localPayloadJson: Value(localPayloadJson),
      remotePayloadJson: Value(remotePayloadJson),
      remoteRevision: Value(remoteRevision),
      detectedAt: Value(detectedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localPayloadJson: serializer.fromJson<String>(json['localPayloadJson']),
      remotePayloadJson: serializer.fromJson<String>(json['remotePayloadJson']),
      remoteRevision: serializer.fromJson<int>(json['remoteRevision']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localPayloadJson': serializer.toJson<String>(localPayloadJson),
      'remotePayloadJson': serializer.toJson<String>(remotePayloadJson),
      'remoteRevision': serializer.toJson<int>(remoteRevision),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolution': serializer.toJson<String?>(resolution),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? localPayloadJson,
    String? remotePayloadJson,
    int? remoteRevision,
    DateTime? detectedAt,
    Value<String?> resolution = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflict(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localPayloadJson: localPayloadJson ?? this.localPayloadJson,
    remotePayloadJson: remotePayloadJson ?? this.remotePayloadJson,
    remoteRevision: remoteRevision ?? this.remoteRevision,
    detectedAt: detectedAt ?? this.detectedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localPayloadJson: data.localPayloadJson.present
          ? data.localPayloadJson.value
          : this.localPayloadJson,
      remotePayloadJson: data.remotePayloadJson.present
          ? data.remotePayloadJson.value
          : this.remotePayloadJson,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('remotePayloadJson: $remotePayloadJson, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolution: $resolution, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    localPayloadJson,
    remotePayloadJson,
    remoteRevision,
    detectedAt,
    resolution,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localPayloadJson == this.localPayloadJson &&
          other.remotePayloadJson == this.remotePayloadJson &&
          other.remoteRevision == this.remoteRevision &&
          other.detectedAt == this.detectedAt &&
          other.resolution == this.resolution &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localPayloadJson;
  final Value<String> remotePayloadJson;
  final Value<int> remoteRevision;
  final Value<DateTime> detectedAt;
  final Value<String?> resolution;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localPayloadJson = const Value.absent(),
    this.remotePayloadJson = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String localPayloadJson,
    required String remotePayloadJson,
    required int remoteRevision,
    required DateTime detectedAt,
    this.resolution = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localPayloadJson = Value(localPayloadJson),
       remotePayloadJson = Value(remotePayloadJson),
       remoteRevision = Value(remoteRevision),
       detectedAt = Value(detectedAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localPayloadJson,
    Expression<String>? remotePayloadJson,
    Expression<int>? remoteRevision,
    Expression<DateTime>? detectedAt,
    Expression<String>? resolution,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localPayloadJson != null) 'local_payload_json': localPayloadJson,
      if (remotePayloadJson != null) 'remote_payload_json': remotePayloadJson,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolution != null) 'resolution': resolution,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localPayloadJson,
    Value<String>? remotePayloadJson,
    Value<int>? remoteRevision,
    Value<DateTime>? detectedAt,
    Value<String?>? resolution,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localPayloadJson: localPayloadJson ?? this.localPayloadJson,
      remotePayloadJson: remotePayloadJson ?? this.remotePayloadJson,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      detectedAt: detectedAt ?? this.detectedAt,
      resolution: resolution ?? this.resolution,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localPayloadJson.present) {
      map['local_payload_json'] = Variable<String>(localPayloadJson.value);
    }
    if (remotePayloadJson.present) {
      map['remote_payload_json'] = Variable<String>(remotePayloadJson.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('remotePayloadJson: $remotePayloadJson, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolution: $resolution, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityRecordsTable extends ActivityRecords
    with TableInfo<$ActivityRecordsTable, ActivityRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    recordDate,
    title,
    value,
    unit,
    status,
    notes,
    metadataJson,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $ActivityRecordsTable createAlias(String alias) {
    return $ActivityRecordsTable(attachedDatabase, alias);
  }
}

class ActivityRecord extends DataClass implements Insertable<ActivityRecord> {
  final String id;
  final String kind;
  final DateTime recordDate;
  final String title;
  final int? value;
  final String? unit;
  final String? status;
  final String notes;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const ActivityRecord({
    required this.id,
    required this.kind,
    required this.recordDate,
    required this.title,
    this.value,
    this.unit,
    this.status,
    required this.notes,
    required this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['record_date'] = Variable<DateTime>(recordDate);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<int>(value);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['notes'] = Variable<String>(notes);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ActivityRecordsCompanion toCompanion(bool nullToAbsent) {
    return ActivityRecordsCompanion(
      id: Value(id),
      kind: Value(kind),
      recordDate: Value(recordDate),
      title: Value(title),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      notes: Value(notes),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory ActivityRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRecord(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      title: serializer.fromJson<String>(json['title']),
      value: serializer.fromJson<int?>(json['value']),
      unit: serializer.fromJson<String?>(json['unit']),
      status: serializer.fromJson<String?>(json['status']),
      notes: serializer.fromJson<String>(json['notes']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'title': serializer.toJson<String>(title),
      'value': serializer.toJson<int?>(value),
      'unit': serializer.toJson<String?>(unit),
      'status': serializer.toJson<String?>(status),
      'notes': serializer.toJson<String>(notes),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  ActivityRecord copyWith({
    String? id,
    String? kind,
    DateTime? recordDate,
    String? title,
    Value<int?> value = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> status = const Value.absent(),
    String? notes,
    String? metadataJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => ActivityRecord(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    recordDate: recordDate ?? this.recordDate,
    title: title ?? this.title,
    value: value.present ? value.value : this.value,
    unit: unit.present ? unit.value : this.unit,
    status: status.present ? status.value : this.status,
    notes: notes ?? this.notes,
    metadataJson: metadataJson ?? this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  ActivityRecord copyWithCompanion(ActivityRecordsCompanion data) {
    return ActivityRecord(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      title: data.title.present ? data.title.value : this.title,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRecord(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('recordDate: $recordDate, ')
          ..write('title: $title, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    recordDate,
    title,
    value,
    unit,
    status,
    notes,
    metadataJson,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRecord &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.recordDate == this.recordDate &&
          other.title == this.title &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class ActivityRecordsCompanion extends UpdateCompanion<ActivityRecord> {
  final Value<String> id;
  final Value<String> kind;
  final Value<DateTime> recordDate;
  final Value<String> title;
  final Value<int?> value;
  final Value<String?> unit;
  final Value<String?> status;
  final Value<String> notes;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const ActivityRecordsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.title = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityRecordsCompanion.insert({
    required String id,
    required String kind,
    required DateTime recordDate,
    required String title,
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       recordDate = Value(recordDate),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityRecord> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<DateTime>? recordDate,
    Expression<String>? title,
    Expression<int>? value,
    Expression<String>? unit,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (recordDate != null) 'record_date': recordDate,
      if (title != null) 'title': title,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<DateTime>? recordDate,
    Value<String>? title,
    Value<int?>? value,
    Value<String?>? unit,
    Value<String?>? status,
    Value<String>? notes,
    Value<String>? metadataJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return ActivityRecordsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      recordDate: recordDate ?? this.recordDate,
      title: title ?? this.title,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRecordsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('recordDate: $recordDate, ')
          ..write('title: $title, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Personal'),
  );
  static const VerificationMeta _trackingTypeMeta = const VerificationMeta(
    'trackingType',
  );
  @override
  late final GeneratedColumn<String> trackingType = GeneratedColumn<String>(
    'tracking_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completion'),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scheduleDaysMeta = const VerificationMeta(
    'scheduleDays',
  );
  @override
  late final GeneratedColumn<String> scheduleDays = GeneratedColumn<String>(
    'schedule_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6,7'),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReductionMeta = const VerificationMeta(
    'isReduction',
  );
  @override
  late final GeneratedColumn<bool> isReduction = GeneratedColumn<bool>(
    'is_reduction',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reduction" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    category,
    trackingType,
    unit,
    scheduleDays,
    target,
    isReduction,
    isArchived,
    startDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('tracking_type')) {
      context.handle(
        _trackingTypeMeta,
        trackingType.isAcceptableOrUnknown(
          data['tracking_type']!,
          _trackingTypeMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('schedule_days')) {
      context.handle(
        _scheduleDaysMeta,
        scheduleDays.isAcceptableOrUnknown(
          data['schedule_days']!,
          _scheduleDaysMeta,
        ),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('is_reduction')) {
      context.handle(
        _isReductionMeta,
        isReduction.isAcceptableOrUnknown(
          data['is_reduction']!,
          _isReductionMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      trackingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_type'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      scheduleDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_days'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      ),
      isReduction: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reduction'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final String name;
  final String description;
  final String category;
  final String trackingType;
  final String unit;
  final String scheduleDays;
  final int? target;
  final bool isReduction;
  final bool isArchived;
  final DateTime startDate;
  final DateTime createdAt;
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.trackingType,
    required this.unit,
    required this.scheduleDays,
    this.target,
    required this.isReduction,
    required this.isArchived,
    required this.startDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['tracking_type'] = Variable<String>(trackingType);
    map['unit'] = Variable<String>(unit);
    map['schedule_days'] = Variable<String>(scheduleDays);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<int>(target);
    }
    map['is_reduction'] = Variable<bool>(isReduction);
    map['is_archived'] = Variable<bool>(isArchived);
    map['start_date'] = Variable<DateTime>(startDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      category: Value(category),
      trackingType: Value(trackingType),
      unit: Value(unit),
      scheduleDays: Value(scheduleDays),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      isReduction: Value(isReduction),
      isArchived: Value(isArchived),
      startDate: Value(startDate),
      createdAt: Value(createdAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      trackingType: serializer.fromJson<String>(json['trackingType']),
      unit: serializer.fromJson<String>(json['unit']),
      scheduleDays: serializer.fromJson<String>(json['scheduleDays']),
      target: serializer.fromJson<int?>(json['target']),
      isReduction: serializer.fromJson<bool>(json['isReduction']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'trackingType': serializer.toJson<String>(trackingType),
      'unit': serializer.toJson<String>(unit),
      'scheduleDays': serializer.toJson<String>(scheduleDays),
      'target': serializer.toJson<int?>(target),
      'isReduction': serializer.toJson<bool>(isReduction),
      'isArchived': serializer.toJson<bool>(isArchived),
      'startDate': serializer.toJson<DateTime>(startDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? trackingType,
    String? unit,
    String? scheduleDays,
    Value<int?> target = const Value.absent(),
    bool? isReduction,
    bool? isArchived,
    DateTime? startDate,
    DateTime? createdAt,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    category: category ?? this.category,
    trackingType: trackingType ?? this.trackingType,
    unit: unit ?? this.unit,
    scheduleDays: scheduleDays ?? this.scheduleDays,
    target: target.present ? target.value : this.target,
    isReduction: isReduction ?? this.isReduction,
    isArchived: isArchived ?? this.isArchived,
    startDate: startDate ?? this.startDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      trackingType: data.trackingType.present
          ? data.trackingType.value
          : this.trackingType,
      unit: data.unit.present ? data.unit.value : this.unit,
      scheduleDays: data.scheduleDays.present
          ? data.scheduleDays.value
          : this.scheduleDays,
      target: data.target.present ? data.target.value : this.target,
      isReduction: data.isReduction.present
          ? data.isReduction.value
          : this.isReduction,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('trackingType: $trackingType, ')
          ..write('unit: $unit, ')
          ..write('scheduleDays: $scheduleDays, ')
          ..write('target: $target, ')
          ..write('isReduction: $isReduction, ')
          ..write('isArchived: $isArchived, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    category,
    trackingType,
    unit,
    scheduleDays,
    target,
    isReduction,
    isArchived,
    startDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.category == this.category &&
          other.trackingType == this.trackingType &&
          other.unit == this.unit &&
          other.scheduleDays == this.scheduleDays &&
          other.target == this.target &&
          other.isReduction == this.isReduction &&
          other.isArchived == this.isArchived &&
          other.startDate == this.startDate &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> category;
  final Value<String> trackingType;
  final Value<String> unit;
  final Value<String> scheduleDays;
  final Value<int?> target;
  final Value<bool> isReduction;
  final Value<bool> isArchived;
  final Value<DateTime> startDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.unit = const Value.absent(),
    this.scheduleDays = const Value.absent(),
    this.target = const Value.absent(),
    this.isReduction = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.startDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.unit = const Value.absent(),
    this.scheduleDays = const Value.absent(),
    this.target = const Value.absent(),
    this.isReduction = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime startDate,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? trackingType,
    Expression<String>? unit,
    Expression<String>? scheduleDays,
    Expression<int>? target,
    Expression<bool>? isReduction,
    Expression<bool>? isArchived,
    Expression<DateTime>? startDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (trackingType != null) 'tracking_type': trackingType,
      if (unit != null) 'unit': unit,
      if (scheduleDays != null) 'schedule_days': scheduleDays,
      if (target != null) 'target': target,
      if (isReduction != null) 'is_reduction': isReduction,
      if (isArchived != null) 'is_archived': isArchived,
      if (startDate != null) 'start_date': startDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? category,
    Value<String>? trackingType,
    Value<String>? unit,
    Value<String>? scheduleDays,
    Value<int?>? target,
    Value<bool>? isReduction,
    Value<bool>? isArchived,
    Value<DateTime>? startDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      trackingType: trackingType ?? this.trackingType,
      unit: unit ?? this.unit,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      target: target ?? this.target,
      isReduction: isReduction ?? this.isReduction,
      isArchived: isArchived ?? this.isArchived,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (trackingType.present) {
      map['tracking_type'] = Variable<String>(trackingType.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (scheduleDays.present) {
      map['schedule_days'] = Variable<String>(scheduleDays.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (isReduction.present) {
      map['is_reduction'] = Variable<bool>(isReduction.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('trackingType: $trackingType, ')
          ..write('unit: $unit, ')
          ..write('scheduleDays: $scheduleDays, ')
          ..write('target: $target, ')
          ..write('isReduction: $isReduction, ')
          ..write('isArchived: $isArchived, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitOccurrencesTable extends HabitOccurrences
    with TableInfo<$HabitOccurrencesTable, HabitOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>(
        'occurrence_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numericValueMeta = const VerificationMeta(
    'numericValue',
  );
  @override
  late final GeneratedColumn<int> numericValue = GeneratedColumn<int>(
    'numeric_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    occurrenceDate,
    status,
    numericValue,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
        _numericValueMeta,
        numericValue.isAcceptableOrUnknown(
          data['numeric_value']!,
          _numericValueMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurrence_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      numericValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numeric_value'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HabitOccurrencesTable createAlias(String alias) {
    return $HabitOccurrencesTable(attachedDatabase, alias);
  }
}

class HabitOccurrence extends DataClass implements Insertable<HabitOccurrence> {
  final String id;
  final String habitId;
  final DateTime occurrenceDate;
  final String status;
  final int? numericValue;
  final String notes;
  final DateTime updatedAt;
  const HabitOccurrence({
    required this.id,
    required this.habitId,
    required this.occurrenceDate,
    required this.status,
    this.numericValue,
    required this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<int>(numericValue);
    }
    map['notes'] = Variable<String>(notes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HabitOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return HabitOccurrencesCompanion(
      id: Value(id),
      habitId: Value(habitId),
      occurrenceDate: Value(occurrenceDate),
      status: Value(status),
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
      notes: Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory HabitOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitOccurrence(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      occurrenceDate: serializer.fromJson<DateTime>(json['occurrenceDate']),
      status: serializer.fromJson<String>(json['status']),
      numericValue: serializer.fromJson<int?>(json['numericValue']),
      notes: serializer.fromJson<String>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'occurrenceDate': serializer.toJson<DateTime>(occurrenceDate),
      'status': serializer.toJson<String>(status),
      'numericValue': serializer.toJson<int?>(numericValue),
      'notes': serializer.toJson<String>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HabitOccurrence copyWith({
    String? id,
    String? habitId,
    DateTime? occurrenceDate,
    String? status,
    Value<int?> numericValue = const Value.absent(),
    String? notes,
    DateTime? updatedAt,
  }) => HabitOccurrence(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    status: status ?? this.status,
    numericValue: numericValue.present ? numericValue.value : this.numericValue,
    notes: notes ?? this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HabitOccurrence copyWithCompanion(HabitOccurrencesCompanion data) {
    return HabitOccurrence(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      status: data.status.present ? data.status.value : this.status,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitOccurrence(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('status: $status, ')
          ..write('numericValue: $numericValue, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    occurrenceDate,
    status,
    numericValue,
    notes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitOccurrence &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.status == this.status &&
          other.numericValue == this.numericValue &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class HabitOccurrencesCompanion extends UpdateCompanion<HabitOccurrence> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> occurrenceDate;
  final Value<String> status;
  final Value<int?> numericValue;
  final Value<String> notes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HabitOccurrencesCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.status = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitOccurrencesCompanion.insert({
    required String id,
    required String habitId,
    required DateTime occurrenceDate,
    required String status,
    this.numericValue = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       occurrenceDate = Value(occurrenceDate),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<HabitOccurrence> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? occurrenceDate,
    Expression<String>? status,
    Expression<int>? numericValue,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (status != null) 'status': status,
      if (numericValue != null) 'numeric_value': numericValue,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? occurrenceDate,
    Value<String>? status,
    Value<int?>? numericValue,
    Value<String>? notes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HabitOccurrencesCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      status: status ?? this.status,
      numericValue: numericValue ?? this.numericValue,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<int>(numericValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('status: $status, ')
          ..write('numericValue: $numericValue, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeframeMeta = const VerificationMeta(
    'timeframe',
  );
  @override
  late final GeneratedColumn<String> timeframe = GeneratedColumn<String>(
    'timeframe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Long-term'),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('steps'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Active'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    timeframe,
    target,
    progress,
    unit,
    dueDate,
    status,
    notes,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('timeframe')) {
      context.handle(
        _timeframeMeta,
        timeframe.isAcceptableOrUnknown(data['timeframe']!, _timeframeMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timeframe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeframe'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String name;
  final String timeframe;
  final int? target;
  final int progress;
  final String unit;
  final DateTime? dueDate;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const Goal({
    required this.id,
    required this.name,
    required this.timeframe,
    this.target,
    required this.progress,
    required this.unit,
    this.dueDate,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['timeframe'] = Variable<String>(timeframe);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<int>(target);
    }
    map['progress'] = Variable<int>(progress);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      timeframe: Value(timeframe),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      progress: Value(progress),
      unit: Value(unit),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      timeframe: serializer.fromJson<String>(json['timeframe']),
      target: serializer.fromJson<int?>(json['target']),
      progress: serializer.fromJson<int>(json['progress']),
      unit: serializer.fromJson<String>(json['unit']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'timeframe': serializer.toJson<String>(timeframe),
      'target': serializer.toJson<int?>(target),
      'progress': serializer.toJson<int>(progress),
      'unit': serializer.toJson<String>(unit),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Goal copyWith({
    String? id,
    String? name,
    String? timeframe,
    Value<int?> target = const Value.absent(),
    int? progress,
    String? unit,
    Value<DateTime?> dueDate = const Value.absent(),
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    timeframe: timeframe ?? this.timeframe,
    target: target.present ? target.value : this.target,
    progress: progress ?? this.progress,
    unit: unit ?? this.unit,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      timeframe: data.timeframe.present ? data.timeframe.value : this.timeframe,
      target: data.target.present ? data.target.value : this.target,
      progress: data.progress.present ? data.progress.value : this.progress,
      unit: data.unit.present ? data.unit.value : this.unit,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timeframe: $timeframe, ')
          ..write('target: $target, ')
          ..write('progress: $progress, ')
          ..write('unit: $unit, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    timeframe,
    target,
    progress,
    unit,
    dueDate,
    status,
    notes,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.timeframe == this.timeframe &&
          other.target == this.target &&
          other.progress == this.progress &&
          other.unit == this.unit &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> timeframe;
  final Value<int?> target;
  final Value<int> progress;
  final Value<String> unit;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timeframe = const Value.absent(),
    this.target = const Value.absent(),
    this.progress = const Value.absent(),
    this.unit = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String name,
    this.timeframe = const Value.absent(),
    this.target = const Value.absent(),
    this.progress = const Value.absent(),
    this.unit = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? timeframe,
    Expression<int>? target,
    Expression<int>? progress,
    Expression<String>? unit,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timeframe != null) 'timeframe': timeframe,
      if (target != null) 'target': target,
      if (progress != null) 'progress': progress,
      if (unit != null) 'unit': unit,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? timeframe,
    Value<int?>? target,
    Value<int>? progress,
    Value<String>? unit,
    Value<DateTime?>? dueDate,
    Value<String>? status,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timeframe: timeframe ?? this.timeframe,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      unit: unit ?? this.unit,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timeframe.present) {
      map['timeframe'] = Variable<String>(timeframe.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timeframe: $timeframe, ')
          ..write('target: $target, ')
          ..write('progress: $progress, ')
          ..write('unit: $unit, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Monthly'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    amountMinor,
    period,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String category;
  final int amountMinor;
  final String period;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Budget({
    required this.id,
    required this.category,
    required this.amountMinor,
    required this.period,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['period'] = Variable<String>(period);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      category: Value(category),
      amountMinor: Value(amountMinor),
      period: Value(period),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      period: serializer.fromJson<String>(json['period']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'period': serializer.toJson<String>(period),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Budget copyWith({
    String? id,
    String? category,
    int? amountMinor,
    String? period,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Budget(
    id: id ?? this.id,
    category: category ?? this.category,
    amountMinor: amountMinor ?? this.amountMinor,
    period: period ?? this.period,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      period: data.period.present ? data.period.value : this.period,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('period: $period, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, category, amountMinor, period, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.category == this.category &&
          other.amountMinor == this.amountMinor &&
          other.period == this.period &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> category;
  final Value<int> amountMinor;
  final Value<String> period;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.period = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String category,
    required int amountMinor,
    this.period = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       amountMinor = Value(amountMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<int>? amountMinor,
    Expression<String>? period,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (period != null) 'period': period,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<int>? amountMinor,
    Value<String>? period,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      amountMinor: amountMinor ?? this.amountMinor,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('period: $period, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LifeOsDatabase extends GeneratedDatabase {
  _$LifeOsDatabase(QueryExecutor e) : super(e);
  $LifeOsDatabaseManager get managers => $LifeOsDatabaseManager(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $DashboardCardsTable dashboardCards = $DashboardCardsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $SyncPendingChangesTable syncPendingChanges =
      $SyncPendingChangesTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $ActivityRecordsTable activityRecords = $ActivityRecordsTable(
    this,
  );
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitOccurrencesTable habitOccurrences = $HabitOccurrencesTable(
    this,
  );
  late final $GoalsTable goals = $GoalsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appPreferences,
    dashboardCards,
    syncMetadata,
    syncPendingChanges,
    syncConflicts,
    activityRecords,
    habits,
    habitOccurrences,
    goals,
    budgets,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_occurrences', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<int> id,
      Value<String> themeId,
      Value<String> accentId,
      Value<String> currencyCode,
      Value<String> dateFormat,
      Value<String> timeFormat,
      Value<bool> sidebarCollapsed,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<int> id,
      Value<String> themeId,
      Value<String> accentId,
      Value<String> currencyCode,
      Value<String> dateFormat,
      Value<String> timeFormat,
      Value<bool> sidebarCollapsed,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accentId => $composableBuilder(
    column: $table.accentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateFormat => $composableBuilder(
    column: $table.dateFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeFormat => $composableBuilder(
    column: $table.timeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sidebarCollapsed => $composableBuilder(
    column: $table.sidebarCollapsed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentId => $composableBuilder(
    column: $table.accentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateFormat => $composableBuilder(
    column: $table.dateFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeFormat => $composableBuilder(
    column: $table.timeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sidebarCollapsed => $composableBuilder(
    column: $table.sidebarCollapsed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<String> get accentId =>
      $composableBuilder(column: $table.accentId, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateFormat => $composableBuilder(
    column: $table.dateFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeFormat => $composableBuilder(
    column: $table.timeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sidebarCollapsed => $composableBuilder(
    column: $table.sidebarCollapsed,
    builder: (column) => column,
  );
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<
              _$LifeOsDatabase,
              $AppPreferencesTable,
              AppPreference
            >,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$LifeOsDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<String> accentId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> dateFormat = const Value.absent(),
                Value<String> timeFormat = const Value.absent(),
                Value<bool> sidebarCollapsed = const Value.absent(),
              }) => AppPreferencesCompanion(
                id: id,
                themeId: themeId,
                accentId: accentId,
                currencyCode: currencyCode,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                sidebarCollapsed: sidebarCollapsed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<String> accentId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> dateFormat = const Value.absent(),
                Value<String> timeFormat = const Value.absent(),
                Value<bool> sidebarCollapsed = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                id: id,
                themeId: themeId,
                accentId: accentId,
                currencyCode: currencyCode,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                sidebarCollapsed: sidebarCollapsed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppPreferencesTable, AppPreference>(table),
                  BaseReferences<
                    _$LifeOsDatabase,
                    $AppPreferencesTable,
                    AppPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$LifeOsDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;
typedef $$DashboardCardsTableCreateCompanionBuilder =
    DashboardCardsCompanion Function({
      required String cardId,
      required int position,
      Value<bool> visible,
      Value<int> desktopSpan,
      Value<int> rowid,
    });
typedef $$DashboardCardsTableUpdateCompanionBuilder =
    DashboardCardsCompanion Function({
      Value<String> cardId,
      Value<int> position,
      Value<bool> visible,
      Value<int> desktopSpan,
      Value<int> rowid,
    });

class $$DashboardCardsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $DashboardCardsTable> {
  $$DashboardCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get visible => $composableBuilder(
    column: $table.visible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get desktopSpan => $composableBuilder(
    column: $table.desktopSpan,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DashboardCardsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $DashboardCardsTable> {
  $$DashboardCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get visible => $composableBuilder(
    column: $table.visible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get desktopSpan => $composableBuilder(
    column: $table.desktopSpan,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DashboardCardsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $DashboardCardsTable> {
  $$DashboardCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get visible =>
      $composableBuilder(column: $table.visible, builder: (column) => column);

  GeneratedColumn<int> get desktopSpan => $composableBuilder(
    column: $table.desktopSpan,
    builder: (column) => column,
  );
}

class $$DashboardCardsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $DashboardCardsTable,
          DashboardCardSetting,
          $$DashboardCardsTableFilterComposer,
          $$DashboardCardsTableOrderingComposer,
          $$DashboardCardsTableAnnotationComposer,
          $$DashboardCardsTableCreateCompanionBuilder,
          $$DashboardCardsTableUpdateCompanionBuilder,
          (
            DashboardCardSetting,
            BaseReferences<
              _$LifeOsDatabase,
              $DashboardCardsTable,
              DashboardCardSetting
            >,
          ),
          DashboardCardSetting,
          PrefetchHooks Function()
        > {
  $$DashboardCardsTableTableManager(
    _$LifeOsDatabase db,
    $DashboardCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashboardCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> visible = const Value.absent(),
                Value<int> desktopSpan = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DashboardCardsCompanion(
                cardId: cardId,
                position: position,
                visible: visible,
                desktopSpan: desktopSpan,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required int position,
                Value<bool> visible = const Value.absent(),
                Value<int> desktopSpan = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DashboardCardsCompanion.insert(
                cardId: cardId,
                position: position,
                visible: visible,
                desktopSpan: desktopSpan,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DashboardCardsTable, DashboardCardSetting>(
                    table,
                  ),
                  BaseReferences<
                    _$LifeOsDatabase,
                    $DashboardCardsTable,
                    DashboardCardSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DashboardCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $DashboardCardsTable,
      DashboardCardSetting,
      $$DashboardCardsTableFilterComposer,
      $$DashboardCardsTableOrderingComposer,
      $$DashboardCardsTableAnnotationComposer,
      $$DashboardCardsTableCreateCompanionBuilder,
      $$DashboardCardsTableUpdateCompanionBuilder,
      (
        DashboardCardSetting,
        BaseReferences<
          _$LifeOsDatabase,
          $DashboardCardsTable,
          DashboardCardSetting
        >,
      ),
      DashboardCardSetting,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$LifeOsDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<
              _$LifeOsDatabase,
              $SyncMetadataTable,
              SyncMetadataData
            >,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$LifeOsDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetadataTable, SyncMetadataData>(table),
                  BaseReferences<
                    _$LifeOsDatabase,
                    $SyncMetadataTable,
                    SyncMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$LifeOsDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$SyncPendingChangesTableCreateCompanionBuilder =
    SyncPendingChangesCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String operation,
      Value<String> changeId,
      Value<String> payloadJson,
      Value<int?> baseRevision,
      required DateTime enqueuedAt,
      Value<int> rowid,
    });
typedef $$SyncPendingChangesTableUpdateCompanionBuilder =
    SyncPendingChangesCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> changeId,
      Value<String> payloadJson,
      Value<int?> baseRevision,
      Value<DateTime> enqueuedAt,
      Value<int> rowid,
    });

class $$SyncPendingChangesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $SyncPendingChangesTable> {
  $$SyncPendingChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncPendingChangesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $SyncPendingChangesTable> {
  $$SyncPendingChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPendingChangesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $SyncPendingChangesTable> {
  $$SyncPendingChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => column,
  );
}

class $$SyncPendingChangesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $SyncPendingChangesTable,
          SyncPendingChange,
          $$SyncPendingChangesTableFilterComposer,
          $$SyncPendingChangesTableOrderingComposer,
          $$SyncPendingChangesTableAnnotationComposer,
          $$SyncPendingChangesTableCreateCompanionBuilder,
          $$SyncPendingChangesTableUpdateCompanionBuilder,
          (
            SyncPendingChange,
            BaseReferences<
              _$LifeOsDatabase,
              $SyncPendingChangesTable,
              SyncPendingChange
            >,
          ),
          SyncPendingChange,
          PrefetchHooks Function()
        > {
  $$SyncPendingChangesTableTableManager(
    _$LifeOsDatabase db,
    $SyncPendingChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPendingChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPendingChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPendingChangesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> changeId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<DateTime> enqueuedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPendingChangesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                changeId: changeId,
                payloadJson: payloadJson,
                baseRevision: baseRevision,
                enqueuedAt: enqueuedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                Value<String> changeId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                required DateTime enqueuedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncPendingChangesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                changeId: changeId,
                payloadJson: payloadJson,
                baseRevision: baseRevision,
                enqueuedAt: enqueuedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncPendingChangesTable, SyncPendingChange>(
                    table,
                  ),
                  BaseReferences<
                    _$LifeOsDatabase,
                    $SyncPendingChangesTable,
                    SyncPendingChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPendingChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $SyncPendingChangesTable,
      SyncPendingChange,
      $$SyncPendingChangesTableFilterComposer,
      $$SyncPendingChangesTableOrderingComposer,
      $$SyncPendingChangesTableAnnotationComposer,
      $$SyncPendingChangesTableCreateCompanionBuilder,
      $$SyncPendingChangesTableUpdateCompanionBuilder,
      (
        SyncPendingChange,
        BaseReferences<
          _$LifeOsDatabase,
          $SyncPendingChangesTable,
          SyncPendingChange
        >,
      ),
      SyncPendingChange,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String localPayloadJson,
      required String remotePayloadJson,
      required int remoteRevision,
      required DateTime detectedAt,
      Value<String?> resolution,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localPayloadJson,
      Value<String> remotePayloadJson,
      Value<int> remoteRevision,
      Value<DateTime> detectedAt,
      Value<String?> resolution,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePayloadJson => $composableBuilder(
    column: $table.remotePayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePayloadJson => $composableBuilder(
    column: $table.remotePayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remotePayloadJson => $composableBuilder(
    column: $table.remotePayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$LifeOsDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(
    _$LifeOsDatabase db,
    $SyncConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localPayloadJson = const Value.absent(),
                Value<String> remotePayloadJson = const Value.absent(),
                Value<int> remoteRevision = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localPayloadJson: localPayloadJson,
                remotePayloadJson: remotePayloadJson,
                remoteRevision: remoteRevision,
                detectedAt: detectedAt,
                resolution: resolution,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String localPayloadJson,
                required String remotePayloadJson,
                required int remoteRevision,
                required DateTime detectedAt,
                Value<String?> resolution = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localPayloadJson: localPayloadJson,
                remotePayloadJson: remotePayloadJson,
                remoteRevision: remoteRevision,
                detectedAt: detectedAt,
                resolution: resolution,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, SyncConflict>(table),
                  BaseReferences<
                    _$LifeOsDatabase,
                    $SyncConflictsTable,
                    SyncConflict
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$LifeOsDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$ActivityRecordsTableCreateCompanionBuilder =
    ActivityRecordsCompanion Function({
      required String id,
      required String kind,
      required DateTime recordDate,
      required String title,
      Value<int?> value,
      Value<String?> unit,
      Value<String?> status,
      Value<String> notes,
      Value<String> metadataJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$ActivityRecordsTableUpdateCompanionBuilder =
    ActivityRecordsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<DateTime> recordDate,
      Value<String> title,
      Value<int?> value,
      Value<String?> unit,
      Value<String?> status,
      Value<String> notes,
      Value<String> metadataJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$ActivityRecordsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $ActivityRecordsTable> {
  $$ActivityRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityRecordsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $ActivityRecordsTable> {
  $$ActivityRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityRecordsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $ActivityRecordsTable> {
  $$ActivityRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$ActivityRecordsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $ActivityRecordsTable,
          ActivityRecord,
          $$ActivityRecordsTableFilterComposer,
          $$ActivityRecordsTableOrderingComposer,
          $$ActivityRecordsTableAnnotationComposer,
          $$ActivityRecordsTableCreateCompanionBuilder,
          $$ActivityRecordsTableUpdateCompanionBuilder,
          (
            ActivityRecord,
            BaseReferences<
              _$LifeOsDatabase,
              $ActivityRecordsTable,
              ActivityRecord
            >,
          ),
          ActivityRecord,
          PrefetchHooks Function()
        > {
  $$ActivityRecordsTableTableManager(
    _$LifeOsDatabase db,
    $ActivityRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> value = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityRecordsCompanion(
                id: id,
                kind: kind,
                recordDate: recordDate,
                title: title,
                value: value,
                unit: unit,
                status: status,
                notes: notes,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required DateTime recordDate,
                required String title,
                Value<int?> value = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityRecordsCompanion.insert(
                id: id,
                kind: kind,
                recordDate: recordDate,
                title: title,
                value: value,
                unit: unit,
                status: status,
                notes: notes,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityRecordsTable, ActivityRecord>(table),
                  BaseReferences<
                    _$LifeOsDatabase,
                    $ActivityRecordsTable,
                    ActivityRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $ActivityRecordsTable,
      ActivityRecord,
      $$ActivityRecordsTableFilterComposer,
      $$ActivityRecordsTableOrderingComposer,
      $$ActivityRecordsTableAnnotationComposer,
      $$ActivityRecordsTableCreateCompanionBuilder,
      $$ActivityRecordsTableUpdateCompanionBuilder,
      (
        ActivityRecord,
        BaseReferences<_$LifeOsDatabase, $ActivityRecordsTable, ActivityRecord>,
      ),
      ActivityRecord,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      Value<String> category,
      Value<String> trackingType,
      Value<String> unit,
      Value<String> scheduleDays,
      Value<int?> target,
      Value<bool> isReduction,
      Value<bool> isArchived,
      required DateTime startDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> category,
      Value<String> trackingType,
      Value<String> unit,
      Value<String> scheduleDays,
      Value<int?> target,
      Value<bool> isReduction,
      Value<bool> isArchived,
      Value<DateTime> startDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$LifeOsDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitOccurrencesTable, List<HabitOccurrence>>
  _habitOccurrencesRefsTable(_$LifeOsDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.habitOccurrences,
        aliasName: 'habits__id__habit_occurrences__habit_id',
      );

  $$HabitOccurrencesTableProcessedTableManager get habitOccurrencesRefs {
    final manager = $$HabitOccurrencesTableTableManager(
      $_db,
      $_db.habitOccurrences,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _habitOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleDays => $composableBuilder(
    column: $table.scheduleDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReduction => $composableBuilder(
    column: $table.isReduction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitOccurrencesRefs(
    Expression<bool> Function($$HabitOccurrencesTableFilterComposer f) f,
  ) {
    final $$HabitOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitOccurrences,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.habitOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleDays => $composableBuilder(
    column: $table.scheduleDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReduction => $composableBuilder(
    column: $table.isReduction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get scheduleDays => $composableBuilder(
    column: $table.scheduleDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<bool> get isReduction => $composableBuilder(
    column: $table.isReduction,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> habitOccurrencesRefs<T extends Object>(
    Expression<T> Function($$HabitOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$HabitOccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitOccurrences,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitOccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.habitOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool habitOccurrencesRefs})
        > {
  $$HabitsTableTableManager(_$LifeOsDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> trackingType = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> scheduleDays = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<bool> isReduction = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                description: description,
                category: category,
                trackingType: trackingType,
                unit: unit,
                scheduleDays: scheduleDays,
                target: target,
                isReduction: isReduction,
                isArchived: isArchived,
                startDate: startDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> trackingType = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> scheduleDays = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<bool> isReduction = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime startDate,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                description: description,
                category: category,
                trackingType: trackingType,
                unit: unit,
                scheduleDays: scheduleDays,
                target: target,
                isReduction: isReduction,
                isArchived: isArchived,
                startDate: startDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, Habit>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitOccurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (habitOccurrencesRefs) db.habitOccurrences,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitOccurrencesRefs)
                    await $_getPrefetchedData<
                      Habit,
                      $HabitsTable,
                      HabitOccurrence
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._habitOccurrencesRefsTable(db),
                      managerFromTypedResult: (p0) => $$HabitsTableReferences(
                        db,
                        table,
                        p0,
                      ).habitOccurrencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool habitOccurrencesRefs})
    >;
typedef $$HabitOccurrencesTableCreateCompanionBuilder =
    HabitOccurrencesCompanion Function({
      required String id,
      required String habitId,
      required DateTime occurrenceDate,
      required String status,
      Value<int?> numericValue,
      Value<String> notes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HabitOccurrencesTableUpdateCompanionBuilder =
    HabitOccurrencesCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> occurrenceDate,
      Value<String> status,
      Value<int?> numericValue,
      Value<String> notes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$HabitOccurrencesTableReferences
    extends
        BaseReferences<
          _$LifeOsDatabase,
          $HabitOccurrencesTable,
          HabitOccurrence
        > {
  $$HabitOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$LifeOsDatabase db) =>
      db.habits.createAlias('habit_occurrences__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitOccurrencesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $HabitOccurrencesTable> {
  $$HabitOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitOccurrencesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $HabitOccurrencesTable> {
  $$HabitOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitOccurrencesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $HabitOccurrencesTable> {
  $$HabitOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitOccurrencesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $HabitOccurrencesTable,
          HabitOccurrence,
          $$HabitOccurrencesTableFilterComposer,
          $$HabitOccurrencesTableOrderingComposer,
          $$HabitOccurrencesTableAnnotationComposer,
          $$HabitOccurrencesTableCreateCompanionBuilder,
          $$HabitOccurrencesTableUpdateCompanionBuilder,
          (HabitOccurrence, $$HabitOccurrencesTableReferences),
          HabitOccurrence,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitOccurrencesTableTableManager(
    _$LifeOsDatabase db,
    $HabitOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitOccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> occurrenceDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> numericValue = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitOccurrencesCompanion(
                id: id,
                habitId: habitId,
                occurrenceDate: occurrenceDate,
                status: status,
                numericValue: numericValue,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime occurrenceDate,
                required String status,
                Value<int?> numericValue = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitOccurrencesCompanion.insert(
                id: id,
                habitId: habitId,
                occurrenceDate: occurrenceDate,
                status: status,
                numericValue: numericValue,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitOccurrencesTable, HabitOccurrence>(table),
                  $$HabitOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable:
                                    $$HabitOccurrencesTableReferences
                                        ._habitIdTable(db),
                                referencedColumn:
                                    $$HabitOccurrencesTableReferences
                                        ._habitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $HabitOccurrencesTable,
      HabitOccurrence,
      $$HabitOccurrencesTableFilterComposer,
      $$HabitOccurrencesTableOrderingComposer,
      $$HabitOccurrencesTableAnnotationComposer,
      $$HabitOccurrencesTableCreateCompanionBuilder,
      $$HabitOccurrencesTableUpdateCompanionBuilder,
      (HabitOccurrence, $$HabitOccurrencesTableReferences),
      HabitOccurrence,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required String name,
      Value<String> timeframe,
      Value<int?> target,
      Value<int> progress,
      Value<String> unit,
      Value<DateTime?> dueDate,
      Value<String> status,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> timeframe,
      Value<int?> target,
      Value<int> progress,
      Value<String> unit,
      Value<DateTime?> dueDate,
      Value<String> status,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeframe => $composableBuilder(
    column: $table.timeframe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeframe => $composableBuilder(
    column: $table.timeframe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get timeframe =>
      $composableBuilder(column: $table.timeframe, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$LifeOsDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$LifeOsDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> timeframe = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                timeframe: timeframe,
                target: target,
                progress: progress,
                unit: unit,
                dueDate: dueDate,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> timeframe = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                timeframe: timeframe,
                target: target,
                progress: progress,
                unit: unit,
                dueDate: dueDate,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, Goal>(table),
                  BaseReferences<_$LifeOsDatabase, $GoalsTable, Goal>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$LifeOsDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String category,
      required int amountMinor,
      Value<String> period,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<int> amountMinor,
      Value<String> period,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$LifeOsDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$LifeOsDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                category: category,
                amountMinor: amountMinor,
                period: period,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required int amountMinor,
                Value<String> period = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                category: category,
                amountMinor: amountMinor,
                period: period,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, Budget>(table),
                  BaseReferences<_$LifeOsDatabase, $BudgetsTable, Budget>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$LifeOsDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;

class $LifeOsDatabaseManager {
  final _$LifeOsDatabase _db;
  $LifeOsDatabaseManager(this._db);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$DashboardCardsTableTableManager get dashboardCards =>
      $$DashboardCardsTableTableManager(_db, _db.dashboardCards);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$SyncPendingChangesTableTableManager get syncPendingChanges =>
      $$SyncPendingChangesTableTableManager(_db, _db.syncPendingChanges);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$ActivityRecordsTableTableManager get activityRecords =>
      $$ActivityRecordsTableTableManager(_db, _db.activityRecords);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitOccurrencesTableTableManager get habitOccurrences =>
      $$HabitOccurrencesTableTableManager(_db, _db.habitOccurrences);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
}
