// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('me'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Kolkata'),
  );
  static const VerificationMeta _defaultNotifyMinutesMeta =
      const VerificationMeta('defaultNotifyMinutes');
  @override
  late final GeneratedColumn<int> defaultNotifyMinutes = GeneratedColumn<int>(
    'default_notify_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9 * 60),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
  defaultOffsets = GeneratedColumn<String>(
    'default_offsets',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('30,14,7,3,1,0,-1'),
  ).withConverter<List<int>>($ProfilesTable.$converterdefaultOffsets);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _exactAlarmsMeta = const VerificationMeta(
    'exactAlarms',
  );
  @override
  late final GeneratedColumn<bool> exactAlarms = GeneratedColumn<bool>(
    'exact_alarms',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exact_alarms" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    email,
    phone,
    timezone,
    defaultNotifyMinutes,
    defaultOffsets,
    currency,
    themeMode,
    exactAlarms,
    notificationsEnabled,
    onboarded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('default_notify_minutes')) {
      context.handle(
        _defaultNotifyMinutesMeta,
        defaultNotifyMinutes.isAcceptableOrUnknown(
          data['default_notify_minutes']!,
          _defaultNotifyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('exact_alarms')) {
      context.handle(
        _exactAlarmsMeta,
        exactAlarms.isAcceptableOrUnknown(
          data['exact_alarms']!,
          _exactAlarmsMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      defaultNotifyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_notify_minutes'],
      )!,
      defaultOffsets: $ProfilesTable.$converterdefaultOffsets.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_offsets'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      exactAlarms: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exact_alarms'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converterdefaultOffsets =
      const IntListConverter();
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String? displayName;
  final String? email;
  final String? phone;
  final String timezone;
  final int defaultNotifyMinutes;
  final List<int> defaultOffsets;
  final String currency;
  final String themeMode;
  final bool exactAlarms;
  final bool notificationsEnabled;
  final bool onboarded;
  const Profile({
    required this.id,
    this.displayName,
    this.email,
    this.phone,
    required this.timezone,
    required this.defaultNotifyMinutes,
    required this.defaultOffsets,
    required this.currency,
    required this.themeMode,
    required this.exactAlarms,
    required this.notificationsEnabled,
    required this.onboarded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['timezone'] = Variable<String>(timezone);
    map['default_notify_minutes'] = Variable<int>(defaultNotifyMinutes);
    {
      map['default_offsets'] = Variable<String>(
        $ProfilesTable.$converterdefaultOffsets.toSql(defaultOffsets),
      );
    }
    map['currency'] = Variable<String>(currency);
    map['theme_mode'] = Variable<String>(themeMode);
    map['exact_alarms'] = Variable<bool>(exactAlarms);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['onboarded'] = Variable<bool>(onboarded);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      timezone: Value(timezone),
      defaultNotifyMinutes: Value(defaultNotifyMinutes),
      defaultOffsets: Value(defaultOffsets),
      currency: Value(currency),
      themeMode: Value(themeMode),
      exactAlarms: Value(exactAlarms),
      notificationsEnabled: Value(notificationsEnabled),
      onboarded: Value(onboarded),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      timezone: serializer.fromJson<String>(json['timezone']),
      defaultNotifyMinutes: serializer.fromJson<int>(
        json['defaultNotifyMinutes'],
      ),
      defaultOffsets: serializer.fromJson<List<int>>(json['defaultOffsets']),
      currency: serializer.fromJson<String>(json['currency']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      exactAlarms: serializer.fromJson<bool>(json['exactAlarms']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'timezone': serializer.toJson<String>(timezone),
      'defaultNotifyMinutes': serializer.toJson<int>(defaultNotifyMinutes),
      'defaultOffsets': serializer.toJson<List<int>>(defaultOffsets),
      'currency': serializer.toJson<String>(currency),
      'themeMode': serializer.toJson<String>(themeMode),
      'exactAlarms': serializer.toJson<bool>(exactAlarms),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'onboarded': serializer.toJson<bool>(onboarded),
    };
  }

  Profile copyWith({
    String? id,
    Value<String?> displayName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? timezone,
    int? defaultNotifyMinutes,
    List<int>? defaultOffsets,
    String? currency,
    String? themeMode,
    bool? exactAlarms,
    bool? notificationsEnabled,
    bool? onboarded,
  }) => Profile(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    timezone: timezone ?? this.timezone,
    defaultNotifyMinutes: defaultNotifyMinutes ?? this.defaultNotifyMinutes,
    defaultOffsets: defaultOffsets ?? this.defaultOffsets,
    currency: currency ?? this.currency,
    themeMode: themeMode ?? this.themeMode,
    exactAlarms: exactAlarms ?? this.exactAlarms,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    onboarded: onboarded ?? this.onboarded,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      defaultNotifyMinutes: data.defaultNotifyMinutes.present
          ? data.defaultNotifyMinutes.value
          : this.defaultNotifyMinutes,
      defaultOffsets: data.defaultOffsets.present
          ? data.defaultOffsets.value
          : this.defaultOffsets,
      currency: data.currency.present ? data.currency.value : this.currency,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      exactAlarms: data.exactAlarms.present
          ? data.exactAlarms.value
          : this.exactAlarms,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('timezone: $timezone, ')
          ..write('defaultNotifyMinutes: $defaultNotifyMinutes, ')
          ..write('defaultOffsets: $defaultOffsets, ')
          ..write('currency: $currency, ')
          ..write('themeMode: $themeMode, ')
          ..write('exactAlarms: $exactAlarms, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    email,
    phone,
    timezone,
    defaultNotifyMinutes,
    defaultOffsets,
    currency,
    themeMode,
    exactAlarms,
    notificationsEnabled,
    onboarded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.timezone == this.timezone &&
          other.defaultNotifyMinutes == this.defaultNotifyMinutes &&
          other.defaultOffsets == this.defaultOffsets &&
          other.currency == this.currency &&
          other.themeMode == this.themeMode &&
          other.exactAlarms == this.exactAlarms &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.onboarded == this.onboarded);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String?> displayName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> timezone;
  final Value<int> defaultNotifyMinutes;
  final Value<List<int>> defaultOffsets;
  final Value<String> currency;
  final Value<String> themeMode;
  final Value<bool> exactAlarms;
  final Value<bool> notificationsEnabled;
  final Value<bool> onboarded;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.timezone = const Value.absent(),
    this.defaultNotifyMinutes = const Value.absent(),
    this.defaultOffsets = const Value.absent(),
    this.currency = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.exactAlarms = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.timezone = const Value.absent(),
    this.defaultNotifyMinutes = const Value.absent(),
    this.defaultOffsets = const Value.absent(),
    this.currency = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.exactAlarms = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? timezone,
    Expression<int>? defaultNotifyMinutes,
    Expression<String>? defaultOffsets,
    Expression<String>? currency,
    Expression<String>? themeMode,
    Expression<bool>? exactAlarms,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? onboarded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (timezone != null) 'timezone': timezone,
      if (defaultNotifyMinutes != null)
        'default_notify_minutes': defaultNotifyMinutes,
      if (defaultOffsets != null) 'default_offsets': defaultOffsets,
      if (currency != null) 'currency': currency,
      if (themeMode != null) 'theme_mode': themeMode,
      if (exactAlarms != null) 'exact_alarms': exactAlarms,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (onboarded != null) 'onboarded': onboarded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String?>? displayName,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? timezone,
    Value<int>? defaultNotifyMinutes,
    Value<List<int>>? defaultOffsets,
    Value<String>? currency,
    Value<String>? themeMode,
    Value<bool>? exactAlarms,
    Value<bool>? notificationsEnabled,
    Value<bool>? onboarded,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      timezone: timezone ?? this.timezone,
      defaultNotifyMinutes: defaultNotifyMinutes ?? this.defaultNotifyMinutes,
      defaultOffsets: defaultOffsets ?? this.defaultOffsets,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      exactAlarms: exactAlarms ?? this.exactAlarms,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboarded: onboarded ?? this.onboarded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (defaultNotifyMinutes.present) {
      map['default_notify_minutes'] = Variable<int>(defaultNotifyMinutes.value);
    }
    if (defaultOffsets.present) {
      map['default_offsets'] = Variable<String>(
        $ProfilesTable.$converterdefaultOffsets.toSql(defaultOffsets.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (exactAlarms.present) {
      map['exact_alarms'] = Variable<bool>(exactAlarms.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('timezone: $timezone, ')
          ..write('defaultNotifyMinutes: $defaultNotifyMinutes, ')
          ..write('defaultOffsets: $defaultOffsets, ')
          ..write('currency: $currency, ')
          ..write('themeMode: $themeMode, ')
          ..write('exactAlarms: $exactAlarms, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('onboarded: $onboarded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyMembersTable extends FamilyMembers
    with TableInfo<$FamilyMembersTable, FamilyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    name,
    relation,
    emoji,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
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
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMember(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $FamilyMembersTable createAlias(String alias) {
    return $FamilyMembersTable(attachedDatabase, alias);
  }
}

class FamilyMember extends DataClass implements Insertable<FamilyMember> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String name;
  final String? relation;
  final String? emoji;
  final int sortOrder;
  const FamilyMember({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.name,
    this.relation,
    this.emoji,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || relation != null) {
      map['relation'] = Variable<String>(relation);
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  FamilyMembersCompanion toCompanion(bool nullToAbsent) {
    return FamilyMembersCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      name: Value(name),
      relation: relation == null && nullToAbsent
          ? const Value.absent()
          : Value(relation),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      sortOrder: Value(sortOrder),
    );
  }

  factory FamilyMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMember(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      relation: serializer.fromJson<String?>(json['relation']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'relation': serializer.toJson<String?>(relation),
      'emoji': serializer.toJson<String?>(emoji),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  FamilyMember copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? name,
    Value<String?> relation = const Value.absent(),
    Value<String?> emoji = const Value.absent(),
    int? sortOrder,
  }) => FamilyMember(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    relation: relation.present ? relation.value : this.relation,
    emoji: emoji.present ? emoji.value : this.emoji,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  FamilyMember copyWithCompanion(FamilyMembersCompanion data) {
    return FamilyMember(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      relation: data.relation.present ? data.relation.value : this.relation,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMember(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relation: $relation, ')
          ..write('emoji: $emoji, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    name,
    relation,
    emoji,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMember &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.relation == this.relation &&
          other.emoji == this.emoji &&
          other.sortOrder == this.sortOrder);
}

class FamilyMembersCompanion extends UpdateCompanion<FamilyMember> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> relation;
  final Value<String?> emoji;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const FamilyMembersCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.relation = const Value.absent(),
    this.emoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyMembersCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String name,
    this.relation = const Value.absent(),
    this.emoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<FamilyMember> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? relation,
    Expression<String>? emoji,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (relation != null) 'relation': relation,
      if (emoji != null) 'emoji': emoji,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyMembersCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? relation,
    Value<String?>? emoji,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return FamilyMembersCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMembersCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relation: $relation, ')
          ..write('emoji: $emoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentKeyMeta = const VerificationMeta(
    'parentKey',
  );
  @override
  late final GeneratedColumn<String> parentKey = GeneratedColumn<String>(
    'parent_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    parentKey,
    name,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_key')) {
      context.handle(
        _parentKeyMeta,
        parentKey.isAcceptableOrUnknown(data['parent_key']!, _parentKeyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategory(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_key'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategory extends DataClass implements Insertable<CustomCategory> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String? parentKey;
  final String name;
  final String? icon;
  const CustomCategory({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    this.parentKey,
    required this.name,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentKey != null) {
      map['parent_key'] = Variable<String>(parentKey);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      parentKey: parentKey == null && nullToAbsent
          ? const Value.absent()
          : Value(parentKey),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory CustomCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategory(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      parentKey: serializer.fromJson<String?>(json['parentKey']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'parentKey': serializer.toJson<String?>(parentKey),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  CustomCategory copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    Value<String?> parentKey = const Value.absent(),
    String? name,
    Value<String?> icon = const Value.absent(),
  }) => CustomCategory(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    parentKey: parentKey.present ? parentKey.value : this.parentKey,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
  );
  CustomCategory copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategory(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      parentKey: data.parentKey.present ? data.parentKey.value : this.parentKey,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategory(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('parentKey: $parentKey, ')
          ..write('name: $name, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, deletedAt, id, parentKey, name, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategory &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.parentKey == this.parentKey &&
          other.name == this.name &&
          other.icon == this.icon);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategory> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String?> parentKey;
  final Value<String> name;
  final Value<String?> icon;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.parentKey = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    this.parentKey = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CustomCategory> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? parentKey,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (parentKey != null) 'parent_key': parentKey,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String?>? parentKey,
    Value<String>? name,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return CustomCategoriesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      parentKey: parentKey ?? this.parentKey,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentKey.present) {
      map['parent_key'] = Variable<String>(parentKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('parentKey: $parentKey, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMemberIdMeta = const VerificationMeta(
    'familyMemberId',
  );
  @override
  late final GeneratedColumn<String> familyMemberId = GeneratedColumn<String>(
    'family_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ItemsTable.$converterstartDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ItemsTable.$converterdueDaten);
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceUnit, int>
  recurrenceUnit = GeneratedColumn<int>(
    'recurrence_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<RecurrenceUnit>($ItemsTable.$converterrecurrenceUnit);
  static const VerificationMeta _recurrenceEveryMeta = const VerificationMeta(
    'recurrenceEvery',
  );
  @override
  late final GeneratedColumn<int> recurrenceEvery = GeneratedColumn<int>(
    'recurrence_every',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>?, String>
  reminderOffsets = GeneratedColumn<String>(
    'reminder_offsets',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<int>?>($ItemsTable.$converterreminderOffsetsn);
  static const VerificationMeta _notifyMinutesMeta = const VerificationMeta(
    'notifyMinutes',
  );
  @override
  late final GeneratedColumn<int> notifyMinutes = GeneratedColumn<int>(
    'notify_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    familyMemberId,
    categoryKey,
    title,
    provider,
    referenceNo,
    amountMinor,
    currency,
    startDate,
    dueDate,
    recurrenceUnit,
    recurrenceEvery,
    reminderOffsets,
    notifyMinutes,
    snoozedUntil,
    archived,
    notes,
    extra,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_member_id')) {
      context.handle(
        _familyMemberIdMeta,
        familyMemberId.isAcceptableOrUnknown(
          data['family_member_id']!,
          _familyMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('recurrence_every')) {
      context.handle(
        _recurrenceEveryMeta,
        recurrenceEvery.isAcceptableOrUnknown(
          data['recurrence_every']!,
          _recurrenceEveryMeta,
        ),
      );
    }
    if (data.containsKey('notify_minutes')) {
      context.handle(
        _notifyMinutesMeta,
        notifyMinutes.isAcceptableOrUnknown(
          data['notify_minutes']!,
          _notifyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_member_id'],
      ),
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      startDate: $ItemsTable.$converterstartDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        ),
      ),
      dueDate: $ItemsTable.$converterdueDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        ),
      ),
      recurrenceUnit: $ItemsTable.$converterrecurrenceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recurrence_unit'],
        )!,
      ),
      recurrenceEvery: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_every'],
      )!,
      reminderOffsets: $ItemsTable.$converterreminderOffsetsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_offsets'],
        ),
      ),
      notifyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notify_minutes'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterstartDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterstartDaten =
      NullAwareTypeConverter.wrap($converterstartDate);
  static TypeConverter<DateTime, String> $converterdueDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterdueDaten =
      NullAwareTypeConverter.wrap($converterdueDate);
  static JsonTypeConverter2<RecurrenceUnit, int, int> $converterrecurrenceUnit =
      const EnumIndexConverter<RecurrenceUnit>(RecurrenceUnit.values);
  static TypeConverter<List<int>, String> $converterreminderOffsets =
      const IntListConverter();
  static TypeConverter<List<int>?, String?> $converterreminderOffsetsn =
      NullAwareTypeConverter.wrap($converterreminderOffsets);
}

class Item extends DataClass implements Insertable<Item> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String? familyMemberId;
  final String categoryKey;
  final String title;
  final String? provider;
  final String? referenceNo;
  final int? amountMinor;
  final String currency;
  final DateTime? startDate;
  final DateTime? dueDate;
  final RecurrenceUnit recurrenceUnit;
  final int recurrenceEvery;
  final List<int>? reminderOffsets;
  final int? notifyMinutes;
  final DateTime? snoozedUntil;
  final bool archived;
  final String? notes;
  final String extra;
  const Item({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    this.familyMemberId,
    required this.categoryKey,
    required this.title,
    this.provider,
    this.referenceNo,
    this.amountMinor,
    required this.currency,
    this.startDate,
    this.dueDate,
    required this.recurrenceUnit,
    required this.recurrenceEvery,
    this.reminderOffsets,
    this.notifyMinutes,
    this.snoozedUntil,
    required this.archived,
    this.notes,
    required this.extra,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyMemberId != null) {
      map['family_member_id'] = Variable<String>(familyMemberId);
    }
    map['category_key'] = Variable<String>(categoryKey);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(
        $ItemsTable.$converterstartDaten.toSql(startDate),
      );
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(
        $ItemsTable.$converterdueDaten.toSql(dueDate),
      );
    }
    {
      map['recurrence_unit'] = Variable<int>(
        $ItemsTable.$converterrecurrenceUnit.toSql(recurrenceUnit),
      );
    }
    map['recurrence_every'] = Variable<int>(recurrenceEvery);
    if (!nullToAbsent || reminderOffsets != null) {
      map['reminder_offsets'] = Variable<String>(
        $ItemsTable.$converterreminderOffsetsn.toSql(reminderOffsets),
      );
    }
    if (!nullToAbsent || notifyMinutes != null) {
      map['notify_minutes'] = Variable<int>(notifyMinutes);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['extra'] = Variable<String>(extra);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      familyMemberId: familyMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyMemberId),
      categoryKey: Value(categoryKey),
      title: Value(title),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: Value(currency),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      recurrenceUnit: Value(recurrenceUnit),
      recurrenceEvery: Value(recurrenceEvery),
      reminderOffsets: reminderOffsets == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderOffsets),
      notifyMinutes: notifyMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(notifyMinutes),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      archived: Value(archived),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      extra: Value(extra),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      familyMemberId: serializer.fromJson<String?>(json['familyMemberId']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      title: serializer.fromJson<String>(json['title']),
      provider: serializer.fromJson<String?>(json['provider']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      recurrenceUnit: $ItemsTable.$converterrecurrenceUnit.fromJson(
        serializer.fromJson<int>(json['recurrenceUnit']),
      ),
      recurrenceEvery: serializer.fromJson<int>(json['recurrenceEvery']),
      reminderOffsets: serializer.fromJson<List<int>?>(json['reminderOffsets']),
      notifyMinutes: serializer.fromJson<int?>(json['notifyMinutes']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      archived: serializer.fromJson<bool>(json['archived']),
      notes: serializer.fromJson<String?>(json['notes']),
      extra: serializer.fromJson<String>(json['extra']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'familyMemberId': serializer.toJson<String?>(familyMemberId),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'title': serializer.toJson<String>(title),
      'provider': serializer.toJson<String?>(provider),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'recurrenceUnit': serializer.toJson<int>(
        $ItemsTable.$converterrecurrenceUnit.toJson(recurrenceUnit),
      ),
      'recurrenceEvery': serializer.toJson<int>(recurrenceEvery),
      'reminderOffsets': serializer.toJson<List<int>?>(reminderOffsets),
      'notifyMinutes': serializer.toJson<int?>(notifyMinutes),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'archived': serializer.toJson<bool>(archived),
      'notes': serializer.toJson<String?>(notes),
      'extra': serializer.toJson<String>(extra),
    };
  }

  Item copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    Value<String?> familyMemberId = const Value.absent(),
    String? categoryKey,
    String? title,
    Value<String?> provider = const Value.absent(),
    Value<String?> referenceNo = const Value.absent(),
    Value<int?> amountMinor = const Value.absent(),
    String? currency,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    RecurrenceUnit? recurrenceUnit,
    int? recurrenceEvery,
    Value<List<int>?> reminderOffsets = const Value.absent(),
    Value<int?> notifyMinutes = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    bool? archived,
    Value<String?> notes = const Value.absent(),
    String? extra,
  }) => Item(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    familyMemberId: familyMemberId.present
        ? familyMemberId.value
        : this.familyMemberId,
    categoryKey: categoryKey ?? this.categoryKey,
    title: title ?? this.title,
    provider: provider.present ? provider.value : this.provider,
    referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currency: currency ?? this.currency,
    startDate: startDate.present ? startDate.value : this.startDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    recurrenceUnit: recurrenceUnit ?? this.recurrenceUnit,
    recurrenceEvery: recurrenceEvery ?? this.recurrenceEvery,
    reminderOffsets: reminderOffsets.present
        ? reminderOffsets.value
        : this.reminderOffsets,
    notifyMinutes: notifyMinutes.present
        ? notifyMinutes.value
        : this.notifyMinutes,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    archived: archived ?? this.archived,
    notes: notes.present ? notes.value : this.notes,
    extra: extra ?? this.extra,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      familyMemberId: data.familyMemberId.present
          ? data.familyMemberId.value
          : this.familyMemberId,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      title: data.title.present ? data.title.value : this.title,
      provider: data.provider.present ? data.provider.value : this.provider,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      recurrenceUnit: data.recurrenceUnit.present
          ? data.recurrenceUnit.value
          : this.recurrenceUnit,
      recurrenceEvery: data.recurrenceEvery.present
          ? data.recurrenceEvery.value
          : this.recurrenceEvery,
      reminderOffsets: data.reminderOffsets.present
          ? data.reminderOffsets.value
          : this.reminderOffsets,
      notifyMinutes: data.notifyMinutes.present
          ? data.notifyMinutes.value
          : this.notifyMinutes,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      archived: data.archived.present ? data.archived.value : this.archived,
      notes: data.notes.present ? data.notes.value : this.notes,
      extra: data.extra.present ? data.extra.value : this.extra,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('familyMemberId: $familyMemberId, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('title: $title, ')
          ..write('provider: $provider, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('recurrenceUnit: $recurrenceUnit, ')
          ..write('recurrenceEvery: $recurrenceEvery, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('notifyMinutes: $notifyMinutes, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('archived: $archived, ')
          ..write('notes: $notes, ')
          ..write('extra: $extra')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    deletedAt,
    id,
    familyMemberId,
    categoryKey,
    title,
    provider,
    referenceNo,
    amountMinor,
    currency,
    startDate,
    dueDate,
    recurrenceUnit,
    recurrenceEvery,
    reminderOffsets,
    notifyMinutes,
    snoozedUntil,
    archived,
    notes,
    extra,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.familyMemberId == this.familyMemberId &&
          other.categoryKey == this.categoryKey &&
          other.title == this.title &&
          other.provider == this.provider &&
          other.referenceNo == this.referenceNo &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.startDate == this.startDate &&
          other.dueDate == this.dueDate &&
          other.recurrenceUnit == this.recurrenceUnit &&
          other.recurrenceEvery == this.recurrenceEvery &&
          other.reminderOffsets == this.reminderOffsets &&
          other.notifyMinutes == this.notifyMinutes &&
          other.snoozedUntil == this.snoozedUntil &&
          other.archived == this.archived &&
          other.notes == this.notes &&
          other.extra == this.extra);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String?> familyMemberId;
  final Value<String> categoryKey;
  final Value<String> title;
  final Value<String?> provider;
  final Value<String?> referenceNo;
  final Value<int?> amountMinor;
  final Value<String> currency;
  final Value<DateTime?> startDate;
  final Value<DateTime?> dueDate;
  final Value<RecurrenceUnit> recurrenceUnit;
  final Value<int> recurrenceEvery;
  final Value<List<int>?> reminderOffsets;
  final Value<int?> notifyMinutes;
  final Value<DateTime?> snoozedUntil;
  final Value<bool> archived;
  final Value<String?> notes;
  final Value<String> extra;
  final Value<int> rowid;
  const ItemsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.familyMemberId = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.title = const Value.absent(),
    this.provider = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.recurrenceUnit = const Value.absent(),
    this.recurrenceEvery = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.notifyMinutes = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.archived = const Value.absent(),
    this.notes = const Value.absent(),
    this.extra = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    this.familyMemberId = const Value.absent(),
    required String categoryKey,
    required String title,
    this.provider = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    required RecurrenceUnit recurrenceUnit,
    this.recurrenceEvery = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.notifyMinutes = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.archived = const Value.absent(),
    this.notes = const Value.absent(),
    this.extra = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryKey = Value(categoryKey),
       title = Value(title),
       recurrenceUnit = Value(recurrenceUnit);
  static Insertable<Item> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? familyMemberId,
    Expression<String>? categoryKey,
    Expression<String>? title,
    Expression<String>? provider,
    Expression<String>? referenceNo,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? startDate,
    Expression<String>? dueDate,
    Expression<int>? recurrenceUnit,
    Expression<int>? recurrenceEvery,
    Expression<String>? reminderOffsets,
    Expression<int>? notifyMinutes,
    Expression<DateTime>? snoozedUntil,
    Expression<bool>? archived,
    Expression<String>? notes,
    Expression<String>? extra,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (familyMemberId != null) 'family_member_id': familyMemberId,
      if (categoryKey != null) 'category_key': categoryKey,
      if (title != null) 'title': title,
      if (provider != null) 'provider': provider,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (startDate != null) 'start_date': startDate,
      if (dueDate != null) 'due_date': dueDate,
      if (recurrenceUnit != null) 'recurrence_unit': recurrenceUnit,
      if (recurrenceEvery != null) 'recurrence_every': recurrenceEvery,
      if (reminderOffsets != null) 'reminder_offsets': reminderOffsets,
      if (notifyMinutes != null) 'notify_minutes': notifyMinutes,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (archived != null) 'archived': archived,
      if (notes != null) 'notes': notes,
      if (extra != null) 'extra': extra,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String?>? familyMemberId,
    Value<String>? categoryKey,
    Value<String>? title,
    Value<String?>? provider,
    Value<String?>? referenceNo,
    Value<int?>? amountMinor,
    Value<String>? currency,
    Value<DateTime?>? startDate,
    Value<DateTime?>? dueDate,
    Value<RecurrenceUnit>? recurrenceUnit,
    Value<int>? recurrenceEvery,
    Value<List<int>?>? reminderOffsets,
    Value<int?>? notifyMinutes,
    Value<DateTime?>? snoozedUntil,
    Value<bool>? archived,
    Value<String?>? notes,
    Value<String>? extra,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      categoryKey: categoryKey ?? this.categoryKey,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      referenceNo: referenceNo ?? this.referenceNo,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      recurrenceUnit: recurrenceUnit ?? this.recurrenceUnit,
      recurrenceEvery: recurrenceEvery ?? this.recurrenceEvery,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      notifyMinutes: notifyMinutes ?? this.notifyMinutes,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      archived: archived ?? this.archived,
      notes: notes ?? this.notes,
      extra: extra ?? this.extra,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyMemberId.present) {
      map['family_member_id'] = Variable<String>(familyMemberId.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $ItemsTable.$converterstartDaten.toSql(startDate.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $ItemsTable.$converterdueDaten.toSql(dueDate.value),
      );
    }
    if (recurrenceUnit.present) {
      map['recurrence_unit'] = Variable<int>(
        $ItemsTable.$converterrecurrenceUnit.toSql(recurrenceUnit.value),
      );
    }
    if (recurrenceEvery.present) {
      map['recurrence_every'] = Variable<int>(recurrenceEvery.value);
    }
    if (reminderOffsets.present) {
      map['reminder_offsets'] = Variable<String>(
        $ItemsTable.$converterreminderOffsetsn.toSql(reminderOffsets.value),
      );
    }
    if (notifyMinutes.present) {
      map['notify_minutes'] = Variable<int>(notifyMinutes.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('familyMemberId: $familyMemberId, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('title: $title, ')
          ..write('provider: $provider, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('recurrenceUnit: $recurrenceUnit, ')
          ..write('recurrenceEvery: $recurrenceEvery, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('notifyMinutes: $notifyMinutes, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('archived: $archived, ')
          ..write('notes: $notes, ')
          ..write('extra: $extra, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RenewalsTable extends Renewals with TableInfo<$RenewalsTable, Renewal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RenewalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> previousDue =
      GeneratedColumn<String>(
        'previous_due',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RenewalsTable.$converterpreviousDue);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> newDue =
      GeneratedColumn<String>(
        'new_due',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RenewalsTable.$converternewDue);
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _renewedAtMeta = const VerificationMeta(
    'renewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> renewedAt = GeneratedColumn<DateTime>(
    'renewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    itemId,
    previousDue,
    newDue,
    amountMinor,
    provider,
    notes,
    renewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'renewals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Renewal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('renewed_at')) {
      context.handle(
        _renewedAtMeta,
        renewedAt.isAcceptableOrUnknown(data['renewed_at']!, _renewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Renewal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Renewal(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      previousDue: $RenewalsTable.$converterpreviousDue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}previous_due'],
        )!,
      ),
      newDue: $RenewalsTable.$converternewDue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}new_due'],
        )!,
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      renewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}renewed_at'],
      )!,
    );
  }

  @override
  $RenewalsTable createAlias(String alias) {
    return $RenewalsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterpreviousDue =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converternewDue =
      const DateOnlyConverter();
}

class Renewal extends DataClass implements Insertable<Renewal> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String itemId;
  final DateTime previousDue;
  final DateTime newDue;
  final int? amountMinor;
  final String? provider;
  final String? notes;
  final DateTime renewedAt;
  const Renewal({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.itemId,
    required this.previousDue,
    required this.newDue,
    this.amountMinor,
    this.provider,
    this.notes,
    required this.renewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    {
      map['previous_due'] = Variable<String>(
        $RenewalsTable.$converterpreviousDue.toSql(previousDue),
      );
    }
    {
      map['new_due'] = Variable<String>(
        $RenewalsTable.$converternewDue.toSql(newDue),
      );
    }
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['renewed_at'] = Variable<DateTime>(renewedAt);
    return map;
  }

  RenewalsCompanion toCompanion(bool nullToAbsent) {
    return RenewalsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      itemId: Value(itemId),
      previousDue: Value(previousDue),
      newDue: Value(newDue),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      renewedAt: Value(renewedAt),
    );
  }

  factory Renewal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Renewal(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      previousDue: serializer.fromJson<DateTime>(json['previousDue']),
      newDue: serializer.fromJson<DateTime>(json['newDue']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      provider: serializer.fromJson<String?>(json['provider']),
      notes: serializer.fromJson<String?>(json['notes']),
      renewedAt: serializer.fromJson<DateTime>(json['renewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'previousDue': serializer.toJson<DateTime>(previousDue),
      'newDue': serializer.toJson<DateTime>(newDue),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'provider': serializer.toJson<String?>(provider),
      'notes': serializer.toJson<String?>(notes),
      'renewedAt': serializer.toJson<DateTime>(renewedAt),
    };
  }

  Renewal copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? itemId,
    DateTime? previousDue,
    DateTime? newDue,
    Value<int?> amountMinor = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? renewedAt,
  }) => Renewal(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    previousDue: previousDue ?? this.previousDue,
    newDue: newDue ?? this.newDue,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    provider: provider.present ? provider.value : this.provider,
    notes: notes.present ? notes.value : this.notes,
    renewedAt: renewedAt ?? this.renewedAt,
  );
  Renewal copyWithCompanion(RenewalsCompanion data) {
    return Renewal(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      previousDue: data.previousDue.present
          ? data.previousDue.value
          : this.previousDue,
      newDue: data.newDue.present ? data.newDue.value : this.newDue,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      provider: data.provider.present ? data.provider.value : this.provider,
      notes: data.notes.present ? data.notes.value : this.notes,
      renewedAt: data.renewedAt.present ? data.renewedAt.value : this.renewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Renewal(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('previousDue: $previousDue, ')
          ..write('newDue: $newDue, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('provider: $provider, ')
          ..write('notes: $notes, ')
          ..write('renewedAt: $renewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    itemId,
    previousDue,
    newDue,
    amountMinor,
    provider,
    notes,
    renewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Renewal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.previousDue == this.previousDue &&
          other.newDue == this.newDue &&
          other.amountMinor == this.amountMinor &&
          other.provider == this.provider &&
          other.notes == this.notes &&
          other.renewedAt == this.renewedAt);
}

class RenewalsCompanion extends UpdateCompanion<Renewal> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> itemId;
  final Value<DateTime> previousDue;
  final Value<DateTime> newDue;
  final Value<int?> amountMinor;
  final Value<String?> provider;
  final Value<String?> notes;
  final Value<DateTime> renewedAt;
  final Value<int> rowid;
  const RenewalsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.previousDue = const Value.absent(),
    this.newDue = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.provider = const Value.absent(),
    this.notes = const Value.absent(),
    this.renewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RenewalsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String itemId,
    required DateTime previousDue,
    required DateTime newDue,
    this.amountMinor = const Value.absent(),
    this.provider = const Value.absent(),
    this.notes = const Value.absent(),
    this.renewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       previousDue = Value(previousDue),
       newDue = Value(newDue);
  static Insertable<Renewal> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? previousDue,
    Expression<String>? newDue,
    Expression<int>? amountMinor,
    Expression<String>? provider,
    Expression<String>? notes,
    Expression<DateTime>? renewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (previousDue != null) 'previous_due': previousDue,
      if (newDue != null) 'new_due': newDue,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (provider != null) 'provider': provider,
      if (notes != null) 'notes': notes,
      if (renewedAt != null) 'renewed_at': renewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RenewalsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? itemId,
    Value<DateTime>? previousDue,
    Value<DateTime>? newDue,
    Value<int?>? amountMinor,
    Value<String?>? provider,
    Value<String?>? notes,
    Value<DateTime>? renewedAt,
    Value<int>? rowid,
  }) {
    return RenewalsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      previousDue: previousDue ?? this.previousDue,
      newDue: newDue ?? this.newDue,
      amountMinor: amountMinor ?? this.amountMinor,
      provider: provider ?? this.provider,
      notes: notes ?? this.notes,
      renewedAt: renewedAt ?? this.renewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (previousDue.present) {
      map['previous_due'] = Variable<String>(
        $RenewalsTable.$converterpreviousDue.toSql(previousDue.value),
      );
    }
    if (newDue.present) {
      map['new_due'] = Variable<String>(
        $RenewalsTable.$converternewDue.toSql(newDue.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (renewedAt.present) {
      map['renewed_at'] = Variable<DateTime>(renewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RenewalsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('previousDue: $previousDue, ')
          ..write('newDue: $newDue, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('provider: $provider, ')
          ..write('notes: $notes, ')
          ..write('renewedAt: $renewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    itemId,
    fileName,
    mimeType,
    sizeBytes,
    localPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String itemId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? localPath;
  const Attachment({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.itemId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.localPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      itemId: Value(itemId),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      localPath: serializer.fromJson<String?>(json['localPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'localPath': serializer.toJson<String?>(localPath),
    };
  }

  Attachment copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? itemId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Value<String?> localPath = const Value.absent(),
  }) => Attachment(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    localPath: localPath.present ? localPath.value : this.localPath,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('localPath: $localPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    itemId,
    fileName,
    mimeType,
    sizeBytes,
    localPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.localPath == this.localPath);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> localPath;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String itemId,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes);
  static Insertable<Attachment> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledNotificationsTable extends ScheduledNotifications
    with TableInfo<$ScheduledNotificationsTable, ScheduledNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _osIdMeta = const VerificationMeta('osId');
  @override
  late final GeneratedColumn<int> osId = GeneratedColumn<int>(
    'os_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _instanceKeyMeta = const VerificationMeta(
    'instanceKey',
  );
  @override
  late final GeneratedColumn<String> instanceKey = GeneratedColumn<String>(
    'instance_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    osId,
    instanceKey,
    itemId,
    fireAt,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('os_id')) {
      context.handle(
        _osIdMeta,
        osId.isAcceptableOrUnknown(data['os_id']!, _osIdMeta),
      );
    }
    if (data.containsKey('instance_key')) {
      context.handle(
        _instanceKeyMeta,
        instanceKey.isAcceptableOrUnknown(
          data['instance_key']!,
          _instanceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceKeyMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {osId};
  @override
  ScheduledNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledNotification(
      osId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}os_id'],
      )!,
      instanceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_key'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $ScheduledNotificationsTable createAlias(String alias) {
    return $ScheduledNotificationsTable(attachedDatabase, alias);
  }
}

class ScheduledNotification extends DataClass
    implements Insertable<ScheduledNotification> {
  final int osId;
  final String instanceKey;
  final String itemId;
  final DateTime fireAt;
  final String body;
  const ScheduledNotification({
    required this.osId,
    required this.instanceKey,
    required this.itemId,
    required this.fireAt,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['os_id'] = Variable<int>(osId);
    map['instance_key'] = Variable<String>(instanceKey);
    map['item_id'] = Variable<String>(itemId);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['body'] = Variable<String>(body);
    return map;
  }

  ScheduledNotificationsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledNotificationsCompanion(
      osId: Value(osId),
      instanceKey: Value(instanceKey),
      itemId: Value(itemId),
      fireAt: Value(fireAt),
      body: Value(body),
    );
  }

  factory ScheduledNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledNotification(
      osId: serializer.fromJson<int>(json['osId']),
      instanceKey: serializer.fromJson<String>(json['instanceKey']),
      itemId: serializer.fromJson<String>(json['itemId']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'osId': serializer.toJson<int>(osId),
      'instanceKey': serializer.toJson<String>(instanceKey),
      'itemId': serializer.toJson<String>(itemId),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'body': serializer.toJson<String>(body),
    };
  }

  ScheduledNotification copyWith({
    int? osId,
    String? instanceKey,
    String? itemId,
    DateTime? fireAt,
    String? body,
  }) => ScheduledNotification(
    osId: osId ?? this.osId,
    instanceKey: instanceKey ?? this.instanceKey,
    itemId: itemId ?? this.itemId,
    fireAt: fireAt ?? this.fireAt,
    body: body ?? this.body,
  );
  ScheduledNotification copyWithCompanion(
    ScheduledNotificationsCompanion data,
  ) {
    return ScheduledNotification(
      osId: data.osId.present ? data.osId.value : this.osId,
      instanceKey: data.instanceKey.present
          ? data.instanceKey.value
          : this.instanceKey,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotification(')
          ..write('osId: $osId, ')
          ..write('instanceKey: $instanceKey, ')
          ..write('itemId: $itemId, ')
          ..write('fireAt: $fireAt, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(osId, instanceKey, itemId, fireAt, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledNotification &&
          other.osId == this.osId &&
          other.instanceKey == this.instanceKey &&
          other.itemId == this.itemId &&
          other.fireAt == this.fireAt &&
          other.body == this.body);
}

class ScheduledNotificationsCompanion
    extends UpdateCompanion<ScheduledNotification> {
  final Value<int> osId;
  final Value<String> instanceKey;
  final Value<String> itemId;
  final Value<DateTime> fireAt;
  final Value<String> body;
  const ScheduledNotificationsCompanion({
    this.osId = const Value.absent(),
    this.instanceKey = const Value.absent(),
    this.itemId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.body = const Value.absent(),
  });
  ScheduledNotificationsCompanion.insert({
    this.osId = const Value.absent(),
    required String instanceKey,
    required String itemId,
    required DateTime fireAt,
    required String body,
  }) : instanceKey = Value(instanceKey),
       itemId = Value(itemId),
       fireAt = Value(fireAt),
       body = Value(body);
  static Insertable<ScheduledNotification> custom({
    Expression<int>? osId,
    Expression<String>? instanceKey,
    Expression<String>? itemId,
    Expression<DateTime>? fireAt,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (osId != null) 'os_id': osId,
      if (instanceKey != null) 'instance_key': instanceKey,
      if (itemId != null) 'item_id': itemId,
      if (fireAt != null) 'fire_at': fireAt,
      if (body != null) 'body': body,
    });
  }

  ScheduledNotificationsCompanion copyWith({
    Value<int>? osId,
    Value<String>? instanceKey,
    Value<String>? itemId,
    Value<DateTime>? fireAt,
    Value<String>? body,
  }) {
    return ScheduledNotificationsCompanion(
      osId: osId ?? this.osId,
      instanceKey: instanceKey ?? this.instanceKey,
      itemId: itemId ?? this.itemId,
      fireAt: fireAt ?? this.fireAt,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (osId.present) {
      map['os_id'] = Variable<int>(osId.value);
    }
    if (instanceKey.present) {
      map['instance_key'] = Variable<String>(instanceKey.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotificationsCompanion(')
          ..write('osId: $osId, ')
          ..write('instanceKey: $instanceKey, ')
          ..write('itemId: $itemId, ')
          ..write('fireAt: $fireAt, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $FamilyMembersTable familyMembers = $FamilyMembersTable(this);
  late final $CustomCategoriesTable customCategories = $CustomCategoriesTable(
    this,
  );
  late final $ItemsTable items = $ItemsTable(this);
  late final $RenewalsTable renewals = $RenewalsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $ScheduledNotificationsTable scheduledNotifications =
      $ScheduledNotificationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    familyMembers,
    customCategories,
    items,
    renewals,
    attachments,
    scheduledNotifications,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<String?> displayName,
  Value<String?> email,
  Value<String?> phone,
  Value<String> timezone,
  Value<int> defaultNotifyMinutes,
  Value<List<int>> defaultOffsets,
  Value<String> currency,
  Value<String> themeMode,
  Value<bool> exactAlarms,
  Value<bool> notificationsEnabled,
  Value<bool> onboarded,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<String?> displayName,
  Value<String?> email,
  Value<String?> phone,
  Value<String> timezone,
  Value<int> defaultNotifyMinutes,
  Value<List<int>> defaultOffsets,
  Value<String> currency,
  Value<String> themeMode,
  Value<bool> exactAlarms,
  Value<bool> notificationsEnabled,
  Value<bool> onboarded,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultNotifyMinutes => $composableBuilder(
    column: $table.defaultNotifyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get defaultOffsets => $composableBuilder(
    column: $table.defaultOffsets,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exactAlarms => $composableBuilder(
    column: $table.exactAlarms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultNotifyMinutes => $composableBuilder(
    column: $table.defaultNotifyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultOffsets => $composableBuilder(
    column: $table.defaultOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exactAlarms => $composableBuilder(
    column: $table.exactAlarms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get defaultNotifyMinutes => $composableBuilder(
    column: $table.defaultNotifyMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>, String> get defaultOffsets =>
      $composableBuilder(
        column: $table.defaultOffsets,
        builder: (column) => column,
      );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get exactAlarms => $composableBuilder(
    column: $table.exactAlarms,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> defaultNotifyMinutes = const Value.absent(),
                Value<List<int>> defaultOffsets = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> exactAlarms = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                displayName: displayName,
                email: email,
                phone: phone,
                timezone: timezone,
                defaultNotifyMinutes: defaultNotifyMinutes,
                defaultOffsets: defaultOffsets,
                currency: currency,
                themeMode: themeMode,
                exactAlarms: exactAlarms,
                notificationsEnabled: notificationsEnabled,
                onboarded: onboarded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> defaultNotifyMinutes = const Value.absent(),
                Value<List<int>> defaultOffsets = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> exactAlarms = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                email: email,
                phone: phone,
                timezone: timezone,
                defaultNotifyMinutes: defaultNotifyMinutes,
                defaultOffsets: defaultOffsets,
                currency: currency,
                themeMode: themeMode,
                exactAlarms: exactAlarms,
                notificationsEnabled: notificationsEnabled,
                onboarded: onboarded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
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

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$FamilyMembersTableCreateCompanionBuilder =
    FamilyMembersCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String name,
      Value<String?> relation,
      Value<String?> emoji,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$FamilyMembersTableUpdateCompanionBuilder =
    FamilyMembersCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> name,
      Value<String?> relation,
      Value<String?> emoji,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$FamilyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$FamilyMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyMembersTable,
          FamilyMember,
          $$FamilyMembersTableFilterComposer,
          $$FamilyMembersTableOrderingComposer,
          $$FamilyMembersTableAnnotationComposer,
          $$FamilyMembersTableCreateCompanionBuilder,
          $$FamilyMembersTableUpdateCompanionBuilder,
          (
            FamilyMember,
            BaseReferences<_$AppDatabase, $FamilyMembersTable, FamilyMember>,
          ),
          FamilyMember,
          PrefetchHooks Function()
        > {
  $$FamilyMembersTableTableManager(_$AppDatabase db, $FamilyMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMembersCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                name: name,
                relation: relation,
                emoji: emoji,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String name,
                Value<String?> relation = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMembersCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                name: name,
                relation: relation,
                emoji: emoji,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FamilyMembersTable, FamilyMember>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FamilyMembersTable,
                    FamilyMember
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyMembersTable,
      FamilyMember,
      $$FamilyMembersTableFilterComposer,
      $$FamilyMembersTableOrderingComposer,
      $$FamilyMembersTableAnnotationComposer,
      $$FamilyMembersTableCreateCompanionBuilder,
      $$FamilyMembersTableUpdateCompanionBuilder,
      (
        FamilyMember,
        BaseReferences<_$AppDatabase, $FamilyMembersTable, FamilyMember>,
      ),
      FamilyMember,
      PrefetchHooks Function()
    >;
typedef $$CustomCategoriesTableCreateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      Value<String?> parentKey,
      required String name,
      Value<String?> icon,
      Value<int> rowid,
    });
typedef $$CustomCategoriesTableUpdateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String?> parentKey,
      Value<String> name,
      Value<String?> icon,
      Value<int> rowid,
    });

class $$CustomCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentKey => $composableBuilder(
    column: $table.parentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentKey => $composableBuilder(
    column: $table.parentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentKey =>
      $composableBuilder(column: $table.parentKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$CustomCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomCategoriesTable,
          CustomCategory,
          $$CustomCategoriesTableFilterComposer,
          $$CustomCategoriesTableOrderingComposer,
          $$CustomCategoriesTableAnnotationComposer,
          $$CustomCategoriesTableCreateCompanionBuilder,
          $$CustomCategoriesTableUpdateCompanionBuilder,
          (
            CustomCategory,
            BaseReferences<
              _$AppDatabase,
              $CustomCategoriesTable,
              CustomCategory
            >,
          ),
          CustomCategory,
          PrefetchHooks Function()
        > {
  $$CustomCategoriesTableTableManager(
    _$AppDatabase db,
    $CustomCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> parentKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomCategoriesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                parentKey: parentKey,
                name: name,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                Value<String?> parentKey = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomCategoriesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                parentKey: parentKey,
                name: name,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomCategoriesTable, CustomCategory>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomCategoriesTable,
                    CustomCategory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomCategoriesTable,
      CustomCategory,
      $$CustomCategoriesTableFilterComposer,
      $$CustomCategoriesTableOrderingComposer,
      $$CustomCategoriesTableAnnotationComposer,
      $$CustomCategoriesTableCreateCompanionBuilder,
      $$CustomCategoriesTableUpdateCompanionBuilder,
      (
        CustomCategory,
        BaseReferences<_$AppDatabase, $CustomCategoriesTable, CustomCategory>,
      ),
      CustomCategory,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String id,
  Value<String?> familyMemberId,
  required String categoryKey,
  required String title,
  Value<String?> provider,
  Value<String?> referenceNo,
  Value<int?> amountMinor,
  Value<String> currency,
  Value<DateTime?> startDate,
  Value<DateTime?> dueDate,
  required RecurrenceUnit recurrenceUnit,
  Value<int> recurrenceEvery,
  Value<List<int>?> reminderOffsets,
  Value<int?> notifyMinutes,
  Value<DateTime?> snoozedUntil,
  Value<bool> archived,
  Value<String?> notes,
  Value<String> extra,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> id,
  Value<String?> familyMemberId,
  Value<String> categoryKey,
  Value<String> title,
  Value<String?> provider,
  Value<String?> referenceNo,
  Value<int?> amountMinor,
  Value<String> currency,
  Value<DateTime?> startDate,
  Value<DateTime?> dueDate,
  Value<RecurrenceUnit> recurrenceUnit,
  Value<int> recurrenceEvery,
  Value<List<int>?> reminderOffsets,
  Value<int?> notifyMinutes,
  Value<DateTime?> snoozedUntil,
  Value<bool> archived,
  Value<String?> notes,
  Value<String> extra,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyMemberId => $composableBuilder(
    column: $table.familyMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get dueDate =>
      $composableBuilder(
        column: $table.dueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecurrenceUnit, RecurrenceUnit, int>
  get recurrenceUnit => $composableBuilder(
    column: $table.recurrenceUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get recurrenceEvery => $composableBuilder(
    column: $table.recurrenceEvery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>?, List<int>, String>
  get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get notifyMinutes => $composableBuilder(
    column: $table.notifyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyMemberId => $composableBuilder(
    column: $table.familyMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceUnit => $composableBuilder(
    column: $table.recurrenceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceEvery => $composableBuilder(
    column: $table.recurrenceEvery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifyMinutes => $composableBuilder(
    column: $table.notifyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyMemberId => $composableBuilder(
    column: $table.familyMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceUnit, int> get recurrenceUnit =>
      $composableBuilder(
        column: $table.recurrenceUnit,
        builder: (column) => column,
      );

  GeneratedColumn<int> get recurrenceEvery => $composableBuilder(
    column: $table.recurrenceEvery,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>?, String> get reminderOffsets =>
      $composableBuilder(
        column: $table.reminderOffsets,
        builder: (column) => column,
      );

  GeneratedColumn<int> get notifyMinutes => $composableBuilder(
    column: $table.notifyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> familyMemberId = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<RecurrenceUnit> recurrenceUnit = const Value.absent(),
                Value<int> recurrenceEvery = const Value.absent(),
                Value<List<int>?> reminderOffsets = const Value.absent(),
                Value<int?> notifyMinutes = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> extra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                familyMemberId: familyMemberId,
                categoryKey: categoryKey,
                title: title,
                provider: provider,
                referenceNo: referenceNo,
                amountMinor: amountMinor,
                currency: currency,
                startDate: startDate,
                dueDate: dueDate,
                recurrenceUnit: recurrenceUnit,
                recurrenceEvery: recurrenceEvery,
                reminderOffsets: reminderOffsets,
                notifyMinutes: notifyMinutes,
                snoozedUntil: snoozedUntil,
                archived: archived,
                notes: notes,
                extra: extra,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                Value<String?> familyMemberId = const Value.absent(),
                required String categoryKey,
                required String title,
                Value<String?> provider = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                required RecurrenceUnit recurrenceUnit,
                Value<int> recurrenceEvery = const Value.absent(),
                Value<List<int>?> reminderOffsets = const Value.absent(),
                Value<int?> notifyMinutes = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> extra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                familyMemberId: familyMemberId,
                categoryKey: categoryKey,
                title: title,
                provider: provider,
                referenceNo: referenceNo,
                amountMinor: amountMinor,
                currency: currency,
                startDate: startDate,
                dueDate: dueDate,
                recurrenceUnit: recurrenceUnit,
                recurrenceEvery: recurrenceEvery,
                reminderOffsets: reminderOffsets,
                notifyMinutes: notifyMinutes,
                snoozedUntil: snoozedUntil,
                archived: archived,
                notes: notes,
                extra: extra,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, Item>(table),
                  BaseReferences<_$AppDatabase, $ItemsTable, Item>(
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

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$RenewalsTableCreateCompanionBuilder = RenewalsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String id,
  required String itemId,
  required DateTime previousDue,
  required DateTime newDue,
  Value<int?> amountMinor,
  Value<String?> provider,
  Value<String?> notes,
  Value<DateTime> renewedAt,
  Value<int> rowid,
});
typedef $$RenewalsTableUpdateCompanionBuilder = RenewalsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> id,
  Value<String> itemId,
  Value<DateTime> previousDue,
  Value<DateTime> newDue,
  Value<int?> amountMinor,
  Value<String?> provider,
  Value<String?> notes,
  Value<DateTime> renewedAt,
  Value<int> rowid,
});

class $$RenewalsTableFilterComposer
    extends Composer<_$AppDatabase, $RenewalsTable> {
  $$RenewalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get previousDue =>
      $composableBuilder(
        column: $table.previousDue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get newDue =>
      $composableBuilder(
        column: $table.newDue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get renewedAt => $composableBuilder(
    column: $table.renewedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RenewalsTableOrderingComposer
    extends Composer<_$AppDatabase, $RenewalsTable> {
  $$RenewalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousDue => $composableBuilder(
    column: $table.previousDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newDue => $composableBuilder(
    column: $table.newDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get renewedAt => $composableBuilder(
    column: $table.renewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RenewalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RenewalsTable> {
  $$RenewalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get previousDue =>
      $composableBuilder(
        column: $table.previousDue,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, String> get newDue =>
      $composableBuilder(column: $table.newDue, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get renewedAt =>
      $composableBuilder(column: $table.renewedAt, builder: (column) => column);
}

class $$RenewalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RenewalsTable,
          Renewal,
          $$RenewalsTableFilterComposer,
          $$RenewalsTableOrderingComposer,
          $$RenewalsTableAnnotationComposer,
          $$RenewalsTableCreateCompanionBuilder,
          $$RenewalsTableUpdateCompanionBuilder,
          (Renewal, BaseReferences<_$AppDatabase, $RenewalsTable, Renewal>),
          Renewal,
          PrefetchHooks Function()
        > {
  $$RenewalsTableTableManager(_$AppDatabase db, $RenewalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RenewalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RenewalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RenewalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<DateTime> previousDue = const Value.absent(),
                Value<DateTime> newDue = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> renewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RenewalsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                itemId: itemId,
                previousDue: previousDue,
                newDue: newDue,
                amountMinor: amountMinor,
                provider: provider,
                notes: notes,
                renewedAt: renewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String itemId,
                required DateTime previousDue,
                required DateTime newDue,
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> renewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RenewalsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                itemId: itemId,
                previousDue: previousDue,
                newDue: newDue,
                amountMinor: amountMinor,
                provider: provider,
                notes: notes,
                renewedAt: renewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RenewalsTable, Renewal>(table),
                  BaseReferences<_$AppDatabase, $RenewalsTable, Renewal>(
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

typedef $$RenewalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RenewalsTable,
      Renewal,
      $$RenewalsTableFilterComposer,
      $$RenewalsTableOrderingComposer,
      $$RenewalsTableAnnotationComposer,
      $$RenewalsTableCreateCompanionBuilder,
      $$RenewalsTableUpdateCompanionBuilder,
      (Renewal, BaseReferences<_$AppDatabase, $RenewalsTable, Renewal>),
      Renewal,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String itemId,
      required String fileName,
      required String mimeType,
      required int sizeBytes,
      Value<String?> localPath,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> itemId,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String?> localPath,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                itemId: itemId,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                localPath: localPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String itemId,
                required String fileName,
                required String mimeType,
                required int sizeBytes,
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                itemId: itemId,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, Attachment>(table),
                  BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>(
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

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$ScheduledNotificationsTableCreateCompanionBuilder =
    ScheduledNotificationsCompanion Function({
      Value<int> osId,
      required String instanceKey,
      required String itemId,
      required DateTime fireAt,
      required String body,
    });
typedef $$ScheduledNotificationsTableUpdateCompanionBuilder =
    ScheduledNotificationsCompanion Function({
      Value<int> osId,
      Value<String> instanceKey,
      Value<String> itemId,
      Value<DateTime> fireAt,
      Value<String> body,
    });

class $$ScheduledNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get osId => $composableBuilder(
    column: $table.osId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instanceKey => $composableBuilder(
    column: $table.instanceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduledNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get osId => $composableBuilder(
    column: $table.osId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instanceKey => $composableBuilder(
    column: $table.instanceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduledNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get osId =>
      $composableBuilder(column: $table.osId, builder: (column) => column);

  GeneratedColumn<String> get instanceKey => $composableBuilder(
    column: $table.instanceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$ScheduledNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledNotificationsTable,
          ScheduledNotification,
          $$ScheduledNotificationsTableFilterComposer,
          $$ScheduledNotificationsTableOrderingComposer,
          $$ScheduledNotificationsTableAnnotationComposer,
          $$ScheduledNotificationsTableCreateCompanionBuilder,
          $$ScheduledNotificationsTableUpdateCompanionBuilder,
          (
            ScheduledNotification,
            BaseReferences<
              _$AppDatabase,
              $ScheduledNotificationsTable,
              ScheduledNotification
            >,
          ),
          ScheduledNotification,
          PrefetchHooks Function()
        > {
  $$ScheduledNotificationsTableTableManager(
    _$AppDatabase db,
    $ScheduledNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledNotificationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduledNotificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduledNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> osId = const Value.absent(),
                Value<String> instanceKey = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> body = const Value.absent(),
              }) => ScheduledNotificationsCompanion(
                osId: osId,
                instanceKey: instanceKey,
                itemId: itemId,
                fireAt: fireAt,
                body: body,
              ),
          createCompanionCallback:
              ({
                Value<int> osId = const Value.absent(),
                required String instanceKey,
                required String itemId,
                required DateTime fireAt,
                required String body,
              }) => ScheduledNotificationsCompanion.insert(
                osId: osId,
                instanceKey: instanceKey,
                itemId: itemId,
                fireAt: fireAt,
                body: body,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScheduledNotificationsTable,
                    ScheduledNotification
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScheduledNotificationsTable,
                    ScheduledNotification
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduledNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledNotificationsTable,
      ScheduledNotification,
      $$ScheduledNotificationsTableFilterComposer,
      $$ScheduledNotificationsTableOrderingComposer,
      $$ScheduledNotificationsTableAnnotationComposer,
      $$ScheduledNotificationsTableCreateCompanionBuilder,
      $$ScheduledNotificationsTableUpdateCompanionBuilder,
      (
        ScheduledNotification,
        BaseReferences<
          _$AppDatabase,
          $ScheduledNotificationsTable,
          ScheduledNotification
        >,
      ),
      ScheduledNotification,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$FamilyMembersTableTableManager get familyMembers =>
      $$FamilyMembersTableTableManager(_db, _db.familyMembers);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$RenewalsTableTableManager get renewals =>
      $$RenewalsTableTableManager(_db, _db.renewals);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$ScheduledNotificationsTableTableManager get scheduledNotifications =>
      $$ScheduledNotificationsTableTableManager(
        _db,
        _db.scheduledNotifications,
      );
}
