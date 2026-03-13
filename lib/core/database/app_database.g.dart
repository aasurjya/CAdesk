// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientsTableTable extends ClientsTable
    with TableInfo<$ClientsTableTable, ClientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
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
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aadhaarHashMeta = const VerificationMeta(
    'aadhaarHash',
  );
  @override
  late final GeneratedColumn<String> aadhaarHash = GeneratedColumn<String>(
    'aadhaar_hash',
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
  static const VerificationMeta _alternatePhoneMeta = const VerificationMeta(
    'alternatePhone',
  );
  @override
  late final GeneratedColumn<String> alternatePhone = GeneratedColumn<String>(
    'alternate_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientTypeMeta = const VerificationMeta(
    'clientType',
  );
  @override
  late final GeneratedColumn<String> clientType = GeneratedColumn<String>(
    'client_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfIncorporationMeta =
      const VerificationMeta('dateOfIncorporation');
  @override
  late final GeneratedColumn<String> dateOfIncorporation =
      GeneratedColumn<String>(
        'date_of_incorporation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tanMeta = const VerificationMeta('tan');
  @override
  late final GeneratedColumn<String> tan = GeneratedColumn<String>(
    'tan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servicesAvailedMeta = const VerificationMeta(
    'servicesAvailed',
  );
  @override
  late final GeneratedColumn<String> servicesAvailed = GeneratedColumn<String>(
    'services_availed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    name,
    pan,
    aadhaarHash,
    email,
    phone,
    alternatePhone,
    clientType,
    dateOfBirth,
    dateOfIncorporation,
    address,
    city,
    state,
    pincode,
    gstin,
    tan,
    servicesAvailed,
    status,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    } else if (isInserting) {
      context.missing(_panMeta);
    }
    if (data.containsKey('aadhaar_hash')) {
      context.handle(
        _aadhaarHashMeta,
        aadhaarHash.isAcceptableOrUnknown(
          data['aadhaar_hash']!,
          _aadhaarHashMeta,
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
    if (data.containsKey('alternate_phone')) {
      context.handle(
        _alternatePhoneMeta,
        alternatePhone.isAcceptableOrUnknown(
          data['alternate_phone']!,
          _alternatePhoneMeta,
        ),
      );
    }
    if (data.containsKey('client_type')) {
      context.handle(
        _clientTypeMeta,
        clientType.isAcceptableOrUnknown(data['client_type']!, _clientTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_clientTypeMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('date_of_incorporation')) {
      context.handle(
        _dateOfIncorporationMeta,
        dateOfIncorporation.isAcceptableOrUnknown(
          data['date_of_incorporation']!,
          _dateOfIncorporationMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('tan')) {
      context.handle(
        _tanMeta,
        tan.isAcceptableOrUnknown(data['tan']!, _tanMeta),
      );
    }
    if (data.containsKey('services_availed')) {
      context.handle(
        _servicesAvailedMeta,
        servicesAvailed.isAcceptableOrUnknown(
          data['services_availed']!,
          _servicesAvailedMeta,
        ),
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
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      )!,
      aadhaarHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aadhaar_hash'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      alternatePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_phone'],
      ),
      clientType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_type'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      dateOfIncorporation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_incorporation'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      tan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tan'],
      ),
      servicesAvailed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}services_availed'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ClientsTableTable createAlias(String alias) {
    return $ClientsTableTable(attachedDatabase, alias);
  }
}

class ClientRow extends DataClass implements Insertable<ClientRow> {
  final String id;
  final String firmId;
  final String name;
  final String pan;
  final String? aadhaarHash;
  final String? email;
  final String? phone;
  final String? alternatePhone;
  final String clientType;
  final String? dateOfBirth;
  final String? dateOfIncorporation;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstin;
  final String? tan;
  final String servicesAvailed;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const ClientRow({
    required this.id,
    required this.firmId,
    required this.name,
    required this.pan,
    this.aadhaarHash,
    this.email,
    this.phone,
    this.alternatePhone,
    required this.clientType,
    this.dateOfBirth,
    this.dateOfIncorporation,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.gstin,
    this.tan,
    required this.servicesAvailed,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['name'] = Variable<String>(name);
    map['pan'] = Variable<String>(pan);
    if (!nullToAbsent || aadhaarHash != null) {
      map['aadhaar_hash'] = Variable<String>(aadhaarHash);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || alternatePhone != null) {
      map['alternate_phone'] = Variable<String>(alternatePhone);
    }
    map['client_type'] = Variable<String>(clientType);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || dateOfIncorporation != null) {
      map['date_of_incorporation'] = Variable<String>(dateOfIncorporation);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || tan != null) {
      map['tan'] = Variable<String>(tan);
    }
    map['services_availed'] = Variable<String>(servicesAvailed);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ClientsTableCompanion toCompanion(bool nullToAbsent) {
    return ClientsTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      name: Value(name),
      pan: Value(pan),
      aadhaarHash: aadhaarHash == null && nullToAbsent
          ? const Value.absent()
          : Value(aadhaarHash),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      alternatePhone: alternatePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(alternatePhone),
      clientType: Value(clientType),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      dateOfIncorporation: dateOfIncorporation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfIncorporation),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      tan: tan == null && nullToAbsent ? const Value.absent() : Value(tan),
      servicesAvailed: Value(servicesAvailed),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory ClientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      name: serializer.fromJson<String>(json['name']),
      pan: serializer.fromJson<String>(json['pan']),
      aadhaarHash: serializer.fromJson<String?>(json['aadhaarHash']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      alternatePhone: serializer.fromJson<String?>(json['alternatePhone']),
      clientType: serializer.fromJson<String>(json['clientType']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      dateOfIncorporation: serializer.fromJson<String?>(
        json['dateOfIncorporation'],
      ),
      address: serializer.fromJson<String?>(json['address']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      tan: serializer.fromJson<String?>(json['tan']),
      servicesAvailed: serializer.fromJson<String>(json['servicesAvailed']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'name': serializer.toJson<String>(name),
      'pan': serializer.toJson<String>(pan),
      'aadhaarHash': serializer.toJson<String?>(aadhaarHash),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'alternatePhone': serializer.toJson<String?>(alternatePhone),
      'clientType': serializer.toJson<String>(clientType),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'dateOfIncorporation': serializer.toJson<String?>(dateOfIncorporation),
      'address': serializer.toJson<String?>(address),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'pincode': serializer.toJson<String?>(pincode),
      'gstin': serializer.toJson<String?>(gstin),
      'tan': serializer.toJson<String?>(tan),
      'servicesAvailed': serializer.toJson<String>(servicesAvailed),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  ClientRow copyWith({
    String? id,
    String? firmId,
    String? name,
    String? pan,
    Value<String?> aadhaarHash = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> alternatePhone = const Value.absent(),
    String? clientType,
    Value<String?> dateOfBirth = const Value.absent(),
    Value<String?> dateOfIncorporation = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> pincode = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> tan = const Value.absent(),
    String? servicesAvailed,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => ClientRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    name: name ?? this.name,
    pan: pan ?? this.pan,
    aadhaarHash: aadhaarHash.present ? aadhaarHash.value : this.aadhaarHash,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    alternatePhone: alternatePhone.present
        ? alternatePhone.value
        : this.alternatePhone,
    clientType: clientType ?? this.clientType,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    dateOfIncorporation: dateOfIncorporation.present
        ? dateOfIncorporation.value
        : this.dateOfIncorporation,
    address: address.present ? address.value : this.address,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    pincode: pincode.present ? pincode.value : this.pincode,
    gstin: gstin.present ? gstin.value : this.gstin,
    tan: tan.present ? tan.value : this.tan,
    servicesAvailed: servicesAvailed ?? this.servicesAvailed,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  ClientRow copyWithCompanion(ClientsTableCompanion data) {
    return ClientRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      name: data.name.present ? data.name.value : this.name,
      pan: data.pan.present ? data.pan.value : this.pan,
      aadhaarHash: data.aadhaarHash.present
          ? data.aadhaarHash.value
          : this.aadhaarHash,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      alternatePhone: data.alternatePhone.present
          ? data.alternatePhone.value
          : this.alternatePhone,
      clientType: data.clientType.present
          ? data.clientType.value
          : this.clientType,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      dateOfIncorporation: data.dateOfIncorporation.present
          ? data.dateOfIncorporation.value
          : this.dateOfIncorporation,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      tan: data.tan.present ? data.tan.value : this.tan,
      servicesAvailed: data.servicesAvailed.present
          ? data.servicesAvailed.value
          : this.servicesAvailed,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('name: $name, ')
          ..write('pan: $pan, ')
          ..write('aadhaarHash: $aadhaarHash, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('clientType: $clientType, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('dateOfIncorporation: $dateOfIncorporation, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('gstin: $gstin, ')
          ..write('tan: $tan, ')
          ..write('servicesAvailed: $servicesAvailed, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    firmId,
    name,
    pan,
    aadhaarHash,
    email,
    phone,
    alternatePhone,
    clientType,
    dateOfBirth,
    dateOfIncorporation,
    address,
    city,
    state,
    pincode,
    gstin,
    tan,
    servicesAvailed,
    status,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.name == this.name &&
          other.pan == this.pan &&
          other.aadhaarHash == this.aadhaarHash &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.alternatePhone == this.alternatePhone &&
          other.clientType == this.clientType &&
          other.dateOfBirth == this.dateOfBirth &&
          other.dateOfIncorporation == this.dateOfIncorporation &&
          other.address == this.address &&
          other.city == this.city &&
          other.state == this.state &&
          other.pincode == this.pincode &&
          other.gstin == this.gstin &&
          other.tan == this.tan &&
          other.servicesAvailed == this.servicesAvailed &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class ClientsTableCompanion extends UpdateCompanion<ClientRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> name;
  final Value<String> pan;
  final Value<String?> aadhaarHash;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> alternatePhone;
  final Value<String> clientType;
  final Value<String?> dateOfBirth;
  final Value<String?> dateOfIncorporation;
  final Value<String?> address;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> pincode;
  final Value<String?> gstin;
  final Value<String?> tan;
  final Value<String> servicesAvailed;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ClientsTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.name = const Value.absent(),
    this.pan = const Value.absent(),
    this.aadhaarHash = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.clientType = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.dateOfIncorporation = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.gstin = const Value.absent(),
    this.tan = const Value.absent(),
    this.servicesAvailed = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String name,
    required String pan,
    this.aadhaarHash = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    required String clientType,
    this.dateOfBirth = const Value.absent(),
    this.dateOfIncorporation = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.gstin = const Value.absent(),
    this.tan = const Value.absent(),
    this.servicesAvailed = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       name = Value(name),
       pan = Value(pan),
       clientType = Value(clientType);
  static Insertable<ClientRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? name,
    Expression<String>? pan,
    Expression<String>? aadhaarHash,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? alternatePhone,
    Expression<String>? clientType,
    Expression<String>? dateOfBirth,
    Expression<String>? dateOfIncorporation,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? pincode,
    Expression<String>? gstin,
    Expression<String>? tan,
    Expression<String>? servicesAvailed,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (name != null) 'name': name,
      if (pan != null) 'pan': pan,
      if (aadhaarHash != null) 'aadhaar_hash': aadhaarHash,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      if (clientType != null) 'client_type': clientType,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (dateOfIncorporation != null)
        'date_of_incorporation': dateOfIncorporation,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (gstin != null) 'gstin': gstin,
      if (tan != null) 'tan': tan,
      if (servicesAvailed != null) 'services_availed': servicesAvailed,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? name,
    Value<String>? pan,
    Value<String?>? aadhaarHash,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? alternatePhone,
    Value<String>? clientType,
    Value<String?>? dateOfBirth,
    Value<String?>? dateOfIncorporation,
    Value<String?>? address,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? pincode,
    Value<String?>? gstin,
    Value<String?>? tan,
    Value<String>? servicesAvailed,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ClientsTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      aadhaarHash: aadhaarHash ?? this.aadhaarHash,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      clientType: clientType ?? this.clientType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfIncorporation: dateOfIncorporation ?? this.dateOfIncorporation,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      gstin: gstin ?? this.gstin,
      tan: tan ?? this.tan,
      servicesAvailed: servicesAvailed ?? this.servicesAvailed,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (aadhaarHash.present) {
      map['aadhaar_hash'] = Variable<String>(aadhaarHash.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (alternatePhone.present) {
      map['alternate_phone'] = Variable<String>(alternatePhone.value);
    }
    if (clientType.present) {
      map['client_type'] = Variable<String>(clientType.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (dateOfIncorporation.present) {
      map['date_of_incorporation'] = Variable<String>(
        dateOfIncorporation.value,
      );
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (tan.present) {
      map['tan'] = Variable<String>(tan.value);
    }
    if (servicesAvailed.present) {
      map['services_availed'] = Variable<String>(servicesAvailed.value);
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
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('name: $name, ')
          ..write('pan: $pan, ')
          ..write('aadhaarHash: $aadhaarHash, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('clientType: $clientType, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('dateOfIncorporation: $dateOfIncorporation, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('gstin: $gstin, ')
          ..write('tan: $tan, ')
          ..write('servicesAvailed: $servicesAvailed, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _syncUuid.v4(),
  );
  static const VerificationMeta _sourceTableMeta = const VerificationMeta(
    'sourceTable',
  );
  @override
  late final GeneratedColumn<String> sourceTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
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
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceTable,
    recordId,
    operation,
    payload,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _sourceTableMeta,
        sourceTable.isAcceptableOrUnknown(
          data['table_name']!,
          _sourceTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final String id;
  final String sourceTable;
  final String recordId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const SyncQueueRow({
    required this.id,
    required this.sourceTable,
    required this.recordId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(sourceTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      sourceTable: Value(sourceTable),
      recordId: Value(recordId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<String>(json['id']),
      sourceTable: serializer.fromJson<String>(json['sourceTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceTable': serializer.toJson<String>(sourceTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueRow copyWith({
    String? id,
    String? sourceTable,
    String? recordId,
    String? operation,
    String? payload,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueRow(
    id: id ?? this.id,
    sourceTable: sourceTable ?? this.sourceTable,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueRow copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      sourceTable: data.sourceTable.present
          ? data.sourceTable.value
          : this.sourceTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('sourceTable: $sourceTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceTable,
    recordId,
    operation,
    payload,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.sourceTable == this.sourceTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<String> id;
  final Value<String> sourceTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.sourceTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String sourceTable,
    required String recordId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceTable = Value(sourceTable),
       recordId = Value(recordId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueRow> custom({
    Expression<String>? id,
    Expression<String>? sourceTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceTable != null) 'table_name': sourceTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceTable,
    Value<String>? recordId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      sourceTable: sourceTable ?? this.sourceTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceTable.present) {
      map['table_name'] = Variable<String>(sourceTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('sourceTable: $sourceTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTableTable extends SyncConflictsTable
    with TableInfo<$SyncConflictsTableTable, SyncConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _syncUuid.v4(),
  );
  static const VerificationMeta _sourceTableMeta = const VerificationMeta(
    'sourceTable',
  );
  @override
  late final GeneratedColumn<String> sourceTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadMeta = const VerificationMeta(
    'localPayload',
  );
  @override
  late final GeneratedColumn<String> localPayload = GeneratedColumn<String>(
    'local_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverPayloadMeta = const VerificationMeta(
    'serverPayload',
  );
  @override
  late final GeneratedColumn<String> serverPayload = GeneratedColumn<String>(
    'server_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceTable,
    recordId,
    localPayload,
    serverPayload,
    detectedAt,
    resolvedAt,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _sourceTableMeta,
        sourceTable.isAcceptableOrUnknown(
          data['table_name']!,
          _sourceTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('local_payload')) {
      context.handle(
        _localPayloadMeta,
        localPayload.isAcceptableOrUnknown(
          data['local_payload']!,
          _localPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadMeta);
    }
    if (data.containsKey('server_payload')) {
      context.handle(
        _serverPayloadMeta,
        serverPayload.isAcceptableOrUnknown(
          data['server_payload']!,
          _serverPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverPayloadMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      localPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload'],
      )!,
      serverPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_payload'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $SyncConflictsTableTable createAlias(String alias) {
    return $SyncConflictsTableTable(attachedDatabase, alias);
  }
}

class SyncConflictRow extends DataClass implements Insertable<SyncConflictRow> {
  final String id;
  final String sourceTable;
  final String recordId;
  final String localPayload;
  final String serverPayload;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolution;
  const SyncConflictRow({
    required this.id,
    required this.sourceTable,
    required this.recordId,
    required this.localPayload,
    required this.serverPayload,
    required this.detectedAt,
    this.resolvedAt,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(sourceTable);
    map['record_id'] = Variable<String>(recordId);
    map['local_payload'] = Variable<String>(localPayload);
    map['server_payload'] = Variable<String>(serverPayload);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  SyncConflictsTableCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsTableCompanion(
      id: Value(id),
      sourceTable: Value(sourceTable),
      recordId: Value(recordId),
      localPayload: Value(localPayload),
      serverPayload: Value(serverPayload),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory SyncConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRow(
      id: serializer.fromJson<String>(json['id']),
      sourceTable: serializer.fromJson<String>(json['sourceTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      localPayload: serializer.fromJson<String>(json['localPayload']),
      serverPayload: serializer.fromJson<String>(json['serverPayload']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceTable': serializer.toJson<String>(sourceTable),
      'recordId': serializer.toJson<String>(recordId),
      'localPayload': serializer.toJson<String>(localPayload),
      'serverPayload': serializer.toJson<String>(serverPayload),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  SyncConflictRow copyWith({
    String? id,
    String? sourceTable,
    String? recordId,
    String? localPayload,
    String? serverPayload,
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => SyncConflictRow(
    id: id ?? this.id,
    sourceTable: sourceTable ?? this.sourceTable,
    recordId: recordId ?? this.recordId,
    localPayload: localPayload ?? this.localPayload,
    serverPayload: serverPayload ?? this.serverPayload,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  SyncConflictRow copyWithCompanion(SyncConflictsTableCompanion data) {
    return SyncConflictRow(
      id: data.id.present ? data.id.value : this.id,
      sourceTable: data.sourceTable.present
          ? data.sourceTable.value
          : this.sourceTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      localPayload: data.localPayload.present
          ? data.localPayload.value
          : this.localPayload,
      serverPayload: data.serverPayload.present
          ? data.serverPayload.value
          : this.serverPayload,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRow(')
          ..write('id: $id, ')
          ..write('sourceTable: $sourceTable, ')
          ..write('recordId: $recordId, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverPayload: $serverPayload, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceTable,
    recordId,
    localPayload,
    serverPayload,
    detectedAt,
    resolvedAt,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRow &&
          other.id == this.id &&
          other.sourceTable == this.sourceTable &&
          other.recordId == this.recordId &&
          other.localPayload == this.localPayload &&
          other.serverPayload == this.serverPayload &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolution == this.resolution);
}

class SyncConflictsTableCompanion extends UpdateCompanion<SyncConflictRow> {
  final Value<String> id;
  final Value<String> sourceTable;
  final Value<String> recordId;
  final Value<String> localPayload;
  final Value<String> serverPayload;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolution;
  final Value<int> rowid;
  const SyncConflictsTableCompanion({
    this.id = const Value.absent(),
    this.sourceTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.localPayload = const Value.absent(),
    this.serverPayload = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sourceTable,
    required String recordId,
    required String localPayload,
    required String serverPayload,
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceTable = Value(sourceTable),
       recordId = Value(recordId),
       localPayload = Value(localPayload),
       serverPayload = Value(serverPayload);
  static Insertable<SyncConflictRow> custom({
    Expression<String>? id,
    Expression<String>? sourceTable,
    Expression<String>? recordId,
    Expression<String>? localPayload,
    Expression<String>? serverPayload,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolution,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceTable != null) 'table_name': sourceTable,
      if (recordId != null) 'record_id': recordId,
      if (localPayload != null) 'local_payload': localPayload,
      if (serverPayload != null) 'server_payload': serverPayload,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolution != null) 'resolution': resolution,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceTable,
    Value<String>? recordId,
    Value<String>? localPayload,
    Value<String>? serverPayload,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolution,
    Value<int>? rowid,
  }) {
    return SyncConflictsTableCompanion(
      id: id ?? this.id,
      sourceTable: sourceTable ?? this.sourceTable,
      recordId: recordId ?? this.recordId,
      localPayload: localPayload ?? this.localPayload,
      serverPayload: serverPayload ?? this.serverPayload,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceTable.present) {
      map['table_name'] = Variable<String>(sourceTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (localPayload.present) {
      map['local_payload'] = Variable<String>(localPayload.value);
    }
    if (serverPayload.present) {
      map['server_payload'] = Variable<String>(serverPayload.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsTableCompanion(')
          ..write('id: $id, ')
          ..write('sourceTable: $sourceTable, ')
          ..write('recordId: $recordId, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverPayload: $serverPayload, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItrFilingsTableTable extends ItrFilingsTable
    with TableInfo<$ItrFilingsTableTable, ItrFilingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItrFilingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
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
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aadhaarMeta = const VerificationMeta(
    'aadhaar',
  );
  @override
  late final GeneratedColumn<String> aadhaar = GeneratedColumn<String>(
    'aadhaar',
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
  static const VerificationMeta _itrTypeMeta = const VerificationMeta(
    'itrType',
  );
  @override
  late final GeneratedColumn<String> itrType = GeneratedColumn<String>(
    'itr_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentYearMeta = const VerificationMeta(
    'assessmentYear',
  );
  @override
  late final GeneratedColumn<String> assessmentYear = GeneratedColumn<String>(
    'assessment_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _financialYearMeta = const VerificationMeta(
    'financialYear',
  );
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
    'financial_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filingStatusMeta = const VerificationMeta(
    'filingStatus',
  );
  @override
  late final GeneratedColumn<String> filingStatus = GeneratedColumn<String>(
    'filing_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _totalIncomeMeta = const VerificationMeta(
    'totalIncome',
  );
  @override
  late final GeneratedColumn<double> totalIncome = GeneratedColumn<double>(
    'total_income',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxPayableMeta = const VerificationMeta(
    'taxPayable',
  );
  @override
  late final GeneratedColumn<double> taxPayable = GeneratedColumn<double>(
    'tax_payable',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refundDueMeta = const VerificationMeta(
    'refundDue',
  );
  @override
  late final GeneratedColumn<double> refundDue = GeneratedColumn<double>(
    'refund_due',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tdsAmountMeta = const VerificationMeta(
    'tdsAmount',
  );
  @override
  late final GeneratedColumn<double> tdsAmount = GeneratedColumn<double>(
    'tds_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _advanceTaxMeta = const VerificationMeta(
    'advanceTax',
  );
  @override
  late final GeneratedColumn<double> advanceTax = GeneratedColumn<double>(
    'advance_tax',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selfAssessmentTaxMeta = const VerificationMeta(
    'selfAssessmentTax',
  );
  @override
  late final GeneratedColumn<double> selfAssessmentTax =
      GeneratedColumn<double>(
        'self_assessment_tax',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _acknowledgementNumberMeta =
      const VerificationMeta('acknowledgementNumber');
  @override
  late final GeneratedColumn<String> acknowledgementNumber =
      GeneratedColumn<String>(
        'acknowledgement_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _filedDateMeta = const VerificationMeta(
    'filedDate',
  );
  @override
  late final GeneratedColumn<String> filedDate = GeneratedColumn<String>(
    'filed_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedDateMeta = const VerificationMeta(
    'verifiedDate',
  );
  @override
  late final GeneratedColumn<String> verifiedDate = GeneratedColumn<String>(
    'verified_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    name,
    pan,
    aadhaar,
    email,
    phone,
    itrType,
    assessmentYear,
    financialYear,
    filingStatus,
    totalIncome,
    taxPayable,
    refundDue,
    tdsAmount,
    advanceTax,
    selfAssessmentTax,
    acknowledgementNumber,
    filedDate,
    verifiedDate,
    dueDate,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_itr_filings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItrFilingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
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
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    } else if (isInserting) {
      context.missing(_panMeta);
    }
    if (data.containsKey('aadhaar')) {
      context.handle(
        _aadhaarMeta,
        aadhaar.isAcceptableOrUnknown(data['aadhaar']!, _aadhaarMeta),
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
    if (data.containsKey('itr_type')) {
      context.handle(
        _itrTypeMeta,
        itrType.isAcceptableOrUnknown(data['itr_type']!, _itrTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itrTypeMeta);
    }
    if (data.containsKey('assessment_year')) {
      context.handle(
        _assessmentYearMeta,
        assessmentYear.isAcceptableOrUnknown(
          data['assessment_year']!,
          _assessmentYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentYearMeta);
    }
    if (data.containsKey('financial_year')) {
      context.handle(
        _financialYearMeta,
        financialYear.isAcceptableOrUnknown(
          data['financial_year']!,
          _financialYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialYearMeta);
    }
    if (data.containsKey('filing_status')) {
      context.handle(
        _filingStatusMeta,
        filingStatus.isAcceptableOrUnknown(
          data['filing_status']!,
          _filingStatusMeta,
        ),
      );
    }
    if (data.containsKey('total_income')) {
      context.handle(
        _totalIncomeMeta,
        totalIncome.isAcceptableOrUnknown(
          data['total_income']!,
          _totalIncomeMeta,
        ),
      );
    }
    if (data.containsKey('tax_payable')) {
      context.handle(
        _taxPayableMeta,
        taxPayable.isAcceptableOrUnknown(data['tax_payable']!, _taxPayableMeta),
      );
    }
    if (data.containsKey('refund_due')) {
      context.handle(
        _refundDueMeta,
        refundDue.isAcceptableOrUnknown(data['refund_due']!, _refundDueMeta),
      );
    }
    if (data.containsKey('tds_amount')) {
      context.handle(
        _tdsAmountMeta,
        tdsAmount.isAcceptableOrUnknown(data['tds_amount']!, _tdsAmountMeta),
      );
    }
    if (data.containsKey('advance_tax')) {
      context.handle(
        _advanceTaxMeta,
        advanceTax.isAcceptableOrUnknown(data['advance_tax']!, _advanceTaxMeta),
      );
    }
    if (data.containsKey('self_assessment_tax')) {
      context.handle(
        _selfAssessmentTaxMeta,
        selfAssessmentTax.isAcceptableOrUnknown(
          data['self_assessment_tax']!,
          _selfAssessmentTaxMeta,
        ),
      );
    }
    if (data.containsKey('acknowledgement_number')) {
      context.handle(
        _acknowledgementNumberMeta,
        acknowledgementNumber.isAcceptableOrUnknown(
          data['acknowledgement_number']!,
          _acknowledgementNumberMeta,
        ),
      );
    }
    if (data.containsKey('filed_date')) {
      context.handle(
        _filedDateMeta,
        filedDate.isAcceptableOrUnknown(data['filed_date']!, _filedDateMeta),
      );
    }
    if (data.containsKey('verified_date')) {
      context.handle(
        _verifiedDateMeta,
        verifiedDate.isAcceptableOrUnknown(
          data['verified_date']!,
          _verifiedDateMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
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
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItrFilingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItrFilingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      )!,
      aadhaar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aadhaar'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      itrType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itr_type'],
      )!,
      assessmentYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_year'],
      )!,
      financialYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_year'],
      )!,
      filingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filing_status'],
      )!,
      totalIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_income'],
      ),
      taxPayable: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_payable'],
      ),
      refundDue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}refund_due'],
      ),
      tdsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tds_amount'],
      ),
      advanceTax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}advance_tax'],
      ),
      selfAssessmentTax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}self_assessment_tax'],
      ),
      acknowledgementNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}acknowledgement_number'],
      ),
      filedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filed_date'],
      ),
      verifiedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verified_date'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
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
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ItrFilingsTableTable createAlias(String alias) {
    return $ItrFilingsTableTable(attachedDatabase, alias);
  }
}

class ItrFilingRow extends DataClass implements Insertable<ItrFilingRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String name;
  final String pan;
  final String? aadhaar;
  final String? email;
  final String? phone;
  final String itrType;
  final String assessmentYear;
  final String financialYear;
  final String filingStatus;
  final double? totalIncome;
  final double? taxPayable;
  final double? refundDue;
  final double? tdsAmount;
  final double? advanceTax;
  final double? selfAssessmentTax;
  final String? acknowledgementNumber;
  final String? filedDate;
  final String? verifiedDate;
  final String? dueDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const ItrFilingRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    required this.name,
    required this.pan,
    this.aadhaar,
    this.email,
    this.phone,
    required this.itrType,
    required this.assessmentYear,
    required this.financialYear,
    required this.filingStatus,
    this.totalIncome,
    this.taxPayable,
    this.refundDue,
    this.tdsAmount,
    this.advanceTax,
    this.selfAssessmentTax,
    this.acknowledgementNumber,
    this.filedDate,
    this.verifiedDate,
    this.dueDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    map['name'] = Variable<String>(name);
    map['pan'] = Variable<String>(pan);
    if (!nullToAbsent || aadhaar != null) {
      map['aadhaar'] = Variable<String>(aadhaar);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['itr_type'] = Variable<String>(itrType);
    map['assessment_year'] = Variable<String>(assessmentYear);
    map['financial_year'] = Variable<String>(financialYear);
    map['filing_status'] = Variable<String>(filingStatus);
    if (!nullToAbsent || totalIncome != null) {
      map['total_income'] = Variable<double>(totalIncome);
    }
    if (!nullToAbsent || taxPayable != null) {
      map['tax_payable'] = Variable<double>(taxPayable);
    }
    if (!nullToAbsent || refundDue != null) {
      map['refund_due'] = Variable<double>(refundDue);
    }
    if (!nullToAbsent || tdsAmount != null) {
      map['tds_amount'] = Variable<double>(tdsAmount);
    }
    if (!nullToAbsent || advanceTax != null) {
      map['advance_tax'] = Variable<double>(advanceTax);
    }
    if (!nullToAbsent || selfAssessmentTax != null) {
      map['self_assessment_tax'] = Variable<double>(selfAssessmentTax);
    }
    if (!nullToAbsent || acknowledgementNumber != null) {
      map['acknowledgement_number'] = Variable<String>(acknowledgementNumber);
    }
    if (!nullToAbsent || filedDate != null) {
      map['filed_date'] = Variable<String>(filedDate);
    }
    if (!nullToAbsent || verifiedDate != null) {
      map['verified_date'] = Variable<String>(verifiedDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ItrFilingsTableCompanion toCompanion(bool nullToAbsent) {
    return ItrFilingsTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      name: Value(name),
      pan: Value(pan),
      aadhaar: aadhaar == null && nullToAbsent
          ? const Value.absent()
          : Value(aadhaar),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      itrType: Value(itrType),
      assessmentYear: Value(assessmentYear),
      financialYear: Value(financialYear),
      filingStatus: Value(filingStatus),
      totalIncome: totalIncome == null && nullToAbsent
          ? const Value.absent()
          : Value(totalIncome),
      taxPayable: taxPayable == null && nullToAbsent
          ? const Value.absent()
          : Value(taxPayable),
      refundDue: refundDue == null && nullToAbsent
          ? const Value.absent()
          : Value(refundDue),
      tdsAmount: tdsAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(tdsAmount),
      advanceTax: advanceTax == null && nullToAbsent
          ? const Value.absent()
          : Value(advanceTax),
      selfAssessmentTax: selfAssessmentTax == null && nullToAbsent
          ? const Value.absent()
          : Value(selfAssessmentTax),
      acknowledgementNumber: acknowledgementNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgementNumber),
      filedDate: filedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(filedDate),
      verifiedDate: verifiedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory ItrFilingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItrFilingRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      pan: serializer.fromJson<String>(json['pan']),
      aadhaar: serializer.fromJson<String?>(json['aadhaar']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      itrType: serializer.fromJson<String>(json['itrType']),
      assessmentYear: serializer.fromJson<String>(json['assessmentYear']),
      financialYear: serializer.fromJson<String>(json['financialYear']),
      filingStatus: serializer.fromJson<String>(json['filingStatus']),
      totalIncome: serializer.fromJson<double?>(json['totalIncome']),
      taxPayable: serializer.fromJson<double?>(json['taxPayable']),
      refundDue: serializer.fromJson<double?>(json['refundDue']),
      tdsAmount: serializer.fromJson<double?>(json['tdsAmount']),
      advanceTax: serializer.fromJson<double?>(json['advanceTax']),
      selfAssessmentTax: serializer.fromJson<double?>(
        json['selfAssessmentTax'],
      ),
      acknowledgementNumber: serializer.fromJson<String?>(
        json['acknowledgementNumber'],
      ),
      filedDate: serializer.fromJson<String?>(json['filedDate']),
      verifiedDate: serializer.fromJson<String?>(json['verifiedDate']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'name': serializer.toJson<String>(name),
      'pan': serializer.toJson<String>(pan),
      'aadhaar': serializer.toJson<String?>(aadhaar),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'itrType': serializer.toJson<String>(itrType),
      'assessmentYear': serializer.toJson<String>(assessmentYear),
      'financialYear': serializer.toJson<String>(financialYear),
      'filingStatus': serializer.toJson<String>(filingStatus),
      'totalIncome': serializer.toJson<double?>(totalIncome),
      'taxPayable': serializer.toJson<double?>(taxPayable),
      'refundDue': serializer.toJson<double?>(refundDue),
      'tdsAmount': serializer.toJson<double?>(tdsAmount),
      'advanceTax': serializer.toJson<double?>(advanceTax),
      'selfAssessmentTax': serializer.toJson<double?>(selfAssessmentTax),
      'acknowledgementNumber': serializer.toJson<String?>(
        acknowledgementNumber,
      ),
      'filedDate': serializer.toJson<String?>(filedDate),
      'verifiedDate': serializer.toJson<String?>(verifiedDate),
      'dueDate': serializer.toJson<String?>(dueDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  ItrFilingRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    String? name,
    String? pan,
    Value<String?> aadhaar = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? itrType,
    String? assessmentYear,
    String? financialYear,
    String? filingStatus,
    Value<double?> totalIncome = const Value.absent(),
    Value<double?> taxPayable = const Value.absent(),
    Value<double?> refundDue = const Value.absent(),
    Value<double?> tdsAmount = const Value.absent(),
    Value<double?> advanceTax = const Value.absent(),
    Value<double?> selfAssessmentTax = const Value.absent(),
    Value<String?> acknowledgementNumber = const Value.absent(),
    Value<String?> filedDate = const Value.absent(),
    Value<String?> verifiedDate = const Value.absent(),
    Value<String?> dueDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => ItrFilingRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    name: name ?? this.name,
    pan: pan ?? this.pan,
    aadhaar: aadhaar.present ? aadhaar.value : this.aadhaar,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    itrType: itrType ?? this.itrType,
    assessmentYear: assessmentYear ?? this.assessmentYear,
    financialYear: financialYear ?? this.financialYear,
    filingStatus: filingStatus ?? this.filingStatus,
    totalIncome: totalIncome.present ? totalIncome.value : this.totalIncome,
    taxPayable: taxPayable.present ? taxPayable.value : this.taxPayable,
    refundDue: refundDue.present ? refundDue.value : this.refundDue,
    tdsAmount: tdsAmount.present ? tdsAmount.value : this.tdsAmount,
    advanceTax: advanceTax.present ? advanceTax.value : this.advanceTax,
    selfAssessmentTax: selfAssessmentTax.present
        ? selfAssessmentTax.value
        : this.selfAssessmentTax,
    acknowledgementNumber: acknowledgementNumber.present
        ? acknowledgementNumber.value
        : this.acknowledgementNumber,
    filedDate: filedDate.present ? filedDate.value : this.filedDate,
    verifiedDate: verifiedDate.present ? verifiedDate.value : this.verifiedDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  ItrFilingRow copyWithCompanion(ItrFilingsTableCompanion data) {
    return ItrFilingRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      pan: data.pan.present ? data.pan.value : this.pan,
      aadhaar: data.aadhaar.present ? data.aadhaar.value : this.aadhaar,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      itrType: data.itrType.present ? data.itrType.value : this.itrType,
      assessmentYear: data.assessmentYear.present
          ? data.assessmentYear.value
          : this.assessmentYear,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      filingStatus: data.filingStatus.present
          ? data.filingStatus.value
          : this.filingStatus,
      totalIncome: data.totalIncome.present
          ? data.totalIncome.value
          : this.totalIncome,
      taxPayable: data.taxPayable.present
          ? data.taxPayable.value
          : this.taxPayable,
      refundDue: data.refundDue.present ? data.refundDue.value : this.refundDue,
      tdsAmount: data.tdsAmount.present ? data.tdsAmount.value : this.tdsAmount,
      advanceTax: data.advanceTax.present
          ? data.advanceTax.value
          : this.advanceTax,
      selfAssessmentTax: data.selfAssessmentTax.present
          ? data.selfAssessmentTax.value
          : this.selfAssessmentTax,
      acknowledgementNumber: data.acknowledgementNumber.present
          ? data.acknowledgementNumber.value
          : this.acknowledgementNumber,
      filedDate: data.filedDate.present ? data.filedDate.value : this.filedDate,
      verifiedDate: data.verifiedDate.present
          ? data.verifiedDate.value
          : this.verifiedDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItrFilingRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('pan: $pan, ')
          ..write('aadhaar: $aadhaar, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('itrType: $itrType, ')
          ..write('assessmentYear: $assessmentYear, ')
          ..write('financialYear: $financialYear, ')
          ..write('filingStatus: $filingStatus, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('taxPayable: $taxPayable, ')
          ..write('refundDue: $refundDue, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('advanceTax: $advanceTax, ')
          ..write('selfAssessmentTax: $selfAssessmentTax, ')
          ..write('acknowledgementNumber: $acknowledgementNumber, ')
          ..write('filedDate: $filedDate, ')
          ..write('verifiedDate: $verifiedDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    firmId,
    clientId,
    name,
    pan,
    aadhaar,
    email,
    phone,
    itrType,
    assessmentYear,
    financialYear,
    filingStatus,
    totalIncome,
    taxPayable,
    refundDue,
    tdsAmount,
    advanceTax,
    selfAssessmentTax,
    acknowledgementNumber,
    filedDate,
    verifiedDate,
    dueDate,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItrFilingRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.pan == this.pan &&
          other.aadhaar == this.aadhaar &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.itrType == this.itrType &&
          other.assessmentYear == this.assessmentYear &&
          other.financialYear == this.financialYear &&
          other.filingStatus == this.filingStatus &&
          other.totalIncome == this.totalIncome &&
          other.taxPayable == this.taxPayable &&
          other.refundDue == this.refundDue &&
          other.tdsAmount == this.tdsAmount &&
          other.advanceTax == this.advanceTax &&
          other.selfAssessmentTax == this.selfAssessmentTax &&
          other.acknowledgementNumber == this.acknowledgementNumber &&
          other.filedDate == this.filedDate &&
          other.verifiedDate == this.verifiedDate &&
          other.dueDate == this.dueDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class ItrFilingsTableCompanion extends UpdateCompanion<ItrFilingRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String> name;
  final Value<String> pan;
  final Value<String?> aadhaar;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> itrType;
  final Value<String> assessmentYear;
  final Value<String> financialYear;
  final Value<String> filingStatus;
  final Value<double?> totalIncome;
  final Value<double?> taxPayable;
  final Value<double?> refundDue;
  final Value<double?> tdsAmount;
  final Value<double?> advanceTax;
  final Value<double?> selfAssessmentTax;
  final Value<String?> acknowledgementNumber;
  final Value<String?> filedDate;
  final Value<String?> verifiedDate;
  final Value<String?> dueDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ItrFilingsTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.pan = const Value.absent(),
    this.aadhaar = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.itrType = const Value.absent(),
    this.assessmentYear = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.filingStatus = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.taxPayable = const Value.absent(),
    this.refundDue = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.advanceTax = const Value.absent(),
    this.selfAssessmentTax = const Value.absent(),
    this.acknowledgementNumber = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.verifiedDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItrFilingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    required String name,
    required String pan,
    this.aadhaar = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String itrType,
    required String assessmentYear,
    required String financialYear,
    this.filingStatus = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.taxPayable = const Value.absent(),
    this.refundDue = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.advanceTax = const Value.absent(),
    this.selfAssessmentTax = const Value.absent(),
    this.acknowledgementNumber = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.verifiedDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       name = Value(name),
       pan = Value(pan),
       itrType = Value(itrType),
       assessmentYear = Value(assessmentYear),
       financialYear = Value(financialYear);
  static Insertable<ItrFilingRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? pan,
    Expression<String>? aadhaar,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? itrType,
    Expression<String>? assessmentYear,
    Expression<String>? financialYear,
    Expression<String>? filingStatus,
    Expression<double>? totalIncome,
    Expression<double>? taxPayable,
    Expression<double>? refundDue,
    Expression<double>? tdsAmount,
    Expression<double>? advanceTax,
    Expression<double>? selfAssessmentTax,
    Expression<String>? acknowledgementNumber,
    Expression<String>? filedDate,
    Expression<String>? verifiedDate,
    Expression<String>? dueDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (pan != null) 'pan': pan,
      if (aadhaar != null) 'aadhaar': aadhaar,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (itrType != null) 'itr_type': itrType,
      if (assessmentYear != null) 'assessment_year': assessmentYear,
      if (financialYear != null) 'financial_year': financialYear,
      if (filingStatus != null) 'filing_status': filingStatus,
      if (totalIncome != null) 'total_income': totalIncome,
      if (taxPayable != null) 'tax_payable': taxPayable,
      if (refundDue != null) 'refund_due': refundDue,
      if (tdsAmount != null) 'tds_amount': tdsAmount,
      if (advanceTax != null) 'advance_tax': advanceTax,
      if (selfAssessmentTax != null) 'self_assessment_tax': selfAssessmentTax,
      if (acknowledgementNumber != null)
        'acknowledgement_number': acknowledgementNumber,
      if (filedDate != null) 'filed_date': filedDate,
      if (verifiedDate != null) 'verified_date': verifiedDate,
      if (dueDate != null) 'due_date': dueDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItrFilingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String>? name,
    Value<String>? pan,
    Value<String?>? aadhaar,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? itrType,
    Value<String>? assessmentYear,
    Value<String>? financialYear,
    Value<String>? filingStatus,
    Value<double?>? totalIncome,
    Value<double?>? taxPayable,
    Value<double?>? refundDue,
    Value<double?>? tdsAmount,
    Value<double?>? advanceTax,
    Value<double?>? selfAssessmentTax,
    Value<String?>? acknowledgementNumber,
    Value<String?>? filedDate,
    Value<String?>? verifiedDate,
    Value<String?>? dueDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ItrFilingsTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      aadhaar: aadhaar ?? this.aadhaar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      itrType: itrType ?? this.itrType,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      financialYear: financialYear ?? this.financialYear,
      filingStatus: filingStatus ?? this.filingStatus,
      totalIncome: totalIncome ?? this.totalIncome,
      taxPayable: taxPayable ?? this.taxPayable,
      refundDue: refundDue ?? this.refundDue,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      advanceTax: advanceTax ?? this.advanceTax,
      selfAssessmentTax: selfAssessmentTax ?? this.selfAssessmentTax,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      filedDate: filedDate ?? this.filedDate,
      verifiedDate: verifiedDate ?? this.verifiedDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (aadhaar.present) {
      map['aadhaar'] = Variable<String>(aadhaar.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (itrType.present) {
      map['itr_type'] = Variable<String>(itrType.value);
    }
    if (assessmentYear.present) {
      map['assessment_year'] = Variable<String>(assessmentYear.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (filingStatus.present) {
      map['filing_status'] = Variable<String>(filingStatus.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (taxPayable.present) {
      map['tax_payable'] = Variable<double>(taxPayable.value);
    }
    if (refundDue.present) {
      map['refund_due'] = Variable<double>(refundDue.value);
    }
    if (tdsAmount.present) {
      map['tds_amount'] = Variable<double>(tdsAmount.value);
    }
    if (advanceTax.present) {
      map['advance_tax'] = Variable<double>(advanceTax.value);
    }
    if (selfAssessmentTax.present) {
      map['self_assessment_tax'] = Variable<double>(selfAssessmentTax.value);
    }
    if (acknowledgementNumber.present) {
      map['acknowledgement_number'] = Variable<String>(
        acknowledgementNumber.value,
      );
    }
    if (filedDate.present) {
      map['filed_date'] = Variable<String>(filedDate.value);
    }
    if (verifiedDate.present) {
      map['verified_date'] = Variable<String>(verifiedDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
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
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItrFilingsTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('pan: $pan, ')
          ..write('aadhaar: $aadhaar, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('itrType: $itrType, ')
          ..write('assessmentYear: $assessmentYear, ')
          ..write('financialYear: $financialYear, ')
          ..write('filingStatus: $filingStatus, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('taxPayable: $taxPayable, ')
          ..write('refundDue: $refundDue, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('advanceTax: $advanceTax, ')
          ..write('selfAssessmentTax: $selfAssessmentTax, ')
          ..write('acknowledgementNumber: $acknowledgementNumber, ')
          ..write('filedDate: $filedDate, ')
          ..write('verifiedDate: $verifiedDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GstClientsTableTable extends GstClientsTable
    with TableInfo<$GstClientsTableTable, GstClientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GstClientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeNameMeta = const VerificationMeta(
    'tradeName',
  );
  @override
  late final GeneratedColumn<String> tradeName = GeneratedColumn<String>(
    'trade_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationTypeMeta = const VerificationMeta(
    'registrationType',
  );
  @override
  late final GeneratedColumn<String> registrationType = GeneratedColumn<String>(
    'registration_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
    'state_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnsPendingMeta = const VerificationMeta(
    'returnsPending',
  );
  @override
  late final GeneratedColumn<String> returnsPending = GeneratedColumn<String>(
    'returns_pending',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _lastFiledDateMeta = const VerificationMeta(
    'lastFiledDate',
  );
  @override
  late final GeneratedColumn<String> lastFiledDate = GeneratedColumn<String>(
    'last_filed_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _complianceScoreMeta = const VerificationMeta(
    'complianceScore',
  );
  @override
  late final GeneratedColumn<int> complianceScore = GeneratedColumn<int>(
    'compliance_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
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
  static const VerificationMeta _registrationDateMeta = const VerificationMeta(
    'registrationDate',
  );
  @override
  late final GeneratedColumn<String> registrationDate = GeneratedColumn<String>(
    'registration_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancellationDateMeta = const VerificationMeta(
    'cancellationDate',
  );
  @override
  late final GeneratedColumn<String> cancellationDate = GeneratedColumn<String>(
    'cancellation_date',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    businessName,
    tradeName,
    gstin,
    pan,
    registrationType,
    state,
    stateCode,
    returnsPending,
    lastFiledDate,
    complianceScore,
    isActive,
    registrationDate,
    cancellationDate,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_gst_clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<GstClientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessNameMeta);
    }
    if (data.containsKey('trade_name')) {
      context.handle(
        _tradeNameMeta,
        tradeName.isAcceptableOrUnknown(data['trade_name']!, _tradeNameMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    } else if (isInserting) {
      context.missing(_gstinMeta);
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    } else if (isInserting) {
      context.missing(_panMeta);
    }
    if (data.containsKey('registration_type')) {
      context.handle(
        _registrationTypeMeta,
        registrationType.isAcceptableOrUnknown(
          data['registration_type']!,
          _registrationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationTypeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_stateCodeMeta);
    }
    if (data.containsKey('returns_pending')) {
      context.handle(
        _returnsPendingMeta,
        returnsPending.isAcceptableOrUnknown(
          data['returns_pending']!,
          _returnsPendingMeta,
        ),
      );
    }
    if (data.containsKey('last_filed_date')) {
      context.handle(
        _lastFiledDateMeta,
        lastFiledDate.isAcceptableOrUnknown(
          data['last_filed_date']!,
          _lastFiledDateMeta,
        ),
      );
    }
    if (data.containsKey('compliance_score')) {
      context.handle(
        _complianceScoreMeta,
        complianceScore.isAcceptableOrUnknown(
          data['compliance_score']!,
          _complianceScoreMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('registration_date')) {
      context.handle(
        _registrationDateMeta,
        registrationDate.isAcceptableOrUnknown(
          data['registration_date']!,
          _registrationDateMeta,
        ),
      );
    }
    if (data.containsKey('cancellation_date')) {
      context.handle(
        _cancellationDateMeta,
        cancellationDate.isAcceptableOrUnknown(
          data['cancellation_date']!,
          _cancellationDateMeta,
        ),
      );
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GstClientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GstClientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      tradeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_name'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      )!,
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      )!,
      registrationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_type'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_code'],
      )!,
      returnsPending: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}returns_pending'],
      )!,
      lastFiledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_filed_date'],
      ),
      complianceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compliance_score'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      registrationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_date'],
      ),
      cancellationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancellation_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $GstClientsTableTable createAlias(String alias) {
    return $GstClientsTableTable(attachedDatabase, alias);
  }
}

class GstClientRow extends DataClass implements Insertable<GstClientRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String businessName;
  final String? tradeName;
  final String gstin;
  final String pan;
  final String registrationType;
  final String state;
  final String stateCode;
  final String returnsPending;
  final String? lastFiledDate;
  final int complianceScore;
  final bool isActive;
  final String? registrationDate;
  final String? cancellationDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const GstClientRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    required this.businessName,
    this.tradeName,
    required this.gstin,
    required this.pan,
    required this.registrationType,
    required this.state,
    required this.stateCode,
    required this.returnsPending,
    this.lastFiledDate,
    required this.complianceScore,
    required this.isActive,
    this.registrationDate,
    this.cancellationDate,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    map['business_name'] = Variable<String>(businessName);
    if (!nullToAbsent || tradeName != null) {
      map['trade_name'] = Variable<String>(tradeName);
    }
    map['gstin'] = Variable<String>(gstin);
    map['pan'] = Variable<String>(pan);
    map['registration_type'] = Variable<String>(registrationType);
    map['state'] = Variable<String>(state);
    map['state_code'] = Variable<String>(stateCode);
    map['returns_pending'] = Variable<String>(returnsPending);
    if (!nullToAbsent || lastFiledDate != null) {
      map['last_filed_date'] = Variable<String>(lastFiledDate);
    }
    map['compliance_score'] = Variable<int>(complianceScore);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || registrationDate != null) {
      map['registration_date'] = Variable<String>(registrationDate);
    }
    if (!nullToAbsent || cancellationDate != null) {
      map['cancellation_date'] = Variable<String>(cancellationDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  GstClientsTableCompanion toCompanion(bool nullToAbsent) {
    return GstClientsTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      businessName: Value(businessName),
      tradeName: tradeName == null && nullToAbsent
          ? const Value.absent()
          : Value(tradeName),
      gstin: Value(gstin),
      pan: Value(pan),
      registrationType: Value(registrationType),
      state: Value(state),
      stateCode: Value(stateCode),
      returnsPending: Value(returnsPending),
      lastFiledDate: lastFiledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFiledDate),
      complianceScore: Value(complianceScore),
      isActive: Value(isActive),
      registrationDate: registrationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationDate),
      cancellationDate: cancellationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellationDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory GstClientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GstClientRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      businessName: serializer.fromJson<String>(json['businessName']),
      tradeName: serializer.fromJson<String?>(json['tradeName']),
      gstin: serializer.fromJson<String>(json['gstin']),
      pan: serializer.fromJson<String>(json['pan']),
      registrationType: serializer.fromJson<String>(json['registrationType']),
      state: serializer.fromJson<String>(json['state']),
      stateCode: serializer.fromJson<String>(json['stateCode']),
      returnsPending: serializer.fromJson<String>(json['returnsPending']),
      lastFiledDate: serializer.fromJson<String?>(json['lastFiledDate']),
      complianceScore: serializer.fromJson<int>(json['complianceScore']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      registrationDate: serializer.fromJson<String?>(json['registrationDate']),
      cancellationDate: serializer.fromJson<String?>(json['cancellationDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'businessName': serializer.toJson<String>(businessName),
      'tradeName': serializer.toJson<String?>(tradeName),
      'gstin': serializer.toJson<String>(gstin),
      'pan': serializer.toJson<String>(pan),
      'registrationType': serializer.toJson<String>(registrationType),
      'state': serializer.toJson<String>(state),
      'stateCode': serializer.toJson<String>(stateCode),
      'returnsPending': serializer.toJson<String>(returnsPending),
      'lastFiledDate': serializer.toJson<String?>(lastFiledDate),
      'complianceScore': serializer.toJson<int>(complianceScore),
      'isActive': serializer.toJson<bool>(isActive),
      'registrationDate': serializer.toJson<String?>(registrationDate),
      'cancellationDate': serializer.toJson<String?>(cancellationDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  GstClientRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    String? businessName,
    Value<String?> tradeName = const Value.absent(),
    String? gstin,
    String? pan,
    String? registrationType,
    String? state,
    String? stateCode,
    String? returnsPending,
    Value<String?> lastFiledDate = const Value.absent(),
    int? complianceScore,
    bool? isActive,
    Value<String?> registrationDate = const Value.absent(),
    Value<String?> cancellationDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => GstClientRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    businessName: businessName ?? this.businessName,
    tradeName: tradeName.present ? tradeName.value : this.tradeName,
    gstin: gstin ?? this.gstin,
    pan: pan ?? this.pan,
    registrationType: registrationType ?? this.registrationType,
    state: state ?? this.state,
    stateCode: stateCode ?? this.stateCode,
    returnsPending: returnsPending ?? this.returnsPending,
    lastFiledDate: lastFiledDate.present
        ? lastFiledDate.value
        : this.lastFiledDate,
    complianceScore: complianceScore ?? this.complianceScore,
    isActive: isActive ?? this.isActive,
    registrationDate: registrationDate.present
        ? registrationDate.value
        : this.registrationDate,
    cancellationDate: cancellationDate.present
        ? cancellationDate.value
        : this.cancellationDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  GstClientRow copyWithCompanion(GstClientsTableCompanion data) {
    return GstClientRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      tradeName: data.tradeName.present ? data.tradeName.value : this.tradeName,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      pan: data.pan.present ? data.pan.value : this.pan,
      registrationType: data.registrationType.present
          ? data.registrationType.value
          : this.registrationType,
      state: data.state.present ? data.state.value : this.state,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      returnsPending: data.returnsPending.present
          ? data.returnsPending.value
          : this.returnsPending,
      lastFiledDate: data.lastFiledDate.present
          ? data.lastFiledDate.value
          : this.lastFiledDate,
      complianceScore: data.complianceScore.present
          ? data.complianceScore.value
          : this.complianceScore,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      registrationDate: data.registrationDate.present
          ? data.registrationDate.value
          : this.registrationDate,
      cancellationDate: data.cancellationDate.present
          ? data.cancellationDate.value
          : this.cancellationDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GstClientRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('businessName: $businessName, ')
          ..write('tradeName: $tradeName, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('registrationType: $registrationType, ')
          ..write('state: $state, ')
          ..write('stateCode: $stateCode, ')
          ..write('returnsPending: $returnsPending, ')
          ..write('lastFiledDate: $lastFiledDate, ')
          ..write('complianceScore: $complianceScore, ')
          ..write('isActive: $isActive, ')
          ..write('registrationDate: $registrationDate, ')
          ..write('cancellationDate: $cancellationDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firmId,
    clientId,
    businessName,
    tradeName,
    gstin,
    pan,
    registrationType,
    state,
    stateCode,
    returnsPending,
    lastFiledDate,
    complianceScore,
    isActive,
    registrationDate,
    cancellationDate,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GstClientRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.businessName == this.businessName &&
          other.tradeName == this.tradeName &&
          other.gstin == this.gstin &&
          other.pan == this.pan &&
          other.registrationType == this.registrationType &&
          other.state == this.state &&
          other.stateCode == this.stateCode &&
          other.returnsPending == this.returnsPending &&
          other.lastFiledDate == this.lastFiledDate &&
          other.complianceScore == this.complianceScore &&
          other.isActive == this.isActive &&
          other.registrationDate == this.registrationDate &&
          other.cancellationDate == this.cancellationDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class GstClientsTableCompanion extends UpdateCompanion<GstClientRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String> businessName;
  final Value<String?> tradeName;
  final Value<String> gstin;
  final Value<String> pan;
  final Value<String> registrationType;
  final Value<String> state;
  final Value<String> stateCode;
  final Value<String> returnsPending;
  final Value<String?> lastFiledDate;
  final Value<int> complianceScore;
  final Value<bool> isActive;
  final Value<String?> registrationDate;
  final Value<String?> cancellationDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const GstClientsTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.businessName = const Value.absent(),
    this.tradeName = const Value.absent(),
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.registrationType = const Value.absent(),
    this.state = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.returnsPending = const Value.absent(),
    this.lastFiledDate = const Value.absent(),
    this.complianceScore = const Value.absent(),
    this.isActive = const Value.absent(),
    this.registrationDate = const Value.absent(),
    this.cancellationDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GstClientsTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    required String businessName,
    this.tradeName = const Value.absent(),
    required String gstin,
    required String pan,
    required String registrationType,
    required String state,
    required String stateCode,
    this.returnsPending = const Value.absent(),
    this.lastFiledDate = const Value.absent(),
    this.complianceScore = const Value.absent(),
    this.isActive = const Value.absent(),
    this.registrationDate = const Value.absent(),
    this.cancellationDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       businessName = Value(businessName),
       gstin = Value(gstin),
       pan = Value(pan),
       registrationType = Value(registrationType),
       state = Value(state),
       stateCode = Value(stateCode);
  static Insertable<GstClientRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? businessName,
    Expression<String>? tradeName,
    Expression<String>? gstin,
    Expression<String>? pan,
    Expression<String>? registrationType,
    Expression<String>? state,
    Expression<String>? stateCode,
    Expression<String>? returnsPending,
    Expression<String>? lastFiledDate,
    Expression<int>? complianceScore,
    Expression<bool>? isActive,
    Expression<String>? registrationDate,
    Expression<String>? cancellationDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (businessName != null) 'business_name': businessName,
      if (tradeName != null) 'trade_name': tradeName,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      if (registrationType != null) 'registration_type': registrationType,
      if (state != null) 'state': state,
      if (stateCode != null) 'state_code': stateCode,
      if (returnsPending != null) 'returns_pending': returnsPending,
      if (lastFiledDate != null) 'last_filed_date': lastFiledDate,
      if (complianceScore != null) 'compliance_score': complianceScore,
      if (isActive != null) 'is_active': isActive,
      if (registrationDate != null) 'registration_date': registrationDate,
      if (cancellationDate != null) 'cancellation_date': cancellationDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GstClientsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String>? businessName,
    Value<String?>? tradeName,
    Value<String>? gstin,
    Value<String>? pan,
    Value<String>? registrationType,
    Value<String>? state,
    Value<String>? stateCode,
    Value<String>? returnsPending,
    Value<String?>? lastFiledDate,
    Value<int>? complianceScore,
    Value<bool>? isActive,
    Value<String?>? registrationDate,
    Value<String?>? cancellationDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return GstClientsTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      businessName: businessName ?? this.businessName,
      tradeName: tradeName ?? this.tradeName,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      registrationType: registrationType ?? this.registrationType,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      returnsPending: returnsPending ?? this.returnsPending,
      lastFiledDate: lastFiledDate ?? this.lastFiledDate,
      complianceScore: complianceScore ?? this.complianceScore,
      isActive: isActive ?? this.isActive,
      registrationDate: registrationDate ?? this.registrationDate,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (tradeName.present) {
      map['trade_name'] = Variable<String>(tradeName.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (registrationType.present) {
      map['registration_type'] = Variable<String>(registrationType.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (returnsPending.present) {
      map['returns_pending'] = Variable<String>(returnsPending.value);
    }
    if (lastFiledDate.present) {
      map['last_filed_date'] = Variable<String>(lastFiledDate.value);
    }
    if (complianceScore.present) {
      map['compliance_score'] = Variable<int>(complianceScore.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (registrationDate.present) {
      map['registration_date'] = Variable<String>(registrationDate.value);
    }
    if (cancellationDate.present) {
      map['cancellation_date'] = Variable<String>(cancellationDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GstClientsTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('businessName: $businessName, ')
          ..write('tradeName: $tradeName, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('registrationType: $registrationType, ')
          ..write('state: $state, ')
          ..write('stateCode: $stateCode, ')
          ..write('returnsPending: $returnsPending, ')
          ..write('lastFiledDate: $lastFiledDate, ')
          ..write('complianceScore: $complianceScore, ')
          ..write('isActive: $isActive, ')
          ..write('registrationDate: $registrationDate, ')
          ..write('cancellationDate: $cancellationDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GstReturnsTableTable extends GstReturnsTable
    with TableInfo<$GstReturnsTableTable, GstReturnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GstReturnsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnTypeMeta = const VerificationMeta(
    'returnType',
  );
  @override
  late final GeneratedColumn<String> returnType = GeneratedColumn<String>(
    'return_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMonthMeta = const VerificationMeta(
    'periodMonth',
  );
  @override
  late final GeneratedColumn<int> periodMonth = GeneratedColumn<int>(
    'period_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodYearMeta = const VerificationMeta(
    'periodYear',
  );
  @override
  late final GeneratedColumn<int> periodYear = GeneratedColumn<int>(
    'period_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filedDateMeta = const VerificationMeta(
    'filedDate',
  );
  @override
  late final GeneratedColumn<String> filedDate = GeneratedColumn<String>(
    'filed_date',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _taxableValueMeta = const VerificationMeta(
    'taxableValue',
  );
  @override
  late final GeneratedColumn<double> taxableValue = GeneratedColumn<double>(
    'taxable_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstMeta = const VerificationMeta('igst');
  @override
  late final GeneratedColumn<double> igst = GeneratedColumn<double>(
    'igst',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cgstMeta = const VerificationMeta('cgst');
  @override
  late final GeneratedColumn<double> cgst = GeneratedColumn<double>(
    'cgst',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstMeta = const VerificationMeta('sgst');
  @override
  late final GeneratedColumn<double> sgst = GeneratedColumn<double>(
    'sgst',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessMeta = const VerificationMeta('cess');
  @override
  late final GeneratedColumn<double> cess = GeneratedColumn<double>(
    'cess',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lateFeeMeta = const VerificationMeta(
    'lateFee',
  );
  @override
  late final GeneratedColumn<double> lateFee = GeneratedColumn<double>(
    'late_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _itcClaimedMeta = const VerificationMeta(
    'itcClaimed',
  );
  @override
  late final GeneratedColumn<double> itcClaimed = GeneratedColumn<double>(
    'itc_claimed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    gstin,
    returnType,
    periodMonth,
    periodYear,
    dueDate,
    filedDate,
    status,
    taxableValue,
    igst,
    cgst,
    sgst,
    cess,
    lateFee,
    itcClaimed,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_gst_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<GstReturnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    } else if (isInserting) {
      context.missing(_gstinMeta);
    }
    if (data.containsKey('return_type')) {
      context.handle(
        _returnTypeMeta,
        returnType.isAcceptableOrUnknown(data['return_type']!, _returnTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_returnTypeMeta);
    }
    if (data.containsKey('period_month')) {
      context.handle(
        _periodMonthMeta,
        periodMonth.isAcceptableOrUnknown(
          data['period_month']!,
          _periodMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    if (data.containsKey('period_year')) {
      context.handle(
        _periodYearMeta,
        periodYear.isAcceptableOrUnknown(data['period_year']!, _periodYearMeta),
      );
    } else if (isInserting) {
      context.missing(_periodYearMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('filed_date')) {
      context.handle(
        _filedDateMeta,
        filedDate.isAcceptableOrUnknown(data['filed_date']!, _filedDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('taxable_value')) {
      context.handle(
        _taxableValueMeta,
        taxableValue.isAcceptableOrUnknown(
          data['taxable_value']!,
          _taxableValueMeta,
        ),
      );
    }
    if (data.containsKey('igst')) {
      context.handle(
        _igstMeta,
        igst.isAcceptableOrUnknown(data['igst']!, _igstMeta),
      );
    }
    if (data.containsKey('cgst')) {
      context.handle(
        _cgstMeta,
        cgst.isAcceptableOrUnknown(data['cgst']!, _cgstMeta),
      );
    }
    if (data.containsKey('sgst')) {
      context.handle(
        _sgstMeta,
        sgst.isAcceptableOrUnknown(data['sgst']!, _sgstMeta),
      );
    }
    if (data.containsKey('cess')) {
      context.handle(
        _cessMeta,
        cess.isAcceptableOrUnknown(data['cess']!, _cessMeta),
      );
    }
    if (data.containsKey('late_fee')) {
      context.handle(
        _lateFeeMeta,
        lateFee.isAcceptableOrUnknown(data['late_fee']!, _lateFeeMeta),
      );
    }
    if (data.containsKey('itc_claimed')) {
      context.handle(
        _itcClaimedMeta,
        itcClaimed.isAcceptableOrUnknown(data['itc_claimed']!, _itcClaimedMeta),
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
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GstReturnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GstReturnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      )!,
      returnType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_type'],
      )!,
      periodMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_month'],
      )!,
      periodYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_year'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      filedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filed_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      taxableValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxable_value'],
      )!,
      igst: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst'],
      )!,
      cgst: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst'],
      )!,
      sgst: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst'],
      )!,
      cess: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess'],
      )!,
      lateFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}late_fee'],
      )!,
      itcClaimed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}itc_claimed'],
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
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $GstReturnsTableTable createAlias(String alias) {
    return $GstReturnsTableTable(attachedDatabase, alias);
  }
}

class GstReturnRow extends DataClass implements Insertable<GstReturnRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String gstin;
  final String returnType;
  final int periodMonth;
  final int periodYear;
  final String? dueDate;
  final String? filedDate;
  final String status;
  final double taxableValue;
  final double igst;
  final double cgst;
  final double sgst;
  final double cess;
  final double lateFee;
  final double itcClaimed;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const GstReturnRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    required this.gstin,
    required this.returnType,
    required this.periodMonth,
    required this.periodYear,
    this.dueDate,
    this.filedDate,
    required this.status,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
    required this.lateFee,
    required this.itcClaimed,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    map['gstin'] = Variable<String>(gstin);
    map['return_type'] = Variable<String>(returnType);
    map['period_month'] = Variable<int>(periodMonth);
    map['period_year'] = Variable<int>(periodYear);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || filedDate != null) {
      map['filed_date'] = Variable<String>(filedDate);
    }
    map['status'] = Variable<String>(status);
    map['taxable_value'] = Variable<double>(taxableValue);
    map['igst'] = Variable<double>(igst);
    map['cgst'] = Variable<double>(cgst);
    map['sgst'] = Variable<double>(sgst);
    map['cess'] = Variable<double>(cess);
    map['late_fee'] = Variable<double>(lateFee);
    map['itc_claimed'] = Variable<double>(itcClaimed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  GstReturnsTableCompanion toCompanion(bool nullToAbsent) {
    return GstReturnsTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      gstin: Value(gstin),
      returnType: Value(returnType),
      periodMonth: Value(periodMonth),
      periodYear: Value(periodYear),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      filedDate: filedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(filedDate),
      status: Value(status),
      taxableValue: Value(taxableValue),
      igst: Value(igst),
      cgst: Value(cgst),
      sgst: Value(sgst),
      cess: Value(cess),
      lateFee: Value(lateFee),
      itcClaimed: Value(itcClaimed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory GstReturnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GstReturnRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      gstin: serializer.fromJson<String>(json['gstin']),
      returnType: serializer.fromJson<String>(json['returnType']),
      periodMonth: serializer.fromJson<int>(json['periodMonth']),
      periodYear: serializer.fromJson<int>(json['periodYear']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      filedDate: serializer.fromJson<String?>(json['filedDate']),
      status: serializer.fromJson<String>(json['status']),
      taxableValue: serializer.fromJson<double>(json['taxableValue']),
      igst: serializer.fromJson<double>(json['igst']),
      cgst: serializer.fromJson<double>(json['cgst']),
      sgst: serializer.fromJson<double>(json['sgst']),
      cess: serializer.fromJson<double>(json['cess']),
      lateFee: serializer.fromJson<double>(json['lateFee']),
      itcClaimed: serializer.fromJson<double>(json['itcClaimed']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'gstin': serializer.toJson<String>(gstin),
      'returnType': serializer.toJson<String>(returnType),
      'periodMonth': serializer.toJson<int>(periodMonth),
      'periodYear': serializer.toJson<int>(periodYear),
      'dueDate': serializer.toJson<String?>(dueDate),
      'filedDate': serializer.toJson<String?>(filedDate),
      'status': serializer.toJson<String>(status),
      'taxableValue': serializer.toJson<double>(taxableValue),
      'igst': serializer.toJson<double>(igst),
      'cgst': serializer.toJson<double>(cgst),
      'sgst': serializer.toJson<double>(sgst),
      'cess': serializer.toJson<double>(cess),
      'lateFee': serializer.toJson<double>(lateFee),
      'itcClaimed': serializer.toJson<double>(itcClaimed),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  GstReturnRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    String? gstin,
    String? returnType,
    int? periodMonth,
    int? periodYear,
    Value<String?> dueDate = const Value.absent(),
    Value<String?> filedDate = const Value.absent(),
    String? status,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? lateFee,
    double? itcClaimed,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => GstReturnRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    gstin: gstin ?? this.gstin,
    returnType: returnType ?? this.returnType,
    periodMonth: periodMonth ?? this.periodMonth,
    periodYear: periodYear ?? this.periodYear,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    filedDate: filedDate.present ? filedDate.value : this.filedDate,
    status: status ?? this.status,
    taxableValue: taxableValue ?? this.taxableValue,
    igst: igst ?? this.igst,
    cgst: cgst ?? this.cgst,
    sgst: sgst ?? this.sgst,
    cess: cess ?? this.cess,
    lateFee: lateFee ?? this.lateFee,
    itcClaimed: itcClaimed ?? this.itcClaimed,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  GstReturnRow copyWithCompanion(GstReturnsTableCompanion data) {
    return GstReturnRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      returnType: data.returnType.present
          ? data.returnType.value
          : this.returnType,
      periodMonth: data.periodMonth.present
          ? data.periodMonth.value
          : this.periodMonth,
      periodYear: data.periodYear.present
          ? data.periodYear.value
          : this.periodYear,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      filedDate: data.filedDate.present ? data.filedDate.value : this.filedDate,
      status: data.status.present ? data.status.value : this.status,
      taxableValue: data.taxableValue.present
          ? data.taxableValue.value
          : this.taxableValue,
      igst: data.igst.present ? data.igst.value : this.igst,
      cgst: data.cgst.present ? data.cgst.value : this.cgst,
      sgst: data.sgst.present ? data.sgst.value : this.sgst,
      cess: data.cess.present ? data.cess.value : this.cess,
      lateFee: data.lateFee.present ? data.lateFee.value : this.lateFee,
      itcClaimed: data.itcClaimed.present
          ? data.itcClaimed.value
          : this.itcClaimed,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GstReturnRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('gstin: $gstin, ')
          ..write('returnType: $returnType, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodYear: $periodYear, ')
          ..write('dueDate: $dueDate, ')
          ..write('filedDate: $filedDate, ')
          ..write('status: $status, ')
          ..write('taxableValue: $taxableValue, ')
          ..write('igst: $igst, ')
          ..write('cgst: $cgst, ')
          ..write('sgst: $sgst, ')
          ..write('cess: $cess, ')
          ..write('lateFee: $lateFee, ')
          ..write('itcClaimed: $itcClaimed, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    firmId,
    clientId,
    gstin,
    returnType,
    periodMonth,
    periodYear,
    dueDate,
    filedDate,
    status,
    taxableValue,
    igst,
    cgst,
    sgst,
    cess,
    lateFee,
    itcClaimed,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GstReturnRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.gstin == this.gstin &&
          other.returnType == this.returnType &&
          other.periodMonth == this.periodMonth &&
          other.periodYear == this.periodYear &&
          other.dueDate == this.dueDate &&
          other.filedDate == this.filedDate &&
          other.status == this.status &&
          other.taxableValue == this.taxableValue &&
          other.igst == this.igst &&
          other.cgst == this.cgst &&
          other.sgst == this.sgst &&
          other.cess == this.cess &&
          other.lateFee == this.lateFee &&
          other.itcClaimed == this.itcClaimed &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class GstReturnsTableCompanion extends UpdateCompanion<GstReturnRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String> gstin;
  final Value<String> returnType;
  final Value<int> periodMonth;
  final Value<int> periodYear;
  final Value<String?> dueDate;
  final Value<String?> filedDate;
  final Value<String> status;
  final Value<double> taxableValue;
  final Value<double> igst;
  final Value<double> cgst;
  final Value<double> sgst;
  final Value<double> cess;
  final Value<double> lateFee;
  final Value<double> itcClaimed;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const GstReturnsTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.gstin = const Value.absent(),
    this.returnType = const Value.absent(),
    this.periodMonth = const Value.absent(),
    this.periodYear = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.taxableValue = const Value.absent(),
    this.igst = const Value.absent(),
    this.cgst = const Value.absent(),
    this.sgst = const Value.absent(),
    this.cess = const Value.absent(),
    this.lateFee = const Value.absent(),
    this.itcClaimed = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GstReturnsTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    required String gstin,
    required String returnType,
    required int periodMonth,
    required int periodYear,
    this.dueDate = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.taxableValue = const Value.absent(),
    this.igst = const Value.absent(),
    this.cgst = const Value.absent(),
    this.sgst = const Value.absent(),
    this.cess = const Value.absent(),
    this.lateFee = const Value.absent(),
    this.itcClaimed = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       gstin = Value(gstin),
       returnType = Value(returnType),
       periodMonth = Value(periodMonth),
       periodYear = Value(periodYear);
  static Insertable<GstReturnRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? gstin,
    Expression<String>? returnType,
    Expression<int>? periodMonth,
    Expression<int>? periodYear,
    Expression<String>? dueDate,
    Expression<String>? filedDate,
    Expression<String>? status,
    Expression<double>? taxableValue,
    Expression<double>? igst,
    Expression<double>? cgst,
    Expression<double>? sgst,
    Expression<double>? cess,
    Expression<double>? lateFee,
    Expression<double>? itcClaimed,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (gstin != null) 'gstin': gstin,
      if (returnType != null) 'return_type': returnType,
      if (periodMonth != null) 'period_month': periodMonth,
      if (periodYear != null) 'period_year': periodYear,
      if (dueDate != null) 'due_date': dueDate,
      if (filedDate != null) 'filed_date': filedDate,
      if (status != null) 'status': status,
      if (taxableValue != null) 'taxable_value': taxableValue,
      if (igst != null) 'igst': igst,
      if (cgst != null) 'cgst': cgst,
      if (sgst != null) 'sgst': sgst,
      if (cess != null) 'cess': cess,
      if (lateFee != null) 'late_fee': lateFee,
      if (itcClaimed != null) 'itc_claimed': itcClaimed,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GstReturnsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String>? gstin,
    Value<String>? returnType,
    Value<int>? periodMonth,
    Value<int>? periodYear,
    Value<String?>? dueDate,
    Value<String?>? filedDate,
    Value<String>? status,
    Value<double>? taxableValue,
    Value<double>? igst,
    Value<double>? cgst,
    Value<double>? sgst,
    Value<double>? cess,
    Value<double>? lateFee,
    Value<double>? itcClaimed,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return GstReturnsTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      gstin: gstin ?? this.gstin,
      returnType: returnType ?? this.returnType,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      lateFee: lateFee ?? this.lateFee,
      itcClaimed: itcClaimed ?? this.itcClaimed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (returnType.present) {
      map['return_type'] = Variable<String>(returnType.value);
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<int>(periodMonth.value);
    }
    if (periodYear.present) {
      map['period_year'] = Variable<int>(periodYear.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (filedDate.present) {
      map['filed_date'] = Variable<String>(filedDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (taxableValue.present) {
      map['taxable_value'] = Variable<double>(taxableValue.value);
    }
    if (igst.present) {
      map['igst'] = Variable<double>(igst.value);
    }
    if (cgst.present) {
      map['cgst'] = Variable<double>(cgst.value);
    }
    if (sgst.present) {
      map['sgst'] = Variable<double>(sgst.value);
    }
    if (cess.present) {
      map['cess'] = Variable<double>(cess.value);
    }
    if (lateFee.present) {
      map['late_fee'] = Variable<double>(lateFee.value);
    }
    if (itcClaimed.present) {
      map['itc_claimed'] = Variable<double>(itcClaimed.value);
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
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GstReturnsTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('gstin: $gstin, ')
          ..write('returnType: $returnType, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodYear: $periodYear, ')
          ..write('dueDate: $dueDate, ')
          ..write('filedDate: $filedDate, ')
          ..write('status: $status, ')
          ..write('taxableValue: $taxableValue, ')
          ..write('igst: $igst, ')
          ..write('cgst: $cgst, ')
          ..write('sgst: $sgst, ')
          ..write('cess: $cess, ')
          ..write('lateFee: $lateFee, ')
          ..write('itcClaimed: $itcClaimed, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TdsReturnsTableTable extends TdsReturnsTable
    with TableInfo<$TdsReturnsTableTable, TdsReturnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TdsReturnsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deductorIdMeta = const VerificationMeta(
    'deductorId',
  );
  @override
  late final GeneratedColumn<String> deductorId = GeneratedColumn<String>(
    'deductor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanMeta = const VerificationMeta('tan');
  @override
  late final GeneratedColumn<String> tan = GeneratedColumn<String>(
    'tan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formTypeMeta = const VerificationMeta(
    'formType',
  );
  @override
  late final GeneratedColumn<String> formType = GeneratedColumn<String>(
    'form_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quarterMeta = const VerificationMeta(
    'quarter',
  );
  @override
  late final GeneratedColumn<String> quarter = GeneratedColumn<String>(
    'quarter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _financialYearMeta = const VerificationMeta(
    'financialYear',
  );
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
    'financial_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filedDateMeta = const VerificationMeta(
    'filedDate',
  );
  @override
  late final GeneratedColumn<String> filedDate = GeneratedColumn<String>(
    'filed_date',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _totalDeductionsMeta = const VerificationMeta(
    'totalDeductions',
  );
  @override
  late final GeneratedColumn<double> totalDeductions = GeneratedColumn<double>(
    'total_deductions',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalTaxDeductedMeta = const VerificationMeta(
    'totalTaxDeducted',
  );
  @override
  late final GeneratedColumn<double> totalTaxDeducted = GeneratedColumn<double>(
    'total_tax_deducted',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalDepositedMeta = const VerificationMeta(
    'totalDeposited',
  );
  @override
  late final GeneratedColumn<double> totalDeposited = GeneratedColumn<double>(
    'total_deposited',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lateFeeMeta = const VerificationMeta(
    'lateFee',
  );
  @override
  late final GeneratedColumn<double> lateFee = GeneratedColumn<double>(
    'late_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tokenNumberMeta = const VerificationMeta(
    'tokenNumber',
  );
  @override
  late final GeneratedColumn<String> tokenNumber = GeneratedColumn<String>(
    'token_number',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    deductorId,
    tan,
    formType,
    quarter,
    financialYear,
    dueDate,
    filedDate,
    status,
    totalDeductions,
    totalTaxDeducted,
    totalDeposited,
    lateFee,
    tokenNumber,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tds_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<TdsReturnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('deductor_id')) {
      context.handle(
        _deductorIdMeta,
        deductorId.isAcceptableOrUnknown(data['deductor_id']!, _deductorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deductorIdMeta);
    }
    if (data.containsKey('tan')) {
      context.handle(
        _tanMeta,
        tan.isAcceptableOrUnknown(data['tan']!, _tanMeta),
      );
    } else if (isInserting) {
      context.missing(_tanMeta);
    }
    if (data.containsKey('form_type')) {
      context.handle(
        _formTypeMeta,
        formType.isAcceptableOrUnknown(data['form_type']!, _formTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_formTypeMeta);
    }
    if (data.containsKey('quarter')) {
      context.handle(
        _quarterMeta,
        quarter.isAcceptableOrUnknown(data['quarter']!, _quarterMeta),
      );
    } else if (isInserting) {
      context.missing(_quarterMeta);
    }
    if (data.containsKey('financial_year')) {
      context.handle(
        _financialYearMeta,
        financialYear.isAcceptableOrUnknown(
          data['financial_year']!,
          _financialYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialYearMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('filed_date')) {
      context.handle(
        _filedDateMeta,
        filedDate.isAcceptableOrUnknown(data['filed_date']!, _filedDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_deductions')) {
      context.handle(
        _totalDeductionsMeta,
        totalDeductions.isAcceptableOrUnknown(
          data['total_deductions']!,
          _totalDeductionsMeta,
        ),
      );
    }
    if (data.containsKey('total_tax_deducted')) {
      context.handle(
        _totalTaxDeductedMeta,
        totalTaxDeducted.isAcceptableOrUnknown(
          data['total_tax_deducted']!,
          _totalTaxDeductedMeta,
        ),
      );
    }
    if (data.containsKey('total_deposited')) {
      context.handle(
        _totalDepositedMeta,
        totalDeposited.isAcceptableOrUnknown(
          data['total_deposited']!,
          _totalDepositedMeta,
        ),
      );
    }
    if (data.containsKey('late_fee')) {
      context.handle(
        _lateFeeMeta,
        lateFee.isAcceptableOrUnknown(data['late_fee']!, _lateFeeMeta),
      );
    }
    if (data.containsKey('token_number')) {
      context.handle(
        _tokenNumberMeta,
        tokenNumber.isAcceptableOrUnknown(
          data['token_number']!,
          _tokenNumberMeta,
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
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TdsReturnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TdsReturnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      deductorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deductor_id'],
      )!,
      tan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tan'],
      )!,
      formType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_type'],
      )!,
      quarter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quarter'],
      )!,
      financialYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_year'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      filedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filed_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalDeductions: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_deductions'],
      )!,
      totalTaxDeducted: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_tax_deducted'],
      )!,
      totalDeposited: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_deposited'],
      )!,
      lateFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}late_fee'],
      )!,
      tokenNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_number'],
      ),
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
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $TdsReturnsTableTable createAlias(String alias) {
    return $TdsReturnsTableTable(attachedDatabase, alias);
  }
}

class TdsReturnRow extends DataClass implements Insertable<TdsReturnRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String deductorId;
  final String tan;
  final String formType;
  final String quarter;
  final String financialYear;
  final String? dueDate;
  final String? filedDate;
  final String status;
  final double totalDeductions;
  final double totalTaxDeducted;
  final double totalDeposited;
  final double lateFee;
  final String? tokenNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const TdsReturnRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    required this.deductorId,
    required this.tan,
    required this.formType,
    required this.quarter,
    required this.financialYear,
    this.dueDate,
    this.filedDate,
    required this.status,
    required this.totalDeductions,
    required this.totalTaxDeducted,
    required this.totalDeposited,
    required this.lateFee,
    this.tokenNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    map['deductor_id'] = Variable<String>(deductorId);
    map['tan'] = Variable<String>(tan);
    map['form_type'] = Variable<String>(formType);
    map['quarter'] = Variable<String>(quarter);
    map['financial_year'] = Variable<String>(financialYear);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || filedDate != null) {
      map['filed_date'] = Variable<String>(filedDate);
    }
    map['status'] = Variable<String>(status);
    map['total_deductions'] = Variable<double>(totalDeductions);
    map['total_tax_deducted'] = Variable<double>(totalTaxDeducted);
    map['total_deposited'] = Variable<double>(totalDeposited);
    map['late_fee'] = Variable<double>(lateFee);
    if (!nullToAbsent || tokenNumber != null) {
      map['token_number'] = Variable<String>(tokenNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  TdsReturnsTableCompanion toCompanion(bool nullToAbsent) {
    return TdsReturnsTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      deductorId: Value(deductorId),
      tan: Value(tan),
      formType: Value(formType),
      quarter: Value(quarter),
      financialYear: Value(financialYear),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      filedDate: filedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(filedDate),
      status: Value(status),
      totalDeductions: Value(totalDeductions),
      totalTaxDeducted: Value(totalTaxDeducted),
      totalDeposited: Value(totalDeposited),
      lateFee: Value(lateFee),
      tokenNumber: tokenNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory TdsReturnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TdsReturnRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      deductorId: serializer.fromJson<String>(json['deductorId']),
      tan: serializer.fromJson<String>(json['tan']),
      formType: serializer.fromJson<String>(json['formType']),
      quarter: serializer.fromJson<String>(json['quarter']),
      financialYear: serializer.fromJson<String>(json['financialYear']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      filedDate: serializer.fromJson<String?>(json['filedDate']),
      status: serializer.fromJson<String>(json['status']),
      totalDeductions: serializer.fromJson<double>(json['totalDeductions']),
      totalTaxDeducted: serializer.fromJson<double>(json['totalTaxDeducted']),
      totalDeposited: serializer.fromJson<double>(json['totalDeposited']),
      lateFee: serializer.fromJson<double>(json['lateFee']),
      tokenNumber: serializer.fromJson<String?>(json['tokenNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'deductorId': serializer.toJson<String>(deductorId),
      'tan': serializer.toJson<String>(tan),
      'formType': serializer.toJson<String>(formType),
      'quarter': serializer.toJson<String>(quarter),
      'financialYear': serializer.toJson<String>(financialYear),
      'dueDate': serializer.toJson<String?>(dueDate),
      'filedDate': serializer.toJson<String?>(filedDate),
      'status': serializer.toJson<String>(status),
      'totalDeductions': serializer.toJson<double>(totalDeductions),
      'totalTaxDeducted': serializer.toJson<double>(totalTaxDeducted),
      'totalDeposited': serializer.toJson<double>(totalDeposited),
      'lateFee': serializer.toJson<double>(lateFee),
      'tokenNumber': serializer.toJson<String?>(tokenNumber),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  TdsReturnRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    String? deductorId,
    String? tan,
    String? formType,
    String? quarter,
    String? financialYear,
    Value<String?> dueDate = const Value.absent(),
    Value<String?> filedDate = const Value.absent(),
    String? status,
    double? totalDeductions,
    double? totalTaxDeducted,
    double? totalDeposited,
    double? lateFee,
    Value<String?> tokenNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => TdsReturnRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    deductorId: deductorId ?? this.deductorId,
    tan: tan ?? this.tan,
    formType: formType ?? this.formType,
    quarter: quarter ?? this.quarter,
    financialYear: financialYear ?? this.financialYear,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    filedDate: filedDate.present ? filedDate.value : this.filedDate,
    status: status ?? this.status,
    totalDeductions: totalDeductions ?? this.totalDeductions,
    totalTaxDeducted: totalTaxDeducted ?? this.totalTaxDeducted,
    totalDeposited: totalDeposited ?? this.totalDeposited,
    lateFee: lateFee ?? this.lateFee,
    tokenNumber: tokenNumber.present ? tokenNumber.value : this.tokenNumber,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  TdsReturnRow copyWithCompanion(TdsReturnsTableCompanion data) {
    return TdsReturnRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      deductorId: data.deductorId.present
          ? data.deductorId.value
          : this.deductorId,
      tan: data.tan.present ? data.tan.value : this.tan,
      formType: data.formType.present ? data.formType.value : this.formType,
      quarter: data.quarter.present ? data.quarter.value : this.quarter,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      filedDate: data.filedDate.present ? data.filedDate.value : this.filedDate,
      status: data.status.present ? data.status.value : this.status,
      totalDeductions: data.totalDeductions.present
          ? data.totalDeductions.value
          : this.totalDeductions,
      totalTaxDeducted: data.totalTaxDeducted.present
          ? data.totalTaxDeducted.value
          : this.totalTaxDeducted,
      totalDeposited: data.totalDeposited.present
          ? data.totalDeposited.value
          : this.totalDeposited,
      lateFee: data.lateFee.present ? data.lateFee.value : this.lateFee,
      tokenNumber: data.tokenNumber.present
          ? data.tokenNumber.value
          : this.tokenNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TdsReturnRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('deductorId: $deductorId, ')
          ..write('tan: $tan, ')
          ..write('formType: $formType, ')
          ..write('quarter: $quarter, ')
          ..write('financialYear: $financialYear, ')
          ..write('dueDate: $dueDate, ')
          ..write('filedDate: $filedDate, ')
          ..write('status: $status, ')
          ..write('totalDeductions: $totalDeductions, ')
          ..write('totalTaxDeducted: $totalTaxDeducted, ')
          ..write('totalDeposited: $totalDeposited, ')
          ..write('lateFee: $lateFee, ')
          ..write('tokenNumber: $tokenNumber, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    firmId,
    clientId,
    deductorId,
    tan,
    formType,
    quarter,
    financialYear,
    dueDate,
    filedDate,
    status,
    totalDeductions,
    totalTaxDeducted,
    totalDeposited,
    lateFee,
    tokenNumber,
    notes,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TdsReturnRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.deductorId == this.deductorId &&
          other.tan == this.tan &&
          other.formType == this.formType &&
          other.quarter == this.quarter &&
          other.financialYear == this.financialYear &&
          other.dueDate == this.dueDate &&
          other.filedDate == this.filedDate &&
          other.status == this.status &&
          other.totalDeductions == this.totalDeductions &&
          other.totalTaxDeducted == this.totalTaxDeducted &&
          other.totalDeposited == this.totalDeposited &&
          other.lateFee == this.lateFee &&
          other.tokenNumber == this.tokenNumber &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class TdsReturnsTableCompanion extends UpdateCompanion<TdsReturnRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String> deductorId;
  final Value<String> tan;
  final Value<String> formType;
  final Value<String> quarter;
  final Value<String> financialYear;
  final Value<String?> dueDate;
  final Value<String?> filedDate;
  final Value<String> status;
  final Value<double> totalDeductions;
  final Value<double> totalTaxDeducted;
  final Value<double> totalDeposited;
  final Value<double> lateFee;
  final Value<String?> tokenNumber;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const TdsReturnsTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.deductorId = const Value.absent(),
    this.tan = const Value.absent(),
    this.formType = const Value.absent(),
    this.quarter = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.totalDeductions = const Value.absent(),
    this.totalTaxDeducted = const Value.absent(),
    this.totalDeposited = const Value.absent(),
    this.lateFee = const Value.absent(),
    this.tokenNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TdsReturnsTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    required String deductorId,
    required String tan,
    required String formType,
    required String quarter,
    required String financialYear,
    this.dueDate = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.totalDeductions = const Value.absent(),
    this.totalTaxDeducted = const Value.absent(),
    this.totalDeposited = const Value.absent(),
    this.lateFee = const Value.absent(),
    this.tokenNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       deductorId = Value(deductorId),
       tan = Value(tan),
       formType = Value(formType),
       quarter = Value(quarter),
       financialYear = Value(financialYear);
  static Insertable<TdsReturnRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? deductorId,
    Expression<String>? tan,
    Expression<String>? formType,
    Expression<String>? quarter,
    Expression<String>? financialYear,
    Expression<String>? dueDate,
    Expression<String>? filedDate,
    Expression<String>? status,
    Expression<double>? totalDeductions,
    Expression<double>? totalTaxDeducted,
    Expression<double>? totalDeposited,
    Expression<double>? lateFee,
    Expression<String>? tokenNumber,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (deductorId != null) 'deductor_id': deductorId,
      if (tan != null) 'tan': tan,
      if (formType != null) 'form_type': formType,
      if (quarter != null) 'quarter': quarter,
      if (financialYear != null) 'financial_year': financialYear,
      if (dueDate != null) 'due_date': dueDate,
      if (filedDate != null) 'filed_date': filedDate,
      if (status != null) 'status': status,
      if (totalDeductions != null) 'total_deductions': totalDeductions,
      if (totalTaxDeducted != null) 'total_tax_deducted': totalTaxDeducted,
      if (totalDeposited != null) 'total_deposited': totalDeposited,
      if (lateFee != null) 'late_fee': lateFee,
      if (tokenNumber != null) 'token_number': tokenNumber,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TdsReturnsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String>? deductorId,
    Value<String>? tan,
    Value<String>? formType,
    Value<String>? quarter,
    Value<String>? financialYear,
    Value<String?>? dueDate,
    Value<String?>? filedDate,
    Value<String>? status,
    Value<double>? totalDeductions,
    Value<double>? totalTaxDeducted,
    Value<double>? totalDeposited,
    Value<double>? lateFee,
    Value<String?>? tokenNumber,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return TdsReturnsTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      deductorId: deductorId ?? this.deductorId,
      tan: tan ?? this.tan,
      formType: formType ?? this.formType,
      quarter: quarter ?? this.quarter,
      financialYear: financialYear ?? this.financialYear,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      totalTaxDeducted: totalTaxDeducted ?? this.totalTaxDeducted,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      lateFee: lateFee ?? this.lateFee,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (deductorId.present) {
      map['deductor_id'] = Variable<String>(deductorId.value);
    }
    if (tan.present) {
      map['tan'] = Variable<String>(tan.value);
    }
    if (formType.present) {
      map['form_type'] = Variable<String>(formType.value);
    }
    if (quarter.present) {
      map['quarter'] = Variable<String>(quarter.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (filedDate.present) {
      map['filed_date'] = Variable<String>(filedDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalDeductions.present) {
      map['total_deductions'] = Variable<double>(totalDeductions.value);
    }
    if (totalTaxDeducted.present) {
      map['total_tax_deducted'] = Variable<double>(totalTaxDeducted.value);
    }
    if (totalDeposited.present) {
      map['total_deposited'] = Variable<double>(totalDeposited.value);
    }
    if (lateFee.present) {
      map['late_fee'] = Variable<double>(lateFee.value);
    }
    if (tokenNumber.present) {
      map['token_number'] = Variable<String>(tokenNumber.value);
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
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TdsReturnsTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('deductorId: $deductorId, ')
          ..write('tan: $tan, ')
          ..write('formType: $formType, ')
          ..write('quarter: $quarter, ')
          ..write('financialYear: $financialYear, ')
          ..write('dueDate: $dueDate, ')
          ..write('filedDate: $filedDate, ')
          ..write('status: $status, ')
          ..write('totalDeductions: $totalDeductions, ')
          ..write('totalTaxDeducted: $totalTaxDeducted, ')
          ..write('totalDeposited: $totalDeposited, ')
          ..write('lateFee: $lateFee, ')
          ..write('tokenNumber: $tokenNumber, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TdsChallansTableTable extends TdsChallansTable
    with TableInfo<$TdsChallansTableTable, TdsChallanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TdsChallansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tdsReturnIdMeta = const VerificationMeta(
    'tdsReturnId',
  );
  @override
  late final GeneratedColumn<String> tdsReturnId = GeneratedColumn<String>(
    'tds_return_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deductorIdMeta = const VerificationMeta(
    'deductorId',
  );
  @override
  late final GeneratedColumn<String> deductorId = GeneratedColumn<String>(
    'deductor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challanNumberMeta = const VerificationMeta(
    'challanNumber',
  );
  @override
  late final GeneratedColumn<String> challanNumber = GeneratedColumn<String>(
    'challan_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bsrCodeMeta = const VerificationMeta(
    'bsrCode',
  );
  @override
  late final GeneratedColumn<String> bsrCode = GeneratedColumn<String>(
    'bsr_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deducteeCountMeta = const VerificationMeta(
    'deducteeCount',
  );
  @override
  late final GeneratedColumn<int> deducteeCount = GeneratedColumn<int>(
    'deductee_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tdsAmountMeta = const VerificationMeta(
    'tdsAmount',
  );
  @override
  late final GeneratedColumn<double> tdsAmount = GeneratedColumn<double>(
    'tds_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surchargeMeta = const VerificationMeta(
    'surcharge',
  );
  @override
  late final GeneratedColumn<double> surcharge = GeneratedColumn<double>(
    'surcharge',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _educationCessMeta = const VerificationMeta(
    'educationCess',
  );
  @override
  late final GeneratedColumn<double> educationCess = GeneratedColumn<double>(
    'education_cess',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _interestMeta = const VerificationMeta(
    'interest',
  );
  @override
  late final GeneratedColumn<double> interest = GeneratedColumn<double>(
    'interest',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _penaltyMeta = const VerificationMeta(
    'penalty',
  );
  @override
  late final GeneratedColumn<double> penalty = GeneratedColumn<double>(
    'penalty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<String> paymentDate = GeneratedColumn<String>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _financialYearMeta = const VerificationMeta(
    'financialYear',
  );
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
    'financial_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('deposited'),
  );
  static const VerificationMeta _taxTypeMeta = const VerificationMeta(
    'taxType',
  );
  @override
  late final GeneratedColumn<String> taxType = GeneratedColumn<String>(
    'tax_type',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    tdsReturnId,
    deductorId,
    challanNumber,
    bsrCode,
    section,
    deducteeCount,
    tdsAmount,
    surcharge,
    educationCess,
    interest,
    penalty,
    totalAmount,
    paymentDate,
    month,
    financialYear,
    status,
    taxType,
    createdAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tds_challans';
  @override
  VerificationContext validateIntegrity(
    Insertable<TdsChallanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('tds_return_id')) {
      context.handle(
        _tdsReturnIdMeta,
        tdsReturnId.isAcceptableOrUnknown(
          data['tds_return_id']!,
          _tdsReturnIdMeta,
        ),
      );
    }
    if (data.containsKey('deductor_id')) {
      context.handle(
        _deductorIdMeta,
        deductorId.isAcceptableOrUnknown(data['deductor_id']!, _deductorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deductorIdMeta);
    }
    if (data.containsKey('challan_number')) {
      context.handle(
        _challanNumberMeta,
        challanNumber.isAcceptableOrUnknown(
          data['challan_number']!,
          _challanNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challanNumberMeta);
    }
    if (data.containsKey('bsr_code')) {
      context.handle(
        _bsrCodeMeta,
        bsrCode.isAcceptableOrUnknown(data['bsr_code']!, _bsrCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bsrCodeMeta);
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionMeta);
    }
    if (data.containsKey('deductee_count')) {
      context.handle(
        _deducteeCountMeta,
        deducteeCount.isAcceptableOrUnknown(
          data['deductee_count']!,
          _deducteeCountMeta,
        ),
      );
    }
    if (data.containsKey('tds_amount')) {
      context.handle(
        _tdsAmountMeta,
        tdsAmount.isAcceptableOrUnknown(data['tds_amount']!, _tdsAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_tdsAmountMeta);
    }
    if (data.containsKey('surcharge')) {
      context.handle(
        _surchargeMeta,
        surcharge.isAcceptableOrUnknown(data['surcharge']!, _surchargeMeta),
      );
    }
    if (data.containsKey('education_cess')) {
      context.handle(
        _educationCessMeta,
        educationCess.isAcceptableOrUnknown(
          data['education_cess']!,
          _educationCessMeta,
        ),
      );
    }
    if (data.containsKey('interest')) {
      context.handle(
        _interestMeta,
        interest.isAcceptableOrUnknown(data['interest']!, _interestMeta),
      );
    }
    if (data.containsKey('penalty')) {
      context.handle(
        _penaltyMeta,
        penalty.isAcceptableOrUnknown(data['penalty']!, _penaltyMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('financial_year')) {
      context.handle(
        _financialYearMeta,
        financialYear.isAcceptableOrUnknown(
          data['financial_year']!,
          _financialYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialYearMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('tax_type')) {
      context.handle(
        _taxTypeMeta,
        taxType.isAcceptableOrUnknown(data['tax_type']!, _taxTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TdsChallanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TdsChallanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      tdsReturnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tds_return_id'],
      ),
      deductorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deductor_id'],
      )!,
      challanNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challan_number'],
      )!,
      bsrCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bsr_code'],
      )!,
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      deducteeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deductee_count'],
      )!,
      tdsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tds_amount'],
      )!,
      surcharge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}surcharge'],
      )!,
      educationCess: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}education_cess'],
      )!,
      interest: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest'],
      )!,
      penalty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}penalty'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_date'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      financialYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_year'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      taxType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $TdsChallansTableTable createAlias(String alias) {
    return $TdsChallansTableTable(attachedDatabase, alias);
  }
}

class TdsChallanRow extends DataClass implements Insertable<TdsChallanRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String? tdsReturnId;
  final String deductorId;
  final String challanNumber;
  final String bsrCode;
  final String section;
  final int deducteeCount;
  final double tdsAmount;
  final double surcharge;
  final double educationCess;
  final double interest;
  final double penalty;
  final double totalAmount;
  final String paymentDate;
  final int month;
  final String financialYear;
  final String status;
  final String? taxType;
  final DateTime createdAt;
  final String? syncedAt;
  final bool isDirty;
  const TdsChallanRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    this.tdsReturnId,
    required this.deductorId,
    required this.challanNumber,
    required this.bsrCode,
    required this.section,
    required this.deducteeCount,
    required this.tdsAmount,
    required this.surcharge,
    required this.educationCess,
    required this.interest,
    required this.penalty,
    required this.totalAmount,
    required this.paymentDate,
    required this.month,
    required this.financialYear,
    required this.status,
    this.taxType,
    required this.createdAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || tdsReturnId != null) {
      map['tds_return_id'] = Variable<String>(tdsReturnId);
    }
    map['deductor_id'] = Variable<String>(deductorId);
    map['challan_number'] = Variable<String>(challanNumber);
    map['bsr_code'] = Variable<String>(bsrCode);
    map['section'] = Variable<String>(section);
    map['deductee_count'] = Variable<int>(deducteeCount);
    map['tds_amount'] = Variable<double>(tdsAmount);
    map['surcharge'] = Variable<double>(surcharge);
    map['education_cess'] = Variable<double>(educationCess);
    map['interest'] = Variable<double>(interest);
    map['penalty'] = Variable<double>(penalty);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_date'] = Variable<String>(paymentDate);
    map['month'] = Variable<int>(month);
    map['financial_year'] = Variable<String>(financialYear);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || taxType != null) {
      map['tax_type'] = Variable<String>(taxType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  TdsChallansTableCompanion toCompanion(bool nullToAbsent) {
    return TdsChallansTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      tdsReturnId: tdsReturnId == null && nullToAbsent
          ? const Value.absent()
          : Value(tdsReturnId),
      deductorId: Value(deductorId),
      challanNumber: Value(challanNumber),
      bsrCode: Value(bsrCode),
      section: Value(section),
      deducteeCount: Value(deducteeCount),
      tdsAmount: Value(tdsAmount),
      surcharge: Value(surcharge),
      educationCess: Value(educationCess),
      interest: Value(interest),
      penalty: Value(penalty),
      totalAmount: Value(totalAmount),
      paymentDate: Value(paymentDate),
      month: Value(month),
      financialYear: Value(financialYear),
      status: Value(status),
      taxType: taxType == null && nullToAbsent
          ? const Value.absent()
          : Value(taxType),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory TdsChallanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TdsChallanRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      tdsReturnId: serializer.fromJson<String?>(json['tdsReturnId']),
      deductorId: serializer.fromJson<String>(json['deductorId']),
      challanNumber: serializer.fromJson<String>(json['challanNumber']),
      bsrCode: serializer.fromJson<String>(json['bsrCode']),
      section: serializer.fromJson<String>(json['section']),
      deducteeCount: serializer.fromJson<int>(json['deducteeCount']),
      tdsAmount: serializer.fromJson<double>(json['tdsAmount']),
      surcharge: serializer.fromJson<double>(json['surcharge']),
      educationCess: serializer.fromJson<double>(json['educationCess']),
      interest: serializer.fromJson<double>(json['interest']),
      penalty: serializer.fromJson<double>(json['penalty']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentDate: serializer.fromJson<String>(json['paymentDate']),
      month: serializer.fromJson<int>(json['month']),
      financialYear: serializer.fromJson<String>(json['financialYear']),
      status: serializer.fromJson<String>(json['status']),
      taxType: serializer.fromJson<String?>(json['taxType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'tdsReturnId': serializer.toJson<String?>(tdsReturnId),
      'deductorId': serializer.toJson<String>(deductorId),
      'challanNumber': serializer.toJson<String>(challanNumber),
      'bsrCode': serializer.toJson<String>(bsrCode),
      'section': serializer.toJson<String>(section),
      'deducteeCount': serializer.toJson<int>(deducteeCount),
      'tdsAmount': serializer.toJson<double>(tdsAmount),
      'surcharge': serializer.toJson<double>(surcharge),
      'educationCess': serializer.toJson<double>(educationCess),
      'interest': serializer.toJson<double>(interest),
      'penalty': serializer.toJson<double>(penalty),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentDate': serializer.toJson<String>(paymentDate),
      'month': serializer.toJson<int>(month),
      'financialYear': serializer.toJson<String>(financialYear),
      'status': serializer.toJson<String>(status),
      'taxType': serializer.toJson<String?>(taxType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  TdsChallanRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    Value<String?> tdsReturnId = const Value.absent(),
    String? deductorId,
    String? challanNumber,
    String? bsrCode,
    String? section,
    int? deducteeCount,
    double? tdsAmount,
    double? surcharge,
    double? educationCess,
    double? interest,
    double? penalty,
    double? totalAmount,
    String? paymentDate,
    int? month,
    String? financialYear,
    String? status,
    Value<String?> taxType = const Value.absent(),
    DateTime? createdAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => TdsChallanRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    tdsReturnId: tdsReturnId.present ? tdsReturnId.value : this.tdsReturnId,
    deductorId: deductorId ?? this.deductorId,
    challanNumber: challanNumber ?? this.challanNumber,
    bsrCode: bsrCode ?? this.bsrCode,
    section: section ?? this.section,
    deducteeCount: deducteeCount ?? this.deducteeCount,
    tdsAmount: tdsAmount ?? this.tdsAmount,
    surcharge: surcharge ?? this.surcharge,
    educationCess: educationCess ?? this.educationCess,
    interest: interest ?? this.interest,
    penalty: penalty ?? this.penalty,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentDate: paymentDate ?? this.paymentDate,
    month: month ?? this.month,
    financialYear: financialYear ?? this.financialYear,
    status: status ?? this.status,
    taxType: taxType.present ? taxType.value : this.taxType,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  TdsChallanRow copyWithCompanion(TdsChallansTableCompanion data) {
    return TdsChallanRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      tdsReturnId: data.tdsReturnId.present
          ? data.tdsReturnId.value
          : this.tdsReturnId,
      deductorId: data.deductorId.present
          ? data.deductorId.value
          : this.deductorId,
      challanNumber: data.challanNumber.present
          ? data.challanNumber.value
          : this.challanNumber,
      bsrCode: data.bsrCode.present ? data.bsrCode.value : this.bsrCode,
      section: data.section.present ? data.section.value : this.section,
      deducteeCount: data.deducteeCount.present
          ? data.deducteeCount.value
          : this.deducteeCount,
      tdsAmount: data.tdsAmount.present ? data.tdsAmount.value : this.tdsAmount,
      surcharge: data.surcharge.present ? data.surcharge.value : this.surcharge,
      educationCess: data.educationCess.present
          ? data.educationCess.value
          : this.educationCess,
      interest: data.interest.present ? data.interest.value : this.interest,
      penalty: data.penalty.present ? data.penalty.value : this.penalty,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      month: data.month.present ? data.month.value : this.month,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      status: data.status.present ? data.status.value : this.status,
      taxType: data.taxType.present ? data.taxType.value : this.taxType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TdsChallanRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('tdsReturnId: $tdsReturnId, ')
          ..write('deductorId: $deductorId, ')
          ..write('challanNumber: $challanNumber, ')
          ..write('bsrCode: $bsrCode, ')
          ..write('section: $section, ')
          ..write('deducteeCount: $deducteeCount, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('surcharge: $surcharge, ')
          ..write('educationCess: $educationCess, ')
          ..write('interest: $interest, ')
          ..write('penalty: $penalty, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('month: $month, ')
          ..write('financialYear: $financialYear, ')
          ..write('status: $status, ')
          ..write('taxType: $taxType, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    firmId,
    clientId,
    tdsReturnId,
    deductorId,
    challanNumber,
    bsrCode,
    section,
    deducteeCount,
    tdsAmount,
    surcharge,
    educationCess,
    interest,
    penalty,
    totalAmount,
    paymentDate,
    month,
    financialYear,
    status,
    taxType,
    createdAt,
    syncedAt,
    isDirty,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TdsChallanRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.tdsReturnId == this.tdsReturnId &&
          other.deductorId == this.deductorId &&
          other.challanNumber == this.challanNumber &&
          other.bsrCode == this.bsrCode &&
          other.section == this.section &&
          other.deducteeCount == this.deducteeCount &&
          other.tdsAmount == this.tdsAmount &&
          other.surcharge == this.surcharge &&
          other.educationCess == this.educationCess &&
          other.interest == this.interest &&
          other.penalty == this.penalty &&
          other.totalAmount == this.totalAmount &&
          other.paymentDate == this.paymentDate &&
          other.month == this.month &&
          other.financialYear == this.financialYear &&
          other.status == this.status &&
          other.taxType == this.taxType &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class TdsChallansTableCompanion extends UpdateCompanion<TdsChallanRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String?> tdsReturnId;
  final Value<String> deductorId;
  final Value<String> challanNumber;
  final Value<String> bsrCode;
  final Value<String> section;
  final Value<int> deducteeCount;
  final Value<double> tdsAmount;
  final Value<double> surcharge;
  final Value<double> educationCess;
  final Value<double> interest;
  final Value<double> penalty;
  final Value<double> totalAmount;
  final Value<String> paymentDate;
  final Value<int> month;
  final Value<String> financialYear;
  final Value<String> status;
  final Value<String?> taxType;
  final Value<DateTime> createdAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const TdsChallansTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.tdsReturnId = const Value.absent(),
    this.deductorId = const Value.absent(),
    this.challanNumber = const Value.absent(),
    this.bsrCode = const Value.absent(),
    this.section = const Value.absent(),
    this.deducteeCount = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.surcharge = const Value.absent(),
    this.educationCess = const Value.absent(),
    this.interest = const Value.absent(),
    this.penalty = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.month = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.status = const Value.absent(),
    this.taxType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TdsChallansTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    this.tdsReturnId = const Value.absent(),
    required String deductorId,
    required String challanNumber,
    required String bsrCode,
    required String section,
    this.deducteeCount = const Value.absent(),
    required double tdsAmount,
    this.surcharge = const Value.absent(),
    this.educationCess = const Value.absent(),
    this.interest = const Value.absent(),
    this.penalty = const Value.absent(),
    required double totalAmount,
    required String paymentDate,
    required int month,
    required String financialYear,
    this.status = const Value.absent(),
    this.taxType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       deductorId = Value(deductorId),
       challanNumber = Value(challanNumber),
       bsrCode = Value(bsrCode),
       section = Value(section),
       tdsAmount = Value(tdsAmount),
       totalAmount = Value(totalAmount),
       paymentDate = Value(paymentDate),
       month = Value(month),
       financialYear = Value(financialYear);
  static Insertable<TdsChallanRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? tdsReturnId,
    Expression<String>? deductorId,
    Expression<String>? challanNumber,
    Expression<String>? bsrCode,
    Expression<String>? section,
    Expression<int>? deducteeCount,
    Expression<double>? tdsAmount,
    Expression<double>? surcharge,
    Expression<double>? educationCess,
    Expression<double>? interest,
    Expression<double>? penalty,
    Expression<double>? totalAmount,
    Expression<String>? paymentDate,
    Expression<int>? month,
    Expression<String>? financialYear,
    Expression<String>? status,
    Expression<String>? taxType,
    Expression<DateTime>? createdAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (tdsReturnId != null) 'tds_return_id': tdsReturnId,
      if (deductorId != null) 'deductor_id': deductorId,
      if (challanNumber != null) 'challan_number': challanNumber,
      if (bsrCode != null) 'bsr_code': bsrCode,
      if (section != null) 'section': section,
      if (deducteeCount != null) 'deductee_count': deducteeCount,
      if (tdsAmount != null) 'tds_amount': tdsAmount,
      if (surcharge != null) 'surcharge': surcharge,
      if (educationCess != null) 'education_cess': educationCess,
      if (interest != null) 'interest': interest,
      if (penalty != null) 'penalty': penalty,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (month != null) 'month': month,
      if (financialYear != null) 'financial_year': financialYear,
      if (status != null) 'status': status,
      if (taxType != null) 'tax_type': taxType,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TdsChallansTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String?>? tdsReturnId,
    Value<String>? deductorId,
    Value<String>? challanNumber,
    Value<String>? bsrCode,
    Value<String>? section,
    Value<int>? deducteeCount,
    Value<double>? tdsAmount,
    Value<double>? surcharge,
    Value<double>? educationCess,
    Value<double>? interest,
    Value<double>? penalty,
    Value<double>? totalAmount,
    Value<String>? paymentDate,
    Value<int>? month,
    Value<String>? financialYear,
    Value<String>? status,
    Value<String?>? taxType,
    Value<DateTime>? createdAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return TdsChallansTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      tdsReturnId: tdsReturnId ?? this.tdsReturnId,
      deductorId: deductorId ?? this.deductorId,
      challanNumber: challanNumber ?? this.challanNumber,
      bsrCode: bsrCode ?? this.bsrCode,
      section: section ?? this.section,
      deducteeCount: deducteeCount ?? this.deducteeCount,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      surcharge: surcharge ?? this.surcharge,
      educationCess: educationCess ?? this.educationCess,
      interest: interest ?? this.interest,
      penalty: penalty ?? this.penalty,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      month: month ?? this.month,
      financialYear: financialYear ?? this.financialYear,
      status: status ?? this.status,
      taxType: taxType ?? this.taxType,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (tdsReturnId.present) {
      map['tds_return_id'] = Variable<String>(tdsReturnId.value);
    }
    if (deductorId.present) {
      map['deductor_id'] = Variable<String>(deductorId.value);
    }
    if (challanNumber.present) {
      map['challan_number'] = Variable<String>(challanNumber.value);
    }
    if (bsrCode.present) {
      map['bsr_code'] = Variable<String>(bsrCode.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (deducteeCount.present) {
      map['deductee_count'] = Variable<int>(deducteeCount.value);
    }
    if (tdsAmount.present) {
      map['tds_amount'] = Variable<double>(tdsAmount.value);
    }
    if (surcharge.present) {
      map['surcharge'] = Variable<double>(surcharge.value);
    }
    if (educationCess.present) {
      map['education_cess'] = Variable<double>(educationCess.value);
    }
    if (interest.present) {
      map['interest'] = Variable<double>(interest.value);
    }
    if (penalty.present) {
      map['penalty'] = Variable<double>(penalty.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<String>(paymentDate.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (taxType.present) {
      map['tax_type'] = Variable<String>(taxType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TdsChallansTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('tdsReturnId: $tdsReturnId, ')
          ..write('deductorId: $deductorId, ')
          ..write('challanNumber: $challanNumber, ')
          ..write('bsrCode: $bsrCode, ')
          ..write('section: $section, ')
          ..write('deducteeCount: $deducteeCount, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('surcharge: $surcharge, ')
          ..write('educationCess: $educationCess, ')
          ..write('interest: $interest, ')
          ..write('penalty: $penalty, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('month: $month, ')
          ..write('financialYear: $financialYear, ')
          ..write('status: $status, ')
          ..write('taxType: $taxType, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTableTable extends InvoicesTable
    with TableInfo<$InvoicesTableTable, InvoiceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientNameMeta = const VerificationMeta(
    'clientName',
  );
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
    'client_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<String> invoiceDate = GeneratedColumn<String>(
    'invoice_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineItemsMeta = const VerificationMeta(
    'lineItems',
  );
  @override
  late final GeneratedColumn<String> lineItems = GeneratedColumn<String>(
    'line_items',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalGstMeta = const VerificationMeta(
    'totalGst',
  );
  @override
  late final GeneratedColumn<double> totalGst = GeneratedColumn<double>(
    'total_gst',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _grandTotalMeta = const VerificationMeta(
    'grandTotal',
  );
  @override
  late final GeneratedColumn<double> grandTotal = GeneratedColumn<double>(
    'grand_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _balanceDueMeta = const VerificationMeta(
    'balanceDue',
  );
  @override
  late final GeneratedColumn<double> balanceDue = GeneratedColumn<double>(
    'balance_due',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<String> paymentDate = GeneratedColumn<String>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termsMeta = const VerificationMeta('terms');
  @override
  late final GeneratedColumn<String> terms = GeneratedColumn<String>(
    'terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurringFrequencyMeta =
      const VerificationMeta('recurringFrequency');
  @override
  late final GeneratedColumn<String> recurringFrequency =
      GeneratedColumn<String>(
        'recurring_frequency',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    clientName,
    invoiceNumber,
    gstin,
    invoiceDate,
    dueDate,
    lineItems,
    subtotal,
    discountAmount,
    totalGst,
    grandTotal,
    paidAmount,
    balanceDue,
    status,
    paymentDate,
    paymentMethod,
    remarks,
    terms,
    isRecurring,
    recurringFrequency,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('client_name')) {
      context.handle(
        _clientNameMeta,
        clientName.isAcceptableOrUnknown(data['client_name']!, _clientNameMeta),
      );
    } else if (isInserting) {
      context.missing(_clientNameMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('line_items')) {
      context.handle(
        _lineItemsMeta,
        lineItems.isAcceptableOrUnknown(data['line_items']!, _lineItemsMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_gst')) {
      context.handle(
        _totalGstMeta,
        totalGst.isAcceptableOrUnknown(data['total_gst']!, _totalGstMeta),
      );
    }
    if (data.containsKey('grand_total')) {
      context.handle(
        _grandTotalMeta,
        grandTotal.isAcceptableOrUnknown(data['grand_total']!, _grandTotalMeta),
      );
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('balance_due')) {
      context.handle(
        _balanceDueMeta,
        balanceDue.isAcceptableOrUnknown(data['balance_due']!, _balanceDueMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('terms')) {
      context.handle(
        _termsMeta,
        terms.isAcceptableOrUnknown(data['terms']!, _termsMeta),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('recurring_frequency')) {
      context.handle(
        _recurringFrequencyMeta,
        recurringFrequency.isAcceptableOrUnknown(
          data['recurring_frequency']!,
          _recurringFrequencyMeta,
        ),
      );
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      clientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_name'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      lineItems: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_items'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      totalGst: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_gst'],
      )!,
      grandTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grand_total'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
      balanceDue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_due'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_date'],
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      terms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms'],
      ),
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      recurringFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_frequency'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $InvoicesTableTable createAlias(String alias) {
    return $InvoicesTableTable(attachedDatabase, alias);
  }
}

class InvoiceRow extends DataClass implements Insertable<InvoiceRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String clientName;
  final String invoiceNumber;
  final String? gstin;
  final String invoiceDate;
  final String dueDate;
  final String lineItems;
  final double subtotal;
  final double discountAmount;
  final double totalGst;
  final double grandTotal;
  final double paidAmount;
  final double balanceDue;
  final String status;
  final String? paymentDate;
  final String? paymentMethod;
  final String? remarks;
  final String? terms;
  final bool isRecurring;
  final String? recurringFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const InvoiceRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    required this.clientName,
    required this.invoiceNumber,
    this.gstin,
    required this.invoiceDate,
    required this.dueDate,
    required this.lineItems,
    required this.subtotal,
    required this.discountAmount,
    required this.totalGst,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceDue,
    required this.status,
    this.paymentDate,
    this.paymentMethod,
    this.remarks,
    this.terms,
    required this.isRecurring,
    this.recurringFrequency,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    map['client_name'] = Variable<String>(clientName);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    map['invoice_date'] = Variable<String>(invoiceDate);
    map['due_date'] = Variable<String>(dueDate);
    map['line_items'] = Variable<String>(lineItems);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['total_gst'] = Variable<double>(totalGst);
    map['grand_total'] = Variable<double>(grandTotal);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['balance_due'] = Variable<double>(balanceDue);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<String>(paymentDate);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || terms != null) {
      map['terms'] = Variable<String>(terms);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringFrequency != null) {
      map['recurring_frequency'] = Variable<String>(recurringFrequency);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  InvoicesTableCompanion toCompanion(bool nullToAbsent) {
    return InvoicesTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      clientName: Value(clientName),
      invoiceNumber: Value(invoiceNumber),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      invoiceDate: Value(invoiceDate),
      dueDate: Value(dueDate),
      lineItems: Value(lineItems),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      totalGst: Value(totalGst),
      grandTotal: Value(grandTotal),
      paidAmount: Value(paidAmount),
      balanceDue: Value(balanceDue),
      status: Value(status),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      terms: terms == null && nullToAbsent
          ? const Value.absent()
          : Value(terms),
      isRecurring: Value(isRecurring),
      recurringFrequency: recurringFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringFrequency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory InvoiceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      clientName: serializer.fromJson<String>(json['clientName']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      invoiceDate: serializer.fromJson<String>(json['invoiceDate']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      lineItems: serializer.fromJson<String>(json['lineItems']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      totalGst: serializer.fromJson<double>(json['totalGst']),
      grandTotal: serializer.fromJson<double>(json['grandTotal']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      balanceDue: serializer.fromJson<double>(json['balanceDue']),
      status: serializer.fromJson<String>(json['status']),
      paymentDate: serializer.fromJson<String?>(json['paymentDate']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      terms: serializer.fromJson<String?>(json['terms']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringFrequency: serializer.fromJson<String?>(
        json['recurringFrequency'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'clientName': serializer.toJson<String>(clientName),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'gstin': serializer.toJson<String?>(gstin),
      'invoiceDate': serializer.toJson<String>(invoiceDate),
      'dueDate': serializer.toJson<String>(dueDate),
      'lineItems': serializer.toJson<String>(lineItems),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'totalGst': serializer.toJson<double>(totalGst),
      'grandTotal': serializer.toJson<double>(grandTotal),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'balanceDue': serializer.toJson<double>(balanceDue),
      'status': serializer.toJson<String>(status),
      'paymentDate': serializer.toJson<String?>(paymentDate),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'remarks': serializer.toJson<String?>(remarks),
      'terms': serializer.toJson<String?>(terms),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringFrequency': serializer.toJson<String?>(recurringFrequency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  InvoiceRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    String? clientName,
    String? invoiceNumber,
    Value<String?> gstin = const Value.absent(),
    String? invoiceDate,
    String? dueDate,
    String? lineItems,
    double? subtotal,
    double? discountAmount,
    double? totalGst,
    double? grandTotal,
    double? paidAmount,
    double? balanceDue,
    String? status,
    Value<String?> paymentDate = const Value.absent(),
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> terms = const Value.absent(),
    bool? isRecurring,
    Value<String?> recurringFrequency = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => InvoiceRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    clientName: clientName ?? this.clientName,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    gstin: gstin.present ? gstin.value : this.gstin,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    dueDate: dueDate ?? this.dueDate,
    lineItems: lineItems ?? this.lineItems,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    totalGst: totalGst ?? this.totalGst,
    grandTotal: grandTotal ?? this.grandTotal,
    paidAmount: paidAmount ?? this.paidAmount,
    balanceDue: balanceDue ?? this.balanceDue,
    status: status ?? this.status,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    remarks: remarks.present ? remarks.value : this.remarks,
    terms: terms.present ? terms.value : this.terms,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringFrequency: recurringFrequency.present
        ? recurringFrequency.value
        : this.recurringFrequency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  InvoiceRow copyWithCompanion(InvoicesTableCompanion data) {
    return InvoiceRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      clientName: data.clientName.present
          ? data.clientName.value
          : this.clientName,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      lineItems: data.lineItems.present ? data.lineItems.value : this.lineItems,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      totalGst: data.totalGst.present ? data.totalGst.value : this.totalGst,
      grandTotal: data.grandTotal.present
          ? data.grandTotal.value
          : this.grandTotal,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      balanceDue: data.balanceDue.present
          ? data.balanceDue.value
          : this.balanceDue,
      status: data.status.present ? data.status.value : this.status,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      terms: data.terms.present ? data.terms.value : this.terms,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      recurringFrequency: data.recurringFrequency.present
          ? data.recurringFrequency.value
          : this.recurringFrequency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('clientName: $clientName, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('gstin: $gstin, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('lineItems: $lineItems, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalGst: $totalGst, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('status: $status, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('remarks: $remarks, ')
          ..write('terms: $terms, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringFrequency: $recurringFrequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    firmId,
    clientId,
    clientName,
    invoiceNumber,
    gstin,
    invoiceDate,
    dueDate,
    lineItems,
    subtotal,
    discountAmount,
    totalGst,
    grandTotal,
    paidAmount,
    balanceDue,
    status,
    paymentDate,
    paymentMethod,
    remarks,
    terms,
    isRecurring,
    recurringFrequency,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.clientName == this.clientName &&
          other.invoiceNumber == this.invoiceNumber &&
          other.gstin == this.gstin &&
          other.invoiceDate == this.invoiceDate &&
          other.dueDate == this.dueDate &&
          other.lineItems == this.lineItems &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.totalGst == this.totalGst &&
          other.grandTotal == this.grandTotal &&
          other.paidAmount == this.paidAmount &&
          other.balanceDue == this.balanceDue &&
          other.status == this.status &&
          other.paymentDate == this.paymentDate &&
          other.paymentMethod == this.paymentMethod &&
          other.remarks == this.remarks &&
          other.terms == this.terms &&
          other.isRecurring == this.isRecurring &&
          other.recurringFrequency == this.recurringFrequency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class InvoicesTableCompanion extends UpdateCompanion<InvoiceRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String> clientName;
  final Value<String> invoiceNumber;
  final Value<String?> gstin;
  final Value<String> invoiceDate;
  final Value<String> dueDate;
  final Value<String> lineItems;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<double> totalGst;
  final Value<double> grandTotal;
  final Value<double> paidAmount;
  final Value<double> balanceDue;
  final Value<String> status;
  final Value<String?> paymentDate;
  final Value<String?> paymentMethod;
  final Value<String?> remarks;
  final Value<String?> terms;
  final Value<bool> isRecurring;
  final Value<String?> recurringFrequency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const InvoicesTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.clientName = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.gstin = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.lineItems = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalGst = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.remarks = const Value.absent(),
    this.terms = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringFrequency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    required String clientName,
    required String invoiceNumber,
    this.gstin = const Value.absent(),
    required String invoiceDate,
    required String dueDate,
    this.lineItems = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalGst = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.remarks = const Value.absent(),
    this.terms = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringFrequency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       clientName = Value(clientName),
       invoiceNumber = Value(invoiceNumber),
       invoiceDate = Value(invoiceDate),
       dueDate = Value(dueDate);
  static Insertable<InvoiceRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? clientName,
    Expression<String>? invoiceNumber,
    Expression<String>? gstin,
    Expression<String>? invoiceDate,
    Expression<String>? dueDate,
    Expression<String>? lineItems,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<double>? totalGst,
    Expression<double>? grandTotal,
    Expression<double>? paidAmount,
    Expression<double>? balanceDue,
    Expression<String>? status,
    Expression<String>? paymentDate,
    Expression<String>? paymentMethod,
    Expression<String>? remarks,
    Expression<String>? terms,
    Expression<bool>? isRecurring,
    Expression<String>? recurringFrequency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (clientName != null) 'client_name': clientName,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (gstin != null) 'gstin': gstin,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (dueDate != null) 'due_date': dueDate,
      if (lineItems != null) 'line_items': lineItems,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (totalGst != null) 'total_gst': totalGst,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (balanceDue != null) 'balance_due': balanceDue,
      if (status != null) 'status': status,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (remarks != null) 'remarks': remarks,
      if (terms != null) 'terms': terms,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringFrequency != null) 'recurring_frequency': recurringFrequency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String>? clientName,
    Value<String>? invoiceNumber,
    Value<String?>? gstin,
    Value<String>? invoiceDate,
    Value<String>? dueDate,
    Value<String>? lineItems,
    Value<double>? subtotal,
    Value<double>? discountAmount,
    Value<double>? totalGst,
    Value<double>? grandTotal,
    Value<double>? paidAmount,
    Value<double>? balanceDue,
    Value<String>? status,
    Value<String?>? paymentDate,
    Value<String?>? paymentMethod,
    Value<String?>? remarks,
    Value<String?>? terms,
    Value<bool>? isRecurring,
    Value<String?>? recurringFrequency,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return InvoicesTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      gstin: gstin ?? this.gstin,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      totalGst: totalGst ?? this.totalGst,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      remarks: remarks ?? this.remarks,
      terms: terms ?? this.terms,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<String>(invoiceDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (lineItems.present) {
      map['line_items'] = Variable<String>(lineItems.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (totalGst.present) {
      map['total_gst'] = Variable<double>(totalGst.value);
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<double>(grandTotal.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (balanceDue.present) {
      map['balance_due'] = Variable<double>(balanceDue.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<String>(paymentDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (terms.present) {
      map['terms'] = Variable<String>(terms.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringFrequency.present) {
      map['recurring_frequency'] = Variable<String>(recurringFrequency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('clientName: $clientName, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('gstin: $gstin, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('lineItems: $lineItems, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalGst: $totalGst, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('status: $status, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('remarks: $remarks, ')
          ..write('terms: $terms, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringFrequency: $recurringFrequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientNameMeta = const VerificationMeta(
    'clientName',
  );
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
    'client_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<String> paymentDate = GeneratedColumn<String>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    invoiceId,
    clientName,
    amount,
    paymentDate,
    mode,
    reference,
    notes,
    createdAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('client_name')) {
      context.handle(
        _clientNameMeta,
        clientName.isAcceptableOrUnknown(data['client_name']!, _clientNameMeta),
      );
    } else if (isInserting) {
      context.missing(_clientNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      clientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_date'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String firmId;
  final String invoiceId;
  final String clientName;
  final double amount;
  final String paymentDate;
  final String mode;
  final String reference;
  final String notes;
  final DateTime createdAt;
  final String? syncedAt;
  final bool isDirty;
  const PaymentRow({
    required this.id,
    required this.firmId,
    required this.invoiceId,
    required this.clientName,
    required this.amount,
    required this.paymentDate,
    required this.mode,
    required this.reference,
    required this.notes,
    required this.createdAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['client_name'] = Variable<String>(clientName);
    map['amount'] = Variable<double>(amount);
    map['payment_date'] = Variable<String>(paymentDate);
    map['mode'] = Variable<String>(mode);
    map['reference'] = Variable<String>(reference);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      invoiceId: Value(invoiceId),
      clientName: Value(clientName),
      amount: Value(amount),
      paymentDate: Value(paymentDate),
      mode: Value(mode),
      reference: Value(reference),
      notes: Value(notes),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      clientName: serializer.fromJson<String>(json['clientName']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentDate: serializer.fromJson<String>(json['paymentDate']),
      mode: serializer.fromJson<String>(json['mode']),
      reference: serializer.fromJson<String>(json['reference']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'clientName': serializer.toJson<String>(clientName),
      'amount': serializer.toJson<double>(amount),
      'paymentDate': serializer.toJson<String>(paymentDate),
      'mode': serializer.toJson<String>(mode),
      'reference': serializer.toJson<String>(reference),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? firmId,
    String? invoiceId,
    String? clientName,
    double? amount,
    String? paymentDate,
    String? mode,
    String? reference,
    String? notes,
    DateTime? createdAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => PaymentRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    invoiceId: invoiceId ?? this.invoiceId,
    clientName: clientName ?? this.clientName,
    amount: amount ?? this.amount,
    paymentDate: paymentDate ?? this.paymentDate,
    mode: mode ?? this.mode,
    reference: reference ?? this.reference,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  PaymentRow copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      clientName: data.clientName.present
          ? data.clientName.value
          : this.clientName,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      mode: data.mode.present ? data.mode.value : this.mode,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('clientName: $clientName, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('mode: $mode, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firmId,
    invoiceId,
    clientName,
    amount,
    paymentDate,
    mode,
    reference,
    notes,
    createdAt,
    syncedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.invoiceId == this.invoiceId &&
          other.clientName == this.clientName &&
          other.amount == this.amount &&
          other.paymentDate == this.paymentDate &&
          other.mode == this.mode &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> invoiceId;
  final Value<String> clientName;
  final Value<double> amount;
  final Value<String> paymentDate;
  final Value<String> mode;
  final Value<String> reference;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.clientName = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.mode = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String invoiceId,
    required String clientName,
    required double amount,
    required String paymentDate,
    required String mode,
    required String reference,
    required String notes,
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       invoiceId = Value(invoiceId),
       clientName = Value(clientName),
       amount = Value(amount),
       paymentDate = Value(paymentDate),
       mode = Value(mode),
       reference = Value(reference),
       notes = Value(notes);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? invoiceId,
    Expression<String>? clientName,
    Expression<double>? amount,
    Expression<String>? paymentDate,
    Expression<String>? mode,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (clientName != null) 'client_name': clientName,
      if (amount != null) 'amount': amount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (mode != null) 'mode': mode,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? invoiceId,
    Value<String>? clientName,
    Value<double>? amount,
    Value<String>? paymentDate,
    Value<String>? mode,
    Value<String>? reference,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      invoiceId: invoiceId ?? this.invoiceId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      mode: mode ?? this.mode,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<String>(paymentDate.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('clientName: $clientName, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('mode: $mode, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientNameMeta = const VerificationMeta(
    'clientName',
  );
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
    'client_name',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedByMeta = const VerificationMeta(
    'assignedBy',
  );
  @override
  late final GeneratedColumn<String> assignedBy = GeneratedColumn<String>(
    'assigned_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<String> completedDate = GeneratedColumn<String>(
    'completed_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    clientId,
    clientName,
    title,
    description,
    taskType,
    priority,
    status,
    assignedTo,
    assignedBy,
    dueDate,
    completedDate,
    tags,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('client_name')) {
      context.handle(
        _clientNameMeta,
        clientName.isAcceptableOrUnknown(data['client_name']!, _clientNameMeta),
      );
    } else if (isInserting) {
      context.missing(_clientNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedToMeta);
    }
    if (data.containsKey('assigned_by')) {
      context.handle(
        _assignedByMeta,
        assignedBy.isAcceptableOrUnknown(data['assigned_by']!, _assignedByMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedByMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      clientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      )!,
      assignedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_by'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      completedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_date'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String firmId;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final String taskType;
  final String priority;
  final String status;
  final String assignedTo;
  final String assignedBy;
  final String dueDate;
  final String? completedDate;
  final String tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncedAt;
  final bool isDirty;
  const TaskRow({
    required this.id,
    required this.firmId,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.description,
    required this.taskType,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.assignedBy,
    required this.dueDate,
    this.completedDate,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['client_id'] = Variable<String>(clientId);
    map['client_name'] = Variable<String>(clientName);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['task_type'] = Variable<String>(taskType);
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['assigned_to'] = Variable<String>(assignedTo);
    map['assigned_by'] = Variable<String>(assignedBy);
    map['due_date'] = Variable<String>(dueDate);
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<String>(completedDate);
    }
    map['tags'] = Variable<String>(tags);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      clientName: Value(clientName),
      title: Value(title),
      description: Value(description),
      taskType: Value(taskType),
      priority: Value(priority),
      status: Value(status),
      assignedTo: Value(assignedTo),
      assignedBy: Value(assignedBy),
      dueDate: Value(dueDate),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      tags: Value(tags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      clientName: serializer.fromJson<String>(json['clientName']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      taskType: serializer.fromJson<String>(json['taskType']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      assignedTo: serializer.fromJson<String>(json['assignedTo']),
      assignedBy: serializer.fromJson<String>(json['assignedBy']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      completedDate: serializer.fromJson<String?>(json['completedDate']),
      tags: serializer.fromJson<String>(json['tags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<String?>(json['syncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'clientId': serializer.toJson<String>(clientId),
      'clientName': serializer.toJson<String>(clientName),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'taskType': serializer.toJson<String>(taskType),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'assignedTo': serializer.toJson<String>(assignedTo),
      'assignedBy': serializer.toJson<String>(assignedBy),
      'dueDate': serializer.toJson<String>(dueDate),
      'completedDate': serializer.toJson<String?>(completedDate),
      'tags': serializer.toJson<String>(tags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<String?>(syncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  TaskRow copyWith({
    String? id,
    String? firmId,
    String? clientId,
    String? clientName,
    String? title,
    String? description,
    String? taskType,
    String? priority,
    String? status,
    String? assignedTo,
    String? assignedBy,
    String? dueDate,
    Value<String?> completedDate = const Value.absent(),
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
    bool? isDirty,
  }) => TaskRow(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    clientId: clientId ?? this.clientId,
    clientName: clientName ?? this.clientName,
    title: title ?? this.title,
    description: description ?? this.description,
    taskType: taskType ?? this.taskType,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    assignedTo: assignedTo ?? this.assignedTo,
    assignedBy: assignedBy ?? this.assignedBy,
    dueDate: dueDate ?? this.dueDate,
    completedDate: completedDate.present
        ? completedDate.value
        : this.completedDate,
    tags: tags ?? this.tags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  TaskRow copyWithCompanion(TasksTableCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      clientName: data.clientName.present
          ? data.clientName.value
          : this.clientName,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      assignedBy: data.assignedBy.present
          ? data.assignedBy.value
          : this.assignedBy,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('clientName: $clientName, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('taskType: $taskType, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('assignedBy: $assignedBy, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firmId,
    clientId,
    clientName,
    title,
    description,
    taskType,
    priority,
    status,
    assignedTo,
    assignedBy,
    dueDate,
    completedDate,
    tags,
    createdAt,
    updatedAt,
    syncedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.clientId == this.clientId &&
          other.clientName == this.clientName &&
          other.title == this.title &&
          other.description == this.description &&
          other.taskType == this.taskType &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.assignedTo == this.assignedTo &&
          other.assignedBy == this.assignedBy &&
          other.dueDate == this.dueDate &&
          other.completedDate == this.completedDate &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.isDirty == this.isDirty);
}

class TasksTableCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> clientId;
  final Value<String> clientName;
  final Value<String> title;
  final Value<String> description;
  final Value<String> taskType;
  final Value<String> priority;
  final Value<String> status;
  final Value<String> assignedTo;
  final Value<String> assignedBy;
  final Value<String> dueDate;
  final Value<String?> completedDate;
  final Value<String> tags;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> syncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const TasksTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.clientName = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.taskType = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.assignedBy = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksTableCompanion.insert({
    this.id = const Value.absent(),
    required String firmId,
    required String clientId,
    required String clientName,
    required String title,
    required String description,
    required String taskType,
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    required String assignedTo,
    required String assignedBy,
    required String dueDate,
    this.completedDate = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firmId = Value(firmId),
       clientId = Value(clientId),
       clientName = Value(clientName),
       title = Value(title),
       description = Value(description),
       taskType = Value(taskType),
       assignedTo = Value(assignedTo),
       assignedBy = Value(assignedBy),
       dueDate = Value(dueDate);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? clientId,
    Expression<String>? clientName,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? taskType,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<String>? assignedTo,
    Expression<String>? assignedBy,
    Expression<String>? dueDate,
    Expression<String>? completedDate,
    Expression<String>? tags,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (clientId != null) 'client_id': clientId,
      if (clientName != null) 'client_name': clientName,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (taskType != null) 'task_type': taskType,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (assignedBy != null) 'assigned_by': assignedBy,
      if (dueDate != null) 'due_date': dueDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? clientId,
    Value<String>? clientName,
    Value<String>? title,
    Value<String>? description,
    Value<String>? taskType,
    Value<String>? priority,
    Value<String>? status,
    Value<String>? assignedTo,
    Value<String>? assignedBy,
    Value<String>? dueDate,
    Value<String?>? completedDate,
    Value<String>? tags,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? syncedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return TasksTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (assignedBy.present) {
      map['assigned_by'] = Variable<String>(assignedBy.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<String>(completedDate.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('clientId: $clientId, ')
          ..write('clientName: $clientName, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('taskType: $taskType, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('assignedBy: $assignedBy, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FirmInfoTableTable extends FirmInfoTable
    with TableInfo<$FirmInfoTableTable, FirmInfoTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FirmInfoTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panNumberMeta = const VerificationMeta(
    'panNumber',
  );
  @override
  late final GeneratedColumn<String> panNumber = GeneratedColumn<String>(
    'pan_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tanNumberMeta = const VerificationMeta(
    'tanNumber',
  );
  @override
  late final GeneratedColumn<String> tanNumber = GeneratedColumn<String>(
    'tan_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dscCertificateMeta = const VerificationMeta(
    'dscCertificate',
  );
  @override
  late final GeneratedColumn<Uint8List> dscCertificate =
      GeneratedColumn<Uint8List>(
        'dsc_certificate',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bankAccountMeta = const VerificationMeta(
    'bankAccount',
  );
  @override
  late final GeneratedColumn<String> bankAccount = GeneratedColumn<String>(
    'bank_account',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationDateMeta = const VerificationMeta(
    'registrationDate',
  );
  @override
  late final GeneratedColumn<DateTime> registrationDate =
      GeneratedColumn<DateTime>(
        'registration_date',
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    city,
    state,
    pincode,
    panNumber,
    tanNumber,
    dscCertificate,
    bankAccount,
    registrationDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'firm_info_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FirmInfoTableData> instance, {
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
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('pan_number')) {
      context.handle(
        _panNumberMeta,
        panNumber.isAcceptableOrUnknown(data['pan_number']!, _panNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_panNumberMeta);
    }
    if (data.containsKey('tan_number')) {
      context.handle(
        _tanNumberMeta,
        tanNumber.isAcceptableOrUnknown(data['tan_number']!, _tanNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_tanNumberMeta);
    }
    if (data.containsKey('dsc_certificate')) {
      context.handle(
        _dscCertificateMeta,
        dscCertificate.isAcceptableOrUnknown(
          data['dsc_certificate']!,
          _dscCertificateMeta,
        ),
      );
    }
    if (data.containsKey('bank_account')) {
      context.handle(
        _bankAccountMeta,
        bankAccount.isAcceptableOrUnknown(
          data['bank_account']!,
          _bankAccountMeta,
        ),
      );
    }
    if (data.containsKey('registration_date')) {
      context.handle(
        _registrationDateMeta,
        registrationDate.isAcceptableOrUnknown(
          data['registration_date']!,
          _registrationDateMeta,
        ),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FirmInfoTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FirmInfoTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      panNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan_number'],
      )!,
      tanNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tan_number'],
      )!,
      dscCertificate: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}dsc_certificate'],
      ),
      bankAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_account'],
      ),
      registrationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registration_date'],
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
  $FirmInfoTableTable createAlias(String alias) {
    return $FirmInfoTableTable(attachedDatabase, alias);
  }
}

class FirmInfoTableData extends DataClass
    implements Insertable<FirmInfoTableData> {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? pincode;
  final String panNumber;
  final String tanNumber;
  final Uint8List? dscCertificate;
  final String? bankAccount;
  final DateTime? registrationDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FirmInfoTableData({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.pincode,
    required this.panNumber,
    required this.tanNumber,
    this.dscCertificate,
    this.bankAccount,
    this.registrationDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    map['pan_number'] = Variable<String>(panNumber);
    map['tan_number'] = Variable<String>(tanNumber);
    if (!nullToAbsent || dscCertificate != null) {
      map['dsc_certificate'] = Variable<Uint8List>(dscCertificate);
    }
    if (!nullToAbsent || bankAccount != null) {
      map['bank_account'] = Variable<String>(bankAccount);
    }
    if (!nullToAbsent || registrationDate != null) {
      map['registration_date'] = Variable<DateTime>(registrationDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FirmInfoTableCompanion toCompanion(bool nullToAbsent) {
    return FirmInfoTableCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      panNumber: Value(panNumber),
      tanNumber: Value(tanNumber),
      dscCertificate: dscCertificate == null && nullToAbsent
          ? const Value.absent()
          : Value(dscCertificate),
      bankAccount: bankAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccount),
      registrationDate: registrationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FirmInfoTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FirmInfoTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      panNumber: serializer.fromJson<String>(json['panNumber']),
      tanNumber: serializer.fromJson<String>(json['tanNumber']),
      dscCertificate: serializer.fromJson<Uint8List?>(json['dscCertificate']),
      bankAccount: serializer.fromJson<String?>(json['bankAccount']),
      registrationDate: serializer.fromJson<DateTime?>(
        json['registrationDate'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'pincode': serializer.toJson<String?>(pincode),
      'panNumber': serializer.toJson<String>(panNumber),
      'tanNumber': serializer.toJson<String>(tanNumber),
      'dscCertificate': serializer.toJson<Uint8List?>(dscCertificate),
      'bankAccount': serializer.toJson<String?>(bankAccount),
      'registrationDate': serializer.toJson<DateTime?>(registrationDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FirmInfoTableData copyWith({
    String? id,
    String? name,
    String? address,
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> pincode = const Value.absent(),
    String? panNumber,
    String? tanNumber,
    Value<Uint8List?> dscCertificate = const Value.absent(),
    Value<String?> bankAccount = const Value.absent(),
    Value<DateTime?> registrationDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FirmInfoTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    pincode: pincode.present ? pincode.value : this.pincode,
    panNumber: panNumber ?? this.panNumber,
    tanNumber: tanNumber ?? this.tanNumber,
    dscCertificate: dscCertificate.present
        ? dscCertificate.value
        : this.dscCertificate,
    bankAccount: bankAccount.present ? bankAccount.value : this.bankAccount,
    registrationDate: registrationDate.present
        ? registrationDate.value
        : this.registrationDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FirmInfoTableData copyWithCompanion(FirmInfoTableCompanion data) {
    return FirmInfoTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      panNumber: data.panNumber.present ? data.panNumber.value : this.panNumber,
      tanNumber: data.tanNumber.present ? data.tanNumber.value : this.tanNumber,
      dscCertificate: data.dscCertificate.present
          ? data.dscCertificate.value
          : this.dscCertificate,
      bankAccount: data.bankAccount.present
          ? data.bankAccount.value
          : this.bankAccount,
      registrationDate: data.registrationDate.present
          ? data.registrationDate.value
          : this.registrationDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FirmInfoTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('panNumber: $panNumber, ')
          ..write('tanNumber: $tanNumber, ')
          ..write('dscCertificate: $dscCertificate, ')
          ..write('bankAccount: $bankAccount, ')
          ..write('registrationDate: $registrationDate, ')
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
    city,
    state,
    pincode,
    panNumber,
    tanNumber,
    $driftBlobEquality.hash(dscCertificate),
    bankAccount,
    registrationDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FirmInfoTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.city == this.city &&
          other.state == this.state &&
          other.pincode == this.pincode &&
          other.panNumber == this.panNumber &&
          other.tanNumber == this.tanNumber &&
          $driftBlobEquality.equals(
            other.dscCertificate,
            this.dscCertificate,
          ) &&
          other.bankAccount == this.bankAccount &&
          other.registrationDate == this.registrationDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FirmInfoTableCompanion extends UpdateCompanion<FirmInfoTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> address;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> pincode;
  final Value<String> panNumber;
  final Value<String> tanNumber;
  final Value<Uint8List?> dscCertificate;
  final Value<String?> bankAccount;
  final Value<DateTime?> registrationDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FirmInfoTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.panNumber = const Value.absent(),
    this.tanNumber = const Value.absent(),
    this.dscCertificate = const Value.absent(),
    this.bankAccount = const Value.absent(),
    this.registrationDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FirmInfoTableCompanion.insert({
    required String id,
    required String name,
    required String address,
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    required String panNumber,
    required String tanNumber,
    this.dscCertificate = const Value.absent(),
    this.bankAccount = const Value.absent(),
    this.registrationDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       address = Value(address),
       panNumber = Value(panNumber),
       tanNumber = Value(tanNumber);
  static Insertable<FirmInfoTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? pincode,
    Expression<String>? panNumber,
    Expression<String>? tanNumber,
    Expression<Uint8List>? dscCertificate,
    Expression<String>? bankAccount,
    Expression<DateTime>? registrationDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (panNumber != null) 'pan_number': panNumber,
      if (tanNumber != null) 'tan_number': tanNumber,
      if (dscCertificate != null) 'dsc_certificate': dscCertificate,
      if (bankAccount != null) 'bank_account': bankAccount,
      if (registrationDate != null) 'registration_date': registrationDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FirmInfoTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? address,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? pincode,
    Value<String>? panNumber,
    Value<String>? tanNumber,
    Value<Uint8List?>? dscCertificate,
    Value<String?>? bankAccount,
    Value<DateTime?>? registrationDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FirmInfoTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      panNumber: panNumber ?? this.panNumber,
      tanNumber: tanNumber ?? this.tanNumber,
      dscCertificate: dscCertificate ?? this.dscCertificate,
      bankAccount: bankAccount ?? this.bankAccount,
      registrationDate: registrationDate ?? this.registrationDate,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (panNumber.present) {
      map['pan_number'] = Variable<String>(panNumber.value);
    }
    if (tanNumber.present) {
      map['tan_number'] = Variable<String>(tanNumber.value);
    }
    if (dscCertificate.present) {
      map['dsc_certificate'] = Variable<Uint8List>(dscCertificate.value);
    }
    if (bankAccount.present) {
      map['bank_account'] = Variable<String>(bankAccount.value);
    }
    if (registrationDate.present) {
      map['registration_date'] = Variable<DateTime>(registrationDate.value);
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
    return (StringBuffer('FirmInfoTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('panNumber: $panNumber, ')
          ..write('tanNumber: $tanNumber, ')
          ..write('dscCertificate: $dscCertificate, ')
          ..write('bankAccount: $bankAccount, ')
          ..write('registrationDate: $registrationDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamMembersTableTable extends TeamMembersTable
    with TableInfo<$TeamMembersTableTable, TeamMembersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamMembersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firmIdMeta = const VerificationMeta('firmId');
  @override
  late final GeneratedColumn<String> firmId = GeneratedColumn<String>(
    'firm_id',
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
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
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
  static const VerificationMeta _permissionsMeta = const VerificationMeta(
    'permissions',
  );
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
    'permissions',
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
  List<GeneratedColumn> get $columns => [
    id,
    firmId,
    name,
    pan,
    role,
    email,
    phone,
    permissions,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_members_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamMembersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('firm_id')) {
      context.handle(
        _firmIdMeta,
        firmId.isAcceptableOrUnknown(data['firm_id']!, _firmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_firmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    } else if (isInserting) {
      context.missing(_panMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
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
    if (data.containsKey('permissions')) {
      context.handle(
        _permissionsMeta,
        permissions.isAcceptableOrUnknown(
          data['permissions']!,
          _permissionsMeta,
        ),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamMembersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamMembersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      permissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions'],
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
  $TeamMembersTableTable createAlias(String alias) {
    return $TeamMembersTableTable(attachedDatabase, alias);
  }
}

class TeamMembersTableData extends DataClass
    implements Insertable<TeamMembersTableData> {
  final String id;
  final String firmId;
  final String name;
  final String pan;
  final String? role;
  final String? email;
  final String? phone;
  final String? permissions;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TeamMembersTableData({
    required this.id,
    required this.firmId,
    required this.name,
    required this.pan,
    this.role,
    this.email,
    this.phone,
    this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['firm_id'] = Variable<String>(firmId);
    map['name'] = Variable<String>(name);
    map['pan'] = Variable<String>(pan);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || permissions != null) {
      map['permissions'] = Variable<String>(permissions);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TeamMembersTableCompanion toCompanion(bool nullToAbsent) {
    return TeamMembersTableCompanion(
      id: Value(id),
      firmId: Value(firmId),
      name: Value(name),
      pan: Value(pan),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      permissions: permissions == null && nullToAbsent
          ? const Value.absent()
          : Value(permissions),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TeamMembersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamMembersTableData(
      id: serializer.fromJson<String>(json['id']),
      firmId: serializer.fromJson<String>(json['firmId']),
      name: serializer.fromJson<String>(json['name']),
      pan: serializer.fromJson<String>(json['pan']),
      role: serializer.fromJson<String?>(json['role']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      permissions: serializer.fromJson<String?>(json['permissions']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firmId': serializer.toJson<String>(firmId),
      'name': serializer.toJson<String>(name),
      'pan': serializer.toJson<String>(pan),
      'role': serializer.toJson<String?>(role),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'permissions': serializer.toJson<String?>(permissions),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TeamMembersTableData copyWith({
    String? id,
    String? firmId,
    String? name,
    String? pan,
    Value<String?> role = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> permissions = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TeamMembersTableData(
    id: id ?? this.id,
    firmId: firmId ?? this.firmId,
    name: name ?? this.name,
    pan: pan ?? this.pan,
    role: role.present ? role.value : this.role,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    permissions: permissions.present ? permissions.value : this.permissions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TeamMembersTableData copyWithCompanion(TeamMembersTableCompanion data) {
    return TeamMembersTableData(
      id: data.id.present ? data.id.value : this.id,
      firmId: data.firmId.present ? data.firmId.value : this.firmId,
      name: data.name.present ? data.name.value : this.name,
      pan: data.pan.present ? data.pan.value : this.pan,
      role: data.role.present ? data.role.value : this.role,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamMembersTableData(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('name: $name, ')
          ..write('pan: $pan, ')
          ..write('role: $role, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('permissions: $permissions, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firmId,
    name,
    pan,
    role,
    email,
    phone,
    permissions,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMembersTableData &&
          other.id == this.id &&
          other.firmId == this.firmId &&
          other.name == this.name &&
          other.pan == this.pan &&
          other.role == this.role &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.permissions == this.permissions &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TeamMembersTableCompanion extends UpdateCompanion<TeamMembersTableData> {
  final Value<String> id;
  final Value<String> firmId;
  final Value<String> name;
  final Value<String> pan;
  final Value<String?> role;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> permissions;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TeamMembersTableCompanion({
    this.id = const Value.absent(),
    this.firmId = const Value.absent(),
    this.name = const Value.absent(),
    this.pan = const Value.absent(),
    this.role = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.permissions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamMembersTableCompanion.insert({
    required String id,
    required String firmId,
    required String name,
    required String pan,
    this.role = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.permissions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firmId = Value(firmId),
       name = Value(name),
       pan = Value(pan);
  static Insertable<TeamMembersTableData> custom({
    Expression<String>? id,
    Expression<String>? firmId,
    Expression<String>? name,
    Expression<String>? pan,
    Expression<String>? role,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? permissions,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmId != null) 'firm_id': firmId,
      if (name != null) 'name': name,
      if (pan != null) 'pan': pan,
      if (role != null) 'role': role,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (permissions != null) 'permissions': permissions,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamMembersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? firmId,
    Value<String>? name,
    Value<String>? pan,
    Value<String?>? role,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? permissions,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TeamMembersTableCompanion(
      id: id ?? this.id,
      firmId: firmId ?? this.firmId,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
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
    if (firmId.present) {
      map['firm_id'] = Variable<String>(firmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
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
    return (StringBuffer('TeamMembersTableCompanion(')
          ..write('id: $id, ')
          ..write('firmId: $firmId, ')
          ..write('name: $name, ')
          ..write('pan: $pan, ')
          ..write('role: $role, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('permissions: $permissions, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientAssignmentsTableTable extends ClientAssignmentsTable
    with TableInfo<$ClientAssignmentsTableTable, ClientAssignmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientAssignmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedToIdMeta = const VerificationMeta(
    'assignedToId',
  );
  @override
  late final GeneratedColumn<String> assignedToId = GeneratedColumn<String>(
    'assigned_to_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
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
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    assignedToId,
    startDate,
    endDate,
    role,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_assignments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientAssignmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('assigned_to_id')) {
      context.handle(
        _assignedToIdMeta,
        assignedToId.isAcceptableOrUnknown(
          data['assigned_to_id']!,
          _assignedToIdMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientAssignmentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientAssignmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      assignedToId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
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
  $ClientAssignmentsTableTable createAlias(String alias) {
    return $ClientAssignmentsTableTable(attachedDatabase, alias);
  }
}

class ClientAssignmentsTableData extends DataClass
    implements Insertable<ClientAssignmentsTableData> {
  final String id;
  final String clientId;
  final String? assignedToId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ClientAssignmentsTableData({
    required this.id,
    required this.clientId,
    this.assignedToId,
    this.startDate,
    this.endDate,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || assignedToId != null) {
      map['assigned_to_id'] = Variable<String>(assignedToId);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ClientAssignmentsTableCompanion toCompanion(bool nullToAbsent) {
    return ClientAssignmentsTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      assignedToId: assignedToId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ClientAssignmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientAssignmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      assignedToId: serializer.fromJson<String?>(json['assignedToId']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      role: serializer.fromJson<String?>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'assignedToId': serializer.toJson<String?>(assignedToId),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'role': serializer.toJson<String?>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ClientAssignmentsTableData copyWith({
    String? id,
    String? clientId,
    Value<String?> assignedToId = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> role = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ClientAssignmentsTableData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    assignedToId: assignedToId.present ? assignedToId.value : this.assignedToId,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    role: role.present ? role.value : this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ClientAssignmentsTableData copyWithCompanion(
    ClientAssignmentsTableCompanion data,
  ) {
    return ClientAssignmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      assignedToId: data.assignedToId.present
          ? data.assignedToId.value
          : this.assignedToId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientAssignmentsTableData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('assignedToId: $assignedToId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    assignedToId,
    startDate,
    endDate,
    role,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientAssignmentsTableData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.assignedToId == this.assignedToId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ClientAssignmentsTableCompanion
    extends UpdateCompanion<ClientAssignmentsTableData> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> assignedToId;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ClientAssignmentsTableCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.assignedToId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientAssignmentsTableCompanion.insert({
    required String id,
    required String clientId,
    this.assignedToId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId);
  static Insertable<ClientAssignmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? assignedToId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (assignedToId != null) 'assigned_to_id': assignedToId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientAssignmentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String?>? assignedToId,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ClientAssignmentsTableCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      assignedToId: assignedToId ?? this.assignedToId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      role: role ?? this.role,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (assignedToId.present) {
      map['assigned_to_id'] = Variable<String>(assignedToId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
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
    return (StringBuffer('ClientAssignmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('assignedToId: $assignedToId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayrollEntriesTableTable extends PayrollEntriesTable
    with TableInfo<$PayrollEntriesTableTable, PayrollEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayrollEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basicSalaryMeta = const VerificationMeta(
    'basicSalary',
  );
  @override
  late final GeneratedColumn<String> basicSalary = GeneratedColumn<String>(
    'basic_salary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowancesMeta = const VerificationMeta(
    'allowances',
  );
  @override
  late final GeneratedColumn<String> allowances = GeneratedColumn<String>(
    'allowances',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deductionsMeta = const VerificationMeta(
    'deductions',
  );
  @override
  late final GeneratedColumn<String> deductions = GeneratedColumn<String>(
    'deductions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tdsDeductedMeta = const VerificationMeta(
    'tdsDeducted',
  );
  @override
  late final GeneratedColumn<String> tdsDeducted = GeneratedColumn<String>(
    'tds_deducted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pfDeductedMeta = const VerificationMeta(
    'pfDeducted',
  );
  @override
  late final GeneratedColumn<String> pfDeducted = GeneratedColumn<String>(
    'pf_deducted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _esiDeductedMeta = const VerificationMeta(
    'esiDeducted',
  );
  @override
  late final GeneratedColumn<String> esiDeducted = GeneratedColumn<String>(
    'esi_deducted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netSalaryMeta = const VerificationMeta(
    'netSalary',
  );
  @override
  late final GeneratedColumn<String> netSalary = GeneratedColumn<String>(
    'net_salary',
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
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    employeeId,
    month,
    year,
    basicSalary,
    allowances,
    deductions,
    tdsDeducted,
    pfDeducted,
    esiDeducted,
    netSalary,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payroll_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayrollEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('basic_salary')) {
      context.handle(
        _basicSalaryMeta,
        basicSalary.isAcceptableOrUnknown(
          data['basic_salary']!,
          _basicSalaryMeta,
        ),
      );
    }
    if (data.containsKey('allowances')) {
      context.handle(
        _allowancesMeta,
        allowances.isAcceptableOrUnknown(data['allowances']!, _allowancesMeta),
      );
    }
    if (data.containsKey('deductions')) {
      context.handle(
        _deductionsMeta,
        deductions.isAcceptableOrUnknown(data['deductions']!, _deductionsMeta),
      );
    }
    if (data.containsKey('tds_deducted')) {
      context.handle(
        _tdsDeductedMeta,
        tdsDeducted.isAcceptableOrUnknown(
          data['tds_deducted']!,
          _tdsDeductedMeta,
        ),
      );
    }
    if (data.containsKey('pf_deducted')) {
      context.handle(
        _pfDeductedMeta,
        pfDeducted.isAcceptableOrUnknown(data['pf_deducted']!, _pfDeductedMeta),
      );
    }
    if (data.containsKey('esi_deducted')) {
      context.handle(
        _esiDeductedMeta,
        esiDeducted.isAcceptableOrUnknown(
          data['esi_deducted']!,
          _esiDeductedMeta,
        ),
      );
    }
    if (data.containsKey('net_salary')) {
      context.handle(
        _netSalaryMeta,
        netSalary.isAcceptableOrUnknown(data['net_salary']!, _netSalaryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayrollEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayrollEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      ),
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      basicSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basic_salary'],
      ),
      allowances: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allowances'],
      ),
      deductions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deductions'],
      ),
      tdsDeducted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tds_deducted'],
      ),
      pfDeducted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pf_deducted'],
      ),
      esiDeducted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}esi_deducted'],
      ),
      netSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}net_salary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
  $PayrollEntriesTableTable createAlias(String alias) {
    return $PayrollEntriesTableTable(attachedDatabase, alias);
  }
}

class PayrollEntriesTableData extends DataClass
    implements Insertable<PayrollEntriesTableData> {
  final String id;
  final String clientId;
  final String? employeeId;
  final int month;
  final int year;
  final String? basicSalary;
  final String? allowances;
  final String? deductions;
  final String? tdsDeducted;
  final String? pfDeducted;
  final String? esiDeducted;
  final String? netSalary;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PayrollEntriesTableData({
    required this.id,
    required this.clientId,
    this.employeeId,
    required this.month,
    required this.year,
    this.basicSalary,
    this.allowances,
    this.deductions,
    this.tdsDeducted,
    this.pfDeducted,
    this.esiDeducted,
    this.netSalary,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || employeeId != null) {
      map['employee_id'] = Variable<String>(employeeId);
    }
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || basicSalary != null) {
      map['basic_salary'] = Variable<String>(basicSalary);
    }
    if (!nullToAbsent || allowances != null) {
      map['allowances'] = Variable<String>(allowances);
    }
    if (!nullToAbsent || deductions != null) {
      map['deductions'] = Variable<String>(deductions);
    }
    if (!nullToAbsent || tdsDeducted != null) {
      map['tds_deducted'] = Variable<String>(tdsDeducted);
    }
    if (!nullToAbsent || pfDeducted != null) {
      map['pf_deducted'] = Variable<String>(pfDeducted);
    }
    if (!nullToAbsent || esiDeducted != null) {
      map['esi_deducted'] = Variable<String>(esiDeducted);
    }
    if (!nullToAbsent || netSalary != null) {
      map['net_salary'] = Variable<String>(netSalary);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PayrollEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return PayrollEntriesTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      employeeId: employeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeId),
      month: Value(month),
      year: Value(year),
      basicSalary: basicSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(basicSalary),
      allowances: allowances == null && nullToAbsent
          ? const Value.absent()
          : Value(allowances),
      deductions: deductions == null && nullToAbsent
          ? const Value.absent()
          : Value(deductions),
      tdsDeducted: tdsDeducted == null && nullToAbsent
          ? const Value.absent()
          : Value(tdsDeducted),
      pfDeducted: pfDeducted == null && nullToAbsent
          ? const Value.absent()
          : Value(pfDeducted),
      esiDeducted: esiDeducted == null && nullToAbsent
          ? const Value.absent()
          : Value(esiDeducted),
      netSalary: netSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(netSalary),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PayrollEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayrollEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      employeeId: serializer.fromJson<String?>(json['employeeId']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      basicSalary: serializer.fromJson<String?>(json['basicSalary']),
      allowances: serializer.fromJson<String?>(json['allowances']),
      deductions: serializer.fromJson<String?>(json['deductions']),
      tdsDeducted: serializer.fromJson<String?>(json['tdsDeducted']),
      pfDeducted: serializer.fromJson<String?>(json['pfDeducted']),
      esiDeducted: serializer.fromJson<String?>(json['esiDeducted']),
      netSalary: serializer.fromJson<String?>(json['netSalary']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'employeeId': serializer.toJson<String?>(employeeId),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'basicSalary': serializer.toJson<String?>(basicSalary),
      'allowances': serializer.toJson<String?>(allowances),
      'deductions': serializer.toJson<String?>(deductions),
      'tdsDeducted': serializer.toJson<String?>(tdsDeducted),
      'pfDeducted': serializer.toJson<String?>(pfDeducted),
      'esiDeducted': serializer.toJson<String?>(esiDeducted),
      'netSalary': serializer.toJson<String?>(netSalary),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PayrollEntriesTableData copyWith({
    String? id,
    String? clientId,
    Value<String?> employeeId = const Value.absent(),
    int? month,
    int? year,
    Value<String?> basicSalary = const Value.absent(),
    Value<String?> allowances = const Value.absent(),
    Value<String?> deductions = const Value.absent(),
    Value<String?> tdsDeducted = const Value.absent(),
    Value<String?> pfDeducted = const Value.absent(),
    Value<String?> esiDeducted = const Value.absent(),
    Value<String?> netSalary = const Value.absent(),
    Value<String?> status = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PayrollEntriesTableData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    employeeId: employeeId.present ? employeeId.value : this.employeeId,
    month: month ?? this.month,
    year: year ?? this.year,
    basicSalary: basicSalary.present ? basicSalary.value : this.basicSalary,
    allowances: allowances.present ? allowances.value : this.allowances,
    deductions: deductions.present ? deductions.value : this.deductions,
    tdsDeducted: tdsDeducted.present ? tdsDeducted.value : this.tdsDeducted,
    pfDeducted: pfDeducted.present ? pfDeducted.value : this.pfDeducted,
    esiDeducted: esiDeducted.present ? esiDeducted.value : this.esiDeducted,
    netSalary: netSalary.present ? netSalary.value : this.netSalary,
    status: status.present ? status.value : this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PayrollEntriesTableData copyWithCompanion(PayrollEntriesTableCompanion data) {
    return PayrollEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      basicSalary: data.basicSalary.present
          ? data.basicSalary.value
          : this.basicSalary,
      allowances: data.allowances.present
          ? data.allowances.value
          : this.allowances,
      deductions: data.deductions.present
          ? data.deductions.value
          : this.deductions,
      tdsDeducted: data.tdsDeducted.present
          ? data.tdsDeducted.value
          : this.tdsDeducted,
      pfDeducted: data.pfDeducted.present
          ? data.pfDeducted.value
          : this.pfDeducted,
      esiDeducted: data.esiDeducted.present
          ? data.esiDeducted.value
          : this.esiDeducted,
      netSalary: data.netSalary.present ? data.netSalary.value : this.netSalary,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayrollEntriesTableData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('employeeId: $employeeId, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('basicSalary: $basicSalary, ')
          ..write('allowances: $allowances, ')
          ..write('deductions: $deductions, ')
          ..write('tdsDeducted: $tdsDeducted, ')
          ..write('pfDeducted: $pfDeducted, ')
          ..write('esiDeducted: $esiDeducted, ')
          ..write('netSalary: $netSalary, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    employeeId,
    month,
    year,
    basicSalary,
    allowances,
    deductions,
    tdsDeducted,
    pfDeducted,
    esiDeducted,
    netSalary,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayrollEntriesTableData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.employeeId == this.employeeId &&
          other.month == this.month &&
          other.year == this.year &&
          other.basicSalary == this.basicSalary &&
          other.allowances == this.allowances &&
          other.deductions == this.deductions &&
          other.tdsDeducted == this.tdsDeducted &&
          other.pfDeducted == this.pfDeducted &&
          other.esiDeducted == this.esiDeducted &&
          other.netSalary == this.netSalary &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PayrollEntriesTableCompanion
    extends UpdateCompanion<PayrollEntriesTableData> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> employeeId;
  final Value<int> month;
  final Value<int> year;
  final Value<String?> basicSalary;
  final Value<String?> allowances;
  final Value<String?> deductions;
  final Value<String?> tdsDeducted;
  final Value<String?> pfDeducted;
  final Value<String?> esiDeducted;
  final Value<String?> netSalary;
  final Value<String?> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PayrollEntriesTableCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.basicSalary = const Value.absent(),
    this.allowances = const Value.absent(),
    this.deductions = const Value.absent(),
    this.tdsDeducted = const Value.absent(),
    this.pfDeducted = const Value.absent(),
    this.esiDeducted = const Value.absent(),
    this.netSalary = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayrollEntriesTableCompanion.insert({
    required String id,
    required String clientId,
    this.employeeId = const Value.absent(),
    required int month,
    required int year,
    this.basicSalary = const Value.absent(),
    this.allowances = const Value.absent(),
    this.deductions = const Value.absent(),
    this.tdsDeducted = const Value.absent(),
    this.pfDeducted = const Value.absent(),
    this.esiDeducted = const Value.absent(),
    this.netSalary = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       month = Value(month),
       year = Value(year);
  static Insertable<PayrollEntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? employeeId,
    Expression<int>? month,
    Expression<int>? year,
    Expression<String>? basicSalary,
    Expression<String>? allowances,
    Expression<String>? deductions,
    Expression<String>? tdsDeducted,
    Expression<String>? pfDeducted,
    Expression<String>? esiDeducted,
    Expression<String>? netSalary,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (employeeId != null) 'employee_id': employeeId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (basicSalary != null) 'basic_salary': basicSalary,
      if (allowances != null) 'allowances': allowances,
      if (deductions != null) 'deductions': deductions,
      if (tdsDeducted != null) 'tds_deducted': tdsDeducted,
      if (pfDeducted != null) 'pf_deducted': pfDeducted,
      if (esiDeducted != null) 'esi_deducted': esiDeducted,
      if (netSalary != null) 'net_salary': netSalary,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayrollEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String?>? employeeId,
    Value<int>? month,
    Value<int>? year,
    Value<String?>? basicSalary,
    Value<String?>? allowances,
    Value<String?>? deductions,
    Value<String?>? tdsDeducted,
    Value<String?>? pfDeducted,
    Value<String?>? esiDeducted,
    Value<String?>? netSalary,
    Value<String?>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PayrollEntriesTableCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      employeeId: employeeId ?? this.employeeId,
      month: month ?? this.month,
      year: year ?? this.year,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      pfDeducted: pfDeducted ?? this.pfDeducted,
      esiDeducted: esiDeducted ?? this.esiDeducted,
      netSalary: netSalary ?? this.netSalary,
      status: status ?? this.status,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (basicSalary.present) {
      map['basic_salary'] = Variable<String>(basicSalary.value);
    }
    if (allowances.present) {
      map['allowances'] = Variable<String>(allowances.value);
    }
    if (deductions.present) {
      map['deductions'] = Variable<String>(deductions.value);
    }
    if (tdsDeducted.present) {
      map['tds_deducted'] = Variable<String>(tdsDeducted.value);
    }
    if (pfDeducted.present) {
      map['pf_deducted'] = Variable<String>(pfDeducted.value);
    }
    if (esiDeducted.present) {
      map['esi_deducted'] = Variable<String>(esiDeducted.value);
    }
    if (netSalary.present) {
      map['net_salary'] = Variable<String>(netSalary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('PayrollEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('employeeId: $employeeId, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('basicSalary: $basicSalary, ')
          ..write('allowances: $allowances, ')
          ..write('deductions: $deductions, ')
          ..write('tdsDeducted: $tdsDeducted, ')
          ..write('pfDeducted: $pfDeducted, ')
          ..write('esiDeducted: $esiDeducted, ')
          ..write('netSalary: $netSalary, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditAssignmentsTableTable extends AuditAssignmentsTable
    with TableInfo<$AuditAssignmentsTableTable, AuditAssignmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditAssignmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditorIdMeta = const VerificationMeta(
    'auditorId',
  );
  @override
  late final GeneratedColumn<String> auditorId = GeneratedColumn<String>(
    'auditor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _financialYearMeta = const VerificationMeta(
    'financialYear',
  );
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
    'financial_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<String> fee = GeneratedColumn<String>(
    'fee',
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
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    auditorId,
    financialYear,
    startDate,
    endDate,
    status,
    fee,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_assignments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditAssignmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('auditor_id')) {
      context.handle(
        _auditorIdMeta,
        auditorId.isAcceptableOrUnknown(data['auditor_id']!, _auditorIdMeta),
      );
    }
    if (data.containsKey('financial_year')) {
      context.handle(
        _financialYearMeta,
        financialYear.isAcceptableOrUnknown(
          data['financial_year']!,
          _financialYearMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditAssignmentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditAssignmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      auditorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auditor_id'],
      ),
      financialYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_year'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      fee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee'],
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
  $AuditAssignmentsTableTable createAlias(String alias) {
    return $AuditAssignmentsTableTable(attachedDatabase, alias);
  }
}

class AuditAssignmentsTableData extends DataClass
    implements Insertable<AuditAssignmentsTableData> {
  final String id;
  final String clientId;
  final String? auditorId;
  final String? financialYear;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? fee;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AuditAssignmentsTableData({
    required this.id,
    required this.clientId,
    this.auditorId,
    this.financialYear,
    this.startDate,
    this.endDate,
    this.status,
    this.fee,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || auditorId != null) {
      map['auditor_id'] = Variable<String>(auditorId);
    }
    if (!nullToAbsent || financialYear != null) {
      map['financial_year'] = Variable<String>(financialYear);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || fee != null) {
      map['fee'] = Variable<String>(fee);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AuditAssignmentsTableCompanion toCompanion(bool nullToAbsent) {
    return AuditAssignmentsTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      auditorId: auditorId == null && nullToAbsent
          ? const Value.absent()
          : Value(auditorId),
      financialYear: financialYear == null && nullToAbsent
          ? const Value.absent()
          : Value(financialYear),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      fee: fee == null && nullToAbsent ? const Value.absent() : Value(fee),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AuditAssignmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditAssignmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      auditorId: serializer.fromJson<String?>(json['auditorId']),
      financialYear: serializer.fromJson<String?>(json['financialYear']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      status: serializer.fromJson<String?>(json['status']),
      fee: serializer.fromJson<String?>(json['fee']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'auditorId': serializer.toJson<String?>(auditorId),
      'financialYear': serializer.toJson<String?>(financialYear),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'status': serializer.toJson<String?>(status),
      'fee': serializer.toJson<String?>(fee),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AuditAssignmentsTableData copyWith({
    String? id,
    String? clientId,
    Value<String?> auditorId = const Value.absent(),
    Value<String?> financialYear = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> fee = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AuditAssignmentsTableData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    auditorId: auditorId.present ? auditorId.value : this.auditorId,
    financialYear: financialYear.present
        ? financialYear.value
        : this.financialYear,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    status: status.present ? status.value : this.status,
    fee: fee.present ? fee.value : this.fee,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AuditAssignmentsTableData copyWithCompanion(
    AuditAssignmentsTableCompanion data,
  ) {
    return AuditAssignmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      auditorId: data.auditorId.present ? data.auditorId.value : this.auditorId,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      fee: data.fee.present ? data.fee.value : this.fee,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditAssignmentsTableData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('auditorId: $auditorId, ')
          ..write('financialYear: $financialYear, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('fee: $fee, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    auditorId,
    financialYear,
    startDate,
    endDate,
    status,
    fee,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditAssignmentsTableData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.auditorId == this.auditorId &&
          other.financialYear == this.financialYear &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.fee == this.fee &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AuditAssignmentsTableCompanion
    extends UpdateCompanion<AuditAssignmentsTableData> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> auditorId;
  final Value<String?> financialYear;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> status;
  final Value<String?> fee;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AuditAssignmentsTableCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.auditorId = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.fee = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditAssignmentsTableCompanion.insert({
    required String id,
    required String clientId,
    this.auditorId = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.fee = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId);
  static Insertable<AuditAssignmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? auditorId,
    Expression<String>? financialYear,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<String>? fee,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (auditorId != null) 'auditor_id': auditorId,
      if (financialYear != null) 'financial_year': financialYear,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (fee != null) 'fee': fee,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditAssignmentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String?>? auditorId,
    Value<String?>? financialYear,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? status,
    Value<String?>? fee,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AuditAssignmentsTableCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      auditorId: auditorId ?? this.auditorId,
      financialYear: financialYear ?? this.financialYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      fee: fee ?? this.fee,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (auditorId.present) {
      map['auditor_id'] = Variable<String>(auditorId.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fee.present) {
      map['fee'] = Variable<String>(fee.value);
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
    return (StringBuffer('AuditAssignmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('auditorId: $auditorId, ')
          ..write('financialYear: $financialYear, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('fee: $fee, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditReportsTableTable extends AuditReportsTable
    with TableInfo<$AuditReportsTableTable, AuditReportsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditReportsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _saReportNumberMeta = const VerificationMeta(
    'saReportNumber',
  );
  @override
  late final GeneratedColumn<String> saReportNumber = GeneratedColumn<String>(
    'sa_report_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportDateMeta = const VerificationMeta(
    'reportDate',
  );
  @override
  late final GeneratedColumn<DateTime> reportDate = GeneratedColumn<DateTime>(
    'report_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportedByMeta = const VerificationMeta(
    'reportedBy',
  );
  @override
  late final GeneratedColumn<String> reportedBy = GeneratedColumn<String>(
    'reported_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _auditFindingsMeta = const VerificationMeta(
    'auditFindings',
  );
  @override
  late final GeneratedColumn<String> auditFindings = GeneratedColumn<String>(
    'audit_findings',
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
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    year,
    saReportNumber,
    reportDate,
    reportedBy,
    auditFindings,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_reports_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditReportsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('sa_report_number')) {
      context.handle(
        _saReportNumberMeta,
        saReportNumber.isAcceptableOrUnknown(
          data['sa_report_number']!,
          _saReportNumberMeta,
        ),
      );
    }
    if (data.containsKey('report_date')) {
      context.handle(
        _reportDateMeta,
        reportDate.isAcceptableOrUnknown(data['report_date']!, _reportDateMeta),
      );
    }
    if (data.containsKey('reported_by')) {
      context.handle(
        _reportedByMeta,
        reportedBy.isAcceptableOrUnknown(data['reported_by']!, _reportedByMeta),
      );
    }
    if (data.containsKey('audit_findings')) {
      context.handle(
        _auditFindingsMeta,
        auditFindings.isAcceptableOrUnknown(
          data['audit_findings']!,
          _auditFindingsMeta,
        ),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditReportsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditReportsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      saReportNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sa_report_number'],
      ),
      reportDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}report_date'],
      ),
      reportedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_by'],
      ),
      auditFindings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_findings'],
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
  $AuditReportsTableTable createAlias(String alias) {
    return $AuditReportsTableTable(attachedDatabase, alias);
  }
}

class AuditReportsTableData extends DataClass
    implements Insertable<AuditReportsTableData> {
  final String id;
  final String clientId;
  final int year;
  final String? saReportNumber;
  final DateTime? reportDate;
  final String? reportedBy;
  final String? auditFindings;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AuditReportsTableData({
    required this.id,
    required this.clientId,
    required this.year,
    this.saReportNumber,
    this.reportDate,
    this.reportedBy,
    this.auditFindings,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || saReportNumber != null) {
      map['sa_report_number'] = Variable<String>(saReportNumber);
    }
    if (!nullToAbsent || reportDate != null) {
      map['report_date'] = Variable<DateTime>(reportDate);
    }
    if (!nullToAbsent || reportedBy != null) {
      map['reported_by'] = Variable<String>(reportedBy);
    }
    if (!nullToAbsent || auditFindings != null) {
      map['audit_findings'] = Variable<String>(auditFindings);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AuditReportsTableCompanion toCompanion(bool nullToAbsent) {
    return AuditReportsTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      year: Value(year),
      saReportNumber: saReportNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(saReportNumber),
      reportDate: reportDate == null && nullToAbsent
          ? const Value.absent()
          : Value(reportDate),
      reportedBy: reportedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedBy),
      auditFindings: auditFindings == null && nullToAbsent
          ? const Value.absent()
          : Value(auditFindings),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AuditReportsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditReportsTableData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      year: serializer.fromJson<int>(json['year']),
      saReportNumber: serializer.fromJson<String?>(json['saReportNumber']),
      reportDate: serializer.fromJson<DateTime?>(json['reportDate']),
      reportedBy: serializer.fromJson<String?>(json['reportedBy']),
      auditFindings: serializer.fromJson<String?>(json['auditFindings']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'year': serializer.toJson<int>(year),
      'saReportNumber': serializer.toJson<String?>(saReportNumber),
      'reportDate': serializer.toJson<DateTime?>(reportDate),
      'reportedBy': serializer.toJson<String?>(reportedBy),
      'auditFindings': serializer.toJson<String?>(auditFindings),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AuditReportsTableData copyWith({
    String? id,
    String? clientId,
    int? year,
    Value<String?> saReportNumber = const Value.absent(),
    Value<DateTime?> reportDate = const Value.absent(),
    Value<String?> reportedBy = const Value.absent(),
    Value<String?> auditFindings = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AuditReportsTableData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    year: year ?? this.year,
    saReportNumber: saReportNumber.present
        ? saReportNumber.value
        : this.saReportNumber,
    reportDate: reportDate.present ? reportDate.value : this.reportDate,
    reportedBy: reportedBy.present ? reportedBy.value : this.reportedBy,
    auditFindings: auditFindings.present
        ? auditFindings.value
        : this.auditFindings,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AuditReportsTableData copyWithCompanion(AuditReportsTableCompanion data) {
    return AuditReportsTableData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      year: data.year.present ? data.year.value : this.year,
      saReportNumber: data.saReportNumber.present
          ? data.saReportNumber.value
          : this.saReportNumber,
      reportDate: data.reportDate.present
          ? data.reportDate.value
          : this.reportDate,
      reportedBy: data.reportedBy.present
          ? data.reportedBy.value
          : this.reportedBy,
      auditFindings: data.auditFindings.present
          ? data.auditFindings.value
          : this.auditFindings,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditReportsTableData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('year: $year, ')
          ..write('saReportNumber: $saReportNumber, ')
          ..write('reportDate: $reportDate, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('auditFindings: $auditFindings, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    year,
    saReportNumber,
    reportDate,
    reportedBy,
    auditFindings,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditReportsTableData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.year == this.year &&
          other.saReportNumber == this.saReportNumber &&
          other.reportDate == this.reportDate &&
          other.reportedBy == this.reportedBy &&
          other.auditFindings == this.auditFindings &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AuditReportsTableCompanion
    extends UpdateCompanion<AuditReportsTableData> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<int> year;
  final Value<String?> saReportNumber;
  final Value<DateTime?> reportDate;
  final Value<String?> reportedBy;
  final Value<String?> auditFindings;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AuditReportsTableCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.year = const Value.absent(),
    this.saReportNumber = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.reportedBy = const Value.absent(),
    this.auditFindings = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditReportsTableCompanion.insert({
    required String id,
    required String clientId,
    required int year,
    this.saReportNumber = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.reportedBy = const Value.absent(),
    this.auditFindings = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       year = Value(year);
  static Insertable<AuditReportsTableData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<int>? year,
    Expression<String>? saReportNumber,
    Expression<DateTime>? reportDate,
    Expression<String>? reportedBy,
    Expression<String>? auditFindings,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (year != null) 'year': year,
      if (saReportNumber != null) 'sa_report_number': saReportNumber,
      if (reportDate != null) 'report_date': reportDate,
      if (reportedBy != null) 'reported_by': reportedBy,
      if (auditFindings != null) 'audit_findings': auditFindings,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditReportsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<int>? year,
    Value<String?>? saReportNumber,
    Value<DateTime?>? reportDate,
    Value<String?>? reportedBy,
    Value<String?>? auditFindings,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AuditReportsTableCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      year: year ?? this.year,
      saReportNumber: saReportNumber ?? this.saReportNumber,
      reportDate: reportDate ?? this.reportDate,
      reportedBy: reportedBy ?? this.reportedBy,
      auditFindings: auditFindings ?? this.auditFindings,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (saReportNumber.present) {
      map['sa_report_number'] = Variable<String>(saReportNumber.value);
    }
    if (reportDate.present) {
      map['report_date'] = Variable<DateTime>(reportDate.value);
    }
    if (reportedBy.present) {
      map['reported_by'] = Variable<String>(reportedBy.value);
    }
    if (auditFindings.present) {
      map['audit_findings'] = Variable<String>(auditFindings.value);
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
    return (StringBuffer('AuditReportsTableCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('year: $year, ')
          ..write('saReportNumber: $saReportNumber, ')
          ..write('reportDate: $reportDate, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('auditFindings: $auditFindings, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MCAFilingsTableTable extends MCAFilingsTable
    with TableInfo<$MCAFilingsTableTable, MCAFilingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MCAFilingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formTypeMeta = const VerificationMeta(
    'formType',
  );
  @override
  late final GeneratedColumn<String> formType = GeneratedColumn<String>(
    'form_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _financialYearMeta = const VerificationMeta(
    'financialYear',
  );
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
    'financial_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _filedDateMeta = const VerificationMeta(
    'filedDate',
  );
  @override
  late final GeneratedColumn<DateTime> filedDate = GeneratedColumn<DateTime>(
    'filed_date',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filingNumberMeta = const VerificationMeta(
    'filingNumber',
  );
  @override
  late final GeneratedColumn<String> filingNumber = GeneratedColumn<String>(
    'filing_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
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
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    formType,
    financialYear,
    dueDate,
    filedDate,
    status,
    filingNumber,
    remarks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'm_c_a_filings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MCAFilingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('form_type')) {
      context.handle(
        _formTypeMeta,
        formType.isAcceptableOrUnknown(data['form_type']!, _formTypeMeta),
      );
    }
    if (data.containsKey('financial_year')) {
      context.handle(
        _financialYearMeta,
        financialYear.isAcceptableOrUnknown(
          data['financial_year']!,
          _financialYearMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('filed_date')) {
      context.handle(
        _filedDateMeta,
        filedDate.isAcceptableOrUnknown(data['filed_date']!, _filedDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('filing_number')) {
      context.handle(
        _filingNumberMeta,
        filingNumber.isAcceptableOrUnknown(
          data['filing_number']!,
          _filingNumberMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MCAFilingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MCAFilingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      formType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_type'],
      ),
      financialYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_year'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      filedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}filed_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      filingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filing_number'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
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
  $MCAFilingsTableTable createAlias(String alias) {
    return $MCAFilingsTableTable(attachedDatabase, alias);
  }
}

class MCAFilingsTableData extends DataClass
    implements Insertable<MCAFilingsTableData> {
  final String id;
  final String clientId;
  final String? formType;
  final String? financialYear;
  final DateTime? dueDate;
  final DateTime? filedDate;
  final String? status;
  final String? filingNumber;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MCAFilingsTableData({
    required this.id,
    required this.clientId,
    this.formType,
    this.financialYear,
    this.dueDate,
    this.filedDate,
    this.status,
    this.filingNumber,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || formType != null) {
      map['form_type'] = Variable<String>(formType);
    }
    if (!nullToAbsent || financialYear != null) {
      map['financial_year'] = Variable<String>(financialYear);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || filedDate != null) {
      map['filed_date'] = Variable<DateTime>(filedDate);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || filingNumber != null) {
      map['filing_number'] = Variable<String>(filingNumber);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MCAFilingsTableCompanion toCompanion(bool nullToAbsent) {
    return MCAFilingsTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      formType: formType == null && nullToAbsent
          ? const Value.absent()
          : Value(formType),
      financialYear: financialYear == null && nullToAbsent
          ? const Value.absent()
          : Value(financialYear),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      filedDate: filedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(filedDate),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      filingNumber: filingNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(filingNumber),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MCAFilingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MCAFilingsTableData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      formType: serializer.fromJson<String?>(json['formType']),
      financialYear: serializer.fromJson<String?>(json['financialYear']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      filedDate: serializer.fromJson<DateTime?>(json['filedDate']),
      status: serializer.fromJson<String?>(json['status']),
      filingNumber: serializer.fromJson<String?>(json['filingNumber']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'formType': serializer.toJson<String?>(formType),
      'financialYear': serializer.toJson<String?>(financialYear),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'filedDate': serializer.toJson<DateTime?>(filedDate),
      'status': serializer.toJson<String?>(status),
      'filingNumber': serializer.toJson<String?>(filingNumber),
      'remarks': serializer.toJson<String?>(remarks),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MCAFilingsTableData copyWith({
    String? id,
    String? clientId,
    Value<String?> formType = const Value.absent(),
    Value<String?> financialYear = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> filedDate = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> filingNumber = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MCAFilingsTableData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    formType: formType.present ? formType.value : this.formType,
    financialYear: financialYear.present
        ? financialYear.value
        : this.financialYear,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    filedDate: filedDate.present ? filedDate.value : this.filedDate,
    status: status.present ? status.value : this.status,
    filingNumber: filingNumber.present ? filingNumber.value : this.filingNumber,
    remarks: remarks.present ? remarks.value : this.remarks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MCAFilingsTableData copyWithCompanion(MCAFilingsTableCompanion data) {
    return MCAFilingsTableData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      formType: data.formType.present ? data.formType.value : this.formType,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      filedDate: data.filedDate.present ? data.filedDate.value : this.filedDate,
      status: data.status.present ? data.status.value : this.status,
      filingNumber: data.filingNumber.present
          ? data.filingNumber.value
          : this.filingNumber,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MCAFilingsTableData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('formType: $formType, ')
          ..write('financialYear: $financialYear, ')
          ..write('dueDate: $dueDate, ')
          ..write('filedDate: $filedDate, ')
          ..write('status: $status, ')
          ..write('filingNumber: $filingNumber, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    formType,
    financialYear,
    dueDate,
    filedDate,
    status,
    filingNumber,
    remarks,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MCAFilingsTableData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.formType == this.formType &&
          other.financialYear == this.financialYear &&
          other.dueDate == this.dueDate &&
          other.filedDate == this.filedDate &&
          other.status == this.status &&
          other.filingNumber == this.filingNumber &&
          other.remarks == this.remarks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MCAFilingsTableCompanion extends UpdateCompanion<MCAFilingsTableData> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> formType;
  final Value<String?> financialYear;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> filedDate;
  final Value<String?> status;
  final Value<String?> filingNumber;
  final Value<String?> remarks;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MCAFilingsTableCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.formType = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.filingNumber = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MCAFilingsTableCompanion.insert({
    required String id,
    required String clientId,
    this.formType = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.filedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.filingNumber = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId);
  static Insertable<MCAFilingsTableData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? formType,
    Expression<String>? financialYear,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? filedDate,
    Expression<String>? status,
    Expression<String>? filingNumber,
    Expression<String>? remarks,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (formType != null) 'form_type': formType,
      if (financialYear != null) 'financial_year': financialYear,
      if (dueDate != null) 'due_date': dueDate,
      if (filedDate != null) 'filed_date': filedDate,
      if (status != null) 'status': status,
      if (filingNumber != null) 'filing_number': filingNumber,
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MCAFilingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String?>? formType,
    Value<String?>? financialYear,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? filedDate,
    Value<String?>? status,
    Value<String?>? filingNumber,
    Value<String?>? remarks,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MCAFilingsTableCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      formType: formType ?? this.formType,
      financialYear: financialYear ?? this.financialYear,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      filingNumber: filingNumber ?? this.filingNumber,
      remarks: remarks ?? this.remarks,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (formType.present) {
      map['form_type'] = Variable<String>(formType.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (filedDate.present) {
      map['filed_date'] = Variable<DateTime>(filedDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (filingNumber.present) {
      map['filing_number'] = Variable<String>(filingNumber.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
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
    return (StringBuffer('MCAFilingsTableCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('formType: $formType, ')
          ..write('financialYear: $financialYear, ')
          ..write('dueDate: $dueDate, ')
          ..write('filedDate: $filedDate, ')
          ..write('status: $status, ')
          ..write('filingNumber: $filingNumber, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReconciliationResultsTableTable extends ReconciliationResultsTable
    with
        TableInfo<
          $ReconciliationResultsTableTable,
          ReconciliationResultsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReconciliationResultsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reconciliationTypeMeta =
      const VerificationMeta('reconciliationType');
  @override
  late final GeneratedColumn<String> reconciliationType =
      GeneratedColumn<String>(
        'reconciliation_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMatchedMeta = const VerificationMeta(
    'totalMatched',
  );
  @override
  late final GeneratedColumn<int> totalMatched = GeneratedColumn<int>(
    'total_matched',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalUnmatchedMeta = const VerificationMeta(
    'totalUnmatched',
  );
  @override
  late final GeneratedColumn<int> totalUnmatched = GeneratedColumn<int>(
    'total_unmatched',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discrepanciesMeta = const VerificationMeta(
    'discrepancies',
  );
  @override
  late final GeneratedColumn<String> discrepancies = GeneratedColumn<String>(
    'discrepancies',
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
  static const VerificationMeta _reviewedByMeta = const VerificationMeta(
    'reviewedBy',
  );
  @override
  late final GeneratedColumn<String> reviewedBy = GeneratedColumn<String>(
    'reviewed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedDateMeta = const VerificationMeta(
    'reviewedDate',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedDate = GeneratedColumn<DateTime>(
    'reviewed_date',
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
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    reconciliationType,
    period,
    totalMatched,
    totalUnmatched,
    discrepancies,
    status,
    reviewedBy,
    reviewedDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reconciliation_results_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReconciliationResultsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('reconciliation_type')) {
      context.handle(
        _reconciliationTypeMeta,
        reconciliationType.isAcceptableOrUnknown(
          data['reconciliation_type']!,
          _reconciliationTypeMeta,
        ),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('total_matched')) {
      context.handle(
        _totalMatchedMeta,
        totalMatched.isAcceptableOrUnknown(
          data['total_matched']!,
          _totalMatchedMeta,
        ),
      );
    }
    if (data.containsKey('total_unmatched')) {
      context.handle(
        _totalUnmatchedMeta,
        totalUnmatched.isAcceptableOrUnknown(
          data['total_unmatched']!,
          _totalUnmatchedMeta,
        ),
      );
    }
    if (data.containsKey('discrepancies')) {
      context.handle(
        _discrepanciesMeta,
        discrepancies.isAcceptableOrUnknown(
          data['discrepancies']!,
          _discrepanciesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('reviewed_by')) {
      context.handle(
        _reviewedByMeta,
        reviewedBy.isAcceptableOrUnknown(data['reviewed_by']!, _reviewedByMeta),
      );
    }
    if (data.containsKey('reviewed_date')) {
      context.handle(
        _reviewedDateMeta,
        reviewedDate.isAcceptableOrUnknown(
          data['reviewed_date']!,
          _reviewedDateMeta,
        ),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReconciliationResultsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReconciliationResultsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      reconciliationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reconciliation_type'],
      ),
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      ),
      totalMatched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_matched'],
      ),
      totalUnmatched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_unmatched'],
      ),
      discrepancies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discrepancies'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      reviewedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_by'],
      ),
      reviewedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_date'],
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
  $ReconciliationResultsTableTable createAlias(String alias) {
    return $ReconciliationResultsTableTable(attachedDatabase, alias);
  }
}

class ReconciliationResultsTableData extends DataClass
    implements Insertable<ReconciliationResultsTableData> {
  final String id;
  final String clientId;
  final String? reconciliationType;
  final String? period;
  final int? totalMatched;
  final int? totalUnmatched;
  final String? discrepancies;
  final String? status;
  final String? reviewedBy;
  final DateTime? reviewedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReconciliationResultsTableData({
    required this.id,
    required this.clientId,
    this.reconciliationType,
    this.period,
    this.totalMatched,
    this.totalUnmatched,
    this.discrepancies,
    this.status,
    this.reviewedBy,
    this.reviewedDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || reconciliationType != null) {
      map['reconciliation_type'] = Variable<String>(reconciliationType);
    }
    if (!nullToAbsent || period != null) {
      map['period'] = Variable<String>(period);
    }
    if (!nullToAbsent || totalMatched != null) {
      map['total_matched'] = Variable<int>(totalMatched);
    }
    if (!nullToAbsent || totalUnmatched != null) {
      map['total_unmatched'] = Variable<int>(totalUnmatched);
    }
    if (!nullToAbsent || discrepancies != null) {
      map['discrepancies'] = Variable<String>(discrepancies);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || reviewedBy != null) {
      map['reviewed_by'] = Variable<String>(reviewedBy);
    }
    if (!nullToAbsent || reviewedDate != null) {
      map['reviewed_date'] = Variable<DateTime>(reviewedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReconciliationResultsTableCompanion toCompanion(bool nullToAbsent) {
    return ReconciliationResultsTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      reconciliationType: reconciliationType == null && nullToAbsent
          ? const Value.absent()
          : Value(reconciliationType),
      period: period == null && nullToAbsent
          ? const Value.absent()
          : Value(period),
      totalMatched: totalMatched == null && nullToAbsent
          ? const Value.absent()
          : Value(totalMatched),
      totalUnmatched: totalUnmatched == null && nullToAbsent
          ? const Value.absent()
          : Value(totalUnmatched),
      discrepancies: discrepancies == null && nullToAbsent
          ? const Value.absent()
          : Value(discrepancies),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      reviewedBy: reviewedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedBy),
      reviewedDate: reviewedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReconciliationResultsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReconciliationResultsTableData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      reconciliationType: serializer.fromJson<String?>(
        json['reconciliationType'],
      ),
      period: serializer.fromJson<String?>(json['period']),
      totalMatched: serializer.fromJson<int?>(json['totalMatched']),
      totalUnmatched: serializer.fromJson<int?>(json['totalUnmatched']),
      discrepancies: serializer.fromJson<String?>(json['discrepancies']),
      status: serializer.fromJson<String?>(json['status']),
      reviewedBy: serializer.fromJson<String?>(json['reviewedBy']),
      reviewedDate: serializer.fromJson<DateTime?>(json['reviewedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'reconciliationType': serializer.toJson<String?>(reconciliationType),
      'period': serializer.toJson<String?>(period),
      'totalMatched': serializer.toJson<int?>(totalMatched),
      'totalUnmatched': serializer.toJson<int?>(totalUnmatched),
      'discrepancies': serializer.toJson<String?>(discrepancies),
      'status': serializer.toJson<String?>(status),
      'reviewedBy': serializer.toJson<String?>(reviewedBy),
      'reviewedDate': serializer.toJson<DateTime?>(reviewedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReconciliationResultsTableData copyWith({
    String? id,
    String? clientId,
    Value<String?> reconciliationType = const Value.absent(),
    Value<String?> period = const Value.absent(),
    Value<int?> totalMatched = const Value.absent(),
    Value<int?> totalUnmatched = const Value.absent(),
    Value<String?> discrepancies = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> reviewedBy = const Value.absent(),
    Value<DateTime?> reviewedDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReconciliationResultsTableData(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    reconciliationType: reconciliationType.present
        ? reconciliationType.value
        : this.reconciliationType,
    period: period.present ? period.value : this.period,
    totalMatched: totalMatched.present ? totalMatched.value : this.totalMatched,
    totalUnmatched: totalUnmatched.present
        ? totalUnmatched.value
        : this.totalUnmatched,
    discrepancies: discrepancies.present
        ? discrepancies.value
        : this.discrepancies,
    status: status.present ? status.value : this.status,
    reviewedBy: reviewedBy.present ? reviewedBy.value : this.reviewedBy,
    reviewedDate: reviewedDate.present ? reviewedDate.value : this.reviewedDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReconciliationResultsTableData copyWithCompanion(
    ReconciliationResultsTableCompanion data,
  ) {
    return ReconciliationResultsTableData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      reconciliationType: data.reconciliationType.present
          ? data.reconciliationType.value
          : this.reconciliationType,
      period: data.period.present ? data.period.value : this.period,
      totalMatched: data.totalMatched.present
          ? data.totalMatched.value
          : this.totalMatched,
      totalUnmatched: data.totalUnmatched.present
          ? data.totalUnmatched.value
          : this.totalUnmatched,
      discrepancies: data.discrepancies.present
          ? data.discrepancies.value
          : this.discrepancies,
      status: data.status.present ? data.status.value : this.status,
      reviewedBy: data.reviewedBy.present
          ? data.reviewedBy.value
          : this.reviewedBy,
      reviewedDate: data.reviewedDate.present
          ? data.reviewedDate.value
          : this.reviewedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReconciliationResultsTableData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('reconciliationType: $reconciliationType, ')
          ..write('period: $period, ')
          ..write('totalMatched: $totalMatched, ')
          ..write('totalUnmatched: $totalUnmatched, ')
          ..write('discrepancies: $discrepancies, ')
          ..write('status: $status, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedDate: $reviewedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    reconciliationType,
    period,
    totalMatched,
    totalUnmatched,
    discrepancies,
    status,
    reviewedBy,
    reviewedDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReconciliationResultsTableData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.reconciliationType == this.reconciliationType &&
          other.period == this.period &&
          other.totalMatched == this.totalMatched &&
          other.totalUnmatched == this.totalUnmatched &&
          other.discrepancies == this.discrepancies &&
          other.status == this.status &&
          other.reviewedBy == this.reviewedBy &&
          other.reviewedDate == this.reviewedDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReconciliationResultsTableCompanion
    extends UpdateCompanion<ReconciliationResultsTableData> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> reconciliationType;
  final Value<String?> period;
  final Value<int?> totalMatched;
  final Value<int?> totalUnmatched;
  final Value<String?> discrepancies;
  final Value<String?> status;
  final Value<String?> reviewedBy;
  final Value<DateTime?> reviewedDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReconciliationResultsTableCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.reconciliationType = const Value.absent(),
    this.period = const Value.absent(),
    this.totalMatched = const Value.absent(),
    this.totalUnmatched = const Value.absent(),
    this.discrepancies = const Value.absent(),
    this.status = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReconciliationResultsTableCompanion.insert({
    required String id,
    required String clientId,
    this.reconciliationType = const Value.absent(),
    this.period = const Value.absent(),
    this.totalMatched = const Value.absent(),
    this.totalUnmatched = const Value.absent(),
    this.discrepancies = const Value.absent(),
    this.status = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId);
  static Insertable<ReconciliationResultsTableData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? reconciliationType,
    Expression<String>? period,
    Expression<int>? totalMatched,
    Expression<int>? totalUnmatched,
    Expression<String>? discrepancies,
    Expression<String>? status,
    Expression<String>? reviewedBy,
    Expression<DateTime>? reviewedDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (reconciliationType != null) 'reconciliation_type': reconciliationType,
      if (period != null) 'period': period,
      if (totalMatched != null) 'total_matched': totalMatched,
      if (totalUnmatched != null) 'total_unmatched': totalUnmatched,
      if (discrepancies != null) 'discrepancies': discrepancies,
      if (status != null) 'status': status,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedDate != null) 'reviewed_date': reviewedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReconciliationResultsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String?>? reconciliationType,
    Value<String?>? period,
    Value<int?>? totalMatched,
    Value<int?>? totalUnmatched,
    Value<String?>? discrepancies,
    Value<String?>? status,
    Value<String?>? reviewedBy,
    Value<DateTime?>? reviewedDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReconciliationResultsTableCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      reconciliationType: reconciliationType ?? this.reconciliationType,
      period: period ?? this.period,
      totalMatched: totalMatched ?? this.totalMatched,
      totalUnmatched: totalUnmatched ?? this.totalUnmatched,
      discrepancies: discrepancies ?? this.discrepancies,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedDate: reviewedDate ?? this.reviewedDate,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (reconciliationType.present) {
      map['reconciliation_type'] = Variable<String>(reconciliationType.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (totalMatched.present) {
      map['total_matched'] = Variable<int>(totalMatched.value);
    }
    if (totalUnmatched.present) {
      map['total_unmatched'] = Variable<int>(totalUnmatched.value);
    }
    if (discrepancies.present) {
      map['discrepancies'] = Variable<String>(discrepancies.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reviewedBy.present) {
      map['reviewed_by'] = Variable<String>(reviewedBy.value);
    }
    if (reviewedDate.present) {
      map['reviewed_date'] = Variable<DateTime>(reviewedDate.value);
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
    return (StringBuffer('ReconciliationResultsTableCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('reconciliationType: $reconciliationType, ')
          ..write('period: $period, ')
          ..write('totalMatched: $totalMatched, ')
          ..write('totalUnmatched: $totalUnmatched, ')
          ..write('discrepancies: $discrepancies, ')
          ..write('status: $status, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedDate: $reviewedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PortalCredentialsTableTable extends PortalCredentialsTable
    with TableInfo<$PortalCredentialsTableTable, PortalCredentialsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PortalCredentialsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portalTypeMeta = const VerificationMeta(
    'portalType',
  );
  @override
  late final GeneratedColumn<String> portalType = GeneratedColumn<String>(
    'portal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedPasswordMeta = const VerificationMeta(
    'encryptedPassword',
  );
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>(
        'encrypted_password',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _grantTokenMeta = const VerificationMeta(
    'grantToken',
  );
  @override
  late final GeneratedColumn<String> grantToken = GeneratedColumn<String>(
    'grant_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refreshTokenMeta = const VerificationMeta(
    'refreshToken',
  );
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
    'refresh_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncDateMeta = const VerificationMeta(
    'lastSyncDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncDate = GeneratedColumn<DateTime>(
    'last_sync_date',
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
  List<GeneratedColumn> get $columns => [
    id,
    portalType,
    username,
    encryptedPassword,
    grantToken,
    refreshToken,
    expiresAt,
    lastSyncDate,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portal_credentials_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PortalCredentialsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('portal_type')) {
      context.handle(
        _portalTypeMeta,
        portalType.isAcceptableOrUnknown(data['portal_type']!, _portalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_portalTypeMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
        _encryptedPasswordMeta,
        encryptedPassword.isAcceptableOrUnknown(
          data['encrypted_password']!,
          _encryptedPasswordMeta,
        ),
      );
    }
    if (data.containsKey('grant_token')) {
      context.handle(
        _grantTokenMeta,
        grantToken.isAcceptableOrUnknown(data['grant_token']!, _grantTokenMeta),
      );
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
        _refreshTokenMeta,
        refreshToken.isAcceptableOrUnknown(
          data['refresh_token']!,
          _refreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('last_sync_date')) {
      context.handle(
        _lastSyncDateMeta,
        lastSyncDate.isAcceptableOrUnknown(
          data['last_sync_date']!,
          _lastSyncDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PortalCredentialsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PortalCredentialsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      portalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portal_type'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      encryptedPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_password'],
      ),
      grantToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grant_token'],
      ),
      refreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refresh_token'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      lastSyncDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
  $PortalCredentialsTableTable createAlias(String alias) {
    return $PortalCredentialsTableTable(attachedDatabase, alias);
  }
}

class PortalCredentialsTableData extends DataClass
    implements Insertable<PortalCredentialsTableData> {
  final String id;
  final String portalType;
  final String? username;
  final String? encryptedPassword;
  final String? grantToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final DateTime? lastSyncDate;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PortalCredentialsTableData({
    required this.id,
    required this.portalType,
    this.username,
    this.encryptedPassword,
    this.grantToken,
    this.refreshToken,
    this.expiresAt,
    this.lastSyncDate,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['portal_type'] = Variable<String>(portalType);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || encryptedPassword != null) {
      map['encrypted_password'] = Variable<String>(encryptedPassword);
    }
    if (!nullToAbsent || grantToken != null) {
      map['grant_token'] = Variable<String>(grantToken);
    }
    if (!nullToAbsent || refreshToken != null) {
      map['refresh_token'] = Variable<String>(refreshToken);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || lastSyncDate != null) {
      map['last_sync_date'] = Variable<DateTime>(lastSyncDate);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PortalCredentialsTableCompanion toCompanion(bool nullToAbsent) {
    return PortalCredentialsTableCompanion(
      id: Value(id),
      portalType: Value(portalType),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      encryptedPassword: encryptedPassword == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedPassword),
      grantToken: grantToken == null && nullToAbsent
          ? const Value.absent()
          : Value(grantToken),
      refreshToken: refreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshToken),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      lastSyncDate: lastSyncDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncDate),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PortalCredentialsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PortalCredentialsTableData(
      id: serializer.fromJson<String>(json['id']),
      portalType: serializer.fromJson<String>(json['portalType']),
      username: serializer.fromJson<String?>(json['username']),
      encryptedPassword: serializer.fromJson<String?>(
        json['encryptedPassword'],
      ),
      grantToken: serializer.fromJson<String?>(json['grantToken']),
      refreshToken: serializer.fromJson<String?>(json['refreshToken']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      lastSyncDate: serializer.fromJson<DateTime?>(json['lastSyncDate']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'portalType': serializer.toJson<String>(portalType),
      'username': serializer.toJson<String?>(username),
      'encryptedPassword': serializer.toJson<String?>(encryptedPassword),
      'grantToken': serializer.toJson<String?>(grantToken),
      'refreshToken': serializer.toJson<String?>(refreshToken),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'lastSyncDate': serializer.toJson<DateTime?>(lastSyncDate),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PortalCredentialsTableData copyWith({
    String? id,
    String? portalType,
    Value<String?> username = const Value.absent(),
    Value<String?> encryptedPassword = const Value.absent(),
    Value<String?> grantToken = const Value.absent(),
    Value<String?> refreshToken = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<DateTime?> lastSyncDate = const Value.absent(),
    Value<String?> status = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PortalCredentialsTableData(
    id: id ?? this.id,
    portalType: portalType ?? this.portalType,
    username: username.present ? username.value : this.username,
    encryptedPassword: encryptedPassword.present
        ? encryptedPassword.value
        : this.encryptedPassword,
    grantToken: grantToken.present ? grantToken.value : this.grantToken,
    refreshToken: refreshToken.present ? refreshToken.value : this.refreshToken,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    lastSyncDate: lastSyncDate.present ? lastSyncDate.value : this.lastSyncDate,
    status: status.present ? status.value : this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PortalCredentialsTableData copyWithCompanion(
    PortalCredentialsTableCompanion data,
  ) {
    return PortalCredentialsTableData(
      id: data.id.present ? data.id.value : this.id,
      portalType: data.portalType.present
          ? data.portalType.value
          : this.portalType,
      username: data.username.present ? data.username.value : this.username,
      encryptedPassword: data.encryptedPassword.present
          ? data.encryptedPassword.value
          : this.encryptedPassword,
      grantToken: data.grantToken.present
          ? data.grantToken.value
          : this.grantToken,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      lastSyncDate: data.lastSyncDate.present
          ? data.lastSyncDate.value
          : this.lastSyncDate,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PortalCredentialsTableData(')
          ..write('id: $id, ')
          ..write('portalType: $portalType, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('grantToken: $grantToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('lastSyncDate: $lastSyncDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    portalType,
    username,
    encryptedPassword,
    grantToken,
    refreshToken,
    expiresAt,
    lastSyncDate,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortalCredentialsTableData &&
          other.id == this.id &&
          other.portalType == this.portalType &&
          other.username == this.username &&
          other.encryptedPassword == this.encryptedPassword &&
          other.grantToken == this.grantToken &&
          other.refreshToken == this.refreshToken &&
          other.expiresAt == this.expiresAt &&
          other.lastSyncDate == this.lastSyncDate &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PortalCredentialsTableCompanion
    extends UpdateCompanion<PortalCredentialsTableData> {
  final Value<String> id;
  final Value<String> portalType;
  final Value<String?> username;
  final Value<String?> encryptedPassword;
  final Value<String?> grantToken;
  final Value<String?> refreshToken;
  final Value<DateTime?> expiresAt;
  final Value<DateTime?> lastSyncDate;
  final Value<String?> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PortalCredentialsTableCompanion({
    this.id = const Value.absent(),
    this.portalType = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.grantToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.lastSyncDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PortalCredentialsTableCompanion.insert({
    required String id,
    required String portalType,
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.grantToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.lastSyncDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       portalType = Value(portalType);
  static Insertable<PortalCredentialsTableData> custom({
    Expression<String>? id,
    Expression<String>? portalType,
    Expression<String>? username,
    Expression<String>? encryptedPassword,
    Expression<String>? grantToken,
    Expression<String>? refreshToken,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? lastSyncDate,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (portalType != null) 'portal_type': portalType,
      if (username != null) 'username': username,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (grantToken != null) 'grant_token': grantToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (lastSyncDate != null) 'last_sync_date': lastSyncDate,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PortalCredentialsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? portalType,
    Value<String?>? username,
    Value<String?>? encryptedPassword,
    Value<String?>? grantToken,
    Value<String?>? refreshToken,
    Value<DateTime?>? expiresAt,
    Value<DateTime?>? lastSyncDate,
    Value<String?>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PortalCredentialsTableCompanion(
      id: id ?? this.id,
      portalType: portalType ?? this.portalType,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      grantToken: grantToken ?? this.grantToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      status: status ?? this.status,
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
    if (portalType.present) {
      map['portal_type'] = Variable<String>(portalType.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (grantToken.present) {
      map['grant_token'] = Variable<String>(grantToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (lastSyncDate.present) {
      map['last_sync_date'] = Variable<DateTime>(lastSyncDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('PortalCredentialsTableCompanion(')
          ..write('id: $id, ')
          ..write('portalType: $portalType, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('grantToken: $grantToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('lastSyncDate: $lastSyncDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTableTable clientsTable = $ClientsTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $SyncConflictsTableTable syncConflictsTable =
      $SyncConflictsTableTable(this);
  late final $ItrFilingsTableTable itrFilingsTable = $ItrFilingsTableTable(
    this,
  );
  late final $GstClientsTableTable gstClientsTable = $GstClientsTableTable(
    this,
  );
  late final $GstReturnsTableTable gstReturnsTable = $GstReturnsTableTable(
    this,
  );
  late final $TdsReturnsTableTable tdsReturnsTable = $TdsReturnsTableTable(
    this,
  );
  late final $TdsChallansTableTable tdsChallansTable = $TdsChallansTableTable(
    this,
  );
  late final $InvoicesTableTable invoicesTable = $InvoicesTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $FirmInfoTableTable firmInfoTable = $FirmInfoTableTable(this);
  late final $TeamMembersTableTable teamMembersTable = $TeamMembersTableTable(
    this,
  );
  late final $ClientAssignmentsTableTable clientAssignmentsTable =
      $ClientAssignmentsTableTable(this);
  late final $PayrollEntriesTableTable payrollEntriesTable =
      $PayrollEntriesTableTable(this);
  late final $AuditAssignmentsTableTable auditAssignmentsTable =
      $AuditAssignmentsTableTable(this);
  late final $AuditReportsTableTable auditReportsTable =
      $AuditReportsTableTable(this);
  late final $MCAFilingsTableTable mCAFilingsTable = $MCAFilingsTableTable(
    this,
  );
  late final $ReconciliationResultsTableTable reconciliationResultsTable =
      $ReconciliationResultsTableTable(this);
  late final $PortalCredentialsTableTable portalCredentialsTable =
      $PortalCredentialsTableTable(this);
  late final ClientsDao clientsDao = ClientsDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final ItrFilingsDao itrFilingsDao = ItrFilingsDao(this as AppDatabase);
  late final GstDao gstDao = GstDao(this as AppDatabase);
  late final TdsDao tdsDao = TdsDao(this as AppDatabase);
  late final InvoicesDao invoicesDao = InvoicesDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clientsTable,
    syncQueueTable,
    syncConflictsTable,
    itrFilingsTable,
    gstClientsTable,
    gstReturnsTable,
    tdsReturnsTable,
    tdsChallansTable,
    invoicesTable,
    paymentsTable,
    tasksTable,
    firmInfoTable,
    teamMembersTable,
    clientAssignmentsTable,
    payrollEntriesTable,
    auditAssignmentsTable,
    auditReportsTable,
    mCAFilingsTable,
    reconciliationResultsTable,
    portalCredentialsTable,
  ];
}

typedef $$ClientsTableTableCreateCompanionBuilder =
    ClientsTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String name,
      required String pan,
      Value<String?> aadhaarHash,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> alternatePhone,
      required String clientType,
      Value<String?> dateOfBirth,
      Value<String?> dateOfIncorporation,
      Value<String?> address,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String?> gstin,
      Value<String?> tan,
      Value<String> servicesAvailed,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ClientsTableTableUpdateCompanionBuilder =
    ClientsTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> name,
      Value<String> pan,
      Value<String?> aadhaarHash,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> alternatePhone,
      Value<String> clientType,
      Value<String?> dateOfBirth,
      Value<String?> dateOfIncorporation,
      Value<String?> address,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String?> gstin,
      Value<String?> tan,
      Value<String> servicesAvailed,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$ClientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTableTable> {
  $$ClientsTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aadhaarHash => $composableBuilder(
    column: $table.aadhaarHash,
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

  ColumnFilters<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientType => $composableBuilder(
    column: $table.clientType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfIncorporation => $composableBuilder(
    column: $table.dateOfIncorporation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tan => $composableBuilder(
    column: $table.tan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servicesAvailed => $composableBuilder(
    column: $table.servicesAvailed,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTableTable> {
  $$ClientsTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aadhaarHash => $composableBuilder(
    column: $table.aadhaarHash,
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

  ColumnOrderings<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientType => $composableBuilder(
    column: $table.clientType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfIncorporation => $composableBuilder(
    column: $table.dateOfIncorporation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tan => $composableBuilder(
    column: $table.tan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servicesAvailed => $composableBuilder(
    column: $table.servicesAvailed,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTableTable> {
  $$ClientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get aadhaarHash => $composableBuilder(
    column: $table.aadhaarHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientType => $composableBuilder(
    column: $table.clientType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfIncorporation => $composableBuilder(
    column: $table.dateOfIncorporation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get tan =>
      $composableBuilder(column: $table.tan, builder: (column) => column);

  GeneratedColumn<String> get servicesAvailed => $composableBuilder(
    column: $table.servicesAvailed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$ClientsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTableTable,
          ClientRow,
          $$ClientsTableTableFilterComposer,
          $$ClientsTableTableOrderingComposer,
          $$ClientsTableTableAnnotationComposer,
          $$ClientsTableTableCreateCompanionBuilder,
          $$ClientsTableTableUpdateCompanionBuilder,
          (
            ClientRow,
            BaseReferences<_$AppDatabase, $ClientsTableTable, ClientRow>,
          ),
          ClientRow,
          PrefetchHooks Function()
        > {
  $$ClientsTableTableTableManager(_$AppDatabase db, $ClientsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> pan = const Value.absent(),
                Value<String?> aadhaarHash = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String> clientType = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> dateOfIncorporation = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> tan = const Value.absent(),
                Value<String> servicesAvailed = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsTableCompanion(
                id: id,
                firmId: firmId,
                name: name,
                pan: pan,
                aadhaarHash: aadhaarHash,
                email: email,
                phone: phone,
                alternatePhone: alternatePhone,
                clientType: clientType,
                dateOfBirth: dateOfBirth,
                dateOfIncorporation: dateOfIncorporation,
                address: address,
                city: city,
                state: state,
                pincode: pincode,
                gstin: gstin,
                tan: tan,
                servicesAvailed: servicesAvailed,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String name,
                required String pan,
                Value<String?> aadhaarHash = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                required String clientType,
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> dateOfIncorporation = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> tan = const Value.absent(),
                Value<String> servicesAvailed = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsTableCompanion.insert(
                id: id,
                firmId: firmId,
                name: name,
                pan: pan,
                aadhaarHash: aadhaarHash,
                email: email,
                phone: phone,
                alternatePhone: alternatePhone,
                clientType: clientType,
                dateOfBirth: dateOfBirth,
                dateOfIncorporation: dateOfIncorporation,
                address: address,
                city: city,
                state: state,
                pincode: pincode,
                gstin: gstin,
                tan: tan,
                servicesAvailed: servicesAvailed,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTableTable,
      ClientRow,
      $$ClientsTableTableFilterComposer,
      $$ClientsTableTableOrderingComposer,
      $$ClientsTableTableAnnotationComposer,
      $$ClientsTableTableCreateCompanionBuilder,
      $$ClientsTableTableUpdateCompanionBuilder,
      (ClientRow, BaseReferences<_$AppDatabase, $ClientsTableTable, ClientRow>),
      ClientRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> id,
      required String sourceTable,
      required String recordId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> id,
      Value<String> sourceTable,
      Value<String> recordId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
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

  ColumnFilters<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
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

  ColumnOrderings<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueRow,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                sourceTable: sourceTable,
                recordId: recordId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String sourceTable,
                required String recordId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                sourceTable: sourceTable,
                recordId: recordId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueRow,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableTableCreateCompanionBuilder =
    SyncConflictsTableCompanion Function({
      Value<String> id,
      required String sourceTable,
      required String recordId,
      required String localPayload,
      required String serverPayload,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableTableUpdateCompanionBuilder =
    SyncConflictsTableCompanion Function({
      Value<String> id,
      Value<String> sourceTable,
      Value<String> recordId,
      Value<String> localPayload,
      Value<String> serverPayload,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });

class $$SyncConflictsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTableTable> {
  $$SyncConflictsTableTableFilterComposer({
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

  ColumnFilters<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTableTable> {
  $$SyncConflictsTableTableOrderingComposer({
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

  ColumnOrderings<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTableTable> {
  $$SyncConflictsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTableTable,
          SyncConflictRow,
          $$SyncConflictsTableTableFilterComposer,
          $$SyncConflictsTableTableOrderingComposer,
          $$SyncConflictsTableTableAnnotationComposer,
          $$SyncConflictsTableTableCreateCompanionBuilder,
          $$SyncConflictsTableTableUpdateCompanionBuilder,
          (
            SyncConflictRow,
            BaseReferences<
              _$AppDatabase,
              $SyncConflictsTableTable,
              SyncConflictRow
            >,
          ),
          SyncConflictRow,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableTableManager(
    _$AppDatabase db,
    $SyncConflictsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> localPayload = const Value.absent(),
                Value<String> serverPayload = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsTableCompanion(
                id: id,
                sourceTable: sourceTable,
                recordId: recordId,
                localPayload: localPayload,
                serverPayload: serverPayload,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String sourceTable,
                required String recordId,
                required String localPayload,
                required String serverPayload,
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsTableCompanion.insert(
                id: id,
                sourceTable: sourceTable,
                recordId: recordId,
                localPayload: localPayload,
                serverPayload: serverPayload,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTableTable,
      SyncConflictRow,
      $$SyncConflictsTableTableFilterComposer,
      $$SyncConflictsTableTableOrderingComposer,
      $$SyncConflictsTableTableAnnotationComposer,
      $$SyncConflictsTableTableCreateCompanionBuilder,
      $$SyncConflictsTableTableUpdateCompanionBuilder,
      (
        SyncConflictRow,
        BaseReferences<
          _$AppDatabase,
          $SyncConflictsTableTable,
          SyncConflictRow
        >,
      ),
      SyncConflictRow,
      PrefetchHooks Function()
    >;
typedef $$ItrFilingsTableTableCreateCompanionBuilder =
    ItrFilingsTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      required String name,
      required String pan,
      Value<String?> aadhaar,
      Value<String?> email,
      Value<String?> phone,
      required String itrType,
      required String assessmentYear,
      required String financialYear,
      Value<String> filingStatus,
      Value<double?> totalIncome,
      Value<double?> taxPayable,
      Value<double?> refundDue,
      Value<double?> tdsAmount,
      Value<double?> advanceTax,
      Value<double?> selfAssessmentTax,
      Value<String?> acknowledgementNumber,
      Value<String?> filedDate,
      Value<String?> verifiedDate,
      Value<String?> dueDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ItrFilingsTableTableUpdateCompanionBuilder =
    ItrFilingsTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String> name,
      Value<String> pan,
      Value<String?> aadhaar,
      Value<String?> email,
      Value<String?> phone,
      Value<String> itrType,
      Value<String> assessmentYear,
      Value<String> financialYear,
      Value<String> filingStatus,
      Value<double?> totalIncome,
      Value<double?> taxPayable,
      Value<double?> refundDue,
      Value<double?> tdsAmount,
      Value<double?> advanceTax,
      Value<double?> selfAssessmentTax,
      Value<String?> acknowledgementNumber,
      Value<String?> filedDate,
      Value<String?> verifiedDate,
      Value<String?> dueDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$ItrFilingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItrFilingsTableTable> {
  $$ItrFilingsTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aadhaar => $composableBuilder(
    column: $table.aadhaar,
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

  ColumnFilters<String> get itrType => $composableBuilder(
    column: $table.itrType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessmentYear => $composableBuilder(
    column: $table.assessmentYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filingStatus => $composableBuilder(
    column: $table.filingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxPayable => $composableBuilder(
    column: $table.taxPayable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refundDue => $composableBuilder(
    column: $table.refundDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get advanceTax => $composableBuilder(
    column: $table.advanceTax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get selfAssessmentTax => $composableBuilder(
    column: $table.selfAssessmentTax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acknowledgementNumber => $composableBuilder(
    column: $table.acknowledgementNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verifiedDate => $composableBuilder(
    column: $table.verifiedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItrFilingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItrFilingsTableTable> {
  $$ItrFilingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aadhaar => $composableBuilder(
    column: $table.aadhaar,
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

  ColumnOrderings<String> get itrType => $composableBuilder(
    column: $table.itrType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessmentYear => $composableBuilder(
    column: $table.assessmentYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filingStatus => $composableBuilder(
    column: $table.filingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxPayable => $composableBuilder(
    column: $table.taxPayable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refundDue => $composableBuilder(
    column: $table.refundDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get advanceTax => $composableBuilder(
    column: $table.advanceTax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get selfAssessmentTax => $composableBuilder(
    column: $table.selfAssessmentTax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acknowledgementNumber => $composableBuilder(
    column: $table.acknowledgementNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verifiedDate => $composableBuilder(
    column: $table.verifiedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItrFilingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItrFilingsTableTable> {
  $$ItrFilingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get aadhaar =>
      $composableBuilder(column: $table.aadhaar, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get itrType =>
      $composableBuilder(column: $table.itrType, builder: (column) => column);

  GeneratedColumn<String> get assessmentYear => $composableBuilder(
    column: $table.assessmentYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filingStatus => $composableBuilder(
    column: $table.filingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxPayable => $composableBuilder(
    column: $table.taxPayable,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refundDue =>
      $composableBuilder(column: $table.refundDue, builder: (column) => column);

  GeneratedColumn<double> get tdsAmount =>
      $composableBuilder(column: $table.tdsAmount, builder: (column) => column);

  GeneratedColumn<double> get advanceTax => $composableBuilder(
    column: $table.advanceTax,
    builder: (column) => column,
  );

  GeneratedColumn<double> get selfAssessmentTax => $composableBuilder(
    column: $table.selfAssessmentTax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get acknowledgementNumber => $composableBuilder(
    column: $table.acknowledgementNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filedDate =>
      $composableBuilder(column: $table.filedDate, builder: (column) => column);

  GeneratedColumn<String> get verifiedDate => $composableBuilder(
    column: $table.verifiedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$ItrFilingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItrFilingsTableTable,
          ItrFilingRow,
          $$ItrFilingsTableTableFilterComposer,
          $$ItrFilingsTableTableOrderingComposer,
          $$ItrFilingsTableTableAnnotationComposer,
          $$ItrFilingsTableTableCreateCompanionBuilder,
          $$ItrFilingsTableTableUpdateCompanionBuilder,
          (
            ItrFilingRow,
            BaseReferences<_$AppDatabase, $ItrFilingsTableTable, ItrFilingRow>,
          ),
          ItrFilingRow,
          PrefetchHooks Function()
        > {
  $$ItrFilingsTableTableTableManager(
    _$AppDatabase db,
    $ItrFilingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItrFilingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItrFilingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItrFilingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> pan = const Value.absent(),
                Value<String?> aadhaar = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> itrType = const Value.absent(),
                Value<String> assessmentYear = const Value.absent(),
                Value<String> financialYear = const Value.absent(),
                Value<String> filingStatus = const Value.absent(),
                Value<double?> totalIncome = const Value.absent(),
                Value<double?> taxPayable = const Value.absent(),
                Value<double?> refundDue = const Value.absent(),
                Value<double?> tdsAmount = const Value.absent(),
                Value<double?> advanceTax = const Value.absent(),
                Value<double?> selfAssessmentTax = const Value.absent(),
                Value<String?> acknowledgementNumber = const Value.absent(),
                Value<String?> filedDate = const Value.absent(),
                Value<String?> verifiedDate = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItrFilingsTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                name: name,
                pan: pan,
                aadhaar: aadhaar,
                email: email,
                phone: phone,
                itrType: itrType,
                assessmentYear: assessmentYear,
                financialYear: financialYear,
                filingStatus: filingStatus,
                totalIncome: totalIncome,
                taxPayable: taxPayable,
                refundDue: refundDue,
                tdsAmount: tdsAmount,
                advanceTax: advanceTax,
                selfAssessmentTax: selfAssessmentTax,
                acknowledgementNumber: acknowledgementNumber,
                filedDate: filedDate,
                verifiedDate: verifiedDate,
                dueDate: dueDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                required String name,
                required String pan,
                Value<String?> aadhaar = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String itrType,
                required String assessmentYear,
                required String financialYear,
                Value<String> filingStatus = const Value.absent(),
                Value<double?> totalIncome = const Value.absent(),
                Value<double?> taxPayable = const Value.absent(),
                Value<double?> refundDue = const Value.absent(),
                Value<double?> tdsAmount = const Value.absent(),
                Value<double?> advanceTax = const Value.absent(),
                Value<double?> selfAssessmentTax = const Value.absent(),
                Value<String?> acknowledgementNumber = const Value.absent(),
                Value<String?> filedDate = const Value.absent(),
                Value<String?> verifiedDate = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItrFilingsTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                name: name,
                pan: pan,
                aadhaar: aadhaar,
                email: email,
                phone: phone,
                itrType: itrType,
                assessmentYear: assessmentYear,
                financialYear: financialYear,
                filingStatus: filingStatus,
                totalIncome: totalIncome,
                taxPayable: taxPayable,
                refundDue: refundDue,
                tdsAmount: tdsAmount,
                advanceTax: advanceTax,
                selfAssessmentTax: selfAssessmentTax,
                acknowledgementNumber: acknowledgementNumber,
                filedDate: filedDate,
                verifiedDate: verifiedDate,
                dueDate: dueDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItrFilingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItrFilingsTableTable,
      ItrFilingRow,
      $$ItrFilingsTableTableFilterComposer,
      $$ItrFilingsTableTableOrderingComposer,
      $$ItrFilingsTableTableAnnotationComposer,
      $$ItrFilingsTableTableCreateCompanionBuilder,
      $$ItrFilingsTableTableUpdateCompanionBuilder,
      (
        ItrFilingRow,
        BaseReferences<_$AppDatabase, $ItrFilingsTableTable, ItrFilingRow>,
      ),
      ItrFilingRow,
      PrefetchHooks Function()
    >;
typedef $$GstClientsTableTableCreateCompanionBuilder =
    GstClientsTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      required String businessName,
      Value<String?> tradeName,
      required String gstin,
      required String pan,
      required String registrationType,
      required String state,
      required String stateCode,
      Value<String> returnsPending,
      Value<String?> lastFiledDate,
      Value<int> complianceScore,
      Value<bool> isActive,
      Value<String?> registrationDate,
      Value<String?> cancellationDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$GstClientsTableTableUpdateCompanionBuilder =
    GstClientsTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String> businessName,
      Value<String?> tradeName,
      Value<String> gstin,
      Value<String> pan,
      Value<String> registrationType,
      Value<String> state,
      Value<String> stateCode,
      Value<String> returnsPending,
      Value<String?> lastFiledDate,
      Value<int> complianceScore,
      Value<bool> isActive,
      Value<String?> registrationDate,
      Value<String?> cancellationDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$GstClientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GstClientsTableTable> {
  $$GstClientsTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeName => $composableBuilder(
    column: $table.tradeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationType => $composableBuilder(
    column: $table.registrationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnsPending => $composableBuilder(
    column: $table.returnsPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastFiledDate => $composableBuilder(
    column: $table.lastFiledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get complianceScore => $composableBuilder(
    column: $table.complianceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationDate => $composableBuilder(
    column: $table.registrationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancellationDate => $composableBuilder(
    column: $table.cancellationDate,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GstClientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GstClientsTableTable> {
  $$GstClientsTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeName => $composableBuilder(
    column: $table.tradeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationType => $composableBuilder(
    column: $table.registrationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnsPending => $composableBuilder(
    column: $table.returnsPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastFiledDate => $composableBuilder(
    column: $table.lastFiledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get complianceScore => $composableBuilder(
    column: $table.complianceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationDate => $composableBuilder(
    column: $table.registrationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancellationDate => $composableBuilder(
    column: $table.cancellationDate,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GstClientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GstClientsTableTable> {
  $$GstClientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tradeName =>
      $composableBuilder(column: $table.tradeName, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get registrationType => $composableBuilder(
    column: $table.registrationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get returnsPending => $composableBuilder(
    column: $table.returnsPending,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastFiledDate => $composableBuilder(
    column: $table.lastFiledDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get complianceScore => $composableBuilder(
    column: $table.complianceScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get registrationDate => $composableBuilder(
    column: $table.registrationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancellationDate => $composableBuilder(
    column: $table.cancellationDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$GstClientsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GstClientsTableTable,
          GstClientRow,
          $$GstClientsTableTableFilterComposer,
          $$GstClientsTableTableOrderingComposer,
          $$GstClientsTableTableAnnotationComposer,
          $$GstClientsTableTableCreateCompanionBuilder,
          $$GstClientsTableTableUpdateCompanionBuilder,
          (
            GstClientRow,
            BaseReferences<_$AppDatabase, $GstClientsTableTable, GstClientRow>,
          ),
          GstClientRow,
          PrefetchHooks Function()
        > {
  $$GstClientsTableTableTableManager(
    _$AppDatabase db,
    $GstClientsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GstClientsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GstClientsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GstClientsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String?> tradeName = const Value.absent(),
                Value<String> gstin = const Value.absent(),
                Value<String> pan = const Value.absent(),
                Value<String> registrationType = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> stateCode = const Value.absent(),
                Value<String> returnsPending = const Value.absent(),
                Value<String?> lastFiledDate = const Value.absent(),
                Value<int> complianceScore = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> registrationDate = const Value.absent(),
                Value<String?> cancellationDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GstClientsTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                businessName: businessName,
                tradeName: tradeName,
                gstin: gstin,
                pan: pan,
                registrationType: registrationType,
                state: state,
                stateCode: stateCode,
                returnsPending: returnsPending,
                lastFiledDate: lastFiledDate,
                complianceScore: complianceScore,
                isActive: isActive,
                registrationDate: registrationDate,
                cancellationDate: cancellationDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                required String businessName,
                Value<String?> tradeName = const Value.absent(),
                required String gstin,
                required String pan,
                required String registrationType,
                required String state,
                required String stateCode,
                Value<String> returnsPending = const Value.absent(),
                Value<String?> lastFiledDate = const Value.absent(),
                Value<int> complianceScore = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> registrationDate = const Value.absent(),
                Value<String?> cancellationDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GstClientsTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                businessName: businessName,
                tradeName: tradeName,
                gstin: gstin,
                pan: pan,
                registrationType: registrationType,
                state: state,
                stateCode: stateCode,
                returnsPending: returnsPending,
                lastFiledDate: lastFiledDate,
                complianceScore: complianceScore,
                isActive: isActive,
                registrationDate: registrationDate,
                cancellationDate: cancellationDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GstClientsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GstClientsTableTable,
      GstClientRow,
      $$GstClientsTableTableFilterComposer,
      $$GstClientsTableTableOrderingComposer,
      $$GstClientsTableTableAnnotationComposer,
      $$GstClientsTableTableCreateCompanionBuilder,
      $$GstClientsTableTableUpdateCompanionBuilder,
      (
        GstClientRow,
        BaseReferences<_$AppDatabase, $GstClientsTableTable, GstClientRow>,
      ),
      GstClientRow,
      PrefetchHooks Function()
    >;
typedef $$GstReturnsTableTableCreateCompanionBuilder =
    GstReturnsTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      required String gstin,
      required String returnType,
      required int periodMonth,
      required int periodYear,
      Value<String?> dueDate,
      Value<String?> filedDate,
      Value<String> status,
      Value<double> taxableValue,
      Value<double> igst,
      Value<double> cgst,
      Value<double> sgst,
      Value<double> cess,
      Value<double> lateFee,
      Value<double> itcClaimed,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$GstReturnsTableTableUpdateCompanionBuilder =
    GstReturnsTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String> gstin,
      Value<String> returnType,
      Value<int> periodMonth,
      Value<int> periodYear,
      Value<String?> dueDate,
      Value<String?> filedDate,
      Value<String> status,
      Value<double> taxableValue,
      Value<double> igst,
      Value<double> cgst,
      Value<double> sgst,
      Value<double> cess,
      Value<double> lateFee,
      Value<double> itcClaimed,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$GstReturnsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GstReturnsTableTable> {
  $$GstReturnsTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnType => $composableBuilder(
    column: $table.returnType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodYear => $composableBuilder(
    column: $table.periodYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxableValue => $composableBuilder(
    column: $table.taxableValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igst => $composableBuilder(
    column: $table.igst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgst => $composableBuilder(
    column: $table.cgst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgst => $composableBuilder(
    column: $table.sgst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cess => $composableBuilder(
    column: $table.cess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lateFee => $composableBuilder(
    column: $table.lateFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get itcClaimed => $composableBuilder(
    column: $table.itcClaimed,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GstReturnsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GstReturnsTableTable> {
  $$GstReturnsTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnType => $composableBuilder(
    column: $table.returnType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodYear => $composableBuilder(
    column: $table.periodYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxableValue => $composableBuilder(
    column: $table.taxableValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igst => $composableBuilder(
    column: $table.igst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgst => $composableBuilder(
    column: $table.cgst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgst => $composableBuilder(
    column: $table.sgst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cess => $composableBuilder(
    column: $table.cess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lateFee => $composableBuilder(
    column: $table.lateFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get itcClaimed => $composableBuilder(
    column: $table.itcClaimed,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GstReturnsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GstReturnsTableTable> {
  $$GstReturnsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get returnType => $composableBuilder(
    column: $table.returnType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodYear => $composableBuilder(
    column: $table.periodYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get filedDate =>
      $composableBuilder(column: $table.filedDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get taxableValue => $composableBuilder(
    column: $table.taxableValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igst =>
      $composableBuilder(column: $table.igst, builder: (column) => column);

  GeneratedColumn<double> get cgst =>
      $composableBuilder(column: $table.cgst, builder: (column) => column);

  GeneratedColumn<double> get sgst =>
      $composableBuilder(column: $table.sgst, builder: (column) => column);

  GeneratedColumn<double> get cess =>
      $composableBuilder(column: $table.cess, builder: (column) => column);

  GeneratedColumn<double> get lateFee =>
      $composableBuilder(column: $table.lateFee, builder: (column) => column);

  GeneratedColumn<double> get itcClaimed => $composableBuilder(
    column: $table.itcClaimed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$GstReturnsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GstReturnsTableTable,
          GstReturnRow,
          $$GstReturnsTableTableFilterComposer,
          $$GstReturnsTableTableOrderingComposer,
          $$GstReturnsTableTableAnnotationComposer,
          $$GstReturnsTableTableCreateCompanionBuilder,
          $$GstReturnsTableTableUpdateCompanionBuilder,
          (
            GstReturnRow,
            BaseReferences<_$AppDatabase, $GstReturnsTableTable, GstReturnRow>,
          ),
          GstReturnRow,
          PrefetchHooks Function()
        > {
  $$GstReturnsTableTableTableManager(
    _$AppDatabase db,
    $GstReturnsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GstReturnsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GstReturnsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GstReturnsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> gstin = const Value.absent(),
                Value<String> returnType = const Value.absent(),
                Value<int> periodMonth = const Value.absent(),
                Value<int> periodYear = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> filedDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> taxableValue = const Value.absent(),
                Value<double> igst = const Value.absent(),
                Value<double> cgst = const Value.absent(),
                Value<double> sgst = const Value.absent(),
                Value<double> cess = const Value.absent(),
                Value<double> lateFee = const Value.absent(),
                Value<double> itcClaimed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GstReturnsTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                gstin: gstin,
                returnType: returnType,
                periodMonth: periodMonth,
                periodYear: periodYear,
                dueDate: dueDate,
                filedDate: filedDate,
                status: status,
                taxableValue: taxableValue,
                igst: igst,
                cgst: cgst,
                sgst: sgst,
                cess: cess,
                lateFee: lateFee,
                itcClaimed: itcClaimed,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                required String gstin,
                required String returnType,
                required int periodMonth,
                required int periodYear,
                Value<String?> dueDate = const Value.absent(),
                Value<String?> filedDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> taxableValue = const Value.absent(),
                Value<double> igst = const Value.absent(),
                Value<double> cgst = const Value.absent(),
                Value<double> sgst = const Value.absent(),
                Value<double> cess = const Value.absent(),
                Value<double> lateFee = const Value.absent(),
                Value<double> itcClaimed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GstReturnsTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                gstin: gstin,
                returnType: returnType,
                periodMonth: periodMonth,
                periodYear: periodYear,
                dueDate: dueDate,
                filedDate: filedDate,
                status: status,
                taxableValue: taxableValue,
                igst: igst,
                cgst: cgst,
                sgst: sgst,
                cess: cess,
                lateFee: lateFee,
                itcClaimed: itcClaimed,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GstReturnsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GstReturnsTableTable,
      GstReturnRow,
      $$GstReturnsTableTableFilterComposer,
      $$GstReturnsTableTableOrderingComposer,
      $$GstReturnsTableTableAnnotationComposer,
      $$GstReturnsTableTableCreateCompanionBuilder,
      $$GstReturnsTableTableUpdateCompanionBuilder,
      (
        GstReturnRow,
        BaseReferences<_$AppDatabase, $GstReturnsTableTable, GstReturnRow>,
      ),
      GstReturnRow,
      PrefetchHooks Function()
    >;
typedef $$TdsReturnsTableTableCreateCompanionBuilder =
    TdsReturnsTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      required String deductorId,
      required String tan,
      required String formType,
      required String quarter,
      required String financialYear,
      Value<String?> dueDate,
      Value<String?> filedDate,
      Value<String> status,
      Value<double> totalDeductions,
      Value<double> totalTaxDeducted,
      Value<double> totalDeposited,
      Value<double> lateFee,
      Value<String?> tokenNumber,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$TdsReturnsTableTableUpdateCompanionBuilder =
    TdsReturnsTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String> deductorId,
      Value<String> tan,
      Value<String> formType,
      Value<String> quarter,
      Value<String> financialYear,
      Value<String?> dueDate,
      Value<String?> filedDate,
      Value<String> status,
      Value<double> totalDeductions,
      Value<double> totalTaxDeducted,
      Value<double> totalDeposited,
      Value<double> lateFee,
      Value<String?> tokenNumber,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$TdsReturnsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TdsReturnsTableTable> {
  $$TdsReturnsTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductorId => $composableBuilder(
    column: $table.deductorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tan => $composableBuilder(
    column: $table.tan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDeductions => $composableBuilder(
    column: $table.totalDeductions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalTaxDeducted => $composableBuilder(
    column: $table.totalTaxDeducted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDeposited => $composableBuilder(
    column: $table.totalDeposited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lateFee => $composableBuilder(
    column: $table.lateFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenNumber => $composableBuilder(
    column: $table.tokenNumber,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TdsReturnsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TdsReturnsTableTable> {
  $$TdsReturnsTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductorId => $composableBuilder(
    column: $table.deductorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tan => $composableBuilder(
    column: $table.tan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDeductions => $composableBuilder(
    column: $table.totalDeductions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalTaxDeducted => $composableBuilder(
    column: $table.totalTaxDeducted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDeposited => $composableBuilder(
    column: $table.totalDeposited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lateFee => $composableBuilder(
    column: $table.lateFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenNumber => $composableBuilder(
    column: $table.tokenNumber,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TdsReturnsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TdsReturnsTableTable> {
  $$TdsReturnsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get deductorId => $composableBuilder(
    column: $table.deductorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tan =>
      $composableBuilder(column: $table.tan, builder: (column) => column);

  GeneratedColumn<String> get formType =>
      $composableBuilder(column: $table.formType, builder: (column) => column);

  GeneratedColumn<String> get quarter =>
      $composableBuilder(column: $table.quarter, builder: (column) => column);

  GeneratedColumn<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get filedDate =>
      $composableBuilder(column: $table.filedDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get totalDeductions => $composableBuilder(
    column: $table.totalDeductions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalTaxDeducted => $composableBuilder(
    column: $table.totalTaxDeducted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDeposited => $composableBuilder(
    column: $table.totalDeposited,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lateFee =>
      $composableBuilder(column: $table.lateFee, builder: (column) => column);

  GeneratedColumn<String> get tokenNumber => $composableBuilder(
    column: $table.tokenNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$TdsReturnsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TdsReturnsTableTable,
          TdsReturnRow,
          $$TdsReturnsTableTableFilterComposer,
          $$TdsReturnsTableTableOrderingComposer,
          $$TdsReturnsTableTableAnnotationComposer,
          $$TdsReturnsTableTableCreateCompanionBuilder,
          $$TdsReturnsTableTableUpdateCompanionBuilder,
          (
            TdsReturnRow,
            BaseReferences<_$AppDatabase, $TdsReturnsTableTable, TdsReturnRow>,
          ),
          TdsReturnRow,
          PrefetchHooks Function()
        > {
  $$TdsReturnsTableTableTableManager(
    _$AppDatabase db,
    $TdsReturnsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TdsReturnsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TdsReturnsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TdsReturnsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> deductorId = const Value.absent(),
                Value<String> tan = const Value.absent(),
                Value<String> formType = const Value.absent(),
                Value<String> quarter = const Value.absent(),
                Value<String> financialYear = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> filedDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalDeductions = const Value.absent(),
                Value<double> totalTaxDeducted = const Value.absent(),
                Value<double> totalDeposited = const Value.absent(),
                Value<double> lateFee = const Value.absent(),
                Value<String?> tokenNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TdsReturnsTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                deductorId: deductorId,
                tan: tan,
                formType: formType,
                quarter: quarter,
                financialYear: financialYear,
                dueDate: dueDate,
                filedDate: filedDate,
                status: status,
                totalDeductions: totalDeductions,
                totalTaxDeducted: totalTaxDeducted,
                totalDeposited: totalDeposited,
                lateFee: lateFee,
                tokenNumber: tokenNumber,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                required String deductorId,
                required String tan,
                required String formType,
                required String quarter,
                required String financialYear,
                Value<String?> dueDate = const Value.absent(),
                Value<String?> filedDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalDeductions = const Value.absent(),
                Value<double> totalTaxDeducted = const Value.absent(),
                Value<double> totalDeposited = const Value.absent(),
                Value<double> lateFee = const Value.absent(),
                Value<String?> tokenNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TdsReturnsTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                deductorId: deductorId,
                tan: tan,
                formType: formType,
                quarter: quarter,
                financialYear: financialYear,
                dueDate: dueDate,
                filedDate: filedDate,
                status: status,
                totalDeductions: totalDeductions,
                totalTaxDeducted: totalTaxDeducted,
                totalDeposited: totalDeposited,
                lateFee: lateFee,
                tokenNumber: tokenNumber,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TdsReturnsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TdsReturnsTableTable,
      TdsReturnRow,
      $$TdsReturnsTableTableFilterComposer,
      $$TdsReturnsTableTableOrderingComposer,
      $$TdsReturnsTableTableAnnotationComposer,
      $$TdsReturnsTableTableCreateCompanionBuilder,
      $$TdsReturnsTableTableUpdateCompanionBuilder,
      (
        TdsReturnRow,
        BaseReferences<_$AppDatabase, $TdsReturnsTableTable, TdsReturnRow>,
      ),
      TdsReturnRow,
      PrefetchHooks Function()
    >;
typedef $$TdsChallansTableTableCreateCompanionBuilder =
    TdsChallansTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      Value<String?> tdsReturnId,
      required String deductorId,
      required String challanNumber,
      required String bsrCode,
      required String section,
      Value<int> deducteeCount,
      required double tdsAmount,
      Value<double> surcharge,
      Value<double> educationCess,
      Value<double> interest,
      Value<double> penalty,
      required double totalAmount,
      required String paymentDate,
      required int month,
      required String financialYear,
      Value<String> status,
      Value<String?> taxType,
      Value<DateTime> createdAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$TdsChallansTableTableUpdateCompanionBuilder =
    TdsChallansTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String?> tdsReturnId,
      Value<String> deductorId,
      Value<String> challanNumber,
      Value<String> bsrCode,
      Value<String> section,
      Value<int> deducteeCount,
      Value<double> tdsAmount,
      Value<double> surcharge,
      Value<double> educationCess,
      Value<double> interest,
      Value<double> penalty,
      Value<double> totalAmount,
      Value<String> paymentDate,
      Value<int> month,
      Value<String> financialYear,
      Value<String> status,
      Value<String?> taxType,
      Value<DateTime> createdAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$TdsChallansTableTableFilterComposer
    extends Composer<_$AppDatabase, $TdsChallansTableTable> {
  $$TdsChallansTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tdsReturnId => $composableBuilder(
    column: $table.tdsReturnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductorId => $composableBuilder(
    column: $table.deductorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challanNumber => $composableBuilder(
    column: $table.challanNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bsrCode => $composableBuilder(
    column: $table.bsrCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deducteeCount => $composableBuilder(
    column: $table.deducteeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get surcharge => $composableBuilder(
    column: $table.surcharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get educationCess => $composableBuilder(
    column: $table.educationCess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interest => $composableBuilder(
    column: $table.interest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get penalty => $composableBuilder(
    column: $table.penalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxType => $composableBuilder(
    column: $table.taxType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TdsChallansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TdsChallansTableTable> {
  $$TdsChallansTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tdsReturnId => $composableBuilder(
    column: $table.tdsReturnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductorId => $composableBuilder(
    column: $table.deductorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challanNumber => $composableBuilder(
    column: $table.challanNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bsrCode => $composableBuilder(
    column: $table.bsrCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deducteeCount => $composableBuilder(
    column: $table.deducteeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get surcharge => $composableBuilder(
    column: $table.surcharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get educationCess => $composableBuilder(
    column: $table.educationCess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interest => $composableBuilder(
    column: $table.interest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get penalty => $composableBuilder(
    column: $table.penalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxType => $composableBuilder(
    column: $table.taxType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TdsChallansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TdsChallansTableTable> {
  $$TdsChallansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get tdsReturnId => $composableBuilder(
    column: $table.tdsReturnId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deductorId => $composableBuilder(
    column: $table.deductorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get challanNumber => $composableBuilder(
    column: $table.challanNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bsrCode =>
      $composableBuilder(column: $table.bsrCode, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<int> get deducteeCount => $composableBuilder(
    column: $table.deducteeCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tdsAmount =>
      $composableBuilder(column: $table.tdsAmount, builder: (column) => column);

  GeneratedColumn<double> get surcharge =>
      $composableBuilder(column: $table.surcharge, builder: (column) => column);

  GeneratedColumn<double> get educationCess => $composableBuilder(
    column: $table.educationCess,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interest =>
      $composableBuilder(column: $table.interest, builder: (column) => column);

  GeneratedColumn<double> get penalty =>
      $composableBuilder(column: $table.penalty, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get taxType =>
      $composableBuilder(column: $table.taxType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$TdsChallansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TdsChallansTableTable,
          TdsChallanRow,
          $$TdsChallansTableTableFilterComposer,
          $$TdsChallansTableTableOrderingComposer,
          $$TdsChallansTableTableAnnotationComposer,
          $$TdsChallansTableTableCreateCompanionBuilder,
          $$TdsChallansTableTableUpdateCompanionBuilder,
          (
            TdsChallanRow,
            BaseReferences<
              _$AppDatabase,
              $TdsChallansTableTable,
              TdsChallanRow
            >,
          ),
          TdsChallanRow,
          PrefetchHooks Function()
        > {
  $$TdsChallansTableTableTableManager(
    _$AppDatabase db,
    $TdsChallansTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TdsChallansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TdsChallansTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TdsChallansTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> tdsReturnId = const Value.absent(),
                Value<String> deductorId = const Value.absent(),
                Value<String> challanNumber = const Value.absent(),
                Value<String> bsrCode = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<int> deducteeCount = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<double> surcharge = const Value.absent(),
                Value<double> educationCess = const Value.absent(),
                Value<double> interest = const Value.absent(),
                Value<double> penalty = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> paymentDate = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<String> financialYear = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> taxType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TdsChallansTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                tdsReturnId: tdsReturnId,
                deductorId: deductorId,
                challanNumber: challanNumber,
                bsrCode: bsrCode,
                section: section,
                deducteeCount: deducteeCount,
                tdsAmount: tdsAmount,
                surcharge: surcharge,
                educationCess: educationCess,
                interest: interest,
                penalty: penalty,
                totalAmount: totalAmount,
                paymentDate: paymentDate,
                month: month,
                financialYear: financialYear,
                status: status,
                taxType: taxType,
                createdAt: createdAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                Value<String?> tdsReturnId = const Value.absent(),
                required String deductorId,
                required String challanNumber,
                required String bsrCode,
                required String section,
                Value<int> deducteeCount = const Value.absent(),
                required double tdsAmount,
                Value<double> surcharge = const Value.absent(),
                Value<double> educationCess = const Value.absent(),
                Value<double> interest = const Value.absent(),
                Value<double> penalty = const Value.absent(),
                required double totalAmount,
                required String paymentDate,
                required int month,
                required String financialYear,
                Value<String> status = const Value.absent(),
                Value<String?> taxType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TdsChallansTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                tdsReturnId: tdsReturnId,
                deductorId: deductorId,
                challanNumber: challanNumber,
                bsrCode: bsrCode,
                section: section,
                deducteeCount: deducteeCount,
                tdsAmount: tdsAmount,
                surcharge: surcharge,
                educationCess: educationCess,
                interest: interest,
                penalty: penalty,
                totalAmount: totalAmount,
                paymentDate: paymentDate,
                month: month,
                financialYear: financialYear,
                status: status,
                taxType: taxType,
                createdAt: createdAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TdsChallansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TdsChallansTableTable,
      TdsChallanRow,
      $$TdsChallansTableTableFilterComposer,
      $$TdsChallansTableTableOrderingComposer,
      $$TdsChallansTableTableAnnotationComposer,
      $$TdsChallansTableTableCreateCompanionBuilder,
      $$TdsChallansTableTableUpdateCompanionBuilder,
      (
        TdsChallanRow,
        BaseReferences<_$AppDatabase, $TdsChallansTableTable, TdsChallanRow>,
      ),
      TdsChallanRow,
      PrefetchHooks Function()
    >;
typedef $$InvoicesTableTableCreateCompanionBuilder =
    InvoicesTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      required String clientName,
      required String invoiceNumber,
      Value<String?> gstin,
      required String invoiceDate,
      required String dueDate,
      Value<String> lineItems,
      Value<double> subtotal,
      Value<double> discountAmount,
      Value<double> totalGst,
      Value<double> grandTotal,
      Value<double> paidAmount,
      Value<double> balanceDue,
      Value<String> status,
      Value<String?> paymentDate,
      Value<String?> paymentMethod,
      Value<String?> remarks,
      Value<String?> terms,
      Value<bool> isRecurring,
      Value<String?> recurringFrequency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$InvoicesTableTableUpdateCompanionBuilder =
    InvoicesTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String> clientName,
      Value<String> invoiceNumber,
      Value<String?> gstin,
      Value<String> invoiceDate,
      Value<String> dueDate,
      Value<String> lineItems,
      Value<double> subtotal,
      Value<double> discountAmount,
      Value<double> totalGst,
      Value<double> grandTotal,
      Value<double> paidAmount,
      Value<double> balanceDue,
      Value<String> status,
      Value<String?> paymentDate,
      Value<String?> paymentMethod,
      Value<String?> remarks,
      Value<String?> terms,
      Value<bool> isRecurring,
      Value<String?> recurringFrequency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$InvoicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTableTable> {
  $$InvoicesTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineItems => $composableBuilder(
    column: $table.lineItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalGst => $composableBuilder(
    column: $table.totalGst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceDue => $composableBuilder(
    column: $table.balanceDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringFrequency => $composableBuilder(
    column: $table.recurringFrequency,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTableTable> {
  $$InvoicesTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineItems => $composableBuilder(
    column: $table.lineItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalGst => $composableBuilder(
    column: $table.totalGst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceDue => $composableBuilder(
    column: $table.balanceDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringFrequency => $composableBuilder(
    column: $table.recurringFrequency,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTableTable> {
  $$InvoicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get lineItems =>
      $composableBuilder(column: $table.lineItems, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalGst =>
      $composableBuilder(column: $table.totalGst, builder: (column) => column);

  GeneratedColumn<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balanceDue => $composableBuilder(
    column: $table.balanceDue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get terms =>
      $composableBuilder(column: $table.terms, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringFrequency => $composableBuilder(
    column: $table.recurringFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$InvoicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTableTable,
          InvoiceRow,
          $$InvoicesTableTableFilterComposer,
          $$InvoicesTableTableOrderingComposer,
          $$InvoicesTableTableAnnotationComposer,
          $$InvoicesTableTableCreateCompanionBuilder,
          $$InvoicesTableTableUpdateCompanionBuilder,
          (
            InvoiceRow,
            BaseReferences<_$AppDatabase, $InvoicesTableTable, InvoiceRow>,
          ),
          InvoiceRow,
          PrefetchHooks Function()
        > {
  $$InvoicesTableTableTableManager(_$AppDatabase db, $InvoicesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> clientName = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String> invoiceDate = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> lineItems = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> totalGst = const Value.absent(),
                Value<double> grandTotal = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<double> balanceDue = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> paymentDate = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurringFrequency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                clientName: clientName,
                invoiceNumber: invoiceNumber,
                gstin: gstin,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                lineItems: lineItems,
                subtotal: subtotal,
                discountAmount: discountAmount,
                totalGst: totalGst,
                grandTotal: grandTotal,
                paidAmount: paidAmount,
                balanceDue: balanceDue,
                status: status,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                remarks: remarks,
                terms: terms,
                isRecurring: isRecurring,
                recurringFrequency: recurringFrequency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                required String clientName,
                required String invoiceNumber,
                Value<String?> gstin = const Value.absent(),
                required String invoiceDate,
                required String dueDate,
                Value<String> lineItems = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> totalGst = const Value.absent(),
                Value<double> grandTotal = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<double> balanceDue = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> paymentDate = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurringFrequency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                clientName: clientName,
                invoiceNumber: invoiceNumber,
                gstin: gstin,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                lineItems: lineItems,
                subtotal: subtotal,
                discountAmount: discountAmount,
                totalGst: totalGst,
                grandTotal: grandTotal,
                paidAmount: paidAmount,
                balanceDue: balanceDue,
                status: status,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                remarks: remarks,
                terms: terms,
                isRecurring: isRecurring,
                recurringFrequency: recurringFrequency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTableTable,
      InvoiceRow,
      $$InvoicesTableTableFilterComposer,
      $$InvoicesTableTableOrderingComposer,
      $$InvoicesTableTableAnnotationComposer,
      $$InvoicesTableTableCreateCompanionBuilder,
      $$InvoicesTableTableUpdateCompanionBuilder,
      (
        InvoiceRow,
        BaseReferences<_$AppDatabase, $InvoicesTableTable, InvoiceRow>,
      ),
      InvoiceRow,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String invoiceId,
      required String clientName,
      required double amount,
      required String paymentDate,
      required String mode,
      required String reference,
      required String notes,
      Value<DateTime> createdAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> invoiceId,
      Value<String> clientName,
      Value<double> amount,
      Value<String> paymentDate,
      Value<String> mode,
      Value<String> reference,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          PaymentRow,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (
            PaymentRow,
            BaseReferences<_$AppDatabase, $PaymentsTableTable, PaymentRow>,
          ),
          PaymentRow,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> clientName = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentDate = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion(
                id: id,
                firmId: firmId,
                invoiceId: invoiceId,
                clientName: clientName,
                amount: amount,
                paymentDate: paymentDate,
                mode: mode,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String invoiceId,
                required String clientName,
                required double amount,
                required String paymentDate,
                required String mode,
                required String reference,
                required String notes,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                id: id,
                firmId: firmId,
                invoiceId: invoiceId,
                clientName: clientName,
                amount: amount,
                paymentDate: paymentDate,
                mode: mode,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      PaymentRow,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (
        PaymentRow,
        BaseReferences<_$AppDatabase, $PaymentsTableTable, PaymentRow>,
      ),
      PaymentRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableTableCreateCompanionBuilder =
    TasksTableCompanion Function({
      Value<String> id,
      required String firmId,
      required String clientId,
      required String clientName,
      required String title,
      required String description,
      required String taskType,
      Value<String> priority,
      Value<String> status,
      required String assignedTo,
      required String assignedBy,
      required String dueDate,
      Value<String?> completedDate,
      Value<String> tags,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$TasksTableTableUpdateCompanionBuilder =
    TasksTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> clientId,
      Value<String> clientName,
      Value<String> title,
      Value<String> description,
      Value<String> taskType,
      Value<String> priority,
      Value<String> status,
      Value<String> assignedTo,
      Value<String> assignedBy,
      Value<String> dueDate,
      Value<String?> completedDate,
      Value<String> tags,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> syncedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedBy => $composableBuilder(
    column: $table.assignedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
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

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedBy => $composableBuilder(
    column: $table.assignedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
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

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedBy => $composableBuilder(
    column: $table.assignedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$TasksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTableTable,
          TaskRow,
          $$TasksTableTableFilterComposer,
          $$TasksTableTableOrderingComposer,
          $$TasksTableTableAnnotationComposer,
          $$TasksTableTableCreateCompanionBuilder,
          $$TasksTableTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTableTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableTableManager(_$AppDatabase db, $TasksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> clientName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> assignedTo = const Value.absent(),
                Value<String> assignedBy = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String?> completedDate = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion(
                id: id,
                firmId: firmId,
                clientId: clientId,
                clientName: clientName,
                title: title,
                description: description,
                taskType: taskType,
                priority: priority,
                status: status,
                assignedTo: assignedTo,
                assignedBy: assignedBy,
                dueDate: dueDate,
                completedDate: completedDate,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firmId,
                required String clientId,
                required String clientName,
                required String title,
                required String description,
                required String taskType,
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String assignedTo,
                required String assignedBy,
                required String dueDate,
                Value<String?> completedDate = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion.insert(
                id: id,
                firmId: firmId,
                clientId: clientId,
                clientName: clientName,
                title: title,
                description: description,
                taskType: taskType,
                priority: priority,
                status: status,
                assignedTo: assignedTo,
                assignedBy: assignedBy,
                dueDate: dueDate,
                completedDate: completedDate,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTableTable,
      TaskRow,
      $$TasksTableTableFilterComposer,
      $$TasksTableTableOrderingComposer,
      $$TasksTableTableAnnotationComposer,
      $$TasksTableTableCreateCompanionBuilder,
      $$TasksTableTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTableTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$FirmInfoTableTableCreateCompanionBuilder =
    FirmInfoTableCompanion Function({
      required String id,
      required String name,
      required String address,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      required String panNumber,
      required String tanNumber,
      Value<Uint8List?> dscCertificate,
      Value<String?> bankAccount,
      Value<DateTime?> registrationDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$FirmInfoTableTableUpdateCompanionBuilder =
    FirmInfoTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> address,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String> panNumber,
      Value<String> tanNumber,
      Value<Uint8List?> dscCertificate,
      Value<String?> bankAccount,
      Value<DateTime?> registrationDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FirmInfoTableTableFilterComposer
    extends Composer<_$AppDatabase, $FirmInfoTableTable> {
  $$FirmInfoTableTableFilterComposer({
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

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get panNumber => $composableBuilder(
    column: $table.panNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tanNumber => $composableBuilder(
    column: $table.tanNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get dscCertificate => $composableBuilder(
    column: $table.dscCertificate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankAccount => $composableBuilder(
    column: $table.bankAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registrationDate => $composableBuilder(
    column: $table.registrationDate,
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

class $$FirmInfoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FirmInfoTableTable> {
  $$FirmInfoTableTableOrderingComposer({
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

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get panNumber => $composableBuilder(
    column: $table.panNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tanNumber => $composableBuilder(
    column: $table.tanNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get dscCertificate => $composableBuilder(
    column: $table.dscCertificate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankAccount => $composableBuilder(
    column: $table.bankAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registrationDate => $composableBuilder(
    column: $table.registrationDate,
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

class $$FirmInfoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FirmInfoTableTable> {
  $$FirmInfoTableTableAnnotationComposer({
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

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get panNumber =>
      $composableBuilder(column: $table.panNumber, builder: (column) => column);

  GeneratedColumn<String> get tanNumber =>
      $composableBuilder(column: $table.tanNumber, builder: (column) => column);

  GeneratedColumn<Uint8List> get dscCertificate => $composableBuilder(
    column: $table.dscCertificate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankAccount => $composableBuilder(
    column: $table.bankAccount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get registrationDate => $composableBuilder(
    column: $table.registrationDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FirmInfoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FirmInfoTableTable,
          FirmInfoTableData,
          $$FirmInfoTableTableFilterComposer,
          $$FirmInfoTableTableOrderingComposer,
          $$FirmInfoTableTableAnnotationComposer,
          $$FirmInfoTableTableCreateCompanionBuilder,
          $$FirmInfoTableTableUpdateCompanionBuilder,
          (
            FirmInfoTableData,
            BaseReferences<
              _$AppDatabase,
              $FirmInfoTableTable,
              FirmInfoTableData
            >,
          ),
          FirmInfoTableData,
          PrefetchHooks Function()
        > {
  $$FirmInfoTableTableTableManager(_$AppDatabase db, $FirmInfoTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FirmInfoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FirmInfoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FirmInfoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String> panNumber = const Value.absent(),
                Value<String> tanNumber = const Value.absent(),
                Value<Uint8List?> dscCertificate = const Value.absent(),
                Value<String?> bankAccount = const Value.absent(),
                Value<DateTime?> registrationDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FirmInfoTableCompanion(
                id: id,
                name: name,
                address: address,
                city: city,
                state: state,
                pincode: pincode,
                panNumber: panNumber,
                tanNumber: tanNumber,
                dscCertificate: dscCertificate,
                bankAccount: bankAccount,
                registrationDate: registrationDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String address,
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                required String panNumber,
                required String tanNumber,
                Value<Uint8List?> dscCertificate = const Value.absent(),
                Value<String?> bankAccount = const Value.absent(),
                Value<DateTime?> registrationDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FirmInfoTableCompanion.insert(
                id: id,
                name: name,
                address: address,
                city: city,
                state: state,
                pincode: pincode,
                panNumber: panNumber,
                tanNumber: tanNumber,
                dscCertificate: dscCertificate,
                bankAccount: bankAccount,
                registrationDate: registrationDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FirmInfoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FirmInfoTableTable,
      FirmInfoTableData,
      $$FirmInfoTableTableFilterComposer,
      $$FirmInfoTableTableOrderingComposer,
      $$FirmInfoTableTableAnnotationComposer,
      $$FirmInfoTableTableCreateCompanionBuilder,
      $$FirmInfoTableTableUpdateCompanionBuilder,
      (
        FirmInfoTableData,
        BaseReferences<_$AppDatabase, $FirmInfoTableTable, FirmInfoTableData>,
      ),
      FirmInfoTableData,
      PrefetchHooks Function()
    >;
typedef $$TeamMembersTableTableCreateCompanionBuilder =
    TeamMembersTableCompanion Function({
      required String id,
      required String firmId,
      required String name,
      required String pan,
      Value<String?> role,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> permissions,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TeamMembersTableTableUpdateCompanionBuilder =
    TeamMembersTableCompanion Function({
      Value<String> id,
      Value<String> firmId,
      Value<String> name,
      Value<String> pan,
      Value<String?> role,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> permissions,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TeamMembersTableTableFilterComposer
    extends Composer<_$AppDatabase, $TeamMembersTableTable> {
  $$TeamMembersTableTableFilterComposer({
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

  ColumnFilters<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
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

  ColumnFilters<String> get permissions => $composableBuilder(
    column: $table.permissions,
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

class $$TeamMembersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamMembersTableTable> {
  $$TeamMembersTableTableOrderingComposer({
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

  ColumnOrderings<String> get firmId => $composableBuilder(
    column: $table.firmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
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

  ColumnOrderings<String> get permissions => $composableBuilder(
    column: $table.permissions,
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

class $$TeamMembersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamMembersTableTable> {
  $$TeamMembersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmId =>
      $composableBuilder(column: $table.firmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TeamMembersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamMembersTableTable,
          TeamMembersTableData,
          $$TeamMembersTableTableFilterComposer,
          $$TeamMembersTableTableOrderingComposer,
          $$TeamMembersTableTableAnnotationComposer,
          $$TeamMembersTableTableCreateCompanionBuilder,
          $$TeamMembersTableTableUpdateCompanionBuilder,
          (
            TeamMembersTableData,
            BaseReferences<
              _$AppDatabase,
              $TeamMembersTableTable,
              TeamMembersTableData
            >,
          ),
          TeamMembersTableData,
          PrefetchHooks Function()
        > {
  $$TeamMembersTableTableTableManager(
    _$AppDatabase db,
    $TeamMembersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamMembersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamMembersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamMembersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> pan = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> permissions = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersTableCompanion(
                id: id,
                firmId: firmId,
                name: name,
                pan: pan,
                role: role,
                email: email,
                phone: phone,
                permissions: permissions,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String firmId,
                required String name,
                required String pan,
                Value<String?> role = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> permissions = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersTableCompanion.insert(
                id: id,
                firmId: firmId,
                name: name,
                pan: pan,
                role: role,
                email: email,
                phone: phone,
                permissions: permissions,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamMembersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamMembersTableTable,
      TeamMembersTableData,
      $$TeamMembersTableTableFilterComposer,
      $$TeamMembersTableTableOrderingComposer,
      $$TeamMembersTableTableAnnotationComposer,
      $$TeamMembersTableTableCreateCompanionBuilder,
      $$TeamMembersTableTableUpdateCompanionBuilder,
      (
        TeamMembersTableData,
        BaseReferences<
          _$AppDatabase,
          $TeamMembersTableTable,
          TeamMembersTableData
        >,
      ),
      TeamMembersTableData,
      PrefetchHooks Function()
    >;
typedef $$ClientAssignmentsTableTableCreateCompanionBuilder =
    ClientAssignmentsTableCompanion Function({
      required String id,
      required String clientId,
      Value<String?> assignedToId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ClientAssignmentsTableTableUpdateCompanionBuilder =
    ClientAssignmentsTableCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String?> assignedToId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ClientAssignmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClientAssignmentsTableTable> {
  $$ClientAssignmentsTableTableFilterComposer({
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

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToId => $composableBuilder(
    column: $table.assignedToId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
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

class $$ClientAssignmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientAssignmentsTableTable> {
  $$ClientAssignmentsTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToId => $composableBuilder(
    column: $table.assignedToId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
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

class $$ClientAssignmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientAssignmentsTableTable> {
  $$ClientAssignmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get assignedToId => $composableBuilder(
    column: $table.assignedToId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ClientAssignmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientAssignmentsTableTable,
          ClientAssignmentsTableData,
          $$ClientAssignmentsTableTableFilterComposer,
          $$ClientAssignmentsTableTableOrderingComposer,
          $$ClientAssignmentsTableTableAnnotationComposer,
          $$ClientAssignmentsTableTableCreateCompanionBuilder,
          $$ClientAssignmentsTableTableUpdateCompanionBuilder,
          (
            ClientAssignmentsTableData,
            BaseReferences<
              _$AppDatabase,
              $ClientAssignmentsTableTable,
              ClientAssignmentsTableData
            >,
          ),
          ClientAssignmentsTableData,
          PrefetchHooks Function()
        > {
  $$ClientAssignmentsTableTableTableManager(
    _$AppDatabase db,
    $ClientAssignmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientAssignmentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ClientAssignmentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClientAssignmentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> assignedToId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientAssignmentsTableCompanion(
                id: id,
                clientId: clientId,
                assignedToId: assignedToId,
                startDate: startDate,
                endDate: endDate,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<String?> assignedToId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientAssignmentsTableCompanion.insert(
                id: id,
                clientId: clientId,
                assignedToId: assignedToId,
                startDate: startDate,
                endDate: endDate,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientAssignmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientAssignmentsTableTable,
      ClientAssignmentsTableData,
      $$ClientAssignmentsTableTableFilterComposer,
      $$ClientAssignmentsTableTableOrderingComposer,
      $$ClientAssignmentsTableTableAnnotationComposer,
      $$ClientAssignmentsTableTableCreateCompanionBuilder,
      $$ClientAssignmentsTableTableUpdateCompanionBuilder,
      (
        ClientAssignmentsTableData,
        BaseReferences<
          _$AppDatabase,
          $ClientAssignmentsTableTable,
          ClientAssignmentsTableData
        >,
      ),
      ClientAssignmentsTableData,
      PrefetchHooks Function()
    >;
typedef $$PayrollEntriesTableTableCreateCompanionBuilder =
    PayrollEntriesTableCompanion Function({
      required String id,
      required String clientId,
      Value<String?> employeeId,
      required int month,
      required int year,
      Value<String?> basicSalary,
      Value<String?> allowances,
      Value<String?> deductions,
      Value<String?> tdsDeducted,
      Value<String?> pfDeducted,
      Value<String?> esiDeducted,
      Value<String?> netSalary,
      Value<String?> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PayrollEntriesTableTableUpdateCompanionBuilder =
    PayrollEntriesTableCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String?> employeeId,
      Value<int> month,
      Value<int> year,
      Value<String?> basicSalary,
      Value<String?> allowances,
      Value<String?> deductions,
      Value<String?> tdsDeducted,
      Value<String?> pfDeducted,
      Value<String?> esiDeducted,
      Value<String?> netSalary,
      Value<String?> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PayrollEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PayrollEntriesTableTable> {
  $$PayrollEntriesTableTableFilterComposer({
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

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basicSalary => $composableBuilder(
    column: $table.basicSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allowances => $composableBuilder(
    column: $table.allowances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductions => $composableBuilder(
    column: $table.deductions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tdsDeducted => $composableBuilder(
    column: $table.tdsDeducted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pfDeducted => $composableBuilder(
    column: $table.pfDeducted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get esiDeducted => $composableBuilder(
    column: $table.esiDeducted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get netSalary => $composableBuilder(
    column: $table.netSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

class $$PayrollEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PayrollEntriesTableTable> {
  $$PayrollEntriesTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basicSalary => $composableBuilder(
    column: $table.basicSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowances => $composableBuilder(
    column: $table.allowances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductions => $composableBuilder(
    column: $table.deductions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tdsDeducted => $composableBuilder(
    column: $table.tdsDeducted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pfDeducted => $composableBuilder(
    column: $table.pfDeducted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get esiDeducted => $composableBuilder(
    column: $table.esiDeducted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get netSalary => $composableBuilder(
    column: $table.netSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

class $$PayrollEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayrollEntriesTableTable> {
  $$PayrollEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get basicSalary => $composableBuilder(
    column: $table.basicSalary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allowances => $composableBuilder(
    column: $table.allowances,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deductions => $composableBuilder(
    column: $table.deductions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tdsDeducted => $composableBuilder(
    column: $table.tdsDeducted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pfDeducted => $composableBuilder(
    column: $table.pfDeducted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get esiDeducted => $composableBuilder(
    column: $table.esiDeducted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get netSalary =>
      $composableBuilder(column: $table.netSalary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PayrollEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayrollEntriesTableTable,
          PayrollEntriesTableData,
          $$PayrollEntriesTableTableFilterComposer,
          $$PayrollEntriesTableTableOrderingComposer,
          $$PayrollEntriesTableTableAnnotationComposer,
          $$PayrollEntriesTableTableCreateCompanionBuilder,
          $$PayrollEntriesTableTableUpdateCompanionBuilder,
          (
            PayrollEntriesTableData,
            BaseReferences<
              _$AppDatabase,
              $PayrollEntriesTableTable,
              PayrollEntriesTableData
            >,
          ),
          PayrollEntriesTableData,
          PrefetchHooks Function()
        > {
  $$PayrollEntriesTableTableTableManager(
    _$AppDatabase db,
    $PayrollEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayrollEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayrollEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PayrollEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> employeeId = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> basicSalary = const Value.absent(),
                Value<String?> allowances = const Value.absent(),
                Value<String?> deductions = const Value.absent(),
                Value<String?> tdsDeducted = const Value.absent(),
                Value<String?> pfDeducted = const Value.absent(),
                Value<String?> esiDeducted = const Value.absent(),
                Value<String?> netSalary = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayrollEntriesTableCompanion(
                id: id,
                clientId: clientId,
                employeeId: employeeId,
                month: month,
                year: year,
                basicSalary: basicSalary,
                allowances: allowances,
                deductions: deductions,
                tdsDeducted: tdsDeducted,
                pfDeducted: pfDeducted,
                esiDeducted: esiDeducted,
                netSalary: netSalary,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<String?> employeeId = const Value.absent(),
                required int month,
                required int year,
                Value<String?> basicSalary = const Value.absent(),
                Value<String?> allowances = const Value.absent(),
                Value<String?> deductions = const Value.absent(),
                Value<String?> tdsDeducted = const Value.absent(),
                Value<String?> pfDeducted = const Value.absent(),
                Value<String?> esiDeducted = const Value.absent(),
                Value<String?> netSalary = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayrollEntriesTableCompanion.insert(
                id: id,
                clientId: clientId,
                employeeId: employeeId,
                month: month,
                year: year,
                basicSalary: basicSalary,
                allowances: allowances,
                deductions: deductions,
                tdsDeducted: tdsDeducted,
                pfDeducted: pfDeducted,
                esiDeducted: esiDeducted,
                netSalary: netSalary,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayrollEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayrollEntriesTableTable,
      PayrollEntriesTableData,
      $$PayrollEntriesTableTableFilterComposer,
      $$PayrollEntriesTableTableOrderingComposer,
      $$PayrollEntriesTableTableAnnotationComposer,
      $$PayrollEntriesTableTableCreateCompanionBuilder,
      $$PayrollEntriesTableTableUpdateCompanionBuilder,
      (
        PayrollEntriesTableData,
        BaseReferences<
          _$AppDatabase,
          $PayrollEntriesTableTable,
          PayrollEntriesTableData
        >,
      ),
      PayrollEntriesTableData,
      PrefetchHooks Function()
    >;
typedef $$AuditAssignmentsTableTableCreateCompanionBuilder =
    AuditAssignmentsTableCompanion Function({
      required String id,
      required String clientId,
      Value<String?> auditorId,
      Value<String?> financialYear,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> status,
      Value<String?> fee,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AuditAssignmentsTableTableUpdateCompanionBuilder =
    AuditAssignmentsTableCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String?> auditorId,
      Value<String?> financialYear,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> status,
      Value<String?> fee,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AuditAssignmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuditAssignmentsTableTable> {
  $$AuditAssignmentsTableTableFilterComposer({
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

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditorId => $composableBuilder(
    column: $table.auditorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fee => $composableBuilder(
    column: $table.fee,
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

class $$AuditAssignmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditAssignmentsTableTable> {
  $$AuditAssignmentsTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditorId => $composableBuilder(
    column: $table.auditorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fee => $composableBuilder(
    column: $table.fee,
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

class $$AuditAssignmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditAssignmentsTableTable> {
  $$AuditAssignmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get auditorId =>
      $composableBuilder(column: $table.auditorId, builder: (column) => column);

  GeneratedColumn<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AuditAssignmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditAssignmentsTableTable,
          AuditAssignmentsTableData,
          $$AuditAssignmentsTableTableFilterComposer,
          $$AuditAssignmentsTableTableOrderingComposer,
          $$AuditAssignmentsTableTableAnnotationComposer,
          $$AuditAssignmentsTableTableCreateCompanionBuilder,
          $$AuditAssignmentsTableTableUpdateCompanionBuilder,
          (
            AuditAssignmentsTableData,
            BaseReferences<
              _$AppDatabase,
              $AuditAssignmentsTableTable,
              AuditAssignmentsTableData
            >,
          ),
          AuditAssignmentsTableData,
          PrefetchHooks Function()
        > {
  $$AuditAssignmentsTableTableTableManager(
    _$AppDatabase db,
    $AuditAssignmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditAssignmentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AuditAssignmentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AuditAssignmentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> auditorId = const Value.absent(),
                Value<String?> financialYear = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> fee = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditAssignmentsTableCompanion(
                id: id,
                clientId: clientId,
                auditorId: auditorId,
                financialYear: financialYear,
                startDate: startDate,
                endDate: endDate,
                status: status,
                fee: fee,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<String?> auditorId = const Value.absent(),
                Value<String?> financialYear = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> fee = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditAssignmentsTableCompanion.insert(
                id: id,
                clientId: clientId,
                auditorId: auditorId,
                financialYear: financialYear,
                startDate: startDate,
                endDate: endDate,
                status: status,
                fee: fee,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditAssignmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditAssignmentsTableTable,
      AuditAssignmentsTableData,
      $$AuditAssignmentsTableTableFilterComposer,
      $$AuditAssignmentsTableTableOrderingComposer,
      $$AuditAssignmentsTableTableAnnotationComposer,
      $$AuditAssignmentsTableTableCreateCompanionBuilder,
      $$AuditAssignmentsTableTableUpdateCompanionBuilder,
      (
        AuditAssignmentsTableData,
        BaseReferences<
          _$AppDatabase,
          $AuditAssignmentsTableTable,
          AuditAssignmentsTableData
        >,
      ),
      AuditAssignmentsTableData,
      PrefetchHooks Function()
    >;
typedef $$AuditReportsTableTableCreateCompanionBuilder =
    AuditReportsTableCompanion Function({
      required String id,
      required String clientId,
      required int year,
      Value<String?> saReportNumber,
      Value<DateTime?> reportDate,
      Value<String?> reportedBy,
      Value<String?> auditFindings,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AuditReportsTableTableUpdateCompanionBuilder =
    AuditReportsTableCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<int> year,
      Value<String?> saReportNumber,
      Value<DateTime?> reportDate,
      Value<String?> reportedBy,
      Value<String?> auditFindings,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AuditReportsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuditReportsTableTable> {
  $$AuditReportsTableTableFilterComposer({
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

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saReportNumber => $composableBuilder(
    column: $table.saReportNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditFindings => $composableBuilder(
    column: $table.auditFindings,
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

class $$AuditReportsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditReportsTableTable> {
  $$AuditReportsTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saReportNumber => $composableBuilder(
    column: $table.saReportNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditFindings => $composableBuilder(
    column: $table.auditFindings,
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

class $$AuditReportsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditReportsTableTable> {
  $$AuditReportsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get saReportNumber => $composableBuilder(
    column: $table.saReportNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get auditFindings => $composableBuilder(
    column: $table.auditFindings,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AuditReportsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditReportsTableTable,
          AuditReportsTableData,
          $$AuditReportsTableTableFilterComposer,
          $$AuditReportsTableTableOrderingComposer,
          $$AuditReportsTableTableAnnotationComposer,
          $$AuditReportsTableTableCreateCompanionBuilder,
          $$AuditReportsTableTableUpdateCompanionBuilder,
          (
            AuditReportsTableData,
            BaseReferences<
              _$AppDatabase,
              $AuditReportsTableTable,
              AuditReportsTableData
            >,
          ),
          AuditReportsTableData,
          PrefetchHooks Function()
        > {
  $$AuditReportsTableTableTableManager(
    _$AppDatabase db,
    $AuditReportsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditReportsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditReportsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditReportsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> saReportNumber = const Value.absent(),
                Value<DateTime?> reportDate = const Value.absent(),
                Value<String?> reportedBy = const Value.absent(),
                Value<String?> auditFindings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditReportsTableCompanion(
                id: id,
                clientId: clientId,
                year: year,
                saReportNumber: saReportNumber,
                reportDate: reportDate,
                reportedBy: reportedBy,
                auditFindings: auditFindings,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required int year,
                Value<String?> saReportNumber = const Value.absent(),
                Value<DateTime?> reportDate = const Value.absent(),
                Value<String?> reportedBy = const Value.absent(),
                Value<String?> auditFindings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditReportsTableCompanion.insert(
                id: id,
                clientId: clientId,
                year: year,
                saReportNumber: saReportNumber,
                reportDate: reportDate,
                reportedBy: reportedBy,
                auditFindings: auditFindings,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditReportsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditReportsTableTable,
      AuditReportsTableData,
      $$AuditReportsTableTableFilterComposer,
      $$AuditReportsTableTableOrderingComposer,
      $$AuditReportsTableTableAnnotationComposer,
      $$AuditReportsTableTableCreateCompanionBuilder,
      $$AuditReportsTableTableUpdateCompanionBuilder,
      (
        AuditReportsTableData,
        BaseReferences<
          _$AppDatabase,
          $AuditReportsTableTable,
          AuditReportsTableData
        >,
      ),
      AuditReportsTableData,
      PrefetchHooks Function()
    >;
typedef $$MCAFilingsTableTableCreateCompanionBuilder =
    MCAFilingsTableCompanion Function({
      required String id,
      required String clientId,
      Value<String?> formType,
      Value<String?> financialYear,
      Value<DateTime?> dueDate,
      Value<DateTime?> filedDate,
      Value<String?> status,
      Value<String?> filingNumber,
      Value<String?> remarks,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$MCAFilingsTableTableUpdateCompanionBuilder =
    MCAFilingsTableCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String?> formType,
      Value<String?> financialYear,
      Value<DateTime?> dueDate,
      Value<DateTime?> filedDate,
      Value<String?> status,
      Value<String?> filingNumber,
      Value<String?> remarks,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MCAFilingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MCAFilingsTableTable> {
  $$MCAFilingsTableTableFilterComposer({
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

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filingNumber => $composableBuilder(
    column: $table.filingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
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

class $$MCAFilingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MCAFilingsTableTable> {
  $$MCAFilingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get filedDate => $composableBuilder(
    column: $table.filedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filingNumber => $composableBuilder(
    column: $table.filingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
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

class $$MCAFilingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MCAFilingsTableTable> {
  $$MCAFilingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get formType =>
      $composableBuilder(column: $table.formType, builder: (column) => column);

  GeneratedColumn<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get filedDate =>
      $composableBuilder(column: $table.filedDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get filingNumber => $composableBuilder(
    column: $table.filingNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MCAFilingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MCAFilingsTableTable,
          MCAFilingsTableData,
          $$MCAFilingsTableTableFilterComposer,
          $$MCAFilingsTableTableOrderingComposer,
          $$MCAFilingsTableTableAnnotationComposer,
          $$MCAFilingsTableTableCreateCompanionBuilder,
          $$MCAFilingsTableTableUpdateCompanionBuilder,
          (
            MCAFilingsTableData,
            BaseReferences<
              _$AppDatabase,
              $MCAFilingsTableTable,
              MCAFilingsTableData
            >,
          ),
          MCAFilingsTableData,
          PrefetchHooks Function()
        > {
  $$MCAFilingsTableTableTableManager(
    _$AppDatabase db,
    $MCAFilingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MCAFilingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MCAFilingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MCAFilingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> formType = const Value.absent(),
                Value<String?> financialYear = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> filedDate = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> filingNumber = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MCAFilingsTableCompanion(
                id: id,
                clientId: clientId,
                formType: formType,
                financialYear: financialYear,
                dueDate: dueDate,
                filedDate: filedDate,
                status: status,
                filingNumber: filingNumber,
                remarks: remarks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<String?> formType = const Value.absent(),
                Value<String?> financialYear = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> filedDate = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> filingNumber = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MCAFilingsTableCompanion.insert(
                id: id,
                clientId: clientId,
                formType: formType,
                financialYear: financialYear,
                dueDate: dueDate,
                filedDate: filedDate,
                status: status,
                filingNumber: filingNumber,
                remarks: remarks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MCAFilingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MCAFilingsTableTable,
      MCAFilingsTableData,
      $$MCAFilingsTableTableFilterComposer,
      $$MCAFilingsTableTableOrderingComposer,
      $$MCAFilingsTableTableAnnotationComposer,
      $$MCAFilingsTableTableCreateCompanionBuilder,
      $$MCAFilingsTableTableUpdateCompanionBuilder,
      (
        MCAFilingsTableData,
        BaseReferences<
          _$AppDatabase,
          $MCAFilingsTableTable,
          MCAFilingsTableData
        >,
      ),
      MCAFilingsTableData,
      PrefetchHooks Function()
    >;
typedef $$ReconciliationResultsTableTableCreateCompanionBuilder =
    ReconciliationResultsTableCompanion Function({
      required String id,
      required String clientId,
      Value<String?> reconciliationType,
      Value<String?> period,
      Value<int?> totalMatched,
      Value<int?> totalUnmatched,
      Value<String?> discrepancies,
      Value<String?> status,
      Value<String?> reviewedBy,
      Value<DateTime?> reviewedDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ReconciliationResultsTableTableUpdateCompanionBuilder =
    ReconciliationResultsTableCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String?> reconciliationType,
      Value<String?> period,
      Value<int?> totalMatched,
      Value<int?> totalUnmatched,
      Value<String?> discrepancies,
      Value<String?> status,
      Value<String?> reviewedBy,
      Value<DateTime?> reviewedDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ReconciliationResultsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReconciliationResultsTableTable> {
  $$ReconciliationResultsTableTableFilterComposer({
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

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reconciliationType => $composableBuilder(
    column: $table.reconciliationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMatched => $composableBuilder(
    column: $table.totalMatched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalUnmatched => $composableBuilder(
    column: $table.totalUnmatched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discrepancies => $composableBuilder(
    column: $table.discrepancies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedDate => $composableBuilder(
    column: $table.reviewedDate,
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

class $$ReconciliationResultsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReconciliationResultsTableTable> {
  $$ReconciliationResultsTableTableOrderingComposer({
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

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reconciliationType => $composableBuilder(
    column: $table.reconciliationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMatched => $composableBuilder(
    column: $table.totalMatched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalUnmatched => $composableBuilder(
    column: $table.totalUnmatched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discrepancies => $composableBuilder(
    column: $table.discrepancies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedDate => $composableBuilder(
    column: $table.reviewedDate,
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

class $$ReconciliationResultsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReconciliationResultsTableTable> {
  $$ReconciliationResultsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get reconciliationType => $composableBuilder(
    column: $table.reconciliationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get totalMatched => $composableBuilder(
    column: $table.totalMatched,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalUnmatched => $composableBuilder(
    column: $table.totalUnmatched,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discrepancies => $composableBuilder(
    column: $table.discrepancies,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedDate => $composableBuilder(
    column: $table.reviewedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReconciliationResultsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReconciliationResultsTableTable,
          ReconciliationResultsTableData,
          $$ReconciliationResultsTableTableFilterComposer,
          $$ReconciliationResultsTableTableOrderingComposer,
          $$ReconciliationResultsTableTableAnnotationComposer,
          $$ReconciliationResultsTableTableCreateCompanionBuilder,
          $$ReconciliationResultsTableTableUpdateCompanionBuilder,
          (
            ReconciliationResultsTableData,
            BaseReferences<
              _$AppDatabase,
              $ReconciliationResultsTableTable,
              ReconciliationResultsTableData
            >,
          ),
          ReconciliationResultsTableData,
          PrefetchHooks Function()
        > {
  $$ReconciliationResultsTableTableTableManager(
    _$AppDatabase db,
    $ReconciliationResultsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReconciliationResultsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReconciliationResultsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReconciliationResultsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> reconciliationType = const Value.absent(),
                Value<String?> period = const Value.absent(),
                Value<int?> totalMatched = const Value.absent(),
                Value<int?> totalUnmatched = const Value.absent(),
                Value<String?> discrepancies = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReconciliationResultsTableCompanion(
                id: id,
                clientId: clientId,
                reconciliationType: reconciliationType,
                period: period,
                totalMatched: totalMatched,
                totalUnmatched: totalUnmatched,
                discrepancies: discrepancies,
                status: status,
                reviewedBy: reviewedBy,
                reviewedDate: reviewedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<String?> reconciliationType = const Value.absent(),
                Value<String?> period = const Value.absent(),
                Value<int?> totalMatched = const Value.absent(),
                Value<int?> totalUnmatched = const Value.absent(),
                Value<String?> discrepancies = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> reviewedBy = const Value.absent(),
                Value<DateTime?> reviewedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReconciliationResultsTableCompanion.insert(
                id: id,
                clientId: clientId,
                reconciliationType: reconciliationType,
                period: period,
                totalMatched: totalMatched,
                totalUnmatched: totalUnmatched,
                discrepancies: discrepancies,
                status: status,
                reviewedBy: reviewedBy,
                reviewedDate: reviewedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReconciliationResultsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReconciliationResultsTableTable,
      ReconciliationResultsTableData,
      $$ReconciliationResultsTableTableFilterComposer,
      $$ReconciliationResultsTableTableOrderingComposer,
      $$ReconciliationResultsTableTableAnnotationComposer,
      $$ReconciliationResultsTableTableCreateCompanionBuilder,
      $$ReconciliationResultsTableTableUpdateCompanionBuilder,
      (
        ReconciliationResultsTableData,
        BaseReferences<
          _$AppDatabase,
          $ReconciliationResultsTableTable,
          ReconciliationResultsTableData
        >,
      ),
      ReconciliationResultsTableData,
      PrefetchHooks Function()
    >;
typedef $$PortalCredentialsTableTableCreateCompanionBuilder =
    PortalCredentialsTableCompanion Function({
      required String id,
      required String portalType,
      Value<String?> username,
      Value<String?> encryptedPassword,
      Value<String?> grantToken,
      Value<String?> refreshToken,
      Value<DateTime?> expiresAt,
      Value<DateTime?> lastSyncDate,
      Value<String?> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PortalCredentialsTableTableUpdateCompanionBuilder =
    PortalCredentialsTableCompanion Function({
      Value<String> id,
      Value<String> portalType,
      Value<String?> username,
      Value<String?> encryptedPassword,
      Value<String?> grantToken,
      Value<String?> refreshToken,
      Value<DateTime?> expiresAt,
      Value<DateTime?> lastSyncDate,
      Value<String?> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PortalCredentialsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PortalCredentialsTableTable> {
  $$PortalCredentialsTableTableFilterComposer({
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

  ColumnFilters<String> get portalType => $composableBuilder(
    column: $table.portalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grantToken => $composableBuilder(
    column: $table.grantToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncDate => $composableBuilder(
    column: $table.lastSyncDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

class $$PortalCredentialsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PortalCredentialsTableTable> {
  $$PortalCredentialsTableTableOrderingComposer({
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

  ColumnOrderings<String> get portalType => $composableBuilder(
    column: $table.portalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grantToken => $composableBuilder(
    column: $table.grantToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncDate => $composableBuilder(
    column: $table.lastSyncDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

class $$PortalCredentialsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PortalCredentialsTableTable> {
  $$PortalCredentialsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get portalType => $composableBuilder(
    column: $table.portalType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grantToken => $composableBuilder(
    column: $table.grantToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncDate => $composableBuilder(
    column: $table.lastSyncDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PortalCredentialsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PortalCredentialsTableTable,
          PortalCredentialsTableData,
          $$PortalCredentialsTableTableFilterComposer,
          $$PortalCredentialsTableTableOrderingComposer,
          $$PortalCredentialsTableTableAnnotationComposer,
          $$PortalCredentialsTableTableCreateCompanionBuilder,
          $$PortalCredentialsTableTableUpdateCompanionBuilder,
          (
            PortalCredentialsTableData,
            BaseReferences<
              _$AppDatabase,
              $PortalCredentialsTableTable,
              PortalCredentialsTableData
            >,
          ),
          PortalCredentialsTableData,
          PrefetchHooks Function()
        > {
  $$PortalCredentialsTableTableTableManager(
    _$AppDatabase db,
    $PortalCredentialsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PortalCredentialsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PortalCredentialsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PortalCredentialsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> portalType = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> encryptedPassword = const Value.absent(),
                Value<String?> grantToken = const Value.absent(),
                Value<String?> refreshToken = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime?> lastSyncDate = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortalCredentialsTableCompanion(
                id: id,
                portalType: portalType,
                username: username,
                encryptedPassword: encryptedPassword,
                grantToken: grantToken,
                refreshToken: refreshToken,
                expiresAt: expiresAt,
                lastSyncDate: lastSyncDate,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String portalType,
                Value<String?> username = const Value.absent(),
                Value<String?> encryptedPassword = const Value.absent(),
                Value<String?> grantToken = const Value.absent(),
                Value<String?> refreshToken = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime?> lastSyncDate = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortalCredentialsTableCompanion.insert(
                id: id,
                portalType: portalType,
                username: username,
                encryptedPassword: encryptedPassword,
                grantToken: grantToken,
                refreshToken: refreshToken,
                expiresAt: expiresAt,
                lastSyncDate: lastSyncDate,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PortalCredentialsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PortalCredentialsTableTable,
      PortalCredentialsTableData,
      $$PortalCredentialsTableTableFilterComposer,
      $$PortalCredentialsTableTableOrderingComposer,
      $$PortalCredentialsTableTableAnnotationComposer,
      $$PortalCredentialsTableTableCreateCompanionBuilder,
      $$PortalCredentialsTableTableUpdateCompanionBuilder,
      (
        PortalCredentialsTableData,
        BaseReferences<
          _$AppDatabase,
          $PortalCredentialsTableTable,
          PortalCredentialsTableData
        >,
      ),
      PortalCredentialsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableTableManager get clientsTable =>
      $$ClientsTableTableTableManager(_db, _db.clientsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$SyncConflictsTableTableTableManager get syncConflictsTable =>
      $$SyncConflictsTableTableTableManager(_db, _db.syncConflictsTable);
  $$ItrFilingsTableTableTableManager get itrFilingsTable =>
      $$ItrFilingsTableTableTableManager(_db, _db.itrFilingsTable);
  $$GstClientsTableTableTableManager get gstClientsTable =>
      $$GstClientsTableTableTableManager(_db, _db.gstClientsTable);
  $$GstReturnsTableTableTableManager get gstReturnsTable =>
      $$GstReturnsTableTableTableManager(_db, _db.gstReturnsTable);
  $$TdsReturnsTableTableTableManager get tdsReturnsTable =>
      $$TdsReturnsTableTableTableManager(_db, _db.tdsReturnsTable);
  $$TdsChallansTableTableTableManager get tdsChallansTable =>
      $$TdsChallansTableTableTableManager(_db, _db.tdsChallansTable);
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db, _db.invoicesTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$FirmInfoTableTableTableManager get firmInfoTable =>
      $$FirmInfoTableTableTableManager(_db, _db.firmInfoTable);
  $$TeamMembersTableTableTableManager get teamMembersTable =>
      $$TeamMembersTableTableTableManager(_db, _db.teamMembersTable);
  $$ClientAssignmentsTableTableTableManager get clientAssignmentsTable =>
      $$ClientAssignmentsTableTableTableManager(
        _db,
        _db.clientAssignmentsTable,
      );
  $$PayrollEntriesTableTableTableManager get payrollEntriesTable =>
      $$PayrollEntriesTableTableTableManager(_db, _db.payrollEntriesTable);
  $$AuditAssignmentsTableTableTableManager get auditAssignmentsTable =>
      $$AuditAssignmentsTableTableTableManager(_db, _db.auditAssignmentsTable);
  $$AuditReportsTableTableTableManager get auditReportsTable =>
      $$AuditReportsTableTableTableManager(_db, _db.auditReportsTable);
  $$MCAFilingsTableTableTableManager get mCAFilingsTable =>
      $$MCAFilingsTableTableTableManager(_db, _db.mCAFilingsTable);
  $$ReconciliationResultsTableTableTableManager
  get reconciliationResultsTable =>
      $$ReconciliationResultsTableTableTableManager(
        _db,
        _db.reconciliationResultsTable,
      );
  $$PortalCredentialsTableTableTableManager get portalCredentialsTable =>
      $$PortalCredentialsTableTableTableManager(
        _db,
        _db.portalCredentialsTable,
      );
}
