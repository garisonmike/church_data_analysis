// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChurchesTable extends Churches with TableInfo<$ChurchesTable, Churche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChurchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactEmailMeta = const VerificationMeta(
    'contactEmail',
  );
  @override
  late final GeneratedColumn<String> contactEmail = GeneratedColumn<String>(
    'contact_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPhoneMeta = const VerificationMeta(
    'contactPhone',
  );
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
    'contact_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    defaultValue: const Constant('USD'),
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
    name,
    address,
    contactEmail,
    contactPhone,
    currency,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'churches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Churche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('contact_email')) {
      context.handle(
        _contactEmailMeta,
        contactEmail.isAcceptableOrUnknown(
          data['contact_email']!,
          _contactEmailMeta,
        ),
      );
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
        _contactPhoneMeta,
        contactPhone.isAcceptableOrUnknown(
          data['contact_phone']!,
          _contactPhoneMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
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
  Churche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Churche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      contactEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_email'],
      ),
      contactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_phone'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
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
  $ChurchesTable createAlias(String alias) {
    return $ChurchesTable(attachedDatabase, alias);
  }
}

class Churche extends DataClass implements Insertable<Churche> {
  final int id;
  final String name;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Churche({
    required this.id,
    required this.name,
    this.address,
    this.contactEmail,
    this.contactPhone,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || contactEmail != null) {
      map['contact_email'] = Variable<String>(contactEmail);
    }
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChurchesCompanion toCompanion(bool nullToAbsent) {
    return ChurchesCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      contactEmail: contactEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(contactEmail),
      contactPhone: contactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPhone),
      currency: Value(currency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Churche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Churche(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      contactEmail: serializer.fromJson<String?>(json['contactEmail']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'contactEmail': serializer.toJson<String?>(contactEmail),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Churche copyWith({
    int? id,
    String? name,
    Value<String?> address = const Value.absent(),
    Value<String?> contactEmail = const Value.absent(),
    Value<String?> contactPhone = const Value.absent(),
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Churche(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    contactEmail: contactEmail.present ? contactEmail.value : this.contactEmail,
    contactPhone: contactPhone.present ? contactPhone.value : this.contactPhone,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Churche copyWithCompanion(ChurchesCompanion data) {
    return Churche(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      contactEmail: data.contactEmail.present
          ? data.contactEmail.value
          : this.contactEmail,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Churche(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    address,
    contactEmail,
    contactPhone,
    currency,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Churche &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.contactEmail == this.contactEmail &&
          other.contactPhone == this.contactPhone &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChurchesCompanion extends UpdateCompanion<Churche> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> contactEmail;
  final Value<String?> contactPhone;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ChurchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChurchesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.currency = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Churche> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? contactEmail,
    Expression<String>? contactPhone,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChurchesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<String?>? contactEmail,
    Value<String?>? contactPhone,
    Value<String>? currency,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ChurchesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (contactEmail.present) {
      map['contact_email'] = Variable<String>(contactEmail.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChurchesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AdminUsersTable extends AdminUsers
    with TableInfo<$AdminUsersTable, AdminUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminUsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _churchIdMeta = const VerificationMeta(
    'churchId',
  );
  @override
  late final GeneratedColumn<int> churchId = GeneratedColumn<int>(
    'church_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES churches (id)',
    ),
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
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    fullName,
    email,
    churchId,
    isActive,
    createdAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('church_id')) {
      context.handle(
        _churchIdMeta,
        churchId.isAcceptableOrUnknown(data['church_id']!, _churchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_churchIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastLoginAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdminUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      )!,
    );
  }

  @override
  $AdminUsersTable createAlias(String alias) {
    return $AdminUsersTable(attachedDatabase, alias);
  }
}

class AdminUser extends DataClass implements Insertable<AdminUser> {
  final int id;
  final String username;
  final String fullName;
  final String? email;
  final int churchId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  const AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    required this.churchId,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['church_id'] = Variable<int>(churchId);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    return map;
  }

  AdminUsersCompanion toCompanion(bool nullToAbsent) {
    return AdminUsersCompanion(
      id: Value(id),
      username: Value(username),
      fullName: Value(fullName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      churchId: Value(churchId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      lastLoginAt: Value(lastLoginAt),
    );
  }

  factory AdminUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminUser(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      fullName: serializer.fromJson<String>(json['fullName']),
      email: serializer.fromJson<String?>(json['email']),
      churchId: serializer.fromJson<int>(json['churchId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLoginAt: serializer.fromJson<DateTime>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'fullName': serializer.toJson<String>(fullName),
      'email': serializer.toJson<String?>(email),
      'churchId': serializer.toJson<int>(churchId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLoginAt': serializer.toJson<DateTime>(lastLoginAt),
    };
  }

  AdminUser copyWith({
    int? id,
    String? username,
    String? fullName,
    Value<String?> email = const Value.absent(),
    int? churchId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) => AdminUser(
    id: id ?? this.id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    email: email.present ? email.value : this.email,
    churchId: churchId ?? this.churchId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );
  AdminUser copyWithCompanion(AdminUsersCompanion data) {
    return AdminUser(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminUser(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('churchId: $churchId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    fullName,
    email,
    churchId,
    isActive,
    createdAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminUser &&
          other.id == this.id &&
          other.username == this.username &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.churchId == this.churchId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class AdminUsersCompanion extends UpdateCompanion<AdminUser> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> fullName;
  final Value<String?> email;
  final Value<int> churchId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastLoginAt;
  const AdminUsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.churchId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  });
  AdminUsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String fullName,
    this.email = const Value.absent(),
    required int churchId,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) : username = Value(username),
       fullName = Value(fullName),
       churchId = Value(churchId),
       createdAt = Value(createdAt),
       lastLoginAt = Value(lastLoginAt);
  static Insertable<AdminUser> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<int>? churchId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLoginAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (churchId != null) 'church_id': churchId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
    });
  }

  AdminUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? fullName,
    Value<String?>? email,
    Value<int>? churchId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastLoginAt,
  }) {
    return AdminUsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      churchId: churchId ?? this.churchId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (churchId.present) {
      map['church_id'] = Variable<int>(churchId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminUsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('churchId: $churchId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyRecordsTable extends WeeklyRecords
    with TableInfo<$WeeklyRecordsTable, WeeklyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _churchIdMeta = const VerificationMeta(
    'churchId',
  );
  @override
  late final GeneratedColumn<int> churchId = GeneratedColumn<int>(
    'church_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES churches (id)',
    ),
  );
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> weekStartDate =
      GeneratedColumn<DateTime>(
        'week_start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _menMeta = const VerificationMeta('men');
  @override
  late final GeneratedColumn<int> men = GeneratedColumn<int>(
    'men',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _womenMeta = const VerificationMeta('women');
  @override
  late final GeneratedColumn<int> women = GeneratedColumn<int>(
    'women',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _youthMeta = const VerificationMeta('youth');
  @override
  late final GeneratedColumn<int> youth = GeneratedColumn<int>(
    'youth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _childrenMeta = const VerificationMeta(
    'children',
  );
  @override
  late final GeneratedColumn<int> children = GeneratedColumn<int>(
    'children',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sundayHomeChurchMeta = const VerificationMeta(
    'sundayHomeChurch',
  );
  @override
  late final GeneratedColumn<int> sundayHomeChurch = GeneratedColumn<int>(
    'sunday_home_church',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _titheMeta = const VerificationMeta('tithe');
  @override
  late final GeneratedColumn<double> tithe = GeneratedColumn<double>(
    'tithe',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _offeringsMeta = const VerificationMeta(
    'offerings',
  );
  @override
  late final GeneratedColumn<double> offerings = GeneratedColumn<double>(
    'offerings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _emergencyCollectionMeta =
      const VerificationMeta('emergencyCollection');
  @override
  late final GeneratedColumn<double> emergencyCollection =
      GeneratedColumn<double>(
        'emergency_collection',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _plannedCollectionMeta = const VerificationMeta(
    'plannedCollection',
  );
  @override
  late final GeneratedColumn<double> plannedCollection =
      GeneratedColumn<double>(
        'planned_collection',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
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
    churchId,
    weekStartDate,
    men,
    women,
    youth,
    children,
    sundayHomeChurch,
    tithe,
    offerings,
    emergencyCollection,
    plannedCollection,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('church_id')) {
      context.handle(
        _churchIdMeta,
        churchId.isAcceptableOrUnknown(data['church_id']!, _churchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_churchIdMeta);
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('men')) {
      context.handle(
        _menMeta,
        men.isAcceptableOrUnknown(data['men']!, _menMeta),
      );
    }
    if (data.containsKey('women')) {
      context.handle(
        _womenMeta,
        women.isAcceptableOrUnknown(data['women']!, _womenMeta),
      );
    }
    if (data.containsKey('youth')) {
      context.handle(
        _youthMeta,
        youth.isAcceptableOrUnknown(data['youth']!, _youthMeta),
      );
    }
    if (data.containsKey('children')) {
      context.handle(
        _childrenMeta,
        children.isAcceptableOrUnknown(data['children']!, _childrenMeta),
      );
    }
    if (data.containsKey('sunday_home_church')) {
      context.handle(
        _sundayHomeChurchMeta,
        sundayHomeChurch.isAcceptableOrUnknown(
          data['sunday_home_church']!,
          _sundayHomeChurchMeta,
        ),
      );
    }
    if (data.containsKey('tithe')) {
      context.handle(
        _titheMeta,
        tithe.isAcceptableOrUnknown(data['tithe']!, _titheMeta),
      );
    }
    if (data.containsKey('offerings')) {
      context.handle(
        _offeringsMeta,
        offerings.isAcceptableOrUnknown(data['offerings']!, _offeringsMeta),
      );
    }
    if (data.containsKey('emergency_collection')) {
      context.handle(
        _emergencyCollectionMeta,
        emergencyCollection.isAcceptableOrUnknown(
          data['emergency_collection']!,
          _emergencyCollectionMeta,
        ),
      );
    }
    if (data.containsKey('planned_collection')) {
      context.handle(
        _plannedCollectionMeta,
        plannedCollection.isAcceptableOrUnknown(
          data['planned_collection']!,
          _plannedCollectionMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {churchId, weekStartDate},
  ];
  @override
  WeeklyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start_date'],
      )!,
      men: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}men'],
      )!,
      women: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}women'],
      )!,
      youth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}youth'],
      )!,
      children: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}children'],
      )!,
      sundayHomeChurch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sunday_home_church'],
      )!,
      tithe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tithe'],
      )!,
      offerings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offerings'],
      )!,
      emergencyCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}emergency_collection'],
      )!,
      plannedCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_collection'],
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
  $WeeklyRecordsTable createAlias(String alias) {
    return $WeeklyRecordsTable(attachedDatabase, alias);
  }
}

class WeeklyRecord extends DataClass implements Insertable<WeeklyRecord> {
  final int id;
  final int churchId;
  final DateTime weekStartDate;
  final int men;
  final int women;
  final int youth;
  final int children;
  final int sundayHomeChurch;
  final double tithe;
  final double offerings;
  final double emergencyCollection;
  final double plannedCollection;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeeklyRecord({
    required this.id,
    required this.churchId,
    required this.weekStartDate,
    required this.men,
    required this.women,
    required this.youth,
    required this.children,
    required this.sundayHomeChurch,
    required this.tithe,
    required this.offerings,
    required this.emergencyCollection,
    required this.plannedCollection,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    map['week_start_date'] = Variable<DateTime>(weekStartDate);
    map['men'] = Variable<int>(men);
    map['women'] = Variable<int>(women);
    map['youth'] = Variable<int>(youth);
    map['children'] = Variable<int>(children);
    map['sunday_home_church'] = Variable<int>(sundayHomeChurch);
    map['tithe'] = Variable<double>(tithe);
    map['offerings'] = Variable<double>(offerings);
    map['emergency_collection'] = Variable<double>(emergencyCollection);
    map['planned_collection'] = Variable<double>(plannedCollection);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeeklyRecordsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyRecordsCompanion(
      id: Value(id),
      churchId: Value(churchId),
      weekStartDate: Value(weekStartDate),
      men: Value(men),
      women: Value(women),
      youth: Value(youth),
      children: Value(children),
      sundayHomeChurch: Value(sundayHomeChurch),
      tithe: Value(tithe),
      offerings: Value(offerings),
      emergencyCollection: Value(emergencyCollection),
      plannedCollection: Value(plannedCollection),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeeklyRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyRecord(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      men: serializer.fromJson<int>(json['men']),
      women: serializer.fromJson<int>(json['women']),
      youth: serializer.fromJson<int>(json['youth']),
      children: serializer.fromJson<int>(json['children']),
      sundayHomeChurch: serializer.fromJson<int>(json['sundayHomeChurch']),
      tithe: serializer.fromJson<double>(json['tithe']),
      offerings: serializer.fromJson<double>(json['offerings']),
      emergencyCollection: serializer.fromJson<double>(
        json['emergencyCollection'],
      ),
      plannedCollection: serializer.fromJson<double>(json['plannedCollection']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'churchId': serializer.toJson<int>(churchId),
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'men': serializer.toJson<int>(men),
      'women': serializer.toJson<int>(women),
      'youth': serializer.toJson<int>(youth),
      'children': serializer.toJson<int>(children),
      'sundayHomeChurch': serializer.toJson<int>(sundayHomeChurch),
      'tithe': serializer.toJson<double>(tithe),
      'offerings': serializer.toJson<double>(offerings),
      'emergencyCollection': serializer.toJson<double>(emergencyCollection),
      'plannedCollection': serializer.toJson<double>(plannedCollection),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklyRecord copyWith({
    int? id,
    int? churchId,
    DateTime? weekStartDate,
    int? men,
    int? women,
    int? youth,
    int? children,
    int? sundayHomeChurch,
    double? tithe,
    double? offerings,
    double? emergencyCollection,
    double? plannedCollection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WeeklyRecord(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    men: men ?? this.men,
    women: women ?? this.women,
    youth: youth ?? this.youth,
    children: children ?? this.children,
    sundayHomeChurch: sundayHomeChurch ?? this.sundayHomeChurch,
    tithe: tithe ?? this.tithe,
    offerings: offerings ?? this.offerings,
    emergencyCollection: emergencyCollection ?? this.emergencyCollection,
    plannedCollection: plannedCollection ?? this.plannedCollection,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklyRecord copyWithCompanion(WeeklyRecordsCompanion data) {
    return WeeklyRecord(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      men: data.men.present ? data.men.value : this.men,
      women: data.women.present ? data.women.value : this.women,
      youth: data.youth.present ? data.youth.value : this.youth,
      children: data.children.present ? data.children.value : this.children,
      sundayHomeChurch: data.sundayHomeChurch.present
          ? data.sundayHomeChurch.value
          : this.sundayHomeChurch,
      tithe: data.tithe.present ? data.tithe.value : this.tithe,
      offerings: data.offerings.present ? data.offerings.value : this.offerings,
      emergencyCollection: data.emergencyCollection.present
          ? data.emergencyCollection.value
          : this.emergencyCollection,
      plannedCollection: data.plannedCollection.present
          ? data.plannedCollection.value
          : this.plannedCollection,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyRecord(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('men: $men, ')
          ..write('women: $women, ')
          ..write('youth: $youth, ')
          ..write('children: $children, ')
          ..write('sundayHomeChurch: $sundayHomeChurch, ')
          ..write('tithe: $tithe, ')
          ..write('offerings: $offerings, ')
          ..write('emergencyCollection: $emergencyCollection, ')
          ..write('plannedCollection: $plannedCollection, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    weekStartDate,
    men,
    women,
    youth,
    children,
    sundayHomeChurch,
    tithe,
    offerings,
    emergencyCollection,
    plannedCollection,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyRecord &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.weekStartDate == this.weekStartDate &&
          other.men == this.men &&
          other.women == this.women &&
          other.youth == this.youth &&
          other.children == this.children &&
          other.sundayHomeChurch == this.sundayHomeChurch &&
          other.tithe == this.tithe &&
          other.offerings == this.offerings &&
          other.emergencyCollection == this.emergencyCollection &&
          other.plannedCollection == this.plannedCollection &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeeklyRecordsCompanion extends UpdateCompanion<WeeklyRecord> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<DateTime> weekStartDate;
  final Value<int> men;
  final Value<int> women;
  final Value<int> youth;
  final Value<int> children;
  final Value<int> sundayHomeChurch;
  final Value<double> tithe;
  final Value<double> offerings;
  final Value<double> emergencyCollection;
  final Value<double> plannedCollection;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeeklyRecordsCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.men = const Value.absent(),
    this.women = const Value.absent(),
    this.youth = const Value.absent(),
    this.children = const Value.absent(),
    this.sundayHomeChurch = const Value.absent(),
    this.tithe = const Value.absent(),
    this.offerings = const Value.absent(),
    this.emergencyCollection = const Value.absent(),
    this.plannedCollection = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeeklyRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    required DateTime weekStartDate,
    this.men = const Value.absent(),
    this.women = const Value.absent(),
    this.youth = const Value.absent(),
    this.children = const Value.absent(),
    this.sundayHomeChurch = const Value.absent(),
    this.tithe = const Value.absent(),
    this.offerings = const Value.absent(),
    this.emergencyCollection = const Value.absent(),
    this.plannedCollection = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : churchId = Value(churchId),
       weekStartDate = Value(weekStartDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeeklyRecord> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<DateTime>? weekStartDate,
    Expression<int>? men,
    Expression<int>? women,
    Expression<int>? youth,
    Expression<int>? children,
    Expression<int>? sundayHomeChurch,
    Expression<double>? tithe,
    Expression<double>? offerings,
    Expression<double>? emergencyCollection,
    Expression<double>? plannedCollection,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (men != null) 'men': men,
      if (women != null) 'women': women,
      if (youth != null) 'youth': youth,
      if (children != null) 'children': children,
      if (sundayHomeChurch != null) 'sunday_home_church': sundayHomeChurch,
      if (tithe != null) 'tithe': tithe,
      if (offerings != null) 'offerings': offerings,
      if (emergencyCollection != null)
        'emergency_collection': emergencyCollection,
      if (plannedCollection != null) 'planned_collection': plannedCollection,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeeklyRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<DateTime>? weekStartDate,
    Value<int>? men,
    Value<int>? women,
    Value<int>? youth,
    Value<int>? children,
    Value<int>? sundayHomeChurch,
    Value<double>? tithe,
    Value<double>? offerings,
    Value<double>? emergencyCollection,
    Value<double>? plannedCollection,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeeklyRecordsCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      men: men ?? this.men,
      women: women ?? this.women,
      youth: youth ?? this.youth,
      children: children ?? this.children,
      sundayHomeChurch: sundayHomeChurch ?? this.sundayHomeChurch,
      tithe: tithe ?? this.tithe,
      offerings: offerings ?? this.offerings,
      emergencyCollection: emergencyCollection ?? this.emergencyCollection,
      plannedCollection: plannedCollection ?? this.plannedCollection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (churchId.present) {
      map['church_id'] = Variable<int>(churchId.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<DateTime>(weekStartDate.value);
    }
    if (men.present) {
      map['men'] = Variable<int>(men.value);
    }
    if (women.present) {
      map['women'] = Variable<int>(women.value);
    }
    if (youth.present) {
      map['youth'] = Variable<int>(youth.value);
    }
    if (children.present) {
      map['children'] = Variable<int>(children.value);
    }
    if (sundayHomeChurch.present) {
      map['sunday_home_church'] = Variable<int>(sundayHomeChurch.value);
    }
    if (tithe.present) {
      map['tithe'] = Variable<double>(tithe.value);
    }
    if (offerings.present) {
      map['offerings'] = Variable<double>(offerings.value);
    }
    if (emergencyCollection.present) {
      map['emergency_collection'] = Variable<double>(emergencyCollection.value);
    }
    if (plannedCollection.present) {
      map['planned_collection'] = Variable<double>(plannedCollection.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('men: $men, ')
          ..write('women: $women, ')
          ..write('youth: $youth, ')
          ..write('children: $children, ')
          ..write('sundayHomeChurch: $sundayHomeChurch, ')
          ..write('tithe: $tithe, ')
          ..write('offerings: $offerings, ')
          ..write('emergencyCollection: $emergencyCollection, ')
          ..write('plannedCollection: $plannedCollection, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DerivedMetricsListTable extends DerivedMetricsList
    with TableInfo<$DerivedMetricsListTable, DerivedMetricsListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DerivedMetricsListTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _churchIdMeta = const VerificationMeta(
    'churchId',
  );
  @override
  late final GeneratedColumn<int> churchId = GeneratedColumn<int>(
    'church_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES churches (id)',
    ),
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageAttendanceMeta = const VerificationMeta(
    'averageAttendance',
  );
  @override
  late final GeneratedColumn<double> averageAttendance =
      GeneratedColumn<double>(
        'average_attendance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _averageIncomeMeta = const VerificationMeta(
    'averageIncome',
  );
  @override
  late final GeneratedColumn<double> averageIncome = GeneratedColumn<double>(
    'average_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _growthPercentageMeta = const VerificationMeta(
    'growthPercentage',
  );
  @override
  late final GeneratedColumn<double> growthPercentage = GeneratedColumn<double>(
    'growth_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceToIncomeRatioMeta =
      const VerificationMeta('attendanceToIncomeRatio');
  @override
  late final GeneratedColumn<double> attendanceToIncomeRatio =
      GeneratedColumn<double>(
        'attendance_to_income_ratio',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _perCapitaGivingMeta = const VerificationMeta(
    'perCapitaGiving',
  );
  @override
  late final GeneratedColumn<double> perCapitaGiving = GeneratedColumn<double>(
    'per_capita_giving',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _menPercentageMeta = const VerificationMeta(
    'menPercentage',
  );
  @override
  late final GeneratedColumn<double> menPercentage = GeneratedColumn<double>(
    'men_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _womenPercentageMeta = const VerificationMeta(
    'womenPercentage',
  );
  @override
  late final GeneratedColumn<double> womenPercentage = GeneratedColumn<double>(
    'women_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _youthPercentageMeta = const VerificationMeta(
    'youthPercentage',
  );
  @override
  late final GeneratedColumn<double> youthPercentage = GeneratedColumn<double>(
    'youth_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childrenPercentageMeta =
      const VerificationMeta('childrenPercentage');
  @override
  late final GeneratedColumn<double> childrenPercentage =
      GeneratedColumn<double>(
        'children_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _tithePercentageMeta = const VerificationMeta(
    'tithePercentage',
  );
  @override
  late final GeneratedColumn<double> tithePercentage = GeneratedColumn<double>(
    'tithe_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offeringsPercentageMeta =
      const VerificationMeta('offeringsPercentage');
  @override
  late final GeneratedColumn<double> offeringsPercentage =
      GeneratedColumn<double>(
        'offerings_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calculatedAtMeta = const VerificationMeta(
    'calculatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
    'calculated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    churchId,
    periodStart,
    periodEnd,
    averageAttendance,
    averageIncome,
    growthPercentage,
    attendanceToIncomeRatio,
    perCapitaGiving,
    menPercentage,
    womenPercentage,
    youthPercentage,
    childrenPercentage,
    tithePercentage,
    offeringsPercentage,
    calculatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'derived_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DerivedMetricsListData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('church_id')) {
      context.handle(
        _churchIdMeta,
        churchId.isAcceptableOrUnknown(data['church_id']!, _churchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_churchIdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('average_attendance')) {
      context.handle(
        _averageAttendanceMeta,
        averageAttendance.isAcceptableOrUnknown(
          data['average_attendance']!,
          _averageAttendanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageAttendanceMeta);
    }
    if (data.containsKey('average_income')) {
      context.handle(
        _averageIncomeMeta,
        averageIncome.isAcceptableOrUnknown(
          data['average_income']!,
          _averageIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageIncomeMeta);
    }
    if (data.containsKey('growth_percentage')) {
      context.handle(
        _growthPercentageMeta,
        growthPercentage.isAcceptableOrUnknown(
          data['growth_percentage']!,
          _growthPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_growthPercentageMeta);
    }
    if (data.containsKey('attendance_to_income_ratio')) {
      context.handle(
        _attendanceToIncomeRatioMeta,
        attendanceToIncomeRatio.isAcceptableOrUnknown(
          data['attendance_to_income_ratio']!,
          _attendanceToIncomeRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceToIncomeRatioMeta);
    }
    if (data.containsKey('per_capita_giving')) {
      context.handle(
        _perCapitaGivingMeta,
        perCapitaGiving.isAcceptableOrUnknown(
          data['per_capita_giving']!,
          _perCapitaGivingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perCapitaGivingMeta);
    }
    if (data.containsKey('men_percentage')) {
      context.handle(
        _menPercentageMeta,
        menPercentage.isAcceptableOrUnknown(
          data['men_percentage']!,
          _menPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_menPercentageMeta);
    }
    if (data.containsKey('women_percentage')) {
      context.handle(
        _womenPercentageMeta,
        womenPercentage.isAcceptableOrUnknown(
          data['women_percentage']!,
          _womenPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_womenPercentageMeta);
    }
    if (data.containsKey('youth_percentage')) {
      context.handle(
        _youthPercentageMeta,
        youthPercentage.isAcceptableOrUnknown(
          data['youth_percentage']!,
          _youthPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_youthPercentageMeta);
    }
    if (data.containsKey('children_percentage')) {
      context.handle(
        _childrenPercentageMeta,
        childrenPercentage.isAcceptableOrUnknown(
          data['children_percentage']!,
          _childrenPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_childrenPercentageMeta);
    }
    if (data.containsKey('tithe_percentage')) {
      context.handle(
        _tithePercentageMeta,
        tithePercentage.isAcceptableOrUnknown(
          data['tithe_percentage']!,
          _tithePercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tithePercentageMeta);
    }
    if (data.containsKey('offerings_percentage')) {
      context.handle(
        _offeringsPercentageMeta,
        offeringsPercentage.isAcceptableOrUnknown(
          data['offerings_percentage']!,
          _offeringsPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_offeringsPercentageMeta);
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
        _calculatedAtMeta,
        calculatedAt.isAcceptableOrUnknown(
          data['calculated_at']!,
          _calculatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DerivedMetricsListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DerivedMetricsListData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      )!,
      averageAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_attendance'],
      )!,
      averageIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_income'],
      )!,
      growthPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}growth_percentage'],
      )!,
      attendanceToIncomeRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}attendance_to_income_ratio'],
      )!,
      perCapitaGiving: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}per_capita_giving'],
      )!,
      menPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}men_percentage'],
      )!,
      womenPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}women_percentage'],
      )!,
      youthPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}youth_percentage'],
      )!,
      childrenPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}children_percentage'],
      )!,
      tithePercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tithe_percentage'],
      )!,
      offeringsPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offerings_percentage'],
      )!,
      calculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_at'],
      )!,
    );
  }

  @override
  $DerivedMetricsListTable createAlias(String alias) {
    return $DerivedMetricsListTable(attachedDatabase, alias);
  }
}

class DerivedMetricsListData extends DataClass
    implements Insertable<DerivedMetricsListData> {
  final int id;
  final int churchId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double averageAttendance;
  final double averageIncome;
  final double growthPercentage;
  final double attendanceToIncomeRatio;
  final double perCapitaGiving;
  final double menPercentage;
  final double womenPercentage;
  final double youthPercentage;
  final double childrenPercentage;
  final double tithePercentage;
  final double offeringsPercentage;
  final DateTime calculatedAt;
  const DerivedMetricsListData({
    required this.id,
    required this.churchId,
    required this.periodStart,
    required this.periodEnd,
    required this.averageAttendance,
    required this.averageIncome,
    required this.growthPercentage,
    required this.attendanceToIncomeRatio,
    required this.perCapitaGiving,
    required this.menPercentage,
    required this.womenPercentage,
    required this.youthPercentage,
    required this.childrenPercentage,
    required this.tithePercentage,
    required this.offeringsPercentage,
    required this.calculatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['average_attendance'] = Variable<double>(averageAttendance);
    map['average_income'] = Variable<double>(averageIncome);
    map['growth_percentage'] = Variable<double>(growthPercentage);
    map['attendance_to_income_ratio'] = Variable<double>(
      attendanceToIncomeRatio,
    );
    map['per_capita_giving'] = Variable<double>(perCapitaGiving);
    map['men_percentage'] = Variable<double>(menPercentage);
    map['women_percentage'] = Variable<double>(womenPercentage);
    map['youth_percentage'] = Variable<double>(youthPercentage);
    map['children_percentage'] = Variable<double>(childrenPercentage);
    map['tithe_percentage'] = Variable<double>(tithePercentage);
    map['offerings_percentage'] = Variable<double>(offeringsPercentage);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    return map;
  }

  DerivedMetricsListCompanion toCompanion(bool nullToAbsent) {
    return DerivedMetricsListCompanion(
      id: Value(id),
      churchId: Value(churchId),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      averageAttendance: Value(averageAttendance),
      averageIncome: Value(averageIncome),
      growthPercentage: Value(growthPercentage),
      attendanceToIncomeRatio: Value(attendanceToIncomeRatio),
      perCapitaGiving: Value(perCapitaGiving),
      menPercentage: Value(menPercentage),
      womenPercentage: Value(womenPercentage),
      youthPercentage: Value(youthPercentage),
      childrenPercentage: Value(childrenPercentage),
      tithePercentage: Value(tithePercentage),
      offeringsPercentage: Value(offeringsPercentage),
      calculatedAt: Value(calculatedAt),
    );
  }

  factory DerivedMetricsListData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DerivedMetricsListData(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      averageAttendance: serializer.fromJson<double>(json['averageAttendance']),
      averageIncome: serializer.fromJson<double>(json['averageIncome']),
      growthPercentage: serializer.fromJson<double>(json['growthPercentage']),
      attendanceToIncomeRatio: serializer.fromJson<double>(
        json['attendanceToIncomeRatio'],
      ),
      perCapitaGiving: serializer.fromJson<double>(json['perCapitaGiving']),
      menPercentage: serializer.fromJson<double>(json['menPercentage']),
      womenPercentage: serializer.fromJson<double>(json['womenPercentage']),
      youthPercentage: serializer.fromJson<double>(json['youthPercentage']),
      childrenPercentage: serializer.fromJson<double>(
        json['childrenPercentage'],
      ),
      tithePercentage: serializer.fromJson<double>(json['tithePercentage']),
      offeringsPercentage: serializer.fromJson<double>(
        json['offeringsPercentage'],
      ),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'churchId': serializer.toJson<int>(churchId),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'averageAttendance': serializer.toJson<double>(averageAttendance),
      'averageIncome': serializer.toJson<double>(averageIncome),
      'growthPercentage': serializer.toJson<double>(growthPercentage),
      'attendanceToIncomeRatio': serializer.toJson<double>(
        attendanceToIncomeRatio,
      ),
      'perCapitaGiving': serializer.toJson<double>(perCapitaGiving),
      'menPercentage': serializer.toJson<double>(menPercentage),
      'womenPercentage': serializer.toJson<double>(womenPercentage),
      'youthPercentage': serializer.toJson<double>(youthPercentage),
      'childrenPercentage': serializer.toJson<double>(childrenPercentage),
      'tithePercentage': serializer.toJson<double>(tithePercentage),
      'offeringsPercentage': serializer.toJson<double>(offeringsPercentage),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
    };
  }

  DerivedMetricsListData copyWith({
    int? id,
    int? churchId,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? averageAttendance,
    double? averageIncome,
    double? growthPercentage,
    double? attendanceToIncomeRatio,
    double? perCapitaGiving,
    double? menPercentage,
    double? womenPercentage,
    double? youthPercentage,
    double? childrenPercentage,
    double? tithePercentage,
    double? offeringsPercentage,
    DateTime? calculatedAt,
  }) => DerivedMetricsListData(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    averageAttendance: averageAttendance ?? this.averageAttendance,
    averageIncome: averageIncome ?? this.averageIncome,
    growthPercentage: growthPercentage ?? this.growthPercentage,
    attendanceToIncomeRatio:
        attendanceToIncomeRatio ?? this.attendanceToIncomeRatio,
    perCapitaGiving: perCapitaGiving ?? this.perCapitaGiving,
    menPercentage: menPercentage ?? this.menPercentage,
    womenPercentage: womenPercentage ?? this.womenPercentage,
    youthPercentage: youthPercentage ?? this.youthPercentage,
    childrenPercentage: childrenPercentage ?? this.childrenPercentage,
    tithePercentage: tithePercentage ?? this.tithePercentage,
    offeringsPercentage: offeringsPercentage ?? this.offeringsPercentage,
    calculatedAt: calculatedAt ?? this.calculatedAt,
  );
  DerivedMetricsListData copyWithCompanion(DerivedMetricsListCompanion data) {
    return DerivedMetricsListData(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      averageAttendance: data.averageAttendance.present
          ? data.averageAttendance.value
          : this.averageAttendance,
      averageIncome: data.averageIncome.present
          ? data.averageIncome.value
          : this.averageIncome,
      growthPercentage: data.growthPercentage.present
          ? data.growthPercentage.value
          : this.growthPercentage,
      attendanceToIncomeRatio: data.attendanceToIncomeRatio.present
          ? data.attendanceToIncomeRatio.value
          : this.attendanceToIncomeRatio,
      perCapitaGiving: data.perCapitaGiving.present
          ? data.perCapitaGiving.value
          : this.perCapitaGiving,
      menPercentage: data.menPercentage.present
          ? data.menPercentage.value
          : this.menPercentage,
      womenPercentage: data.womenPercentage.present
          ? data.womenPercentage.value
          : this.womenPercentage,
      youthPercentage: data.youthPercentage.present
          ? data.youthPercentage.value
          : this.youthPercentage,
      childrenPercentage: data.childrenPercentage.present
          ? data.childrenPercentage.value
          : this.childrenPercentage,
      tithePercentage: data.tithePercentage.present
          ? data.tithePercentage.value
          : this.tithePercentage,
      offeringsPercentage: data.offeringsPercentage.present
          ? data.offeringsPercentage.value
          : this.offeringsPercentage,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DerivedMetricsListData(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('averageAttendance: $averageAttendance, ')
          ..write('averageIncome: $averageIncome, ')
          ..write('growthPercentage: $growthPercentage, ')
          ..write('attendanceToIncomeRatio: $attendanceToIncomeRatio, ')
          ..write('perCapitaGiving: $perCapitaGiving, ')
          ..write('menPercentage: $menPercentage, ')
          ..write('womenPercentage: $womenPercentage, ')
          ..write('youthPercentage: $youthPercentage, ')
          ..write('childrenPercentage: $childrenPercentage, ')
          ..write('tithePercentage: $tithePercentage, ')
          ..write('offeringsPercentage: $offeringsPercentage, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    periodStart,
    periodEnd,
    averageAttendance,
    averageIncome,
    growthPercentage,
    attendanceToIncomeRatio,
    perCapitaGiving,
    menPercentage,
    womenPercentage,
    youthPercentage,
    childrenPercentage,
    tithePercentage,
    offeringsPercentage,
    calculatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DerivedMetricsListData &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.averageAttendance == this.averageAttendance &&
          other.averageIncome == this.averageIncome &&
          other.growthPercentage == this.growthPercentage &&
          other.attendanceToIncomeRatio == this.attendanceToIncomeRatio &&
          other.perCapitaGiving == this.perCapitaGiving &&
          other.menPercentage == this.menPercentage &&
          other.womenPercentage == this.womenPercentage &&
          other.youthPercentage == this.youthPercentage &&
          other.childrenPercentage == this.childrenPercentage &&
          other.tithePercentage == this.tithePercentage &&
          other.offeringsPercentage == this.offeringsPercentage &&
          other.calculatedAt == this.calculatedAt);
}

class DerivedMetricsListCompanion
    extends UpdateCompanion<DerivedMetricsListData> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<double> averageAttendance;
  final Value<double> averageIncome;
  final Value<double> growthPercentage;
  final Value<double> attendanceToIncomeRatio;
  final Value<double> perCapitaGiving;
  final Value<double> menPercentage;
  final Value<double> womenPercentage;
  final Value<double> youthPercentage;
  final Value<double> childrenPercentage;
  final Value<double> tithePercentage;
  final Value<double> offeringsPercentage;
  final Value<DateTime> calculatedAt;
  const DerivedMetricsListCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.averageAttendance = const Value.absent(),
    this.averageIncome = const Value.absent(),
    this.growthPercentage = const Value.absent(),
    this.attendanceToIncomeRatio = const Value.absent(),
    this.perCapitaGiving = const Value.absent(),
    this.menPercentage = const Value.absent(),
    this.womenPercentage = const Value.absent(),
    this.youthPercentage = const Value.absent(),
    this.childrenPercentage = const Value.absent(),
    this.tithePercentage = const Value.absent(),
    this.offeringsPercentage = const Value.absent(),
    this.calculatedAt = const Value.absent(),
  });
  DerivedMetricsListCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double averageAttendance,
    required double averageIncome,
    required double growthPercentage,
    required double attendanceToIncomeRatio,
    required double perCapitaGiving,
    required double menPercentage,
    required double womenPercentage,
    required double youthPercentage,
    required double childrenPercentage,
    required double tithePercentage,
    required double offeringsPercentage,
    required DateTime calculatedAt,
  }) : churchId = Value(churchId),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       averageAttendance = Value(averageAttendance),
       averageIncome = Value(averageIncome),
       growthPercentage = Value(growthPercentage),
       attendanceToIncomeRatio = Value(attendanceToIncomeRatio),
       perCapitaGiving = Value(perCapitaGiving),
       menPercentage = Value(menPercentage),
       womenPercentage = Value(womenPercentage),
       youthPercentage = Value(youthPercentage),
       childrenPercentage = Value(childrenPercentage),
       tithePercentage = Value(tithePercentage),
       offeringsPercentage = Value(offeringsPercentage),
       calculatedAt = Value(calculatedAt);
  static Insertable<DerivedMetricsListData> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<double>? averageAttendance,
    Expression<double>? averageIncome,
    Expression<double>? growthPercentage,
    Expression<double>? attendanceToIncomeRatio,
    Expression<double>? perCapitaGiving,
    Expression<double>? menPercentage,
    Expression<double>? womenPercentage,
    Expression<double>? youthPercentage,
    Expression<double>? childrenPercentage,
    Expression<double>? tithePercentage,
    Expression<double>? offeringsPercentage,
    Expression<DateTime>? calculatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (averageAttendance != null) 'average_attendance': averageAttendance,
      if (averageIncome != null) 'average_income': averageIncome,
      if (growthPercentage != null) 'growth_percentage': growthPercentage,
      if (attendanceToIncomeRatio != null)
        'attendance_to_income_ratio': attendanceToIncomeRatio,
      if (perCapitaGiving != null) 'per_capita_giving': perCapitaGiving,
      if (menPercentage != null) 'men_percentage': menPercentage,
      if (womenPercentage != null) 'women_percentage': womenPercentage,
      if (youthPercentage != null) 'youth_percentage': youthPercentage,
      if (childrenPercentage != null) 'children_percentage': childrenPercentage,
      if (tithePercentage != null) 'tithe_percentage': tithePercentage,
      if (offeringsPercentage != null)
        'offerings_percentage': offeringsPercentage,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
    });
  }

  DerivedMetricsListCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<DateTime>? periodStart,
    Value<DateTime>? periodEnd,
    Value<double>? averageAttendance,
    Value<double>? averageIncome,
    Value<double>? growthPercentage,
    Value<double>? attendanceToIncomeRatio,
    Value<double>? perCapitaGiving,
    Value<double>? menPercentage,
    Value<double>? womenPercentage,
    Value<double>? youthPercentage,
    Value<double>? childrenPercentage,
    Value<double>? tithePercentage,
    Value<double>? offeringsPercentage,
    Value<DateTime>? calculatedAt,
  }) {
    return DerivedMetricsListCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      averageAttendance: averageAttendance ?? this.averageAttendance,
      averageIncome: averageIncome ?? this.averageIncome,
      growthPercentage: growthPercentage ?? this.growthPercentage,
      attendanceToIncomeRatio:
          attendanceToIncomeRatio ?? this.attendanceToIncomeRatio,
      perCapitaGiving: perCapitaGiving ?? this.perCapitaGiving,
      menPercentage: menPercentage ?? this.menPercentage,
      womenPercentage: womenPercentage ?? this.womenPercentage,
      youthPercentage: youthPercentage ?? this.youthPercentage,
      childrenPercentage: childrenPercentage ?? this.childrenPercentage,
      tithePercentage: tithePercentage ?? this.tithePercentage,
      offeringsPercentage: offeringsPercentage ?? this.offeringsPercentage,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (churchId.present) {
      map['church_id'] = Variable<int>(churchId.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (averageAttendance.present) {
      map['average_attendance'] = Variable<double>(averageAttendance.value);
    }
    if (averageIncome.present) {
      map['average_income'] = Variable<double>(averageIncome.value);
    }
    if (growthPercentage.present) {
      map['growth_percentage'] = Variable<double>(growthPercentage.value);
    }
    if (attendanceToIncomeRatio.present) {
      map['attendance_to_income_ratio'] = Variable<double>(
        attendanceToIncomeRatio.value,
      );
    }
    if (perCapitaGiving.present) {
      map['per_capita_giving'] = Variable<double>(perCapitaGiving.value);
    }
    if (menPercentage.present) {
      map['men_percentage'] = Variable<double>(menPercentage.value);
    }
    if (womenPercentage.present) {
      map['women_percentage'] = Variable<double>(womenPercentage.value);
    }
    if (youthPercentage.present) {
      map['youth_percentage'] = Variable<double>(youthPercentage.value);
    }
    if (childrenPercentage.present) {
      map['children_percentage'] = Variable<double>(childrenPercentage.value);
    }
    if (tithePercentage.present) {
      map['tithe_percentage'] = Variable<double>(tithePercentage.value);
    }
    if (offeringsPercentage.present) {
      map['offerings_percentage'] = Variable<double>(offeringsPercentage.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DerivedMetricsListCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('averageAttendance: $averageAttendance, ')
          ..write('averageIncome: $averageIncome, ')
          ..write('growthPercentage: $growthPercentage, ')
          ..write('attendanceToIncomeRatio: $attendanceToIncomeRatio, ')
          ..write('perCapitaGiving: $perCapitaGiving, ')
          ..write('menPercentage: $menPercentage, ')
          ..write('womenPercentage: $womenPercentage, ')
          ..write('youthPercentage: $youthPercentage, ')
          ..write('childrenPercentage: $childrenPercentage, ')
          ..write('tithePercentage: $tithePercentage, ')
          ..write('offeringsPercentage: $offeringsPercentage, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExportHistoryListTable extends ExportHistoryList
    with TableInfo<$ExportHistoryListTable, ExportHistoryListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportHistoryListTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _churchIdMeta = const VerificationMeta(
    'churchId',
  );
  @override
  late final GeneratedColumn<int> churchId = GeneratedColumn<int>(
    'church_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES churches (id)',
    ),
  );
  static const VerificationMeta _exportTypeMeta = const VerificationMeta(
    'exportType',
  );
  @override
  late final GeneratedColumn<String> exportType = GeneratedColumn<String>(
    'export_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportNameMeta = const VerificationMeta(
    'exportName',
  );
  @override
  late final GeneratedColumn<String> exportName = GeneratedColumn<String>(
    'export_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _graphTypeMeta = const VerificationMeta(
    'graphType',
  );
  @override
  late final GeneratedColumn<String> graphType = GeneratedColumn<String>(
    'graph_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exportedAtMeta = const VerificationMeta(
    'exportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> exportedAt = GeneratedColumn<DateTime>(
    'exported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordCountMeta = const VerificationMeta(
    'recordCount',
  );
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
    'record_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    churchId,
    exportType,
    exportName,
    filePath,
    graphType,
    exportedAt,
    recordCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportHistoryListData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('church_id')) {
      context.handle(
        _churchIdMeta,
        churchId.isAcceptableOrUnknown(data['church_id']!, _churchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_churchIdMeta);
    }
    if (data.containsKey('export_type')) {
      context.handle(
        _exportTypeMeta,
        exportType.isAcceptableOrUnknown(data['export_type']!, _exportTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_exportTypeMeta);
    }
    if (data.containsKey('export_name')) {
      context.handle(
        _exportNameMeta,
        exportName.isAcceptableOrUnknown(data['export_name']!, _exportNameMeta),
      );
    } else if (isInserting) {
      context.missing(_exportNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('graph_type')) {
      context.handle(
        _graphTypeMeta,
        graphType.isAcceptableOrUnknown(data['graph_type']!, _graphTypeMeta),
      );
    }
    if (data.containsKey('exported_at')) {
      context.handle(
        _exportedAtMeta,
        exportedAt.isAcceptableOrUnknown(data['exported_at']!, _exportedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_exportedAtMeta);
    }
    if (data.containsKey('record_count')) {
      context.handle(
        _recordCountMeta,
        recordCount.isAcceptableOrUnknown(
          data['record_count']!,
          _recordCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportHistoryListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportHistoryListData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      exportType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}export_type'],
      )!,
      exportName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}export_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      graphType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graph_type'],
      ),
      exportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exported_at'],
      )!,
      recordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_count'],
      )!,
    );
  }

  @override
  $ExportHistoryListTable createAlias(String alias) {
    return $ExportHistoryListTable(attachedDatabase, alias);
  }
}

class ExportHistoryListData extends DataClass
    implements Insertable<ExportHistoryListData> {
  final int id;
  final int churchId;
  final String exportType;
  final String exportName;
  final String? filePath;
  final String? graphType;
  final DateTime exportedAt;
  final int recordCount;
  const ExportHistoryListData({
    required this.id,
    required this.churchId,
    required this.exportType,
    required this.exportName,
    this.filePath,
    this.graphType,
    required this.exportedAt,
    required this.recordCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    map['export_type'] = Variable<String>(exportType);
    map['export_name'] = Variable<String>(exportName);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || graphType != null) {
      map['graph_type'] = Variable<String>(graphType);
    }
    map['exported_at'] = Variable<DateTime>(exportedAt);
    map['record_count'] = Variable<int>(recordCount);
    return map;
  }

  ExportHistoryListCompanion toCompanion(bool nullToAbsent) {
    return ExportHistoryListCompanion(
      id: Value(id),
      churchId: Value(churchId),
      exportType: Value(exportType),
      exportName: Value(exportName),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      graphType: graphType == null && nullToAbsent
          ? const Value.absent()
          : Value(graphType),
      exportedAt: Value(exportedAt),
      recordCount: Value(recordCount),
    );
  }

  factory ExportHistoryListData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportHistoryListData(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      exportType: serializer.fromJson<String>(json['exportType']),
      exportName: serializer.fromJson<String>(json['exportName']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      graphType: serializer.fromJson<String?>(json['graphType']),
      exportedAt: serializer.fromJson<DateTime>(json['exportedAt']),
      recordCount: serializer.fromJson<int>(json['recordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'churchId': serializer.toJson<int>(churchId),
      'exportType': serializer.toJson<String>(exportType),
      'exportName': serializer.toJson<String>(exportName),
      'filePath': serializer.toJson<String?>(filePath),
      'graphType': serializer.toJson<String?>(graphType),
      'exportedAt': serializer.toJson<DateTime>(exportedAt),
      'recordCount': serializer.toJson<int>(recordCount),
    };
  }

  ExportHistoryListData copyWith({
    int? id,
    int? churchId,
    String? exportType,
    String? exportName,
    Value<String?> filePath = const Value.absent(),
    Value<String?> graphType = const Value.absent(),
    DateTime? exportedAt,
    int? recordCount,
  }) => ExportHistoryListData(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    exportType: exportType ?? this.exportType,
    exportName: exportName ?? this.exportName,
    filePath: filePath.present ? filePath.value : this.filePath,
    graphType: graphType.present ? graphType.value : this.graphType,
    exportedAt: exportedAt ?? this.exportedAt,
    recordCount: recordCount ?? this.recordCount,
  );
  ExportHistoryListData copyWithCompanion(ExportHistoryListCompanion data) {
    return ExportHistoryListData(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      exportType: data.exportType.present
          ? data.exportType.value
          : this.exportType,
      exportName: data.exportName.present
          ? data.exportName.value
          : this.exportName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      graphType: data.graphType.present ? data.graphType.value : this.graphType,
      exportedAt: data.exportedAt.present
          ? data.exportedAt.value
          : this.exportedAt,
      recordCount: data.recordCount.present
          ? data.recordCount.value
          : this.recordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportHistoryListData(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('exportType: $exportType, ')
          ..write('exportName: $exportName, ')
          ..write('filePath: $filePath, ')
          ..write('graphType: $graphType, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('recordCount: $recordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    exportType,
    exportName,
    filePath,
    graphType,
    exportedAt,
    recordCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportHistoryListData &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.exportType == this.exportType &&
          other.exportName == this.exportName &&
          other.filePath == this.filePath &&
          other.graphType == this.graphType &&
          other.exportedAt == this.exportedAt &&
          other.recordCount == this.recordCount);
}

class ExportHistoryListCompanion
    extends UpdateCompanion<ExportHistoryListData> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<String> exportType;
  final Value<String> exportName;
  final Value<String?> filePath;
  final Value<String?> graphType;
  final Value<DateTime> exportedAt;
  final Value<int> recordCount;
  const ExportHistoryListCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.exportType = const Value.absent(),
    this.exportName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.graphType = const Value.absent(),
    this.exportedAt = const Value.absent(),
    this.recordCount = const Value.absent(),
  });
  ExportHistoryListCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    required String exportType,
    required String exportName,
    this.filePath = const Value.absent(),
    this.graphType = const Value.absent(),
    required DateTime exportedAt,
    this.recordCount = const Value.absent(),
  }) : churchId = Value(churchId),
       exportType = Value(exportType),
       exportName = Value(exportName),
       exportedAt = Value(exportedAt);
  static Insertable<ExportHistoryListData> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<String>? exportType,
    Expression<String>? exportName,
    Expression<String>? filePath,
    Expression<String>? graphType,
    Expression<DateTime>? exportedAt,
    Expression<int>? recordCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (exportType != null) 'export_type': exportType,
      if (exportName != null) 'export_name': exportName,
      if (filePath != null) 'file_path': filePath,
      if (graphType != null) 'graph_type': graphType,
      if (exportedAt != null) 'exported_at': exportedAt,
      if (recordCount != null) 'record_count': recordCount,
    });
  }

  ExportHistoryListCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<String>? exportType,
    Value<String>? exportName,
    Value<String?>? filePath,
    Value<String?>? graphType,
    Value<DateTime>? exportedAt,
    Value<int>? recordCount,
  }) {
    return ExportHistoryListCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      exportType: exportType ?? this.exportType,
      exportName: exportName ?? this.exportName,
      filePath: filePath ?? this.filePath,
      graphType: graphType ?? this.graphType,
      exportedAt: exportedAt ?? this.exportedAt,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (churchId.present) {
      map['church_id'] = Variable<int>(churchId.value);
    }
    if (exportType.present) {
      map['export_type'] = Variable<String>(exportType.value);
    }
    if (exportName.present) {
      map['export_name'] = Variable<String>(exportName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (graphType.present) {
      map['graph_type'] = Variable<String>(graphType.value);
    }
    if (exportedAt.present) {
      map['exported_at'] = Variable<DateTime>(exportedAt.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportHistoryListCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('exportType: $exportType, ')
          ..write('exportName: $exportName, ')
          ..write('filePath: $filePath, ')
          ..write('graphType: $graphType, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('recordCount: $recordCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChurchesTable churches = $ChurchesTable(this);
  late final $AdminUsersTable adminUsers = $AdminUsersTable(this);
  late final $WeeklyRecordsTable weeklyRecords = $WeeklyRecordsTable(this);
  late final $DerivedMetricsListTable derivedMetricsList =
      $DerivedMetricsListTable(this);
  late final $ExportHistoryListTable exportHistoryList =
      $ExportHistoryListTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    churches,
    adminUsers,
    weeklyRecords,
    derivedMetricsList,
    exportHistoryList,
  ];
}

typedef $$ChurchesTableCreateCompanionBuilder =
    ChurchesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> address,
      Value<String?> contactEmail,
      Value<String?> contactPhone,
      Value<String> currency,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ChurchesTableUpdateCompanionBuilder =
    ChurchesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> address,
      Value<String?> contactEmail,
      Value<String?> contactPhone,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ChurchesTableReferences
    extends BaseReferences<_$AppDatabase, $ChurchesTable, Churche> {
  $$ChurchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AdminUsersTable, List<AdminUser>>
  _adminUsersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adminUsers,
    aliasName: $_aliasNameGenerator(db.churches.id, db.adminUsers.churchId),
  );

  $$AdminUsersTableProcessedTableManager get adminUsersRefs {
    final manager = $$AdminUsersTableTableManager(
      $_db,
      $_db.adminUsers,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_adminUsersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WeeklyRecordsTable, List<WeeklyRecord>>
  _weeklyRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weeklyRecords,
    aliasName: $_aliasNameGenerator(db.churches.id, db.weeklyRecords.churchId),
  );

  $$WeeklyRecordsTableProcessedTableManager get weeklyRecordsRefs {
    final manager = $$WeeklyRecordsTableTableManager(
      $_db,
      $_db.weeklyRecords,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weeklyRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DerivedMetricsListTable,
    List<DerivedMetricsListData>
  >
  _derivedMetricsListRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.derivedMetricsList,
        aliasName: $_aliasNameGenerator(
          db.churches.id,
          db.derivedMetricsList.churchId,
        ),
      );

  $$DerivedMetricsListTableProcessedTableManager get derivedMetricsListRefs {
    final manager = $$DerivedMetricsListTableTableManager(
      $_db,
      $_db.derivedMetricsList,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _derivedMetricsListRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExportHistoryListTable,
    List<ExportHistoryListData>
  >
  _exportHistoryListRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exportHistoryList,
        aliasName: $_aliasNameGenerator(
          db.churches.id,
          db.exportHistoryList.churchId,
        ),
      );

  $$ExportHistoryListTableProcessedTableManager get exportHistoryListRefs {
    final manager = $$ExportHistoryListTableTableManager(
      $_db,
      $_db.exportHistoryList,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exportHistoryListRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChurchesTableFilterComposer
    extends Composer<_$AppDatabase, $ChurchesTable> {
  $$ChurchesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactEmail => $composableBuilder(
    column: $table.contactEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
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

  Expression<bool> adminUsersRefs(
    Expression<bool> Function($$AdminUsersTableFilterComposer f) f,
  ) {
    final $$AdminUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUsersTableFilterComposer(
            $db: $db,
            $table: $db.adminUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> weeklyRecordsRefs(
    Expression<bool> Function($$WeeklyRecordsTableFilterComposer f) f,
  ) {
    final $$WeeklyRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyRecords,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyRecordsTableFilterComposer(
            $db: $db,
            $table: $db.weeklyRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> derivedMetricsListRefs(
    Expression<bool> Function($$DerivedMetricsListTableFilterComposer f) f,
  ) {
    final $$DerivedMetricsListTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.derivedMetricsList,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DerivedMetricsListTableFilterComposer(
            $db: $db,
            $table: $db.derivedMetricsList,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportHistoryListRefs(
    Expression<bool> Function($$ExportHistoryListTableFilterComposer f) f,
  ) {
    final $$ExportHistoryListTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportHistoryList,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportHistoryListTableFilterComposer(
            $db: $db,
            $table: $db.exportHistoryList,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChurchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChurchesTable> {
  $$ChurchesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactEmail => $composableBuilder(
    column: $table.contactEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
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

class $$ChurchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChurchesTable> {
  $$ChurchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get contactEmail => $composableBuilder(
    column: $table.contactEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> adminUsersRefs<T extends Object>(
    Expression<T> Function($$AdminUsersTableAnnotationComposer a) f,
  ) {
    final $$AdminUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.adminUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> weeklyRecordsRefs<T extends Object>(
    Expression<T> Function($$WeeklyRecordsTableAnnotationComposer a) f,
  ) {
    final $$WeeklyRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyRecords,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.weeklyRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> derivedMetricsListRefs<T extends Object>(
    Expression<T> Function($$DerivedMetricsListTableAnnotationComposer a) f,
  ) {
    final $$DerivedMetricsListTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.derivedMetricsList,
          getReferencedColumn: (t) => t.churchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DerivedMetricsListTableAnnotationComposer(
                $db: $db,
                $table: $db.derivedMetricsList,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> exportHistoryListRefs<T extends Object>(
    Expression<T> Function($$ExportHistoryListTableAnnotationComposer a) f,
  ) {
    final $$ExportHistoryListTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exportHistoryList,
          getReferencedColumn: (t) => t.churchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExportHistoryListTableAnnotationComposer(
                $db: $db,
                $table: $db.exportHistoryList,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ChurchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChurchesTable,
          Churche,
          $$ChurchesTableFilterComposer,
          $$ChurchesTableOrderingComposer,
          $$ChurchesTableAnnotationComposer,
          $$ChurchesTableCreateCompanionBuilder,
          $$ChurchesTableUpdateCompanionBuilder,
          (Churche, $$ChurchesTableReferences),
          Churche,
          PrefetchHooks Function({
            bool adminUsersRefs,
            bool weeklyRecordsRefs,
            bool derivedMetricsListRefs,
            bool exportHistoryListRefs,
          })
        > {
  $$ChurchesTableTableManager(_$AppDatabase db, $ChurchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChurchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChurchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChurchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> contactEmail = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ChurchesCompanion(
                id: id,
                name: name,
                address: address,
                contactEmail: contactEmail,
                contactPhone: contactPhone,
                currency: currency,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> address = const Value.absent(),
                Value<String?> contactEmail = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<String> currency = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ChurchesCompanion.insert(
                id: id,
                name: name,
                address: address,
                contactEmail: contactEmail,
                contactPhone: contactPhone,
                currency: currency,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChurchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                adminUsersRefs = false,
                weeklyRecordsRefs = false,
                derivedMetricsListRefs = false,
                exportHistoryListRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (adminUsersRefs) db.adminUsers,
                    if (weeklyRecordsRefs) db.weeklyRecords,
                    if (derivedMetricsListRefs) db.derivedMetricsList,
                    if (exportHistoryListRefs) db.exportHistoryList,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (adminUsersRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          AdminUser
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._adminUsersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).adminUsersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (weeklyRecordsRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          WeeklyRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._weeklyRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).weeklyRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (derivedMetricsListRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          DerivedMetricsListData
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._derivedMetricsListRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).derivedMetricsListRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exportHistoryListRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          ExportHistoryListData
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._exportHistoryListRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).exportHistoryListRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
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

typedef $$ChurchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChurchesTable,
      Churche,
      $$ChurchesTableFilterComposer,
      $$ChurchesTableOrderingComposer,
      $$ChurchesTableAnnotationComposer,
      $$ChurchesTableCreateCompanionBuilder,
      $$ChurchesTableUpdateCompanionBuilder,
      (Churche, $$ChurchesTableReferences),
      Churche,
      PrefetchHooks Function({
        bool adminUsersRefs,
        bool weeklyRecordsRefs,
        bool derivedMetricsListRefs,
        bool exportHistoryListRefs,
      })
    >;
typedef $$AdminUsersTableCreateCompanionBuilder =
    AdminUsersCompanion Function({
      Value<int> id,
      required String username,
      required String fullName,
      Value<String?> email,
      required int churchId,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime lastLoginAt,
    });
typedef $$AdminUsersTableUpdateCompanionBuilder =
    AdminUsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> fullName,
      Value<String?> email,
      Value<int> churchId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> lastLoginAt,
    });

final class $$AdminUsersTableReferences
    extends BaseReferences<_$AppDatabase, $AdminUsersTable, AdminUser> {
  $$AdminUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.adminUsers.churchId, db.churches.id),
      );

  $$ChurchesTableProcessedTableManager get churchId {
    final $_column = $_itemColumn<int>('church_id')!;

    final manager = $$ChurchesTableTableManager(
      $_db,
      $_db.churches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_churchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdminUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AdminUsersTable> {
  $$AdminUsersTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChurchesTableFilterComposer get churchId {
    final $$ChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableFilterComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdminUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AdminUsersTable> {
  $$AdminUsersTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChurchesTableOrderingComposer get churchId {
    final $$ChurchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableOrderingComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdminUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdminUsersTable> {
  $$AdminUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  $$ChurchesTableAnnotationComposer get churchId {
    final $$ChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdminUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdminUsersTable,
          AdminUser,
          $$AdminUsersTableFilterComposer,
          $$AdminUsersTableOrderingComposer,
          $$AdminUsersTableAnnotationComposer,
          $$AdminUsersTableCreateCompanionBuilder,
          $$AdminUsersTableUpdateCompanionBuilder,
          (AdminUser, $$AdminUsersTableReferences),
          AdminUser,
          PrefetchHooks Function({bool churchId})
        > {
  $$AdminUsersTableTableManager(_$AppDatabase db, $AdminUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
              }) => AdminUsersCompanion(
                id: id,
                username: username,
                fullName: fullName,
                email: email,
                churchId: churchId,
                isActive: isActive,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String fullName,
                Value<String?> email = const Value.absent(),
                required int churchId,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastLoginAt,
              }) => AdminUsersCompanion.insert(
                id: id,
                username: username,
                fullName: fullName,
                email: email,
                churchId: churchId,
                isActive: isActive,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdminUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({churchId = false}) {
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
                    if (churchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.churchId,
                                referencedTable: $$AdminUsersTableReferences
                                    ._churchIdTable(db),
                                referencedColumn: $$AdminUsersTableReferences
                                    ._churchIdTable(db)
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

typedef $$AdminUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdminUsersTable,
      AdminUser,
      $$AdminUsersTableFilterComposer,
      $$AdminUsersTableOrderingComposer,
      $$AdminUsersTableAnnotationComposer,
      $$AdminUsersTableCreateCompanionBuilder,
      $$AdminUsersTableUpdateCompanionBuilder,
      (AdminUser, $$AdminUsersTableReferences),
      AdminUser,
      PrefetchHooks Function({bool churchId})
    >;
typedef $$WeeklyRecordsTableCreateCompanionBuilder =
    WeeklyRecordsCompanion Function({
      Value<int> id,
      required int churchId,
      required DateTime weekStartDate,
      Value<int> men,
      Value<int> women,
      Value<int> youth,
      Value<int> children,
      Value<int> sundayHomeChurch,
      Value<double> tithe,
      Value<double> offerings,
      Value<double> emergencyCollection,
      Value<double> plannedCollection,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WeeklyRecordsTableUpdateCompanionBuilder =
    WeeklyRecordsCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<DateTime> weekStartDate,
      Value<int> men,
      Value<int> women,
      Value<int> youth,
      Value<int> children,
      Value<int> sundayHomeChurch,
      Value<double> tithe,
      Value<double> offerings,
      Value<double> emergencyCollection,
      Value<double> plannedCollection,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WeeklyRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $WeeklyRecordsTable, WeeklyRecord> {
  $$WeeklyRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.weeklyRecords.churchId, db.churches.id),
      );

  $$ChurchesTableProcessedTableManager get churchId {
    final $_column = $_itemColumn<int>('church_id')!;

    final manager = $$ChurchesTableTableManager(
      $_db,
      $_db.churches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_churchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeeklyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyRecordsTable> {
  $$WeeklyRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get men => $composableBuilder(
    column: $table.men,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get women => $composableBuilder(
    column: $table.women,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get youth => $composableBuilder(
    column: $table.youth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get children => $composableBuilder(
    column: $table.children,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sundayHomeChurch => $composableBuilder(
    column: $table.sundayHomeChurch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tithe => $composableBuilder(
    column: $table.tithe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offerings => $composableBuilder(
    column: $table.offerings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get emergencyCollection => $composableBuilder(
    column: $table.emergencyCollection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedCollection => $composableBuilder(
    column: $table.plannedCollection,
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

  $$ChurchesTableFilterComposer get churchId {
    final $$ChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableFilterComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyRecordsTable> {
  $$WeeklyRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get men => $composableBuilder(
    column: $table.men,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get women => $composableBuilder(
    column: $table.women,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get youth => $composableBuilder(
    column: $table.youth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get children => $composableBuilder(
    column: $table.children,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sundayHomeChurch => $composableBuilder(
    column: $table.sundayHomeChurch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tithe => $composableBuilder(
    column: $table.tithe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offerings => $composableBuilder(
    column: $table.offerings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get emergencyCollection => $composableBuilder(
    column: $table.emergencyCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedCollection => $composableBuilder(
    column: $table.plannedCollection,
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

  $$ChurchesTableOrderingComposer get churchId {
    final $$ChurchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableOrderingComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyRecordsTable> {
  $$WeeklyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get men =>
      $composableBuilder(column: $table.men, builder: (column) => column);

  GeneratedColumn<int> get women =>
      $composableBuilder(column: $table.women, builder: (column) => column);

  GeneratedColumn<int> get youth =>
      $composableBuilder(column: $table.youth, builder: (column) => column);

  GeneratedColumn<int> get children =>
      $composableBuilder(column: $table.children, builder: (column) => column);

  GeneratedColumn<int> get sundayHomeChurch => $composableBuilder(
    column: $table.sundayHomeChurch,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tithe =>
      $composableBuilder(column: $table.tithe, builder: (column) => column);

  GeneratedColumn<double> get offerings =>
      $composableBuilder(column: $table.offerings, builder: (column) => column);

  GeneratedColumn<double> get emergencyCollection => $composableBuilder(
    column: $table.emergencyCollection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedCollection => $composableBuilder(
    column: $table.plannedCollection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChurchesTableAnnotationComposer get churchId {
    final $$ChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyRecordsTable,
          WeeklyRecord,
          $$WeeklyRecordsTableFilterComposer,
          $$WeeklyRecordsTableOrderingComposer,
          $$WeeklyRecordsTableAnnotationComposer,
          $$WeeklyRecordsTableCreateCompanionBuilder,
          $$WeeklyRecordsTableUpdateCompanionBuilder,
          (WeeklyRecord, $$WeeklyRecordsTableReferences),
          WeeklyRecord,
          PrefetchHooks Function({bool churchId})
        > {
  $$WeeklyRecordsTableTableManager(_$AppDatabase db, $WeeklyRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<DateTime> weekStartDate = const Value.absent(),
                Value<int> men = const Value.absent(),
                Value<int> women = const Value.absent(),
                Value<int> youth = const Value.absent(),
                Value<int> children = const Value.absent(),
                Value<int> sundayHomeChurch = const Value.absent(),
                Value<double> tithe = const Value.absent(),
                Value<double> offerings = const Value.absent(),
                Value<double> emergencyCollection = const Value.absent(),
                Value<double> plannedCollection = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklyRecordsCompanion(
                id: id,
                churchId: churchId,
                weekStartDate: weekStartDate,
                men: men,
                women: women,
                youth: youth,
                children: children,
                sundayHomeChurch: sundayHomeChurch,
                tithe: tithe,
                offerings: offerings,
                emergencyCollection: emergencyCollection,
                plannedCollection: plannedCollection,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                required DateTime weekStartDate,
                Value<int> men = const Value.absent(),
                Value<int> women = const Value.absent(),
                Value<int> youth = const Value.absent(),
                Value<int> children = const Value.absent(),
                Value<int> sundayHomeChurch = const Value.absent(),
                Value<double> tithe = const Value.absent(),
                Value<double> offerings = const Value.absent(),
                Value<double> emergencyCollection = const Value.absent(),
                Value<double> plannedCollection = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WeeklyRecordsCompanion.insert(
                id: id,
                churchId: churchId,
                weekStartDate: weekStartDate,
                men: men,
                women: women,
                youth: youth,
                children: children,
                sundayHomeChurch: sundayHomeChurch,
                tithe: tithe,
                offerings: offerings,
                emergencyCollection: emergencyCollection,
                plannedCollection: plannedCollection,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WeeklyRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({churchId = false}) {
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
                    if (churchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.churchId,
                                referencedTable: $$WeeklyRecordsTableReferences
                                    ._churchIdTable(db),
                                referencedColumn: $$WeeklyRecordsTableReferences
                                    ._churchIdTable(db)
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

typedef $$WeeklyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyRecordsTable,
      WeeklyRecord,
      $$WeeklyRecordsTableFilterComposer,
      $$WeeklyRecordsTableOrderingComposer,
      $$WeeklyRecordsTableAnnotationComposer,
      $$WeeklyRecordsTableCreateCompanionBuilder,
      $$WeeklyRecordsTableUpdateCompanionBuilder,
      (WeeklyRecord, $$WeeklyRecordsTableReferences),
      WeeklyRecord,
      PrefetchHooks Function({bool churchId})
    >;
typedef $$DerivedMetricsListTableCreateCompanionBuilder =
    DerivedMetricsListCompanion Function({
      Value<int> id,
      required int churchId,
      required DateTime periodStart,
      required DateTime periodEnd,
      required double averageAttendance,
      required double averageIncome,
      required double growthPercentage,
      required double attendanceToIncomeRatio,
      required double perCapitaGiving,
      required double menPercentage,
      required double womenPercentage,
      required double youthPercentage,
      required double childrenPercentage,
      required double tithePercentage,
      required double offeringsPercentage,
      required DateTime calculatedAt,
    });
typedef $$DerivedMetricsListTableUpdateCompanionBuilder =
    DerivedMetricsListCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<DateTime> periodStart,
      Value<DateTime> periodEnd,
      Value<double> averageAttendance,
      Value<double> averageIncome,
      Value<double> growthPercentage,
      Value<double> attendanceToIncomeRatio,
      Value<double> perCapitaGiving,
      Value<double> menPercentage,
      Value<double> womenPercentage,
      Value<double> youthPercentage,
      Value<double> childrenPercentage,
      Value<double> tithePercentage,
      Value<double> offeringsPercentage,
      Value<DateTime> calculatedAt,
    });

final class $$DerivedMetricsListTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DerivedMetricsListTable,
          DerivedMetricsListData
        > {
  $$DerivedMetricsListTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.derivedMetricsList.churchId, db.churches.id),
      );

  $$ChurchesTableProcessedTableManager get churchId {
    final $_column = $_itemColumn<int>('church_id')!;

    final manager = $$ChurchesTableTableManager(
      $_db,
      $_db.churches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_churchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DerivedMetricsListTableFilterComposer
    extends Composer<_$AppDatabase, $DerivedMetricsListTable> {
  $$DerivedMetricsListTableFilterComposer({
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

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageAttendance => $composableBuilder(
    column: $table.averageAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageIncome => $composableBuilder(
    column: $table.averageIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get growthPercentage => $composableBuilder(
    column: $table.growthPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get attendanceToIncomeRatio => $composableBuilder(
    column: $table.attendanceToIncomeRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perCapitaGiving => $composableBuilder(
    column: $table.perCapitaGiving,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get menPercentage => $composableBuilder(
    column: $table.menPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get womenPercentage => $composableBuilder(
    column: $table.womenPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get youthPercentage => $composableBuilder(
    column: $table.youthPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get childrenPercentage => $composableBuilder(
    column: $table.childrenPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tithePercentage => $composableBuilder(
    column: $table.tithePercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offeringsPercentage => $composableBuilder(
    column: $table.offeringsPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChurchesTableFilterComposer get churchId {
    final $$ChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableFilterComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DerivedMetricsListTableOrderingComposer
    extends Composer<_$AppDatabase, $DerivedMetricsListTable> {
  $$DerivedMetricsListTableOrderingComposer({
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

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageAttendance => $composableBuilder(
    column: $table.averageAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageIncome => $composableBuilder(
    column: $table.averageIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get growthPercentage => $composableBuilder(
    column: $table.growthPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get attendanceToIncomeRatio => $composableBuilder(
    column: $table.attendanceToIncomeRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perCapitaGiving => $composableBuilder(
    column: $table.perCapitaGiving,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get menPercentage => $composableBuilder(
    column: $table.menPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get womenPercentage => $composableBuilder(
    column: $table.womenPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get youthPercentage => $composableBuilder(
    column: $table.youthPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get childrenPercentage => $composableBuilder(
    column: $table.childrenPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tithePercentage => $composableBuilder(
    column: $table.tithePercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offeringsPercentage => $composableBuilder(
    column: $table.offeringsPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChurchesTableOrderingComposer get churchId {
    final $$ChurchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableOrderingComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DerivedMetricsListTableAnnotationComposer
    extends Composer<_$AppDatabase, $DerivedMetricsListTable> {
  $$DerivedMetricsListTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<double> get averageAttendance => $composableBuilder(
    column: $table.averageAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageIncome => $composableBuilder(
    column: $table.averageIncome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get growthPercentage => $composableBuilder(
    column: $table.growthPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get attendanceToIncomeRatio => $composableBuilder(
    column: $table.attendanceToIncomeRatio,
    builder: (column) => column,
  );

  GeneratedColumn<double> get perCapitaGiving => $composableBuilder(
    column: $table.perCapitaGiving,
    builder: (column) => column,
  );

  GeneratedColumn<double> get menPercentage => $composableBuilder(
    column: $table.menPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get womenPercentage => $composableBuilder(
    column: $table.womenPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get youthPercentage => $composableBuilder(
    column: $table.youthPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get childrenPercentage => $composableBuilder(
    column: $table.childrenPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tithePercentage => $composableBuilder(
    column: $table.tithePercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get offeringsPercentage => $composableBuilder(
    column: $table.offeringsPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => column,
  );

  $$ChurchesTableAnnotationComposer get churchId {
    final $$ChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DerivedMetricsListTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DerivedMetricsListTable,
          DerivedMetricsListData,
          $$DerivedMetricsListTableFilterComposer,
          $$DerivedMetricsListTableOrderingComposer,
          $$DerivedMetricsListTableAnnotationComposer,
          $$DerivedMetricsListTableCreateCompanionBuilder,
          $$DerivedMetricsListTableUpdateCompanionBuilder,
          (DerivedMetricsListData, $$DerivedMetricsListTableReferences),
          DerivedMetricsListData,
          PrefetchHooks Function({bool churchId})
        > {
  $$DerivedMetricsListTableTableManager(
    _$AppDatabase db,
    $DerivedMetricsListTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DerivedMetricsListTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DerivedMetricsListTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DerivedMetricsListTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> periodEnd = const Value.absent(),
                Value<double> averageAttendance = const Value.absent(),
                Value<double> averageIncome = const Value.absent(),
                Value<double> growthPercentage = const Value.absent(),
                Value<double> attendanceToIncomeRatio = const Value.absent(),
                Value<double> perCapitaGiving = const Value.absent(),
                Value<double> menPercentage = const Value.absent(),
                Value<double> womenPercentage = const Value.absent(),
                Value<double> youthPercentage = const Value.absent(),
                Value<double> childrenPercentage = const Value.absent(),
                Value<double> tithePercentage = const Value.absent(),
                Value<double> offeringsPercentage = const Value.absent(),
                Value<DateTime> calculatedAt = const Value.absent(),
              }) => DerivedMetricsListCompanion(
                id: id,
                churchId: churchId,
                periodStart: periodStart,
                periodEnd: periodEnd,
                averageAttendance: averageAttendance,
                averageIncome: averageIncome,
                growthPercentage: growthPercentage,
                attendanceToIncomeRatio: attendanceToIncomeRatio,
                perCapitaGiving: perCapitaGiving,
                menPercentage: menPercentage,
                womenPercentage: womenPercentage,
                youthPercentage: youthPercentage,
                childrenPercentage: childrenPercentage,
                tithePercentage: tithePercentage,
                offeringsPercentage: offeringsPercentage,
                calculatedAt: calculatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                required DateTime periodStart,
                required DateTime periodEnd,
                required double averageAttendance,
                required double averageIncome,
                required double growthPercentage,
                required double attendanceToIncomeRatio,
                required double perCapitaGiving,
                required double menPercentage,
                required double womenPercentage,
                required double youthPercentage,
                required double childrenPercentage,
                required double tithePercentage,
                required double offeringsPercentage,
                required DateTime calculatedAt,
              }) => DerivedMetricsListCompanion.insert(
                id: id,
                churchId: churchId,
                periodStart: periodStart,
                periodEnd: periodEnd,
                averageAttendance: averageAttendance,
                averageIncome: averageIncome,
                growthPercentage: growthPercentage,
                attendanceToIncomeRatio: attendanceToIncomeRatio,
                perCapitaGiving: perCapitaGiving,
                menPercentage: menPercentage,
                womenPercentage: womenPercentage,
                youthPercentage: youthPercentage,
                childrenPercentage: childrenPercentage,
                tithePercentage: tithePercentage,
                offeringsPercentage: offeringsPercentage,
                calculatedAt: calculatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DerivedMetricsListTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({churchId = false}) {
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
                    if (churchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.churchId,
                                referencedTable:
                                    $$DerivedMetricsListTableReferences
                                        ._churchIdTable(db),
                                referencedColumn:
                                    $$DerivedMetricsListTableReferences
                                        ._churchIdTable(db)
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

typedef $$DerivedMetricsListTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DerivedMetricsListTable,
      DerivedMetricsListData,
      $$DerivedMetricsListTableFilterComposer,
      $$DerivedMetricsListTableOrderingComposer,
      $$DerivedMetricsListTableAnnotationComposer,
      $$DerivedMetricsListTableCreateCompanionBuilder,
      $$DerivedMetricsListTableUpdateCompanionBuilder,
      (DerivedMetricsListData, $$DerivedMetricsListTableReferences),
      DerivedMetricsListData,
      PrefetchHooks Function({bool churchId})
    >;
typedef $$ExportHistoryListTableCreateCompanionBuilder =
    ExportHistoryListCompanion Function({
      Value<int> id,
      required int churchId,
      required String exportType,
      required String exportName,
      Value<String?> filePath,
      Value<String?> graphType,
      required DateTime exportedAt,
      Value<int> recordCount,
    });
typedef $$ExportHistoryListTableUpdateCompanionBuilder =
    ExportHistoryListCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<String> exportType,
      Value<String> exportName,
      Value<String?> filePath,
      Value<String?> graphType,
      Value<DateTime> exportedAt,
      Value<int> recordCount,
    });

final class $$ExportHistoryListTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExportHistoryListTable,
          ExportHistoryListData
        > {
  $$ExportHistoryListTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.exportHistoryList.churchId, db.churches.id),
      );

  $$ChurchesTableProcessedTableManager get churchId {
    final $_column = $_itemColumn<int>('church_id')!;

    final manager = $$ChurchesTableTableManager(
      $_db,
      $_db.churches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_churchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExportHistoryListTableFilterComposer
    extends Composer<_$AppDatabase, $ExportHistoryListTable> {
  $$ExportHistoryListTableFilterComposer({
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

  ColumnFilters<String> get exportType => $composableBuilder(
    column: $table.exportType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exportName => $composableBuilder(
    column: $table.exportName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graphType => $composableBuilder(
    column: $table.graphType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnFilters(column),
  );

  $$ChurchesTableFilterComposer get churchId {
    final $$ChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableFilterComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportHistoryListTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportHistoryListTable> {
  $$ExportHistoryListTableOrderingComposer({
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

  ColumnOrderings<String> get exportType => $composableBuilder(
    column: $table.exportType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exportName => $composableBuilder(
    column: $table.exportName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graphType => $composableBuilder(
    column: $table.graphType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChurchesTableOrderingComposer get churchId {
    final $$ChurchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableOrderingComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportHistoryListTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportHistoryListTable> {
  $$ExportHistoryListTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exportType => $composableBuilder(
    column: $table.exportType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exportName => $composableBuilder(
    column: $table.exportName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get graphType =>
      $composableBuilder(column: $table.graphType, builder: (column) => column);

  GeneratedColumn<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => column,
  );

  $$ChurchesTableAnnotationComposer get churchId {
    final $$ChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.churchId,
      referencedTable: $db.churches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.churches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportHistoryListTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportHistoryListTable,
          ExportHistoryListData,
          $$ExportHistoryListTableFilterComposer,
          $$ExportHistoryListTableOrderingComposer,
          $$ExportHistoryListTableAnnotationComposer,
          $$ExportHistoryListTableCreateCompanionBuilder,
          $$ExportHistoryListTableUpdateCompanionBuilder,
          (ExportHistoryListData, $$ExportHistoryListTableReferences),
          ExportHistoryListData,
          PrefetchHooks Function({bool churchId})
        > {
  $$ExportHistoryListTableTableManager(
    _$AppDatabase db,
    $ExportHistoryListTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportHistoryListTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportHistoryListTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportHistoryListTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<String> exportType = const Value.absent(),
                Value<String> exportName = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> graphType = const Value.absent(),
                Value<DateTime> exportedAt = const Value.absent(),
                Value<int> recordCount = const Value.absent(),
              }) => ExportHistoryListCompanion(
                id: id,
                churchId: churchId,
                exportType: exportType,
                exportName: exportName,
                filePath: filePath,
                graphType: graphType,
                exportedAt: exportedAt,
                recordCount: recordCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                required String exportType,
                required String exportName,
                Value<String?> filePath = const Value.absent(),
                Value<String?> graphType = const Value.absent(),
                required DateTime exportedAt,
                Value<int> recordCount = const Value.absent(),
              }) => ExportHistoryListCompanion.insert(
                id: id,
                churchId: churchId,
                exportType: exportType,
                exportName: exportName,
                filePath: filePath,
                graphType: graphType,
                exportedAt: exportedAt,
                recordCount: recordCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExportHistoryListTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({churchId = false}) {
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
                    if (churchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.churchId,
                                referencedTable:
                                    $$ExportHistoryListTableReferences
                                        ._churchIdTable(db),
                                referencedColumn:
                                    $$ExportHistoryListTableReferences
                                        ._churchIdTable(db)
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

typedef $$ExportHistoryListTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportHistoryListTable,
      ExportHistoryListData,
      $$ExportHistoryListTableFilterComposer,
      $$ExportHistoryListTableOrderingComposer,
      $$ExportHistoryListTableAnnotationComposer,
      $$ExportHistoryListTableCreateCompanionBuilder,
      $$ExportHistoryListTableUpdateCompanionBuilder,
      (ExportHistoryListData, $$ExportHistoryListTableReferences),
      ExportHistoryListData,
      PrefetchHooks Function({bool churchId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChurchesTableTableManager get churches =>
      $$ChurchesTableTableManager(_db, _db.churches);
  $$AdminUsersTableTableManager get adminUsers =>
      $$AdminUsersTableTableManager(_db, _db.adminUsers);
  $$WeeklyRecordsTableTableManager get weeklyRecords =>
      $$WeeklyRecordsTableTableManager(_db, _db.weeklyRecords);
  $$DerivedMetricsListTableTableManager get derivedMetricsList =>
      $$DerivedMetricsListTableTableManager(_db, _db.derivedMetricsList);
  $$ExportHistoryListTableTableManager get exportHistoryList =>
      $$ExportHistoryListTableTableManager(_db, _db.exportHistoryList);
}
