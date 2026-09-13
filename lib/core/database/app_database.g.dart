// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    type,
    currency,
    initialBalance,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AccountsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static TypeConverter<AccountType, String> $convertertype =
      accountTypeConverter;
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final AccountType type;
  final String currency;
  final int initialBalance;
  final bool isArchived;
  const Account({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.type,
    required this.currency,
    required this.initialBalance,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($AccountsTable.$convertertype.toSql(type));
    }
    map['currency'] = Variable<String>(currency);
    map['initial_balance'] = Variable<int>(initialBalance);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      initialBalance: Value(initialBalance),
      isArchived: Value(isArchived),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<AccountType>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      initialBalance: serializer.fromJson<int>(json['initialBalance']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<AccountType>(type),
      'currency': serializer.toJson<String>(currency),
      'initialBalance': serializer.toJson<int>(initialBalance),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Account copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    AccountType? type,
    String? currency,
    int? initialBalance,
    bool? isArchived,
  }) => Account(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    initialBalance: initialBalance ?? this.initialBalance,
    isArchived: isArchived ?? this.isArchived,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    name,
    type,
    currency,
    initialBalance,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.initialBalance == this.initialBalance &&
          other.isArchived == this.isArchived);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<String> currency;
  final Value<int> initialBalance;
  final Value<bool> isArchived;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    required AccountType type,
    required String currency,
    this.initialBalance = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       currency = Value(currency);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<int>? initialBalance,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<AccountType>? type,
    Value<String>? currency,
    Value<int>? initialBalance,
    Value<bool>? isArchived,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AccountsTable.$convertertype.toSql(type.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryKind>($CategoriesTable.$converterkind);
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    kind,
    parentId,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $CategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<CategoryKind, String> $converterkind =
      categoryKindConverter;
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final CategoryKind kind;
  final int? parentId;
  final bool isArchived;
  const Category({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.kind,
    this.parentId,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      kind: Value(kind),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isArchived: Value(isArchived),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<CategoryKind>(json['kind']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<CategoryKind>(kind),
      'parentId': serializer.toJson<int?>(parentId),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Category copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    CategoryKind? kind,
    Value<int?> parentId = const Value.absent(),
    bool? isArchived,
  }) => Category(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    parentId: parentId.present ? parentId.value : this.parentId,
    isArchived: isArchived ?? this.isArchived,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, name, kind, parentId, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.parentId == this.parentId &&
          other.isArchived == this.isArchived);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<CategoryKind> kind;
  final Value<int?> parentId;
  final Value<bool> isArchived;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    required CategoryKind kind,
    this.parentId = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? parentId,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (parentId != null) 'parent_id': parentId,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<CategoryKind>? kind,
    Value<int?>? parentId,
    Value<bool>? isArchived,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      parentId: parentId ?? this.parentId,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    contact,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String? contact;
  final bool isArchived;
  const Client({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.contact,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      isArchived: Value(isArchived),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String?>(contact),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Client copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    Value<String?> contact = const Value.absent(),
    bool? isArchived,
  }) => Client(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    contact: contact.present ? contact.value : this.contact,
    isArchived: isArchived ?? this.isArchived,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, name, contact, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.isArchived == this.isArchived);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<String?> contact;
  final Value<bool> isArchived;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    this.contact = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Client> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  ClientsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<String?>? contact,
    Value<bool>? isArchived,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BillingType?, String>
  billingType = GeneratedColumn<String>(
    'billing_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<BillingType?>($ProjectsTable.$converterbillingTypen);
  static const VerificationMeta _estimatedAmountMeta = const VerificationMeta(
    'estimatedAmount',
  );
  @override
  late final GeneratedColumn<int> estimatedAmount = GeneratedColumn<int>(
    'estimated_amount',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    id,
    createdAt,
    updatedAt,
    clientId,
    name,
    billingType,
    estimatedAmount,
    currency,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('estimated_amount')) {
      context.handle(
        _estimatedAmountMeta,
        estimatedAmount.isAcceptableOrUnknown(
          data['estimated_amount']!,
          _estimatedAmountMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      billingType: $ProjectsTable.$converterbillingTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}billing_type'],
        ),
      ),
      estimatedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_amount'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static TypeConverter<BillingType, String> $converterbillingType =
      billingTypeConverter;
  static TypeConverter<BillingType?, String?> $converterbillingTypen =
      NullAwareTypeConverter.wrap($converterbillingType);
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int clientId;
  final String name;
  final BillingType? billingType;
  final int? estimatedAmount;
  final String currency;
  final bool isActive;
  const Project({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.clientId,
    required this.name,
    this.billingType,
    this.estimatedAmount,
    required this.currency,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['client_id'] = Variable<int>(clientId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || billingType != null) {
      map['billing_type'] = Variable<String>(
        $ProjectsTable.$converterbillingTypen.toSql(billingType),
      );
    }
    if (!nullToAbsent || estimatedAmount != null) {
      map['estimated_amount'] = Variable<int>(estimatedAmount);
    }
    map['currency'] = Variable<String>(currency);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      clientId: Value(clientId),
      name: Value(name),
      billingType: billingType == null && nullToAbsent
          ? const Value.absent()
          : Value(billingType),
      estimatedAmount: estimatedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedAmount),
      currency: Value(currency),
      isActive: Value(isActive),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      clientId: serializer.fromJson<int>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      billingType: serializer.fromJson<BillingType?>(json['billingType']),
      estimatedAmount: serializer.fromJson<int?>(json['estimatedAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'clientId': serializer.toJson<int>(clientId),
      'name': serializer.toJson<String>(name),
      'billingType': serializer.toJson<BillingType?>(billingType),
      'estimatedAmount': serializer.toJson<int?>(estimatedAmount),
      'currency': serializer.toJson<String>(currency),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Project copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? clientId,
    String? name,
    Value<BillingType?> billingType = const Value.absent(),
    Value<int?> estimatedAmount = const Value.absent(),
    String? currency,
    bool? isActive,
  }) => Project(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    clientId: clientId ?? this.clientId,
    name: name ?? this.name,
    billingType: billingType.present ? billingType.value : this.billingType,
    estimatedAmount: estimatedAmount.present
        ? estimatedAmount.value
        : this.estimatedAmount,
    currency: currency ?? this.currency,
    isActive: isActive ?? this.isActive,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      billingType: data.billingType.present
          ? data.billingType.value
          : this.billingType,
      estimatedAmount: data.estimatedAmount.present
          ? data.estimatedAmount.value
          : this.estimatedAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('billingType: $billingType, ')
          ..write('estimatedAmount: $estimatedAmount, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    clientId,
    name,
    billingType,
    estimatedAmount,
    currency,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.billingType == this.billingType &&
          other.estimatedAmount == this.estimatedAmount &&
          other.currency == this.currency &&
          other.isActive == this.isActive);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> clientId;
  final Value<String> name;
  final Value<BillingType?> billingType;
  final Value<int?> estimatedAmount;
  final Value<String> currency;
  final Value<bool> isActive;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.billingType = const Value.absent(),
    this.estimatedAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required int clientId,
    required String name,
    this.billingType = const Value.absent(),
    this.estimatedAmount = const Value.absent(),
    required String currency,
    this.isActive = const Value.absent(),
  }) : clientId = Value(clientId),
       name = Value(name),
       currency = Value(currency);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? clientId,
    Expression<String>? name,
    Expression<String>? billingType,
    Expression<int>? estimatedAmount,
    Expression<String>? currency,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (billingType != null) 'billing_type': billingType,
      if (estimatedAmount != null) 'estimated_amount': estimatedAmount,
      if (currency != null) 'currency': currency,
      if (isActive != null) 'is_active': isActive,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? clientId,
    Value<String>? name,
    Value<BillingType?>? billingType,
    Value<int?>? estimatedAmount,
    Value<String>? currency,
    Value<bool>? isActive,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      billingType: billingType ?? this.billingType,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (billingType.present) {
      map['billing_type'] = Variable<String>(
        $ProjectsTable.$converterbillingTypen.toSql(billingType.value),
      );
    }
    if (estimatedAmount.present) {
      map['estimated_amount'] = Variable<int>(estimatedAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('billingType: $billingType, ')
          ..write('estimatedAmount: $estimatedAmount, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $SalarySourcesTable extends SalarySources
    with TableInfo<$SalarySourcesTable, SalarySource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalarySourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAmountMeta = const VerificationMeta(
    'expectedAmount',
  );
  @override
  late final GeneratedColumn<int> expectedAmount = GeneratedColumn<int>(
    'expected_amount',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceFrequency?, String>
  frequency =
      GeneratedColumn<String>(
        'frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RecurrenceFrequency?>(
        $SalarySourcesTable.$converterfrequencyn,
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
    id,
    createdAt,
    updatedAt,
    name,
    expectedAmount,
    currency,
    frequency,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalarySource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('expected_amount')) {
      context.handle(
        _expectedAmountMeta,
        expectedAmount.isAcceptableOrUnknown(
          data['expected_amount']!,
          _expectedAmountMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalarySource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalarySource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      expectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      frequency: $SalarySourcesTable.$converterfrequencyn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        ),
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $SalarySourcesTable createAlias(String alias) {
    return $SalarySourcesTable(attachedDatabase, alias);
  }

  static TypeConverter<RecurrenceFrequency, String> $converterfrequency =
      recurrenceFrequencyConverter;
  static TypeConverter<RecurrenceFrequency?, String?> $converterfrequencyn =
      NullAwareTypeConverter.wrap($converterfrequency);
}

class SalarySource extends DataClass implements Insertable<SalarySource> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final int? expectedAmount;
  final String currency;
  final RecurrenceFrequency? frequency;
  final bool isActive;
  const SalarySource({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.expectedAmount,
    required this.currency,
    this.frequency,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || expectedAmount != null) {
      map['expected_amount'] = Variable<int>(expectedAmount);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(
        $SalarySourcesTable.$converterfrequencyn.toSql(frequency),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SalarySourcesCompanion toCompanion(bool nullToAbsent) {
    return SalarySourcesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      expectedAmount: expectedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedAmount),
      currency: Value(currency),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      isActive: Value(isActive),
    );
  }

  factory SalarySource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalarySource(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      expectedAmount: serializer.fromJson<int?>(json['expectedAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      frequency: serializer.fromJson<RecurrenceFrequency?>(json['frequency']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'expectedAmount': serializer.toJson<int?>(expectedAmount),
      'currency': serializer.toJson<String>(currency),
      'frequency': serializer.toJson<RecurrenceFrequency?>(frequency),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  SalarySource copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    Value<int?> expectedAmount = const Value.absent(),
    String? currency,
    Value<RecurrenceFrequency?> frequency = const Value.absent(),
    bool? isActive,
  }) => SalarySource(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    expectedAmount: expectedAmount.present
        ? expectedAmount.value
        : this.expectedAmount,
    currency: currency ?? this.currency,
    frequency: frequency.present ? frequency.value : this.frequency,
    isActive: isActive ?? this.isActive,
  );
  SalarySource copyWithCompanion(SalarySourcesCompanion data) {
    return SalarySource(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      expectedAmount: data.expectedAmount.present
          ? data.expectedAmount.value
          : this.expectedAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalarySource(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('currency: $currency, ')
          ..write('frequency: $frequency, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    name,
    expectedAmount,
    currency,
    frequency,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalarySource &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.expectedAmount == this.expectedAmount &&
          other.currency == this.currency &&
          other.frequency == this.frequency &&
          other.isActive == this.isActive);
}

class SalarySourcesCompanion extends UpdateCompanion<SalarySource> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<int?> expectedAmount;
  final Value<String> currency;
  final Value<RecurrenceFrequency?> frequency;
  final Value<bool> isActive;
  const SalarySourcesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.expectedAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.frequency = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  SalarySourcesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    this.expectedAmount = const Value.absent(),
    required String currency,
    this.frequency = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       currency = Value(currency);
  static Insertable<SalarySource> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<int>? expectedAmount,
    Expression<String>? currency,
    Expression<String>? frequency,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (expectedAmount != null) 'expected_amount': expectedAmount,
      if (currency != null) 'currency': currency,
      if (frequency != null) 'frequency': frequency,
      if (isActive != null) 'is_active': isActive,
    });
  }

  SalarySourcesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<int?>? expectedAmount,
    Value<String>? currency,
    Value<RecurrenceFrequency?>? frequency,
    Value<bool>? isActive,
  }) {
    return SalarySourcesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (expectedAmount.present) {
      map['expected_amount'] = Variable<int>(expectedAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $SalarySourcesTable.$converterfrequencyn.toSql(frequency.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalarySourcesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('currency: $currency, ')
          ..write('frequency: $frequency, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAmountMeta = const VerificationMeta(
    'currentAmount',
  );
  @override
  late final GeneratedColumn<int> currentAmount = GeneratedColumn<int>(
    'current_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyContributionMeta =
      const VerificationMeta('monthlyContribution');
  @override
  late final GeneratedColumn<int> monthlyContribution = GeneratedColumn<int>(
    'monthly_contribution',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    targetAmount,
    currentAmount,
    monthlyContribution,
    currency,
    targetDate,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
        _currentAmountMeta,
        currentAmount.isAcceptableOrUnknown(
          data['current_amount']!,
          _currentAmountMeta,
        ),
      );
    }
    if (data.containsKey('monthly_contribution')) {
      context.handle(
        _monthlyContributionMeta,
        monthlyContribution.isAcceptableOrUnknown(
          data['monthly_contribution']!,
          _monthlyContributionMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount'],
      )!,
      currentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_amount'],
      ),
      monthlyContribution: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_contribution'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final int targetAmount;
  final int? currentAmount;
  final int? monthlyContribution;
  final String currency;
  final DateTime? targetDate;
  final bool isArchived;
  const SavingsGoal({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.targetAmount,
    this.currentAmount,
    this.monthlyContribution,
    required this.currency,
    this.targetDate,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<int>(targetAmount);
    if (!nullToAbsent || currentAmount != null) {
      map['current_amount'] = Variable<int>(currentAmount);
    }
    if (!nullToAbsent || monthlyContribution != null) {
      map['monthly_contribution'] = Variable<int>(monthlyContribution);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: currentAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(currentAmount),
      monthlyContribution: monthlyContribution == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyContribution),
      currency: Value(currency),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      isArchived: Value(isArchived),
    );
  }

  factory SavingsGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      currentAmount: serializer.fromJson<int?>(json['currentAmount']),
      monthlyContribution: serializer.fromJson<int?>(
        json['monthlyContribution'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'currentAmount': serializer.toJson<int?>(currentAmount),
      'monthlyContribution': serializer.toJson<int?>(monthlyContribution),
      'currency': serializer.toJson<String>(currency),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  SavingsGoal copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    int? targetAmount,
    Value<int?> currentAmount = const Value.absent(),
    Value<int?> monthlyContribution = const Value.absent(),
    String? currency,
    Value<DateTime?> targetDate = const Value.absent(),
    bool? isArchived,
  }) => SavingsGoal(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount.present
        ? currentAmount.value
        : this.currentAmount,
    monthlyContribution: monthlyContribution.present
        ? monthlyContribution.value
        : this.monthlyContribution,
    currency: currency ?? this.currency,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    isArchived: isArchived ?? this.isArchived,
  );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      monthlyContribution: data.monthlyContribution.present
          ? data.monthlyContribution.value
          : this.monthlyContribution,
      currency: data.currency.present ? data.currency.value : this.currency,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('monthlyContribution: $monthlyContribution, ')
          ..write('currency: $currency, ')
          ..write('targetDate: $targetDate, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    name,
    targetAmount,
    currentAmount,
    monthlyContribution,
    currency,
    targetDate,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.monthlyContribution == this.monthlyContribution &&
          other.currency == this.currency &&
          other.targetDate == this.targetDate &&
          other.isArchived == this.isArchived);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<int> targetAmount;
  final Value<int?> currentAmount;
  final Value<int?> monthlyContribution;
  final Value<String> currency;
  final Value<DateTime?> targetDate;
  final Value<bool> isArchived;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.monthlyContribution = const Value.absent(),
    this.currency = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    required int targetAmount,
    this.currentAmount = const Value.absent(),
    this.monthlyContribution = const Value.absent(),
    required String currency,
    this.targetDate = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : name = Value(name),
       targetAmount = Value(targetAmount),
       currency = Value(currency);
  static Insertable<SavingsGoal> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<int>? targetAmount,
    Expression<int>? currentAmount,
    Expression<int>? monthlyContribution,
    Expression<String>? currency,
    Expression<DateTime>? targetDate,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (monthlyContribution != null)
        'monthly_contribution': monthlyContribution,
      if (currency != null) 'currency': currency,
      if (targetDate != null) 'target_date': targetDate,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<int>? targetAmount,
    Value<int?>? currentAmount,
    Value<int?>? monthlyContribution,
    Value<String>? currency,
    Value<DateTime?>? targetDate,
    Value<bool>? isArchived,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<int>(currentAmount.value);
    }
    if (monthlyContribution.present) {
      map['monthly_contribution'] = Variable<int>(monthlyContribution.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('monthlyContribution: $monthlyContribution, ')
          ..write('currency: $currency, ')
          ..write('targetDate: $targetDate, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MovementType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MovementType>($RecurringRulesTable.$convertertype);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<int> destinationAccountId = GeneratedColumn<int>(
    'destination_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceFrequency, String>
  frequency =
      GeneratedColumn<String>(
        'frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecurrenceFrequency>(
        $RecurringRulesTable.$converterfrequency,
      );
  static const VerificationMeta _intervalCountMeta = const VerificationMeta(
    'intervalCount',
  );
  @override
  late final GeneratedColumn<int> intervalCount = GeneratedColumn<int>(
    'interval_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthDayMeta = const VerificationMeta(
    'monthDay',
  );
  @override
  late final GeneratedColumn<int> monthDay = GeneratedColumn<int>(
    'month_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDateMeta = const VerificationMeta(
    'nextDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDate = GeneratedColumn<DateTime>(
    'next_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _autoGenerateMeta = const VerificationMeta(
    'autoGenerate',
  );
  @override
  late final GeneratedColumn<bool> autoGenerate = GeneratedColumn<bool>(
    'auto_generate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_generate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    concept,
    type,
    accountId,
    destinationAccountId,
    categoryId,
    amount,
    currency,
    frequency,
    intervalCount,
    startDate,
    endDate,
    monthDay,
    weekday,
    nextDate,
    isActive,
    autoGenerate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('interval_count')) {
      context.handle(
        _intervalCountMeta,
        intervalCount.isAcceptableOrUnknown(
          data['interval_count']!,
          _intervalCountMeta,
        ),
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
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('month_day')) {
      context.handle(
        _monthDayMeta,
        monthDay.isAcceptableOrUnknown(data['month_day']!, _monthDayMeta),
      );
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    }
    if (data.containsKey('next_date')) {
      context.handle(
        _nextDateMeta,
        nextDate.isAcceptableOrUnknown(data['next_date']!, _nextDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('auto_generate')) {
      context.handle(
        _autoGenerateMeta,
        autoGenerate.isAcceptableOrUnknown(
          data['auto_generate']!,
          _autoGenerateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      type: $RecurringRulesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destination_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      frequency: $RecurringRulesTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      intervalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_count'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      monthDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_day'],
      ),
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      ),
      nextDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      autoGenerate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_generate'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<MovementType, String> $convertertype =
      movementTypeConverter;
  static TypeConverter<RecurrenceFrequency, String> $converterfrequency =
      recurrenceFrequencyConverter;
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String concept;
  final MovementType type;
  final int accountId;
  final int? destinationAccountId;
  final int? categoryId;
  final int amount;
  final String currency;
  final RecurrenceFrequency frequency;
  final int intervalCount;
  final DateTime startDate;
  final DateTime? endDate;
  final int? monthDay;
  final int? weekday;
  final DateTime? nextDate;
  final bool isActive;
  final bool autoGenerate;
  const RecurringRule({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.concept,
    required this.type,
    required this.accountId,
    this.destinationAccountId,
    this.categoryId,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.intervalCount,
    required this.startDate,
    this.endDate,
    this.monthDay,
    this.weekday,
    this.nextDate,
    required this.isActive,
    required this.autoGenerate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['concept'] = Variable<String>(concept);
    {
      map['type'] = Variable<String>(
        $RecurringRulesTable.$convertertype.toSql(type),
      );
    }
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<int>(destinationAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['amount'] = Variable<int>(amount);
    map['currency'] = Variable<String>(currency);
    {
      map['frequency'] = Variable<String>(
        $RecurringRulesTable.$converterfrequency.toSql(frequency),
      );
    }
    map['interval_count'] = Variable<int>(intervalCount);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || monthDay != null) {
      map['month_day'] = Variable<int>(monthDay);
    }
    if (!nullToAbsent || weekday != null) {
      map['weekday'] = Variable<int>(weekday);
    }
    if (!nullToAbsent || nextDate != null) {
      map['next_date'] = Variable<DateTime>(nextDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['auto_generate'] = Variable<bool>(autoGenerate);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      concept: Value(concept),
      type: Value(type),
      accountId: Value(accountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      currency: Value(currency),
      frequency: Value(frequency),
      intervalCount: Value(intervalCount),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      monthDay: monthDay == null && nullToAbsent
          ? const Value.absent()
          : Value(monthDay),
      weekday: weekday == null && nullToAbsent
          ? const Value.absent()
          : Value(weekday),
      nextDate: nextDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDate),
      isActive: Value(isActive),
      autoGenerate: Value(autoGenerate),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      concept: serializer.fromJson<String>(json['concept']),
      type: serializer.fromJson<MovementType>(json['type']),
      accountId: serializer.fromJson<int>(json['accountId']),
      destinationAccountId: serializer.fromJson<int?>(
        json['destinationAccountId'],
      ),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      amount: serializer.fromJson<int>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      frequency: serializer.fromJson<RecurrenceFrequency>(json['frequency']),
      intervalCount: serializer.fromJson<int>(json['intervalCount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      monthDay: serializer.fromJson<int?>(json['monthDay']),
      weekday: serializer.fromJson<int?>(json['weekday']),
      nextDate: serializer.fromJson<DateTime?>(json['nextDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      autoGenerate: serializer.fromJson<bool>(json['autoGenerate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'concept': serializer.toJson<String>(concept),
      'type': serializer.toJson<MovementType>(type),
      'accountId': serializer.toJson<int>(accountId),
      'destinationAccountId': serializer.toJson<int?>(destinationAccountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'amount': serializer.toJson<int>(amount),
      'currency': serializer.toJson<String>(currency),
      'frequency': serializer.toJson<RecurrenceFrequency>(frequency),
      'intervalCount': serializer.toJson<int>(intervalCount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'monthDay': serializer.toJson<int?>(monthDay),
      'weekday': serializer.toJson<int?>(weekday),
      'nextDate': serializer.toJson<DateTime?>(nextDate),
      'isActive': serializer.toJson<bool>(isActive),
      'autoGenerate': serializer.toJson<bool>(autoGenerate),
    };
  }

  RecurringRule copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? concept,
    MovementType? type,
    int? accountId,
    Value<int?> destinationAccountId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    int? amount,
    String? currency,
    RecurrenceFrequency? frequency,
    int? intervalCount,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> monthDay = const Value.absent(),
    Value<int?> weekday = const Value.absent(),
    Value<DateTime?> nextDate = const Value.absent(),
    bool? isActive,
    bool? autoGenerate,
  }) => RecurringRule(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    concept: concept ?? this.concept,
    type: type ?? this.type,
    accountId: accountId ?? this.accountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    frequency: frequency ?? this.frequency,
    intervalCount: intervalCount ?? this.intervalCount,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    monthDay: monthDay.present ? monthDay.value : this.monthDay,
    weekday: weekday.present ? weekday.value : this.weekday,
    nextDate: nextDate.present ? nextDate.value : this.nextDate,
    isActive: isActive ?? this.isActive,
    autoGenerate: autoGenerate ?? this.autoGenerate,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      concept: data.concept.present ? data.concept.value : this.concept,
      type: data.type.present ? data.type.value : this.type,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      intervalCount: data.intervalCount.present
          ? data.intervalCount.value
          : this.intervalCount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      monthDay: data.monthDay.present ? data.monthDay.value : this.monthDay,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      nextDate: data.nextDate.present ? data.nextDate.value : this.nextDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      autoGenerate: data.autoGenerate.present
          ? data.autoGenerate.value
          : this.autoGenerate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('concept: $concept, ')
          ..write('type: $type, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('frequency: $frequency, ')
          ..write('intervalCount: $intervalCount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('monthDay: $monthDay, ')
          ..write('weekday: $weekday, ')
          ..write('nextDate: $nextDate, ')
          ..write('isActive: $isActive, ')
          ..write('autoGenerate: $autoGenerate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    concept,
    type,
    accountId,
    destinationAccountId,
    categoryId,
    amount,
    currency,
    frequency,
    intervalCount,
    startDate,
    endDate,
    monthDay,
    weekday,
    nextDate,
    isActive,
    autoGenerate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.concept == this.concept &&
          other.type == this.type &&
          other.accountId == this.accountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.frequency == this.frequency &&
          other.intervalCount == this.intervalCount &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.monthDay == this.monthDay &&
          other.weekday == this.weekday &&
          other.nextDate == this.nextDate &&
          other.isActive == this.isActive &&
          other.autoGenerate == this.autoGenerate);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> concept;
  final Value<MovementType> type;
  final Value<int> accountId;
  final Value<int?> destinationAccountId;
  final Value<int?> categoryId;
  final Value<int> amount;
  final Value<String> currency;
  final Value<RecurrenceFrequency> frequency;
  final Value<int> intervalCount;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> monthDay;
  final Value<int?> weekday;
  final Value<DateTime?> nextDate;
  final Value<bool> isActive;
  final Value<bool> autoGenerate;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.concept = const Value.absent(),
    this.type = const Value.absent(),
    this.accountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.frequency = const Value.absent(),
    this.intervalCount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.monthDay = const Value.absent(),
    this.weekday = const Value.absent(),
    this.nextDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoGenerate = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String concept,
    required MovementType type,
    required int accountId,
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int amount,
    required String currency,
    required RecurrenceFrequency frequency,
    this.intervalCount = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.monthDay = const Value.absent(),
    this.weekday = const Value.absent(),
    this.nextDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoGenerate = const Value.absent(),
  }) : concept = Value(concept),
       type = Value(type),
       accountId = Value(accountId),
       amount = Value(amount),
       currency = Value(currency),
       frequency = Value(frequency),
       startDate = Value(startDate);
  static Insertable<RecurringRule> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? concept,
    Expression<String>? type,
    Expression<int>? accountId,
    Expression<int>? destinationAccountId,
    Expression<int>? categoryId,
    Expression<int>? amount,
    Expression<String>? currency,
    Expression<String>? frequency,
    Expression<int>? intervalCount,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? monthDay,
    Expression<int>? weekday,
    Expression<DateTime>? nextDate,
    Expression<bool>? isActive,
    Expression<bool>? autoGenerate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (concept != null) 'concept': concept,
      if (type != null) 'type': type,
      if (accountId != null) 'account_id': accountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (frequency != null) 'frequency': frequency,
      if (intervalCount != null) 'interval_count': intervalCount,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (monthDay != null) 'month_day': monthDay,
      if (weekday != null) 'weekday': weekday,
      if (nextDate != null) 'next_date': nextDate,
      if (isActive != null) 'is_active': isActive,
      if (autoGenerate != null) 'auto_generate': autoGenerate,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? concept,
    Value<MovementType>? type,
    Value<int>? accountId,
    Value<int?>? destinationAccountId,
    Value<int?>? categoryId,
    Value<int>? amount,
    Value<String>? currency,
    Value<RecurrenceFrequency>? frequency,
    Value<int>? intervalCount,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? monthDay,
    Value<int?>? weekday,
    Value<DateTime?>? nextDate,
    Value<bool>? isActive,
    Value<bool>? autoGenerate,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      concept: concept ?? this.concept,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      intervalCount: intervalCount ?? this.intervalCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthDay: monthDay ?? this.monthDay,
      weekday: weekday ?? this.weekday,
      nextDate: nextDate ?? this.nextDate,
      isActive: isActive ?? this.isActive,
      autoGenerate: autoGenerate ?? this.autoGenerate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RecurringRulesTable.$convertertype.toSql(type.value),
      );
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<int>(destinationAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $RecurringRulesTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (intervalCount.present) {
      map['interval_count'] = Variable<int>(intervalCount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (monthDay.present) {
      map['month_day'] = Variable<int>(monthDay.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (nextDate.present) {
      map['next_date'] = Variable<DateTime>(nextDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (autoGenerate.present) {
      map['auto_generate'] = Variable<bool>(autoGenerate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('concept: $concept, ')
          ..write('type: $type, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('frequency: $frequency, ')
          ..write('intervalCount: $intervalCount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('monthDay: $monthDay, ')
          ..write('weekday: $weekday, ')
          ..write('nextDate: $nextDate, ')
          ..write('isActive: $isActive, ')
          ..write('autoGenerate: $autoGenerate')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  @override
  late final GeneratedColumnWithTypeConverter<MovementType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MovementType>($TransactionsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<MovementStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MovementStatus>($TransactionsTable.$converterstatus);
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<int> destinationAccountId = GeneratedColumn<int>(
    'destination_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salarySourceIdMeta = const VerificationMeta(
    'salarySourceId',
  );
  @override
  late final GeneratedColumn<int> salarySourceId = GeneratedColumn<int>(
    'salary_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingsGoalIdMeta = const VerificationMeta(
    'savingsGoalId',
  );
  @override
  late final GeneratedColumn<int> savingsGoalId = GeneratedColumn<int>(
    'savings_goal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<int> recurringRuleId = GeneratedColumn<int>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedDateMeta = const VerificationMeta(
    'expectedDate',
  );
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
    'expected_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  @override
  late final GeneratedColumn<DateTime> actualDate = GeneratedColumn<DateTime>(
    'actual_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    createdAt,
    updatedAt,
    type,
    status,
    concept,
    amount,
    currency,
    accountId,
    destinationAccountId,
    categoryId,
    clientId,
    projectId,
    salarySourceId,
    savingsGoalId,
    recurringRuleId,
    expectedDate,
    actualDate,
    notes,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('salary_source_id')) {
      context.handle(
        _salarySourceIdMeta,
        salarySourceId.isAcceptableOrUnknown(
          data['salary_source_id']!,
          _salarySourceIdMeta,
        ),
      );
    }
    if (data.containsKey('savings_goal_id')) {
      context.handle(
        _savingsGoalIdMeta,
        savingsGoalId.isAcceptableOrUnknown(
          data['savings_goal_id']!,
          _savingsGoalIdMeta,
        ),
      );
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('expected_date')) {
      context.handle(
        _expectedDateMeta,
        expectedDate.isAcceptableOrUnknown(
          data['expected_date']!,
          _expectedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedDateMeta);
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $TransactionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destination_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      ),
      salarySourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_source_id'],
      ),
      savingsGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_goal_id'],
      ),
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      expectedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_date'],
      )!,
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<MovementType, String> $convertertype =
      movementTypeConverter;
  static TypeConverter<MovementStatus, String> $converterstatus =
      movementStatusConverter;
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MovementType type;
  final MovementStatus status;
  final String concept;
  final int amount;
  final String currency;
  final int accountId;
  final int? destinationAccountId;
  final int? categoryId;
  final int? clientId;
  final int? projectId;
  final int? salarySourceId;
  final int? savingsGoalId;
  final int? recurringRuleId;

  /// Fecha en la que se espera que ocurra. Siempre existe.
  final DateTime expectedDate;

  /// Fecha en la que ocurrio de verdad. Solo en estados realizados.
  final DateTime? actualDate;
  final String? notes;

  /// Borrado logico: conserva historia y relaciones, sale del saldo.
  final bool isDeleted;
  const Transaction({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.status,
    required this.concept,
    required this.amount,
    required this.currency,
    required this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.clientId,
    this.projectId,
    this.salarySourceId,
    this.savingsGoalId,
    this.recurringRuleId,
    required this.expectedDate,
    this.actualDate,
    this.notes,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    {
      map['status'] = Variable<String>(
        $TransactionsTable.$converterstatus.toSql(status),
      );
    }
    map['concept'] = Variable<String>(concept);
    map['amount'] = Variable<int>(amount);
    map['currency'] = Variable<String>(currency);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<int>(destinationAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<int>(clientId);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || salarySourceId != null) {
      map['salary_source_id'] = Variable<int>(salarySourceId);
    }
    if (!nullToAbsent || savingsGoalId != null) {
      map['savings_goal_id'] = Variable<int>(savingsGoalId);
    }
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId);
    }
    map['expected_date'] = Variable<DateTime>(expectedDate);
    if (!nullToAbsent || actualDate != null) {
      map['actual_date'] = Variable<DateTime>(actualDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      type: Value(type),
      status: Value(status),
      concept: Value(concept),
      amount: Value(amount),
      currency: Value(currency),
      accountId: Value(accountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      salarySourceId: salarySourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(salarySourceId),
      savingsGoalId: savingsGoalId == null && nullToAbsent
          ? const Value.absent()
          : Value(savingsGoalId),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      expectedDate: Value(expectedDate),
      actualDate: actualDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isDeleted: Value(isDeleted),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      type: serializer.fromJson<MovementType>(json['type']),
      status: serializer.fromJson<MovementStatus>(json['status']),
      concept: serializer.fromJson<String>(json['concept']),
      amount: serializer.fromJson<int>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      accountId: serializer.fromJson<int>(json['accountId']),
      destinationAccountId: serializer.fromJson<int?>(
        json['destinationAccountId'],
      ),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      clientId: serializer.fromJson<int?>(json['clientId']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      salarySourceId: serializer.fromJson<int?>(json['salarySourceId']),
      savingsGoalId: serializer.fromJson<int?>(json['savingsGoalId']),
      recurringRuleId: serializer.fromJson<int?>(json['recurringRuleId']),
      expectedDate: serializer.fromJson<DateTime>(json['expectedDate']),
      actualDate: serializer.fromJson<DateTime?>(json['actualDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'type': serializer.toJson<MovementType>(type),
      'status': serializer.toJson<MovementStatus>(status),
      'concept': serializer.toJson<String>(concept),
      'amount': serializer.toJson<int>(amount),
      'currency': serializer.toJson<String>(currency),
      'accountId': serializer.toJson<int>(accountId),
      'destinationAccountId': serializer.toJson<int?>(destinationAccountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'clientId': serializer.toJson<int?>(clientId),
      'projectId': serializer.toJson<int?>(projectId),
      'salarySourceId': serializer.toJson<int?>(salarySourceId),
      'savingsGoalId': serializer.toJson<int?>(savingsGoalId),
      'recurringRuleId': serializer.toJson<int?>(recurringRuleId),
      'expectedDate': serializer.toJson<DateTime>(expectedDate),
      'actualDate': serializer.toJson<DateTime?>(actualDate),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Transaction copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    MovementType? type,
    MovementStatus? status,
    String? concept,
    int? amount,
    String? currency,
    int? accountId,
    Value<int?> destinationAccountId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<int?> clientId = const Value.absent(),
    Value<int?> projectId = const Value.absent(),
    Value<int?> salarySourceId = const Value.absent(),
    Value<int?> savingsGoalId = const Value.absent(),
    Value<int?> recurringRuleId = const Value.absent(),
    DateTime? expectedDate,
    Value<DateTime?> actualDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
  }) => Transaction(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    type: type ?? this.type,
    status: status ?? this.status,
    concept: concept ?? this.concept,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    accountId: accountId ?? this.accountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    clientId: clientId.present ? clientId.value : this.clientId,
    projectId: projectId.present ? projectId.value : this.projectId,
    salarySourceId: salarySourceId.present
        ? salarySourceId.value
        : this.salarySourceId,
    savingsGoalId: savingsGoalId.present
        ? savingsGoalId.value
        : this.savingsGoalId,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    expectedDate: expectedDate ?? this.expectedDate,
    actualDate: actualDate.present ? actualDate.value : this.actualDate,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      concept: data.concept.present ? data.concept.value : this.concept,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      salarySourceId: data.salarySourceId.present
          ? data.salarySourceId.value
          : this.salarySourceId,
      savingsGoalId: data.savingsGoalId.present
          ? data.savingsGoalId.value
          : this.savingsGoalId,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('concept: $concept, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('clientId: $clientId, ')
          ..write('projectId: $projectId, ')
          ..write('salarySourceId: $salarySourceId, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    type,
    status,
    concept,
    amount,
    currency,
    accountId,
    destinationAccountId,
    categoryId,
    clientId,
    projectId,
    salarySourceId,
    savingsGoalId,
    recurringRuleId,
    expectedDate,
    actualDate,
    notes,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.type == this.type &&
          other.status == this.status &&
          other.concept == this.concept &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.accountId == this.accountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.categoryId == this.categoryId &&
          other.clientId == this.clientId &&
          other.projectId == this.projectId &&
          other.salarySourceId == this.salarySourceId &&
          other.savingsGoalId == this.savingsGoalId &&
          other.recurringRuleId == this.recurringRuleId &&
          other.expectedDate == this.expectedDate &&
          other.actualDate == this.actualDate &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<MovementType> type;
  final Value<MovementStatus> status;
  final Value<String> concept;
  final Value<int> amount;
  final Value<String> currency;
  final Value<int> accountId;
  final Value<int?> destinationAccountId;
  final Value<int?> categoryId;
  final Value<int?> clientId;
  final Value<int?> projectId;
  final Value<int?> salarySourceId;
  final Value<int?> savingsGoalId;
  final Value<int?> recurringRuleId;
  final Value<DateTime> expectedDate;
  final Value<DateTime?> actualDate;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.concept = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.accountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.salarySourceId = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required MovementType type,
    required MovementStatus status,
    required String concept,
    required int amount,
    required String currency,
    required int accountId,
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.salarySourceId = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    required DateTime expectedDate,
    this.actualDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : type = Value(type),
       status = Value(status),
       concept = Value(concept),
       amount = Value(amount),
       currency = Value(currency),
       accountId = Value(accountId),
       expectedDate = Value(expectedDate);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? concept,
    Expression<int>? amount,
    Expression<String>? currency,
    Expression<int>? accountId,
    Expression<int>? destinationAccountId,
    Expression<int>? categoryId,
    Expression<int>? clientId,
    Expression<int>? projectId,
    Expression<int>? salarySourceId,
    Expression<int>? savingsGoalId,
    Expression<int>? recurringRuleId,
    Expression<DateTime>? expectedDate,
    Expression<DateTime>? actualDate,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (concept != null) 'concept': concept,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (accountId != null) 'account_id': accountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (clientId != null) 'client_id': clientId,
      if (projectId != null) 'project_id': projectId,
      if (salarySourceId != null) 'salary_source_id': salarySourceId,
      if (savingsGoalId != null) 'savings_goal_id': savingsGoalId,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (actualDate != null) 'actual_date': actualDate,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<MovementType>? type,
    Value<MovementStatus>? status,
    Value<String>? concept,
    Value<int>? amount,
    Value<String>? currency,
    Value<int>? accountId,
    Value<int?>? destinationAccountId,
    Value<int?>? categoryId,
    Value<int?>? clientId,
    Value<int?>? projectId,
    Value<int?>? salarySourceId,
    Value<int?>? savingsGoalId,
    Value<int?>? recurringRuleId,
    Value<DateTime>? expectedDate,
    Value<DateTime?>? actualDate,
    Value<String?>? notes,
    Value<bool>? isDeleted,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      status: status ?? this.status,
      concept: concept ?? this.concept,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      salarySourceId: salarySourceId ?? this.salarySourceId,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      expectedDate: expectedDate ?? this.expectedDate,
      actualDate: actualDate ?? this.actualDate,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TransactionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<int>(destinationAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (salarySourceId.present) {
      map['salary_source_id'] = Variable<int>(salarySourceId.value);
    }
    if (savingsGoalId.present) {
      map['savings_goal_id'] = Variable<int>(savingsGoalId.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<DateTime>(actualDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('concept: $concept, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('clientId: $clientId, ')
          ..write('projectId: $projectId, ')
          ..write('salarySourceId: $salarySourceId, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $SalarySourcesTable salarySources = $SalarySourcesTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final Index idxCategoriesParent = Index(
    'idx_categories_parent',
    'CREATE INDEX idx_categories_parent ON categories (parent_id)',
  );
  late final Index idxProjectsClient = Index(
    'idx_projects_client',
    'CREATE INDEX idx_projects_client ON projects (client_id)',
  );
  late final Index idxRulesActiveNext = Index(
    'idx_rules_active_next',
    'CREATE INDEX idx_rules_active_next ON recurring_rules (is_active, next_date)',
  );
  late final Index idxRulesAccount = Index(
    'idx_rules_account',
    'CREATE INDEX idx_rules_account ON recurring_rules (account_id)',
  );
  late final Index idxTxExpected = Index(
    'idx_tx_expected',
    'CREATE INDEX idx_tx_expected ON transactions (expected_date)',
  );
  late final Index idxTxActual = Index(
    'idx_tx_actual',
    'CREATE INDEX idx_tx_actual ON transactions (actual_date)',
  );
  late final Index idxTxStatus = Index(
    'idx_tx_status',
    'CREATE INDEX idx_tx_status ON transactions (status)',
  );
  late final Index idxTxAccount = Index(
    'idx_tx_account',
    'CREATE INDEX idx_tx_account ON transactions (account_id)',
  );
  late final Index idxTxDestination = Index(
    'idx_tx_destination',
    'CREATE INDEX idx_tx_destination ON transactions (destination_account_id)',
  );
  late final Index idxTxCategory = Index(
    'idx_tx_category',
    'CREATE INDEX idx_tx_category ON transactions (category_id)',
  );
  late final Index idxTxClient = Index(
    'idx_tx_client',
    'CREATE INDEX idx_tx_client ON transactions (client_id)',
  );
  late final Index idxTxProject = Index(
    'idx_tx_project',
    'CREATE INDEX idx_tx_project ON transactions (project_id)',
  );
  late final Index idxTxSalarySource = Index(
    'idx_tx_salary_source',
    'CREATE INDEX idx_tx_salary_source ON transactions (salary_source_id)',
  );
  late final Index idxTxSavingsGoal = Index(
    'idx_tx_savings_goal',
    'CREATE INDEX idx_tx_savings_goal ON transactions (savings_goal_id)',
  );
  late final Index idxTxRule = Index(
    'idx_tx_rule',
    'CREATE INDEX idx_tx_rule ON transactions (recurring_rule_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    clients,
    projects,
    salarySources,
    savingsGoals,
    recurringRules,
    transactions,
    idxCategoriesParent,
    idxProjectsClient,
    idxRulesActiveNext,
    idxRulesAccount,
    idxTxExpected,
    idxTxActual,
    idxTxStatus,
    idxTxAccount,
    idxTxDestination,
    idxTxCategory,
    idxTxClient,
    idxTxProject,
    idxTxSalarySource,
    idxTxSavingsGoal,
    idxTxRule,
  ];
}
