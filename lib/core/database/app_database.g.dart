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
  static const VerificationMeta _iqamaNoMeta = const VerificationMeta(
    'iqamaNo',
  );
  @override
  late final GeneratedColumn<String> iqamaNo = GeneratedColumn<String>(
    'iqama_no',
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
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobCategoryMeta = const VerificationMeta(
    'jobCategory',
  );
  @override
  late final GeneratedColumn<String> jobCategory = GeneratedColumn<String>(
    'job_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('direct_labor'),
  );
  static const VerificationMeta _employmentTypeMeta = const VerificationMeta(
    'employmentType',
  );
  @override
  late final GeneratedColumn<String> employmentType = GeneratedColumn<String>(
    'employment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('company'),
  );
  static const VerificationMeta _rentalCompanyMeta = const VerificationMeta(
    'rentalCompany',
  );
  @override
  late final GeneratedColumn<String> rentalCompany = GeneratedColumn<String>(
    'rental_company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iqamaExpiryMeta = const VerificationMeta(
    'iqamaExpiry',
  );
  @override
  late final GeneratedColumn<DateTime> iqamaExpiry = GeneratedColumn<DateTime>(
    'iqama_expiry',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    iqamaNo,
    fullNameAr,
    fullNameEn,
    jobTitle,
    jobCategory,
    employmentType,
    rentalCompany,
    iqamaExpiry,
    currentTeamId,
    archivedAt,
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
    if (data.containsKey('iqama_no')) {
      context.handle(
        _iqamaNoMeta,
        iqamaNo.isAcceptableOrUnknown(data['iqama_no']!, _iqamaNoMeta),
      );
    } else if (isInserting) {
      context.missing(_iqamaNoMeta);
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
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    }
    if (data.containsKey('job_category')) {
      context.handle(
        _jobCategoryMeta,
        jobCategory.isAcceptableOrUnknown(
          data['job_category']!,
          _jobCategoryMeta,
        ),
      );
    }
    if (data.containsKey('employment_type')) {
      context.handle(
        _employmentTypeMeta,
        employmentType.isAcceptableOrUnknown(
          data['employment_type']!,
          _employmentTypeMeta,
        ),
      );
    }
    if (data.containsKey('rental_company')) {
      context.handle(
        _rentalCompanyMeta,
        rentalCompany.isAcceptableOrUnknown(
          data['rental_company']!,
          _rentalCompanyMeta,
        ),
      );
    }
    if (data.containsKey('iqama_expiry')) {
      context.handle(
        _iqamaExpiryMeta,
        iqamaExpiry.isAcceptableOrUnknown(
          data['iqama_expiry']!,
          _iqamaExpiryMeta,
        ),
      );
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {iqamaNo};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      iqamaNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iqama_no'],
      )!,
      fullNameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name_ar'],
      )!,
      fullNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name_en'],
      ),
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      ),
      jobCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_category'],
      )!,
      employmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employment_type'],
      )!,
      rentalCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rental_company'],
      ),
      iqamaExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}iqama_expiry'],
      ),
      currentTeamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_team_id'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
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
  final String iqamaNo;
  final String fullNameAr;
  final String? fullNameEn;
  final String? jobTitle;
  final String jobCategory;
  final String employmentType;
  final String? rentalCompany;
  final DateTime? iqamaExpiry;
  final String? currentTeamId;
  final DateTime? archivedAt;
  final int rowVersion;
  const Employee({
    required this.iqamaNo,
    required this.fullNameAr,
    this.fullNameEn,
    this.jobTitle,
    required this.jobCategory,
    required this.employmentType,
    this.rentalCompany,
    this.iqamaExpiry,
    this.currentTeamId,
    this.archivedAt,
    required this.rowVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['iqama_no'] = Variable<String>(iqamaNo);
    map['full_name_ar'] = Variable<String>(fullNameAr);
    if (!nullToAbsent || fullNameEn != null) {
      map['full_name_en'] = Variable<String>(fullNameEn);
    }
    if (!nullToAbsent || jobTitle != null) {
      map['job_title'] = Variable<String>(jobTitle);
    }
    map['job_category'] = Variable<String>(jobCategory);
    map['employment_type'] = Variable<String>(employmentType);
    if (!nullToAbsent || rentalCompany != null) {
      map['rental_company'] = Variable<String>(rentalCompany);
    }
    if (!nullToAbsent || iqamaExpiry != null) {
      map['iqama_expiry'] = Variable<DateTime>(iqamaExpiry);
    }
    if (!nullToAbsent || currentTeamId != null) {
      map['current_team_id'] = Variable<String>(currentTeamId);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['row_version'] = Variable<int>(rowVersion);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      iqamaNo: Value(iqamaNo),
      fullNameAr: Value(fullNameAr),
      fullNameEn: fullNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(fullNameEn),
      jobTitle: jobTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(jobTitle),
      jobCategory: Value(jobCategory),
      employmentType: Value(employmentType),
      rentalCompany: rentalCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(rentalCompany),
      iqamaExpiry: iqamaExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(iqamaExpiry),
      currentTeamId: currentTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTeamId),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      rowVersion: Value(rowVersion),
    );
  }

  factory Employee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      iqamaNo: serializer.fromJson<String>(json['iqamaNo']),
      fullNameAr: serializer.fromJson<String>(json['fullNameAr']),
      fullNameEn: serializer.fromJson<String?>(json['fullNameEn']),
      jobTitle: serializer.fromJson<String?>(json['jobTitle']),
      jobCategory: serializer.fromJson<String>(json['jobCategory']),
      employmentType: serializer.fromJson<String>(json['employmentType']),
      rentalCompany: serializer.fromJson<String?>(json['rentalCompany']),
      iqamaExpiry: serializer.fromJson<DateTime?>(json['iqamaExpiry']),
      currentTeamId: serializer.fromJson<String?>(json['currentTeamId']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'iqamaNo': serializer.toJson<String>(iqamaNo),
      'fullNameAr': serializer.toJson<String>(fullNameAr),
      'fullNameEn': serializer.toJson<String?>(fullNameEn),
      'jobTitle': serializer.toJson<String?>(jobTitle),
      'jobCategory': serializer.toJson<String>(jobCategory),
      'employmentType': serializer.toJson<String>(employmentType),
      'rentalCompany': serializer.toJson<String?>(rentalCompany),
      'iqamaExpiry': serializer.toJson<DateTime?>(iqamaExpiry),
      'currentTeamId': serializer.toJson<String?>(currentTeamId),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
    };
  }

  Employee copyWith({
    String? iqamaNo,
    String? fullNameAr,
    Value<String?> fullNameEn = const Value.absent(),
    Value<String?> jobTitle = const Value.absent(),
    String? jobCategory,
    String? employmentType,
    Value<String?> rentalCompany = const Value.absent(),
    Value<DateTime?> iqamaExpiry = const Value.absent(),
    Value<String?> currentTeamId = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    int? rowVersion,
  }) => Employee(
    iqamaNo: iqamaNo ?? this.iqamaNo,
    fullNameAr: fullNameAr ?? this.fullNameAr,
    fullNameEn: fullNameEn.present ? fullNameEn.value : this.fullNameEn,
    jobTitle: jobTitle.present ? jobTitle.value : this.jobTitle,
    jobCategory: jobCategory ?? this.jobCategory,
    employmentType: employmentType ?? this.employmentType,
    rentalCompany: rentalCompany.present
        ? rentalCompany.value
        : this.rentalCompany,
    iqamaExpiry: iqamaExpiry.present ? iqamaExpiry.value : this.iqamaExpiry,
    currentTeamId: currentTeamId.present
        ? currentTeamId.value
        : this.currentTeamId,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    rowVersion: rowVersion ?? this.rowVersion,
  );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      iqamaNo: data.iqamaNo.present ? data.iqamaNo.value : this.iqamaNo,
      fullNameAr: data.fullNameAr.present
          ? data.fullNameAr.value
          : this.fullNameAr,
      fullNameEn: data.fullNameEn.present
          ? data.fullNameEn.value
          : this.fullNameEn,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      jobCategory: data.jobCategory.present
          ? data.jobCategory.value
          : this.jobCategory,
      employmentType: data.employmentType.present
          ? data.employmentType.value
          : this.employmentType,
      rentalCompany: data.rentalCompany.present
          ? data.rentalCompany.value
          : this.rentalCompany,
      iqamaExpiry: data.iqamaExpiry.present
          ? data.iqamaExpiry.value
          : this.iqamaExpiry,
      currentTeamId: data.currentTeamId.present
          ? data.currentTeamId.value
          : this.currentTeamId,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('iqamaNo: $iqamaNo, ')
          ..write('fullNameAr: $fullNameAr, ')
          ..write('fullNameEn: $fullNameEn, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('jobCategory: $jobCategory, ')
          ..write('employmentType: $employmentType, ')
          ..write('rentalCompany: $rentalCompany, ')
          ..write('iqamaExpiry: $iqamaExpiry, ')
          ..write('currentTeamId: $currentTeamId, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowVersion: $rowVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    iqamaNo,
    fullNameAr,
    fullNameEn,
    jobTitle,
    jobCategory,
    employmentType,
    rentalCompany,
    iqamaExpiry,
    currentTeamId,
    archivedAt,
    rowVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.iqamaNo == this.iqamaNo &&
          other.fullNameAr == this.fullNameAr &&
          other.fullNameEn == this.fullNameEn &&
          other.jobTitle == this.jobTitle &&
          other.jobCategory == this.jobCategory &&
          other.employmentType == this.employmentType &&
          other.rentalCompany == this.rentalCompany &&
          other.iqamaExpiry == this.iqamaExpiry &&
          other.currentTeamId == this.currentTeamId &&
          other.archivedAt == this.archivedAt &&
          other.rowVersion == this.rowVersion);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> iqamaNo;
  final Value<String> fullNameAr;
  final Value<String?> fullNameEn;
  final Value<String?> jobTitle;
  final Value<String> jobCategory;
  final Value<String> employmentType;
  final Value<String?> rentalCompany;
  final Value<DateTime?> iqamaExpiry;
  final Value<String?> currentTeamId;
  final Value<DateTime?> archivedAt;
  final Value<int> rowVersion;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.iqamaNo = const Value.absent(),
    this.fullNameAr = const Value.absent(),
    this.fullNameEn = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.jobCategory = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.rentalCompany = const Value.absent(),
    this.iqamaExpiry = const Value.absent(),
    this.currentTeamId = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String iqamaNo,
    required String fullNameAr,
    this.fullNameEn = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.jobCategory = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.rentalCompany = const Value.absent(),
    this.iqamaExpiry = const Value.absent(),
    this.currentTeamId = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : iqamaNo = Value(iqamaNo),
       fullNameAr = Value(fullNameAr);
  static Insertable<Employee> custom({
    Expression<String>? iqamaNo,
    Expression<String>? fullNameAr,
    Expression<String>? fullNameEn,
    Expression<String>? jobTitle,
    Expression<String>? jobCategory,
    Expression<String>? employmentType,
    Expression<String>? rentalCompany,
    Expression<DateTime>? iqamaExpiry,
    Expression<String>? currentTeamId,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (iqamaNo != null) 'iqama_no': iqamaNo,
      if (fullNameAr != null) 'full_name_ar': fullNameAr,
      if (fullNameEn != null) 'full_name_en': fullNameEn,
      if (jobTitle != null) 'job_title': jobTitle,
      if (jobCategory != null) 'job_category': jobCategory,
      if (employmentType != null) 'employment_type': employmentType,
      if (rentalCompany != null) 'rental_company': rentalCompany,
      if (iqamaExpiry != null) 'iqama_expiry': iqamaExpiry,
      if (currentTeamId != null) 'current_team_id': currentTeamId,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith({
    Value<String>? iqamaNo,
    Value<String>? fullNameAr,
    Value<String?>? fullNameEn,
    Value<String?>? jobTitle,
    Value<String>? jobCategory,
    Value<String>? employmentType,
    Value<String?>? rentalCompany,
    Value<DateTime?>? iqamaExpiry,
    Value<String?>? currentTeamId,
    Value<DateTime?>? archivedAt,
    Value<int>? rowVersion,
    Value<int>? rowid,
  }) {
    return EmployeesCompanion(
      iqamaNo: iqamaNo ?? this.iqamaNo,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      jobTitle: jobTitle ?? this.jobTitle,
      jobCategory: jobCategory ?? this.jobCategory,
      employmentType: employmentType ?? this.employmentType,
      rentalCompany: rentalCompany ?? this.rentalCompany,
      iqamaExpiry: iqamaExpiry ?? this.iqamaExpiry,
      currentTeamId: currentTeamId ?? this.currentTeamId,
      archivedAt: archivedAt ?? this.archivedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (iqamaNo.present) {
      map['iqama_no'] = Variable<String>(iqamaNo.value);
    }
    if (fullNameAr.present) {
      map['full_name_ar'] = Variable<String>(fullNameAr.value);
    }
    if (fullNameEn.present) {
      map['full_name_en'] = Variable<String>(fullNameEn.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (jobCategory.present) {
      map['job_category'] = Variable<String>(jobCategory.value);
    }
    if (employmentType.present) {
      map['employment_type'] = Variable<String>(employmentType.value);
    }
    if (rentalCompany.present) {
      map['rental_company'] = Variable<String>(rentalCompany.value);
    }
    if (iqamaExpiry.present) {
      map['iqama_expiry'] = Variable<DateTime>(iqamaExpiry.value);
    }
    if (currentTeamId.present) {
      map['current_team_id'] = Variable<String>(currentTeamId.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
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
          ..write('iqamaNo: $iqamaNo, ')
          ..write('fullNameAr: $fullNameAr, ')
          ..write('fullNameEn: $fullNameEn, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('jobCategory: $jobCategory, ')
          ..write('employmentType: $employmentType, ')
          ..write('rentalCompany: $rentalCompany, ')
          ..write('iqamaExpiry: $iqamaExpiry, ')
          ..write('currentTeamId: $currentTeamId, ')
          ..write('archivedAt: $archivedAt, ')
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
  static const VerificationMeta _iqamaNoMeta = const VerificationMeta(
    'iqamaNo',
  );
  @override
  late final GeneratedColumn<String> iqamaNo = GeneratedColumn<String>(
    'iqama_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [periodId, iqamaNo, startDate, endDate];
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
    if (data.containsKey('iqama_no')) {
      context.handle(
        _iqamaNoMeta,
        iqamaNo.isAcceptableOrUnknown(data['iqama_no']!, _iqamaNoMeta),
      );
    } else if (isInserting) {
      context.missing(_iqamaNoMeta);
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
      iqamaNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iqama_no'],
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
  final String iqamaNo;
  final String startDate;
  final String? endDate;
  const EmploymentPeriod({
    required this.periodId,
    required this.iqamaNo,
    required this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period_id'] = Variable<String>(periodId);
    map['iqama_no'] = Variable<String>(iqamaNo);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    return map;
  }

  EmploymentPeriodsCompanion toCompanion(bool nullToAbsent) {
    return EmploymentPeriodsCompanion(
      periodId: Value(periodId),
      iqamaNo: Value(iqamaNo),
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
      iqamaNo: serializer.fromJson<String>(json['iqamaNo']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'periodId': serializer.toJson<String>(periodId),
      'iqamaNo': serializer.toJson<String>(iqamaNo),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
    };
  }

  EmploymentPeriod copyWith({
    String? periodId,
    String? iqamaNo,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
  }) => EmploymentPeriod(
    periodId: periodId ?? this.periodId,
    iqamaNo: iqamaNo ?? this.iqamaNo,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  EmploymentPeriod copyWithCompanion(EmploymentPeriodsCompanion data) {
    return EmploymentPeriod(
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      iqamaNo: data.iqamaNo.present ? data.iqamaNo.value : this.iqamaNo,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmploymentPeriod(')
          ..write('periodId: $periodId, ')
          ..write('iqamaNo: $iqamaNo, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(periodId, iqamaNo, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmploymentPeriod &&
          other.periodId == this.periodId &&
          other.iqamaNo == this.iqamaNo &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class EmploymentPeriodsCompanion extends UpdateCompanion<EmploymentPeriod> {
  final Value<String> periodId;
  final Value<String> iqamaNo;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int> rowid;
  const EmploymentPeriodsCompanion({
    this.periodId = const Value.absent(),
    this.iqamaNo = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmploymentPeriodsCompanion.insert({
    required String periodId,
    required String iqamaNo,
    required String startDate,
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : periodId = Value(periodId),
       iqamaNo = Value(iqamaNo),
       startDate = Value(startDate);
  static Insertable<EmploymentPeriod> custom({
    Expression<String>? periodId,
    Expression<String>? iqamaNo,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (periodId != null) 'period_id': periodId,
      if (iqamaNo != null) 'iqama_no': iqamaNo,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmploymentPeriodsCompanion copyWith({
    Value<String>? periodId,
    Value<String>? iqamaNo,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int>? rowid,
  }) {
    return EmploymentPeriodsCompanion(
      periodId: periodId ?? this.periodId,
      iqamaNo: iqamaNo ?? this.iqamaNo,
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
    if (iqamaNo.present) {
      map['iqama_no'] = Variable<String>(iqamaNo.value);
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
          ..write('iqamaNo: $iqamaNo, ')
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

class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pwHashMeta = const VerificationMeta('pwHash');
  @override
  late final GeneratedColumn<String> pwHash = GeneratedColumn<String>(
    'pw_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pwSaltMeta = const VerificationMeta('pwSalt');
  @override
  late final GeneratedColumn<String> pwSalt = GeneratedColumn<String>(
    'pw_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kdfParamsMeta = const VerificationMeta(
    'kdfParams',
  );
  @override
  late final GeneratedColumn<String> kdfParams = GeneratedColumn<String>(
    'kdf_params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mustChangeMeta = const VerificationMeta(
    'mustChange',
  );
  @override
  late final GeneratedColumn<bool> mustChange = GeneratedColumn<bool>(
    'must_change',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("must_change" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    employeeUid,
    displayName,
    role,
    active,
    pwHash,
    pwSalt,
    kdfParams,
    mustChange,
    failedAttempts,
    lockedUntil,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('pw_hash')) {
      context.handle(
        _pwHashMeta,
        pwHash.isAcceptableOrUnknown(data['pw_hash']!, _pwHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pwHashMeta);
    }
    if (data.containsKey('pw_salt')) {
      context.handle(
        _pwSaltMeta,
        pwSalt.isAcceptableOrUnknown(data['pw_salt']!, _pwSaltMeta),
      );
    } else if (isInserting) {
      context.missing(_pwSaltMeta);
    }
    if (data.containsKey('kdf_params')) {
      context.handle(
        _kdfParamsMeta,
        kdfParams.isAcceptableOrUnknown(data['kdf_params']!, _kdfParamsMeta),
      );
    } else if (isInserting) {
      context.missing(_kdfParamsMeta);
    }
    if (data.containsKey('must_change')) {
      context.handle(
        _mustChangeMeta,
        mustChange.isAcceptableOrUnknown(data['must_change']!, _mustChangeMeta),
      );
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_uid'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      pwHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pw_hash'],
      )!,
      pwSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pw_salt'],
      )!,
      kdfParams: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kdf_params'],
      )!,
      mustChange: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}must_change'],
      )!,
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final String id;
  final String? employeeUid;
  final String displayName;
  final String role;
  final bool active;
  final String pwHash;
  final String pwSalt;
  final String kdfParams;
  final bool mustChange;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final DateTime createdAt;
  const AppUser({
    required this.id,
    this.employeeUid,
    required this.displayName,
    required this.role,
    required this.active,
    required this.pwHash,
    required this.pwSalt,
    required this.kdfParams,
    required this.mustChange,
    required this.failedAttempts,
    this.lockedUntil,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || employeeUid != null) {
      map['employee_uid'] = Variable<String>(employeeUid);
    }
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['active'] = Variable<bool>(active);
    map['pw_hash'] = Variable<String>(pwHash);
    map['pw_salt'] = Variable<String>(pwSalt);
    map['kdf_params'] = Variable<String>(kdfParams);
    map['must_change'] = Variable<bool>(mustChange);
    map['failed_attempts'] = Variable<int>(failedAttempts);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      employeeUid: employeeUid == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeUid),
      displayName: Value(displayName),
      role: Value(role),
      active: Value(active),
      pwHash: Value(pwHash),
      pwSalt: Value(pwSalt),
      kdfParams: Value(kdfParams),
      mustChange: Value(mustChange),
      failedAttempts: Value(failedAttempts),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      createdAt: Value(createdAt),
    );
  }

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      id: serializer.fromJson<String>(json['id']),
      employeeUid: serializer.fromJson<String?>(json['employeeUid']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      active: serializer.fromJson<bool>(json['active']),
      pwHash: serializer.fromJson<String>(json['pwHash']),
      pwSalt: serializer.fromJson<String>(json['pwSalt']),
      kdfParams: serializer.fromJson<String>(json['kdfParams']),
      mustChange: serializer.fromJson<bool>(json['mustChange']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeUid': serializer.toJson<String?>(employeeUid),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'active': serializer.toJson<bool>(active),
      'pwHash': serializer.toJson<String>(pwHash),
      'pwSalt': serializer.toJson<String>(pwSalt),
      'kdfParams': serializer.toJson<String>(kdfParams),
      'mustChange': serializer.toJson<bool>(mustChange),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppUser copyWith({
    String? id,
    Value<String?> employeeUid = const Value.absent(),
    String? displayName,
    String? role,
    bool? active,
    String? pwHash,
    String? pwSalt,
    String? kdfParams,
    bool? mustChange,
    int? failedAttempts,
    Value<DateTime?> lockedUntil = const Value.absent(),
    DateTime? createdAt,
  }) => AppUser(
    id: id ?? this.id,
    employeeUid: employeeUid.present ? employeeUid.value : this.employeeUid,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    active: active ?? this.active,
    pwHash: pwHash ?? this.pwHash,
    pwSalt: pwSalt ?? this.pwSalt,
    kdfParams: kdfParams ?? this.kdfParams,
    mustChange: mustChange ?? this.mustChange,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
    createdAt: createdAt ?? this.createdAt,
  );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      id: data.id.present ? data.id.value : this.id,
      employeeUid: data.employeeUid.present
          ? data.employeeUid.value
          : this.employeeUid,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      active: data.active.present ? data.active.value : this.active,
      pwHash: data.pwHash.present ? data.pwHash.value : this.pwHash,
      pwSalt: data.pwSalt.present ? data.pwSalt.value : this.pwSalt,
      kdfParams: data.kdfParams.present ? data.kdfParams.value : this.kdfParams,
      mustChange: data.mustChange.present
          ? data.mustChange.value
          : this.mustChange,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('id: $id, ')
          ..write('employeeUid: $employeeUid, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('active: $active, ')
          ..write('pwHash: $pwHash, ')
          ..write('pwSalt: $pwSalt, ')
          ..write('kdfParams: $kdfParams, ')
          ..write('mustChange: $mustChange, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeUid,
    displayName,
    role,
    active,
    pwHash,
    pwSalt,
    kdfParams,
    mustChange,
    failedAttempts,
    lockedUntil,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.id == this.id &&
          other.employeeUid == this.employeeUid &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.active == this.active &&
          other.pwHash == this.pwHash &&
          other.pwSalt == this.pwSalt &&
          other.kdfParams == this.kdfParams &&
          other.mustChange == this.mustChange &&
          other.failedAttempts == this.failedAttempts &&
          other.lockedUntil == this.lockedUntil &&
          other.createdAt == this.createdAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<String> id;
  final Value<String?> employeeUid;
  final Value<String> displayName;
  final Value<String> role;
  final Value<bool> active;
  final Value<String> pwHash;
  final Value<String> pwSalt;
  final Value<String> kdfParams;
  final Value<bool> mustChange;
  final Value<int> failedAttempts;
  final Value<DateTime?> lockedUntil;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.employeeUid = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.active = const Value.absent(),
    this.pwHash = const Value.absent(),
    this.pwSalt = const Value.absent(),
    this.kdfParams = const Value.absent(),
    this.mustChange = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsersCompanion.insert({
    required String id,
    this.employeeUid = const Value.absent(),
    required String displayName,
    required String role,
    this.active = const Value.absent(),
    required String pwHash,
    required String pwSalt,
    required String kdfParams,
    this.mustChange = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       role = Value(role),
       pwHash = Value(pwHash),
       pwSalt = Value(pwSalt),
       kdfParams = Value(kdfParams),
       createdAt = Value(createdAt);
  static Insertable<AppUser> custom({
    Expression<String>? id,
    Expression<String>? employeeUid,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<bool>? active,
    Expression<String>? pwHash,
    Expression<String>? pwSalt,
    Expression<String>? kdfParams,
    Expression<bool>? mustChange,
    Expression<int>? failedAttempts,
    Expression<DateTime>? lockedUntil,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeUid != null) 'employee_uid': employeeUid,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (active != null) 'active': active,
      if (pwHash != null) 'pw_hash': pwHash,
      if (pwSalt != null) 'pw_salt': pwSalt,
      if (kdfParams != null) 'kdf_params': kdfParams,
      if (mustChange != null) 'must_change': mustChange,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? employeeUid,
    Value<String>? displayName,
    Value<String>? role,
    Value<bool>? active,
    Value<String>? pwHash,
    Value<String>? pwSalt,
    Value<String>? kdfParams,
    Value<bool>? mustChange,
    Value<int>? failedAttempts,
    Value<DateTime?>? lockedUntil,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AppUsersCompanion(
      id: id ?? this.id,
      employeeUid: employeeUid ?? this.employeeUid,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      active: active ?? this.active,
      pwHash: pwHash ?? this.pwHash,
      pwSalt: pwSalt ?? this.pwSalt,
      kdfParams: kdfParams ?? this.kdfParams,
      mustChange: mustChange ?? this.mustChange,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
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
    if (employeeUid.present) {
      map['employee_uid'] = Variable<String>(employeeUid.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (pwHash.present) {
      map['pw_hash'] = Variable<String>(pwHash.value);
    }
    if (pwSalt.present) {
      map['pw_salt'] = Variable<String>(pwSalt.value);
    }
    if (kdfParams.present) {
      map['kdf_params'] = Variable<String>(kdfParams.value);
    }
    if (mustChange.present) {
      map['must_change'] = Variable<bool>(mustChange.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
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
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('employeeUid: $employeeUid, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('active: $active, ')
          ..write('pwHash: $pwHash, ')
          ..write('pwSalt: $pwSalt, ')
          ..write('kdfParams: $kdfParams, ')
          ..write('mustChange: $mustChange, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserScopesTable extends UserScopes
    with TableInfo<$UserScopesTable, UserScope> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserScopesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeTypeMeta = const VerificationMeta(
    'scopeType',
  );
  @override
  late final GeneratedColumn<String> scopeType = GeneratedColumn<String>(
    'scope_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, scopeType, scopeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_scopes';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserScope> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scope_type')) {
      context.handle(
        _scopeTypeMeta,
        scopeType.isAcceptableOrUnknown(data['scope_type']!, _scopeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeTypeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserScope map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserScope(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scopeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_type'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
    );
  }

  @override
  $UserScopesTable createAlias(String alias) {
    return $UserScopesTable(attachedDatabase, alias);
  }
}

class UserScope extends DataClass implements Insertable<UserScope> {
  final String id;
  final String userId;
  final String scopeType;
  final String scopeId;
  const UserScope({
    required this.id,
    required this.userId,
    required this.scopeType,
    required this.scopeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['scope_type'] = Variable<String>(scopeType);
    map['scope_id'] = Variable<String>(scopeId);
    return map;
  }

  UserScopesCompanion toCompanion(bool nullToAbsent) {
    return UserScopesCompanion(
      id: Value(id),
      userId: Value(userId),
      scopeType: Value(scopeType),
      scopeId: Value(scopeId),
    );
  }

  factory UserScope.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserScope(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      scopeType: serializer.fromJson<String>(json['scopeType']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'scopeType': serializer.toJson<String>(scopeType),
      'scopeId': serializer.toJson<String>(scopeId),
    };
  }

  UserScope copyWith({
    String? id,
    String? userId,
    String? scopeType,
    String? scopeId,
  }) => UserScope(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    scopeType: scopeType ?? this.scopeType,
    scopeId: scopeId ?? this.scopeId,
  );
  UserScope copyWithCompanion(UserScopesCompanion data) {
    return UserScope(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      scopeType: data.scopeType.present ? data.scopeType.value : this.scopeType,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserScope(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scopeType: $scopeType, ')
          ..write('scopeId: $scopeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, scopeType, scopeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserScope &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.scopeType == this.scopeType &&
          other.scopeId == this.scopeId);
}

class UserScopesCompanion extends UpdateCompanion<UserScope> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> scopeType;
  final Value<String> scopeId;
  final Value<int> rowid;
  const UserScopesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.scopeType = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserScopesCompanion.insert({
    required String id,
    required String userId,
    required String scopeType,
    required String scopeId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       scopeType = Value(scopeType),
       scopeId = Value(scopeId);
  static Insertable<UserScope> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? scopeType,
    Expression<String>? scopeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (scopeType != null) 'scope_type': scopeType,
      if (scopeId != null) 'scope_id': scopeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserScopesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? scopeType,
    Value<String>? scopeId,
    Value<int>? rowid,
  }) {
    return UserScopesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scopeType: scopeType ?? this.scopeType,
      scopeId: scopeId ?? this.scopeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scopeType.present) {
      map['scope_type'] = Variable<String>(scopeType.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserScopesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scopeType: $scopeType, ')
          ..write('scopeId: $scopeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
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
  @override
  List<GeneratedColumn> get $columns => [
    auditId,
    userId,
    action,
    entityType,
    entityId,
    deviceId,
    deviceTime,
    receivedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
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
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
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
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {auditId};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}device_time'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String auditId;
  final String? userId;
  final String action;
  final String entityType;
  final String entityId;
  final String deviceId;
  final DateTime deviceTime;
  final DateTime? receivedAt;
  final String syncStatus;
  const AuditLog({
    required this.auditId,
    this.userId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.deviceId,
    required this.deviceTime,
    this.receivedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['audit_id'] = Variable<String>(auditId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['device_id'] = Variable<String>(deviceId);
    map['device_time'] = Variable<DateTime>(deviceTime);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      auditId: Value(auditId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      deviceId: Value(deviceId),
      deviceTime: Value(deviceTime),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      auditId: serializer.fromJson<String>(json['auditId']),
      userId: serializer.fromJson<String?>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceTime: serializer.fromJson<DateTime>(json['deviceTime']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'auditId': serializer.toJson<String>(auditId),
      'userId': serializer.toJson<String?>(userId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceTime': serializer.toJson<DateTime>(deviceTime),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  AuditLog copyWith({
    String? auditId,
    Value<String?> userId = const Value.absent(),
    String? action,
    String? entityType,
    String? entityId,
    String? deviceId,
    DateTime? deviceTime,
    Value<DateTime?> receivedAt = const Value.absent(),
    String? syncStatus,
  }) => AuditLog(
    auditId: auditId ?? this.auditId,
    userId: userId.present ? userId.value : this.userId,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    deviceId: deviceId ?? this.deviceId,
    deviceTime: deviceTime ?? this.deviceTime,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('auditId: $auditId, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    auditId,
    userId,
    action,
    entityType,
    entityId,
    deviceId,
    deviceTime,
    receivedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.auditId == this.auditId &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deviceId == this.deviceId &&
          other.deviceTime == this.deviceTime &&
          other.receivedAt == this.receivedAt &&
          other.syncStatus == this.syncStatus);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> auditId;
  final Value<String?> userId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> deviceId;
  final Value<DateTime> deviceTime;
  final Value<DateTime?> receivedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.auditId = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String auditId,
    this.userId = const Value.absent(),
    required String action,
    required String entityType,
    required String entityId,
    required String deviceId,
    required DateTime deviceTime,
    this.receivedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : auditId = Value(auditId),
       action = Value(action),
       entityType = Value(entityType),
       entityId = Value(entityId),
       deviceId = Value(deviceId),
       deviceTime = Value(deviceTime);
  static Insertable<AuditLog> custom({
    Expression<String>? auditId,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? deviceId,
    Expression<DateTime>? deviceTime,
    Expression<DateTime>? receivedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (auditId != null) 'audit_id': auditId,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceTime != null) 'device_time': deviceTime,
      if (receivedAt != null) 'received_at': receivedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? auditId,
    Value<String?>? userId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? deviceId,
    Value<DateTime>? deviceTime,
    Value<DateTime?>? receivedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      auditId: auditId ?? this.auditId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deviceId: deviceId ?? this.deviceId,
      deviceTime: deviceTime ?? this.deviceTime,
      receivedAt: receivedAt ?? this.receivedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<DateTime>(deviceTime.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('auditId: $auditId, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkerHistoryTable extends WorkerHistory
    with TableInfo<$WorkerHistoryTable, WorkerHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkerHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _historyIdMeta = const VerificationMeta(
    'historyId',
  );
  @override
  late final GeneratedColumn<String> historyId = GeneratedColumn<String>(
    'history_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iqamaNoMeta = const VerificationMeta(
    'iqamaNo',
  );
  @override
  late final GeneratedColumn<String> iqamaNo = GeneratedColumn<String>(
    'iqama_no',
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
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
    historyId,
    iqamaNo,
    action,
    details,
    userId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worker_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkerHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('history_id')) {
      context.handle(
        _historyIdMeta,
        historyId.isAcceptableOrUnknown(data['history_id']!, _historyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_historyIdMeta);
    }
    if (data.containsKey('iqama_no')) {
      context.handle(
        _iqamaNoMeta,
        iqamaNo.isAcceptableOrUnknown(data['iqama_no']!, _iqamaNoMeta),
      );
    } else if (isInserting) {
      context.missing(_iqamaNoMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {historyId};
  @override
  WorkerHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkerHistoryData(
      historyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}history_id'],
      )!,
      iqamaNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iqama_no'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkerHistoryTable createAlias(String alias) {
    return $WorkerHistoryTable(attachedDatabase, alias);
  }
}

class WorkerHistoryData extends DataClass
    implements Insertable<WorkerHistoryData> {
  final String historyId;
  final String iqamaNo;
  final String action;
  final String details;
  final String? userId;
  final DateTime createdAt;
  const WorkerHistoryData({
    required this.historyId,
    required this.iqamaNo,
    required this.action,
    required this.details,
    this.userId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['history_id'] = Variable<String>(historyId);
    map['iqama_no'] = Variable<String>(iqamaNo);
    map['action'] = Variable<String>(action);
    map['details'] = Variable<String>(details);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkerHistoryCompanion toCompanion(bool nullToAbsent) {
    return WorkerHistoryCompanion(
      historyId: Value(historyId),
      iqamaNo: Value(iqamaNo),
      action: Value(action),
      details: Value(details),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory WorkerHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkerHistoryData(
      historyId: serializer.fromJson<String>(json['historyId']),
      iqamaNo: serializer.fromJson<String>(json['iqamaNo']),
      action: serializer.fromJson<String>(json['action']),
      details: serializer.fromJson<String>(json['details']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'historyId': serializer.toJson<String>(historyId),
      'iqamaNo': serializer.toJson<String>(iqamaNo),
      'action': serializer.toJson<String>(action),
      'details': serializer.toJson<String>(details),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkerHistoryData copyWith({
    String? historyId,
    String? iqamaNo,
    String? action,
    String? details,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
  }) => WorkerHistoryData(
    historyId: historyId ?? this.historyId,
    iqamaNo: iqamaNo ?? this.iqamaNo,
    action: action ?? this.action,
    details: details ?? this.details,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkerHistoryData copyWithCompanion(WorkerHistoryCompanion data) {
    return WorkerHistoryData(
      historyId: data.historyId.present ? data.historyId.value : this.historyId,
      iqamaNo: data.iqamaNo.present ? data.iqamaNo.value : this.iqamaNo,
      action: data.action.present ? data.action.value : this.action,
      details: data.details.present ? data.details.value : this.details,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkerHistoryData(')
          ..write('historyId: $historyId, ')
          ..write('iqamaNo: $iqamaNo, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(historyId, iqamaNo, action, details, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkerHistoryData &&
          other.historyId == this.historyId &&
          other.iqamaNo == this.iqamaNo &&
          other.action == this.action &&
          other.details == this.details &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class WorkerHistoryCompanion extends UpdateCompanion<WorkerHistoryData> {
  final Value<String> historyId;
  final Value<String> iqamaNo;
  final Value<String> action;
  final Value<String> details;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WorkerHistoryCompanion({
    this.historyId = const Value.absent(),
    this.iqamaNo = const Value.absent(),
    this.action = const Value.absent(),
    this.details = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkerHistoryCompanion.insert({
    required String historyId,
    required String iqamaNo,
    required String action,
    this.details = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : historyId = Value(historyId),
       iqamaNo = Value(iqamaNo),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<WorkerHistoryData> custom({
    Expression<String>? historyId,
    Expression<String>? iqamaNo,
    Expression<String>? action,
    Expression<String>? details,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (historyId != null) 'history_id': historyId,
      if (iqamaNo != null) 'iqama_no': iqamaNo,
      if (action != null) 'action': action,
      if (details != null) 'details': details,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkerHistoryCompanion copyWith({
    Value<String>? historyId,
    Value<String>? iqamaNo,
    Value<String>? action,
    Value<String>? details,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkerHistoryCompanion(
      historyId: historyId ?? this.historyId,
      iqamaNo: iqamaNo ?? this.iqamaNo,
      action: action ?? this.action,
      details: details ?? this.details,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (historyId.present) {
      map['history_id'] = Variable<String>(historyId.value);
    }
    if (iqamaNo.present) {
      map['iqama_no'] = Variable<String>(iqamaNo.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
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
    return (StringBuffer('WorkerHistoryCompanion(')
          ..write('historyId: $historyId, ')
          ..write('iqamaNo: $iqamaNo, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
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
  late final $EmploymentPeriodsTable employmentPeriods =
      $EmploymentPeriodsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $UserScopesTable userScopes = $UserScopesTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $WorkerHistoryTable workerHistory = $WorkerHistoryTable(this);
  late final Index employmentPeriodIqamaStart = Index(
    'employment_period_iqama_start',
    'CREATE INDEX employment_period_iqama_start ON employment_periods (iqama_no, start_date)',
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
  late final Index workerHistoryIqamaIdx = Index(
    'worker_history_iqama_idx',
    'CREATE INDEX worker_history_iqama_idx ON worker_history (iqama_no)',
  );
  late final Index workerHistoryCreatedAtIdx = Index(
    'worker_history_created_at_idx',
    'CREATE INDEX worker_history_created_at_idx ON worker_history (created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    employees,
    teams,
    employmentPeriods,
    events,
    appUsers,
    userScopes,
    auditLogs,
    workerHistory,
    employmentPeriodIqamaStart,
    eventsDeviceSequenceUnique,
    eventsBusinessDate,
    eventsEmployeeBusinessDate,
    eventsSyncSequence,
    workerHistoryIqamaIdx,
    workerHistoryCreatedAtIdx,
  ];
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
  required String iqamaNo,
  required String fullNameAr,
  Value<String?> fullNameEn,
  Value<String?> jobTitle,
  Value<String> jobCategory,
  Value<String> employmentType,
  Value<String?> rentalCompany,
  Value<DateTime?> iqamaExpiry,
  Value<String?> currentTeamId,
  Value<DateTime?> archivedAt,
  Value<int> rowVersion,
  Value<int> rowid,
});
typedef $$EmployeesTableUpdateCompanionBuilder = EmployeesCompanion Function({
  Value<String> iqamaNo,
  Value<String> fullNameAr,
  Value<String?> fullNameEn,
  Value<String?> jobTitle,
  Value<String> jobCategory,
  Value<String> employmentType,
  Value<String?> rentalCompany,
  Value<DateTime?> iqamaExpiry,
  Value<String?> currentTeamId,
  Value<DateTime?> archivedAt,
  Value<int> rowVersion,
  Value<int> rowid,
});

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get iqamaNo => $composableBuilder(
    column: $table.iqamaNo,
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

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobCategory => $composableBuilder(
    column: $table.jobCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rentalCompany => $composableBuilder(
    column: $table.rentalCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get iqamaExpiry => $composableBuilder(
    column: $table.iqamaExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentTeamId => $composableBuilder(
    column: $table.currentTeamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get iqamaNo => $composableBuilder(
    column: $table.iqamaNo,
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

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobCategory => $composableBuilder(
    column: $table.jobCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rentalCompany => $composableBuilder(
    column: $table.rentalCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get iqamaExpiry => $composableBuilder(
    column: $table.iqamaExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentTeamId => $composableBuilder(
    column: $table.currentTeamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
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
  GeneratedColumn<String> get iqamaNo =>
      $composableBuilder(column: $table.iqamaNo, builder: (column) => column);

  GeneratedColumn<String> get fullNameAr => $composableBuilder(
    column: $table.fullNameAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullNameEn => $composableBuilder(
    column: $table.fullNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<String> get jobCategory => $composableBuilder(
    column: $table.jobCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rentalCompany => $composableBuilder(
    column: $table.rentalCompany,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get iqamaExpiry => $composableBuilder(
    column: $table.iqamaExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentTeamId => $composableBuilder(
    column: $table.currentTeamId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );
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
          (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
          Employee,
          PrefetchHooks Function()
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
                Value<String> iqamaNo = const Value.absent(),
                Value<String> fullNameAr = const Value.absent(),
                Value<String?> fullNameEn = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<String> jobCategory = const Value.absent(),
                Value<String> employmentType = const Value.absent(),
                Value<String?> rentalCompany = const Value.absent(),
                Value<DateTime?> iqamaExpiry = const Value.absent(),
                Value<String?> currentTeamId = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion(
                iqamaNo: iqamaNo,
                fullNameAr: fullNameAr,
                fullNameEn: fullNameEn,
                jobTitle: jobTitle,
                jobCategory: jobCategory,
                employmentType: employmentType,
                rentalCompany: rentalCompany,
                iqamaExpiry: iqamaExpiry,
                currentTeamId: currentTeamId,
                archivedAt: archivedAt,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String iqamaNo,
                required String fullNameAr,
                Value<String?> fullNameEn = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<String> jobCategory = const Value.absent(),
                Value<String> employmentType = const Value.absent(),
                Value<String?> rentalCompany = const Value.absent(),
                Value<DateTime?> iqamaExpiry = const Value.absent(),
                Value<String?> currentTeamId = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion.insert(
                iqamaNo: iqamaNo,
                fullNameAr: fullNameAr,
                fullNameEn: fullNameEn,
                jobTitle: jobTitle,
                jobCategory: jobCategory,
                employmentType: employmentType,
                rentalCompany: rentalCompany,
                iqamaExpiry: iqamaExpiry,
                currentTeamId: currentTeamId,
                archivedAt: archivedAt,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmployeesTable, Employee>(table),
                  BaseReferences<_$AppDatabase, $EmployeesTable, Employee>(
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
      (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
      Employee,
      PrefetchHooks Function()
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
typedef $$EmploymentPeriodsTableCreateCompanionBuilder =
    EmploymentPeriodsCompanion Function({
      required String periodId,
      required String iqamaNo,
      required String startDate,
      Value<String?> endDate,
      Value<int> rowid,
    });
typedef $$EmploymentPeriodsTableUpdateCompanionBuilder =
    EmploymentPeriodsCompanion Function({
      Value<String> periodId,
      Value<String> iqamaNo,
      Value<String> startDate,
      Value<String?> endDate,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get iqamaNo => $composableBuilder(
    column: $table.iqamaNo,
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

  ColumnOrderings<String> get iqamaNo => $composableBuilder(
    column: $table.iqamaNo,
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

  GeneratedColumn<String> get iqamaNo =>
      $composableBuilder(column: $table.iqamaNo, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);
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
          (
            EmploymentPeriod,
            BaseReferences<
              _$AppDatabase,
              $EmploymentPeriodsTable,
              EmploymentPeriod
            >,
          ),
          EmploymentPeriod,
          PrefetchHooks Function()
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
                Value<String> iqamaNo = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmploymentPeriodsCompanion(
                periodId: periodId,
                iqamaNo: iqamaNo,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String periodId,
                required String iqamaNo,
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmploymentPeriodsCompanion.insert(
                periodId: periodId,
                iqamaNo: iqamaNo,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmploymentPeriodsTable, EmploymentPeriod>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EmploymentPeriodsTable,
                    EmploymentPeriod
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
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
      (
        EmploymentPeriod,
        BaseReferences<
          _$AppDatabase,
          $EmploymentPeriodsTable,
          EmploymentPeriod
        >,
      ),
      EmploymentPeriod,
      PrefetchHooks Function()
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
typedef $$AppUsersTableCreateCompanionBuilder = AppUsersCompanion Function({
  required String id,
  Value<String?> employeeUid,
  required String displayName,
  required String role,
  Value<bool> active,
  required String pwHash,
  required String pwSalt,
  required String kdfParams,
  Value<bool> mustChange,
  Value<int> failedAttempts,
  Value<DateTime?> lockedUntil,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AppUsersTableUpdateCompanionBuilder = AppUsersCompanion Function({
  Value<String> id,
  Value<String?> employeeUid,
  Value<String> displayName,
  Value<String> role,
  Value<bool> active,
  Value<String> pwHash,
  Value<String> pwSalt,
  Value<String> kdfParams,
  Value<bool> mustChange,
  Value<int> failedAttempts,
  Value<DateTime?> lockedUntil,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
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

  ColumnFilters<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pwHash => $composableBuilder(
    column: $table.pwHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pwSalt => $composableBuilder(
    column: $table.pwSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kdfParams => $composableBuilder(
    column: $table.kdfParams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mustChange => $composableBuilder(
    column: $table.mustChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
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

  ColumnOrderings<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pwHash => $composableBuilder(
    column: $table.pwHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pwSalt => $composableBuilder(
    column: $table.pwSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kdfParams => $composableBuilder(
    column: $table.kdfParams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mustChange => $composableBuilder(
    column: $table.mustChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeUid => $composableBuilder(
    column: $table.employeeUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get pwHash =>
      $composableBuilder(column: $table.pwHash, builder: (column) => column);

  GeneratedColumn<String> get pwSalt =>
      $composableBuilder(column: $table.pwSalt, builder: (column) => column);

  GeneratedColumn<String> get kdfParams =>
      $composableBuilder(column: $table.kdfParams, builder: (column) => column);

  GeneratedColumn<bool> get mustChange => $composableBuilder(
    column: $table.mustChange,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUser,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
          AppUser,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> employeeUid = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> pwHash = const Value.absent(),
                Value<String> pwSalt = const Value.absent(),
                Value<String> kdfParams = const Value.absent(),
                Value<bool> mustChange = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                employeeUid: employeeUid,
                displayName: displayName,
                role: role,
                active: active,
                pwHash: pwHash,
                pwSalt: pwSalt,
                kdfParams: kdfParams,
                mustChange: mustChange,
                failedAttempts: failedAttempts,
                lockedUntil: lockedUntil,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> employeeUid = const Value.absent(),
                required String displayName,
                required String role,
                Value<bool> active = const Value.absent(),
                required String pwHash,
                required String pwSalt,
                required String kdfParams,
                Value<bool> mustChange = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                employeeUid: employeeUid,
                displayName: displayName,
                role: role,
                active: active,
                pwHash: pwHash,
                pwSalt: pwSalt,
                kdfParams: kdfParams,
                mustChange: mustChange,
                failedAttempts: failedAttempts,
                lockedUntil: lockedUntil,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppUsersTable, AppUser>(table),
                  BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>(
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

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUser,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
      AppUser,
      PrefetchHooks Function()
    >;
typedef $$UserScopesTableCreateCompanionBuilder = UserScopesCompanion Function({
  required String id,
  required String userId,
  required String scopeType,
  required String scopeId,
  Value<int> rowid,
});
typedef $$UserScopesTableUpdateCompanionBuilder = UserScopesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> scopeType,
  Value<String> scopeId,
  Value<int> rowid,
});

class $$UserScopesTableFilterComposer
    extends Composer<_$AppDatabase, $UserScopesTable> {
  $$UserScopesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeType => $composableBuilder(
    column: $table.scopeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserScopesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserScopesTable> {
  $$UserScopesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeType => $composableBuilder(
    column: $table.scopeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserScopesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserScopesTable> {
  $$UserScopesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get scopeType =>
      $composableBuilder(column: $table.scopeType, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);
}

class $$UserScopesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserScopesTable,
          UserScope,
          $$UserScopesTableFilterComposer,
          $$UserScopesTableOrderingComposer,
          $$UserScopesTableAnnotationComposer,
          $$UserScopesTableCreateCompanionBuilder,
          $$UserScopesTableUpdateCompanionBuilder,
          (
            UserScope,
            BaseReferences<_$AppDatabase, $UserScopesTable, UserScope>,
          ),
          UserScope,
          PrefetchHooks Function()
        > {
  $$UserScopesTableTableManager(_$AppDatabase db, $UserScopesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserScopesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserScopesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserScopesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> scopeType = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserScopesCompanion(
                id: id,
                userId: userId,
                scopeType: scopeType,
                scopeId: scopeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String scopeType,
                required String scopeId,
                Value<int> rowid = const Value.absent(),
              }) => UserScopesCompanion.insert(
                id: id,
                userId: userId,
                scopeType: scopeType,
                scopeId: scopeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserScopesTable, UserScope>(table),
                  BaseReferences<_$AppDatabase, $UserScopesTable, UserScope>(
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

typedef $$UserScopesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserScopesTable,
      UserScope,
      $$UserScopesTableFilterComposer,
      $$UserScopesTableOrderingComposer,
      $$UserScopesTableAnnotationComposer,
      $$UserScopesTableCreateCompanionBuilder,
      $$UserScopesTableUpdateCompanionBuilder,
      (UserScope, BaseReferences<_$AppDatabase, $UserScopesTable, UserScope>),
      UserScope,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String auditId,
  Value<String?> userId,
  required String action,
  required String entityType,
  required String entityId,
  required String deviceId,
  required DateTime deviceTime,
  Value<DateTime?> receivedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> auditId,
  Value<String?> userId,
  Value<String> action,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> deviceId,
  Value<DateTime> deviceTime,
  Value<DateTime?> receivedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
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

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
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

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get auditId =>
      $composableBuilder(column: $table.auditId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> auditId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> deviceTime = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                auditId: auditId,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                deviceId: deviceId,
                deviceTime: deviceTime,
                receivedAt: receivedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String auditId,
                Value<String?> userId = const Value.absent(),
                required String action,
                required String entityType,
                required String entityId,
                required String deviceId,
                required DateTime deviceTime,
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                auditId: auditId,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                deviceId: deviceId,
                deviceTime: deviceTime,
                receivedAt: receivedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>(
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

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$WorkerHistoryTableCreateCompanionBuilder =
    WorkerHistoryCompanion Function({
      required String historyId,
      required String iqamaNo,
      required String action,
      Value<String> details,
      Value<String?> userId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WorkerHistoryTableUpdateCompanionBuilder =
    WorkerHistoryCompanion Function({
      Value<String> historyId,
      Value<String> iqamaNo,
      Value<String> action,
      Value<String> details,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WorkerHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $WorkerHistoryTable> {
  $$WorkerHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get historyId => $composableBuilder(
    column: $table.historyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iqamaNo => $composableBuilder(
    column: $table.iqamaNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkerHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkerHistoryTable> {
  $$WorkerHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get historyId => $composableBuilder(
    column: $table.historyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iqamaNo => $composableBuilder(
    column: $table.iqamaNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkerHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkerHistoryTable> {
  $$WorkerHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get historyId =>
      $composableBuilder(column: $table.historyId, builder: (column) => column);

  GeneratedColumn<String> get iqamaNo =>
      $composableBuilder(column: $table.iqamaNo, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkerHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkerHistoryTable,
          WorkerHistoryData,
          $$WorkerHistoryTableFilterComposer,
          $$WorkerHistoryTableOrderingComposer,
          $$WorkerHistoryTableAnnotationComposer,
          $$WorkerHistoryTableCreateCompanionBuilder,
          $$WorkerHistoryTableUpdateCompanionBuilder,
          (
            WorkerHistoryData,
            BaseReferences<
              _$AppDatabase,
              $WorkerHistoryTable,
              WorkerHistoryData
            >,
          ),
          WorkerHistoryData,
          PrefetchHooks Function()
        > {
  $$WorkerHistoryTableTableManager(_$AppDatabase db, $WorkerHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkerHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkerHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkerHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> historyId = const Value.absent(),
                Value<String> iqamaNo = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> details = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkerHistoryCompanion(
                historyId: historyId,
                iqamaNo: iqamaNo,
                action: action,
                details: details,
                userId: userId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String historyId,
                required String iqamaNo,
                required String action,
                Value<String> details = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkerHistoryCompanion.insert(
                historyId: historyId,
                iqamaNo: iqamaNo,
                action: action,
                details: details,
                userId: userId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkerHistoryTable, WorkerHistoryData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkerHistoryTable,
                    WorkerHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkerHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkerHistoryTable,
      WorkerHistoryData,
      $$WorkerHistoryTableFilterComposer,
      $$WorkerHistoryTableOrderingComposer,
      $$WorkerHistoryTableAnnotationComposer,
      $$WorkerHistoryTableCreateCompanionBuilder,
      $$WorkerHistoryTableUpdateCompanionBuilder,
      (
        WorkerHistoryData,
        BaseReferences<_$AppDatabase, $WorkerHistoryTable, WorkerHistoryData>,
      ),
      WorkerHistoryData,
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
  $$EmploymentPeriodsTableTableManager get employmentPeriods =>
      $$EmploymentPeriodsTableTableManager(_db, _db.employmentPeriods);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$UserScopesTableTableManager get userScopes =>
      $$UserScopesTableTableManager(_db, _db.userScopes);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$WorkerHistoryTableTableManager get workerHistory =>
      $$WorkerHistoryTableTableManager(_db, _db.workerHistory);
}
