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
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardMemberCountMeta = const VerificationMeta(
    'boardMemberCount',
  );
  @override
  late final GeneratedColumn<int> boardMemberCount = GeneratedColumn<int>(
    'board_member_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMembershipMeta = const VerificationMeta(
    'totalMembership',
  );
  @override
  late final GeneratedColumn<int> totalMembership = GeneratedColumn<int>(
    'total_membership',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    website,
    boardMemberCount,
    totalMembership,
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
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('board_member_count')) {
      context.handle(
        _boardMemberCountMeta,
        boardMemberCount.isAcceptableOrUnknown(
          data['board_member_count']!,
          _boardMemberCountMeta,
        ),
      );
    }
    if (data.containsKey('total_membership')) {
      context.handle(
        _totalMembershipMeta,
        totalMembership.isAcceptableOrUnknown(
          data['total_membership']!,
          _totalMembershipMeta,
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
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      boardMemberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_member_count'],
      )!,
      totalMembership: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_membership'],
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
  final String? website;
  final int boardMemberCount;
  final int totalMembership;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Churche({
    required this.id,
    required this.name,
    this.address,
    this.contactEmail,
    this.contactPhone,
    required this.currency,
    this.website,
    required this.boardMemberCount,
    required this.totalMembership,
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
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    map['board_member_count'] = Variable<int>(boardMemberCount);
    map['total_membership'] = Variable<int>(totalMembership);
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
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      boardMemberCount: Value(boardMemberCount),
      totalMembership: Value(totalMembership),
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
      website: serializer.fromJson<String?>(json['website']),
      boardMemberCount: serializer.fromJson<int>(json['boardMemberCount']),
      totalMembership: serializer.fromJson<int>(json['totalMembership']),
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
      'website': serializer.toJson<String?>(website),
      'boardMemberCount': serializer.toJson<int>(boardMemberCount),
      'totalMembership': serializer.toJson<int>(totalMembership),
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
    Value<String?> website = const Value.absent(),
    int? boardMemberCount,
    int? totalMembership,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Churche(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    contactEmail: contactEmail.present ? contactEmail.value : this.contactEmail,
    contactPhone: contactPhone.present ? contactPhone.value : this.contactPhone,
    currency: currency ?? this.currency,
    website: website.present ? website.value : this.website,
    boardMemberCount: boardMemberCount ?? this.boardMemberCount,
    totalMembership: totalMembership ?? this.totalMembership,
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
      website: data.website.present ? data.website.value : this.website,
      boardMemberCount: data.boardMemberCount.present
          ? data.boardMemberCount.value
          : this.boardMemberCount,
      totalMembership: data.totalMembership.present
          ? data.totalMembership.value
          : this.totalMembership,
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
          ..write('website: $website, ')
          ..write('boardMemberCount: $boardMemberCount, ')
          ..write('totalMembership: $totalMembership, ')
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
    website,
    boardMemberCount,
    totalMembership,
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
          other.website == this.website &&
          other.boardMemberCount == this.boardMemberCount &&
          other.totalMembership == this.totalMembership &&
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
  final Value<String?> website;
  final Value<int> boardMemberCount;
  final Value<int> totalMembership;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ChurchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.currency = const Value.absent(),
    this.website = const Value.absent(),
    this.boardMemberCount = const Value.absent(),
    this.totalMembership = const Value.absent(),
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
    this.website = const Value.absent(),
    this.boardMemberCount = const Value.absent(),
    this.totalMembership = const Value.absent(),
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
    Expression<String>? website,
    Expression<int>? boardMemberCount,
    Expression<int>? totalMembership,
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
      if (website != null) 'website': website,
      if (boardMemberCount != null) 'board_member_count': boardMemberCount,
      if (totalMembership != null) 'total_membership': totalMembership,
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
    Value<String?>? website,
    Value<int>? boardMemberCount,
    Value<int>? totalMembership,
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
      website: website ?? this.website,
      boardMemberCount: boardMemberCount ?? this.boardMemberCount,
      totalMembership: totalMembership ?? this.totalMembership,
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
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (boardMemberCount.present) {
      map['board_member_count'] = Variable<int>(boardMemberCount.value);
    }
    if (totalMembership.present) {
      map['total_membership'] = Variable<int>(totalMembership.value);
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
          ..write('website: $website, ')
          ..write('boardMemberCount: $boardMemberCount, ')
          ..write('totalMembership: $totalMembership, ')
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
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    pinHash,
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
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
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
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
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
  final String? pinHash;
  const AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    required this.churchId,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
    this.pinHash,
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
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
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
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
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
      pinHash: serializer.fromJson<String?>(json['pinHash']),
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
      'pinHash': serializer.toJson<String?>(pinHash),
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
    Value<String?> pinHash = const Value.absent(),
  }) => AdminUser(
    id: id ?? this.id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    email: email.present ? email.value : this.email,
    churchId: churchId ?? this.churchId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
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
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
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
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('pinHash: $pinHash')
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
    pinHash,
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
          other.lastLoginAt == this.lastLoginAt &&
          other.pinHash == this.pinHash);
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
  final Value<String?> pinHash;
  const AdminUsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.churchId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.pinHash = const Value.absent(),
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
    this.pinHash = const Value.absent(),
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
    Expression<String>? pinHash,
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
      if (pinHash != null) 'pin_hash': pinHash,
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
    Value<String?>? pinHash,
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
      pinHash: pinHash ?? this.pinHash,
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
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
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
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('pinHash: $pinHash')
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
  static const VerificationMeta _createdByAdminIdMeta = const VerificationMeta(
    'createdByAdminId',
  );
  @override
  late final GeneratedColumn<int> createdByAdminId = GeneratedColumn<int>(
    'created_by_admin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES admin_users (id)',
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
  static const VerificationMeta _baptismsMeta = const VerificationMeta(
    'baptisms',
  );
  @override
  late final GeneratedColumn<int> baptisms = GeneratedColumn<int>(
    'baptisms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holyCommunionMeta = const VerificationMeta(
    'holyCommunion',
  );
  @override
  late final GeneratedColumn<int> holyCommunion = GeneratedColumn<int>(
    'holy_communion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _sabbathSchoolAttendanceMeta =
      const VerificationMeta('sabbathSchoolAttendance');
  @override
  late final GeneratedColumn<int> sabbathSchoolAttendance =
      GeneratedColumn<int>(
        'sabbath_school_attendance',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _visitorsCountMeta = const VerificationMeta(
    'visitorsCount',
  );
  @override
  late final GeneratedColumn<int> visitorsCount = GeneratedColumn<int>(
    'visitors_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _missionOfferingMeta = const VerificationMeta(
    'missionOffering',
  );
  @override
  late final GeneratedColumn<double> missionOffering = GeneratedColumn<double>(
    'mission_offering',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localChurchBudgetMeta = const VerificationMeta(
    'localChurchBudget',
  );
  @override
  late final GeneratedColumn<double> localChurchBudget =
      GeneratedColumn<double>(
        'local_church_budget',
        aliasedName,
        true,
        type: DriftSqlType.double,
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
    createdByAdminId,
    weekStartDate,
    men,
    women,
    youth,
    children,
    sundayHomeChurch,
    baptisms,
    holyCommunion,
    tithe,
    offerings,
    emergencyCollection,
    plannedCollection,
    sabbathSchoolAttendance,
    visitorsCount,
    missionOffering,
    localChurchBudget,
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
    if (data.containsKey('created_by_admin_id')) {
      context.handle(
        _createdByAdminIdMeta,
        createdByAdminId.isAcceptableOrUnknown(
          data['created_by_admin_id']!,
          _createdByAdminIdMeta,
        ),
      );
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
    if (data.containsKey('baptisms')) {
      context.handle(
        _baptismsMeta,
        baptisms.isAcceptableOrUnknown(data['baptisms']!, _baptismsMeta),
      );
    }
    if (data.containsKey('holy_communion')) {
      context.handle(
        _holyCommunionMeta,
        holyCommunion.isAcceptableOrUnknown(
          data['holy_communion']!,
          _holyCommunionMeta,
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
    if (data.containsKey('sabbath_school_attendance')) {
      context.handle(
        _sabbathSchoolAttendanceMeta,
        sabbathSchoolAttendance.isAcceptableOrUnknown(
          data['sabbath_school_attendance']!,
          _sabbathSchoolAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('visitors_count')) {
      context.handle(
        _visitorsCountMeta,
        visitorsCount.isAcceptableOrUnknown(
          data['visitors_count']!,
          _visitorsCountMeta,
        ),
      );
    }
    if (data.containsKey('mission_offering')) {
      context.handle(
        _missionOfferingMeta,
        missionOffering.isAcceptableOrUnknown(
          data['mission_offering']!,
          _missionOfferingMeta,
        ),
      );
    }
    if (data.containsKey('local_church_budget')) {
      context.handle(
        _localChurchBudgetMeta,
        localChurchBudget.isAcceptableOrUnknown(
          data['local_church_budget']!,
          _localChurchBudgetMeta,
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
      createdByAdminId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_admin_id'],
      ),
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
      baptisms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baptisms'],
      ),
      holyCommunion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}holy_communion'],
      ),
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
      sabbathSchoolAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sabbath_school_attendance'],
      ),
      visitorsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visitors_count'],
      ),
      missionOffering: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mission_offering'],
      ),
      localChurchBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}local_church_budget'],
      ),
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
  final int? createdByAdminId;
  final DateTime weekStartDate;
  final int men;
  final int women;
  final int youth;
  final int children;
  final int sundayHomeChurch;
  final int? baptisms;
  final int? holyCommunion;
  final double tithe;
  final double offerings;
  final double emergencyCollection;
  final double plannedCollection;
  final int? sabbathSchoolAttendance;
  final int? visitorsCount;
  final double? missionOffering;
  final double? localChurchBudget;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeeklyRecord({
    required this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.weekStartDate,
    required this.men,
    required this.women,
    required this.youth,
    required this.children,
    required this.sundayHomeChurch,
    this.baptisms,
    this.holyCommunion,
    required this.tithe,
    required this.offerings,
    required this.emergencyCollection,
    required this.plannedCollection,
    this.sabbathSchoolAttendance,
    this.visitorsCount,
    this.missionOffering,
    this.localChurchBudget,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    if (!nullToAbsent || createdByAdminId != null) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId);
    }
    map['week_start_date'] = Variable<DateTime>(weekStartDate);
    map['men'] = Variable<int>(men);
    map['women'] = Variable<int>(women);
    map['youth'] = Variable<int>(youth);
    map['children'] = Variable<int>(children);
    map['sunday_home_church'] = Variable<int>(sundayHomeChurch);
    if (!nullToAbsent || baptisms != null) {
      map['baptisms'] = Variable<int>(baptisms);
    }
    if (!nullToAbsent || holyCommunion != null) {
      map['holy_communion'] = Variable<int>(holyCommunion);
    }
    map['tithe'] = Variable<double>(tithe);
    map['offerings'] = Variable<double>(offerings);
    map['emergency_collection'] = Variable<double>(emergencyCollection);
    map['planned_collection'] = Variable<double>(plannedCollection);
    if (!nullToAbsent || sabbathSchoolAttendance != null) {
      map['sabbath_school_attendance'] = Variable<int>(sabbathSchoolAttendance);
    }
    if (!nullToAbsent || visitorsCount != null) {
      map['visitors_count'] = Variable<int>(visitorsCount);
    }
    if (!nullToAbsent || missionOffering != null) {
      map['mission_offering'] = Variable<double>(missionOffering);
    }
    if (!nullToAbsent || localChurchBudget != null) {
      map['local_church_budget'] = Variable<double>(localChurchBudget);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeeklyRecordsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyRecordsCompanion(
      id: Value(id),
      churchId: Value(churchId),
      createdByAdminId: createdByAdminId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByAdminId),
      weekStartDate: Value(weekStartDate),
      men: Value(men),
      women: Value(women),
      youth: Value(youth),
      children: Value(children),
      sundayHomeChurch: Value(sundayHomeChurch),
      baptisms: baptisms == null && nullToAbsent
          ? const Value.absent()
          : Value(baptisms),
      holyCommunion: holyCommunion == null && nullToAbsent
          ? const Value.absent()
          : Value(holyCommunion),
      tithe: Value(tithe),
      offerings: Value(offerings),
      emergencyCollection: Value(emergencyCollection),
      plannedCollection: Value(plannedCollection),
      sabbathSchoolAttendance: sabbathSchoolAttendance == null && nullToAbsent
          ? const Value.absent()
          : Value(sabbathSchoolAttendance),
      visitorsCount: visitorsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(visitorsCount),
      missionOffering: missionOffering == null && nullToAbsent
          ? const Value.absent()
          : Value(missionOffering),
      localChurchBudget: localChurchBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(localChurchBudget),
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
      createdByAdminId: serializer.fromJson<int?>(json['createdByAdminId']),
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      men: serializer.fromJson<int>(json['men']),
      women: serializer.fromJson<int>(json['women']),
      youth: serializer.fromJson<int>(json['youth']),
      children: serializer.fromJson<int>(json['children']),
      sundayHomeChurch: serializer.fromJson<int>(json['sundayHomeChurch']),
      baptisms: serializer.fromJson<int?>(json['baptisms']),
      holyCommunion: serializer.fromJson<int?>(json['holyCommunion']),
      tithe: serializer.fromJson<double>(json['tithe']),
      offerings: serializer.fromJson<double>(json['offerings']),
      emergencyCollection: serializer.fromJson<double>(
        json['emergencyCollection'],
      ),
      plannedCollection: serializer.fromJson<double>(json['plannedCollection']),
      sabbathSchoolAttendance: serializer.fromJson<int?>(
        json['sabbathSchoolAttendance'],
      ),
      visitorsCount: serializer.fromJson<int?>(json['visitorsCount']),
      missionOffering: serializer.fromJson<double?>(json['missionOffering']),
      localChurchBudget: serializer.fromJson<double?>(
        json['localChurchBudget'],
      ),
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
      'createdByAdminId': serializer.toJson<int?>(createdByAdminId),
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'men': serializer.toJson<int>(men),
      'women': serializer.toJson<int>(women),
      'youth': serializer.toJson<int>(youth),
      'children': serializer.toJson<int>(children),
      'sundayHomeChurch': serializer.toJson<int>(sundayHomeChurch),
      'baptisms': serializer.toJson<int?>(baptisms),
      'holyCommunion': serializer.toJson<int?>(holyCommunion),
      'tithe': serializer.toJson<double>(tithe),
      'offerings': serializer.toJson<double>(offerings),
      'emergencyCollection': serializer.toJson<double>(emergencyCollection),
      'plannedCollection': serializer.toJson<double>(plannedCollection),
      'sabbathSchoolAttendance': serializer.toJson<int?>(
        sabbathSchoolAttendance,
      ),
      'visitorsCount': serializer.toJson<int?>(visitorsCount),
      'missionOffering': serializer.toJson<double?>(missionOffering),
      'localChurchBudget': serializer.toJson<double?>(localChurchBudget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklyRecord copyWith({
    int? id,
    int? churchId,
    Value<int?> createdByAdminId = const Value.absent(),
    DateTime? weekStartDate,
    int? men,
    int? women,
    int? youth,
    int? children,
    int? sundayHomeChurch,
    Value<int?> baptisms = const Value.absent(),
    Value<int?> holyCommunion = const Value.absent(),
    double? tithe,
    double? offerings,
    double? emergencyCollection,
    double? plannedCollection,
    Value<int?> sabbathSchoolAttendance = const Value.absent(),
    Value<int?> visitorsCount = const Value.absent(),
    Value<double?> missionOffering = const Value.absent(),
    Value<double?> localChurchBudget = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WeeklyRecord(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId.present
        ? createdByAdminId.value
        : this.createdByAdminId,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    men: men ?? this.men,
    women: women ?? this.women,
    youth: youth ?? this.youth,
    children: children ?? this.children,
    sundayHomeChurch: sundayHomeChurch ?? this.sundayHomeChurch,
    baptisms: baptisms.present ? baptisms.value : this.baptisms,
    holyCommunion: holyCommunion.present
        ? holyCommunion.value
        : this.holyCommunion,
    tithe: tithe ?? this.tithe,
    offerings: offerings ?? this.offerings,
    emergencyCollection: emergencyCollection ?? this.emergencyCollection,
    plannedCollection: plannedCollection ?? this.plannedCollection,
    sabbathSchoolAttendance: sabbathSchoolAttendance.present
        ? sabbathSchoolAttendance.value
        : this.sabbathSchoolAttendance,
    visitorsCount: visitorsCount.present
        ? visitorsCount.value
        : this.visitorsCount,
    missionOffering: missionOffering.present
        ? missionOffering.value
        : this.missionOffering,
    localChurchBudget: localChurchBudget.present
        ? localChurchBudget.value
        : this.localChurchBudget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklyRecord copyWithCompanion(WeeklyRecordsCompanion data) {
    return WeeklyRecord(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      createdByAdminId: data.createdByAdminId.present
          ? data.createdByAdminId.value
          : this.createdByAdminId,
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
      baptisms: data.baptisms.present ? data.baptisms.value : this.baptisms,
      holyCommunion: data.holyCommunion.present
          ? data.holyCommunion.value
          : this.holyCommunion,
      tithe: data.tithe.present ? data.tithe.value : this.tithe,
      offerings: data.offerings.present ? data.offerings.value : this.offerings,
      emergencyCollection: data.emergencyCollection.present
          ? data.emergencyCollection.value
          : this.emergencyCollection,
      plannedCollection: data.plannedCollection.present
          ? data.plannedCollection.value
          : this.plannedCollection,
      sabbathSchoolAttendance: data.sabbathSchoolAttendance.present
          ? data.sabbathSchoolAttendance.value
          : this.sabbathSchoolAttendance,
      visitorsCount: data.visitorsCount.present
          ? data.visitorsCount.value
          : this.visitorsCount,
      missionOffering: data.missionOffering.present
          ? data.missionOffering.value
          : this.missionOffering,
      localChurchBudget: data.localChurchBudget.present
          ? data.localChurchBudget.value
          : this.localChurchBudget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyRecord(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('men: $men, ')
          ..write('women: $women, ')
          ..write('youth: $youth, ')
          ..write('children: $children, ')
          ..write('sundayHomeChurch: $sundayHomeChurch, ')
          ..write('baptisms: $baptisms, ')
          ..write('holyCommunion: $holyCommunion, ')
          ..write('tithe: $tithe, ')
          ..write('offerings: $offerings, ')
          ..write('emergencyCollection: $emergencyCollection, ')
          ..write('plannedCollection: $plannedCollection, ')
          ..write('sabbathSchoolAttendance: $sabbathSchoolAttendance, ')
          ..write('visitorsCount: $visitorsCount, ')
          ..write('missionOffering: $missionOffering, ')
          ..write('localChurchBudget: $localChurchBudget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    churchId,
    createdByAdminId,
    weekStartDate,
    men,
    women,
    youth,
    children,
    sundayHomeChurch,
    baptisms,
    holyCommunion,
    tithe,
    offerings,
    emergencyCollection,
    plannedCollection,
    sabbathSchoolAttendance,
    visitorsCount,
    missionOffering,
    localChurchBudget,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyRecord &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.createdByAdminId == this.createdByAdminId &&
          other.weekStartDate == this.weekStartDate &&
          other.men == this.men &&
          other.women == this.women &&
          other.youth == this.youth &&
          other.children == this.children &&
          other.sundayHomeChurch == this.sundayHomeChurch &&
          other.baptisms == this.baptisms &&
          other.holyCommunion == this.holyCommunion &&
          other.tithe == this.tithe &&
          other.offerings == this.offerings &&
          other.emergencyCollection == this.emergencyCollection &&
          other.plannedCollection == this.plannedCollection &&
          other.sabbathSchoolAttendance == this.sabbathSchoolAttendance &&
          other.visitorsCount == this.visitorsCount &&
          other.missionOffering == this.missionOffering &&
          other.localChurchBudget == this.localChurchBudget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeeklyRecordsCompanion extends UpdateCompanion<WeeklyRecord> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<int?> createdByAdminId;
  final Value<DateTime> weekStartDate;
  final Value<int> men;
  final Value<int> women;
  final Value<int> youth;
  final Value<int> children;
  final Value<int> sundayHomeChurch;
  final Value<int?> baptisms;
  final Value<int?> holyCommunion;
  final Value<double> tithe;
  final Value<double> offerings;
  final Value<double> emergencyCollection;
  final Value<double> plannedCollection;
  final Value<int?> sabbathSchoolAttendance;
  final Value<int?> visitorsCount;
  final Value<double?> missionOffering;
  final Value<double?> localChurchBudget;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeeklyRecordsCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.createdByAdminId = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.men = const Value.absent(),
    this.women = const Value.absent(),
    this.youth = const Value.absent(),
    this.children = const Value.absent(),
    this.sundayHomeChurch = const Value.absent(),
    this.baptisms = const Value.absent(),
    this.holyCommunion = const Value.absent(),
    this.tithe = const Value.absent(),
    this.offerings = const Value.absent(),
    this.emergencyCollection = const Value.absent(),
    this.plannedCollection = const Value.absent(),
    this.sabbathSchoolAttendance = const Value.absent(),
    this.visitorsCount = const Value.absent(),
    this.missionOffering = const Value.absent(),
    this.localChurchBudget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeeklyRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    this.createdByAdminId = const Value.absent(),
    required DateTime weekStartDate,
    this.men = const Value.absent(),
    this.women = const Value.absent(),
    this.youth = const Value.absent(),
    this.children = const Value.absent(),
    this.sundayHomeChurch = const Value.absent(),
    this.baptisms = const Value.absent(),
    this.holyCommunion = const Value.absent(),
    this.tithe = const Value.absent(),
    this.offerings = const Value.absent(),
    this.emergencyCollection = const Value.absent(),
    this.plannedCollection = const Value.absent(),
    this.sabbathSchoolAttendance = const Value.absent(),
    this.visitorsCount = const Value.absent(),
    this.missionOffering = const Value.absent(),
    this.localChurchBudget = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : churchId = Value(churchId),
       weekStartDate = Value(weekStartDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeeklyRecord> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<int>? createdByAdminId,
    Expression<DateTime>? weekStartDate,
    Expression<int>? men,
    Expression<int>? women,
    Expression<int>? youth,
    Expression<int>? children,
    Expression<int>? sundayHomeChurch,
    Expression<int>? baptisms,
    Expression<int>? holyCommunion,
    Expression<double>? tithe,
    Expression<double>? offerings,
    Expression<double>? emergencyCollection,
    Expression<double>? plannedCollection,
    Expression<int>? sabbathSchoolAttendance,
    Expression<int>? visitorsCount,
    Expression<double>? missionOffering,
    Expression<double>? localChurchBudget,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (createdByAdminId != null) 'created_by_admin_id': createdByAdminId,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (men != null) 'men': men,
      if (women != null) 'women': women,
      if (youth != null) 'youth': youth,
      if (children != null) 'children': children,
      if (sundayHomeChurch != null) 'sunday_home_church': sundayHomeChurch,
      if (baptisms != null) 'baptisms': baptisms,
      if (holyCommunion != null) 'holy_communion': holyCommunion,
      if (tithe != null) 'tithe': tithe,
      if (offerings != null) 'offerings': offerings,
      if (emergencyCollection != null)
        'emergency_collection': emergencyCollection,
      if (plannedCollection != null) 'planned_collection': plannedCollection,
      if (sabbathSchoolAttendance != null)
        'sabbath_school_attendance': sabbathSchoolAttendance,
      if (visitorsCount != null) 'visitors_count': visitorsCount,
      if (missionOffering != null) 'mission_offering': missionOffering,
      if (localChurchBudget != null) 'local_church_budget': localChurchBudget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeeklyRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<int?>? createdByAdminId,
    Value<DateTime>? weekStartDate,
    Value<int>? men,
    Value<int>? women,
    Value<int>? youth,
    Value<int>? children,
    Value<int>? sundayHomeChurch,
    Value<int?>? baptisms,
    Value<int?>? holyCommunion,
    Value<double>? tithe,
    Value<double>? offerings,
    Value<double>? emergencyCollection,
    Value<double>? plannedCollection,
    Value<int?>? sabbathSchoolAttendance,
    Value<int?>? visitorsCount,
    Value<double?>? missionOffering,
    Value<double?>? localChurchBudget,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeeklyRecordsCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      createdByAdminId: createdByAdminId ?? this.createdByAdminId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      men: men ?? this.men,
      women: women ?? this.women,
      youth: youth ?? this.youth,
      children: children ?? this.children,
      sundayHomeChurch: sundayHomeChurch ?? this.sundayHomeChurch,
      baptisms: baptisms ?? this.baptisms,
      holyCommunion: holyCommunion ?? this.holyCommunion,
      tithe: tithe ?? this.tithe,
      offerings: offerings ?? this.offerings,
      emergencyCollection: emergencyCollection ?? this.emergencyCollection,
      plannedCollection: plannedCollection ?? this.plannedCollection,
      sabbathSchoolAttendance:
          sabbathSchoolAttendance ?? this.sabbathSchoolAttendance,
      visitorsCount: visitorsCount ?? this.visitorsCount,
      missionOffering: missionOffering ?? this.missionOffering,
      localChurchBudget: localChurchBudget ?? this.localChurchBudget,
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
    if (createdByAdminId.present) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId.value);
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
    if (baptisms.present) {
      map['baptisms'] = Variable<int>(baptisms.value);
    }
    if (holyCommunion.present) {
      map['holy_communion'] = Variable<int>(holyCommunion.value);
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
    if (sabbathSchoolAttendance.present) {
      map['sabbath_school_attendance'] = Variable<int>(
        sabbathSchoolAttendance.value,
      );
    }
    if (visitorsCount.present) {
      map['visitors_count'] = Variable<int>(visitorsCount.value);
    }
    if (missionOffering.present) {
      map['mission_offering'] = Variable<double>(missionOffering.value);
    }
    if (localChurchBudget.present) {
      map['local_church_budget'] = Variable<double>(localChurchBudget.value);
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
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('men: $men, ')
          ..write('women: $women, ')
          ..write('youth: $youth, ')
          ..write('children: $children, ')
          ..write('sundayHomeChurch: $sundayHomeChurch, ')
          ..write('baptisms: $baptisms, ')
          ..write('holyCommunion: $holyCommunion, ')
          ..write('tithe: $tithe, ')
          ..write('offerings: $offerings, ')
          ..write('emergencyCollection: $emergencyCollection, ')
          ..write('plannedCollection: $plannedCollection, ')
          ..write('sabbathSchoolAttendance: $sabbathSchoolAttendance, ')
          ..write('visitorsCount: $visitorsCount, ')
          ..write('missionOffering: $missionOffering, ')
          ..write('localChurchBudget: $localChurchBudget, ')
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

class $HomeChurchesTable extends HomeChurches
    with TableInfo<$HomeChurchesTable, HomeChurche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomeChurchesTable(this.attachedDatabase, [this._alias]);
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
    defaultValue: const Constant('geographical'),
  );
  static const VerificationMeta _expectedMembershipMeta =
      const VerificationMeta('expectedMembership');
  @override
  late final GeneratedColumn<int> expectedMembership = GeneratedColumn<int>(
    'expected_membership',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedAtKccMeta = const VerificationMeta(
    'expectedAtKcc',
  );
  @override
  late final GeneratedColumn<int> expectedAtKcc = GeneratedColumn<int>(
    'expected_at_kcc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    name,
    category,
    expectedMembership,
    expectedAtKcc,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'home_churches';
  @override
  VerificationContext validateIntegrity(
    Insertable<HomeChurche> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('expected_membership')) {
      context.handle(
        _expectedMembershipMeta,
        expectedMembership.isAcceptableOrUnknown(
          data['expected_membership']!,
          _expectedMembershipMeta,
        ),
      );
    }
    if (data.containsKey('expected_at_kcc')) {
      context.handle(
        _expectedAtKccMeta,
        expectedAtKcc.isAcceptableOrUnknown(
          data['expected_at_kcc']!,
          _expectedAtKccMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  HomeChurche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HomeChurche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      expectedMembership: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_membership'],
      )!,
      expectedAtKcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_at_kcc'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
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
  $HomeChurchesTable createAlias(String alias) {
    return $HomeChurchesTable(attachedDatabase, alias);
  }
}

class HomeChurche extends DataClass implements Insertable<HomeChurche> {
  final int id;
  final int churchId;
  final String name;

  /// geographical | ministry | special
  final String category;

  /// Expected membership registered at this home church
  final int expectedMembership;

  /// Expected count to appear at KCC (main church) events
  final int expectedAtKcc;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const HomeChurche({
    required this.id,
    required this.churchId,
    required this.name,
    required this.category,
    required this.expectedMembership,
    required this.expectedAtKcc,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['expected_membership'] = Variable<int>(expectedMembership);
    map['expected_at_kcc'] = Variable<int>(expectedAtKcc);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HomeChurchesCompanion toCompanion(bool nullToAbsent) {
    return HomeChurchesCompanion(
      id: Value(id),
      churchId: Value(churchId),
      name: Value(name),
      category: Value(category),
      expectedMembership: Value(expectedMembership),
      expectedAtKcc: Value(expectedAtKcc),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HomeChurche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomeChurche(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      expectedMembership: serializer.fromJson<int>(json['expectedMembership']),
      expectedAtKcc: serializer.fromJson<int>(json['expectedAtKcc']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
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
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'expectedMembership': serializer.toJson<int>(expectedMembership),
      'expectedAtKcc': serializer.toJson<int>(expectedAtKcc),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HomeChurche copyWith({
    int? id,
    int? churchId,
    String? name,
    String? category,
    int? expectedMembership,
    int? expectedAtKcc,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HomeChurche(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    name: name ?? this.name,
    category: category ?? this.category,
    expectedMembership: expectedMembership ?? this.expectedMembership,
    expectedAtKcc: expectedAtKcc ?? this.expectedAtKcc,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HomeChurche copyWithCompanion(HomeChurchesCompanion data) {
    return HomeChurche(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      expectedMembership: data.expectedMembership.present
          ? data.expectedMembership.value
          : this.expectedMembership,
      expectedAtKcc: data.expectedAtKcc.present
          ? data.expectedAtKcc.value
          : this.expectedAtKcc,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HomeChurche(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('expectedMembership: $expectedMembership, ')
          ..write('expectedAtKcc: $expectedAtKcc, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    name,
    category,
    expectedMembership,
    expectedAtKcc,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeChurche &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.name == this.name &&
          other.category == this.category &&
          other.expectedMembership == this.expectedMembership &&
          other.expectedAtKcc == this.expectedAtKcc &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HomeChurchesCompanion extends UpdateCompanion<HomeChurche> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<String> name;
  final Value<String> category;
  final Value<int> expectedMembership;
  final Value<int> expectedAtKcc;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const HomeChurchesCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.expectedMembership = const Value.absent(),
    this.expectedAtKcc = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HomeChurchesCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    required String name,
    this.category = const Value.absent(),
    this.expectedMembership = const Value.absent(),
    this.expectedAtKcc = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : churchId = Value(churchId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HomeChurche> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? expectedMembership,
    Expression<int>? expectedAtKcc,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (expectedMembership != null) 'expected_membership': expectedMembership,
      if (expectedAtKcc != null) 'expected_at_kcc': expectedAtKcc,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HomeChurchesCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<String>? name,
    Value<String>? category,
    Value<int>? expectedMembership,
    Value<int>? expectedAtKcc,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return HomeChurchesCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      name: name ?? this.name,
      category: category ?? this.category,
      expectedMembership: expectedMembership ?? this.expectedMembership,
      expectedAtKcc: expectedAtKcc ?? this.expectedAtKcc,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (expectedMembership.present) {
      map['expected_membership'] = Variable<int>(expectedMembership.value);
    }
    if (expectedAtKcc.present) {
      map['expected_at_kcc'] = Variable<int>(expectedAtKcc.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('HomeChurchesCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('expectedMembership: $expectedMembership, ')
          ..write('expectedAtKcc: $expectedAtKcc, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BoardMeetingRecordsTable extends BoardMeetingRecords
    with TableInfo<$BoardMeetingRecordsTable, BoardMeetingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardMeetingRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdByAdminIdMeta = const VerificationMeta(
    'createdByAdminId',
  );
  @override
  late final GeneratedColumn<int> createdByAdminId = GeneratedColumn<int>(
    'created_by_admin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES admin_users (id)',
    ),
  );
  static const VerificationMeta _meetingDateMeta = const VerificationMeta(
    'meetingDate',
  );
  @override
  late final GeneratedColumn<DateTime> meetingDate = GeneratedColumn<DateTime>(
    'meeting_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualAttendanceMeta = const VerificationMeta(
    'actualAttendance',
  );
  @override
  late final GeneratedColumn<int> actualAttendance = GeneratedColumn<int>(
    'actual_attendance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedAttendanceMeta =
      const VerificationMeta('expectedAttendance');
  @override
  late final GeneratedColumn<int> expectedAttendance = GeneratedColumn<int>(
    'expected_attendance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    createdByAdminId,
    meetingDate,
    year,
    month,
    actualAttendance,
    expectedAttendance,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_meeting_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardMeetingRecord> instance, {
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
    if (data.containsKey('created_by_admin_id')) {
      context.handle(
        _createdByAdminIdMeta,
        createdByAdminId.isAcceptableOrUnknown(
          data['created_by_admin_id']!,
          _createdByAdminIdMeta,
        ),
      );
    }
    if (data.containsKey('meeting_date')) {
      context.handle(
        _meetingDateMeta,
        meetingDate.isAcceptableOrUnknown(
          data['meeting_date']!,
          _meetingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meetingDateMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('actual_attendance')) {
      context.handle(
        _actualAttendanceMeta,
        actualAttendance.isAcceptableOrUnknown(
          data['actual_attendance']!,
          _actualAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('expected_attendance')) {
      context.handle(
        _expectedAttendanceMeta,
        expectedAttendance.isAcceptableOrUnknown(
          data['expected_attendance']!,
          _expectedAttendanceMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {churchId, year, month},
  ];
  @override
  BoardMeetingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardMeetingRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      createdByAdminId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_admin_id'],
      ),
      meetingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}meeting_date'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      actualAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_attendance'],
      )!,
      expectedAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_attendance'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
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
  $BoardMeetingRecordsTable createAlias(String alias) {
    return $BoardMeetingRecordsTable(attachedDatabase, alias);
  }
}

class BoardMeetingRecord extends DataClass
    implements Insertable<BoardMeetingRecord> {
  final int id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime meetingDate;
  final int year;
  final int month;
  final int actualAttendance;

  /// Snapshot of Churches.boardMemberCount at time of recording
  final int expectedAttendance;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BoardMeetingRecord({
    required this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.meetingDate,
    required this.year,
    required this.month,
    required this.actualAttendance,
    required this.expectedAttendance,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    if (!nullToAbsent || createdByAdminId != null) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId);
    }
    map['meeting_date'] = Variable<DateTime>(meetingDate);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['actual_attendance'] = Variable<int>(actualAttendance);
    map['expected_attendance'] = Variable<int>(expectedAttendance);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BoardMeetingRecordsCompanion toCompanion(bool nullToAbsent) {
    return BoardMeetingRecordsCompanion(
      id: Value(id),
      churchId: Value(churchId),
      createdByAdminId: createdByAdminId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByAdminId),
      meetingDate: Value(meetingDate),
      year: Value(year),
      month: Value(month),
      actualAttendance: Value(actualAttendance),
      expectedAttendance: Value(expectedAttendance),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BoardMeetingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardMeetingRecord(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      createdByAdminId: serializer.fromJson<int?>(json['createdByAdminId']),
      meetingDate: serializer.fromJson<DateTime>(json['meetingDate']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      actualAttendance: serializer.fromJson<int>(json['actualAttendance']),
      expectedAttendance: serializer.fromJson<int>(json['expectedAttendance']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'createdByAdminId': serializer.toJson<int?>(createdByAdminId),
      'meetingDate': serializer.toJson<DateTime>(meetingDate),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'actualAttendance': serializer.toJson<int>(actualAttendance),
      'expectedAttendance': serializer.toJson<int>(expectedAttendance),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BoardMeetingRecord copyWith({
    int? id,
    int? churchId,
    Value<int?> createdByAdminId = const Value.absent(),
    DateTime? meetingDate,
    int? year,
    int? month,
    int? actualAttendance,
    int? expectedAttendance,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BoardMeetingRecord(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId.present
        ? createdByAdminId.value
        : this.createdByAdminId,
    meetingDate: meetingDate ?? this.meetingDate,
    year: year ?? this.year,
    month: month ?? this.month,
    actualAttendance: actualAttendance ?? this.actualAttendance,
    expectedAttendance: expectedAttendance ?? this.expectedAttendance,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BoardMeetingRecord copyWithCompanion(BoardMeetingRecordsCompanion data) {
    return BoardMeetingRecord(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      createdByAdminId: data.createdByAdminId.present
          ? data.createdByAdminId.value
          : this.createdByAdminId,
      meetingDate: data.meetingDate.present
          ? data.meetingDate.value
          : this.meetingDate,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      actualAttendance: data.actualAttendance.present
          ? data.actualAttendance.value
          : this.actualAttendance,
      expectedAttendance: data.expectedAttendance.present
          ? data.expectedAttendance.value
          : this.expectedAttendance,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardMeetingRecord(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('meetingDate: $meetingDate, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('actualAttendance: $actualAttendance, ')
          ..write('expectedAttendance: $expectedAttendance, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    createdByAdminId,
    meetingDate,
    year,
    month,
    actualAttendance,
    expectedAttendance,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardMeetingRecord &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.createdByAdminId == this.createdByAdminId &&
          other.meetingDate == this.meetingDate &&
          other.year == this.year &&
          other.month == this.month &&
          other.actualAttendance == this.actualAttendance &&
          other.expectedAttendance == this.expectedAttendance &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BoardMeetingRecordsCompanion extends UpdateCompanion<BoardMeetingRecord> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<int?> createdByAdminId;
  final Value<DateTime> meetingDate;
  final Value<int> year;
  final Value<int> month;
  final Value<int> actualAttendance;
  final Value<int> expectedAttendance;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BoardMeetingRecordsCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.createdByAdminId = const Value.absent(),
    this.meetingDate = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.actualAttendance = const Value.absent(),
    this.expectedAttendance = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BoardMeetingRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    this.createdByAdminId = const Value.absent(),
    required DateTime meetingDate,
    required int year,
    required int month,
    this.actualAttendance = const Value.absent(),
    this.expectedAttendance = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : churchId = Value(churchId),
       meetingDate = Value(meetingDate),
       year = Value(year),
       month = Value(month),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BoardMeetingRecord> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<int>? createdByAdminId,
    Expression<DateTime>? meetingDate,
    Expression<int>? year,
    Expression<int>? month,
    Expression<int>? actualAttendance,
    Expression<int>? expectedAttendance,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (createdByAdminId != null) 'created_by_admin_id': createdByAdminId,
      if (meetingDate != null) 'meeting_date': meetingDate,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (actualAttendance != null) 'actual_attendance': actualAttendance,
      if (expectedAttendance != null) 'expected_attendance': expectedAttendance,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BoardMeetingRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<int?>? createdByAdminId,
    Value<DateTime>? meetingDate,
    Value<int>? year,
    Value<int>? month,
    Value<int>? actualAttendance,
    Value<int>? expectedAttendance,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BoardMeetingRecordsCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      createdByAdminId: createdByAdminId ?? this.createdByAdminId,
      meetingDate: meetingDate ?? this.meetingDate,
      year: year ?? this.year,
      month: month ?? this.month,
      actualAttendance: actualAttendance ?? this.actualAttendance,
      expectedAttendance: expectedAttendance ?? this.expectedAttendance,
      notes: notes ?? this.notes,
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
    if (createdByAdminId.present) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId.value);
    }
    if (meetingDate.present) {
      map['meeting_date'] = Variable<DateTime>(meetingDate.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (actualAttendance.present) {
      map['actual_attendance'] = Variable<int>(actualAttendance.value);
    }
    if (expectedAttendance.present) {
      map['expected_attendance'] = Variable<int>(expectedAttendance.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardMeetingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('meetingDate: $meetingDate, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('actualAttendance: $actualAttendance, ')
          ..write('expectedAttendance: $expectedAttendance, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HolyCommunionEventsTable extends HolyCommunionEvents
    with TableInfo<$HolyCommunionEventsTable, HolyCommunionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolyCommunionEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdByAdminIdMeta = const VerificationMeta(
    'createdByAdminId',
  );
  @override
  late final GeneratedColumn<int> createdByAdminId = GeneratedColumn<int>(
    'created_by_admin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES admin_users (id)',
    ),
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quarterMeta = const VerificationMeta(
    'quarter',
  );
  @override
  late final GeneratedColumn<int> quarter = GeneratedColumn<int>(
    'quarter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpectedAtKccMeta =
      const VerificationMeta('totalExpectedAtKcc');
  @override
  late final GeneratedColumn<int> totalExpectedAtKcc = GeneratedColumn<int>(
    'total_expected_at_kcc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    createdByAdminId,
    eventDate,
    year,
    quarter,
    totalExpectedAtKcc,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holy_communion_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolyCommunionEvent> instance, {
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
    if (data.containsKey('created_by_admin_id')) {
      context.handle(
        _createdByAdminIdMeta,
        createdByAdminId.isAcceptableOrUnknown(
          data['created_by_admin_id']!,
          _createdByAdminIdMeta,
        ),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('quarter')) {
      context.handle(
        _quarterMeta,
        quarter.isAcceptableOrUnknown(data['quarter']!, _quarterMeta),
      );
    } else if (isInserting) {
      context.missing(_quarterMeta);
    }
    if (data.containsKey('total_expected_at_kcc')) {
      context.handle(
        _totalExpectedAtKccMeta,
        totalExpectedAtKcc.isAcceptableOrUnknown(
          data['total_expected_at_kcc']!,
          _totalExpectedAtKccMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {churchId, year, quarter},
  ];
  @override
  HolyCommunionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolyCommunionEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      createdByAdminId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_admin_id'],
      ),
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      quarter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quarter'],
      )!,
      totalExpectedAtKcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_expected_at_kcc'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
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
  $HolyCommunionEventsTable createAlias(String alias) {
    return $HolyCommunionEventsTable(attachedDatabase, alias);
  }
}

class HolyCommunionEvent extends DataClass
    implements Insertable<HolyCommunionEvent> {
  final int id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime eventDate;
  final int year;
  final int quarter;

  /// Snapshot of the KCC-wide expected total at time of recording
  final int totalExpectedAtKcc;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const HolyCommunionEvent({
    required this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.eventDate,
    required this.year,
    required this.quarter,
    required this.totalExpectedAtKcc,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    if (!nullToAbsent || createdByAdminId != null) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId);
    }
    map['event_date'] = Variable<DateTime>(eventDate);
    map['year'] = Variable<int>(year);
    map['quarter'] = Variable<int>(quarter);
    map['total_expected_at_kcc'] = Variable<int>(totalExpectedAtKcc);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HolyCommunionEventsCompanion toCompanion(bool nullToAbsent) {
    return HolyCommunionEventsCompanion(
      id: Value(id),
      churchId: Value(churchId),
      createdByAdminId: createdByAdminId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByAdminId),
      eventDate: Value(eventDate),
      year: Value(year),
      quarter: Value(quarter),
      totalExpectedAtKcc: Value(totalExpectedAtKcc),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HolyCommunionEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolyCommunionEvent(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      createdByAdminId: serializer.fromJson<int?>(json['createdByAdminId']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      year: serializer.fromJson<int>(json['year']),
      quarter: serializer.fromJson<int>(json['quarter']),
      totalExpectedAtKcc: serializer.fromJson<int>(json['totalExpectedAtKcc']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'createdByAdminId': serializer.toJson<int?>(createdByAdminId),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'year': serializer.toJson<int>(year),
      'quarter': serializer.toJson<int>(quarter),
      'totalExpectedAtKcc': serializer.toJson<int>(totalExpectedAtKcc),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HolyCommunionEvent copyWith({
    int? id,
    int? churchId,
    Value<int?> createdByAdminId = const Value.absent(),
    DateTime? eventDate,
    int? year,
    int? quarter,
    int? totalExpectedAtKcc,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HolyCommunionEvent(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId.present
        ? createdByAdminId.value
        : this.createdByAdminId,
    eventDate: eventDate ?? this.eventDate,
    year: year ?? this.year,
    quarter: quarter ?? this.quarter,
    totalExpectedAtKcc: totalExpectedAtKcc ?? this.totalExpectedAtKcc,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HolyCommunionEvent copyWithCompanion(HolyCommunionEventsCompanion data) {
    return HolyCommunionEvent(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      createdByAdminId: data.createdByAdminId.present
          ? data.createdByAdminId.value
          : this.createdByAdminId,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      year: data.year.present ? data.year.value : this.year,
      quarter: data.quarter.present ? data.quarter.value : this.quarter,
      totalExpectedAtKcc: data.totalExpectedAtKcc.present
          ? data.totalExpectedAtKcc.value
          : this.totalExpectedAtKcc,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolyCommunionEvent(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('eventDate: $eventDate, ')
          ..write('year: $year, ')
          ..write('quarter: $quarter, ')
          ..write('totalExpectedAtKcc: $totalExpectedAtKcc, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    createdByAdminId,
    eventDate,
    year,
    quarter,
    totalExpectedAtKcc,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolyCommunionEvent &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.createdByAdminId == this.createdByAdminId &&
          other.eventDate == this.eventDate &&
          other.year == this.year &&
          other.quarter == this.quarter &&
          other.totalExpectedAtKcc == this.totalExpectedAtKcc &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HolyCommunionEventsCompanion extends UpdateCompanion<HolyCommunionEvent> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<int?> createdByAdminId;
  final Value<DateTime> eventDate;
  final Value<int> year;
  final Value<int> quarter;
  final Value<int> totalExpectedAtKcc;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const HolyCommunionEventsCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.createdByAdminId = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.year = const Value.absent(),
    this.quarter = const Value.absent(),
    this.totalExpectedAtKcc = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HolyCommunionEventsCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    this.createdByAdminId = const Value.absent(),
    required DateTime eventDate,
    required int year,
    required int quarter,
    this.totalExpectedAtKcc = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : churchId = Value(churchId),
       eventDate = Value(eventDate),
       year = Value(year),
       quarter = Value(quarter),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HolyCommunionEvent> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<int>? createdByAdminId,
    Expression<DateTime>? eventDate,
    Expression<int>? year,
    Expression<int>? quarter,
    Expression<int>? totalExpectedAtKcc,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (createdByAdminId != null) 'created_by_admin_id': createdByAdminId,
      if (eventDate != null) 'event_date': eventDate,
      if (year != null) 'year': year,
      if (quarter != null) 'quarter': quarter,
      if (totalExpectedAtKcc != null)
        'total_expected_at_kcc': totalExpectedAtKcc,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HolyCommunionEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<int?>? createdByAdminId,
    Value<DateTime>? eventDate,
    Value<int>? year,
    Value<int>? quarter,
    Value<int>? totalExpectedAtKcc,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return HolyCommunionEventsCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      createdByAdminId: createdByAdminId ?? this.createdByAdminId,
      eventDate: eventDate ?? this.eventDate,
      year: year ?? this.year,
      quarter: quarter ?? this.quarter,
      totalExpectedAtKcc: totalExpectedAtKcc ?? this.totalExpectedAtKcc,
      notes: notes ?? this.notes,
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
    if (createdByAdminId.present) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (quarter.present) {
      map['quarter'] = Variable<int>(quarter.value);
    }
    if (totalExpectedAtKcc.present) {
      map['total_expected_at_kcc'] = Variable<int>(totalExpectedAtKcc.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolyCommunionEventsCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('eventDate: $eventDate, ')
          ..write('year: $year, ')
          ..write('quarter: $quarter, ')
          ..write('totalExpectedAtKcc: $totalExpectedAtKcc, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HolyCommunionAttendanceTable extends HolyCommunionAttendance
    with TableInfo<$HolyCommunionAttendanceTable, HolyCommunionAttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolyCommunionAttendanceTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES holy_communion_events (id)',
    ),
  );
  static const VerificationMeta _homeChurchIdMeta = const VerificationMeta(
    'homeChurchId',
  );
  @override
  late final GeneratedColumn<int> homeChurchId = GeneratedColumn<int>(
    'home_church_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES home_churches (id)',
    ),
  );
  static const VerificationMeta _actualAttendanceMeta = const VerificationMeta(
    'actualAttendance',
  );
  @override
  late final GeneratedColumn<int> actualAttendance = GeneratedColumn<int>(
    'actual_attendance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedAtHcMeta = const VerificationMeta(
    'expectedAtHc',
  );
  @override
  late final GeneratedColumn<int> expectedAtHc = GeneratedColumn<int>(
    'expected_at_hc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    homeChurchId,
    actualAttendance,
    expectedAtHc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holy_communion_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolyCommunionAttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('home_church_id')) {
      context.handle(
        _homeChurchIdMeta,
        homeChurchId.isAcceptableOrUnknown(
          data['home_church_id']!,
          _homeChurchIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_homeChurchIdMeta);
    }
    if (data.containsKey('actual_attendance')) {
      context.handle(
        _actualAttendanceMeta,
        actualAttendance.isAcceptableOrUnknown(
          data['actual_attendance']!,
          _actualAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('expected_at_hc')) {
      context.handle(
        _expectedAtHcMeta,
        expectedAtHc.isAcceptableOrUnknown(
          data['expected_at_hc']!,
          _expectedAtHcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventId, homeChurchId},
  ];
  @override
  HolyCommunionAttendanceData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolyCommunionAttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      homeChurchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_church_id'],
      )!,
      actualAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_attendance'],
      )!,
      expectedAtHc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_at_hc'],
      )!,
    );
  }

  @override
  $HolyCommunionAttendanceTable createAlias(String alias) {
    return $HolyCommunionAttendanceTable(attachedDatabase, alias);
  }
}

class HolyCommunionAttendanceData extends DataClass
    implements Insertable<HolyCommunionAttendanceData> {
  final int id;
  final int eventId;
  final int homeChurchId;
  final int actualAttendance;

  /// Snapshot of HomeChurch.expectedMembership at recording time
  final int expectedAtHc;
  const HolyCommunionAttendanceData({
    required this.id,
    required this.eventId,
    required this.homeChurchId,
    required this.actualAttendance,
    required this.expectedAtHc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['home_church_id'] = Variable<int>(homeChurchId);
    map['actual_attendance'] = Variable<int>(actualAttendance);
    map['expected_at_hc'] = Variable<int>(expectedAtHc);
    return map;
  }

  HolyCommunionAttendanceCompanion toCompanion(bool nullToAbsent) {
    return HolyCommunionAttendanceCompanion(
      id: Value(id),
      eventId: Value(eventId),
      homeChurchId: Value(homeChurchId),
      actualAttendance: Value(actualAttendance),
      expectedAtHc: Value(expectedAtHc),
    );
  }

  factory HolyCommunionAttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolyCommunionAttendanceData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      homeChurchId: serializer.fromJson<int>(json['homeChurchId']),
      actualAttendance: serializer.fromJson<int>(json['actualAttendance']),
      expectedAtHc: serializer.fromJson<int>(json['expectedAtHc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'homeChurchId': serializer.toJson<int>(homeChurchId),
      'actualAttendance': serializer.toJson<int>(actualAttendance),
      'expectedAtHc': serializer.toJson<int>(expectedAtHc),
    };
  }

  HolyCommunionAttendanceData copyWith({
    int? id,
    int? eventId,
    int? homeChurchId,
    int? actualAttendance,
    int? expectedAtHc,
  }) => HolyCommunionAttendanceData(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    homeChurchId: homeChurchId ?? this.homeChurchId,
    actualAttendance: actualAttendance ?? this.actualAttendance,
    expectedAtHc: expectedAtHc ?? this.expectedAtHc,
  );
  HolyCommunionAttendanceData copyWithCompanion(
    HolyCommunionAttendanceCompanion data,
  ) {
    return HolyCommunionAttendanceData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      homeChurchId: data.homeChurchId.present
          ? data.homeChurchId.value
          : this.homeChurchId,
      actualAttendance: data.actualAttendance.present
          ? data.actualAttendance.value
          : this.actualAttendance,
      expectedAtHc: data.expectedAtHc.present
          ? data.expectedAtHc.value
          : this.expectedAtHc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolyCommunionAttendanceData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('homeChurchId: $homeChurchId, ')
          ..write('actualAttendance: $actualAttendance, ')
          ..write('expectedAtHc: $expectedAtHc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventId, homeChurchId, actualAttendance, expectedAtHc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolyCommunionAttendanceData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.homeChurchId == this.homeChurchId &&
          other.actualAttendance == this.actualAttendance &&
          other.expectedAtHc == this.expectedAtHc);
}

class HolyCommunionAttendanceCompanion
    extends UpdateCompanion<HolyCommunionAttendanceData> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<int> homeChurchId;
  final Value<int> actualAttendance;
  final Value<int> expectedAtHc;
  const HolyCommunionAttendanceCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.homeChurchId = const Value.absent(),
    this.actualAttendance = const Value.absent(),
    this.expectedAtHc = const Value.absent(),
  });
  HolyCommunionAttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required int homeChurchId,
    this.actualAttendance = const Value.absent(),
    this.expectedAtHc = const Value.absent(),
  }) : eventId = Value(eventId),
       homeChurchId = Value(homeChurchId);
  static Insertable<HolyCommunionAttendanceData> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<int>? homeChurchId,
    Expression<int>? actualAttendance,
    Expression<int>? expectedAtHc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (homeChurchId != null) 'home_church_id': homeChurchId,
      if (actualAttendance != null) 'actual_attendance': actualAttendance,
      if (expectedAtHc != null) 'expected_at_hc': expectedAtHc,
    });
  }

  HolyCommunionAttendanceCompanion copyWith({
    Value<int>? id,
    Value<int>? eventId,
    Value<int>? homeChurchId,
    Value<int>? actualAttendance,
    Value<int>? expectedAtHc,
  }) {
    return HolyCommunionAttendanceCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      homeChurchId: homeChurchId ?? this.homeChurchId,
      actualAttendance: actualAttendance ?? this.actualAttendance,
      expectedAtHc: expectedAtHc ?? this.expectedAtHc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (homeChurchId.present) {
      map['home_church_id'] = Variable<int>(homeChurchId.value);
    }
    if (actualAttendance.present) {
      map['actual_attendance'] = Variable<int>(actualAttendance.value);
    }
    if (expectedAtHc.present) {
      map['expected_at_hc'] = Variable<int>(expectedAtHc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolyCommunionAttendanceCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('homeChurchId: $homeChurchId, ')
          ..write('actualAttendance: $actualAttendance, ')
          ..write('expectedAtHc: $expectedAtHc')
          ..write(')'))
        .toString();
  }
}

class $BusinessMeetingEventsTable extends BusinessMeetingEvents
    with TableInfo<$BusinessMeetingEventsTable, BusinessMeetingEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessMeetingEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdByAdminIdMeta = const VerificationMeta(
    'createdByAdminId',
  );
  @override
  late final GeneratedColumn<int> createdByAdminId = GeneratedColumn<int>(
    'created_by_admin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES admin_users (id)',
    ),
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quarterMeta = const VerificationMeta(
    'quarter',
  );
  @override
  late final GeneratedColumn<int> quarter = GeneratedColumn<int>(
    'quarter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingNumberMeta = const VerificationMeta(
    'meetingNumber',
  );
  @override
  late final GeneratedColumn<int> meetingNumber = GeneratedColumn<int>(
    'meeting_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalExpectedAtKccMeta =
      const VerificationMeta('totalExpectedAtKcc');
  @override
  late final GeneratedColumn<int> totalExpectedAtKcc = GeneratedColumn<int>(
    'total_expected_at_kcc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    createdByAdminId,
    eventDate,
    year,
    quarter,
    meetingNumber,
    totalExpectedAtKcc,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_meeting_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessMeetingEvent> instance, {
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
    if (data.containsKey('created_by_admin_id')) {
      context.handle(
        _createdByAdminIdMeta,
        createdByAdminId.isAcceptableOrUnknown(
          data['created_by_admin_id']!,
          _createdByAdminIdMeta,
        ),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('quarter')) {
      context.handle(
        _quarterMeta,
        quarter.isAcceptableOrUnknown(data['quarter']!, _quarterMeta),
      );
    } else if (isInserting) {
      context.missing(_quarterMeta);
    }
    if (data.containsKey('meeting_number')) {
      context.handle(
        _meetingNumberMeta,
        meetingNumber.isAcceptableOrUnknown(
          data['meeting_number']!,
          _meetingNumberMeta,
        ),
      );
    }
    if (data.containsKey('total_expected_at_kcc')) {
      context.handle(
        _totalExpectedAtKccMeta,
        totalExpectedAtKcc.isAcceptableOrUnknown(
          data['total_expected_at_kcc']!,
          _totalExpectedAtKccMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {churchId, year, quarter, meetingNumber},
  ];
  @override
  BusinessMeetingEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessMeetingEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      churchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}church_id'],
      )!,
      createdByAdminId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_admin_id'],
      ),
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      quarter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quarter'],
      )!,
      meetingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_number'],
      )!,
      totalExpectedAtKcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_expected_at_kcc'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
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
  $BusinessMeetingEventsTable createAlias(String alias) {
    return $BusinessMeetingEventsTable(attachedDatabase, alias);
  }
}

class BusinessMeetingEvent extends DataClass
    implements Insertable<BusinessMeetingEvent> {
  final int id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime eventDate;
  final int year;
  final int quarter;
  final int meetingNumber;
  final int totalExpectedAtKcc;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BusinessMeetingEvent({
    required this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.eventDate,
    required this.year,
    required this.quarter,
    required this.meetingNumber,
    required this.totalExpectedAtKcc,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['church_id'] = Variable<int>(churchId);
    if (!nullToAbsent || createdByAdminId != null) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId);
    }
    map['event_date'] = Variable<DateTime>(eventDate);
    map['year'] = Variable<int>(year);
    map['quarter'] = Variable<int>(quarter);
    map['meeting_number'] = Variable<int>(meetingNumber);
    map['total_expected_at_kcc'] = Variable<int>(totalExpectedAtKcc);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BusinessMeetingEventsCompanion toCompanion(bool nullToAbsent) {
    return BusinessMeetingEventsCompanion(
      id: Value(id),
      churchId: Value(churchId),
      createdByAdminId: createdByAdminId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByAdminId),
      eventDate: Value(eventDate),
      year: Value(year),
      quarter: Value(quarter),
      meetingNumber: Value(meetingNumber),
      totalExpectedAtKcc: Value(totalExpectedAtKcc),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BusinessMeetingEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessMeetingEvent(
      id: serializer.fromJson<int>(json['id']),
      churchId: serializer.fromJson<int>(json['churchId']),
      createdByAdminId: serializer.fromJson<int?>(json['createdByAdminId']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      year: serializer.fromJson<int>(json['year']),
      quarter: serializer.fromJson<int>(json['quarter']),
      meetingNumber: serializer.fromJson<int>(json['meetingNumber']),
      totalExpectedAtKcc: serializer.fromJson<int>(json['totalExpectedAtKcc']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'createdByAdminId': serializer.toJson<int?>(createdByAdminId),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'year': serializer.toJson<int>(year),
      'quarter': serializer.toJson<int>(quarter),
      'meetingNumber': serializer.toJson<int>(meetingNumber),
      'totalExpectedAtKcc': serializer.toJson<int>(totalExpectedAtKcc),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BusinessMeetingEvent copyWith({
    int? id,
    int? churchId,
    Value<int?> createdByAdminId = const Value.absent(),
    DateTime? eventDate,
    int? year,
    int? quarter,
    int? meetingNumber,
    int? totalExpectedAtKcc,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BusinessMeetingEvent(
    id: id ?? this.id,
    churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId.present
        ? createdByAdminId.value
        : this.createdByAdminId,
    eventDate: eventDate ?? this.eventDate,
    year: year ?? this.year,
    quarter: quarter ?? this.quarter,
    meetingNumber: meetingNumber ?? this.meetingNumber,
    totalExpectedAtKcc: totalExpectedAtKcc ?? this.totalExpectedAtKcc,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BusinessMeetingEvent copyWithCompanion(BusinessMeetingEventsCompanion data) {
    return BusinessMeetingEvent(
      id: data.id.present ? data.id.value : this.id,
      churchId: data.churchId.present ? data.churchId.value : this.churchId,
      createdByAdminId: data.createdByAdminId.present
          ? data.createdByAdminId.value
          : this.createdByAdminId,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      year: data.year.present ? data.year.value : this.year,
      quarter: data.quarter.present ? data.quarter.value : this.quarter,
      meetingNumber: data.meetingNumber.present
          ? data.meetingNumber.value
          : this.meetingNumber,
      totalExpectedAtKcc: data.totalExpectedAtKcc.present
          ? data.totalExpectedAtKcc.value
          : this.totalExpectedAtKcc,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessMeetingEvent(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('eventDate: $eventDate, ')
          ..write('year: $year, ')
          ..write('quarter: $quarter, ')
          ..write('meetingNumber: $meetingNumber, ')
          ..write('totalExpectedAtKcc: $totalExpectedAtKcc, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    churchId,
    createdByAdminId,
    eventDate,
    year,
    quarter,
    meetingNumber,
    totalExpectedAtKcc,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessMeetingEvent &&
          other.id == this.id &&
          other.churchId == this.churchId &&
          other.createdByAdminId == this.createdByAdminId &&
          other.eventDate == this.eventDate &&
          other.year == this.year &&
          other.quarter == this.quarter &&
          other.meetingNumber == this.meetingNumber &&
          other.totalExpectedAtKcc == this.totalExpectedAtKcc &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BusinessMeetingEventsCompanion
    extends UpdateCompanion<BusinessMeetingEvent> {
  final Value<int> id;
  final Value<int> churchId;
  final Value<int?> createdByAdminId;
  final Value<DateTime> eventDate;
  final Value<int> year;
  final Value<int> quarter;
  final Value<int> meetingNumber;
  final Value<int> totalExpectedAtKcc;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BusinessMeetingEventsCompanion({
    this.id = const Value.absent(),
    this.churchId = const Value.absent(),
    this.createdByAdminId = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.year = const Value.absent(),
    this.quarter = const Value.absent(),
    this.meetingNumber = const Value.absent(),
    this.totalExpectedAtKcc = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BusinessMeetingEventsCompanion.insert({
    this.id = const Value.absent(),
    required int churchId,
    this.createdByAdminId = const Value.absent(),
    required DateTime eventDate,
    required int year,
    required int quarter,
    this.meetingNumber = const Value.absent(),
    this.totalExpectedAtKcc = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : churchId = Value(churchId),
       eventDate = Value(eventDate),
       year = Value(year),
       quarter = Value(quarter),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BusinessMeetingEvent> custom({
    Expression<int>? id,
    Expression<int>? churchId,
    Expression<int>? createdByAdminId,
    Expression<DateTime>? eventDate,
    Expression<int>? year,
    Expression<int>? quarter,
    Expression<int>? meetingNumber,
    Expression<int>? totalExpectedAtKcc,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (churchId != null) 'church_id': churchId,
      if (createdByAdminId != null) 'created_by_admin_id': createdByAdminId,
      if (eventDate != null) 'event_date': eventDate,
      if (year != null) 'year': year,
      if (quarter != null) 'quarter': quarter,
      if (meetingNumber != null) 'meeting_number': meetingNumber,
      if (totalExpectedAtKcc != null)
        'total_expected_at_kcc': totalExpectedAtKcc,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BusinessMeetingEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? churchId,
    Value<int?>? createdByAdminId,
    Value<DateTime>? eventDate,
    Value<int>? year,
    Value<int>? quarter,
    Value<int>? meetingNumber,
    Value<int>? totalExpectedAtKcc,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BusinessMeetingEventsCompanion(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      createdByAdminId: createdByAdminId ?? this.createdByAdminId,
      eventDate: eventDate ?? this.eventDate,
      year: year ?? this.year,
      quarter: quarter ?? this.quarter,
      meetingNumber: meetingNumber ?? this.meetingNumber,
      totalExpectedAtKcc: totalExpectedAtKcc ?? this.totalExpectedAtKcc,
      notes: notes ?? this.notes,
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
    if (createdByAdminId.present) {
      map['created_by_admin_id'] = Variable<int>(createdByAdminId.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (quarter.present) {
      map['quarter'] = Variable<int>(quarter.value);
    }
    if (meetingNumber.present) {
      map['meeting_number'] = Variable<int>(meetingNumber.value);
    }
    if (totalExpectedAtKcc.present) {
      map['total_expected_at_kcc'] = Variable<int>(totalExpectedAtKcc.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessMeetingEventsCompanion(')
          ..write('id: $id, ')
          ..write('churchId: $churchId, ')
          ..write('createdByAdminId: $createdByAdminId, ')
          ..write('eventDate: $eventDate, ')
          ..write('year: $year, ')
          ..write('quarter: $quarter, ')
          ..write('meetingNumber: $meetingNumber, ')
          ..write('totalExpectedAtKcc: $totalExpectedAtKcc, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BusinessMeetingAttendanceTable extends BusinessMeetingAttendance
    with
        TableInfo<
          $BusinessMeetingAttendanceTable,
          BusinessMeetingAttendanceData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessMeetingAttendanceTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES business_meeting_events (id)',
    ),
  );
  static const VerificationMeta _homeChurchIdMeta = const VerificationMeta(
    'homeChurchId',
  );
  @override
  late final GeneratedColumn<int> homeChurchId = GeneratedColumn<int>(
    'home_church_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES home_churches (id)',
    ),
  );
  static const VerificationMeta _actualAttendanceMeta = const VerificationMeta(
    'actualAttendance',
  );
  @override
  late final GeneratedColumn<int> actualAttendance = GeneratedColumn<int>(
    'actual_attendance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedAtHcMeta = const VerificationMeta(
    'expectedAtHc',
  );
  @override
  late final GeneratedColumn<int> expectedAtHc = GeneratedColumn<int>(
    'expected_at_hc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    homeChurchId,
    actualAttendance,
    expectedAtHc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_meeting_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessMeetingAttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('home_church_id')) {
      context.handle(
        _homeChurchIdMeta,
        homeChurchId.isAcceptableOrUnknown(
          data['home_church_id']!,
          _homeChurchIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_homeChurchIdMeta);
    }
    if (data.containsKey('actual_attendance')) {
      context.handle(
        _actualAttendanceMeta,
        actualAttendance.isAcceptableOrUnknown(
          data['actual_attendance']!,
          _actualAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('expected_at_hc')) {
      context.handle(
        _expectedAtHcMeta,
        expectedAtHc.isAcceptableOrUnknown(
          data['expected_at_hc']!,
          _expectedAtHcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventId, homeChurchId},
  ];
  @override
  BusinessMeetingAttendanceData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessMeetingAttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      homeChurchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_church_id'],
      )!,
      actualAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_attendance'],
      )!,
      expectedAtHc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_at_hc'],
      )!,
    );
  }

  @override
  $BusinessMeetingAttendanceTable createAlias(String alias) {
    return $BusinessMeetingAttendanceTable(attachedDatabase, alias);
  }
}

class BusinessMeetingAttendanceData extends DataClass
    implements Insertable<BusinessMeetingAttendanceData> {
  final int id;
  final int eventId;
  final int homeChurchId;
  final int actualAttendance;
  final int expectedAtHc;
  const BusinessMeetingAttendanceData({
    required this.id,
    required this.eventId,
    required this.homeChurchId,
    required this.actualAttendance,
    required this.expectedAtHc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['home_church_id'] = Variable<int>(homeChurchId);
    map['actual_attendance'] = Variable<int>(actualAttendance);
    map['expected_at_hc'] = Variable<int>(expectedAtHc);
    return map;
  }

  BusinessMeetingAttendanceCompanion toCompanion(bool nullToAbsent) {
    return BusinessMeetingAttendanceCompanion(
      id: Value(id),
      eventId: Value(eventId),
      homeChurchId: Value(homeChurchId),
      actualAttendance: Value(actualAttendance),
      expectedAtHc: Value(expectedAtHc),
    );
  }

  factory BusinessMeetingAttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessMeetingAttendanceData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      homeChurchId: serializer.fromJson<int>(json['homeChurchId']),
      actualAttendance: serializer.fromJson<int>(json['actualAttendance']),
      expectedAtHc: serializer.fromJson<int>(json['expectedAtHc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'homeChurchId': serializer.toJson<int>(homeChurchId),
      'actualAttendance': serializer.toJson<int>(actualAttendance),
      'expectedAtHc': serializer.toJson<int>(expectedAtHc),
    };
  }

  BusinessMeetingAttendanceData copyWith({
    int? id,
    int? eventId,
    int? homeChurchId,
    int? actualAttendance,
    int? expectedAtHc,
  }) => BusinessMeetingAttendanceData(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    homeChurchId: homeChurchId ?? this.homeChurchId,
    actualAttendance: actualAttendance ?? this.actualAttendance,
    expectedAtHc: expectedAtHc ?? this.expectedAtHc,
  );
  BusinessMeetingAttendanceData copyWithCompanion(
    BusinessMeetingAttendanceCompanion data,
  ) {
    return BusinessMeetingAttendanceData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      homeChurchId: data.homeChurchId.present
          ? data.homeChurchId.value
          : this.homeChurchId,
      actualAttendance: data.actualAttendance.present
          ? data.actualAttendance.value
          : this.actualAttendance,
      expectedAtHc: data.expectedAtHc.present
          ? data.expectedAtHc.value
          : this.expectedAtHc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessMeetingAttendanceData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('homeChurchId: $homeChurchId, ')
          ..write('actualAttendance: $actualAttendance, ')
          ..write('expectedAtHc: $expectedAtHc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventId, homeChurchId, actualAttendance, expectedAtHc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessMeetingAttendanceData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.homeChurchId == this.homeChurchId &&
          other.actualAttendance == this.actualAttendance &&
          other.expectedAtHc == this.expectedAtHc);
}

class BusinessMeetingAttendanceCompanion
    extends UpdateCompanion<BusinessMeetingAttendanceData> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<int> homeChurchId;
  final Value<int> actualAttendance;
  final Value<int> expectedAtHc;
  const BusinessMeetingAttendanceCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.homeChurchId = const Value.absent(),
    this.actualAttendance = const Value.absent(),
    this.expectedAtHc = const Value.absent(),
  });
  BusinessMeetingAttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required int homeChurchId,
    this.actualAttendance = const Value.absent(),
    this.expectedAtHc = const Value.absent(),
  }) : eventId = Value(eventId),
       homeChurchId = Value(homeChurchId);
  static Insertable<BusinessMeetingAttendanceData> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<int>? homeChurchId,
    Expression<int>? actualAttendance,
    Expression<int>? expectedAtHc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (homeChurchId != null) 'home_church_id': homeChurchId,
      if (actualAttendance != null) 'actual_attendance': actualAttendance,
      if (expectedAtHc != null) 'expected_at_hc': expectedAtHc,
    });
  }

  BusinessMeetingAttendanceCompanion copyWith({
    Value<int>? id,
    Value<int>? eventId,
    Value<int>? homeChurchId,
    Value<int>? actualAttendance,
    Value<int>? expectedAtHc,
  }) {
    return BusinessMeetingAttendanceCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      homeChurchId: homeChurchId ?? this.homeChurchId,
      actualAttendance: actualAttendance ?? this.actualAttendance,
      expectedAtHc: expectedAtHc ?? this.expectedAtHc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (homeChurchId.present) {
      map['home_church_id'] = Variable<int>(homeChurchId.value);
    }
    if (actualAttendance.present) {
      map['actual_attendance'] = Variable<int>(actualAttendance.value);
    }
    if (expectedAtHc.present) {
      map['expected_at_hc'] = Variable<int>(expectedAtHc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessMeetingAttendanceCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('homeChurchId: $homeChurchId, ')
          ..write('actualAttendance: $actualAttendance, ')
          ..write('expectedAtHc: $expectedAtHc')
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
  late final $HomeChurchesTable homeChurches = $HomeChurchesTable(this);
  late final $BoardMeetingRecordsTable boardMeetingRecords =
      $BoardMeetingRecordsTable(this);
  late final $HolyCommunionEventsTable holyCommunionEvents =
      $HolyCommunionEventsTable(this);
  late final $HolyCommunionAttendanceTable holyCommunionAttendance =
      $HolyCommunionAttendanceTable(this);
  late final $BusinessMeetingEventsTable businessMeetingEvents =
      $BusinessMeetingEventsTable(this);
  late final $BusinessMeetingAttendanceTable businessMeetingAttendance =
      $BusinessMeetingAttendanceTable(this);
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
    homeChurches,
    boardMeetingRecords,
    holyCommunionEvents,
    holyCommunionAttendance,
    businessMeetingEvents,
    businessMeetingAttendance,
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
      Value<String?> website,
      Value<int> boardMemberCount,
      Value<int> totalMembership,
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
      Value<String?> website,
      Value<int> boardMemberCount,
      Value<int> totalMembership,
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

  static MultiTypedResultKey<$HomeChurchesTable, List<HomeChurche>>
  _homeChurchesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.homeChurches,
    aliasName: $_aliasNameGenerator(db.churches.id, db.homeChurches.churchId),
  );

  $$HomeChurchesTableProcessedTableManager get homeChurchesRefs {
    final manager = $$HomeChurchesTableTableManager(
      $_db,
      $_db.homeChurches,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_homeChurchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BoardMeetingRecordsTable,
    List<BoardMeetingRecord>
  >
  _boardMeetingRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.boardMeetingRecords,
        aliasName: $_aliasNameGenerator(
          db.churches.id,
          db.boardMeetingRecords.churchId,
        ),
      );

  $$BoardMeetingRecordsTableProcessedTableManager get boardMeetingRecordsRefs {
    final manager = $$BoardMeetingRecordsTableTableManager(
      $_db,
      $_db.boardMeetingRecords,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _boardMeetingRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $HolyCommunionEventsTable,
    List<HolyCommunionEvent>
  >
  _holyCommunionEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holyCommunionEvents,
        aliasName: $_aliasNameGenerator(
          db.churches.id,
          db.holyCommunionEvents.churchId,
        ),
      );

  $$HolyCommunionEventsTableProcessedTableManager get holyCommunionEventsRefs {
    final manager = $$HolyCommunionEventsTableTableManager(
      $_db,
      $_db.holyCommunionEvents,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holyCommunionEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BusinessMeetingEventsTable,
    List<BusinessMeetingEvent>
  >
  _businessMeetingEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.businessMeetingEvents,
        aliasName: $_aliasNameGenerator(
          db.churches.id,
          db.businessMeetingEvents.churchId,
        ),
      );

  $$BusinessMeetingEventsTableProcessedTableManager
  get businessMeetingEventsRefs {
    final manager = $$BusinessMeetingEventsTableTableManager(
      $_db,
      $_db.businessMeetingEvents,
    ).filter((f) => f.churchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _businessMeetingEventsRefsTable($_db),
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

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get boardMemberCount => $composableBuilder(
    column: $table.boardMemberCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMembership => $composableBuilder(
    column: $table.totalMembership,
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

  Expression<bool> homeChurchesRefs(
    Expression<bool> Function($$HomeChurchesTableFilterComposer f) f,
  ) {
    final $$HomeChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableFilterComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> boardMeetingRecordsRefs(
    Expression<bool> Function($$BoardMeetingRecordsTableFilterComposer f) f,
  ) {
    final $$BoardMeetingRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.boardMeetingRecords,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardMeetingRecordsTableFilterComposer(
            $db: $db,
            $table: $db.boardMeetingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holyCommunionEventsRefs(
    Expression<bool> Function($$HolyCommunionEventsTableFilterComposer f) f,
  ) {
    final $$HolyCommunionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holyCommunionEvents,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HolyCommunionEventsTableFilterComposer(
            $db: $db,
            $table: $db.holyCommunionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> businessMeetingEventsRefs(
    Expression<bool> Function($$BusinessMeetingEventsTableFilterComposer f) f,
  ) {
    final $$BusinessMeetingEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.churchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableFilterComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
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

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get boardMemberCount => $composableBuilder(
    column: $table.boardMemberCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMembership => $composableBuilder(
    column: $table.totalMembership,
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

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<int> get boardMemberCount => $composableBuilder(
    column: $table.boardMemberCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMembership => $composableBuilder(
    column: $table.totalMembership,
    builder: (column) => column,
  );

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

  Expression<T> homeChurchesRefs<T extends Object>(
    Expression<T> Function($$HomeChurchesTableAnnotationComposer a) f,
  ) {
    final $$HomeChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.churchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> boardMeetingRecordsRefs<T extends Object>(
    Expression<T> Function($$BoardMeetingRecordsTableAnnotationComposer a) f,
  ) {
    final $$BoardMeetingRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.boardMeetingRecords,
          getReferencedColumn: (t) => t.churchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BoardMeetingRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.boardMeetingRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> holyCommunionEventsRefs<T extends Object>(
    Expression<T> Function($$HolyCommunionEventsTableAnnotationComposer a) f,
  ) {
    final $$HolyCommunionEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.holyCommunionEvents,
          getReferencedColumn: (t) => t.churchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.holyCommunionEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> businessMeetingEventsRefs<T extends Object>(
    Expression<T> Function($$BusinessMeetingEventsTableAnnotationComposer a) f,
  ) {
    final $$BusinessMeetingEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.churchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
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
            bool homeChurchesRefs,
            bool boardMeetingRecordsRefs,
            bool holyCommunionEventsRefs,
            bool businessMeetingEventsRefs,
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
                Value<String?> website = const Value.absent(),
                Value<int> boardMemberCount = const Value.absent(),
                Value<int> totalMembership = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ChurchesCompanion(
                id: id,
                name: name,
                address: address,
                contactEmail: contactEmail,
                contactPhone: contactPhone,
                currency: currency,
                website: website,
                boardMemberCount: boardMemberCount,
                totalMembership: totalMembership,
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
                Value<String?> website = const Value.absent(),
                Value<int> boardMemberCount = const Value.absent(),
                Value<int> totalMembership = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ChurchesCompanion.insert(
                id: id,
                name: name,
                address: address,
                contactEmail: contactEmail,
                contactPhone: contactPhone,
                currency: currency,
                website: website,
                boardMemberCount: boardMemberCount,
                totalMembership: totalMembership,
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
                homeChurchesRefs = false,
                boardMeetingRecordsRefs = false,
                holyCommunionEventsRefs = false,
                businessMeetingEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (adminUsersRefs) db.adminUsers,
                    if (weeklyRecordsRefs) db.weeklyRecords,
                    if (derivedMetricsListRefs) db.derivedMetricsList,
                    if (exportHistoryListRefs) db.exportHistoryList,
                    if (homeChurchesRefs) db.homeChurches,
                    if (boardMeetingRecordsRefs) db.boardMeetingRecords,
                    if (holyCommunionEventsRefs) db.holyCommunionEvents,
                    if (businessMeetingEventsRefs) db.businessMeetingEvents,
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
                      if (homeChurchesRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          HomeChurche
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._homeChurchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).homeChurchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (boardMeetingRecordsRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          BoardMeetingRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._boardMeetingRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).boardMeetingRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holyCommunionEventsRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          HolyCommunionEvent
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._holyCommunionEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).holyCommunionEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.churchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (businessMeetingEventsRefs)
                        await $_getPrefetchedData<
                          Churche,
                          $ChurchesTable,
                          BusinessMeetingEvent
                        >(
                          currentTable: table,
                          referencedTable: $$ChurchesTableReferences
                              ._businessMeetingEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).businessMeetingEventsRefs,
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
        bool homeChurchesRefs,
        bool boardMeetingRecordsRefs,
        bool holyCommunionEventsRefs,
        bool businessMeetingEventsRefs,
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
      Value<String?> pinHash,
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
      Value<String?> pinHash,
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

  static MultiTypedResultKey<$WeeklyRecordsTable, List<WeeklyRecord>>
  _weeklyRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weeklyRecords,
    aliasName: $_aliasNameGenerator(
      db.adminUsers.id,
      db.weeklyRecords.createdByAdminId,
    ),
  );

  $$WeeklyRecordsTableProcessedTableManager get weeklyRecordsRefs {
    final manager = $$WeeklyRecordsTableTableManager(
      $_db,
      $_db.weeklyRecords,
    ).filter((f) => f.createdByAdminId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weeklyRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BoardMeetingRecordsTable,
    List<BoardMeetingRecord>
  >
  _boardMeetingRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.boardMeetingRecords,
        aliasName: $_aliasNameGenerator(
          db.adminUsers.id,
          db.boardMeetingRecords.createdByAdminId,
        ),
      );

  $$BoardMeetingRecordsTableProcessedTableManager get boardMeetingRecordsRefs {
    final manager = $$BoardMeetingRecordsTableTableManager(
      $_db,
      $_db.boardMeetingRecords,
    ).filter((f) => f.createdByAdminId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _boardMeetingRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $HolyCommunionEventsTable,
    List<HolyCommunionEvent>
  >
  _holyCommunionEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holyCommunionEvents,
        aliasName: $_aliasNameGenerator(
          db.adminUsers.id,
          db.holyCommunionEvents.createdByAdminId,
        ),
      );

  $$HolyCommunionEventsTableProcessedTableManager get holyCommunionEventsRefs {
    final manager = $$HolyCommunionEventsTableTableManager(
      $_db,
      $_db.holyCommunionEvents,
    ).filter((f) => f.createdByAdminId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holyCommunionEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BusinessMeetingEventsTable,
    List<BusinessMeetingEvent>
  >
  _businessMeetingEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.businessMeetingEvents,
        aliasName: $_aliasNameGenerator(
          db.adminUsers.id,
          db.businessMeetingEvents.createdByAdminId,
        ),
      );

  $$BusinessMeetingEventsTableProcessedTableManager
  get businessMeetingEventsRefs {
    final manager = $$BusinessMeetingEventsTableTableManager(
      $_db,
      $_db.businessMeetingEvents,
    ).filter((f) => f.createdByAdminId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _businessMeetingEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
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

  Expression<bool> weeklyRecordsRefs(
    Expression<bool> Function($$WeeklyRecordsTableFilterComposer f) f,
  ) {
    final $$WeeklyRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyRecords,
      getReferencedColumn: (t) => t.createdByAdminId,
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

  Expression<bool> boardMeetingRecordsRefs(
    Expression<bool> Function($$BoardMeetingRecordsTableFilterComposer f) f,
  ) {
    final $$BoardMeetingRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.boardMeetingRecords,
      getReferencedColumn: (t) => t.createdByAdminId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardMeetingRecordsTableFilterComposer(
            $db: $db,
            $table: $db.boardMeetingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holyCommunionEventsRefs(
    Expression<bool> Function($$HolyCommunionEventsTableFilterComposer f) f,
  ) {
    final $$HolyCommunionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holyCommunionEvents,
      getReferencedColumn: (t) => t.createdByAdminId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HolyCommunionEventsTableFilterComposer(
            $db: $db,
            $table: $db.holyCommunionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> businessMeetingEventsRefs(
    Expression<bool> Function($$BusinessMeetingEventsTableFilterComposer f) f,
  ) {
    final $$BusinessMeetingEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.createdByAdminId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableFilterComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
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

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

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

  Expression<T> weeklyRecordsRefs<T extends Object>(
    Expression<T> Function($$WeeklyRecordsTableAnnotationComposer a) f,
  ) {
    final $$WeeklyRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyRecords,
      getReferencedColumn: (t) => t.createdByAdminId,
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

  Expression<T> boardMeetingRecordsRefs<T extends Object>(
    Expression<T> Function($$BoardMeetingRecordsTableAnnotationComposer a) f,
  ) {
    final $$BoardMeetingRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.boardMeetingRecords,
          getReferencedColumn: (t) => t.createdByAdminId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BoardMeetingRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.boardMeetingRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> holyCommunionEventsRefs<T extends Object>(
    Expression<T> Function($$HolyCommunionEventsTableAnnotationComposer a) f,
  ) {
    final $$HolyCommunionEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.holyCommunionEvents,
          getReferencedColumn: (t) => t.createdByAdminId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.holyCommunionEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> businessMeetingEventsRefs<T extends Object>(
    Expression<T> Function($$BusinessMeetingEventsTableAnnotationComposer a) f,
  ) {
    final $$BusinessMeetingEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.createdByAdminId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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
          PrefetchHooks Function({
            bool churchId,
            bool weeklyRecordsRefs,
            bool boardMeetingRecordsRefs,
            bool holyCommunionEventsRefs,
            bool businessMeetingEventsRefs,
          })
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
                Value<String?> pinHash = const Value.absent(),
              }) => AdminUsersCompanion(
                id: id,
                username: username,
                fullName: fullName,
                email: email,
                churchId: churchId,
                isActive: isActive,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
                pinHash: pinHash,
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
                Value<String?> pinHash = const Value.absent(),
              }) => AdminUsersCompanion.insert(
                id: id,
                username: username,
                fullName: fullName,
                email: email,
                churchId: churchId,
                isActive: isActive,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
                pinHash: pinHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdminUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                churchId = false,
                weeklyRecordsRefs = false,
                boardMeetingRecordsRefs = false,
                holyCommunionEventsRefs = false,
                businessMeetingEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (weeklyRecordsRefs) db.weeklyRecords,
                    if (boardMeetingRecordsRefs) db.boardMeetingRecords,
                    if (holyCommunionEventsRefs) db.holyCommunionEvents,
                    if (businessMeetingEventsRefs) db.businessMeetingEvents,
                  ],
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
                                    referencedColumn:
                                        $$AdminUsersTableReferences
                                            ._churchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (weeklyRecordsRefs)
                        await $_getPrefetchedData<
                          AdminUser,
                          $AdminUsersTable,
                          WeeklyRecord
                        >(
                          currentTable: table,
                          referencedTable: $$AdminUsersTableReferences
                              ._weeklyRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdminUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).weeklyRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdByAdminId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (boardMeetingRecordsRefs)
                        await $_getPrefetchedData<
                          AdminUser,
                          $AdminUsersTable,
                          BoardMeetingRecord
                        >(
                          currentTable: table,
                          referencedTable: $$AdminUsersTableReferences
                              ._boardMeetingRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdminUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).boardMeetingRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdByAdminId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holyCommunionEventsRefs)
                        await $_getPrefetchedData<
                          AdminUser,
                          $AdminUsersTable,
                          HolyCommunionEvent
                        >(
                          currentTable: table,
                          referencedTable: $$AdminUsersTableReferences
                              ._holyCommunionEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdminUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).holyCommunionEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdByAdminId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (businessMeetingEventsRefs)
                        await $_getPrefetchedData<
                          AdminUser,
                          $AdminUsersTable,
                          BusinessMeetingEvent
                        >(
                          currentTable: table,
                          referencedTable: $$AdminUsersTableReferences
                              ._businessMeetingEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdminUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).businessMeetingEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdByAdminId == item.id,
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
      PrefetchHooks Function({
        bool churchId,
        bool weeklyRecordsRefs,
        bool boardMeetingRecordsRefs,
        bool holyCommunionEventsRefs,
        bool businessMeetingEventsRefs,
      })
    >;
typedef $$WeeklyRecordsTableCreateCompanionBuilder =
    WeeklyRecordsCompanion Function({
      Value<int> id,
      required int churchId,
      Value<int?> createdByAdminId,
      required DateTime weekStartDate,
      Value<int> men,
      Value<int> women,
      Value<int> youth,
      Value<int> children,
      Value<int> sundayHomeChurch,
      Value<int?> baptisms,
      Value<int?> holyCommunion,
      Value<double> tithe,
      Value<double> offerings,
      Value<double> emergencyCollection,
      Value<double> plannedCollection,
      Value<int?> sabbathSchoolAttendance,
      Value<int?> visitorsCount,
      Value<double?> missionOffering,
      Value<double?> localChurchBudget,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WeeklyRecordsTableUpdateCompanionBuilder =
    WeeklyRecordsCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<int?> createdByAdminId,
      Value<DateTime> weekStartDate,
      Value<int> men,
      Value<int> women,
      Value<int> youth,
      Value<int> children,
      Value<int> sundayHomeChurch,
      Value<int?> baptisms,
      Value<int?> holyCommunion,
      Value<double> tithe,
      Value<double> offerings,
      Value<double> emergencyCollection,
      Value<double> plannedCollection,
      Value<int?> sabbathSchoolAttendance,
      Value<int?> visitorsCount,
      Value<double?> missionOffering,
      Value<double?> localChurchBudget,
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

  static $AdminUsersTable _createdByAdminIdTable(_$AppDatabase db) =>
      db.adminUsers.createAlias(
        $_aliasNameGenerator(
          db.weeklyRecords.createdByAdminId,
          db.adminUsers.id,
        ),
      );

  $$AdminUsersTableProcessedTableManager? get createdByAdminId {
    final $_column = $_itemColumn<int>('created_by_admin_id');
    if ($_column == null) return null;
    final manager = $$AdminUsersTableTableManager(
      $_db,
      $_db.adminUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByAdminIdTable($_db));
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

  ColumnFilters<int> get baptisms => $composableBuilder(
    column: $table.baptisms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holyCommunion => $composableBuilder(
    column: $table.holyCommunion,
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

  ColumnFilters<int> get sabbathSchoolAttendance => $composableBuilder(
    column: $table.sabbathSchoolAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitorsCount => $composableBuilder(
    column: $table.visitorsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get missionOffering => $composableBuilder(
    column: $table.missionOffering,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get localChurchBudget => $composableBuilder(
    column: $table.localChurchBudget,
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

  $$AdminUsersTableFilterComposer get createdByAdminId {
    final $$AdminUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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

  ColumnOrderings<int> get baptisms => $composableBuilder(
    column: $table.baptisms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holyCommunion => $composableBuilder(
    column: $table.holyCommunion,
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

  ColumnOrderings<int> get sabbathSchoolAttendance => $composableBuilder(
    column: $table.sabbathSchoolAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitorsCount => $composableBuilder(
    column: $table.visitorsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get missionOffering => $composableBuilder(
    column: $table.missionOffering,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get localChurchBudget => $composableBuilder(
    column: $table.localChurchBudget,
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

  $$AdminUsersTableOrderingComposer get createdByAdminId {
    final $$AdminUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUsersTableOrderingComposer(
            $db: $db,
            $table: $db.adminUsers,
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

  GeneratedColumn<int> get baptisms =>
      $composableBuilder(column: $table.baptisms, builder: (column) => column);

  GeneratedColumn<int> get holyCommunion => $composableBuilder(
    column: $table.holyCommunion,
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

  GeneratedColumn<int> get sabbathSchoolAttendance => $composableBuilder(
    column: $table.sabbathSchoolAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get visitorsCount => $composableBuilder(
    column: $table.visitorsCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get missionOffering => $composableBuilder(
    column: $table.missionOffering,
    builder: (column) => column,
  );

  GeneratedColumn<double> get localChurchBudget => $composableBuilder(
    column: $table.localChurchBudget,
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

  $$AdminUsersTableAnnotationComposer get createdByAdminId {
    final $$AdminUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
          PrefetchHooks Function({bool churchId, bool createdByAdminId})
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
                Value<int?> createdByAdminId = const Value.absent(),
                Value<DateTime> weekStartDate = const Value.absent(),
                Value<int> men = const Value.absent(),
                Value<int> women = const Value.absent(),
                Value<int> youth = const Value.absent(),
                Value<int> children = const Value.absent(),
                Value<int> sundayHomeChurch = const Value.absent(),
                Value<int?> baptisms = const Value.absent(),
                Value<int?> holyCommunion = const Value.absent(),
                Value<double> tithe = const Value.absent(),
                Value<double> offerings = const Value.absent(),
                Value<double> emergencyCollection = const Value.absent(),
                Value<double> plannedCollection = const Value.absent(),
                Value<int?> sabbathSchoolAttendance = const Value.absent(),
                Value<int?> visitorsCount = const Value.absent(),
                Value<double?> missionOffering = const Value.absent(),
                Value<double?> localChurchBudget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklyRecordsCompanion(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                weekStartDate: weekStartDate,
                men: men,
                women: women,
                youth: youth,
                children: children,
                sundayHomeChurch: sundayHomeChurch,
                baptisms: baptisms,
                holyCommunion: holyCommunion,
                tithe: tithe,
                offerings: offerings,
                emergencyCollection: emergencyCollection,
                plannedCollection: plannedCollection,
                sabbathSchoolAttendance: sabbathSchoolAttendance,
                visitorsCount: visitorsCount,
                missionOffering: missionOffering,
                localChurchBudget: localChurchBudget,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                Value<int?> createdByAdminId = const Value.absent(),
                required DateTime weekStartDate,
                Value<int> men = const Value.absent(),
                Value<int> women = const Value.absent(),
                Value<int> youth = const Value.absent(),
                Value<int> children = const Value.absent(),
                Value<int> sundayHomeChurch = const Value.absent(),
                Value<int?> baptisms = const Value.absent(),
                Value<int?> holyCommunion = const Value.absent(),
                Value<double> tithe = const Value.absent(),
                Value<double> offerings = const Value.absent(),
                Value<double> emergencyCollection = const Value.absent(),
                Value<double> plannedCollection = const Value.absent(),
                Value<int?> sabbathSchoolAttendance = const Value.absent(),
                Value<int?> visitorsCount = const Value.absent(),
                Value<double?> missionOffering = const Value.absent(),
                Value<double?> localChurchBudget = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WeeklyRecordsCompanion.insert(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                weekStartDate: weekStartDate,
                men: men,
                women: women,
                youth: youth,
                children: children,
                sundayHomeChurch: sundayHomeChurch,
                baptisms: baptisms,
                holyCommunion: holyCommunion,
                tithe: tithe,
                offerings: offerings,
                emergencyCollection: emergencyCollection,
                plannedCollection: plannedCollection,
                sabbathSchoolAttendance: sabbathSchoolAttendance,
                visitorsCount: visitorsCount,
                missionOffering: missionOffering,
                localChurchBudget: localChurchBudget,
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
          prefetchHooksCallback:
              ({churchId = false, createdByAdminId = false}) {
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
                                        $$WeeklyRecordsTableReferences
                                            ._churchIdTable(db),
                                    referencedColumn:
                                        $$WeeklyRecordsTableReferences
                                            ._churchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (createdByAdminId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdByAdminId,
                                    referencedTable:
                                        $$WeeklyRecordsTableReferences
                                            ._createdByAdminIdTable(db),
                                    referencedColumn:
                                        $$WeeklyRecordsTableReferences
                                            ._createdByAdminIdTable(db)
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
      PrefetchHooks Function({bool churchId, bool createdByAdminId})
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
typedef $$HomeChurchesTableCreateCompanionBuilder =
    HomeChurchesCompanion Function({
      Value<int> id,
      required int churchId,
      required String name,
      Value<String> category,
      Value<int> expectedMembership,
      Value<int> expectedAtKcc,
      Value<bool> isActive,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$HomeChurchesTableUpdateCompanionBuilder =
    HomeChurchesCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<String> name,
      Value<String> category,
      Value<int> expectedMembership,
      Value<int> expectedAtKcc,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$HomeChurchesTableReferences
    extends BaseReferences<_$AppDatabase, $HomeChurchesTable, HomeChurche> {
  $$HomeChurchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.homeChurches.churchId, db.churches.id),
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

  static MultiTypedResultKey<
    $HolyCommunionAttendanceTable,
    List<HolyCommunionAttendanceData>
  >
  _holyCommunionAttendanceRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holyCommunionAttendance,
        aliasName: $_aliasNameGenerator(
          db.homeChurches.id,
          db.holyCommunionAttendance.homeChurchId,
        ),
      );

  $$HolyCommunionAttendanceTableProcessedTableManager
  get holyCommunionAttendanceRefs {
    final manager = $$HolyCommunionAttendanceTableTableManager(
      $_db,
      $_db.holyCommunionAttendance,
    ).filter((f) => f.homeChurchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holyCommunionAttendanceRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BusinessMeetingAttendanceTable,
    List<BusinessMeetingAttendanceData>
  >
  _businessMeetingAttendanceRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.businessMeetingAttendance,
        aliasName: $_aliasNameGenerator(
          db.homeChurches.id,
          db.businessMeetingAttendance.homeChurchId,
        ),
      );

  $$BusinessMeetingAttendanceTableProcessedTableManager
  get businessMeetingAttendanceRefs {
    final manager = $$BusinessMeetingAttendanceTableTableManager(
      $_db,
      $_db.businessMeetingAttendance,
    ).filter((f) => f.homeChurchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _businessMeetingAttendanceRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HomeChurchesTableFilterComposer
    extends Composer<_$AppDatabase, $HomeChurchesTable> {
  $$HomeChurchesTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedMembership => $composableBuilder(
    column: $table.expectedMembership,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAtKcc => $composableBuilder(
    column: $table.expectedAtKcc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  Expression<bool> holyCommunionAttendanceRefs(
    Expression<bool> Function($$HolyCommunionAttendanceTableFilterComposer f) f,
  ) {
    final $$HolyCommunionAttendanceTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.holyCommunionAttendance,
          getReferencedColumn: (t) => t.homeChurchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionAttendanceTableFilterComposer(
                $db: $db,
                $table: $db.holyCommunionAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> businessMeetingAttendanceRefs(
    Expression<bool> Function($$BusinessMeetingAttendanceTableFilterComposer f)
    f,
  ) {
    final $$BusinessMeetingAttendanceTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingAttendance,
          getReferencedColumn: (t) => t.homeChurchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingAttendanceTableFilterComposer(
                $db: $db,
                $table: $db.businessMeetingAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HomeChurchesTableOrderingComposer
    extends Composer<_$AppDatabase, $HomeChurchesTable> {
  $$HomeChurchesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedMembership => $composableBuilder(
    column: $table.expectedMembership,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAtKcc => $composableBuilder(
    column: $table.expectedAtKcc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

class $$HomeChurchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HomeChurchesTable> {
  $$HomeChurchesTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get expectedMembership => $composableBuilder(
    column: $table.expectedMembership,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAtKcc => $composableBuilder(
    column: $table.expectedAtKcc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

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

  Expression<T> holyCommunionAttendanceRefs<T extends Object>(
    Expression<T> Function($$HolyCommunionAttendanceTableAnnotationComposer a)
    f,
  ) {
    final $$HolyCommunionAttendanceTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.holyCommunionAttendance,
          getReferencedColumn: (t) => t.homeChurchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionAttendanceTableAnnotationComposer(
                $db: $db,
                $table: $db.holyCommunionAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> businessMeetingAttendanceRefs<T extends Object>(
    Expression<T> Function($$BusinessMeetingAttendanceTableAnnotationComposer a)
    f,
  ) {
    final $$BusinessMeetingAttendanceTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingAttendance,
          getReferencedColumn: (t) => t.homeChurchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingAttendanceTableAnnotationComposer(
                $db: $db,
                $table: $db.businessMeetingAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HomeChurchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HomeChurchesTable,
          HomeChurche,
          $$HomeChurchesTableFilterComposer,
          $$HomeChurchesTableOrderingComposer,
          $$HomeChurchesTableAnnotationComposer,
          $$HomeChurchesTableCreateCompanionBuilder,
          $$HomeChurchesTableUpdateCompanionBuilder,
          (HomeChurche, $$HomeChurchesTableReferences),
          HomeChurche,
          PrefetchHooks Function({
            bool churchId,
            bool holyCommunionAttendanceRefs,
            bool businessMeetingAttendanceRefs,
          })
        > {
  $$HomeChurchesTableTableManager(_$AppDatabase db, $HomeChurchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomeChurchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomeChurchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomeChurchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> expectedMembership = const Value.absent(),
                Value<int> expectedAtKcc = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HomeChurchesCompanion(
                id: id,
                churchId: churchId,
                name: name,
                category: category,
                expectedMembership: expectedMembership,
                expectedAtKcc: expectedAtKcc,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                required String name,
                Value<String> category = const Value.absent(),
                Value<int> expectedMembership = const Value.absent(),
                Value<int> expectedAtKcc = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => HomeChurchesCompanion.insert(
                id: id,
                churchId: churchId,
                name: name,
                category: category,
                expectedMembership: expectedMembership,
                expectedAtKcc: expectedAtKcc,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HomeChurchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                churchId = false,
                holyCommunionAttendanceRefs = false,
                businessMeetingAttendanceRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (holyCommunionAttendanceRefs) db.holyCommunionAttendance,
                    if (businessMeetingAttendanceRefs)
                      db.businessMeetingAttendance,
                  ],
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
                                        $$HomeChurchesTableReferences
                                            ._churchIdTable(db),
                                    referencedColumn:
                                        $$HomeChurchesTableReferences
                                            ._churchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (holyCommunionAttendanceRefs)
                        await $_getPrefetchedData<
                          HomeChurche,
                          $HomeChurchesTable,
                          HolyCommunionAttendanceData
                        >(
                          currentTable: table,
                          referencedTable: $$HomeChurchesTableReferences
                              ._holyCommunionAttendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HomeChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).holyCommunionAttendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.homeChurchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (businessMeetingAttendanceRefs)
                        await $_getPrefetchedData<
                          HomeChurche,
                          $HomeChurchesTable,
                          BusinessMeetingAttendanceData
                        >(
                          currentTable: table,
                          referencedTable: $$HomeChurchesTableReferences
                              ._businessMeetingAttendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HomeChurchesTableReferences(
                                db,
                                table,
                                p0,
                              ).businessMeetingAttendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.homeChurchId == item.id,
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

typedef $$HomeChurchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HomeChurchesTable,
      HomeChurche,
      $$HomeChurchesTableFilterComposer,
      $$HomeChurchesTableOrderingComposer,
      $$HomeChurchesTableAnnotationComposer,
      $$HomeChurchesTableCreateCompanionBuilder,
      $$HomeChurchesTableUpdateCompanionBuilder,
      (HomeChurche, $$HomeChurchesTableReferences),
      HomeChurche,
      PrefetchHooks Function({
        bool churchId,
        bool holyCommunionAttendanceRefs,
        bool businessMeetingAttendanceRefs,
      })
    >;
typedef $$BoardMeetingRecordsTableCreateCompanionBuilder =
    BoardMeetingRecordsCompanion Function({
      Value<int> id,
      required int churchId,
      Value<int?> createdByAdminId,
      required DateTime meetingDate,
      required int year,
      required int month,
      Value<int> actualAttendance,
      Value<int> expectedAttendance,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$BoardMeetingRecordsTableUpdateCompanionBuilder =
    BoardMeetingRecordsCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<int?> createdByAdminId,
      Value<DateTime> meetingDate,
      Value<int> year,
      Value<int> month,
      Value<int> actualAttendance,
      Value<int> expectedAttendance,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BoardMeetingRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BoardMeetingRecordsTable,
          BoardMeetingRecord
        > {
  $$BoardMeetingRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.boardMeetingRecords.churchId, db.churches.id),
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

  static $AdminUsersTable _createdByAdminIdTable(_$AppDatabase db) =>
      db.adminUsers.createAlias(
        $_aliasNameGenerator(
          db.boardMeetingRecords.createdByAdminId,
          db.adminUsers.id,
        ),
      );

  $$AdminUsersTableProcessedTableManager? get createdByAdminId {
    final $_column = $_itemColumn<int>('created_by_admin_id');
    if ($_column == null) return null;
    final manager = $$AdminUsersTableTableManager(
      $_db,
      $_db.adminUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByAdminIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BoardMeetingRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardMeetingRecordsTable> {
  $$BoardMeetingRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get meetingDate => $composableBuilder(
    column: $table.meetingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAttendance => $composableBuilder(
    column: $table.expectedAttendance,
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

  $$AdminUsersTableFilterComposer get createdByAdminId {
    final $$AdminUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BoardMeetingRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardMeetingRecordsTable> {
  $$BoardMeetingRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get meetingDate => $composableBuilder(
    column: $table.meetingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAttendance => $composableBuilder(
    column: $table.expectedAttendance,
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

  $$AdminUsersTableOrderingComposer get createdByAdminId {
    final $$AdminUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUsersTableOrderingComposer(
            $db: $db,
            $table: $db.adminUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BoardMeetingRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardMeetingRecordsTable> {
  $$BoardMeetingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get meetingDate => $composableBuilder(
    column: $table.meetingDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAttendance => $composableBuilder(
    column: $table.expectedAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

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

  $$AdminUsersTableAnnotationComposer get createdByAdminId {
    final $$AdminUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BoardMeetingRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardMeetingRecordsTable,
          BoardMeetingRecord,
          $$BoardMeetingRecordsTableFilterComposer,
          $$BoardMeetingRecordsTableOrderingComposer,
          $$BoardMeetingRecordsTableAnnotationComposer,
          $$BoardMeetingRecordsTableCreateCompanionBuilder,
          $$BoardMeetingRecordsTableUpdateCompanionBuilder,
          (BoardMeetingRecord, $$BoardMeetingRecordsTableReferences),
          BoardMeetingRecord,
          PrefetchHooks Function({bool churchId, bool createdByAdminId})
        > {
  $$BoardMeetingRecordsTableTableManager(
    _$AppDatabase db,
    $BoardMeetingRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardMeetingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardMeetingRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BoardMeetingRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<int?> createdByAdminId = const Value.absent(),
                Value<DateTime> meetingDate = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> actualAttendance = const Value.absent(),
                Value<int> expectedAttendance = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BoardMeetingRecordsCompanion(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                meetingDate: meetingDate,
                year: year,
                month: month,
                actualAttendance: actualAttendance,
                expectedAttendance: expectedAttendance,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                Value<int?> createdByAdminId = const Value.absent(),
                required DateTime meetingDate,
                required int year,
                required int month,
                Value<int> actualAttendance = const Value.absent(),
                Value<int> expectedAttendance = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => BoardMeetingRecordsCompanion.insert(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                meetingDate: meetingDate,
                year: year,
                month: month,
                actualAttendance: actualAttendance,
                expectedAttendance: expectedAttendance,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BoardMeetingRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({churchId = false, createdByAdminId = false}) {
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
                                        $$BoardMeetingRecordsTableReferences
                                            ._churchIdTable(db),
                                    referencedColumn:
                                        $$BoardMeetingRecordsTableReferences
                                            ._churchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (createdByAdminId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdByAdminId,
                                    referencedTable:
                                        $$BoardMeetingRecordsTableReferences
                                            ._createdByAdminIdTable(db),
                                    referencedColumn:
                                        $$BoardMeetingRecordsTableReferences
                                            ._createdByAdminIdTable(db)
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

typedef $$BoardMeetingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardMeetingRecordsTable,
      BoardMeetingRecord,
      $$BoardMeetingRecordsTableFilterComposer,
      $$BoardMeetingRecordsTableOrderingComposer,
      $$BoardMeetingRecordsTableAnnotationComposer,
      $$BoardMeetingRecordsTableCreateCompanionBuilder,
      $$BoardMeetingRecordsTableUpdateCompanionBuilder,
      (BoardMeetingRecord, $$BoardMeetingRecordsTableReferences),
      BoardMeetingRecord,
      PrefetchHooks Function({bool churchId, bool createdByAdminId})
    >;
typedef $$HolyCommunionEventsTableCreateCompanionBuilder =
    HolyCommunionEventsCompanion Function({
      Value<int> id,
      required int churchId,
      Value<int?> createdByAdminId,
      required DateTime eventDate,
      required int year,
      required int quarter,
      Value<int> totalExpectedAtKcc,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$HolyCommunionEventsTableUpdateCompanionBuilder =
    HolyCommunionEventsCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<int?> createdByAdminId,
      Value<DateTime> eventDate,
      Value<int> year,
      Value<int> quarter,
      Value<int> totalExpectedAtKcc,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$HolyCommunionEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HolyCommunionEventsTable,
          HolyCommunionEvent
        > {
  $$HolyCommunionEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.holyCommunionEvents.churchId, db.churches.id),
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

  static $AdminUsersTable _createdByAdminIdTable(_$AppDatabase db) =>
      db.adminUsers.createAlias(
        $_aliasNameGenerator(
          db.holyCommunionEvents.createdByAdminId,
          db.adminUsers.id,
        ),
      );

  $$AdminUsersTableProcessedTableManager? get createdByAdminId {
    final $_column = $_itemColumn<int>('created_by_admin_id');
    if ($_column == null) return null;
    final manager = $$AdminUsersTableTableManager(
      $_db,
      $_db.adminUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByAdminIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $HolyCommunionAttendanceTable,
    List<HolyCommunionAttendanceData>
  >
  _holyCommunionAttendanceRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holyCommunionAttendance,
        aliasName: $_aliasNameGenerator(
          db.holyCommunionEvents.id,
          db.holyCommunionAttendance.eventId,
        ),
      );

  $$HolyCommunionAttendanceTableProcessedTableManager
  get holyCommunionAttendanceRefs {
    final manager = $$HolyCommunionAttendanceTableTableManager(
      $_db,
      $_db.holyCommunionAttendance,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holyCommunionAttendanceRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HolyCommunionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HolyCommunionEventsTable> {
  $$HolyCommunionEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExpectedAtKcc => $composableBuilder(
    column: $table.totalExpectedAtKcc,
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

  $$AdminUsersTableFilterComposer get createdByAdminId {
    final $$AdminUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<bool> holyCommunionAttendanceRefs(
    Expression<bool> Function($$HolyCommunionAttendanceTableFilterComposer f) f,
  ) {
    final $$HolyCommunionAttendanceTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.holyCommunionAttendance,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionAttendanceTableFilterComposer(
                $db: $db,
                $table: $db.holyCommunionAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HolyCommunionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HolyCommunionEventsTable> {
  $$HolyCommunionEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExpectedAtKcc => $composableBuilder(
    column: $table.totalExpectedAtKcc,
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

  $$AdminUsersTableOrderingComposer get createdByAdminId {
    final $$AdminUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUsersTableOrderingComposer(
            $db: $db,
            $table: $db.adminUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HolyCommunionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolyCommunionEventsTable> {
  $$HolyCommunionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get quarter =>
      $composableBuilder(column: $table.quarter, builder: (column) => column);

  GeneratedColumn<int> get totalExpectedAtKcc => $composableBuilder(
    column: $table.totalExpectedAtKcc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

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

  $$AdminUsersTableAnnotationComposer get createdByAdminId {
    final $$AdminUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<T> holyCommunionAttendanceRefs<T extends Object>(
    Expression<T> Function($$HolyCommunionAttendanceTableAnnotationComposer a)
    f,
  ) {
    final $$HolyCommunionAttendanceTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.holyCommunionAttendance,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionAttendanceTableAnnotationComposer(
                $db: $db,
                $table: $db.holyCommunionAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HolyCommunionEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolyCommunionEventsTable,
          HolyCommunionEvent,
          $$HolyCommunionEventsTableFilterComposer,
          $$HolyCommunionEventsTableOrderingComposer,
          $$HolyCommunionEventsTableAnnotationComposer,
          $$HolyCommunionEventsTableCreateCompanionBuilder,
          $$HolyCommunionEventsTableUpdateCompanionBuilder,
          (HolyCommunionEvent, $$HolyCommunionEventsTableReferences),
          HolyCommunionEvent,
          PrefetchHooks Function({
            bool churchId,
            bool createdByAdminId,
            bool holyCommunionAttendanceRefs,
          })
        > {
  $$HolyCommunionEventsTableTableManager(
    _$AppDatabase db,
    $HolyCommunionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolyCommunionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolyCommunionEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HolyCommunionEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<int?> createdByAdminId = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> quarter = const Value.absent(),
                Value<int> totalExpectedAtKcc = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HolyCommunionEventsCompanion(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                eventDate: eventDate,
                year: year,
                quarter: quarter,
                totalExpectedAtKcc: totalExpectedAtKcc,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                Value<int?> createdByAdminId = const Value.absent(),
                required DateTime eventDate,
                required int year,
                required int quarter,
                Value<int> totalExpectedAtKcc = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => HolyCommunionEventsCompanion.insert(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                eventDate: eventDate,
                year: year,
                quarter: quarter,
                totalExpectedAtKcc: totalExpectedAtKcc,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HolyCommunionEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                churchId = false,
                createdByAdminId = false,
                holyCommunionAttendanceRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (holyCommunionAttendanceRefs) db.holyCommunionAttendance,
                  ],
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
                                        $$HolyCommunionEventsTableReferences
                                            ._churchIdTable(db),
                                    referencedColumn:
                                        $$HolyCommunionEventsTableReferences
                                            ._churchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (createdByAdminId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdByAdminId,
                                    referencedTable:
                                        $$HolyCommunionEventsTableReferences
                                            ._createdByAdminIdTable(db),
                                    referencedColumn:
                                        $$HolyCommunionEventsTableReferences
                                            ._createdByAdminIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (holyCommunionAttendanceRefs)
                        await $_getPrefetchedData<
                          HolyCommunionEvent,
                          $HolyCommunionEventsTable,
                          HolyCommunionAttendanceData
                        >(
                          currentTable: table,
                          referencedTable: $$HolyCommunionEventsTableReferences
                              ._holyCommunionAttendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HolyCommunionEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).holyCommunionAttendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
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

typedef $$HolyCommunionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolyCommunionEventsTable,
      HolyCommunionEvent,
      $$HolyCommunionEventsTableFilterComposer,
      $$HolyCommunionEventsTableOrderingComposer,
      $$HolyCommunionEventsTableAnnotationComposer,
      $$HolyCommunionEventsTableCreateCompanionBuilder,
      $$HolyCommunionEventsTableUpdateCompanionBuilder,
      (HolyCommunionEvent, $$HolyCommunionEventsTableReferences),
      HolyCommunionEvent,
      PrefetchHooks Function({
        bool churchId,
        bool createdByAdminId,
        bool holyCommunionAttendanceRefs,
      })
    >;
typedef $$HolyCommunionAttendanceTableCreateCompanionBuilder =
    HolyCommunionAttendanceCompanion Function({
      Value<int> id,
      required int eventId,
      required int homeChurchId,
      Value<int> actualAttendance,
      Value<int> expectedAtHc,
    });
typedef $$HolyCommunionAttendanceTableUpdateCompanionBuilder =
    HolyCommunionAttendanceCompanion Function({
      Value<int> id,
      Value<int> eventId,
      Value<int> homeChurchId,
      Value<int> actualAttendance,
      Value<int> expectedAtHc,
    });

final class $$HolyCommunionAttendanceTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HolyCommunionAttendanceTable,
          HolyCommunionAttendanceData
        > {
  $$HolyCommunionAttendanceTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HolyCommunionEventsTable _eventIdTable(_$AppDatabase db) =>
      db.holyCommunionEvents.createAlias(
        $_aliasNameGenerator(
          db.holyCommunionAttendance.eventId,
          db.holyCommunionEvents.id,
        ),
      );

  $$HolyCommunionEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$HolyCommunionEventsTableTableManager(
      $_db,
      $_db.holyCommunionEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HomeChurchesTable _homeChurchIdTable(_$AppDatabase db) =>
      db.homeChurches.createAlias(
        $_aliasNameGenerator(
          db.holyCommunionAttendance.homeChurchId,
          db.homeChurches.id,
        ),
      );

  $$HomeChurchesTableProcessedTableManager get homeChurchId {
    final $_column = $_itemColumn<int>('home_church_id')!;

    final manager = $$HomeChurchesTableTableManager(
      $_db,
      $_db.homeChurches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeChurchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HolyCommunionAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $HolyCommunionAttendanceTable> {
  $$HolyCommunionAttendanceTableFilterComposer({
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

  ColumnFilters<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAtHc => $composableBuilder(
    column: $table.expectedAtHc,
    builder: (column) => ColumnFilters(column),
  );

  $$HolyCommunionEventsTableFilterComposer get eventId {
    final $$HolyCommunionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.holyCommunionEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HolyCommunionEventsTableFilterComposer(
            $db: $db,
            $table: $db.holyCommunionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HomeChurchesTableFilterComposer get homeChurchId {
    final $$HomeChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeChurchId,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableFilterComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HolyCommunionAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $HolyCommunionAttendanceTable> {
  $$HolyCommunionAttendanceTableOrderingComposer({
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

  ColumnOrderings<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAtHc => $composableBuilder(
    column: $table.expectedAtHc,
    builder: (column) => ColumnOrderings(column),
  );

  $$HolyCommunionEventsTableOrderingComposer get eventId {
    final $$HolyCommunionEventsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.holyCommunionEvents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionEventsTableOrderingComposer(
                $db: $db,
                $table: $db.holyCommunionEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HomeChurchesTableOrderingComposer get homeChurchId {
    final $$HomeChurchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeChurchId,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableOrderingComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HolyCommunionAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolyCommunionAttendanceTable> {
  $$HolyCommunionAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAtHc => $composableBuilder(
    column: $table.expectedAtHc,
    builder: (column) => column,
  );

  $$HolyCommunionEventsTableAnnotationComposer get eventId {
    final $$HolyCommunionEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.holyCommunionEvents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HolyCommunionEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.holyCommunionEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HomeChurchesTableAnnotationComposer get homeChurchId {
    final $$HomeChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeChurchId,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HolyCommunionAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolyCommunionAttendanceTable,
          HolyCommunionAttendanceData,
          $$HolyCommunionAttendanceTableFilterComposer,
          $$HolyCommunionAttendanceTableOrderingComposer,
          $$HolyCommunionAttendanceTableAnnotationComposer,
          $$HolyCommunionAttendanceTableCreateCompanionBuilder,
          $$HolyCommunionAttendanceTableUpdateCompanionBuilder,
          (
            HolyCommunionAttendanceData,
            $$HolyCommunionAttendanceTableReferences,
          ),
          HolyCommunionAttendanceData,
          PrefetchHooks Function({bool eventId, bool homeChurchId})
        > {
  $$HolyCommunionAttendanceTableTableManager(
    _$AppDatabase db,
    $HolyCommunionAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolyCommunionAttendanceTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HolyCommunionAttendanceTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HolyCommunionAttendanceTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<int> homeChurchId = const Value.absent(),
                Value<int> actualAttendance = const Value.absent(),
                Value<int> expectedAtHc = const Value.absent(),
              }) => HolyCommunionAttendanceCompanion(
                id: id,
                eventId: eventId,
                homeChurchId: homeChurchId,
                actualAttendance: actualAttendance,
                expectedAtHc: expectedAtHc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eventId,
                required int homeChurchId,
                Value<int> actualAttendance = const Value.absent(),
                Value<int> expectedAtHc = const Value.absent(),
              }) => HolyCommunionAttendanceCompanion.insert(
                id: id,
                eventId: eventId,
                homeChurchId: homeChurchId,
                actualAttendance: actualAttendance,
                expectedAtHc: expectedAtHc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HolyCommunionAttendanceTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, homeChurchId = false}) {
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
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable:
                                    $$HolyCommunionAttendanceTableReferences
                                        ._eventIdTable(db),
                                referencedColumn:
                                    $$HolyCommunionAttendanceTableReferences
                                        ._eventIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (homeChurchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.homeChurchId,
                                referencedTable:
                                    $$HolyCommunionAttendanceTableReferences
                                        ._homeChurchIdTable(db),
                                referencedColumn:
                                    $$HolyCommunionAttendanceTableReferences
                                        ._homeChurchIdTable(db)
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

typedef $$HolyCommunionAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolyCommunionAttendanceTable,
      HolyCommunionAttendanceData,
      $$HolyCommunionAttendanceTableFilterComposer,
      $$HolyCommunionAttendanceTableOrderingComposer,
      $$HolyCommunionAttendanceTableAnnotationComposer,
      $$HolyCommunionAttendanceTableCreateCompanionBuilder,
      $$HolyCommunionAttendanceTableUpdateCompanionBuilder,
      (HolyCommunionAttendanceData, $$HolyCommunionAttendanceTableReferences),
      HolyCommunionAttendanceData,
      PrefetchHooks Function({bool eventId, bool homeChurchId})
    >;
typedef $$BusinessMeetingEventsTableCreateCompanionBuilder =
    BusinessMeetingEventsCompanion Function({
      Value<int> id,
      required int churchId,
      Value<int?> createdByAdminId,
      required DateTime eventDate,
      required int year,
      required int quarter,
      Value<int> meetingNumber,
      Value<int> totalExpectedAtKcc,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$BusinessMeetingEventsTableUpdateCompanionBuilder =
    BusinessMeetingEventsCompanion Function({
      Value<int> id,
      Value<int> churchId,
      Value<int?> createdByAdminId,
      Value<DateTime> eventDate,
      Value<int> year,
      Value<int> quarter,
      Value<int> meetingNumber,
      Value<int> totalExpectedAtKcc,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BusinessMeetingEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BusinessMeetingEventsTable,
          BusinessMeetingEvent
        > {
  $$BusinessMeetingEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChurchesTable _churchIdTable(_$AppDatabase db) =>
      db.churches.createAlias(
        $_aliasNameGenerator(db.businessMeetingEvents.churchId, db.churches.id),
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

  static $AdminUsersTable _createdByAdminIdTable(_$AppDatabase db) =>
      db.adminUsers.createAlias(
        $_aliasNameGenerator(
          db.businessMeetingEvents.createdByAdminId,
          db.adminUsers.id,
        ),
      );

  $$AdminUsersTableProcessedTableManager? get createdByAdminId {
    final $_column = $_itemColumn<int>('created_by_admin_id');
    if ($_column == null) return null;
    final manager = $$AdminUsersTableTableManager(
      $_db,
      $_db.adminUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByAdminIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $BusinessMeetingAttendanceTable,
    List<BusinessMeetingAttendanceData>
  >
  _businessMeetingAttendanceRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.businessMeetingAttendance,
        aliasName: $_aliasNameGenerator(
          db.businessMeetingEvents.id,
          db.businessMeetingAttendance.eventId,
        ),
      );

  $$BusinessMeetingAttendanceTableProcessedTableManager
  get businessMeetingAttendanceRefs {
    final manager = $$BusinessMeetingAttendanceTableTableManager(
      $_db,
      $_db.businessMeetingAttendance,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _businessMeetingAttendanceRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BusinessMeetingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessMeetingEventsTable> {
  $$BusinessMeetingEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meetingNumber => $composableBuilder(
    column: $table.meetingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExpectedAtKcc => $composableBuilder(
    column: $table.totalExpectedAtKcc,
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

  $$AdminUsersTableFilterComposer get createdByAdminId {
    final $$AdminUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<bool> businessMeetingAttendanceRefs(
    Expression<bool> Function($$BusinessMeetingAttendanceTableFilterComposer f)
    f,
  ) {
    final $$BusinessMeetingAttendanceTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingAttendance,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingAttendanceTableFilterComposer(
                $db: $db,
                $table: $db.businessMeetingAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BusinessMeetingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessMeetingEventsTable> {
  $$BusinessMeetingEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meetingNumber => $composableBuilder(
    column: $table.meetingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExpectedAtKcc => $composableBuilder(
    column: $table.totalExpectedAtKcc,
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

  $$AdminUsersTableOrderingComposer get createdByAdminId {
    final $$AdminUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUsersTableOrderingComposer(
            $db: $db,
            $table: $db.adminUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BusinessMeetingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessMeetingEventsTable> {
  $$BusinessMeetingEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get quarter =>
      $composableBuilder(column: $table.quarter, builder: (column) => column);

  GeneratedColumn<int> get meetingNumber => $composableBuilder(
    column: $table.meetingNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalExpectedAtKcc => $composableBuilder(
    column: $table.totalExpectedAtKcc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

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

  $$AdminUsersTableAnnotationComposer get createdByAdminId {
    final $$AdminUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByAdminId,
      referencedTable: $db.adminUsers,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<T> businessMeetingAttendanceRefs<T extends Object>(
    Expression<T> Function($$BusinessMeetingAttendanceTableAnnotationComposer a)
    f,
  ) {
    final $$BusinessMeetingAttendanceTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.businessMeetingAttendance,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingAttendanceTableAnnotationComposer(
                $db: $db,
                $table: $db.businessMeetingAttendance,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BusinessMeetingEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessMeetingEventsTable,
          BusinessMeetingEvent,
          $$BusinessMeetingEventsTableFilterComposer,
          $$BusinessMeetingEventsTableOrderingComposer,
          $$BusinessMeetingEventsTableAnnotationComposer,
          $$BusinessMeetingEventsTableCreateCompanionBuilder,
          $$BusinessMeetingEventsTableUpdateCompanionBuilder,
          (BusinessMeetingEvent, $$BusinessMeetingEventsTableReferences),
          BusinessMeetingEvent,
          PrefetchHooks Function({
            bool churchId,
            bool createdByAdminId,
            bool businessMeetingAttendanceRefs,
          })
        > {
  $$BusinessMeetingEventsTableTableManager(
    _$AppDatabase db,
    $BusinessMeetingEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessMeetingEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BusinessMeetingEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BusinessMeetingEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> churchId = const Value.absent(),
                Value<int?> createdByAdminId = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> quarter = const Value.absent(),
                Value<int> meetingNumber = const Value.absent(),
                Value<int> totalExpectedAtKcc = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BusinessMeetingEventsCompanion(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                eventDate: eventDate,
                year: year,
                quarter: quarter,
                meetingNumber: meetingNumber,
                totalExpectedAtKcc: totalExpectedAtKcc,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int churchId,
                Value<int?> createdByAdminId = const Value.absent(),
                required DateTime eventDate,
                required int year,
                required int quarter,
                Value<int> meetingNumber = const Value.absent(),
                Value<int> totalExpectedAtKcc = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => BusinessMeetingEventsCompanion.insert(
                id: id,
                churchId: churchId,
                createdByAdminId: createdByAdminId,
                eventDate: eventDate,
                year: year,
                quarter: quarter,
                meetingNumber: meetingNumber,
                totalExpectedAtKcc: totalExpectedAtKcc,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BusinessMeetingEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                churchId = false,
                createdByAdminId = false,
                businessMeetingAttendanceRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (businessMeetingAttendanceRefs)
                      db.businessMeetingAttendance,
                  ],
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
                                        $$BusinessMeetingEventsTableReferences
                                            ._churchIdTable(db),
                                    referencedColumn:
                                        $$BusinessMeetingEventsTableReferences
                                            ._churchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (createdByAdminId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdByAdminId,
                                    referencedTable:
                                        $$BusinessMeetingEventsTableReferences
                                            ._createdByAdminIdTable(db),
                                    referencedColumn:
                                        $$BusinessMeetingEventsTableReferences
                                            ._createdByAdminIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (businessMeetingAttendanceRefs)
                        await $_getPrefetchedData<
                          BusinessMeetingEvent,
                          $BusinessMeetingEventsTable,
                          BusinessMeetingAttendanceData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$BusinessMeetingEventsTableReferences
                                  ._businessMeetingAttendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessMeetingEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).businessMeetingAttendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
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

typedef $$BusinessMeetingEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessMeetingEventsTable,
      BusinessMeetingEvent,
      $$BusinessMeetingEventsTableFilterComposer,
      $$BusinessMeetingEventsTableOrderingComposer,
      $$BusinessMeetingEventsTableAnnotationComposer,
      $$BusinessMeetingEventsTableCreateCompanionBuilder,
      $$BusinessMeetingEventsTableUpdateCompanionBuilder,
      (BusinessMeetingEvent, $$BusinessMeetingEventsTableReferences),
      BusinessMeetingEvent,
      PrefetchHooks Function({
        bool churchId,
        bool createdByAdminId,
        bool businessMeetingAttendanceRefs,
      })
    >;
typedef $$BusinessMeetingAttendanceTableCreateCompanionBuilder =
    BusinessMeetingAttendanceCompanion Function({
      Value<int> id,
      required int eventId,
      required int homeChurchId,
      Value<int> actualAttendance,
      Value<int> expectedAtHc,
    });
typedef $$BusinessMeetingAttendanceTableUpdateCompanionBuilder =
    BusinessMeetingAttendanceCompanion Function({
      Value<int> id,
      Value<int> eventId,
      Value<int> homeChurchId,
      Value<int> actualAttendance,
      Value<int> expectedAtHc,
    });

final class $$BusinessMeetingAttendanceTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BusinessMeetingAttendanceTable,
          BusinessMeetingAttendanceData
        > {
  $$BusinessMeetingAttendanceTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BusinessMeetingEventsTable _eventIdTable(_$AppDatabase db) =>
      db.businessMeetingEvents.createAlias(
        $_aliasNameGenerator(
          db.businessMeetingAttendance.eventId,
          db.businessMeetingEvents.id,
        ),
      );

  $$BusinessMeetingEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$BusinessMeetingEventsTableTableManager(
      $_db,
      $_db.businessMeetingEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HomeChurchesTable _homeChurchIdTable(_$AppDatabase db) =>
      db.homeChurches.createAlias(
        $_aliasNameGenerator(
          db.businessMeetingAttendance.homeChurchId,
          db.homeChurches.id,
        ),
      );

  $$HomeChurchesTableProcessedTableManager get homeChurchId {
    final $_column = $_itemColumn<int>('home_church_id')!;

    final manager = $$HomeChurchesTableTableManager(
      $_db,
      $_db.homeChurches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeChurchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BusinessMeetingAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessMeetingAttendanceTable> {
  $$BusinessMeetingAttendanceTableFilterComposer({
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

  ColumnFilters<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAtHc => $composableBuilder(
    column: $table.expectedAtHc,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessMeetingEventsTableFilterComposer get eventId {
    final $$BusinessMeetingEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableFilterComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HomeChurchesTableFilterComposer get homeChurchId {
    final $$HomeChurchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeChurchId,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableFilterComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BusinessMeetingAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessMeetingAttendanceTable> {
  $$BusinessMeetingAttendanceTableOrderingComposer({
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

  ColumnOrderings<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAtHc => $composableBuilder(
    column: $table.expectedAtHc,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessMeetingEventsTableOrderingComposer get eventId {
    final $$BusinessMeetingEventsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableOrderingComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HomeChurchesTableOrderingComposer get homeChurchId {
    final $$HomeChurchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeChurchId,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableOrderingComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BusinessMeetingAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessMeetingAttendanceTable> {
  $$BusinessMeetingAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get actualAttendance => $composableBuilder(
    column: $table.actualAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAtHc => $composableBuilder(
    column: $table.expectedAtHc,
    builder: (column) => column,
  );

  $$BusinessMeetingEventsTableAnnotationComposer get eventId {
    final $$BusinessMeetingEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.businessMeetingEvents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BusinessMeetingEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.businessMeetingEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HomeChurchesTableAnnotationComposer get homeChurchId {
    final $$HomeChurchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeChurchId,
      referencedTable: $db.homeChurches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomeChurchesTableAnnotationComposer(
            $db: $db,
            $table: $db.homeChurches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BusinessMeetingAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessMeetingAttendanceTable,
          BusinessMeetingAttendanceData,
          $$BusinessMeetingAttendanceTableFilterComposer,
          $$BusinessMeetingAttendanceTableOrderingComposer,
          $$BusinessMeetingAttendanceTableAnnotationComposer,
          $$BusinessMeetingAttendanceTableCreateCompanionBuilder,
          $$BusinessMeetingAttendanceTableUpdateCompanionBuilder,
          (
            BusinessMeetingAttendanceData,
            $$BusinessMeetingAttendanceTableReferences,
          ),
          BusinessMeetingAttendanceData,
          PrefetchHooks Function({bool eventId, bool homeChurchId})
        > {
  $$BusinessMeetingAttendanceTableTableManager(
    _$AppDatabase db,
    $BusinessMeetingAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessMeetingAttendanceTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BusinessMeetingAttendanceTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BusinessMeetingAttendanceTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<int> homeChurchId = const Value.absent(),
                Value<int> actualAttendance = const Value.absent(),
                Value<int> expectedAtHc = const Value.absent(),
              }) => BusinessMeetingAttendanceCompanion(
                id: id,
                eventId: eventId,
                homeChurchId: homeChurchId,
                actualAttendance: actualAttendance,
                expectedAtHc: expectedAtHc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eventId,
                required int homeChurchId,
                Value<int> actualAttendance = const Value.absent(),
                Value<int> expectedAtHc = const Value.absent(),
              }) => BusinessMeetingAttendanceCompanion.insert(
                id: id,
                eventId: eventId,
                homeChurchId: homeChurchId,
                actualAttendance: actualAttendance,
                expectedAtHc: expectedAtHc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BusinessMeetingAttendanceTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, homeChurchId = false}) {
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
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable:
                                    $$BusinessMeetingAttendanceTableReferences
                                        ._eventIdTable(db),
                                referencedColumn:
                                    $$BusinessMeetingAttendanceTableReferences
                                        ._eventIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (homeChurchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.homeChurchId,
                                referencedTable:
                                    $$BusinessMeetingAttendanceTableReferences
                                        ._homeChurchIdTable(db),
                                referencedColumn:
                                    $$BusinessMeetingAttendanceTableReferences
                                        ._homeChurchIdTable(db)
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

typedef $$BusinessMeetingAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessMeetingAttendanceTable,
      BusinessMeetingAttendanceData,
      $$BusinessMeetingAttendanceTableFilterComposer,
      $$BusinessMeetingAttendanceTableOrderingComposer,
      $$BusinessMeetingAttendanceTableAnnotationComposer,
      $$BusinessMeetingAttendanceTableCreateCompanionBuilder,
      $$BusinessMeetingAttendanceTableUpdateCompanionBuilder,
      (
        BusinessMeetingAttendanceData,
        $$BusinessMeetingAttendanceTableReferences,
      ),
      BusinessMeetingAttendanceData,
      PrefetchHooks Function({bool eventId, bool homeChurchId})
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
  $$HomeChurchesTableTableManager get homeChurches =>
      $$HomeChurchesTableTableManager(_db, _db.homeChurches);
  $$BoardMeetingRecordsTableTableManager get boardMeetingRecords =>
      $$BoardMeetingRecordsTableTableManager(_db, _db.boardMeetingRecords);
  $$HolyCommunionEventsTableTableManager get holyCommunionEvents =>
      $$HolyCommunionEventsTableTableManager(_db, _db.holyCommunionEvents);
  $$HolyCommunionAttendanceTableTableManager get holyCommunionAttendance =>
      $$HolyCommunionAttendanceTableTableManager(
        _db,
        _db.holyCommunionAttendance,
      );
  $$BusinessMeetingEventsTableTableManager get businessMeetingEvents =>
      $$BusinessMeetingEventsTableTableManager(_db, _db.businessMeetingEvents);
  $$BusinessMeetingAttendanceTableTableManager get businessMeetingAttendance =>
      $$BusinessMeetingAttendanceTableTableManager(
        _db,
        _db.businessMeetingAttendance,
      );
}
