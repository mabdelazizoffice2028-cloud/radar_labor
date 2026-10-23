// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _employeeUidMeta = const VerificationMeta(
    'employeeUid',
  );
  @override
  late final GeneratedColumn<String> employeeUid = GeneratedColumn<String>(
    'employee_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeCodeMeta = const VerificationMeta(
    'employeeCode',
  );
  @override
  late final GeneratedColumn<String> employeeCode = GeneratedColumn<String>(
    'employee_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameArMeta = const VerificationMeta(
    'fullNameAr',
  );
  @override
  late final GeneratedColumn<String> fullNameAr = GeneratedColumn<String>(
    'full_name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameEnMeta = const VerificationMeta(
    'fullNameEn',
  );
  @override
  late final GeneratedColumn<String> fullNameEn = GeneratedColumn<String>(
    'full_name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _currentTeamIdMeta = const VerificationMeta(
    'currentTeamId',
  );
  @override
  late final GeneratedColumn<String> currentTeamId = GeneratedColumn<String>(
    'current_team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _housingIdMeta = const VerificationMeta(
    'housingId',
  );
  @override
  late final GeneratedColumn<String> housingId = GeneratedColumn<String>(
    'housing_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    employeeUid,
    employeeCode,
    fullNameAr,
    fullNameEn,
    category,
    currentTeamId,
    housingId,
    isActive,
    rowVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<Employee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('employee_uid')) {
      context.handle(
        _employeeUidMeta,
        employeeUid.isAcceptableOrUnknown(
          data['employee_uid']!,
          _employeeUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeUidMeta);
    }
    if (data.containsKey('employee_code')) {
      context.handle(
        _employeeCodeMeta,
        employeeCode.isAcceptableOrUnknown(
          data['employee_code']!,
          _employeeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeCodeMeta);
    }
    if (data.containsKey('full_name_ar')) {
      context.handle(
        _fullNameArMeta,
        fullNameAr.isAcceptableOrUnknown(
          data['full_name_ar']!,
          _fullNameArMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fullNameArMeta);
    }
    if (data.containsKey('full_name_en')) {
      context.handle(
        _fullNameEnMeta,
        fullNameEn.isAcceptableOrUnknown(
          data['full_name_en']!,
          _fullNameEnMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('current_team_id')) {
      context.handle(
        _currentTeamIdMeta,
        currentTeamId.isAcceptableOrUnknown(
          data['current_team_id']!,
          _currentTeamIdMeta,
        ),
      );
    }
    if (data.containsKey('housing_id')) {
      context.handle(
        _housingIdMeta,
        housingId.isAcceptableOrUnknown(data['housing_id']!, _housingIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {employeeUid};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      employeeUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_uid'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      fullNameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name_ar'],
      )!,
      fullNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name_en'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      currentTeamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_team_id'],
      ),
      housingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}housing_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class Employee extends DataClass implements Insertable<Employee> {
  final String employeeUid;
  final String employeeCode;
  final String fullNameAr;
  final String? fullNameEn;
  final String category;
  final String? currentTeamId;
  final String? housingId;
  final bool isActive;
  final int rowVersion;
  const Employee({
    required this.employeeUid,
    required this.employeeCode,
    required this.fullNameAr,
    this.fullNameEn,
    required this.category,
    this.currentTeamId,
    this.housingId,
    required this.isActive,
    required this.rowVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['employee_uid'] = Variable<String>(employeeUid);
    map['employee_code'] = Variable<String>(employeeCode);
    map['full_name_ar'] = Variable<String>(fullNameAr);
    if (!nullToAbsent || fullNameEn != null) {
      map['full_name_en'] = Variable<String>(fullNameEn);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || currentTeamId != null) {
      map['current_team_id'] = Variable<String>(currentTeamId);
    }
    if (!nullToAbsent || housingId != null) {
      map['housing_id'] = Variable<String>(housingId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['row_version'] = Variable<int>(rowVersion);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      employeeUid: Value(employeeUid),
      employeeCode: Value(employeeCode),
      fullNameAr: Value(fullNameAr),
      fullNameEn: fullNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(fullNameEn),
      category: Value(category),
      currentTeamId: currentTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTeamId),
      housingId: housingId == null && nullToAbsent
          ? const Value.absent()
          : Value(housingId),
      isActive: Value(isActive),
      rowVersion: Value(rowVersion),
    );
  }

  factory Employee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      employeeUid: serializer.fromJson<String>(json['employeeUid']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      fullNameAr: serializer.fromJson<String>(json['fullNameAr']),
      fullNameEn: serializer.fromJson<String?>(json['fullNameEn']),
      category: serializer.fromJson<String>(json['category']),
      currentTeamId: serializer.fromJson<String?>(json['currentTeamId']),
      housingId: serializer.fromJson<String?>(json['housingId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'employeeUid': serializer.toJson<String>(employeeUid),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'fullNameAr': serializer.toJson<String>(fullNameAr),
      'fullNameEn': serializer.toJson<String?>(fullNameEn),
      'category': serializer.toJson<String>(category),
      'currentTeamId': serializer.toJson<String?>(currentTeamId),
      'housingId': serializer.toJson<String?>(housingId),
      'isActive': serializer.toJson<bool>(isActive),
      'rowVersion': serializer.toJson<int>(rowVersion),
    };
  }

  Employee copyWith({
    String? employeeUid,
    String? employeeCode,
    String? fullNameAr,
    Value<String?> fullNameEn = const Value.absent(),
    String? category,
    Value<String?> currentTeamId = const Value.absent(),
    Value<String?> housingId = const Value.absent(),
    bool? isActive,
    int? rowVersion,
  }) => Employee(
    employeeUid: employeeUid ?? this.employeeUid,
    employeeCode: employeeCode ?? this.employeeCode,
    fullNameAr: fullNameAr ?? this.fullNameAr,
    fullNameEn: fullNameEn.present ? fullNameEn.value : this.fullNameEn,
    category: category ?? this.category,
    currentTeamId: currentTeamId.present
        ? currentTeamId.value
        : this.currentTeamId,
    housingId: housingId.present ? housingId.value : this.housingId,
    isActive: isActive ?? this.isActive,
    rowVersion: rowVersion ?? this.rowVersion,
  );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      employeeUid: data.employeeUid.present
          ? data.employeeUid.value
          : this.employeeUid,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      fullNameAr: data.fullNameAr.present
          ? data.fullNameAr.value
          : this.fullNameAr,
      fullNameEn: data.fullNameEn.present
          ? data.fullNameEn.value
          : this.fullNameEn,
      category: data.category.present ? data.category.value : this.category,
      currentTeamId: data.currentTeamId.present
          ? data.currentTeamId.value
          : this.currentTeamId,
      housingId: data.housingId.present ? data.housingId.value : this.housingId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('employeeUid: $employeeUid, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('fullNameAr: $fullNameAr, ')
          ..write('fullNameEn: $fullNameEn, ')
          ..write('category: $category, ')
          ..write('currentTeamId: $currentTeamId, ')
          ..write('housingId: $housingId, ')
          ..write('isActive: $isActive, ')
          ..write('rowVersion: $rowVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    employeeUid,
    employeeCode,
    fullNameAr,
    fullNameEn,
    category,
    currentTeamId,
    housingId,
    isActive,
    rowVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.employeeUid == this.employeeUid &&
          other.employeeCode == this.employeeCode &&
          other.fullNameAr == this.fullNameAr &&
          other.fullNameEn == this.fullNameEn &&
          other.category == this.category &&
          other.currentTeamId == this.currentTeamId &&
          other.housingId == this.housingId &&
          other.isActive == this.isActive &&
          other.rowVersion == this.rowVersion);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> employeeUid;
  final Value<String> employeeCode;
  final Value<String> fullNameAr;
  final Value<String?> fullNameEn;
  final Value<String> category;
  final Value<String?> currentTeamId;
  final Value<String?> housingId;
  final Value<bool> isActive;
  final Value<int> rowVersion;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.employeeUid = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.fullNameAr = const Value.absent(),
    this.fullNameEn = const Value.absent(),
    this.category = const Value.absent(),
    this.currentTeamId = const Value.absent(),
    this.housingId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String employeeUid,
    required String employeeCode,
    required String fullNameAr,
    this.fullNameEn = const Value.absent(),
    required String category,
    this.currentTeamId = const Value.absent(),
    this.housingId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : employeeUid = Value(employeeUid),
       employeeCode = Value(employeeCode),
       fullNameAr = Value(fullNameAr),
       category = Value(category);
  static Insertable<Employee> custom({
    Expression<String>? employeeUid,
    Expression<String>? employeeCode,
    Expression<String>? fullNameAr,
    Expression<String>? fullNameEn,
    Expression<String>? category,
    Expression<String>? currentTeamId,
    Expression<String>? housingId,
    Expression<bool>? isActive,
    Expression<int>? rowVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (employeeUid != null) 'employee_uid': employeeUid,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (fullNameAr != null) 'full_name_ar': fullNameAr,
      if (fullNameEn != null) 'full_name_en': fullNameEn,
      if (category != null) 'category': category,
      if (currentTeamId != null) 'current_team_id': currentTeamId,
      if (housingId != null) 'housing_id': housingId,
      if (isActive != null) 'is_active': isActive,
      if (rowVersion != null) 'row_version': rowVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith({
    Value<String>? employeeUid,
    Value<String>? employeeCode,
    Value<String>? fullNameAr,
    Value<String?>? fullNameEn,
    Value<String>? category,
    Value<String?>? currentTeamId,
    Value<String?>? housingId,
    Value<bool>? isActive,
    Value<int>? rowVersion,
    Value<int>? rowid,
  }) {
    return EmployeesCompanion(
      employeeUid: employeeUid ?? this.employeeUid,
      employeeCode: employeeCode ?? this.employeeCode,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      category: category ?? this.category,
      currentTeamId: currentTeamId ?? this.currentTeamId,
      housingId: housingId ?? this.housingId,
      isActive: isActive ?? this.isActive,
      rowVersion: rowVersion ?? this.rowVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (employeeUid.present) {
      map['employee_uid'] = Variable<String>(employeeUid.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (fullNameAr.present) {
      map['full_name_ar'] = Variable<String>(fullNameAr.value);
    }
    if (fullNameEn.present) {
      map['full_name_en'] = Variable<String>(fullNameEn.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (currentTeamId.present) {
      map['current_team_id'] = Variable<String>(currentTeamId.value);
    }
    if (housingId.present) {
      map['housing_id'] = Variable<String>(housingId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('employeeUid: $employeeUid, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('fullNameAr: $fullNameAr, ')
          ..write('fullNameEn: $fullNameEn, ')
          ..write('category: $category, ')
          ..write('currentTeamId: $currentTeamId, ')
          ..write('housingId: $housingId, ')
          ..write('isActive: $isActive, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supervisorUserIdMeta = const VerificationMeta(
    'supervisorUserId',
  );
  @override
  late final GeneratedColumn<String> supervisorUserId = GeneratedColumn<String>(
    'supervisor_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    teamId,
    nameAr,
    nameEn,
    supervisorUserId,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Team> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('supervisor_user_id')) {
      context.handle(
        _supervisorUserIdMeta,
        supervisorUserId.isAcceptableOrUnknown(
          data['supervisor_user_id']!,
          _supervisorUserIdMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId};
  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      supervisorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supervisor_user_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final String teamId;
  final String nameAr;
  final String? nameEn;
  final String? supervisorUserId;
  final bool isActive;
  const Team({
    required this.teamId,
    required this.nameAr,
    this.nameEn,
    this.supervisorUserId,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<String>(teamId);
    map['name_ar'] = Variable<String>(nameAr);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    if (!nullToAbsent || supervisorUserId != null) {
      map['supervisor_user_id'] = Variable<String>(supervisorUserId);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      teamId: Value(teamId),
      nameAr: Value(nameAr),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      supervisorUserId: supervisorUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(supervisorUserId),
      isActive: Value(isActive),
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      teamId: serializer.fromJson<String>(json['teamId']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      supervisorUserId: serializer.fromJson<String?>(json['supervisorUserId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<String>(teamId),
      'nameAr': serializer.toJson<String>(nameAr),
      'nameEn': serializer.toJson<String?>(nameEn),
      'supervisorUserId': serializer.toJson<String?>(supervisorUserId),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Team copyWith({
    String? teamId,
    String? nameAr,
    Value<String?> nameEn = const Value.absent(),
    Value<String?> supervisorUserId = const Value.absent(),
    bool? isActive,
  }) => Team(
    teamId: teamId ?? this.teamId,
    nameAr: nameAr ?? this.nameAr,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    supervisorUserId: supervisorUserId.present
        ? supervisorUserId.value
        : this.supervisorUserId,
    isActive: isActive ?? this.isActive,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      supervisorUserId: data.supervisorUserId.present
          ? data.supervisorUserId.value
          : this.supervisorUserId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('teamId: $teamId, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameEn: $nameEn, ')
          ..write('supervisorUserId: $supervisorUserId, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(teamId, nameAr, nameEn, supervisorUserId, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.teamId == this.teamId &&
          other.nameAr == this.nameAr &&
          other.nameEn == this.nameEn &&
          other.supervisorUserId == this.supervisorUserId &&
          other.isActive == this.isActive);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<String> teamId;
  final Value<String> nameAr;
  final Value<String?> nameEn;
  final Value<String?> supervisorUserId;
  final Value<bool> isActive;
  final Value<int> rowid;
  const TeamsCompanion({
    this.teamId = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.supervisorUserId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsCompanion.insert({
    required String teamId,
    required String nameAr,
    this.nameEn = const Value.absent(),
    this.supervisorUserId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : teamId = Value(teamId),
       nameAr = Value(nameAr);
  static Insertable<Team> custom({
    Expression<String>? teamId,
    Expression<String>? nameAr,
    Expression<String>? nameEn,
    Expression<String>? supervisorUserId,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameEn != null) 'name_en': nameEn,
      if (supervisorUserId != null) 'supervisor_user_id': supervisorUserId,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? teamId,
    Value<String>? nameAr,
    Value<String?>? nameEn,
    Value<String?>? supervisorUserId,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      teamId: teamId ?? this.teamId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      supervisorUserId: supervisorUserId ?? this.supervisorUserId,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (supervisorUserId.present) {
      map['supervisor_user_id'] = Variable<String>(supervisorUserId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('teamId: $teamId, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameEn: $nameEn, ')
          ..write('supervisorUserId: $supervisorUserId, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HousingsTable extends Housings with TableInfo<$HousingsTable, Housing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _housingIdMeta = const VerificationMeta(
    'housingId',
  );
  @override
  late final GeneratedColumn<String> housingId = GeneratedColumn<String>(
    'housing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [housingId, nameAr, nameEn, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'housings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Housing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('housing_id')) {
      context.handle(
        _housingIdMeta,
        housingId.isAcceptableOrUnknown(data['housing_id']!, _housingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_housingIdMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {housingId};
  @override
  Housing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Housing(
      housingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}housing_id'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $HousingsTable createAlias(String alias) {
    return $HousingsTable(attachedDatabase, alias);
  }
}

class Housing extends DataClass implements Insertable<Housing> {
  final String housingId;
  final String nameAr;
  final String? nameEn;
  final bool isActive;
  const Housing({
    required this.housingId,
    required this.nameAr,
    this.nameEn,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['housing_id'] = Variable<String>(housingId);
    map['name_ar'] = Variable<String>(nameAr);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  HousingsCompanion toCompanion(bool nullToAbsent) {
    return HousingsCompanion(
      housingId: Value(housingId),
      nameAr: Value(nameAr),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      isActive: Value(isActive),
    );
  }

  factory Housing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Housing(
      housingId: serializer.fromJson<String>(json['housingId']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'housingId': serializer.toJson<String>(housingId),
      'nameAr': serializer.toJson<String>(nameAr),
      'nameEn': serializer.toJson<String?>(nameEn),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Housing copyWith({
    String? housingId,
    String? nameAr,
    Value<String?> nameEn = const Value.absent(),
    bool? isActive,
  }) => Housing(
    housingId: housingId ?? this.housingId,
    nameAr: nameAr ?? this.nameAr,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    isActive: isActive ?? this.isActive,
  );
  Housing copyWithCompanion(HousingsCompanion data) {
    return Housing(
      housingId: data.housingId.present ? data.housingId.value : this.housingId,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Housing(')
          ..write('housingId: $housingId, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameEn: $nameEn, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(housingId, nameAr, nameEn, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Housing &&
          other.housingId == this.housingId &&
          other.nameAr == this.nameAr &&
          other.nameEn == this.nameEn &&
          other.isActive == this.isActive);
}

class HousingsCompanion extends UpdateCompanion<Housing> {
  final Value<String> housingId;
  final Value<String> nameAr;
  final Value<String?> nameEn;
  final Value<bool> isActive;
  final Value<int> rowid;
  const HousingsCompanion({
    this.housingId = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HousingsCompanion.insert({
    required String housingId,
    required String nameAr,
    this.nameEn = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : housingId = Value(housingId),
       nameAr = Value(nameAr);
  static Insertable<Housing> custom({
    Expression<String>? housingId,
    Expression<String>? nameAr,
    Expression<String>? nameEn,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (housingId != null) 'housing_id': housingId,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameEn != null) 'name_en': nameEn,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HousingsCompanion copyWith({
    Value<String>? housingId,
    Value<String>? nameAr,
    Value<String?>? nameEn,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return HousingsCompanion(
      housingId: housingId ?? this.housingId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (housingId.present) {
      map['housing_id'] = Variable<String>(housingId.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousingsCompanion(')
          ..write('housingId: $housingId, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameEn: $nameEn, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmploymentPeriodsTable extends EmploymentPeriods
    with TableInfo<$EmploymentPeriodsTable, EmploymentPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmploymentPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<String> periodId = GeneratedColumn<String>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeUidMeta = const VerificationMeta(
    'employeeUid',
  );
  @override
  late final GeneratedColumn<String> employeeUid = GeneratedColumn<String>(
    'employee_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (employee_uid) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    periodId,
    employeeUid,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employment_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmploymentPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('employee_uid')) {
      context.handle(
        _employeeUidMeta,
        employeeUid.isAcceptableOrUnknown(
          data['employee_uid']!,
          _employeeUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeUidMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {periodId};
  @override
  EmploymentPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmploymentPeriod(
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_id'],
      )!,
      employeeUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_uid'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $EmploymentPeriodsTable createAlias(String alias) {
    return $EmploymentPeriodsTable(attachedDatabase, alias);
  }
}

class EmploymentPeriod extends DataClass
    implements Insertable<EmploymentPeriod> {
  final String periodId;
  final String employeeUid;
  final String startDate;
  final String? endDate;
  const EmploymentPeriod({
    required this.periodId,
    required this.employeeUid,
    required this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period_id'] = Variable<String>(periodId);
    map['employee_uid'] = Variable<String>(employeeUid);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    return map;
  }

  EmploymentPeriodsCompanion toCompanion(bool nullToAbsent) {
    return EmploymentPeriodsCompanion(
      periodId: Value(periodId),
      employeeUid: Value(employeeUid),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory EmploymentPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmploymentPeriod(
      periodId: serializer.fromJson<String>(json['periodId']),
      employeeUid: serializer.fromJson<String>(json['employeeUid']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'periodId': serializer.toJson<String>(periodId),
      'employeeUid': serializer.toJson<String>(employeeUid),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
    };
  }

  EmploymentPeriod copyWith({
    String? periodId,
    String? employeeUid,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
  }) => EmploymentPeriod(
    periodId: periodId ?? this.periodId,
    employeeUid: employeeUid ?? this.employeeUid,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  EmploymentPeriod copyWithCompanion(EmploymentPeriodsCompanion data) {
    return EmploymentPeriod(
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      employeeUid: data.employeeUid.present
          ? data.employeeUid.value
          : this.employeeUid,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmploymentPeriod(')
          ..write('periodId: $periodId, ')
          ..write('employeeUid: $employeeUid, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(periodId, employeeUid, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmploymentPeriod &&
          other.periodId == this.periodId &&
          other.employeeUid == this.employeeUid &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class EmploymentPeriodsCompanion extends UpdateCompanion<EmploymentPeriod> {
  final Value<String> periodId;
  final Value<String> employeeUid;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int> rowid;
  const EmploymentPeriodsCompanion({
    this.periodId = const Value.absent(),
    this.employeeUid = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmploymentPeriodsCompanion.insert({
    required String periodId,
    required String employeeUid,
    required String startDate,
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : periodId = Value(periodId),
       employeeUid = Value(employeeUid),
       startDate = Value(startDate);
  static Insertable<EmploymentPeriod> custom({
    Expression<String>? periodId,
    Expression<String>? employeeUid,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (periodId != null) 'period_id': periodId,
      if (employeeUid != null) 'employee_uid': employeeUid,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmploymentPeriodsCompanion copyWith({
    Value<String>? periodId,
    Value<String>? employeeUid,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int>? rowid,
  }) {
    return EmploymentPeriodsCompanion(
      periodId: periodId ?? this.periodId,
      employeeUid: employeeUid ?? this.employeeUid,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (periodId.present) {
      map['period_id'] = Variable<String>(periodId.value);
    }
    if (employeeUid.present) {
      map['employee_uid'] = Variable<String>(employeeUid.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmploymentPeriodsCompanion(')
          ..write('periodId: $periodId, ')
          ..write('employeeUid: $employeeUid, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSeqMeta = const VerificationMeta(
    'deviceSeq',
  );
  @override
  late final GeneratedColumn<int> deviceSeq = GeneratedColumn<int>(
    'device_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeUidMeta = const VerificationMeta(
    'employeeUid',
  );
  @override
  late final GeneratedColumn<String> employeeUid = GeneratedColumn<String>(
    'employee_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _housingIdMeta = const VerificationMeta(
    'housingId',
  );
  @override
  late final GeneratedColumn<String> housingId = GeneratedColumn<String>(
    'housing_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta(
    'deviceTime',
  );
  @override
  late final GeneratedColumn<DateTime> deviceTime = GeneratedColumn<DateTime>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lateMeta = const VerificationMeta('late');
  @override
  late final GeneratedColumn<bool> late = GeneratedColumn<bool>(
    'late',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("late" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _eventSchemaVersionMeta =
      const VerificationMeta('eventSchemaVersion');
  @override
  late final GeneratedColumn<int> eventSchemaVersion = GeneratedColumn<int>(
    'event_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _rejectReasonMeta = const VerificationMeta(
    'rejectReason',
  );
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
    'reject_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    deviceId,
    deviceSeq,
    type,
    action,
    businessDate,
    employeeUid,
    teamId,
    housingId,
    userId,
    payload,
    deviceTime,
    receivedAt,
    serverSeq,
    late,
    eventSchemaVersion,
    syncStatus,
    rejectReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_seq')) {
      context.handle(
        _deviceSeqMeta,
        deviceSeq.isAcceptableOrUnknown(data['device_seq']!, _deviceSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceSeqMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('employee_uid')) {
      context.handle(
        _employeeUidMeta,
        employeeUid.isAcceptableOrUnknown(
          data['employee_uid']!,
          _employeeUidMeta,
        ),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('housing_id')) {
      context.handle(
        _housingIdMeta,
        housingId.isAcceptableOrUnknown(data['housing_id']!, _housingIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('device_time')) {
      context.handle(
        _deviceTimeMeta,
        deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('late')) {
      context.handle(
        _lateMeta,
        late.isAcceptableOrUnknown(data['late']!, _lateMeta),
      );
    }
    if (data.containsKey('event_schema_version')) {
      context.handle(
        _eventSchemaVersionMeta,
        eventSchemaVersion.isAcceptableOrUnknown(
          data['event_schema_version']!,
          _eventSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
        _rejectReasonMeta,
        rejectReason.isAcceptableOrUnknown(
          data['reject_reason']!,
          _rejectReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_seq'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      employeeUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_uid'],
      ),
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      housingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}housing_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_time'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      late: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}late'],
      )!,
      eventSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_schema_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      rejectReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reject_reason'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String eventId;
  final String deviceId;
  final int deviceSeq;
  final String type;
  final String action;
  final String businessDate;
  final String? employeeUid;
  final String? teamId;
  final String? housingId;
  final String? userId;
  final String payload;
  final DateTime deviceTime;
  final DateTime? receivedAt;
  final int? serverSeq;
  final bool late;
  final int eventSchemaVersion;
  final String syncStatus;
  final String? rejectReason;
  const Event({
    required this.eventId,
    required this.deviceId,
    required this.deviceSeq,
    required this.type,
    required this.action,
    required this.businessDate,
    this.employeeUid,
    this.teamId,
    this.housingId,
    this.userId,
    required this.payload,
    required this.deviceTime,
    this.receivedAt,
    this.serverSeq,
    required this.late,
    required this.eventSchemaVersion,
    required this.syncStatus,
    this.rejectReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['device_id'] = Variable<String>(deviceId);
    map['device_seq'] = Variable<int>(deviceSeq);
    map['type'] = Variable<String>(type);
    map['action'] = Variable<String>(action);
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || employeeUid != null) {
      map['employee_uid'] = Variable<String>(employeeUid);
    }
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    if (!nullToAbsent || housingId != null) {
      map['housing_id'] = Variable<String>(housingId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['payload'] = Variable<String>(payload);
    map['device_time'] = Variable<DateTime>(deviceTime);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['late'] = Variable<bool>(late);
    map['event_schema_version'] = Variable<int>(eventSchemaVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      eventId: Value(eventId),
      deviceId: Value(deviceId),
      deviceSeq: Value(deviceSeq),
      type: Value(type),
      action: Value(action),
      businessDate: Value(businessDate),
      employeeUid: employeeUid == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeUid),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      housingId: housingId == null && nullToAbsent
          ? const Value.absent()
          : Value(housingId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      payload: Value(payload),
      deviceTime: Value(deviceTime),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      late: Value(late),
      eventSchemaVersion: Value(eventSchemaVersion),
      syncStatus: Value(syncStatus),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      eventId: serializer.fromJson<String>(json['eventId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceSeq: serializer.fromJson<int>(json['deviceSeq']),
      type: serializer.fromJson<String>(json['type']),
      action: serializer.fromJson<String>(json['action']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      employeeUid: serializer.fromJson<String?>(json['employeeUid']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      housingId: serializer.fromJson<String?>(json['housingId']),
      userId: serializer.fromJson<String?>(json['userId']),
      payload: serializer.fromJson<String>(json['payload']),
      deviceTime: serializer.fromJson<DateTime>(json['deviceTime']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      late: serializer.fromJson<bool>(json['late']),
      eventSchemaVersion: serializer.fromJson<int>(json['eventSchemaVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceSeq': serializer.toJson<int>(deviceSeq),
      'type': serializer.toJson<String>(type),
      'action': serializer.toJson<String>(action),
      'businessDate': serializer.toJson<String>(businessDate),
      'employeeUid': serializer.toJson<String?>(employeeUid),
      'teamId': serializer.toJson<String?>(teamId),
      'housingId': serializer.toJson<String?>(housingId),
      'userId': serializer.toJson<String?>(userId),
      'payload': serializer.toJson<String>(payload),
      'deviceTime': serializer.toJson<DateTime>(deviceTime),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'late': serializer.toJson<bool>(late),
      'eventSchemaVersion': serializer.toJson<int>(eventSchemaVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'rejectReason': serializer.toJson<String?>(rejectReason),
    };
  }

  Event copyWith({
    String? eventId,
    String? deviceId,
    int? deviceSeq,
    String? type,
    String? action,
    String? businessDate,
    Value<String?> employeeUid = const Value.absent(),
    Value<String?> teamId = const Value.absent(),
    Value<String?> housingId = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? payload,
    DateTime? deviceTime,
    Value<DateTime?> receivedAt = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    bool? late,
    int? eventSchemaVersion,
    String? syncStatus,
    Value<String?> rejectReason = const Value.absent(),
  }) => Event(
    eventId: eventId ?? this.eventId,
    deviceId: deviceId ?? this.deviceId,
    deviceSeq: deviceSeq ?? this.deviceSeq,
    type: type ?? this.type,
    action: action ?? this.action,
    businessDate: businessDate ?? this.businessDate,
    employeeUid: employeeUid.present ? employeeUid.value : this.employeeUid,
    teamId: teamId.present ? teamId.value : this.teamId,
    housingId: housingId.present ? housingId.value : this.housingId,
    userId: userId.present ? userId.value : this.userId,
    payload: payload ?? this.payload,
    deviceTime: deviceTime ?? this.deviceTime,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    late: late ?? this.late,
    eventSchemaVersion: eventSchemaVersion ?? this.eventSchemaVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    rejectReason: rejectReason.present ? rejectReason.value : this.rejectReason,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceSeq: data.deviceSeq.present ? data.deviceSeq.value : this.deviceSeq,
      type: data.type.present ? data.type.value : this.type,
      action: data.action.present ? data.action.value : this.action,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      employeeUid: data.employeeUid.present
          ? data.employeeUid.value
          : this.employeeUid,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      housingId: data.housingId.present ? data.housingId.value : this.housingId,
      userId: data.userId.present ? data.userId.value : this.userId,
      payload: data.payload.present ? data.payload.value : this.payload,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      late: data.late.present ? data.late.value : this.late,
      eventSchemaVersion: data.eventSchemaVersion.present
          ? data.eventSchemaVersion.value
          : this.eventSchemaVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('eventId: $eventId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('type: $type, ')
          ..write('action: $action, ')
          ..write('businessDate: $businessDate, ')
          ..write('employeeUid: $employeeUid, ')
          ..write('teamId: $teamId, ')
          ..write('housingId: $housingId, ')
          ..write('userId: $userId, ')
          ..write('payload: $payload, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('late: $late, ')
          ..write('eventSchemaVersion: $eventSchemaVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rejectReason: $rejectReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    deviceId,
    deviceSeq,
    type,
    action,
    businessDate,
    employeeUid,
    teamId,
    housingId,
    userId,
    payload,
    deviceTime,
    receivedAt,
    serverSeq,
    late,
    eventSchemaVersion,
    syncStatus,
    rejectReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.eventId == this.eventId &&
          other.deviceId == this.deviceId &&
          other.deviceSeq == this.deviceSeq &&
          other.type == this.type &&
          other.action == this.action &&
          other.businessDate == this.businessDate &&
          other.employeeUid == this.employeeUid &&
          other.teamId == this.teamId &&
          other.housingId == this.housingId &&
          other.userId == this.userId &&
          other.payload == this.payload &&
          other.deviceTime == this.deviceTime &&
          other.receivedAt == this.receivedAt &&
          other.serverSeq == this.serverSeq &&
          other.late == this.late &&
          other.eventSchemaVersion == this.eventSchemaVersion &&
          other.syncStatus == this.syncStatus &&
          other.rejectReason == this.rejectReason);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> eventId;
  final Value<String> deviceId;
  final Value<int> deviceSeq;
  final Value<String> type;
  final Value<String> action;
  final Value<String> businessDate;
  final Value<String?> employeeUid;
  final Value<String?> teamId;
  final Value<String?> housingId;
  final Value<String?> userId;
  final Value<String> payload;
  final Value<DateTime> deviceTime;
  final Value<DateTime?> receivedAt;
  final Value<int?> serverSeq;
  final Value<bool> late;
  final Value<int> eventSchemaVersion;
  final Value<String> syncStatus;
  final Value<String?> rejectReason;
  final Value<int> rowid;
  const EventsCompanion({
    this.eventId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceSeq = const Value.absent(),
    this.type = const Value.absent(),
    this.action = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.employeeUid = const Value.absent(),
    this.teamId = const Value.absent(),
    this.housingId = const Value.absent(),
    this.userId = const Value.absent(),
    this.payload = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.late = const Value.absent(),
    this.eventSchemaVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String eventId,
    required String deviceId,
    required int deviceSeq,
    required String type,
    required String action,
    required String businessDate,
    this.employeeUid = const Value.absent(),
    this.teamId = const Value.absent(),
    this.housingId = const Value.absent(),
    this.userId = const Value.absent(),
    this.payload = const Value.absent(),
    required DateTime deviceTime,
    this.receivedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.late = const Value.absent(),
    this.eventSchemaVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       deviceId = Value(deviceId),
       deviceSeq = Value(deviceSeq),
       type = Value(type),
       action = Value(action),
       businessDate = Value(businessDate),
       deviceTime = Value(deviceTime);
  static Insertable<Event> custom({
    Expression<String>? eventId,
    Expression<String>? deviceId,
    Expression<int>? deviceSeq,
    Expression<String>? type,
    Expression<String>? action,
    Expression<String>? businessDate,
    Expression<String>? employeeUid,
    Expression<String>? teamId,
    Expression<String>? housingId,
    Expression<String>? userId,
    Expression<String>? payload,
    Expression<DateTime>? deviceTime,
    Expression<DateTime>? receivedAt,
    Expression<int>? serverSeq,
    Expression<bool>? late,
    Expression<int>? eventSchemaVersion,
    Expression<String>? syncStatus,
    Expression<String>? rejectReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceSeq != null) 'device_seq': deviceSeq,
      if (type != null) 'type': type,
      if (action != null) 'action': action,
      if (businessDate != null) 'business_date': businessDate,
      if (employeeUid != null) 'employee_uid': employeeUid,
      if (teamId != null) 'team_id': teamId,
      if (housingId != null) 'housing_id': housingId,
      if (userId != null) 'user_id': userId,
      if (payload != null) 'payload': payload,
      if (deviceTime != null) 'device_time': deviceTime,
      if (receivedAt != null) 'received_at': receivedAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (late != null) 'late': late,
      if (eventSchemaVersion != null)
        'event_schema_version': eventSchemaVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? deviceId,
    Value<int>? deviceSeq,
    Value<String>? type,
    Value<String>? action,
    Value<String>? businessDate,
    Value<String?>? employeeUid,
    Value<String?>? teamId,
    Value<String?>? housingId,
    Value<String?>? userId,
    Value<String>? payload,
    Value<DateTime>? deviceTime,
    Value<DateTime?>? receivedAt,
    Value<int?>? serverSeq,
    Value<bool>? late,
    Value<int>? eventSchemaVersion,
    Value<String>? syncStatus,
    Value<String?>? rejectReason,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      eventId: eventId ?? this.eventId,
      deviceId: deviceId ?? this.deviceId,
      deviceSeq: deviceSeq ?? this.deviceSeq,
      type: type ?? this.type,
      action: action ?? this.action,
      businessDate: businessDate ?? this.businessDate,
      employeeUid: employeeUid ?? this.employeeUid,
      teamId: teamId ?? this.teamId,
      housingId: housingId ?? this.housingId,
      userId: userId ?? this.userId,
      payload: payload ?? this.payload,
      deviceTime: deviceTime ?? this.deviceTime,
      receivedAt: receivedAt ?? this.receivedAt,
      serverSeq: serverSeq ?? this.serverSeq,
      late: late ?? this.late,
      eventSchemaVersion: eventSchemaVersion ?? this.eventSchemaVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      rejectReason: rejectReason ?? this.rejectReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceSeq.present) {
      map['device_seq'] = Variable<int>(deviceSeq.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (employeeUid.present) {
      map['employee_uid'] = Variable<String>(employeeUid.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (housingId.present) {
      map['housing_id'] = Variable<String>(housingId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<DateTime>(deviceTime.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (late.present) {
      map['late'] = Variable<bool>(late.value);
    }
    if (eventSchemaVersion.present) {
      map['event_schema_version'] = Variable<int>(eventSchemaVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('type: $type, ')
          ..write('action: $action, ')
          ..write('businessDate: $businessDate, ')
          ..write('employeeUid: $employeeUid, ')
          ..write('teamId: $teamId, ')
          ..write('housingId: $housingId, ')
          ..write('userId: $userId, ')
          ..write('payload: $payload, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('late: $late, ')
          ..write('eventSchemaVersion: $eventSchemaVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $HousingsTable housings = $HousingsTable(this);
  late final $EmploymentPeriodsTable employmentPeriods =
      $EmploymentPeriodsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final Index employeesEmployeeCode = Index(
    'employees_employee_code',
    'CREATE UNIQUE INDEX employees_employee_code ON employees (employee_code COLLATE NOCASE)',
  );
  late final Index employmentPeriodEmployeeStart = Index(
    'employment_period_employee_start',
    'CREATE INDEX employment_period_employee_start ON employment_periods (employee_uid, start_date)',
  );
  late final Index eventsDeviceSequenceUnique = Index(
    'events_device_sequence_unique',
    'CREATE UNIQUE INDEX events_device_sequence_unique ON events (device_id, device_seq)',
  );
  late final Index eventsBusinessDate = Index(
    'events_business_date',
    'CREATE INDEX events_business_date ON events (business_date)',
  );
  late final Index eventsEmployeeBusinessDate = Index(
    'events_employee_business_date',
    'CREATE INDEX events_employee_business_date ON events (employee_uid, business_date)',
  );
  late final Index eventsSyncSequence = Index(
    'events_sync_sequence',
    'CREATE INDEX events_sync_sequence ON events (sync_status, device_seq)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    employees,
    teams,
    housings,
    employmentPeriods,
    events,
    employeesEmployeeCode,
    employmentPeriodEmployeeStart,
    eventsDeviceSequenceUnique,
    eventsBusinessDate,
    eventsEmployeeBusinessDate,
    eventsSyncSequence,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'employees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('employment_periods', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$EmployeesTableCreateCompanionBuilder = EmployeesCompanion Function({
  required String employeeUid,
  required String employeeCode,
  required String fullNameAr,
  Value<String?> fullNameEn,
  required String category,
  Value<String?> currentTeamId,
  Value<String?> housingId,
  Value<bool> isActive,
  Value<int> rowVersion,
  Value<int> rowid,
});
typedef $$EmployeesTableUpdateCompanionBuilder = EmployeesCompanion Function({
  Value<String> employeeUid,
  Value<String> employeeCode,
  Value<String> fullNameAr,
  Value<String?> fullNameEn,
  Value<String> category,
  Value<String?> currentTeamId,
  Value<String?> housingId,
  Value<bool> isActive,
  Value<int> rowVersion,
  Value<int> rowid,
});

final class $$EmployeesTableReferences
    extends BaseReferences<_$AppDatabase, $EmployeesTable, Employee> {
  $$EmployeesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EmploymentPeriodsTable, List<EmploymentPeriod>>
  _employmentPeriodsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.employmentPeriods,
        aliasName: 'employees__employee_uid__employment_periods__employee_uid',
      );

  $$EmploymentPeriodsTableProcessedTableManager get employmentPeriodsRefs {
    final manager =
        $$EmploymentPeriodsTableTableManager(
          $_db,
          $_db.employmentPeriods,
        ).filter(
          (f) => f.employeeUid.employeeUid.sqlEquals(
            $_itemColumn<String>('employee_uid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _employmentPeriodsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullNameAr => $composableBuilder(
    column: $table.fullNameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullNameEn => $composableBuilder(
    column: $table.fullNameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentTeamId => $composableBuilder(
    column: $table.currentTeamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get housingId => $composableBuilder(
    column: $table.housingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> employmentPeriodsRefs(
    Expression<bool> Function($$EmploymentPeriodsTableFilterComposer f) f,
  ) {
    final $$EmploymentPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeUid,
      referencedTable: $db.employmentPeriods,
      getReferencedColumn: (t) => t.employeeUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmploymentPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.employmentPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullNameAr => $composableBuilder(
    column: $table.fullNameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullNameEn => $composableBuilder(
    column: $table.fullNameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentTeamId => $composableBuilder(
    column: $table.currentTeamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get housingId => $composableBuilder(
    column: $table.housingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullNameAr => $composableBuilder(
    column: $table.fullNameAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullNameEn => $composableBuilder(
    column: $table.fullNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get currentTeamId => $composableBuilder(
    column: $table.currentTeamId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get housingId =>
      $composableBuilder(column: $table.housingId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  Expression<T> employmentPeriodsRefs<T extends Object>(
    Expression<T> Function($$EmploymentPeriodsTableAnnotationComposer a) f,
  ) {
    final $$EmploymentPeriodsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.employeeUid,
          referencedTable: $db.employmentPeriods,
          getReferencedColumn: (t) => t.employeeUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EmploymentPeriodsTableAnnotationComposer(
                $db: $db,
                $table: $db.employmentPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          Employee,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (Employee, $$EmployeesTableReferences),
          Employee,
          PrefetchHooks Function({bool employmentPeriodsRefs})
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> employeeUid = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<String> fullNameAr = const Value.absent(),
                Value<String?> fullNameEn = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> currentTeamId = const Value.absent(),
                Value<String?> housingId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion(
                employeeUid: employeeUid,
                employeeCode: employeeCode,
                fullNameAr: fullNameAr,
                fullNameEn: fullNameEn,
                category: category,
                currentTeamId: currentTeamId,
                housingId: housingId,
                isActive: isActive,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String employeeUid,
                required String employeeCode,
                required String fullNameAr,
                Value<String?> fullNameEn = const Value.absent(),
                required String category,
                Value<String?> currentTeamId = const Value.absent(),
                Value<String?> housingId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion.insert(
                employeeUid: employeeUid,
                employeeCode: employeeCode,
                fullNameAr: fullNameAr,
                fullNameEn: fullNameEn,
                category: category,
                currentTeamId: currentTeamId,
                housingId: housingId,
                isActive: isActive,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmployeesTable, Employee>(table),
                  $$EmployeesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({employmentPeriodsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (employmentPeriodsRefs) db.employmentPeriods,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (employmentPeriodsRefs)
                    await $_getPrefetchedData<
                      Employee,
                      $EmployeesTable,
                      EmploymentPeriod
                    >(
                      currentTable: table,
                      referencedTable: $$EmployeesTableReferences
                          ._employmentPeriodsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EmployeesTableReferences(
                            db,
                            table,
                            p0,
                          ).employmentPeriodsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.employeeUid == item.employeeUid,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      Employee,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (Employee, $$EmployeesTableReferences),
      Employee,
      PrefetchHooks Function({bool employmentPeriodsRefs})
    >;
typedef $$TeamsTableCreateCompanionBuilder = TeamsCompanion Function({
  required String teamId,
  required String nameAr,
  Value<String?> nameEn,
  Value<String?> supervisorUserId,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$TeamsTableUpdateCompanionBuilder = TeamsCompanion Function({
  Value<String> teamId,
  Value<String> nameAr,
  Value<String?> nameEn,
  Value<String?> supervisorUserId,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supervisorUserId => $composableBuilder(
    column: $table.supervisorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supervisorUserId => $composableBuilder(
    column: $table.supervisorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get supervisorUserId => $composableBuilder(
    column: $table.supervisorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
          Team,
          PrefetchHooks Function()
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> teamId = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<String?> supervisorUserId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(
                teamId: teamId,
                nameAr: nameAr,
                nameEn: nameEn,
                supervisorUserId: supervisorUserId,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String teamId,
                required String nameAr,
                Value<String?> nameEn = const Value.absent(),
                Value<String?> supervisorUserId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(
                teamId: teamId,
                nameAr: nameAr,
                nameEn: nameEn,
                supervisorUserId: supervisorUserId,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamsTable, Team>(table),
                  BaseReferences<_$AppDatabase, $TeamsTable, Team>(
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

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
      Team,
      PrefetchHooks Function()
    >;
typedef $$HousingsTableCreateCompanionBuilder = HousingsCompanion Function({
  required String housingId,
  required String nameAr,
  Value<String?> nameEn,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$HousingsTableUpdateCompanionBuilder = HousingsCompanion Function({
  Value<String> housingId,
  Value<String> nameAr,
  Value<String?> nameEn,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$HousingsTableFilterComposer
    extends Composer<_$AppDatabase, $HousingsTable> {
  $$HousingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get housingId => $composableBuilder(
    column: $table.housingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HousingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HousingsTable> {
  $$HousingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get housingId => $composableBuilder(
    column: $table.housingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HousingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousingsTable> {
  $$HousingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get housingId =>
      $composableBuilder(column: $table.housingId, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$HousingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousingsTable,
          Housing,
          $$HousingsTableFilterComposer,
          $$HousingsTableOrderingComposer,
          $$HousingsTableAnnotationComposer,
          $$HousingsTableCreateCompanionBuilder,
          $$HousingsTableUpdateCompanionBuilder,
          (Housing, BaseReferences<_$AppDatabase, $HousingsTable, Housing>),
          Housing,
          PrefetchHooks Function()
        > {
  $$HousingsTableTableManager(_$AppDatabase db, $HousingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> housingId = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousingsCompanion(
                housingId: housingId,
                nameAr: nameAr,
                nameEn: nameEn,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String housingId,
                required String nameAr,
                Value<String?> nameEn = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousingsCompanion.insert(
                housingId: housingId,
                nameAr: nameAr,
                nameEn: nameEn,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HousingsTable, Housing>(table),
                  BaseReferences<_$AppDatabase, $HousingsTable, Housing>(
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

typedef $$HousingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousingsTable,
      Housing,
      $$HousingsTableFilterComposer,
      $$HousingsTableOrderingComposer,
      $$HousingsTableAnnotationComposer,
      $$HousingsTableCreateCompanionBuilder,
      $$HousingsTableUpdateCompanionBuilder,
      (Housing, BaseReferences<_$AppDatabase, $HousingsTable, Housing>),
      Housing,
      PrefetchHooks Function()
    >;
typedef $$EmploymentPeriodsTableCreateCompanionBuilder =
    EmploymentPeriodsCompanion Function({
      required String periodId,
      required String employeeUid,
      required String startDate,
      Value<String?> endDate,
      Value<int> rowid,
    });
typedef $$EmploymentPeriodsTableUpdateCompanionBuilder =
    EmploymentPeriodsCompanion Function({
      Value<String> periodId,
      Value<String> employeeUid,
      Value<String> startDate,
      Value<String?> endDate,
      Value<int> rowid,
    });

final class $$EmploymentPeriodsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EmploymentPeriodsTable,
          EmploymentPeriod
        > {
  $$EmploymentPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EmployeesTable _employeeUidTable(_$AppDatabase db) => db.employees
      .createAlias('employment_periods__employee_uid__employees__employee_uid');

  $$EmployeesTableProcessedTableManager get employeeUid {
    final $_column = $_itemColumn<String>('employee_uid')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.employeeUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmploymentPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $EmploymentPeriodsTable> {
  $$EmploymentPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get periodId => $composableBuilder(
    column: $table.periodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  $$EmployeesTableFilterComposer get employeeUid {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeUid,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.employeeUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmploymentPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmploymentPeriodsTable> {
  $$EmploymentPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get periodId => $composableBuilder(
    column: $table.periodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmployeesTableOrderingComposer get employeeUid {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeUid,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.employeeUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmploymentPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmploymentPeriodsTable> {
  $$EmploymentPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get periodId =>
      $composableBuilder(column: $table.periodId, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$EmployeesTableAnnotationComposer get employeeUid {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeUid,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.employeeUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmploymentPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmploymentPeriodsTable,
          EmploymentPeriod,
          $$EmploymentPeriodsTableFilterComposer,
          $$EmploymentPeriodsTableOrderingComposer,
          $$EmploymentPeriodsTableAnnotationComposer,
          $$EmploymentPeriodsTableCreateCompanionBuilder,
          $$EmploymentPeriodsTableUpdateCompanionBuilder,
          (EmploymentPeriod, $$EmploymentPeriodsTableReferences),
          EmploymentPeriod,
          PrefetchHooks Function({bool employeeUid})
        > {
  $$EmploymentPeriodsTableTableManager(
    _$AppDatabase db,
    $EmploymentPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmploymentPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmploymentPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmploymentPeriodsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> periodId = const Value.absent(),
                Value<String> employeeUid = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmploymentPeriodsCompanion(
                periodId: periodId,
                employeeUid: employeeUid,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String periodId,
                required String employeeUid,
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmploymentPeriodsCompanion.insert(
                periodId: periodId,
                employeeUid: employeeUid,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmploymentPeriodsTable, EmploymentPeriod>(table),
                  $$EmploymentPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({employeeUid = false}) {
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
                    if (employeeUid) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.employeeUid,
                        referencedTable: $$EmploymentPeriodsTableReferences
                            ._employeeUidTable(db),
                        referencedColumn: $$EmploymentPeriodsTableReferences
                            ._employeeUidTable(db)
                            .employeeUid,
                      ) as T;
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

typedef $$EmploymentPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmploymentPeriodsTable,
      EmploymentPeriod,
      $$EmploymentPeriodsTableFilterComposer,
      $$EmploymentPeriodsTableOrderingComposer,
      $$EmploymentPeriodsTableAnnotationComposer,
      $$EmploymentPeriodsTableCreateCompanionBuilder,
      $$EmploymentPeriodsTableUpdateCompanionBuilder,
      (EmploymentPeriod, $$EmploymentPeriodsTableReferences),
      EmploymentPeriod,
      PrefetchHooks Function({bool employeeUid})
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String eventId,
  required String deviceId,
  required int deviceSeq,
  required String type,
  required String action,
  required String businessDate,
  Value<String?> employeeUid,
  Value<String?> teamId,
  Value<String?> housingId,
  Value<String?> userId,
  Value<String> payload,
  required DateTime deviceTime,
  Value<DateTime?> receivedAt,
  Value<int?> serverSeq,
  Value<bool> late,
  Value<int> eventSchemaVersion,
  Value<String> syncStatus,
  Value<String?> rejectReason,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> eventId,
  Value<String> deviceId,
  Value<int> deviceSeq,
  Value<String> type,
  Value<String> action,
  Value<String> businessDate,
  Value<String?> employeeUid,
  Value<String?> teamId,
  Value<String?> housingId,
  Value<String?> userId,
  Value<String> payload,
  Value<DateTime> deviceTime,
  Value<DateTime?> receivedAt,
  Value<int?> serverSeq,
  Value<bool> late,
  Value<int> eventSchemaVersion,
  Value<String> syncStatus,
  Value<String?> rejectReason,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSeq => $composableBuilder(
    column: $table.deviceSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get housingId => $composableBuilder(
    column: $table.housingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get late => $composableBuilder(
    column: $table.late,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventSchemaVersion => $composableBuilder(
    column: $table.eventSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSeq => $composableBuilder(
    column: $table.deviceSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get housingId => $composableBuilder(
    column: $table.housingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get late => $composableBuilder(
    column: $table.late,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventSchemaVersion => $composableBuilder(
    column: $table.eventSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get deviceSeq =>
      $composableBuilder(column: $table.deviceSeq, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get housingId =>
      $composableBuilder(column: $table.housingId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<bool> get late =>
      $composableBuilder(column: $table.late, builder: (column) => column);

  GeneratedColumn<int> get eventSchemaVersion => $composableBuilder(
    column: $table.eventSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => column,
  );
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
          Event,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> deviceSeq = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String?> employeeUid = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> housingId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> deviceTime = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<bool> late = const Value.absent(),
                Value<int> eventSchemaVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> rejectReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                eventId: eventId,
                deviceId: deviceId,
                deviceSeq: deviceSeq,
                type: type,
                action: action,
                businessDate: businessDate,
                employeeUid: employeeUid,
                teamId: teamId,
                housingId: housingId,
                userId: userId,
                payload: payload,
                deviceTime: deviceTime,
                receivedAt: receivedAt,
                serverSeq: serverSeq,
                late: late,
                eventSchemaVersion: eventSchemaVersion,
                syncStatus: syncStatus,
                rejectReason: rejectReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String deviceId,
                required int deviceSeq,
                required String type,
                required String action,
                required String businessDate,
                Value<String?> employeeUid = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> housingId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                required DateTime deviceTime,
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<bool> late = const Value.absent(),
                Value<int> eventSchemaVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> rejectReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                eventId: eventId,
                deviceId: deviceId,
                deviceSeq: deviceSeq,
                type: type,
                action: action,
                businessDate: businessDate,
                employeeUid: employeeUid,
                teamId: teamId,
                housingId: housingId,
                userId: userId,
                payload: payload,
                deviceTime: deviceTime,
                receivedAt: receivedAt,
                serverSeq: serverSeq,
                late: late,
                eventSchemaVersion: eventSchemaVersion,
                syncStatus: syncStatus,
                rejectReason: rejectReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, Event>(table),
                  BaseReferences<_$AppDatabase, $EventsTable, Event>(
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

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
      Event,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$HousingsTableTableManager get housings =>
      $$HousingsTableTableManager(_db, _db.housings);
  $$EmploymentPeriodsTableTableManager get employmentPeriods =>
      $$EmploymentPeriodsTableTableManager(_db, _db.employmentPeriods);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
}
