// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LeadsTable extends Leads with TableInfo<$LeadsTable, Lead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
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
  static const VerificationMeta _segmentMeta = const VerificationMeta(
    'segment',
  );
  @override
  late final GeneratedColumn<String> segment = GeneratedColumn<String>(
    'segment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employerMeta = const VerificationMeta(
    'employer',
  );
  @override
  late final GeneratedColumn<String> employer = GeneratedColumn<String>(
    'employer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _declineReasonMeta = const VerificationMeta(
    'declineReason',
  );
  @override
  late final GeneratedColumn<String> declineReason = GeneratedColumn<String>(
    'decline_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productMeta = const VerificationMeta(
    'product',
  );
  @override
  late final GeneratedColumn<String> product = GeneratedColumn<String>(
    'product',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedDateMeta = const VerificationMeta(
    'assignedDate',
  );
  @override
  late final GeneratedColumn<DateTime> assignedDate = GeneratedColumn<DateTime>(
    'assigned_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeCodeMeta = const VerificationMeta(
    'employeeCode',
  );
  @override
  late final GeneratedColumn<String> employeeCode = GeneratedColumn<String>(
    'employee_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadStatusMeta = const VerificationMeta(
    'leadStatus',
  );
  @override
  late final GeneratedColumn<String> leadStatus = GeneratedColumn<String>(
    'lead_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadStatusDateMeta = const VerificationMeta(
    'leadStatusDate',
  );
  @override
  late final GeneratedColumn<DateTime> leadStatusDate =
      GeneratedColumn<DateTime>(
        'lead_status_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataStatusMeta = const VerificationMeta(
    'dataStatus',
  );
  @override
  late final GeneratedColumn<String> dataStatus = GeneratedColumn<String>(
    'data_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followupTimeMeta = const VerificationMeta(
    'followupTime',
  );
  @override
  late final GeneratedColumn<DateTime> followupTime = GeneratedColumn<DateTime>(
    'followup_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arnNoMeta = const VerificationMeta('arnNo');
  @override
  late final GeneratedColumn<String> arnNo = GeneratedColumn<String>(
    'arn_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _syncPendingMeta = const VerificationMeta(
    'syncPending',
  );
  @override
  late final GeneratedColumn<bool> syncPending = GeneratedColumn<bool>(
    'sync_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    mobileNo,
    city,
    segment,
    employer,
    declineReason,
    product,
    assignedTo,
    assignedDate,
    employeeName,
    employeeCode,
    leadStatus,
    leadStatusDate,
    dataStatus,
    followupTime,
    arnNo,
    dateOfBirth,
    remarks,
    syncPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lead> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileNoMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('segment')) {
      context.handle(
        _segmentMeta,
        segment.isAcceptableOrUnknown(data['segment']!, _segmentMeta),
      );
    }
    if (data.containsKey('employer')) {
      context.handle(
        _employerMeta,
        employer.isAcceptableOrUnknown(data['employer']!, _employerMeta),
      );
    }
    if (data.containsKey('decline_reason')) {
      context.handle(
        _declineReasonMeta,
        declineReason.isAcceptableOrUnknown(
          data['decline_reason']!,
          _declineReasonMeta,
        ),
      );
    }
    if (data.containsKey('product')) {
      context.handle(
        _productMeta,
        product.isAcceptableOrUnknown(data['product']!, _productMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('assigned_date')) {
      context.handle(
        _assignedDateMeta,
        assignedDate.isAcceptableOrUnknown(
          data['assigned_date']!,
          _assignedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assignedDateMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    }
    if (data.containsKey('employee_code')) {
      context.handle(
        _employeeCodeMeta,
        employeeCode.isAcceptableOrUnknown(
          data['employee_code']!,
          _employeeCodeMeta,
        ),
      );
    }
    if (data.containsKey('lead_status')) {
      context.handle(
        _leadStatusMeta,
        leadStatus.isAcceptableOrUnknown(data['lead_status']!, _leadStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_leadStatusMeta);
    }
    if (data.containsKey('lead_status_date')) {
      context.handle(
        _leadStatusDateMeta,
        leadStatusDate.isAcceptableOrUnknown(
          data['lead_status_date']!,
          _leadStatusDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_leadStatusDateMeta);
    }
    if (data.containsKey('data_status')) {
      context.handle(
        _dataStatusMeta,
        dataStatus.isAcceptableOrUnknown(data['data_status']!, _dataStatusMeta),
      );
    }
    if (data.containsKey('followup_time')) {
      context.handle(
        _followupTimeMeta,
        followupTime.isAcceptableOrUnknown(
          data['followup_time']!,
          _followupTimeMeta,
        ),
      );
    }
    if (data.containsKey('arn_no')) {
      context.handle(
        _arnNoMeta,
        arnNo.isAcceptableOrUnknown(data['arn_no']!, _arnNoMeta),
      );
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
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('sync_pending')) {
      context.handle(
        _syncPendingMeta,
        syncPending.isAcceptableOrUnknown(
          data['sync_pending']!,
          _syncPendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lead(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      mobileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_no'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      segment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment'],
      ),
      employer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employer'],
      ),
      declineReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decline_reason'],
      ),
      product: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      assignedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_date'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      ),
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      ),
      leadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_status'],
      )!,
      leadStatusDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lead_status_date'],
      )!,
      dataStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_status'],
      ),
      followupTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}followup_time'],
      ),
      arnNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arn_no'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      syncPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_pending'],
      )!,
    );
  }

  @override
  $LeadsTable createAlias(String alias) {
    return $LeadsTable(attachedDatabase, alias);
  }
}

class Lead extends DataClass implements Insertable<Lead> {
  final String id;
  final String customerName;
  final String mobileNo;
  final String? city;
  final String? segment;
  final String? employer;
  final String? declineReason;
  final String? product;
  final String? assignedTo;
  final DateTime assignedDate;
  final String? employeeName;
  final String? employeeCode;
  final String leadStatus;
  final DateTime leadStatusDate;
  final String? dataStatus;
  final DateTime? followupTime;
  final String? arnNo;
  final DateTime? dateOfBirth;
  final String? remarks;
  final bool syncPending;
  const Lead({
    required this.id,
    required this.customerName,
    required this.mobileNo,
    this.city,
    this.segment,
    this.employer,
    this.declineReason,
    this.product,
    this.assignedTo,
    required this.assignedDate,
    this.employeeName,
    this.employeeCode,
    required this.leadStatus,
    required this.leadStatusDate,
    this.dataStatus,
    this.followupTime,
    this.arnNo,
    this.dateOfBirth,
    this.remarks,
    required this.syncPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['mobile_no'] = Variable<String>(mobileNo);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || segment != null) {
      map['segment'] = Variable<String>(segment);
    }
    if (!nullToAbsent || employer != null) {
      map['employer'] = Variable<String>(employer);
    }
    if (!nullToAbsent || declineReason != null) {
      map['decline_reason'] = Variable<String>(declineReason);
    }
    if (!nullToAbsent || product != null) {
      map['product'] = Variable<String>(product);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    map['assigned_date'] = Variable<DateTime>(assignedDate);
    if (!nullToAbsent || employeeName != null) {
      map['employee_name'] = Variable<String>(employeeName);
    }
    if (!nullToAbsent || employeeCode != null) {
      map['employee_code'] = Variable<String>(employeeCode);
    }
    map['lead_status'] = Variable<String>(leadStatus);
    map['lead_status_date'] = Variable<DateTime>(leadStatusDate);
    if (!nullToAbsent || dataStatus != null) {
      map['data_status'] = Variable<String>(dataStatus);
    }
    if (!nullToAbsent || followupTime != null) {
      map['followup_time'] = Variable<DateTime>(followupTime);
    }
    if (!nullToAbsent || arnNo != null) {
      map['arn_no'] = Variable<String>(arnNo);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['sync_pending'] = Variable<bool>(syncPending);
    return map;
  }

  LeadsCompanion toCompanion(bool nullToAbsent) {
    return LeadsCompanion(
      id: Value(id),
      customerName: Value(customerName),
      mobileNo: Value(mobileNo),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      segment: segment == null && nullToAbsent
          ? const Value.absent()
          : Value(segment),
      employer: employer == null && nullToAbsent
          ? const Value.absent()
          : Value(employer),
      declineReason: declineReason == null && nullToAbsent
          ? const Value.absent()
          : Value(declineReason),
      product: product == null && nullToAbsent
          ? const Value.absent()
          : Value(product),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      assignedDate: Value(assignedDate),
      employeeName: employeeName == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeName),
      employeeCode: employeeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeCode),
      leadStatus: Value(leadStatus),
      leadStatusDate: Value(leadStatusDate),
      dataStatus: dataStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(dataStatus),
      followupTime: followupTime == null && nullToAbsent
          ? const Value.absent()
          : Value(followupTime),
      arnNo: arnNo == null && nullToAbsent
          ? const Value.absent()
          : Value(arnNo),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      syncPending: Value(syncPending),
    );
  }

  factory Lead.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lead(
      id: serializer.fromJson<String>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      city: serializer.fromJson<String?>(json['city']),
      segment: serializer.fromJson<String?>(json['segment']),
      employer: serializer.fromJson<String?>(json['employer']),
      declineReason: serializer.fromJson<String?>(json['declineReason']),
      product: serializer.fromJson<String?>(json['product']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      assignedDate: serializer.fromJson<DateTime>(json['assignedDate']),
      employeeName: serializer.fromJson<String?>(json['employeeName']),
      employeeCode: serializer.fromJson<String?>(json['employeeCode']),
      leadStatus: serializer.fromJson<String>(json['leadStatus']),
      leadStatusDate: serializer.fromJson<DateTime>(json['leadStatusDate']),
      dataStatus: serializer.fromJson<String?>(json['dataStatus']),
      followupTime: serializer.fromJson<DateTime?>(json['followupTime']),
      arnNo: serializer.fromJson<String?>(json['arnNo']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      syncPending: serializer.fromJson<bool>(json['syncPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerName': serializer.toJson<String>(customerName),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'city': serializer.toJson<String?>(city),
      'segment': serializer.toJson<String?>(segment),
      'employer': serializer.toJson<String?>(employer),
      'declineReason': serializer.toJson<String?>(declineReason),
      'product': serializer.toJson<String?>(product),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'assignedDate': serializer.toJson<DateTime>(assignedDate),
      'employeeName': serializer.toJson<String?>(employeeName),
      'employeeCode': serializer.toJson<String?>(employeeCode),
      'leadStatus': serializer.toJson<String>(leadStatus),
      'leadStatusDate': serializer.toJson<DateTime>(leadStatusDate),
      'dataStatus': serializer.toJson<String?>(dataStatus),
      'followupTime': serializer.toJson<DateTime?>(followupTime),
      'arnNo': serializer.toJson<String?>(arnNo),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'remarks': serializer.toJson<String?>(remarks),
      'syncPending': serializer.toJson<bool>(syncPending),
    };
  }

  Lead copyWith({
    String? id,
    String? customerName,
    String? mobileNo,
    Value<String?> city = const Value.absent(),
    Value<String?> segment = const Value.absent(),
    Value<String?> employer = const Value.absent(),
    Value<String?> declineReason = const Value.absent(),
    Value<String?> product = const Value.absent(),
    Value<String?> assignedTo = const Value.absent(),
    DateTime? assignedDate,
    Value<String?> employeeName = const Value.absent(),
    Value<String?> employeeCode = const Value.absent(),
    String? leadStatus,
    DateTime? leadStatusDate,
    Value<String?> dataStatus = const Value.absent(),
    Value<DateTime?> followupTime = const Value.absent(),
    Value<String?> arnNo = const Value.absent(),
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    bool? syncPending,
  }) => Lead(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    mobileNo: mobileNo ?? this.mobileNo,
    city: city.present ? city.value : this.city,
    segment: segment.present ? segment.value : this.segment,
    employer: employer.present ? employer.value : this.employer,
    declineReason: declineReason.present
        ? declineReason.value
        : this.declineReason,
    product: product.present ? product.value : this.product,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    assignedDate: assignedDate ?? this.assignedDate,
    employeeName: employeeName.present ? employeeName.value : this.employeeName,
    employeeCode: employeeCode.present ? employeeCode.value : this.employeeCode,
    leadStatus: leadStatus ?? this.leadStatus,
    leadStatusDate: leadStatusDate ?? this.leadStatusDate,
    dataStatus: dataStatus.present ? dataStatus.value : this.dataStatus,
    followupTime: followupTime.present ? followupTime.value : this.followupTime,
    arnNo: arnNo.present ? arnNo.value : this.arnNo,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    remarks: remarks.present ? remarks.value : this.remarks,
    syncPending: syncPending ?? this.syncPending,
  );
  Lead copyWithCompanion(LeadsCompanion data) {
    return Lead(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      city: data.city.present ? data.city.value : this.city,
      segment: data.segment.present ? data.segment.value : this.segment,
      employer: data.employer.present ? data.employer.value : this.employer,
      declineReason: data.declineReason.present
          ? data.declineReason.value
          : this.declineReason,
      product: data.product.present ? data.product.value : this.product,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      assignedDate: data.assignedDate.present
          ? data.assignedDate.value
          : this.assignedDate,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      leadStatus: data.leadStatus.present
          ? data.leadStatus.value
          : this.leadStatus,
      leadStatusDate: data.leadStatusDate.present
          ? data.leadStatusDate.value
          : this.leadStatusDate,
      dataStatus: data.dataStatus.present
          ? data.dataStatus.value
          : this.dataStatus,
      followupTime: data.followupTime.present
          ? data.followupTime.value
          : this.followupTime,
      arnNo: data.arnNo.present ? data.arnNo.value : this.arnNo,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      syncPending: data.syncPending.present
          ? data.syncPending.value
          : this.syncPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lead(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('city: $city, ')
          ..write('segment: $segment, ')
          ..write('employer: $employer, ')
          ..write('declineReason: $declineReason, ')
          ..write('product: $product, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('assignedDate: $assignedDate, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('leadStatusDate: $leadStatusDate, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('followupTime: $followupTime, ')
          ..write('arnNo: $arnNo, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('remarks: $remarks, ')
          ..write('syncPending: $syncPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerName,
    mobileNo,
    city,
    segment,
    employer,
    declineReason,
    product,
    assignedTo,
    assignedDate,
    employeeName,
    employeeCode,
    leadStatus,
    leadStatusDate,
    dataStatus,
    followupTime,
    arnNo,
    dateOfBirth,
    remarks,
    syncPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lead &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.mobileNo == this.mobileNo &&
          other.city == this.city &&
          other.segment == this.segment &&
          other.employer == this.employer &&
          other.declineReason == this.declineReason &&
          other.product == this.product &&
          other.assignedTo == this.assignedTo &&
          other.assignedDate == this.assignedDate &&
          other.employeeName == this.employeeName &&
          other.employeeCode == this.employeeCode &&
          other.leadStatus == this.leadStatus &&
          other.leadStatusDate == this.leadStatusDate &&
          other.dataStatus == this.dataStatus &&
          other.followupTime == this.followupTime &&
          other.arnNo == this.arnNo &&
          other.dateOfBirth == this.dateOfBirth &&
          other.remarks == this.remarks &&
          other.syncPending == this.syncPending);
}

class LeadsCompanion extends UpdateCompanion<Lead> {
  final Value<String> id;
  final Value<String> customerName;
  final Value<String> mobileNo;
  final Value<String?> city;
  final Value<String?> segment;
  final Value<String?> employer;
  final Value<String?> declineReason;
  final Value<String?> product;
  final Value<String?> assignedTo;
  final Value<DateTime> assignedDate;
  final Value<String?> employeeName;
  final Value<String?> employeeCode;
  final Value<String> leadStatus;
  final Value<DateTime> leadStatusDate;
  final Value<String?> dataStatus;
  final Value<DateTime?> followupTime;
  final Value<String?> arnNo;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> remarks;
  final Value<bool> syncPending;
  final Value<int> rowid;
  const LeadsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.city = const Value.absent(),
    this.segment = const Value.absent(),
    this.employer = const Value.absent(),
    this.declineReason = const Value.absent(),
    this.product = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.assignedDate = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.leadStatus = const Value.absent(),
    this.leadStatusDate = const Value.absent(),
    this.dataStatus = const Value.absent(),
    this.followupTime = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.remarks = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeadsCompanion.insert({
    required String id,
    required String customerName,
    required String mobileNo,
    this.city = const Value.absent(),
    this.segment = const Value.absent(),
    this.employer = const Value.absent(),
    this.declineReason = const Value.absent(),
    this.product = const Value.absent(),
    this.assignedTo = const Value.absent(),
    required DateTime assignedDate,
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    required String leadStatus,
    required DateTime leadStatusDate,
    this.dataStatus = const Value.absent(),
    this.followupTime = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.remarks = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       mobileNo = Value(mobileNo),
       assignedDate = Value(assignedDate),
       leadStatus = Value(leadStatus),
       leadStatusDate = Value(leadStatusDate);
  static Insertable<Lead> custom({
    Expression<String>? id,
    Expression<String>? customerName,
    Expression<String>? mobileNo,
    Expression<String>? city,
    Expression<String>? segment,
    Expression<String>? employer,
    Expression<String>? declineReason,
    Expression<String>? product,
    Expression<String>? assignedTo,
    Expression<DateTime>? assignedDate,
    Expression<String>? employeeName,
    Expression<String>? employeeCode,
    Expression<String>? leadStatus,
    Expression<DateTime>? leadStatusDate,
    Expression<String>? dataStatus,
    Expression<DateTime>? followupTime,
    Expression<String>? arnNo,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? remarks,
    Expression<bool>? syncPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (city != null) 'city': city,
      if (segment != null) 'segment': segment,
      if (employer != null) 'employer': employer,
      if (declineReason != null) 'decline_reason': declineReason,
      if (product != null) 'product': product,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (assignedDate != null) 'assigned_date': assignedDate,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (leadStatus != null) 'lead_status': leadStatus,
      if (leadStatusDate != null) 'lead_status_date': leadStatusDate,
      if (dataStatus != null) 'data_status': dataStatus,
      if (followupTime != null) 'followup_time': followupTime,
      if (arnNo != null) 'arn_no': arnNo,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (remarks != null) 'remarks': remarks,
      if (syncPending != null) 'sync_pending': syncPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeadsCompanion copyWith({
    Value<String>? id,
    Value<String>? customerName,
    Value<String>? mobileNo,
    Value<String?>? city,
    Value<String?>? segment,
    Value<String?>? employer,
    Value<String?>? declineReason,
    Value<String?>? product,
    Value<String?>? assignedTo,
    Value<DateTime>? assignedDate,
    Value<String?>? employeeName,
    Value<String?>? employeeCode,
    Value<String>? leadStatus,
    Value<DateTime>? leadStatusDate,
    Value<String?>? dataStatus,
    Value<DateTime?>? followupTime,
    Value<String?>? arnNo,
    Value<DateTime?>? dateOfBirth,
    Value<String?>? remarks,
    Value<bool>? syncPending,
    Value<int>? rowid,
  }) {
    return LeadsCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      city: city ?? this.city,
      segment: segment ?? this.segment,
      employer: employer ?? this.employer,
      declineReason: declineReason ?? this.declineReason,
      product: product ?? this.product,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedDate: assignedDate ?? this.assignedDate,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      leadStatus: leadStatus ?? this.leadStatus,
      leadStatusDate: leadStatusDate ?? this.leadStatusDate,
      dataStatus: dataStatus ?? this.dataStatus,
      followupTime: followupTime ?? this.followupTime,
      arnNo: arnNo ?? this.arnNo,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      remarks: remarks ?? this.remarks,
      syncPending: syncPending ?? this.syncPending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (segment.present) {
      map['segment'] = Variable<String>(segment.value);
    }
    if (employer.present) {
      map['employer'] = Variable<String>(employer.value);
    }
    if (declineReason.present) {
      map['decline_reason'] = Variable<String>(declineReason.value);
    }
    if (product.present) {
      map['product'] = Variable<String>(product.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (assignedDate.present) {
      map['assigned_date'] = Variable<DateTime>(assignedDate.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (leadStatus.present) {
      map['lead_status'] = Variable<String>(leadStatus.value);
    }
    if (leadStatusDate.present) {
      map['lead_status_date'] = Variable<DateTime>(leadStatusDate.value);
    }
    if (dataStatus.present) {
      map['data_status'] = Variable<String>(dataStatus.value);
    }
    if (followupTime.present) {
      map['followup_time'] = Variable<DateTime>(followupTime.value);
    }
    if (arnNo.present) {
      map['arn_no'] = Variable<String>(arnNo.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (syncPending.present) {
      map['sync_pending'] = Variable<bool>(syncPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeadsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('city: $city, ')
          ..write('segment: $segment, ')
          ..write('employer: $employer, ')
          ..write('declineReason: $declineReason, ')
          ..write('product: $product, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('assignedDate: $assignedDate, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('leadStatusDate: $leadStatusDate, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('followupTime: $followupTime, ')
          ..write('arnNo: $arnNo, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('remarks: $remarks, ')
          ..write('syncPending: $syncPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallLogsTable extends CallLogs with TableInfo<$CallLogsTable, CallLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
    'lead_id',
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
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callTimestampMeta = const VerificationMeta(
    'callTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> callTimestamp =
      GeneratedColumn<DateTime>(
        'call_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _callDurationMeta = const VerificationMeta(
    'callDuration',
  );
  @override
  late final GeneratedColumn<int> callDuration = GeneratedColumn<int>(
    'call_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ringDurationMeta = const VerificationMeta(
    'ringDuration',
  );
  @override
  late final GeneratedColumn<int> ringDuration = GeneratedColumn<int>(
    'ring_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionDurationMeta = const VerificationMeta(
    'sessionDuration',
  );
  @override
  late final GeneratedColumn<int> sessionDuration = GeneratedColumn<int>(
    'session_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _callTypeMeta = const VerificationMeta(
    'callType',
  );
  @override
  late final GeneratedColumn<String> callType = GeneratedColumn<String>(
    'call_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callStatusMeta = const VerificationMeta(
    'callStatus',
  );
  @override
  late final GeneratedColumn<String> callStatus = GeneratedColumn<String>(
    'call_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leadId,
    employeeId,
    employeeCode,
    employeeName,
    phoneNumber,
    callTimestamp,
    callDuration,
    ringDuration,
    sessionDuration,
    callType,
    callStatus,
    isSynced,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(
        _leadIdMeta,
        leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leadIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
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
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('call_timestamp')) {
      context.handle(
        _callTimestampMeta,
        callTimestamp.isAcceptableOrUnknown(
          data['call_timestamp']!,
          _callTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_callTimestampMeta);
    }
    if (data.containsKey('call_duration')) {
      context.handle(
        _callDurationMeta,
        callDuration.isAcceptableOrUnknown(
          data['call_duration']!,
          _callDurationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_callDurationMeta);
    }
    if (data.containsKey('ring_duration')) {
      context.handle(
        _ringDurationMeta,
        ringDuration.isAcceptableOrUnknown(
          data['ring_duration']!,
          _ringDurationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ringDurationMeta);
    }
    if (data.containsKey('session_duration')) {
      context.handle(
        _sessionDurationMeta,
        sessionDuration.isAcceptableOrUnknown(
          data['session_duration']!,
          _sessionDurationMeta,
        ),
      );
    }
    if (data.containsKey('call_type')) {
      context.handle(
        _callTypeMeta,
        callType.isAcceptableOrUnknown(data['call_type']!, _callTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_callTypeMeta);
    }
    if (data.containsKey('call_status')) {
      context.handle(
        _callStatusMeta,
        callStatus.isAcceptableOrUnknown(data['call_status']!, _callStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_callStatusMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      leadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      callTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}call_timestamp'],
      )!,
      callDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_duration'],
      )!,
      ringDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ring_duration'],
      )!,
      sessionDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_duration'],
      )!,
      callType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_type'],
      )!,
      callStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_status'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CallLogsTable createAlias(String alias) {
    return $CallLogsTable(attachedDatabase, alias);
  }
}

class CallLog extends DataClass implements Insertable<CallLog> {
  final String id;
  final String leadId;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String phoneNumber;
  final DateTime callTimestamp;
  final int callDuration;
  final int ringDuration;
  final int sessionDuration;
  final String callType;
  final String callStatus;
  final bool isSynced;
  final DateTime createdAt;
  const CallLog({
    required this.id,
    required this.leadId,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.phoneNumber,
    required this.callTimestamp,
    required this.callDuration,
    required this.ringDuration,
    required this.sessionDuration,
    required this.callType,
    required this.callStatus,
    required this.isSynced,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lead_id'] = Variable<String>(leadId);
    map['employee_id'] = Variable<String>(employeeId);
    map['employee_code'] = Variable<String>(employeeCode);
    map['employee_name'] = Variable<String>(employeeName);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['call_timestamp'] = Variable<DateTime>(callTimestamp);
    map['call_duration'] = Variable<int>(callDuration);
    map['ring_duration'] = Variable<int>(ringDuration);
    map['session_duration'] = Variable<int>(sessionDuration);
    map['call_type'] = Variable<String>(callType);
    map['call_status'] = Variable<String>(callStatus);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CallLogsCompanion toCompanion(bool nullToAbsent) {
    return CallLogsCompanion(
      id: Value(id),
      leadId: Value(leadId),
      employeeId: Value(employeeId),
      employeeCode: Value(employeeCode),
      employeeName: Value(employeeName),
      phoneNumber: Value(phoneNumber),
      callTimestamp: Value(callTimestamp),
      callDuration: Value(callDuration),
      ringDuration: Value(ringDuration),
      sessionDuration: Value(sessionDuration),
      callType: Value(callType),
      callStatus: Value(callStatus),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory CallLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallLog(
      id: serializer.fromJson<String>(json['id']),
      leadId: serializer.fromJson<String>(json['leadId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      callTimestamp: serializer.fromJson<DateTime>(json['callTimestamp']),
      callDuration: serializer.fromJson<int>(json['callDuration']),
      ringDuration: serializer.fromJson<int>(json['ringDuration']),
      sessionDuration: serializer.fromJson<int>(json['sessionDuration']),
      callType: serializer.fromJson<String>(json['callType']),
      callStatus: serializer.fromJson<String>(json['callStatus']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'leadId': serializer.toJson<String>(leadId),
      'employeeId': serializer.toJson<String>(employeeId),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'employeeName': serializer.toJson<String>(employeeName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'callTimestamp': serializer.toJson<DateTime>(callTimestamp),
      'callDuration': serializer.toJson<int>(callDuration),
      'ringDuration': serializer.toJson<int>(ringDuration),
      'sessionDuration': serializer.toJson<int>(sessionDuration),
      'callType': serializer.toJson<String>(callType),
      'callStatus': serializer.toJson<String>(callStatus),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CallLog copyWith({
    String? id,
    String? leadId,
    String? employeeId,
    String? employeeCode,
    String? employeeName,
    String? phoneNumber,
    DateTime? callTimestamp,
    int? callDuration,
    int? ringDuration,
    int? sessionDuration,
    String? callType,
    String? callStatus,
    bool? isSynced,
    DateTime? createdAt,
  }) => CallLog(
    id: id ?? this.id,
    leadId: leadId ?? this.leadId,
    employeeId: employeeId ?? this.employeeId,
    employeeCode: employeeCode ?? this.employeeCode,
    employeeName: employeeName ?? this.employeeName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    callTimestamp: callTimestamp ?? this.callTimestamp,
    callDuration: callDuration ?? this.callDuration,
    ringDuration: ringDuration ?? this.ringDuration,
    sessionDuration: sessionDuration ?? this.sessionDuration,
    callType: callType ?? this.callType,
    callStatus: callStatus ?? this.callStatus,
    isSynced: isSynced ?? this.isSynced,
    createdAt: createdAt ?? this.createdAt,
  );
  CallLog copyWithCompanion(CallLogsCompanion data) {
    return CallLog(
      id: data.id.present ? data.id.value : this.id,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      callTimestamp: data.callTimestamp.present
          ? data.callTimestamp.value
          : this.callTimestamp,
      callDuration: data.callDuration.present
          ? data.callDuration.value
          : this.callDuration,
      ringDuration: data.ringDuration.present
          ? data.ringDuration.value
          : this.ringDuration,
      sessionDuration: data.sessionDuration.present
          ? data.sessionDuration.value
          : this.sessionDuration,
      callType: data.callType.present ? data.callType.value : this.callType,
      callStatus: data.callStatus.present
          ? data.callStatus.value
          : this.callStatus,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallLog(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('employeeName: $employeeName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('callTimestamp: $callTimestamp, ')
          ..write('callDuration: $callDuration, ')
          ..write('ringDuration: $ringDuration, ')
          ..write('sessionDuration: $sessionDuration, ')
          ..write('callType: $callType, ')
          ..write('callStatus: $callStatus, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    leadId,
    employeeId,
    employeeCode,
    employeeName,
    phoneNumber,
    callTimestamp,
    callDuration,
    ringDuration,
    sessionDuration,
    callType,
    callStatus,
    isSynced,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallLog &&
          other.id == this.id &&
          other.leadId == this.leadId &&
          other.employeeId == this.employeeId &&
          other.employeeCode == this.employeeCode &&
          other.employeeName == this.employeeName &&
          other.phoneNumber == this.phoneNumber &&
          other.callTimestamp == this.callTimestamp &&
          other.callDuration == this.callDuration &&
          other.ringDuration == this.ringDuration &&
          other.sessionDuration == this.sessionDuration &&
          other.callType == this.callType &&
          other.callStatus == this.callStatus &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class CallLogsCompanion extends UpdateCompanion<CallLog> {
  final Value<String> id;
  final Value<String> leadId;
  final Value<String> employeeId;
  final Value<String> employeeCode;
  final Value<String> employeeName;
  final Value<String> phoneNumber;
  final Value<DateTime> callTimestamp;
  final Value<int> callDuration;
  final Value<int> ringDuration;
  final Value<int> sessionDuration;
  final Value<String> callType;
  final Value<String> callStatus;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CallLogsCompanion({
    this.id = const Value.absent(),
    this.leadId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.callTimestamp = const Value.absent(),
    this.callDuration = const Value.absent(),
    this.ringDuration = const Value.absent(),
    this.sessionDuration = const Value.absent(),
    this.callType = const Value.absent(),
    this.callStatus = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallLogsCompanion.insert({
    required String id,
    required String leadId,
    required String employeeId,
    required String employeeCode,
    required String employeeName,
    required String phoneNumber,
    required DateTime callTimestamp,
    required int callDuration,
    required int ringDuration,
    this.sessionDuration = const Value.absent(),
    required String callType,
    required String callStatus,
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       leadId = Value(leadId),
       employeeId = Value(employeeId),
       employeeCode = Value(employeeCode),
       employeeName = Value(employeeName),
       phoneNumber = Value(phoneNumber),
       callTimestamp = Value(callTimestamp),
       callDuration = Value(callDuration),
       ringDuration = Value(ringDuration),
       callType = Value(callType),
       callStatus = Value(callStatus);
  static Insertable<CallLog> custom({
    Expression<String>? id,
    Expression<String>? leadId,
    Expression<String>? employeeId,
    Expression<String>? employeeCode,
    Expression<String>? employeeName,
    Expression<String>? phoneNumber,
    Expression<DateTime>? callTimestamp,
    Expression<int>? callDuration,
    Expression<int>? ringDuration,
    Expression<int>? sessionDuration,
    Expression<String>? callType,
    Expression<String>? callStatus,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leadId != null) 'lead_id': leadId,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (employeeName != null) 'employee_name': employeeName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (callTimestamp != null) 'call_timestamp': callTimestamp,
      if (callDuration != null) 'call_duration': callDuration,
      if (ringDuration != null) 'ring_duration': ringDuration,
      if (sessionDuration != null) 'session_duration': sessionDuration,
      if (callType != null) 'call_type': callType,
      if (callStatus != null) 'call_status': callStatus,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? leadId,
    Value<String>? employeeId,
    Value<String>? employeeCode,
    Value<String>? employeeName,
    Value<String>? phoneNumber,
    Value<DateTime>? callTimestamp,
    Value<int>? callDuration,
    Value<int>? ringDuration,
    Value<int>? sessionDuration,
    Value<String>? callType,
    Value<String>? callStatus,
    Value<bool>? isSynced,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CallLogsCompanion(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      callTimestamp: callTimestamp ?? this.callTimestamp,
      callDuration: callDuration ?? this.callDuration,
      ringDuration: ringDuration ?? this.ringDuration,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      isSynced: isSynced ?? this.isSynced,
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
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (callTimestamp.present) {
      map['call_timestamp'] = Variable<DateTime>(callTimestamp.value);
    }
    if (callDuration.present) {
      map['call_duration'] = Variable<int>(callDuration.value);
    }
    if (ringDuration.present) {
      map['ring_duration'] = Variable<int>(ringDuration.value);
    }
    if (sessionDuration.present) {
      map['session_duration'] = Variable<int>(sessionDuration.value);
    }
    if (callType.present) {
      map['call_type'] = Variable<String>(callType.value);
    }
    if (callStatus.present) {
      map['call_status'] = Variable<String>(callStatus.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
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
    return (StringBuffer('CallLogsCompanion(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('employeeName: $employeeName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('callTimestamp: $callTimestamp, ')
          ..write('callDuration: $callDuration, ')
          ..write('ringDuration: $ringDuration, ')
          ..write('sessionDuration: $sessionDuration, ')
          ..write('callType: $callType, ')
          ..write('callStatus: $callStatus, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoginCasesTable extends LoginCases
    with TableInfo<$LoginCasesTable, LoginCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoginCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadStatusMeta = const VerificationMeta(
    'leadStatus',
  );
  @override
  late final GeneratedColumn<String> leadStatus = GeneratedColumn<String>(
    'lead_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
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
  static const VerificationMeta _leadStatusDateMeta = const VerificationMeta(
    'leadStatusDate',
  );
  @override
  late final GeneratedColumn<DateTime> leadStatusDate =
      GeneratedColumn<DateTime>(
        'lead_status_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _arnDateMeta = const VerificationMeta(
    'arnDate',
  );
  @override
  late final GeneratedColumn<DateTime> arnDate = GeneratedColumn<DateTime>(
    'arn_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arnNoMeta = const VerificationMeta('arnNo');
  @override
  late final GeneratedColumn<String> arnNo = GeneratedColumn<String>(
    'arn_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
    'lead_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    mobileNumber,
    leadStatus,
    employeeName,
    employeeCode,
    leadStatusDate,
    arnDate,
    arnNo,
    leadId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'login_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoginCase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobileNumberMeta);
    }
    if (data.containsKey('lead_status')) {
      context.handle(
        _leadStatusMeta,
        leadStatus.isAcceptableOrUnknown(data['lead_status']!, _leadStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_leadStatusMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
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
    if (data.containsKey('lead_status_date')) {
      context.handle(
        _leadStatusDateMeta,
        leadStatusDate.isAcceptableOrUnknown(
          data['lead_status_date']!,
          _leadStatusDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_leadStatusDateMeta);
    }
    if (data.containsKey('arn_date')) {
      context.handle(
        _arnDateMeta,
        arnDate.isAcceptableOrUnknown(data['arn_date']!, _arnDateMeta),
      );
    }
    if (data.containsKey('arn_no')) {
      context.handle(
        _arnNoMeta,
        arnNo.isAcceptableOrUnknown(data['arn_no']!, _arnNoMeta),
      );
    }
    if (data.containsKey('lead_id')) {
      context.handle(
        _leadIdMeta,
        leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoginCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoginCase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      )!,
      leadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_status'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      leadStatusDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lead_status_date'],
      )!,
      arnDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arn_date'],
      ),
      arnNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arn_no'],
      ),
      leadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_id'],
      ),
    );
  }

  @override
  $LoginCasesTable createAlias(String alias) {
    return $LoginCasesTable(attachedDatabase, alias);
  }
}

class LoginCase extends DataClass implements Insertable<LoginCase> {
  final String id;
  final String customerName;
  final String mobileNumber;
  final String leadStatus;
  final String employeeName;
  final String employeeCode;
  final DateTime leadStatusDate;
  final DateTime? arnDate;
  final String? arnNo;
  final String? leadId;
  const LoginCase({
    required this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.leadStatus,
    required this.employeeName,
    required this.employeeCode,
    required this.leadStatusDate,
    this.arnDate,
    this.arnNo,
    this.leadId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['mobile_number'] = Variable<String>(mobileNumber);
    map['lead_status'] = Variable<String>(leadStatus);
    map['employee_name'] = Variable<String>(employeeName);
    map['employee_code'] = Variable<String>(employeeCode);
    map['lead_status_date'] = Variable<DateTime>(leadStatusDate);
    if (!nullToAbsent || arnDate != null) {
      map['arn_date'] = Variable<DateTime>(arnDate);
    }
    if (!nullToAbsent || arnNo != null) {
      map['arn_no'] = Variable<String>(arnNo);
    }
    if (!nullToAbsent || leadId != null) {
      map['lead_id'] = Variable<String>(leadId);
    }
    return map;
  }

  LoginCasesCompanion toCompanion(bool nullToAbsent) {
    return LoginCasesCompanion(
      id: Value(id),
      customerName: Value(customerName),
      mobileNumber: Value(mobileNumber),
      leadStatus: Value(leadStatus),
      employeeName: Value(employeeName),
      employeeCode: Value(employeeCode),
      leadStatusDate: Value(leadStatusDate),
      arnDate: arnDate == null && nullToAbsent
          ? const Value.absent()
          : Value(arnDate),
      arnNo: arnNo == null && nullToAbsent
          ? const Value.absent()
          : Value(arnNo),
      leadId: leadId == null && nullToAbsent
          ? const Value.absent()
          : Value(leadId),
    );
  }

  factory LoginCase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoginCase(
      id: serializer.fromJson<String>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      mobileNumber: serializer.fromJson<String>(json['mobileNumber']),
      leadStatus: serializer.fromJson<String>(json['leadStatus']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      leadStatusDate: serializer.fromJson<DateTime>(json['leadStatusDate']),
      arnDate: serializer.fromJson<DateTime?>(json['arnDate']),
      arnNo: serializer.fromJson<String?>(json['arnNo']),
      leadId: serializer.fromJson<String?>(json['leadId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerName': serializer.toJson<String>(customerName),
      'mobileNumber': serializer.toJson<String>(mobileNumber),
      'leadStatus': serializer.toJson<String>(leadStatus),
      'employeeName': serializer.toJson<String>(employeeName),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'leadStatusDate': serializer.toJson<DateTime>(leadStatusDate),
      'arnDate': serializer.toJson<DateTime?>(arnDate),
      'arnNo': serializer.toJson<String?>(arnNo),
      'leadId': serializer.toJson<String?>(leadId),
    };
  }

  LoginCase copyWith({
    String? id,
    String? customerName,
    String? mobileNumber,
    String? leadStatus,
    String? employeeName,
    String? employeeCode,
    DateTime? leadStatusDate,
    Value<DateTime?> arnDate = const Value.absent(),
    Value<String?> arnNo = const Value.absent(),
    Value<String?> leadId = const Value.absent(),
  }) => LoginCase(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    leadStatus: leadStatus ?? this.leadStatus,
    employeeName: employeeName ?? this.employeeName,
    employeeCode: employeeCode ?? this.employeeCode,
    leadStatusDate: leadStatusDate ?? this.leadStatusDate,
    arnDate: arnDate.present ? arnDate.value : this.arnDate,
    arnNo: arnNo.present ? arnNo.value : this.arnNo,
    leadId: leadId.present ? leadId.value : this.leadId,
  );
  LoginCase copyWithCompanion(LoginCasesCompanion data) {
    return LoginCase(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      leadStatus: data.leadStatus.present
          ? data.leadStatus.value
          : this.leadStatus,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      leadStatusDate: data.leadStatusDate.present
          ? data.leadStatusDate.value
          : this.leadStatusDate,
      arnDate: data.arnDate.present ? data.arnDate.value : this.arnDate,
      arnNo: data.arnNo.present ? data.arnNo.value : this.arnNo,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoginCase(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('leadStatusDate: $leadStatusDate, ')
          ..write('arnDate: $arnDate, ')
          ..write('arnNo: $arnNo, ')
          ..write('leadId: $leadId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerName,
    mobileNumber,
    leadStatus,
    employeeName,
    employeeCode,
    leadStatusDate,
    arnDate,
    arnNo,
    leadId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoginCase &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.mobileNumber == this.mobileNumber &&
          other.leadStatus == this.leadStatus &&
          other.employeeName == this.employeeName &&
          other.employeeCode == this.employeeCode &&
          other.leadStatusDate == this.leadStatusDate &&
          other.arnDate == this.arnDate &&
          other.arnNo == this.arnNo &&
          other.leadId == this.leadId);
}

class LoginCasesCompanion extends UpdateCompanion<LoginCase> {
  final Value<String> id;
  final Value<String> customerName;
  final Value<String> mobileNumber;
  final Value<String> leadStatus;
  final Value<String> employeeName;
  final Value<String> employeeCode;
  final Value<DateTime> leadStatusDate;
  final Value<DateTime?> arnDate;
  final Value<String?> arnNo;
  final Value<String?> leadId;
  final Value<int> rowid;
  const LoginCasesCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.leadStatus = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.leadStatusDate = const Value.absent(),
    this.arnDate = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.leadId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoginCasesCompanion.insert({
    required String id,
    required String customerName,
    required String mobileNumber,
    required String leadStatus,
    required String employeeName,
    required String employeeCode,
    required DateTime leadStatusDate,
    this.arnDate = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.leadId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       mobileNumber = Value(mobileNumber),
       leadStatus = Value(leadStatus),
       employeeName = Value(employeeName),
       employeeCode = Value(employeeCode),
       leadStatusDate = Value(leadStatusDate);
  static Insertable<LoginCase> custom({
    Expression<String>? id,
    Expression<String>? customerName,
    Expression<String>? mobileNumber,
    Expression<String>? leadStatus,
    Expression<String>? employeeName,
    Expression<String>? employeeCode,
    Expression<DateTime>? leadStatusDate,
    Expression<DateTime>? arnDate,
    Expression<String>? arnNo,
    Expression<String>? leadId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (leadStatus != null) 'lead_status': leadStatus,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (leadStatusDate != null) 'lead_status_date': leadStatusDate,
      if (arnDate != null) 'arn_date': arnDate,
      if (arnNo != null) 'arn_no': arnNo,
      if (leadId != null) 'lead_id': leadId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoginCasesCompanion copyWith({
    Value<String>? id,
    Value<String>? customerName,
    Value<String>? mobileNumber,
    Value<String>? leadStatus,
    Value<String>? employeeName,
    Value<String>? employeeCode,
    Value<DateTime>? leadStatusDate,
    Value<DateTime?>? arnDate,
    Value<String?>? arnNo,
    Value<String?>? leadId,
    Value<int>? rowid,
  }) {
    return LoginCasesCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      leadStatus: leadStatus ?? this.leadStatus,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      leadStatusDate: leadStatusDate ?? this.leadStatusDate,
      arnDate: arnDate ?? this.arnDate,
      arnNo: arnNo ?? this.arnNo,
      leadId: leadId ?? this.leadId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (leadStatus.present) {
      map['lead_status'] = Variable<String>(leadStatus.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (leadStatusDate.present) {
      map['lead_status_date'] = Variable<DateTime>(leadStatusDate.value);
    }
    if (arnDate.present) {
      map['arn_date'] = Variable<DateTime>(arnDate.value);
    }
    if (arnNo.present) {
      map['arn_no'] = Variable<String>(arnNo.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoginCasesCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('leadStatusDate: $leadStatusDate, ')
          ..write('arnDate: $arnDate, ')
          ..write('arnNo: $arnNo, ')
          ..write('leadId: $leadId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceDateMeta = const VerificationMeta(
    'attendanceDate',
  );
  @override
  late final GeneratedColumn<DateTime> attendanceDate =
      GeneratedColumn<DateTime>(
        'attendance_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _checkInTimeMeta = const VerificationMeta(
    'checkInTime',
  );
  @override
  late final GeneratedColumn<DateTime> checkInTime = GeneratedColumn<DateTime>(
    'check_in_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInSelfieMeta = const VerificationMeta(
    'checkInSelfie',
  );
  @override
  late final GeneratedColumn<String> checkInSelfie = GeneratedColumn<String>(
    'check_in_selfie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInLatitudeMeta = const VerificationMeta(
    'checkInLatitude',
  );
  @override
  late final GeneratedColumn<double> checkInLatitude = GeneratedColumn<double>(
    'check_in_latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInLongitudeMeta = const VerificationMeta(
    'checkInLongitude',
  );
  @override
  late final GeneratedColumn<double> checkInLongitude = GeneratedColumn<double>(
    'check_in_longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkOutTimeMeta = const VerificationMeta(
    'checkOutTime',
  );
  @override
  late final GeneratedColumn<DateTime> checkOutTime = GeneratedColumn<DateTime>(
    'check_out_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkOutSelfieMeta = const VerificationMeta(
    'checkOutSelfie',
  );
  @override
  late final GeneratedColumn<String> checkOutSelfie = GeneratedColumn<String>(
    'check_out_selfie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkOutLatitudeMeta = const VerificationMeta(
    'checkOutLatitude',
  );
  @override
  late final GeneratedColumn<double> checkOutLatitude = GeneratedColumn<double>(
    'check_out_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkOutLongitudeMeta = const VerificationMeta(
    'checkOutLongitude',
  );
  @override
  late final GeneratedColumn<double> checkOutLongitude =
      GeneratedColumn<double>(
        'check_out_longitude',
        aliasedName,
        true,
        type: DriftSqlType.double,
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
  static const VerificationMeta _syncPendingMeta = const VerificationMeta(
    'syncPending',
  );
  @override
  late final GeneratedColumn<bool> syncPending = GeneratedColumn<bool>(
    'sync_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _approvalTypeMeta = const VerificationMeta(
    'approvalType',
  );
  @override
  late final GeneratedColumn<String> approvalType = GeneratedColumn<String>(
    'approval_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeId,
    employeeCode,
    employeeName,
    attendanceDate,
    checkInTime,
    checkInSelfie,
    checkInLatitude,
    checkInLongitude,
    checkOutTime,
    checkOutSelfie,
    checkOutLatitude,
    checkOutLongitude,
    address,
    syncPending,
    status,
    remarks,
    approvalType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
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
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
    }
    if (data.containsKey('attendance_date')) {
      context.handle(
        _attendanceDateMeta,
        attendanceDate.isAcceptableOrUnknown(
          data['attendance_date']!,
          _attendanceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceDateMeta);
    }
    if (data.containsKey('check_in_time')) {
      context.handle(
        _checkInTimeMeta,
        checkInTime.isAcceptableOrUnknown(
          data['check_in_time']!,
          _checkInTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInTimeMeta);
    }
    if (data.containsKey('check_in_selfie')) {
      context.handle(
        _checkInSelfieMeta,
        checkInSelfie.isAcceptableOrUnknown(
          data['check_in_selfie']!,
          _checkInSelfieMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInSelfieMeta);
    }
    if (data.containsKey('check_in_latitude')) {
      context.handle(
        _checkInLatitudeMeta,
        checkInLatitude.isAcceptableOrUnknown(
          data['check_in_latitude']!,
          _checkInLatitudeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInLatitudeMeta);
    }
    if (data.containsKey('check_in_longitude')) {
      context.handle(
        _checkInLongitudeMeta,
        checkInLongitude.isAcceptableOrUnknown(
          data['check_in_longitude']!,
          _checkInLongitudeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInLongitudeMeta);
    }
    if (data.containsKey('check_out_time')) {
      context.handle(
        _checkOutTimeMeta,
        checkOutTime.isAcceptableOrUnknown(
          data['check_out_time']!,
          _checkOutTimeMeta,
        ),
      );
    }
    if (data.containsKey('check_out_selfie')) {
      context.handle(
        _checkOutSelfieMeta,
        checkOutSelfie.isAcceptableOrUnknown(
          data['check_out_selfie']!,
          _checkOutSelfieMeta,
        ),
      );
    }
    if (data.containsKey('check_out_latitude')) {
      context.handle(
        _checkOutLatitudeMeta,
        checkOutLatitude.isAcceptableOrUnknown(
          data['check_out_latitude']!,
          _checkOutLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('check_out_longitude')) {
      context.handle(
        _checkOutLongitudeMeta,
        checkOutLongitude.isAcceptableOrUnknown(
          data['check_out_longitude']!,
          _checkOutLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('sync_pending')) {
      context.handle(
        _syncPendingMeta,
        syncPending.isAcceptableOrUnknown(
          data['sync_pending']!,
          _syncPendingMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('approval_type')) {
      context.handle(
        _approvalTypeMeta,
        approvalType.isAcceptableOrUnknown(
          data['approval_type']!,
          _approvalTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      attendanceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attendance_date'],
      )!,
      checkInTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_time'],
      )!,
      checkInSelfie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_in_selfie'],
      )!,
      checkInLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}check_in_latitude'],
      )!,
      checkInLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}check_in_longitude'],
      )!,
      checkOutTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_out_time'],
      ),
      checkOutSelfie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_out_selfie'],
      ),
      checkOutLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}check_out_latitude'],
      ),
      checkOutLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}check_out_longitude'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      syncPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_pending'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      approvalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approval_type'],
      ),
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final DateTime attendanceDate;
  final DateTime checkInTime;
  final String checkInSelfie;
  final double checkInLatitude;
  final double checkInLongitude;
  final DateTime? checkOutTime;
  final String? checkOutSelfie;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? address;
  final bool syncPending;
  final String? status;
  final String? remarks;
  final String? approvalType;
  const AttendanceData({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkInSelfie,
    required this.checkInLatitude,
    required this.checkInLongitude,
    this.checkOutTime,
    this.checkOutSelfie,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.address,
    required this.syncPending,
    this.status,
    this.remarks,
    this.approvalType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['employee_id'] = Variable<String>(employeeId);
    map['employee_code'] = Variable<String>(employeeCode);
    map['employee_name'] = Variable<String>(employeeName);
    map['attendance_date'] = Variable<DateTime>(attendanceDate);
    map['check_in_time'] = Variable<DateTime>(checkInTime);
    map['check_in_selfie'] = Variable<String>(checkInSelfie);
    map['check_in_latitude'] = Variable<double>(checkInLatitude);
    map['check_in_longitude'] = Variable<double>(checkInLongitude);
    if (!nullToAbsent || checkOutTime != null) {
      map['check_out_time'] = Variable<DateTime>(checkOutTime);
    }
    if (!nullToAbsent || checkOutSelfie != null) {
      map['check_out_selfie'] = Variable<String>(checkOutSelfie);
    }
    if (!nullToAbsent || checkOutLatitude != null) {
      map['check_out_latitude'] = Variable<double>(checkOutLatitude);
    }
    if (!nullToAbsent || checkOutLongitude != null) {
      map['check_out_longitude'] = Variable<double>(checkOutLongitude);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['sync_pending'] = Variable<bool>(syncPending);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || approvalType != null) {
      map['approval_type'] = Variable<String>(approvalType);
    }
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      employeeId: Value(employeeId),
      employeeCode: Value(employeeCode),
      employeeName: Value(employeeName),
      attendanceDate: Value(attendanceDate),
      checkInTime: Value(checkInTime),
      checkInSelfie: Value(checkInSelfie),
      checkInLatitude: Value(checkInLatitude),
      checkInLongitude: Value(checkInLongitude),
      checkOutTime: checkOutTime == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutTime),
      checkOutSelfie: checkOutSelfie == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutSelfie),
      checkOutLatitude: checkOutLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutLatitude),
      checkOutLongitude: checkOutLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutLongitude),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      syncPending: Value(syncPending),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      approvalType: approvalType == null && nullToAbsent
          ? const Value.absent()
          : Value(approvalType),
    );
  }

  factory AttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<String>(json['id']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      attendanceDate: serializer.fromJson<DateTime>(json['attendanceDate']),
      checkInTime: serializer.fromJson<DateTime>(json['checkInTime']),
      checkInSelfie: serializer.fromJson<String>(json['checkInSelfie']),
      checkInLatitude: serializer.fromJson<double>(json['checkInLatitude']),
      checkInLongitude: serializer.fromJson<double>(json['checkInLongitude']),
      checkOutTime: serializer.fromJson<DateTime?>(json['checkOutTime']),
      checkOutSelfie: serializer.fromJson<String?>(json['checkOutSelfie']),
      checkOutLatitude: serializer.fromJson<double?>(json['checkOutLatitude']),
      checkOutLongitude: serializer.fromJson<double?>(
        json['checkOutLongitude'],
      ),
      address: serializer.fromJson<String?>(json['address']),
      syncPending: serializer.fromJson<bool>(json['syncPending']),
      status: serializer.fromJson<String?>(json['status']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      approvalType: serializer.fromJson<String?>(json['approvalType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeId': serializer.toJson<String>(employeeId),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'employeeName': serializer.toJson<String>(employeeName),
      'attendanceDate': serializer.toJson<DateTime>(attendanceDate),
      'checkInTime': serializer.toJson<DateTime>(checkInTime),
      'checkInSelfie': serializer.toJson<String>(checkInSelfie),
      'checkInLatitude': serializer.toJson<double>(checkInLatitude),
      'checkInLongitude': serializer.toJson<double>(checkInLongitude),
      'checkOutTime': serializer.toJson<DateTime?>(checkOutTime),
      'checkOutSelfie': serializer.toJson<String?>(checkOutSelfie),
      'checkOutLatitude': serializer.toJson<double?>(checkOutLatitude),
      'checkOutLongitude': serializer.toJson<double?>(checkOutLongitude),
      'address': serializer.toJson<String?>(address),
      'syncPending': serializer.toJson<bool>(syncPending),
      'status': serializer.toJson<String?>(status),
      'remarks': serializer.toJson<String?>(remarks),
      'approvalType': serializer.toJson<String?>(approvalType),
    };
  }

  AttendanceData copyWith({
    String? id,
    String? employeeId,
    String? employeeCode,
    String? employeeName,
    DateTime? attendanceDate,
    DateTime? checkInTime,
    String? checkInSelfie,
    double? checkInLatitude,
    double? checkInLongitude,
    Value<DateTime?> checkOutTime = const Value.absent(),
    Value<String?> checkOutSelfie = const Value.absent(),
    Value<double?> checkOutLatitude = const Value.absent(),
    Value<double?> checkOutLongitude = const Value.absent(),
    Value<String?> address = const Value.absent(),
    bool? syncPending,
    Value<String?> status = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> approvalType = const Value.absent(),
  }) => AttendanceData(
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    employeeCode: employeeCode ?? this.employeeCode,
    employeeName: employeeName ?? this.employeeName,
    attendanceDate: attendanceDate ?? this.attendanceDate,
    checkInTime: checkInTime ?? this.checkInTime,
    checkInSelfie: checkInSelfie ?? this.checkInSelfie,
    checkInLatitude: checkInLatitude ?? this.checkInLatitude,
    checkInLongitude: checkInLongitude ?? this.checkInLongitude,
    checkOutTime: checkOutTime.present ? checkOutTime.value : this.checkOutTime,
    checkOutSelfie: checkOutSelfie.present
        ? checkOutSelfie.value
        : this.checkOutSelfie,
    checkOutLatitude: checkOutLatitude.present
        ? checkOutLatitude.value
        : this.checkOutLatitude,
    checkOutLongitude: checkOutLongitude.present
        ? checkOutLongitude.value
        : this.checkOutLongitude,
    address: address.present ? address.value : this.address,
    syncPending: syncPending ?? this.syncPending,
    status: status.present ? status.value : this.status,
    remarks: remarks.present ? remarks.value : this.remarks,
    approvalType: approvalType.present ? approvalType.value : this.approvalType,
  );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      attendanceDate: data.attendanceDate.present
          ? data.attendanceDate.value
          : this.attendanceDate,
      checkInTime: data.checkInTime.present
          ? data.checkInTime.value
          : this.checkInTime,
      checkInSelfie: data.checkInSelfie.present
          ? data.checkInSelfie.value
          : this.checkInSelfie,
      checkInLatitude: data.checkInLatitude.present
          ? data.checkInLatitude.value
          : this.checkInLatitude,
      checkInLongitude: data.checkInLongitude.present
          ? data.checkInLongitude.value
          : this.checkInLongitude,
      checkOutTime: data.checkOutTime.present
          ? data.checkOutTime.value
          : this.checkOutTime,
      checkOutSelfie: data.checkOutSelfie.present
          ? data.checkOutSelfie.value
          : this.checkOutSelfie,
      checkOutLatitude: data.checkOutLatitude.present
          ? data.checkOutLatitude.value
          : this.checkOutLatitude,
      checkOutLongitude: data.checkOutLongitude.present
          ? data.checkOutLongitude.value
          : this.checkOutLongitude,
      address: data.address.present ? data.address.value : this.address,
      syncPending: data.syncPending.present
          ? data.syncPending.value
          : this.syncPending,
      status: data.status.present ? data.status.value : this.status,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      approvalType: data.approvalType.present
          ? data.approvalType.value
          : this.approvalType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('employeeName: $employeeName, ')
          ..write('attendanceDate: $attendanceDate, ')
          ..write('checkInTime: $checkInTime, ')
          ..write('checkInSelfie: $checkInSelfie, ')
          ..write('checkInLatitude: $checkInLatitude, ')
          ..write('checkInLongitude: $checkInLongitude, ')
          ..write('checkOutTime: $checkOutTime, ')
          ..write('checkOutSelfie: $checkOutSelfie, ')
          ..write('checkOutLatitude: $checkOutLatitude, ')
          ..write('checkOutLongitude: $checkOutLongitude, ')
          ..write('address: $address, ')
          ..write('syncPending: $syncPending, ')
          ..write('status: $status, ')
          ..write('remarks: $remarks, ')
          ..write('approvalType: $approvalType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeId,
    employeeCode,
    employeeName,
    attendanceDate,
    checkInTime,
    checkInSelfie,
    checkInLatitude,
    checkInLongitude,
    checkOutTime,
    checkOutSelfie,
    checkOutLatitude,
    checkOutLongitude,
    address,
    syncPending,
    status,
    remarks,
    approvalType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.employeeCode == this.employeeCode &&
          other.employeeName == this.employeeName &&
          other.attendanceDate == this.attendanceDate &&
          other.checkInTime == this.checkInTime &&
          other.checkInSelfie == this.checkInSelfie &&
          other.checkInLatitude == this.checkInLatitude &&
          other.checkInLongitude == this.checkInLongitude &&
          other.checkOutTime == this.checkOutTime &&
          other.checkOutSelfie == this.checkOutSelfie &&
          other.checkOutLatitude == this.checkOutLatitude &&
          other.checkOutLongitude == this.checkOutLongitude &&
          other.address == this.address &&
          other.syncPending == this.syncPending &&
          other.status == this.status &&
          other.remarks == this.remarks &&
          other.approvalType == this.approvalType);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<String> id;
  final Value<String> employeeId;
  final Value<String> employeeCode;
  final Value<String> employeeName;
  final Value<DateTime> attendanceDate;
  final Value<DateTime> checkInTime;
  final Value<String> checkInSelfie;
  final Value<double> checkInLatitude;
  final Value<double> checkInLongitude;
  final Value<DateTime?> checkOutTime;
  final Value<String?> checkOutSelfie;
  final Value<double?> checkOutLatitude;
  final Value<double?> checkOutLongitude;
  final Value<String?> address;
  final Value<bool> syncPending;
  final Value<String?> status;
  final Value<String?> remarks;
  final Value<String?> approvalType;
  final Value<int> rowid;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.attendanceDate = const Value.absent(),
    this.checkInTime = const Value.absent(),
    this.checkInSelfie = const Value.absent(),
    this.checkInLatitude = const Value.absent(),
    this.checkInLongitude = const Value.absent(),
    this.checkOutTime = const Value.absent(),
    this.checkOutSelfie = const Value.absent(),
    this.checkOutLatitude = const Value.absent(),
    this.checkOutLongitude = const Value.absent(),
    this.address = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.status = const Value.absent(),
    this.remarks = const Value.absent(),
    this.approvalType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceCompanion.insert({
    required String id,
    required String employeeId,
    required String employeeCode,
    required String employeeName,
    required DateTime attendanceDate,
    required DateTime checkInTime,
    required String checkInSelfie,
    required double checkInLatitude,
    required double checkInLongitude,
    this.checkOutTime = const Value.absent(),
    this.checkOutSelfie = const Value.absent(),
    this.checkOutLatitude = const Value.absent(),
    this.checkOutLongitude = const Value.absent(),
    this.address = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.status = const Value.absent(),
    this.remarks = const Value.absent(),
    this.approvalType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeId = Value(employeeId),
       employeeCode = Value(employeeCode),
       employeeName = Value(employeeName),
       attendanceDate = Value(attendanceDate),
       checkInTime = Value(checkInTime),
       checkInSelfie = Value(checkInSelfie),
       checkInLatitude = Value(checkInLatitude),
       checkInLongitude = Value(checkInLongitude);
  static Insertable<AttendanceData> custom({
    Expression<String>? id,
    Expression<String>? employeeId,
    Expression<String>? employeeCode,
    Expression<String>? employeeName,
    Expression<DateTime>? attendanceDate,
    Expression<DateTime>? checkInTime,
    Expression<String>? checkInSelfie,
    Expression<double>? checkInLatitude,
    Expression<double>? checkInLongitude,
    Expression<DateTime>? checkOutTime,
    Expression<String>? checkOutSelfie,
    Expression<double>? checkOutLatitude,
    Expression<double>? checkOutLongitude,
    Expression<String>? address,
    Expression<bool>? syncPending,
    Expression<String>? status,
    Expression<String>? remarks,
    Expression<String>? approvalType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (employeeName != null) 'employee_name': employeeName,
      if (attendanceDate != null) 'attendance_date': attendanceDate,
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkInSelfie != null) 'check_in_selfie': checkInSelfie,
      if (checkInLatitude != null) 'check_in_latitude': checkInLatitude,
      if (checkInLongitude != null) 'check_in_longitude': checkInLongitude,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      if (checkOutSelfie != null) 'check_out_selfie': checkOutSelfie,
      if (checkOutLatitude != null) 'check_out_latitude': checkOutLatitude,
      if (checkOutLongitude != null) 'check_out_longitude': checkOutLongitude,
      if (address != null) 'address': address,
      if (syncPending != null) 'sync_pending': syncPending,
      if (status != null) 'status': status,
      if (remarks != null) 'remarks': remarks,
      if (approvalType != null) 'approval_type': approvalType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceCompanion copyWith({
    Value<String>? id,
    Value<String>? employeeId,
    Value<String>? employeeCode,
    Value<String>? employeeName,
    Value<DateTime>? attendanceDate,
    Value<DateTime>? checkInTime,
    Value<String>? checkInSelfie,
    Value<double>? checkInLatitude,
    Value<double>? checkInLongitude,
    Value<DateTime?>? checkOutTime,
    Value<String?>? checkOutSelfie,
    Value<double?>? checkOutLatitude,
    Value<double?>? checkOutLongitude,
    Value<String?>? address,
    Value<bool>? syncPending,
    Value<String?>? status,
    Value<String?>? remarks,
    Value<String?>? approvalType,
    Value<int>? rowid,
  }) {
    return AttendanceCompanion(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkInSelfie: checkInSelfie ?? this.checkInSelfie,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkOutSelfie: checkOutSelfie ?? this.checkOutSelfie,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      address: address ?? this.address,
      syncPending: syncPending ?? this.syncPending,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      approvalType: approvalType ?? this.approvalType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (attendanceDate.present) {
      map['attendance_date'] = Variable<DateTime>(attendanceDate.value);
    }
    if (checkInTime.present) {
      map['check_in_time'] = Variable<DateTime>(checkInTime.value);
    }
    if (checkInSelfie.present) {
      map['check_in_selfie'] = Variable<String>(checkInSelfie.value);
    }
    if (checkInLatitude.present) {
      map['check_in_latitude'] = Variable<double>(checkInLatitude.value);
    }
    if (checkInLongitude.present) {
      map['check_in_longitude'] = Variable<double>(checkInLongitude.value);
    }
    if (checkOutTime.present) {
      map['check_out_time'] = Variable<DateTime>(checkOutTime.value);
    }
    if (checkOutSelfie.present) {
      map['check_out_selfie'] = Variable<String>(checkOutSelfie.value);
    }
    if (checkOutLatitude.present) {
      map['check_out_latitude'] = Variable<double>(checkOutLatitude.value);
    }
    if (checkOutLongitude.present) {
      map['check_out_longitude'] = Variable<double>(checkOutLongitude.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (syncPending.present) {
      map['sync_pending'] = Variable<bool>(syncPending.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (approvalType.present) {
      map['approval_type'] = Variable<String>(approvalType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('employeeName: $employeeName, ')
          ..write('attendanceDate: $attendanceDate, ')
          ..write('checkInTime: $checkInTime, ')
          ..write('checkInSelfie: $checkInSelfie, ')
          ..write('checkInLatitude: $checkInLatitude, ')
          ..write('checkInLongitude: $checkInLongitude, ')
          ..write('checkOutTime: $checkOutTime, ')
          ..write('checkOutSelfie: $checkOutSelfie, ')
          ..write('checkOutLatitude: $checkOutLatitude, ')
          ..write('checkOutLongitude: $checkOutLongitude, ')
          ..write('address: $address, ')
          ..write('syncPending: $syncPending, ')
          ..write('status: $status, ')
          ..write('remarks: $remarks, ')
          ..write('approvalType: $approvalType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaveRequestsTable extends LeaveRequests
    with TableInfo<$LeaveRequestsTable, LeaveRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaveRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leaveTypeMeta = const VerificationMeta(
    'leaveType',
  );
  @override
  late final GeneratedColumn<String> leaveType = GeneratedColumn<String>(
    'leave_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromDateMeta = const VerificationMeta(
    'fromDate',
  );
  @override
  late final GeneratedColumn<DateTime> fromDate = GeneratedColumn<DateTime>(
    'from_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toDateMeta = const VerificationMeta('toDate');
  @override
  late final GeneratedColumn<DateTime> toDate = GeneratedColumn<DateTime>(
    'to_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysCountMeta = const VerificationMeta(
    'daysCount',
  );
  @override
  late final GeneratedColumn<int> daysCount = GeneratedColumn<int>(
    'days_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedDateMeta = const VerificationMeta(
    'appliedDate',
  );
  @override
  late final GeneratedColumn<DateTime> appliedDate = GeneratedColumn<DateTime>(
    'applied_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncPendingMeta = const VerificationMeta(
    'syncPending',
  );
  @override
  late final GeneratedColumn<bool> syncPending = GeneratedColumn<bool>(
    'sync_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeId,
    employeeCode,
    employeeName,
    leaveType,
    fromDate,
    toDate,
    daysCount,
    reason,
    status,
    appliedDate,
    syncPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leave_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaveRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
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
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
    }
    if (data.containsKey('leave_type')) {
      context.handle(
        _leaveTypeMeta,
        leaveType.isAcceptableOrUnknown(data['leave_type']!, _leaveTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_leaveTypeMeta);
    }
    if (data.containsKey('from_date')) {
      context.handle(
        _fromDateMeta,
        fromDate.isAcceptableOrUnknown(data['from_date']!, _fromDateMeta),
      );
    } else if (isInserting) {
      context.missing(_fromDateMeta);
    }
    if (data.containsKey('to_date')) {
      context.handle(
        _toDateMeta,
        toDate.isAcceptableOrUnknown(data['to_date']!, _toDateMeta),
      );
    } else if (isInserting) {
      context.missing(_toDateMeta);
    }
    if (data.containsKey('days_count')) {
      context.handle(
        _daysCountMeta,
        daysCount.isAcceptableOrUnknown(data['days_count']!, _daysCountMeta),
      );
    } else if (isInserting) {
      context.missing(_daysCountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('applied_date')) {
      context.handle(
        _appliedDateMeta,
        appliedDate.isAcceptableOrUnknown(
          data['applied_date']!,
          _appliedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedDateMeta);
    }
    if (data.containsKey('sync_pending')) {
      context.handle(
        _syncPendingMeta,
        syncPending.isAcceptableOrUnknown(
          data['sync_pending']!,
          _syncPendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeaveRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaveRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      leaveType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leave_type'],
      )!,
      fromDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}from_date'],
      )!,
      toDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}to_date'],
      )!,
      daysCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_count'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      appliedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_date'],
      )!,
      syncPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_pending'],
      )!,
    );
  }

  @override
  $LeaveRequestsTable createAlias(String alias) {
    return $LeaveRequestsTable(attachedDatabase, alias);
  }
}

class LeaveRequest extends DataClass implements Insertable<LeaveRequest> {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final int daysCount;
  final String reason;
  final String status;
  final DateTime appliedDate;
  final bool syncPending;
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.daysCount,
    required this.reason,
    required this.status,
    required this.appliedDate,
    required this.syncPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['employee_id'] = Variable<String>(employeeId);
    map['employee_code'] = Variable<String>(employeeCode);
    map['employee_name'] = Variable<String>(employeeName);
    map['leave_type'] = Variable<String>(leaveType);
    map['from_date'] = Variable<DateTime>(fromDate);
    map['to_date'] = Variable<DateTime>(toDate);
    map['days_count'] = Variable<int>(daysCount);
    map['reason'] = Variable<String>(reason);
    map['status'] = Variable<String>(status);
    map['applied_date'] = Variable<DateTime>(appliedDate);
    map['sync_pending'] = Variable<bool>(syncPending);
    return map;
  }

  LeaveRequestsCompanion toCompanion(bool nullToAbsent) {
    return LeaveRequestsCompanion(
      id: Value(id),
      employeeId: Value(employeeId),
      employeeCode: Value(employeeCode),
      employeeName: Value(employeeName),
      leaveType: Value(leaveType),
      fromDate: Value(fromDate),
      toDate: Value(toDate),
      daysCount: Value(daysCount),
      reason: Value(reason),
      status: Value(status),
      appliedDate: Value(appliedDate),
      syncPending: Value(syncPending),
    );
  }

  factory LeaveRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaveRequest(
      id: serializer.fromJson<String>(json['id']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      leaveType: serializer.fromJson<String>(json['leaveType']),
      fromDate: serializer.fromJson<DateTime>(json['fromDate']),
      toDate: serializer.fromJson<DateTime>(json['toDate']),
      daysCount: serializer.fromJson<int>(json['daysCount']),
      reason: serializer.fromJson<String>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      appliedDate: serializer.fromJson<DateTime>(json['appliedDate']),
      syncPending: serializer.fromJson<bool>(json['syncPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeId': serializer.toJson<String>(employeeId),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'employeeName': serializer.toJson<String>(employeeName),
      'leaveType': serializer.toJson<String>(leaveType),
      'fromDate': serializer.toJson<DateTime>(fromDate),
      'toDate': serializer.toJson<DateTime>(toDate),
      'daysCount': serializer.toJson<int>(daysCount),
      'reason': serializer.toJson<String>(reason),
      'status': serializer.toJson<String>(status),
      'appliedDate': serializer.toJson<DateTime>(appliedDate),
      'syncPending': serializer.toJson<bool>(syncPending),
    };
  }

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeCode,
    String? employeeName,
    String? leaveType,
    DateTime? fromDate,
    DateTime? toDate,
    int? daysCount,
    String? reason,
    String? status,
    DateTime? appliedDate,
    bool? syncPending,
  }) => LeaveRequest(
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    employeeCode: employeeCode ?? this.employeeCode,
    employeeName: employeeName ?? this.employeeName,
    leaveType: leaveType ?? this.leaveType,
    fromDate: fromDate ?? this.fromDate,
    toDate: toDate ?? this.toDate,
    daysCount: daysCount ?? this.daysCount,
    reason: reason ?? this.reason,
    status: status ?? this.status,
    appliedDate: appliedDate ?? this.appliedDate,
    syncPending: syncPending ?? this.syncPending,
  );
  LeaveRequest copyWithCompanion(LeaveRequestsCompanion data) {
    return LeaveRequest(
      id: data.id.present ? data.id.value : this.id,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      leaveType: data.leaveType.present ? data.leaveType.value : this.leaveType,
      fromDate: data.fromDate.present ? data.fromDate.value : this.fromDate,
      toDate: data.toDate.present ? data.toDate.value : this.toDate,
      daysCount: data.daysCount.present ? data.daysCount.value : this.daysCount,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      appliedDate: data.appliedDate.present
          ? data.appliedDate.value
          : this.appliedDate,
      syncPending: data.syncPending.present
          ? data.syncPending.value
          : this.syncPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaveRequest(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('employeeName: $employeeName, ')
          ..write('leaveType: $leaveType, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('daysCount: $daysCount, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('appliedDate: $appliedDate, ')
          ..write('syncPending: $syncPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeId,
    employeeCode,
    employeeName,
    leaveType,
    fromDate,
    toDate,
    daysCount,
    reason,
    status,
    appliedDate,
    syncPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaveRequest &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.employeeCode == this.employeeCode &&
          other.employeeName == this.employeeName &&
          other.leaveType == this.leaveType &&
          other.fromDate == this.fromDate &&
          other.toDate == this.toDate &&
          other.daysCount == this.daysCount &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.appliedDate == this.appliedDate &&
          other.syncPending == this.syncPending);
}

class LeaveRequestsCompanion extends UpdateCompanion<LeaveRequest> {
  final Value<String> id;
  final Value<String> employeeId;
  final Value<String> employeeCode;
  final Value<String> employeeName;
  final Value<String> leaveType;
  final Value<DateTime> fromDate;
  final Value<DateTime> toDate;
  final Value<int> daysCount;
  final Value<String> reason;
  final Value<String> status;
  final Value<DateTime> appliedDate;
  final Value<bool> syncPending;
  final Value<int> rowid;
  const LeaveRequestsCompanion({
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.leaveType = const Value.absent(),
    this.fromDate = const Value.absent(),
    this.toDate = const Value.absent(),
    this.daysCount = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.appliedDate = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaveRequestsCompanion.insert({
    required String id,
    required String employeeId,
    required String employeeCode,
    required String employeeName,
    required String leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required int daysCount,
    required String reason,
    required String status,
    required DateTime appliedDate,
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeId = Value(employeeId),
       employeeCode = Value(employeeCode),
       employeeName = Value(employeeName),
       leaveType = Value(leaveType),
       fromDate = Value(fromDate),
       toDate = Value(toDate),
       daysCount = Value(daysCount),
       reason = Value(reason),
       status = Value(status),
       appliedDate = Value(appliedDate);
  static Insertable<LeaveRequest> custom({
    Expression<String>? id,
    Expression<String>? employeeId,
    Expression<String>? employeeCode,
    Expression<String>? employeeName,
    Expression<String>? leaveType,
    Expression<DateTime>? fromDate,
    Expression<DateTime>? toDate,
    Expression<int>? daysCount,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<DateTime>? appliedDate,
    Expression<bool>? syncPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (employeeName != null) 'employee_name': employeeName,
      if (leaveType != null) 'leave_type': leaveType,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (daysCount != null) 'days_count': daysCount,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (appliedDate != null) 'applied_date': appliedDate,
      if (syncPending != null) 'sync_pending': syncPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaveRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? employeeId,
    Value<String>? employeeCode,
    Value<String>? employeeName,
    Value<String>? leaveType,
    Value<DateTime>? fromDate,
    Value<DateTime>? toDate,
    Value<int>? daysCount,
    Value<String>? reason,
    Value<String>? status,
    Value<DateTime>? appliedDate,
    Value<bool>? syncPending,
    Value<int>? rowid,
  }) {
    return LeaveRequestsCompanion(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      leaveType: leaveType ?? this.leaveType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      daysCount: daysCount ?? this.daysCount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      syncPending: syncPending ?? this.syncPending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (leaveType.present) {
      map['leave_type'] = Variable<String>(leaveType.value);
    }
    if (fromDate.present) {
      map['from_date'] = Variable<DateTime>(fromDate.value);
    }
    if (toDate.present) {
      map['to_date'] = Variable<DateTime>(toDate.value);
    }
    if (daysCount.present) {
      map['days_count'] = Variable<int>(daysCount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (appliedDate.present) {
      map['applied_date'] = Variable<DateTime>(appliedDate.value);
    }
    if (syncPending.present) {
      map['sync_pending'] = Variable<bool>(syncPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaveRequestsCompanion(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('employeeName: $employeeName, ')
          ..write('leaveType: $leaveType, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('daysCount: $daysCount, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('appliedDate: $appliedDate, ')
          ..write('syncPending: $syncPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidaysTable extends Holidays with TableInfo<$HolidaysTable, Holiday> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _holidayNameMeta = const VerificationMeta(
    'holidayName',
  );
  @override
  late final GeneratedColumn<String> holidayName = GeneratedColumn<String>(
    'holiday_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _holidayDateMeta = const VerificationMeta(
    'holidayDate',
  );
  @override
  late final GeneratedColumn<DateTime> holidayDate = GeneratedColumn<DateTime>(
    'holiday_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, holidayName, holidayDate, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holidays';
  @override
  VerificationContext validateIntegrity(
    Insertable<Holiday> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('holiday_name')) {
      context.handle(
        _holidayNameMeta,
        holidayName.isAcceptableOrUnknown(
          data['holiday_name']!,
          _holidayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_holidayNameMeta);
    }
    if (data.containsKey('holiday_date')) {
      context.handle(
        _holidayDateMeta,
        holidayDate.isAcceptableOrUnknown(
          data['holiday_date']!,
          _holidayDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_holidayDateMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    } else if (isInserting) {
      context.missing(_activeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Holiday map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holiday(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      holidayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holiday_name'],
      )!,
      holidayDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}holiday_date'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $HolidaysTable createAlias(String alias) {
    return $HolidaysTable(attachedDatabase, alias);
  }
}

class Holiday extends DataClass implements Insertable<Holiday> {
  final String id;
  final String holidayName;
  final DateTime holidayDate;
  final bool active;
  const Holiday({
    required this.id,
    required this.holidayName,
    required this.holidayDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['holiday_name'] = Variable<String>(holidayName);
    map['holiday_date'] = Variable<DateTime>(holidayDate);
    map['active'] = Variable<bool>(active);
    return map;
  }

  HolidaysCompanion toCompanion(bool nullToAbsent) {
    return HolidaysCompanion(
      id: Value(id),
      holidayName: Value(holidayName),
      holidayDate: Value(holidayDate),
      active: Value(active),
    );
  }

  factory Holiday.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holiday(
      id: serializer.fromJson<String>(json['id']),
      holidayName: serializer.fromJson<String>(json['holidayName']),
      holidayDate: serializer.fromJson<DateTime>(json['holidayDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'holidayName': serializer.toJson<String>(holidayName),
      'holidayDate': serializer.toJson<DateTime>(holidayDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  Holiday copyWith({
    String? id,
    String? holidayName,
    DateTime? holidayDate,
    bool? active,
  }) => Holiday(
    id: id ?? this.id,
    holidayName: holidayName ?? this.holidayName,
    holidayDate: holidayDate ?? this.holidayDate,
    active: active ?? this.active,
  );
  Holiday copyWithCompanion(HolidaysCompanion data) {
    return Holiday(
      id: data.id.present ? data.id.value : this.id,
      holidayName: data.holidayName.present
          ? data.holidayName.value
          : this.holidayName,
      holidayDate: data.holidayDate.present
          ? data.holidayDate.value
          : this.holidayDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holiday(')
          ..write('id: $id, ')
          ..write('holidayName: $holidayName, ')
          ..write('holidayDate: $holidayDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, holidayName, holidayDate, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holiday &&
          other.id == this.id &&
          other.holidayName == this.holidayName &&
          other.holidayDate == this.holidayDate &&
          other.active == this.active);
}

class HolidaysCompanion extends UpdateCompanion<Holiday> {
  final Value<String> id;
  final Value<String> holidayName;
  final Value<DateTime> holidayDate;
  final Value<bool> active;
  final Value<int> rowid;
  const HolidaysCompanion({
    this.id = const Value.absent(),
    this.holidayName = const Value.absent(),
    this.holidayDate = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidaysCompanion.insert({
    required String id,
    required String holidayName,
    required DateTime holidayDate,
    required bool active,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       holidayName = Value(holidayName),
       holidayDate = Value(holidayDate),
       active = Value(active);
  static Insertable<Holiday> custom({
    Expression<String>? id,
    Expression<String>? holidayName,
    Expression<DateTime>? holidayDate,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (holidayName != null) 'holiday_name': holidayName,
      if (holidayDate != null) 'holiday_date': holidayDate,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HolidaysCompanion copyWith({
    Value<String>? id,
    Value<String>? holidayName,
    Value<DateTime>? holidayDate,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return HolidaysCompanion(
      id: id ?? this.id,
      holidayName: holidayName ?? this.holidayName,
      holidayDate: holidayDate ?? this.holidayDate,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (holidayName.present) {
      map['holiday_name'] = Variable<String>(holidayName.value);
    }
    if (holidayDate.present) {
      map['holiday_date'] = Variable<DateTime>(holidayDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidaysCompanion(')
          ..write('id: $id, ')
          ..write('holidayName: $holidayName, ')
          ..write('holidayDate: $holidayDate, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeadFeedbackTable extends LeadFeedback
    with TableInfo<$LeadFeedbackTable, LeadFeedbackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeadFeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
    'lead_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadStatusMeta = const VerificationMeta(
    'leadStatus',
  );
  @override
  late final GeneratedColumn<String> leadStatus = GeneratedColumn<String>(
    'lead_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadStatusDateMeta = const VerificationMeta(
    'leadStatusDate',
  );
  @override
  late final GeneratedColumn<DateTime> leadStatusDate =
      GeneratedColumn<DateTime>(
        'lead_status_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusUpdateTimeMeta = const VerificationMeta(
    'statusUpdateTime',
  );
  @override
  late final GeneratedColumn<DateTime> statusUpdateTime =
      GeneratedColumn<DateTime>(
        'status_update_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<String> user = GeneratedColumn<String>(
    'user',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
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
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leadId,
    customerName,
    mobileNo,
    leadStatus,
    leadStatusDate,
    statusUpdateTime,
    user,
    employeeName,
    employeeCode,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lead_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeadFeedbackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(
        _leadIdMeta,
        leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leadIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileNoMeta);
    }
    if (data.containsKey('lead_status')) {
      context.handle(
        _leadStatusMeta,
        leadStatus.isAcceptableOrUnknown(data['lead_status']!, _leadStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_leadStatusMeta);
    }
    if (data.containsKey('lead_status_date')) {
      context.handle(
        _leadStatusDateMeta,
        leadStatusDate.isAcceptableOrUnknown(
          data['lead_status_date']!,
          _leadStatusDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_leadStatusDateMeta);
    }
    if (data.containsKey('status_update_time')) {
      context.handle(
        _statusUpdateTimeMeta,
        statusUpdateTime.isAcceptableOrUnknown(
          data['status_update_time']!,
          _statusUpdateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statusUpdateTimeMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
        _userMeta,
        user.isAcceptableOrUnknown(data['user']!, _userMeta),
      );
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeadFeedbackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeadFeedbackData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      leadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      mobileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_no'],
      )!,
      leadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_status'],
      )!,
      leadStatusDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lead_status_date'],
      )!,
      statusUpdateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}status_update_time'],
      )!,
      user: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LeadFeedbackTable createAlias(String alias) {
    return $LeadFeedbackTable(attachedDatabase, alias);
  }
}

class LeadFeedbackData extends DataClass
    implements Insertable<LeadFeedbackData> {
  final String id;
  final String leadId;
  final String customerName;
  final String mobileNo;
  final String leadStatus;
  final DateTime leadStatusDate;
  final DateTime statusUpdateTime;
  final String user;
  final String employeeName;
  final String employeeCode;
  final bool isSynced;
  const LeadFeedbackData({
    required this.id,
    required this.leadId,
    required this.customerName,
    required this.mobileNo,
    required this.leadStatus,
    required this.leadStatusDate,
    required this.statusUpdateTime,
    required this.user,
    required this.employeeName,
    required this.employeeCode,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lead_id'] = Variable<String>(leadId);
    map['customer_name'] = Variable<String>(customerName);
    map['mobile_no'] = Variable<String>(mobileNo);
    map['lead_status'] = Variable<String>(leadStatus);
    map['lead_status_date'] = Variable<DateTime>(leadStatusDate);
    map['status_update_time'] = Variable<DateTime>(statusUpdateTime);
    map['user'] = Variable<String>(user);
    map['employee_name'] = Variable<String>(employeeName);
    map['employee_code'] = Variable<String>(employeeCode);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LeadFeedbackCompanion toCompanion(bool nullToAbsent) {
    return LeadFeedbackCompanion(
      id: Value(id),
      leadId: Value(leadId),
      customerName: Value(customerName),
      mobileNo: Value(mobileNo),
      leadStatus: Value(leadStatus),
      leadStatusDate: Value(leadStatusDate),
      statusUpdateTime: Value(statusUpdateTime),
      user: Value(user),
      employeeName: Value(employeeName),
      employeeCode: Value(employeeCode),
      isSynced: Value(isSynced),
    );
  }

  factory LeadFeedbackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeadFeedbackData(
      id: serializer.fromJson<String>(json['id']),
      leadId: serializer.fromJson<String>(json['leadId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      leadStatus: serializer.fromJson<String>(json['leadStatus']),
      leadStatusDate: serializer.fromJson<DateTime>(json['leadStatusDate']),
      statusUpdateTime: serializer.fromJson<DateTime>(json['statusUpdateTime']),
      user: serializer.fromJson<String>(json['user']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'leadId': serializer.toJson<String>(leadId),
      'customerName': serializer.toJson<String>(customerName),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'leadStatus': serializer.toJson<String>(leadStatus),
      'leadStatusDate': serializer.toJson<DateTime>(leadStatusDate),
      'statusUpdateTime': serializer.toJson<DateTime>(statusUpdateTime),
      'user': serializer.toJson<String>(user),
      'employeeName': serializer.toJson<String>(employeeName),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LeadFeedbackData copyWith({
    String? id,
    String? leadId,
    String? customerName,
    String? mobileNo,
    String? leadStatus,
    DateTime? leadStatusDate,
    DateTime? statusUpdateTime,
    String? user,
    String? employeeName,
    String? employeeCode,
    bool? isSynced,
  }) => LeadFeedbackData(
    id: id ?? this.id,
    leadId: leadId ?? this.leadId,
    customerName: customerName ?? this.customerName,
    mobileNo: mobileNo ?? this.mobileNo,
    leadStatus: leadStatus ?? this.leadStatus,
    leadStatusDate: leadStatusDate ?? this.leadStatusDate,
    statusUpdateTime: statusUpdateTime ?? this.statusUpdateTime,
    user: user ?? this.user,
    employeeName: employeeName ?? this.employeeName,
    employeeCode: employeeCode ?? this.employeeCode,
    isSynced: isSynced ?? this.isSynced,
  );
  LeadFeedbackData copyWithCompanion(LeadFeedbackCompanion data) {
    return LeadFeedbackData(
      id: data.id.present ? data.id.value : this.id,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      leadStatus: data.leadStatus.present
          ? data.leadStatus.value
          : this.leadStatus,
      leadStatusDate: data.leadStatusDate.present
          ? data.leadStatusDate.value
          : this.leadStatusDate,
      statusUpdateTime: data.statusUpdateTime.present
          ? data.statusUpdateTime.value
          : this.statusUpdateTime,
      user: data.user.present ? data.user.value : this.user,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeadFeedbackData(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('leadStatusDate: $leadStatusDate, ')
          ..write('statusUpdateTime: $statusUpdateTime, ')
          ..write('user: $user, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    leadId,
    customerName,
    mobileNo,
    leadStatus,
    leadStatusDate,
    statusUpdateTime,
    user,
    employeeName,
    employeeCode,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeadFeedbackData &&
          other.id == this.id &&
          other.leadId == this.leadId &&
          other.customerName == this.customerName &&
          other.mobileNo == this.mobileNo &&
          other.leadStatus == this.leadStatus &&
          other.leadStatusDate == this.leadStatusDate &&
          other.statusUpdateTime == this.statusUpdateTime &&
          other.user == this.user &&
          other.employeeName == this.employeeName &&
          other.employeeCode == this.employeeCode &&
          other.isSynced == this.isSynced);
}

class LeadFeedbackCompanion extends UpdateCompanion<LeadFeedbackData> {
  final Value<String> id;
  final Value<String> leadId;
  final Value<String> customerName;
  final Value<String> mobileNo;
  final Value<String> leadStatus;
  final Value<DateTime> leadStatusDate;
  final Value<DateTime> statusUpdateTime;
  final Value<String> user;
  final Value<String> employeeName;
  final Value<String> employeeCode;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LeadFeedbackCompanion({
    this.id = const Value.absent(),
    this.leadId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.leadStatus = const Value.absent(),
    this.leadStatusDate = const Value.absent(),
    this.statusUpdateTime = const Value.absent(),
    this.user = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeadFeedbackCompanion.insert({
    required String id,
    required String leadId,
    required String customerName,
    required String mobileNo,
    required String leadStatus,
    required DateTime leadStatusDate,
    required DateTime statusUpdateTime,
    required String user,
    required String employeeName,
    required String employeeCode,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       leadId = Value(leadId),
       customerName = Value(customerName),
       mobileNo = Value(mobileNo),
       leadStatus = Value(leadStatus),
       leadStatusDate = Value(leadStatusDate),
       statusUpdateTime = Value(statusUpdateTime),
       user = Value(user),
       employeeName = Value(employeeName),
       employeeCode = Value(employeeCode);
  static Insertable<LeadFeedbackData> custom({
    Expression<String>? id,
    Expression<String>? leadId,
    Expression<String>? customerName,
    Expression<String>? mobileNo,
    Expression<String>? leadStatus,
    Expression<DateTime>? leadStatusDate,
    Expression<DateTime>? statusUpdateTime,
    Expression<String>? user,
    Expression<String>? employeeName,
    Expression<String>? employeeCode,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leadId != null) 'lead_id': leadId,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (leadStatus != null) 'lead_status': leadStatus,
      if (leadStatusDate != null) 'lead_status_date': leadStatusDate,
      if (statusUpdateTime != null) 'status_update_time': statusUpdateTime,
      if (user != null) 'user': user,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeadFeedbackCompanion copyWith({
    Value<String>? id,
    Value<String>? leadId,
    Value<String>? customerName,
    Value<String>? mobileNo,
    Value<String>? leadStatus,
    Value<DateTime>? leadStatusDate,
    Value<DateTime>? statusUpdateTime,
    Value<String>? user,
    Value<String>? employeeName,
    Value<String>? employeeCode,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LeadFeedbackCompanion(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      leadStatus: leadStatus ?? this.leadStatus,
      leadStatusDate: leadStatusDate ?? this.leadStatusDate,
      statusUpdateTime: statusUpdateTime ?? this.statusUpdateTime,
      user: user ?? this.user,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (leadStatus.present) {
      map['lead_status'] = Variable<String>(leadStatus.value);
    }
    if (leadStatusDate.present) {
      map['lead_status_date'] = Variable<DateTime>(leadStatusDate.value);
    }
    if (statusUpdateTime.present) {
      map['status_update_time'] = Variable<DateTime>(statusUpdateTime.value);
    }
    if (user.present) {
      map['user'] = Variable<String>(user.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeadFeedbackCompanion(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('leadStatusDate: $leadStatusDate, ')
          ..write('statusUpdateTime: $statusUpdateTime, ')
          ..write('user: $user, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApplyLinksTable extends ApplyLinks
    with TableInfo<$ApplyLinksTable, ApplyLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApplyLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkNameMeta = const VerificationMeta(
    'linkName',
  );
  @override
  late final GeneratedColumn<String> linkName = GeneratedColumn<String>(
    'link_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkUrlMeta = const VerificationMeta(
    'linkUrl',
  );
  @override
  late final GeneratedColumn<String> linkUrl = GeneratedColumn<String>(
    'link_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, linkName, linkUrl, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apply_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApplyLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('link_name')) {
      context.handle(
        _linkNameMeta,
        linkName.isAcceptableOrUnknown(data['link_name']!, _linkNameMeta),
      );
    } else if (isInserting) {
      context.missing(_linkNameMeta);
    }
    if (data.containsKey('link_url')) {
      context.handle(
        _linkUrlMeta,
        linkUrl.isAcceptableOrUnknown(data['link_url']!, _linkUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_linkUrlMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApplyLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApplyLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      linkName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_name'],
      )!,
      linkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_url'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $ApplyLinksTable createAlias(String alias) {
    return $ApplyLinksTable(attachedDatabase, alias);
  }
}

class ApplyLink extends DataClass implements Insertable<ApplyLink> {
  final String id;
  final String linkName;
  final String linkUrl;
  final bool isDefault;
  const ApplyLink({
    required this.id,
    required this.linkName,
    required this.linkUrl,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['link_name'] = Variable<String>(linkName);
    map['link_url'] = Variable<String>(linkUrl);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  ApplyLinksCompanion toCompanion(bool nullToAbsent) {
    return ApplyLinksCompanion(
      id: Value(id),
      linkName: Value(linkName),
      linkUrl: Value(linkUrl),
      isDefault: Value(isDefault),
    );
  }

  factory ApplyLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApplyLink(
      id: serializer.fromJson<String>(json['id']),
      linkName: serializer.fromJson<String>(json['linkName']),
      linkUrl: serializer.fromJson<String>(json['linkUrl']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'linkName': serializer.toJson<String>(linkName),
      'linkUrl': serializer.toJson<String>(linkUrl),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  ApplyLink copyWith({
    String? id,
    String? linkName,
    String? linkUrl,
    bool? isDefault,
  }) => ApplyLink(
    id: id ?? this.id,
    linkName: linkName ?? this.linkName,
    linkUrl: linkUrl ?? this.linkUrl,
    isDefault: isDefault ?? this.isDefault,
  );
  ApplyLink copyWithCompanion(ApplyLinksCompanion data) {
    return ApplyLink(
      id: data.id.present ? data.id.value : this.id,
      linkName: data.linkName.present ? data.linkName.value : this.linkName,
      linkUrl: data.linkUrl.present ? data.linkUrl.value : this.linkUrl,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApplyLink(')
          ..write('id: $id, ')
          ..write('linkName: $linkName, ')
          ..write('linkUrl: $linkUrl, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, linkName, linkUrl, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApplyLink &&
          other.id == this.id &&
          other.linkName == this.linkName &&
          other.linkUrl == this.linkUrl &&
          other.isDefault == this.isDefault);
}

class ApplyLinksCompanion extends UpdateCompanion<ApplyLink> {
  final Value<String> id;
  final Value<String> linkName;
  final Value<String> linkUrl;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const ApplyLinksCompanion({
    this.id = const Value.absent(),
    this.linkName = const Value.absent(),
    this.linkUrl = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApplyLinksCompanion.insert({
    required String id,
    required String linkName,
    required String linkUrl,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       linkName = Value(linkName),
       linkUrl = Value(linkUrl);
  static Insertable<ApplyLink> custom({
    Expression<String>? id,
    Expression<String>? linkName,
    Expression<String>? linkUrl,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (linkName != null) 'link_name': linkName,
      if (linkUrl != null) 'link_url': linkUrl,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApplyLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? linkName,
    Value<String>? linkUrl,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return ApplyLinksCompanion(
      id: id ?? this.id,
      linkName: linkName ?? this.linkName,
      linkUrl: linkUrl ?? this.linkUrl,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (linkName.present) {
      map['link_name'] = Variable<String>(linkName.value);
    }
    if (linkUrl.present) {
      map['link_url'] = Variable<String>(linkUrl.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApplyLinksCompanion(')
          ..write('id: $id, ')
          ..write('linkName: $linkName, ')
          ..write('linkUrl: $linkUrl, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VkycRecordsTable extends VkycRecords
    with TableInfo<$VkycRecordsTable, VkycRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VkycRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
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
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankVkycStatusMeta = const VerificationMeta(
    'bankVkycStatus',
  );
  @override
  late final GeneratedColumn<String> bankVkycStatus = GeneratedColumn<String>(
    'bank_vkyc_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userVkycStatusMeta = const VerificationMeta(
    'userVkycStatus',
  );
  @override
  late final GeneratedColumn<String> userVkycStatus = GeneratedColumn<String>(
    'user_vkyc_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userRemarksMeta = const VerificationMeta(
    'userRemarks',
  );
  @override
  late final GeneratedColumn<String> userRemarks = GeneratedColumn<String>(
    'user_remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataStatusMeta = const VerificationMeta(
    'dataStatus',
  );
  @override
  late final GeneratedColumn<String> dataStatus = GeneratedColumn<String>(
    'data_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vkycExpiryDateMeta = const VerificationMeta(
    'vkycExpiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> vkycExpiryDate =
      GeneratedColumn<DateTime>(
        'vkyc_expiry_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _removeDataMeta = const VerificationMeta(
    'removeData',
  );
  @override
  late final GeneratedColumn<bool> removeData = GeneratedColumn<bool>(
    'remove_data',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remove_data" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vkycLinkMeta = const VerificationMeta(
    'vkycLink',
  );
  @override
  late final GeneratedColumn<String> vkycLink = GeneratedColumn<String>(
    'vkyc_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arnNoMeta = const VerificationMeta('arnNo');
  @override
  late final GeneratedColumn<String> arnNo = GeneratedColumn<String>(
    'arn_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncPendingMeta = const VerificationMeta(
    'syncPending',
  );
  @override
  late final GeneratedColumn<bool> syncPending = GeneratedColumn<bool>(
    'sync_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeName,
    employeeCode,
    customerName,
    mobileNo,
    bankVkycStatus,
    userVkycStatus,
    userRemarks,
    dataStatus,
    vkycExpiryDate,
    removeData,
    vkycLink,
    arnNo,
    created,
    updated,
    syncPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vkyc_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<VkycRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
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
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileNoMeta);
    }
    if (data.containsKey('bank_vkyc_status')) {
      context.handle(
        _bankVkycStatusMeta,
        bankVkycStatus.isAcceptableOrUnknown(
          data['bank_vkyc_status']!,
          _bankVkycStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bankVkycStatusMeta);
    }
    if (data.containsKey('user_vkyc_status')) {
      context.handle(
        _userVkycStatusMeta,
        userVkycStatus.isAcceptableOrUnknown(
          data['user_vkyc_status']!,
          _userVkycStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userVkycStatusMeta);
    }
    if (data.containsKey('user_remarks')) {
      context.handle(
        _userRemarksMeta,
        userRemarks.isAcceptableOrUnknown(
          data['user_remarks']!,
          _userRemarksMeta,
        ),
      );
    }
    if (data.containsKey('data_status')) {
      context.handle(
        _dataStatusMeta,
        dataStatus.isAcceptableOrUnknown(data['data_status']!, _dataStatusMeta),
      );
    }
    if (data.containsKey('vkyc_expiry_date')) {
      context.handle(
        _vkycExpiryDateMeta,
        vkycExpiryDate.isAcceptableOrUnknown(
          data['vkyc_expiry_date']!,
          _vkycExpiryDateMeta,
        ),
      );
    }
    if (data.containsKey('remove_data')) {
      context.handle(
        _removeDataMeta,
        removeData.isAcceptableOrUnknown(data['remove_data']!, _removeDataMeta),
      );
    }
    if (data.containsKey('vkyc_link')) {
      context.handle(
        _vkycLinkMeta,
        vkycLink.isAcceptableOrUnknown(data['vkyc_link']!, _vkycLinkMeta),
      );
    }
    if (data.containsKey('arn_no')) {
      context.handle(
        _arnNoMeta,
        arnNo.isAcceptableOrUnknown(data['arn_no']!, _arnNoMeta),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedMeta);
    }
    if (data.containsKey('sync_pending')) {
      context.handle(
        _syncPendingMeta,
        syncPending.isAcceptableOrUnknown(
          data['sync_pending']!,
          _syncPendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VkycRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VkycRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      mobileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_no'],
      )!,
      bankVkycStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_vkyc_status'],
      )!,
      userVkycStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_vkyc_status'],
      )!,
      userRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remarks'],
      ),
      dataStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_status'],
      ),
      vkycExpiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vkyc_expiry_date'],
      ),
      removeData: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remove_data'],
      )!,
      vkycLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vkyc_link'],
      ),
      arnNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arn_no'],
      ),
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      )!,
      syncPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_pending'],
      )!,
    );
  }

  @override
  $VkycRecordsTable createAlias(String alias) {
    return $VkycRecordsTable(attachedDatabase, alias);
  }
}

class VkycRecord extends DataClass implements Insertable<VkycRecord> {
  final String id;
  final String employeeName;
  final String employeeCode;
  final String customerName;
  final String mobileNo;
  final String bankVkycStatus;
  final String userVkycStatus;
  final String? userRemarks;
  final String? dataStatus;
  final DateTime? vkycExpiryDate;
  final bool removeData;
  final String? vkycLink;
  final String? arnNo;
  final DateTime created;
  final DateTime updated;
  final bool syncPending;
  const VkycRecord({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    required this.customerName,
    required this.mobileNo,
    required this.bankVkycStatus,
    required this.userVkycStatus,
    this.userRemarks,
    this.dataStatus,
    this.vkycExpiryDate,
    required this.removeData,
    this.vkycLink,
    this.arnNo,
    required this.created,
    required this.updated,
    required this.syncPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['employee_name'] = Variable<String>(employeeName);
    map['employee_code'] = Variable<String>(employeeCode);
    map['customer_name'] = Variable<String>(customerName);
    map['mobile_no'] = Variable<String>(mobileNo);
    map['bank_vkyc_status'] = Variable<String>(bankVkycStatus);
    map['user_vkyc_status'] = Variable<String>(userVkycStatus);
    if (!nullToAbsent || userRemarks != null) {
      map['user_remarks'] = Variable<String>(userRemarks);
    }
    if (!nullToAbsent || dataStatus != null) {
      map['data_status'] = Variable<String>(dataStatus);
    }
    if (!nullToAbsent || vkycExpiryDate != null) {
      map['vkyc_expiry_date'] = Variable<DateTime>(vkycExpiryDate);
    }
    map['remove_data'] = Variable<bool>(removeData);
    if (!nullToAbsent || vkycLink != null) {
      map['vkyc_link'] = Variable<String>(vkycLink);
    }
    if (!nullToAbsent || arnNo != null) {
      map['arn_no'] = Variable<String>(arnNo);
    }
    map['created'] = Variable<DateTime>(created);
    map['updated'] = Variable<DateTime>(updated);
    map['sync_pending'] = Variable<bool>(syncPending);
    return map;
  }

  VkycRecordsCompanion toCompanion(bool nullToAbsent) {
    return VkycRecordsCompanion(
      id: Value(id),
      employeeName: Value(employeeName),
      employeeCode: Value(employeeCode),
      customerName: Value(customerName),
      mobileNo: Value(mobileNo),
      bankVkycStatus: Value(bankVkycStatus),
      userVkycStatus: Value(userVkycStatus),
      userRemarks: userRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(userRemarks),
      dataStatus: dataStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(dataStatus),
      vkycExpiryDate: vkycExpiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(vkycExpiryDate),
      removeData: Value(removeData),
      vkycLink: vkycLink == null && nullToAbsent
          ? const Value.absent()
          : Value(vkycLink),
      arnNo: arnNo == null && nullToAbsent
          ? const Value.absent()
          : Value(arnNo),
      created: Value(created),
      updated: Value(updated),
      syncPending: Value(syncPending),
    );
  }

  factory VkycRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VkycRecord(
      id: serializer.fromJson<String>(json['id']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      customerName: serializer.fromJson<String>(json['customerName']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      bankVkycStatus: serializer.fromJson<String>(json['bankVkycStatus']),
      userVkycStatus: serializer.fromJson<String>(json['userVkycStatus']),
      userRemarks: serializer.fromJson<String?>(json['userRemarks']),
      dataStatus: serializer.fromJson<String?>(json['dataStatus']),
      vkycExpiryDate: serializer.fromJson<DateTime?>(json['vkycExpiryDate']),
      removeData: serializer.fromJson<bool>(json['removeData']),
      vkycLink: serializer.fromJson<String?>(json['vkycLink']),
      arnNo: serializer.fromJson<String?>(json['arnNo']),
      created: serializer.fromJson<DateTime>(json['created']),
      updated: serializer.fromJson<DateTime>(json['updated']),
      syncPending: serializer.fromJson<bool>(json['syncPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeName': serializer.toJson<String>(employeeName),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'customerName': serializer.toJson<String>(customerName),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'bankVkycStatus': serializer.toJson<String>(bankVkycStatus),
      'userVkycStatus': serializer.toJson<String>(userVkycStatus),
      'userRemarks': serializer.toJson<String?>(userRemarks),
      'dataStatus': serializer.toJson<String?>(dataStatus),
      'vkycExpiryDate': serializer.toJson<DateTime?>(vkycExpiryDate),
      'removeData': serializer.toJson<bool>(removeData),
      'vkycLink': serializer.toJson<String?>(vkycLink),
      'arnNo': serializer.toJson<String?>(arnNo),
      'created': serializer.toJson<DateTime>(created),
      'updated': serializer.toJson<DateTime>(updated),
      'syncPending': serializer.toJson<bool>(syncPending),
    };
  }

  VkycRecord copyWith({
    String? id,
    String? employeeName,
    String? employeeCode,
    String? customerName,
    String? mobileNo,
    String? bankVkycStatus,
    String? userVkycStatus,
    Value<String?> userRemarks = const Value.absent(),
    Value<String?> dataStatus = const Value.absent(),
    Value<DateTime?> vkycExpiryDate = const Value.absent(),
    bool? removeData,
    Value<String?> vkycLink = const Value.absent(),
    Value<String?> arnNo = const Value.absent(),
    DateTime? created,
    DateTime? updated,
    bool? syncPending,
  }) => VkycRecord(
    id: id ?? this.id,
    employeeName: employeeName ?? this.employeeName,
    employeeCode: employeeCode ?? this.employeeCode,
    customerName: customerName ?? this.customerName,
    mobileNo: mobileNo ?? this.mobileNo,
    bankVkycStatus: bankVkycStatus ?? this.bankVkycStatus,
    userVkycStatus: userVkycStatus ?? this.userVkycStatus,
    userRemarks: userRemarks.present ? userRemarks.value : this.userRemarks,
    dataStatus: dataStatus.present ? dataStatus.value : this.dataStatus,
    vkycExpiryDate: vkycExpiryDate.present
        ? vkycExpiryDate.value
        : this.vkycExpiryDate,
    removeData: removeData ?? this.removeData,
    vkycLink: vkycLink.present ? vkycLink.value : this.vkycLink,
    arnNo: arnNo.present ? arnNo.value : this.arnNo,
    created: created ?? this.created,
    updated: updated ?? this.updated,
    syncPending: syncPending ?? this.syncPending,
  );
  VkycRecord copyWithCompanion(VkycRecordsCompanion data) {
    return VkycRecord(
      id: data.id.present ? data.id.value : this.id,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      bankVkycStatus: data.bankVkycStatus.present
          ? data.bankVkycStatus.value
          : this.bankVkycStatus,
      userVkycStatus: data.userVkycStatus.present
          ? data.userVkycStatus.value
          : this.userVkycStatus,
      userRemarks: data.userRemarks.present
          ? data.userRemarks.value
          : this.userRemarks,
      dataStatus: data.dataStatus.present
          ? data.dataStatus.value
          : this.dataStatus,
      vkycExpiryDate: data.vkycExpiryDate.present
          ? data.vkycExpiryDate.value
          : this.vkycExpiryDate,
      removeData: data.removeData.present
          ? data.removeData.value
          : this.removeData,
      vkycLink: data.vkycLink.present ? data.vkycLink.value : this.vkycLink,
      arnNo: data.arnNo.present ? data.arnNo.value : this.arnNo,
      created: data.created.present ? data.created.value : this.created,
      updated: data.updated.present ? data.updated.value : this.updated,
      syncPending: data.syncPending.present
          ? data.syncPending.value
          : this.syncPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VkycRecord(')
          ..write('id: $id, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('bankVkycStatus: $bankVkycStatus, ')
          ..write('userVkycStatus: $userVkycStatus, ')
          ..write('userRemarks: $userRemarks, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('vkycExpiryDate: $vkycExpiryDate, ')
          ..write('removeData: $removeData, ')
          ..write('vkycLink: $vkycLink, ')
          ..write('arnNo: $arnNo, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncPending: $syncPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeName,
    employeeCode,
    customerName,
    mobileNo,
    bankVkycStatus,
    userVkycStatus,
    userRemarks,
    dataStatus,
    vkycExpiryDate,
    removeData,
    vkycLink,
    arnNo,
    created,
    updated,
    syncPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VkycRecord &&
          other.id == this.id &&
          other.employeeName == this.employeeName &&
          other.employeeCode == this.employeeCode &&
          other.customerName == this.customerName &&
          other.mobileNo == this.mobileNo &&
          other.bankVkycStatus == this.bankVkycStatus &&
          other.userVkycStatus == this.userVkycStatus &&
          other.userRemarks == this.userRemarks &&
          other.dataStatus == this.dataStatus &&
          other.vkycExpiryDate == this.vkycExpiryDate &&
          other.removeData == this.removeData &&
          other.vkycLink == this.vkycLink &&
          other.arnNo == this.arnNo &&
          other.created == this.created &&
          other.updated == this.updated &&
          other.syncPending == this.syncPending);
}

class VkycRecordsCompanion extends UpdateCompanion<VkycRecord> {
  final Value<String> id;
  final Value<String> employeeName;
  final Value<String> employeeCode;
  final Value<String> customerName;
  final Value<String> mobileNo;
  final Value<String> bankVkycStatus;
  final Value<String> userVkycStatus;
  final Value<String?> userRemarks;
  final Value<String?> dataStatus;
  final Value<DateTime?> vkycExpiryDate;
  final Value<bool> removeData;
  final Value<String?> vkycLink;
  final Value<String?> arnNo;
  final Value<DateTime> created;
  final Value<DateTime> updated;
  final Value<bool> syncPending;
  final Value<int> rowid;
  const VkycRecordsCompanion({
    this.id = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.customerName = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.bankVkycStatus = const Value.absent(),
    this.userVkycStatus = const Value.absent(),
    this.userRemarks = const Value.absent(),
    this.dataStatus = const Value.absent(),
    this.vkycExpiryDate = const Value.absent(),
    this.removeData = const Value.absent(),
    this.vkycLink = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VkycRecordsCompanion.insert({
    required String id,
    required String employeeName,
    required String employeeCode,
    required String customerName,
    required String mobileNo,
    required String bankVkycStatus,
    required String userVkycStatus,
    this.userRemarks = const Value.absent(),
    this.dataStatus = const Value.absent(),
    this.vkycExpiryDate = const Value.absent(),
    this.removeData = const Value.absent(),
    this.vkycLink = const Value.absent(),
    this.arnNo = const Value.absent(),
    required DateTime created,
    required DateTime updated,
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeName = Value(employeeName),
       employeeCode = Value(employeeCode),
       customerName = Value(customerName),
       mobileNo = Value(mobileNo),
       bankVkycStatus = Value(bankVkycStatus),
       userVkycStatus = Value(userVkycStatus),
       created = Value(created),
       updated = Value(updated);
  static Insertable<VkycRecord> custom({
    Expression<String>? id,
    Expression<String>? employeeName,
    Expression<String>? employeeCode,
    Expression<String>? customerName,
    Expression<String>? mobileNo,
    Expression<String>? bankVkycStatus,
    Expression<String>? userVkycStatus,
    Expression<String>? userRemarks,
    Expression<String>? dataStatus,
    Expression<DateTime>? vkycExpiryDate,
    Expression<bool>? removeData,
    Expression<String>? vkycLink,
    Expression<String>? arnNo,
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<bool>? syncPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (bankVkycStatus != null) 'bank_vkyc_status': bankVkycStatus,
      if (userVkycStatus != null) 'user_vkyc_status': userVkycStatus,
      if (userRemarks != null) 'user_remarks': userRemarks,
      if (dataStatus != null) 'data_status': dataStatus,
      if (vkycExpiryDate != null) 'vkyc_expiry_date': vkycExpiryDate,
      if (removeData != null) 'remove_data': removeData,
      if (vkycLink != null) 'vkyc_link': vkycLink,
      if (arnNo != null) 'arn_no': arnNo,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (syncPending != null) 'sync_pending': syncPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VkycRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? employeeName,
    Value<String>? employeeCode,
    Value<String>? customerName,
    Value<String>? mobileNo,
    Value<String>? bankVkycStatus,
    Value<String>? userVkycStatus,
    Value<String?>? userRemarks,
    Value<String?>? dataStatus,
    Value<DateTime?>? vkycExpiryDate,
    Value<bool>? removeData,
    Value<String?>? vkycLink,
    Value<String?>? arnNo,
    Value<DateTime>? created,
    Value<DateTime>? updated,
    Value<bool>? syncPending,
    Value<int>? rowid,
  }) {
    return VkycRecordsCompanion(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      bankVkycStatus: bankVkycStatus ?? this.bankVkycStatus,
      userVkycStatus: userVkycStatus ?? this.userVkycStatus,
      userRemarks: userRemarks ?? this.userRemarks,
      dataStatus: dataStatus ?? this.dataStatus,
      vkycExpiryDate: vkycExpiryDate ?? this.vkycExpiryDate,
      removeData: removeData ?? this.removeData,
      vkycLink: vkycLink ?? this.vkycLink,
      arnNo: arnNo ?? this.arnNo,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      syncPending: syncPending ?? this.syncPending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (bankVkycStatus.present) {
      map['bank_vkyc_status'] = Variable<String>(bankVkycStatus.value);
    }
    if (userVkycStatus.present) {
      map['user_vkyc_status'] = Variable<String>(userVkycStatus.value);
    }
    if (userRemarks.present) {
      map['user_remarks'] = Variable<String>(userRemarks.value);
    }
    if (dataStatus.present) {
      map['data_status'] = Variable<String>(dataStatus.value);
    }
    if (vkycExpiryDate.present) {
      map['vkyc_expiry_date'] = Variable<DateTime>(vkycExpiryDate.value);
    }
    if (removeData.present) {
      map['remove_data'] = Variable<bool>(removeData.value);
    }
    if (vkycLink.present) {
      map['vkyc_link'] = Variable<String>(vkycLink.value);
    }
    if (arnNo.present) {
      map['arn_no'] = Variable<String>(arnNo.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (syncPending.present) {
      map['sync_pending'] = Variable<bool>(syncPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VkycRecordsCompanion(')
          ..write('id: $id, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('bankVkycStatus: $bankVkycStatus, ')
          ..write('userVkycStatus: $userVkycStatus, ')
          ..write('userRemarks: $userRemarks, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('vkycExpiryDate: $vkycExpiryDate, ')
          ..write('removeData: $removeData, ')
          ..write('vkycLink: $vkycLink, ')
          ..write('arnNo: $arnNo, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncPending: $syncPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BkycRecordsTable extends BkycRecords
    with TableInfo<$BkycRecordsTable, BkycRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BkycRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeCodeMeta = const VerificationMeta(
    'employeeCode',
  );
  @override
  late final GeneratedColumn<String> employeeCode = GeneratedColumn<String>(
    'employee_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arnNoMeta = const VerificationMeta('arnNo');
  @override
  late final GeneratedColumn<String> arnNo = GeneratedColumn<String>(
    'arn_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankStatusMeta = const VerificationMeta(
    'bankStatus',
  );
  @override
  late final GeneratedColumn<String> bankStatus = GeneratedColumn<String>(
    'bank_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userStatusMeta = const VerificationMeta(
    'userStatus',
  );
  @override
  late final GeneratedColumn<String> userStatus = GeneratedColumn<String>(
    'user_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userRemarksMeta = const VerificationMeta(
    'userRemarks',
  );
  @override
  late final GeneratedColumn<String> userRemarks = GeneratedColumn<String>(
    'user_remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankRemarksMeta = const VerificationMeta(
    'bankRemarks',
  );
  @override
  late final GeneratedColumn<String> bankRemarks = GeneratedColumn<String>(
    'bank_remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userStatusDateMeta = const VerificationMeta(
    'userStatusDate',
  );
  @override
  late final GeneratedColumn<DateTime> userStatusDate =
      GeneratedColumn<DateTime>(
        'user_status_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _removeDataMeta = const VerificationMeta(
    'removeData',
  );
  @override
  late final GeneratedColumn<bool> removeData = GeneratedColumn<bool>(
    'remove_data',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remove_data" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataStatusMeta = const VerificationMeta(
    'dataStatus',
  );
  @override
  late final GeneratedColumn<String> dataStatus = GeneratedColumn<String>(
    'data_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncPendingMeta = const VerificationMeta(
    'syncPending',
  );
  @override
  late final GeneratedColumn<bool> syncPending = GeneratedColumn<bool>(
    'sync_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeName,
    employeeCode,
    customerName,
    mobileNo,
    arnNo,
    bankStatus,
    userStatus,
    userRemarks,
    bankRemarks,
    userStatusDate,
    removeData,
    created,
    updated,
    dataStatus,
    syncPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bkyc_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BkycRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    }
    if (data.containsKey('employee_code')) {
      context.handle(
        _employeeCodeMeta,
        employeeCode.isAcceptableOrUnknown(
          data['employee_code']!,
          _employeeCodeMeta,
        ),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileNoMeta);
    }
    if (data.containsKey('arn_no')) {
      context.handle(
        _arnNoMeta,
        arnNo.isAcceptableOrUnknown(data['arn_no']!, _arnNoMeta),
      );
    }
    if (data.containsKey('bank_status')) {
      context.handle(
        _bankStatusMeta,
        bankStatus.isAcceptableOrUnknown(data['bank_status']!, _bankStatusMeta),
      );
    }
    if (data.containsKey('user_status')) {
      context.handle(
        _userStatusMeta,
        userStatus.isAcceptableOrUnknown(data['user_status']!, _userStatusMeta),
      );
    }
    if (data.containsKey('user_remarks')) {
      context.handle(
        _userRemarksMeta,
        userRemarks.isAcceptableOrUnknown(
          data['user_remarks']!,
          _userRemarksMeta,
        ),
      );
    }
    if (data.containsKey('bank_remarks')) {
      context.handle(
        _bankRemarksMeta,
        bankRemarks.isAcceptableOrUnknown(
          data['bank_remarks']!,
          _bankRemarksMeta,
        ),
      );
    }
    if (data.containsKey('user_status_date')) {
      context.handle(
        _userStatusDateMeta,
        userStatusDate.isAcceptableOrUnknown(
          data['user_status_date']!,
          _userStatusDateMeta,
        ),
      );
    }
    if (data.containsKey('remove_data')) {
      context.handle(
        _removeDataMeta,
        removeData.isAcceptableOrUnknown(data['remove_data']!, _removeDataMeta),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedMeta);
    }
    if (data.containsKey('data_status')) {
      context.handle(
        _dataStatusMeta,
        dataStatus.isAcceptableOrUnknown(data['data_status']!, _dataStatusMeta),
      );
    }
    if (data.containsKey('sync_pending')) {
      context.handle(
        _syncPendingMeta,
        syncPending.isAcceptableOrUnknown(
          data['sync_pending']!,
          _syncPendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BkycRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BkycRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      ),
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      mobileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_no'],
      )!,
      arnNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arn_no'],
      ),
      bankStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_status'],
      ),
      userStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_status'],
      ),
      userRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remarks'],
      ),
      bankRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_remarks'],
      ),
      userStatusDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}user_status_date'],
      ),
      removeData: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remove_data'],
      )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      )!,
      dataStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_status'],
      ),
      syncPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_pending'],
      )!,
    );
  }

  @override
  $BkycRecordsTable createAlias(String alias) {
    return $BkycRecordsTable(attachedDatabase, alias);
  }
}

class BkycRecord extends DataClass implements Insertable<BkycRecord> {
  final String id;
  final String? employeeName;
  final String? employeeCode;
  final String customerName;
  final String mobileNo;
  final String? arnNo;
  final String? bankStatus;
  final String? userStatus;
  final String? userRemarks;
  final String? bankRemarks;
  final DateTime? userStatusDate;
  final bool removeData;
  final DateTime created;
  final DateTime updated;
  final String? dataStatus;
  final bool syncPending;
  const BkycRecord({
    required this.id,
    this.employeeName,
    this.employeeCode,
    required this.customerName,
    required this.mobileNo,
    this.arnNo,
    this.bankStatus,
    this.userStatus,
    this.userRemarks,
    this.bankRemarks,
    this.userStatusDate,
    required this.removeData,
    required this.created,
    required this.updated,
    this.dataStatus,
    required this.syncPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || employeeName != null) {
      map['employee_name'] = Variable<String>(employeeName);
    }
    if (!nullToAbsent || employeeCode != null) {
      map['employee_code'] = Variable<String>(employeeCode);
    }
    map['customer_name'] = Variable<String>(customerName);
    map['mobile_no'] = Variable<String>(mobileNo);
    if (!nullToAbsent || arnNo != null) {
      map['arn_no'] = Variable<String>(arnNo);
    }
    if (!nullToAbsent || bankStatus != null) {
      map['bank_status'] = Variable<String>(bankStatus);
    }
    if (!nullToAbsent || userStatus != null) {
      map['user_status'] = Variable<String>(userStatus);
    }
    if (!nullToAbsent || userRemarks != null) {
      map['user_remarks'] = Variable<String>(userRemarks);
    }
    if (!nullToAbsent || bankRemarks != null) {
      map['bank_remarks'] = Variable<String>(bankRemarks);
    }
    if (!nullToAbsent || userStatusDate != null) {
      map['user_status_date'] = Variable<DateTime>(userStatusDate);
    }
    map['remove_data'] = Variable<bool>(removeData);
    map['created'] = Variable<DateTime>(created);
    map['updated'] = Variable<DateTime>(updated);
    if (!nullToAbsent || dataStatus != null) {
      map['data_status'] = Variable<String>(dataStatus);
    }
    map['sync_pending'] = Variable<bool>(syncPending);
    return map;
  }

  BkycRecordsCompanion toCompanion(bool nullToAbsent) {
    return BkycRecordsCompanion(
      id: Value(id),
      employeeName: employeeName == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeName),
      employeeCode: employeeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeCode),
      customerName: Value(customerName),
      mobileNo: Value(mobileNo),
      arnNo: arnNo == null && nullToAbsent
          ? const Value.absent()
          : Value(arnNo),
      bankStatus: bankStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(bankStatus),
      userStatus: userStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(userStatus),
      userRemarks: userRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(userRemarks),
      bankRemarks: bankRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(bankRemarks),
      userStatusDate: userStatusDate == null && nullToAbsent
          ? const Value.absent()
          : Value(userStatusDate),
      removeData: Value(removeData),
      created: Value(created),
      updated: Value(updated),
      dataStatus: dataStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(dataStatus),
      syncPending: Value(syncPending),
    );
  }

  factory BkycRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BkycRecord(
      id: serializer.fromJson<String>(json['id']),
      employeeName: serializer.fromJson<String?>(json['employeeName']),
      employeeCode: serializer.fromJson<String?>(json['employeeCode']),
      customerName: serializer.fromJson<String>(json['customerName']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      arnNo: serializer.fromJson<String?>(json['arnNo']),
      bankStatus: serializer.fromJson<String?>(json['bankStatus']),
      userStatus: serializer.fromJson<String?>(json['userStatus']),
      userRemarks: serializer.fromJson<String?>(json['userRemarks']),
      bankRemarks: serializer.fromJson<String?>(json['bankRemarks']),
      userStatusDate: serializer.fromJson<DateTime?>(json['userStatusDate']),
      removeData: serializer.fromJson<bool>(json['removeData']),
      created: serializer.fromJson<DateTime>(json['created']),
      updated: serializer.fromJson<DateTime>(json['updated']),
      dataStatus: serializer.fromJson<String?>(json['dataStatus']),
      syncPending: serializer.fromJson<bool>(json['syncPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeName': serializer.toJson<String?>(employeeName),
      'employeeCode': serializer.toJson<String?>(employeeCode),
      'customerName': serializer.toJson<String>(customerName),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'arnNo': serializer.toJson<String?>(arnNo),
      'bankStatus': serializer.toJson<String?>(bankStatus),
      'userStatus': serializer.toJson<String?>(userStatus),
      'userRemarks': serializer.toJson<String?>(userRemarks),
      'bankRemarks': serializer.toJson<String?>(bankRemarks),
      'userStatusDate': serializer.toJson<DateTime?>(userStatusDate),
      'removeData': serializer.toJson<bool>(removeData),
      'created': serializer.toJson<DateTime>(created),
      'updated': serializer.toJson<DateTime>(updated),
      'dataStatus': serializer.toJson<String?>(dataStatus),
      'syncPending': serializer.toJson<bool>(syncPending),
    };
  }

  BkycRecord copyWith({
    String? id,
    Value<String?> employeeName = const Value.absent(),
    Value<String?> employeeCode = const Value.absent(),
    String? customerName,
    String? mobileNo,
    Value<String?> arnNo = const Value.absent(),
    Value<String?> bankStatus = const Value.absent(),
    Value<String?> userStatus = const Value.absent(),
    Value<String?> userRemarks = const Value.absent(),
    Value<String?> bankRemarks = const Value.absent(),
    Value<DateTime?> userStatusDate = const Value.absent(),
    bool? removeData,
    DateTime? created,
    DateTime? updated,
    Value<String?> dataStatus = const Value.absent(),
    bool? syncPending,
  }) => BkycRecord(
    id: id ?? this.id,
    employeeName: employeeName.present ? employeeName.value : this.employeeName,
    employeeCode: employeeCode.present ? employeeCode.value : this.employeeCode,
    customerName: customerName ?? this.customerName,
    mobileNo: mobileNo ?? this.mobileNo,
    arnNo: arnNo.present ? arnNo.value : this.arnNo,
    bankStatus: bankStatus.present ? bankStatus.value : this.bankStatus,
    userStatus: userStatus.present ? userStatus.value : this.userStatus,
    userRemarks: userRemarks.present ? userRemarks.value : this.userRemarks,
    bankRemarks: bankRemarks.present ? bankRemarks.value : this.bankRemarks,
    userStatusDate: userStatusDate.present
        ? userStatusDate.value
        : this.userStatusDate,
    removeData: removeData ?? this.removeData,
    created: created ?? this.created,
    updated: updated ?? this.updated,
    dataStatus: dataStatus.present ? dataStatus.value : this.dataStatus,
    syncPending: syncPending ?? this.syncPending,
  );
  BkycRecord copyWithCompanion(BkycRecordsCompanion data) {
    return BkycRecord(
      id: data.id.present ? data.id.value : this.id,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      arnNo: data.arnNo.present ? data.arnNo.value : this.arnNo,
      bankStatus: data.bankStatus.present
          ? data.bankStatus.value
          : this.bankStatus,
      userStatus: data.userStatus.present
          ? data.userStatus.value
          : this.userStatus,
      userRemarks: data.userRemarks.present
          ? data.userRemarks.value
          : this.userRemarks,
      bankRemarks: data.bankRemarks.present
          ? data.bankRemarks.value
          : this.bankRemarks,
      userStatusDate: data.userStatusDate.present
          ? data.userStatusDate.value
          : this.userStatusDate,
      removeData: data.removeData.present
          ? data.removeData.value
          : this.removeData,
      created: data.created.present ? data.created.value : this.created,
      updated: data.updated.present ? data.updated.value : this.updated,
      dataStatus: data.dataStatus.present
          ? data.dataStatus.value
          : this.dataStatus,
      syncPending: data.syncPending.present
          ? data.syncPending.value
          : this.syncPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BkycRecord(')
          ..write('id: $id, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('arnNo: $arnNo, ')
          ..write('bankStatus: $bankStatus, ')
          ..write('userStatus: $userStatus, ')
          ..write('userRemarks: $userRemarks, ')
          ..write('bankRemarks: $bankRemarks, ')
          ..write('userStatusDate: $userStatusDate, ')
          ..write('removeData: $removeData, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('syncPending: $syncPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeName,
    employeeCode,
    customerName,
    mobileNo,
    arnNo,
    bankStatus,
    userStatus,
    userRemarks,
    bankRemarks,
    userStatusDate,
    removeData,
    created,
    updated,
    dataStatus,
    syncPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BkycRecord &&
          other.id == this.id &&
          other.employeeName == this.employeeName &&
          other.employeeCode == this.employeeCode &&
          other.customerName == this.customerName &&
          other.mobileNo == this.mobileNo &&
          other.arnNo == this.arnNo &&
          other.bankStatus == this.bankStatus &&
          other.userStatus == this.userStatus &&
          other.userRemarks == this.userRemarks &&
          other.bankRemarks == this.bankRemarks &&
          other.userStatusDate == this.userStatusDate &&
          other.removeData == this.removeData &&
          other.created == this.created &&
          other.updated == this.updated &&
          other.dataStatus == this.dataStatus &&
          other.syncPending == this.syncPending);
}

class BkycRecordsCompanion extends UpdateCompanion<BkycRecord> {
  final Value<String> id;
  final Value<String?> employeeName;
  final Value<String?> employeeCode;
  final Value<String> customerName;
  final Value<String> mobileNo;
  final Value<String?> arnNo;
  final Value<String?> bankStatus;
  final Value<String?> userStatus;
  final Value<String?> userRemarks;
  final Value<String?> bankRemarks;
  final Value<DateTime?> userStatusDate;
  final Value<bool> removeData;
  final Value<DateTime> created;
  final Value<DateTime> updated;
  final Value<String?> dataStatus;
  final Value<bool> syncPending;
  final Value<int> rowid;
  const BkycRecordsCompanion({
    this.id = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.customerName = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.bankStatus = const Value.absent(),
    this.userStatus = const Value.absent(),
    this.userRemarks = const Value.absent(),
    this.bankRemarks = const Value.absent(),
    this.userStatusDate = const Value.absent(),
    this.removeData = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.dataStatus = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BkycRecordsCompanion.insert({
    required String id,
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    required String customerName,
    required String mobileNo,
    this.arnNo = const Value.absent(),
    this.bankStatus = const Value.absent(),
    this.userStatus = const Value.absent(),
    this.userRemarks = const Value.absent(),
    this.bankRemarks = const Value.absent(),
    this.userStatusDate = const Value.absent(),
    this.removeData = const Value.absent(),
    required DateTime created,
    required DateTime updated,
    this.dataStatus = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       mobileNo = Value(mobileNo),
       created = Value(created),
       updated = Value(updated);
  static Insertable<BkycRecord> custom({
    Expression<String>? id,
    Expression<String>? employeeName,
    Expression<String>? employeeCode,
    Expression<String>? customerName,
    Expression<String>? mobileNo,
    Expression<String>? arnNo,
    Expression<String>? bankStatus,
    Expression<String>? userStatus,
    Expression<String>? userRemarks,
    Expression<String>? bankRemarks,
    Expression<DateTime>? userStatusDate,
    Expression<bool>? removeData,
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<String>? dataStatus,
    Expression<bool>? syncPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (arnNo != null) 'arn_no': arnNo,
      if (bankStatus != null) 'bank_status': bankStatus,
      if (userStatus != null) 'user_status': userStatus,
      if (userRemarks != null) 'user_remarks': userRemarks,
      if (bankRemarks != null) 'bank_remarks': bankRemarks,
      if (userStatusDate != null) 'user_status_date': userStatusDate,
      if (removeData != null) 'remove_data': removeData,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (dataStatus != null) 'data_status': dataStatus,
      if (syncPending != null) 'sync_pending': syncPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BkycRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? employeeName,
    Value<String?>? employeeCode,
    Value<String>? customerName,
    Value<String>? mobileNo,
    Value<String?>? arnNo,
    Value<String?>? bankStatus,
    Value<String?>? userStatus,
    Value<String?>? userRemarks,
    Value<String?>? bankRemarks,
    Value<DateTime?>? userStatusDate,
    Value<bool>? removeData,
    Value<DateTime>? created,
    Value<DateTime>? updated,
    Value<String?>? dataStatus,
    Value<bool>? syncPending,
    Value<int>? rowid,
  }) {
    return BkycRecordsCompanion(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      arnNo: arnNo ?? this.arnNo,
      bankStatus: bankStatus ?? this.bankStatus,
      userStatus: userStatus ?? this.userStatus,
      userRemarks: userRemarks ?? this.userRemarks,
      bankRemarks: bankRemarks ?? this.bankRemarks,
      userStatusDate: userStatusDate ?? this.userStatusDate,
      removeData: removeData ?? this.removeData,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      dataStatus: dataStatus ?? this.dataStatus,
      syncPending: syncPending ?? this.syncPending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (arnNo.present) {
      map['arn_no'] = Variable<String>(arnNo.value);
    }
    if (bankStatus.present) {
      map['bank_status'] = Variable<String>(bankStatus.value);
    }
    if (userStatus.present) {
      map['user_status'] = Variable<String>(userStatus.value);
    }
    if (userRemarks.present) {
      map['user_remarks'] = Variable<String>(userRemarks.value);
    }
    if (bankRemarks.present) {
      map['bank_remarks'] = Variable<String>(bankRemarks.value);
    }
    if (userStatusDate.present) {
      map['user_status_date'] = Variable<DateTime>(userStatusDate.value);
    }
    if (removeData.present) {
      map['remove_data'] = Variable<bool>(removeData.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (dataStatus.present) {
      map['data_status'] = Variable<String>(dataStatus.value);
    }
    if (syncPending.present) {
      map['sync_pending'] = Variable<bool>(syncPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BkycRecordsCompanion(')
          ..write('id: $id, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('arnNo: $arnNo, ')
          ..write('bankStatus: $bankStatus, ')
          ..write('userStatus: $userStatus, ')
          ..write('userRemarks: $userRemarks, ')
          ..write('bankRemarks: $bankRemarks, ')
          ..write('userStatusDate: $userStatusDate, ')
          ..write('removeData: $removeData, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('syncPending: $syncPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivationRecordsTable extends ActivationRecords
    with TableInfo<$ActivationRecordsTable, ActivationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeCodeMeta = const VerificationMeta(
    'employeeCode',
  );
  @override
  late final GeneratedColumn<String> employeeCode = GeneratedColumn<String>(
    'employee_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arnNoMeta = const VerificationMeta('arnNo');
  @override
  late final GeneratedColumn<String> arnNo = GeneratedColumn<String>(
    'arn_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionMonthMeta = const VerificationMeta(
    'decisionMonth',
  );
  @override
  late final GeneratedColumn<String> decisionMonth = GeneratedColumn<String>(
    'decision_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionDateMeta = const VerificationMeta(
    'decisionDate',
  );
  @override
  late final GeneratedColumn<DateTime> decisionDate = GeneratedColumn<DateTime>(
    'decision_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankStatusMeta = const VerificationMeta(
    'bankStatus',
  );
  @override
  late final GeneratedColumn<String> bankStatus = GeneratedColumn<String>(
    'bank_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankStatusDateMeta = const VerificationMeta(
    'bankStatusDate',
  );
  @override
  late final GeneratedColumn<DateTime> bankStatusDate =
      GeneratedColumn<DateTime>(
        'bank_status_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _userStatusMeta = const VerificationMeta(
    'userStatus',
  );
  @override
  late final GeneratedColumn<String> userStatus = GeneratedColumn<String>(
    'user_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userStatusDateMeta = const VerificationMeta(
    'userStatusDate',
  );
  @override
  late final GeneratedColumn<DateTime> userStatusDate =
      GeneratedColumn<DateTime>(
        'user_status_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dataStatusMeta = const VerificationMeta(
    'dataStatus',
  );
  @override
  late final GeneratedColumn<String> dataStatus = GeneratedColumn<String>(
    'data_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _removeDataMeta = const VerificationMeta(
    'removeData',
  );
  @override
  late final GeneratedColumn<bool> removeData = GeneratedColumn<bool>(
    'remove_data',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remove_data" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userRemarksMeta = const VerificationMeta(
    'userRemarks',
  );
  @override
  late final GeneratedColumn<String> userRemarks = GeneratedColumn<String>(
    'user_remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followupDateMeta = const VerificationMeta(
    'followupDate',
  );
  @override
  late final GeneratedColumn<DateTime> followupDate = GeneratedColumn<DateTime>(
    'followup_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncPendingMeta = const VerificationMeta(
    'syncPending',
  );
  @override
  late final GeneratedColumn<bool> syncPending = GeneratedColumn<bool>(
    'sync_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeName,
    employeeCode,
    customerName,
    mobileNo,
    arnNo,
    decisionMonth,
    decisionDate,
    bankStatus,
    bankStatusDate,
    userStatus,
    userStatusDate,
    dataStatus,
    removeData,
    userRemarks,
    followupDate,
    created,
    updated,
    syncPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activation_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    }
    if (data.containsKey('employee_code')) {
      context.handle(
        _employeeCodeMeta,
        employeeCode.isAcceptableOrUnknown(
          data['employee_code']!,
          _employeeCodeMeta,
        ),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileNoMeta);
    }
    if (data.containsKey('arn_no')) {
      context.handle(
        _arnNoMeta,
        arnNo.isAcceptableOrUnknown(data['arn_no']!, _arnNoMeta),
      );
    }
    if (data.containsKey('decision_month')) {
      context.handle(
        _decisionMonthMeta,
        decisionMonth.isAcceptableOrUnknown(
          data['decision_month']!,
          _decisionMonthMeta,
        ),
      );
    }
    if (data.containsKey('decision_date')) {
      context.handle(
        _decisionDateMeta,
        decisionDate.isAcceptableOrUnknown(
          data['decision_date']!,
          _decisionDateMeta,
        ),
      );
    }
    if (data.containsKey('bank_status')) {
      context.handle(
        _bankStatusMeta,
        bankStatus.isAcceptableOrUnknown(data['bank_status']!, _bankStatusMeta),
      );
    }
    if (data.containsKey('bank_status_date')) {
      context.handle(
        _bankStatusDateMeta,
        bankStatusDate.isAcceptableOrUnknown(
          data['bank_status_date']!,
          _bankStatusDateMeta,
        ),
      );
    }
    if (data.containsKey('user_status')) {
      context.handle(
        _userStatusMeta,
        userStatus.isAcceptableOrUnknown(data['user_status']!, _userStatusMeta),
      );
    }
    if (data.containsKey('user_status_date')) {
      context.handle(
        _userStatusDateMeta,
        userStatusDate.isAcceptableOrUnknown(
          data['user_status_date']!,
          _userStatusDateMeta,
        ),
      );
    }
    if (data.containsKey('data_status')) {
      context.handle(
        _dataStatusMeta,
        dataStatus.isAcceptableOrUnknown(data['data_status']!, _dataStatusMeta),
      );
    }
    if (data.containsKey('remove_data')) {
      context.handle(
        _removeDataMeta,
        removeData.isAcceptableOrUnknown(data['remove_data']!, _removeDataMeta),
      );
    }
    if (data.containsKey('user_remarks')) {
      context.handle(
        _userRemarksMeta,
        userRemarks.isAcceptableOrUnknown(
          data['user_remarks']!,
          _userRemarksMeta,
        ),
      );
    }
    if (data.containsKey('followup_date')) {
      context.handle(
        _followupDateMeta,
        followupDate.isAcceptableOrUnknown(
          data['followup_date']!,
          _followupDateMeta,
        ),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedMeta);
    }
    if (data.containsKey('sync_pending')) {
      context.handle(
        _syncPendingMeta,
        syncPending.isAcceptableOrUnknown(
          data['sync_pending']!,
          _syncPendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      ),
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      mobileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_no'],
      )!,
      arnNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arn_no'],
      ),
      decisionMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_month'],
      ),
      decisionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decision_date'],
      ),
      bankStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_status'],
      ),
      bankStatusDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bank_status_date'],
      ),
      userStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_status'],
      ),
      userStatusDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}user_status_date'],
      ),
      dataStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_status'],
      ),
      removeData: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remove_data'],
      )!,
      userRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_remarks'],
      ),
      followupDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}followup_date'],
      ),
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      )!,
      syncPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_pending'],
      )!,
    );
  }

  @override
  $ActivationRecordsTable createAlias(String alias) {
    return $ActivationRecordsTable(attachedDatabase, alias);
  }
}

class ActivationRecord extends DataClass
    implements Insertable<ActivationRecord> {
  final String id;
  final String? employeeName;
  final String? employeeCode;
  final String customerName;
  final String mobileNo;
  final String? arnNo;
  final String? decisionMonth;
  final DateTime? decisionDate;
  final String? bankStatus;
  final DateTime? bankStatusDate;
  final String? userStatus;
  final DateTime? userStatusDate;
  final String? dataStatus;
  final bool removeData;
  final String? userRemarks;
  final DateTime? followupDate;
  final DateTime created;
  final DateTime updated;
  final bool syncPending;
  const ActivationRecord({
    required this.id,
    this.employeeName,
    this.employeeCode,
    required this.customerName,
    required this.mobileNo,
    this.arnNo,
    this.decisionMonth,
    this.decisionDate,
    this.bankStatus,
    this.bankStatusDate,
    this.userStatus,
    this.userStatusDate,
    this.dataStatus,
    required this.removeData,
    this.userRemarks,
    this.followupDate,
    required this.created,
    required this.updated,
    required this.syncPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || employeeName != null) {
      map['employee_name'] = Variable<String>(employeeName);
    }
    if (!nullToAbsent || employeeCode != null) {
      map['employee_code'] = Variable<String>(employeeCode);
    }
    map['customer_name'] = Variable<String>(customerName);
    map['mobile_no'] = Variable<String>(mobileNo);
    if (!nullToAbsent || arnNo != null) {
      map['arn_no'] = Variable<String>(arnNo);
    }
    if (!nullToAbsent || decisionMonth != null) {
      map['decision_month'] = Variable<String>(decisionMonth);
    }
    if (!nullToAbsent || decisionDate != null) {
      map['decision_date'] = Variable<DateTime>(decisionDate);
    }
    if (!nullToAbsent || bankStatus != null) {
      map['bank_status'] = Variable<String>(bankStatus);
    }
    if (!nullToAbsent || bankStatusDate != null) {
      map['bank_status_date'] = Variable<DateTime>(bankStatusDate);
    }
    if (!nullToAbsent || userStatus != null) {
      map['user_status'] = Variable<String>(userStatus);
    }
    if (!nullToAbsent || userStatusDate != null) {
      map['user_status_date'] = Variable<DateTime>(userStatusDate);
    }
    if (!nullToAbsent || dataStatus != null) {
      map['data_status'] = Variable<String>(dataStatus);
    }
    map['remove_data'] = Variable<bool>(removeData);
    if (!nullToAbsent || userRemarks != null) {
      map['user_remarks'] = Variable<String>(userRemarks);
    }
    if (!nullToAbsent || followupDate != null) {
      map['followup_date'] = Variable<DateTime>(followupDate);
    }
    map['created'] = Variable<DateTime>(created);
    map['updated'] = Variable<DateTime>(updated);
    map['sync_pending'] = Variable<bool>(syncPending);
    return map;
  }

  ActivationRecordsCompanion toCompanion(bool nullToAbsent) {
    return ActivationRecordsCompanion(
      id: Value(id),
      employeeName: employeeName == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeName),
      employeeCode: employeeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeCode),
      customerName: Value(customerName),
      mobileNo: Value(mobileNo),
      arnNo: arnNo == null && nullToAbsent
          ? const Value.absent()
          : Value(arnNo),
      decisionMonth: decisionMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionMonth),
      decisionDate: decisionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionDate),
      bankStatus: bankStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(bankStatus),
      bankStatusDate: bankStatusDate == null && nullToAbsent
          ? const Value.absent()
          : Value(bankStatusDate),
      userStatus: userStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(userStatus),
      userStatusDate: userStatusDate == null && nullToAbsent
          ? const Value.absent()
          : Value(userStatusDate),
      dataStatus: dataStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(dataStatus),
      removeData: Value(removeData),
      userRemarks: userRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(userRemarks),
      followupDate: followupDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followupDate),
      created: Value(created),
      updated: Value(updated),
      syncPending: Value(syncPending),
    );
  }

  factory ActivationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivationRecord(
      id: serializer.fromJson<String>(json['id']),
      employeeName: serializer.fromJson<String?>(json['employeeName']),
      employeeCode: serializer.fromJson<String?>(json['employeeCode']),
      customerName: serializer.fromJson<String>(json['customerName']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      arnNo: serializer.fromJson<String?>(json['arnNo']),
      decisionMonth: serializer.fromJson<String?>(json['decisionMonth']),
      decisionDate: serializer.fromJson<DateTime?>(json['decisionDate']),
      bankStatus: serializer.fromJson<String?>(json['bankStatus']),
      bankStatusDate: serializer.fromJson<DateTime?>(json['bankStatusDate']),
      userStatus: serializer.fromJson<String?>(json['userStatus']),
      userStatusDate: serializer.fromJson<DateTime?>(json['userStatusDate']),
      dataStatus: serializer.fromJson<String?>(json['dataStatus']),
      removeData: serializer.fromJson<bool>(json['removeData']),
      userRemarks: serializer.fromJson<String?>(json['userRemarks']),
      followupDate: serializer.fromJson<DateTime?>(json['followupDate']),
      created: serializer.fromJson<DateTime>(json['created']),
      updated: serializer.fromJson<DateTime>(json['updated']),
      syncPending: serializer.fromJson<bool>(json['syncPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeName': serializer.toJson<String?>(employeeName),
      'employeeCode': serializer.toJson<String?>(employeeCode),
      'customerName': serializer.toJson<String>(customerName),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'arnNo': serializer.toJson<String?>(arnNo),
      'decisionMonth': serializer.toJson<String?>(decisionMonth),
      'decisionDate': serializer.toJson<DateTime?>(decisionDate),
      'bankStatus': serializer.toJson<String?>(bankStatus),
      'bankStatusDate': serializer.toJson<DateTime?>(bankStatusDate),
      'userStatus': serializer.toJson<String?>(userStatus),
      'userStatusDate': serializer.toJson<DateTime?>(userStatusDate),
      'dataStatus': serializer.toJson<String?>(dataStatus),
      'removeData': serializer.toJson<bool>(removeData),
      'userRemarks': serializer.toJson<String?>(userRemarks),
      'followupDate': serializer.toJson<DateTime?>(followupDate),
      'created': serializer.toJson<DateTime>(created),
      'updated': serializer.toJson<DateTime>(updated),
      'syncPending': serializer.toJson<bool>(syncPending),
    };
  }

  ActivationRecord copyWith({
    String? id,
    Value<String?> employeeName = const Value.absent(),
    Value<String?> employeeCode = const Value.absent(),
    String? customerName,
    String? mobileNo,
    Value<String?> arnNo = const Value.absent(),
    Value<String?> decisionMonth = const Value.absent(),
    Value<DateTime?> decisionDate = const Value.absent(),
    Value<String?> bankStatus = const Value.absent(),
    Value<DateTime?> bankStatusDate = const Value.absent(),
    Value<String?> userStatus = const Value.absent(),
    Value<DateTime?> userStatusDate = const Value.absent(),
    Value<String?> dataStatus = const Value.absent(),
    bool? removeData,
    Value<String?> userRemarks = const Value.absent(),
    Value<DateTime?> followupDate = const Value.absent(),
    DateTime? created,
    DateTime? updated,
    bool? syncPending,
  }) => ActivationRecord(
    id: id ?? this.id,
    employeeName: employeeName.present ? employeeName.value : this.employeeName,
    employeeCode: employeeCode.present ? employeeCode.value : this.employeeCode,
    customerName: customerName ?? this.customerName,
    mobileNo: mobileNo ?? this.mobileNo,
    arnNo: arnNo.present ? arnNo.value : this.arnNo,
    decisionMonth: decisionMonth.present
        ? decisionMonth.value
        : this.decisionMonth,
    decisionDate: decisionDate.present ? decisionDate.value : this.decisionDate,
    bankStatus: bankStatus.present ? bankStatus.value : this.bankStatus,
    bankStatusDate: bankStatusDate.present
        ? bankStatusDate.value
        : this.bankStatusDate,
    userStatus: userStatus.present ? userStatus.value : this.userStatus,
    userStatusDate: userStatusDate.present
        ? userStatusDate.value
        : this.userStatusDate,
    dataStatus: dataStatus.present ? dataStatus.value : this.dataStatus,
    removeData: removeData ?? this.removeData,
    userRemarks: userRemarks.present ? userRemarks.value : this.userRemarks,
    followupDate: followupDate.present ? followupDate.value : this.followupDate,
    created: created ?? this.created,
    updated: updated ?? this.updated,
    syncPending: syncPending ?? this.syncPending,
  );
  ActivationRecord copyWithCompanion(ActivationRecordsCompanion data) {
    return ActivationRecord(
      id: data.id.present ? data.id.value : this.id,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      arnNo: data.arnNo.present ? data.arnNo.value : this.arnNo,
      decisionMonth: data.decisionMonth.present
          ? data.decisionMonth.value
          : this.decisionMonth,
      decisionDate: data.decisionDate.present
          ? data.decisionDate.value
          : this.decisionDate,
      bankStatus: data.bankStatus.present
          ? data.bankStatus.value
          : this.bankStatus,
      bankStatusDate: data.bankStatusDate.present
          ? data.bankStatusDate.value
          : this.bankStatusDate,
      userStatus: data.userStatus.present
          ? data.userStatus.value
          : this.userStatus,
      userStatusDate: data.userStatusDate.present
          ? data.userStatusDate.value
          : this.userStatusDate,
      dataStatus: data.dataStatus.present
          ? data.dataStatus.value
          : this.dataStatus,
      removeData: data.removeData.present
          ? data.removeData.value
          : this.removeData,
      userRemarks: data.userRemarks.present
          ? data.userRemarks.value
          : this.userRemarks,
      followupDate: data.followupDate.present
          ? data.followupDate.value
          : this.followupDate,
      created: data.created.present ? data.created.value : this.created,
      updated: data.updated.present ? data.updated.value : this.updated,
      syncPending: data.syncPending.present
          ? data.syncPending.value
          : this.syncPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivationRecord(')
          ..write('id: $id, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('arnNo: $arnNo, ')
          ..write('decisionMonth: $decisionMonth, ')
          ..write('decisionDate: $decisionDate, ')
          ..write('bankStatus: $bankStatus, ')
          ..write('bankStatusDate: $bankStatusDate, ')
          ..write('userStatus: $userStatus, ')
          ..write('userStatusDate: $userStatusDate, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('removeData: $removeData, ')
          ..write('userRemarks: $userRemarks, ')
          ..write('followupDate: $followupDate, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncPending: $syncPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeName,
    employeeCode,
    customerName,
    mobileNo,
    arnNo,
    decisionMonth,
    decisionDate,
    bankStatus,
    bankStatusDate,
    userStatus,
    userStatusDate,
    dataStatus,
    removeData,
    userRemarks,
    followupDate,
    created,
    updated,
    syncPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivationRecord &&
          other.id == this.id &&
          other.employeeName == this.employeeName &&
          other.employeeCode == this.employeeCode &&
          other.customerName == this.customerName &&
          other.mobileNo == this.mobileNo &&
          other.arnNo == this.arnNo &&
          other.decisionMonth == this.decisionMonth &&
          other.decisionDate == this.decisionDate &&
          other.bankStatus == this.bankStatus &&
          other.bankStatusDate == this.bankStatusDate &&
          other.userStatus == this.userStatus &&
          other.userStatusDate == this.userStatusDate &&
          other.dataStatus == this.dataStatus &&
          other.removeData == this.removeData &&
          other.userRemarks == this.userRemarks &&
          other.followupDate == this.followupDate &&
          other.created == this.created &&
          other.updated == this.updated &&
          other.syncPending == this.syncPending);
}

class ActivationRecordsCompanion extends UpdateCompanion<ActivationRecord> {
  final Value<String> id;
  final Value<String?> employeeName;
  final Value<String?> employeeCode;
  final Value<String> customerName;
  final Value<String> mobileNo;
  final Value<String?> arnNo;
  final Value<String?> decisionMonth;
  final Value<DateTime?> decisionDate;
  final Value<String?> bankStatus;
  final Value<DateTime?> bankStatusDate;
  final Value<String?> userStatus;
  final Value<DateTime?> userStatusDate;
  final Value<String?> dataStatus;
  final Value<bool> removeData;
  final Value<String?> userRemarks;
  final Value<DateTime?> followupDate;
  final Value<DateTime> created;
  final Value<DateTime> updated;
  final Value<bool> syncPending;
  final Value<int> rowid;
  const ActivationRecordsCompanion({
    this.id = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.customerName = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.arnNo = const Value.absent(),
    this.decisionMonth = const Value.absent(),
    this.decisionDate = const Value.absent(),
    this.bankStatus = const Value.absent(),
    this.bankStatusDate = const Value.absent(),
    this.userStatus = const Value.absent(),
    this.userStatusDate = const Value.absent(),
    this.dataStatus = const Value.absent(),
    this.removeData = const Value.absent(),
    this.userRemarks = const Value.absent(),
    this.followupDate = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivationRecordsCompanion.insert({
    required String id,
    this.employeeName = const Value.absent(),
    this.employeeCode = const Value.absent(),
    required String customerName,
    required String mobileNo,
    this.arnNo = const Value.absent(),
    this.decisionMonth = const Value.absent(),
    this.decisionDate = const Value.absent(),
    this.bankStatus = const Value.absent(),
    this.bankStatusDate = const Value.absent(),
    this.userStatus = const Value.absent(),
    this.userStatusDate = const Value.absent(),
    this.dataStatus = const Value.absent(),
    this.removeData = const Value.absent(),
    this.userRemarks = const Value.absent(),
    this.followupDate = const Value.absent(),
    required DateTime created,
    required DateTime updated,
    this.syncPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       mobileNo = Value(mobileNo),
       created = Value(created),
       updated = Value(updated);
  static Insertable<ActivationRecord> custom({
    Expression<String>? id,
    Expression<String>? employeeName,
    Expression<String>? employeeCode,
    Expression<String>? customerName,
    Expression<String>? mobileNo,
    Expression<String>? arnNo,
    Expression<String>? decisionMonth,
    Expression<DateTime>? decisionDate,
    Expression<String>? bankStatus,
    Expression<DateTime>? bankStatusDate,
    Expression<String>? userStatus,
    Expression<DateTime>? userStatusDate,
    Expression<String>? dataStatus,
    Expression<bool>? removeData,
    Expression<String>? userRemarks,
    Expression<DateTime>? followupDate,
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<bool>? syncPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (customerName != null) 'customer_name': customerName,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (arnNo != null) 'arn_no': arnNo,
      if (decisionMonth != null) 'decision_month': decisionMonth,
      if (decisionDate != null) 'decision_date': decisionDate,
      if (bankStatus != null) 'bank_status': bankStatus,
      if (bankStatusDate != null) 'bank_status_date': bankStatusDate,
      if (userStatus != null) 'user_status': userStatus,
      if (userStatusDate != null) 'user_status_date': userStatusDate,
      if (dataStatus != null) 'data_status': dataStatus,
      if (removeData != null) 'remove_data': removeData,
      if (userRemarks != null) 'user_remarks': userRemarks,
      if (followupDate != null) 'followup_date': followupDate,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (syncPending != null) 'sync_pending': syncPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? employeeName,
    Value<String?>? employeeCode,
    Value<String>? customerName,
    Value<String>? mobileNo,
    Value<String?>? arnNo,
    Value<String?>? decisionMonth,
    Value<DateTime?>? decisionDate,
    Value<String?>? bankStatus,
    Value<DateTime?>? bankStatusDate,
    Value<String?>? userStatus,
    Value<DateTime?>? userStatusDate,
    Value<String?>? dataStatus,
    Value<bool>? removeData,
    Value<String?>? userRemarks,
    Value<DateTime?>? followupDate,
    Value<DateTime>? created,
    Value<DateTime>? updated,
    Value<bool>? syncPending,
    Value<int>? rowid,
  }) {
    return ActivationRecordsCompanion(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      arnNo: arnNo ?? this.arnNo,
      decisionMonth: decisionMonth ?? this.decisionMonth,
      decisionDate: decisionDate ?? this.decisionDate,
      bankStatus: bankStatus ?? this.bankStatus,
      bankStatusDate: bankStatusDate ?? this.bankStatusDate,
      userStatus: userStatus ?? this.userStatus,
      userStatusDate: userStatusDate ?? this.userStatusDate,
      dataStatus: dataStatus ?? this.dataStatus,
      removeData: removeData ?? this.removeData,
      userRemarks: userRemarks ?? this.userRemarks,
      followupDate: followupDate ?? this.followupDate,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      syncPending: syncPending ?? this.syncPending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (arnNo.present) {
      map['arn_no'] = Variable<String>(arnNo.value);
    }
    if (decisionMonth.present) {
      map['decision_month'] = Variable<String>(decisionMonth.value);
    }
    if (decisionDate.present) {
      map['decision_date'] = Variable<DateTime>(decisionDate.value);
    }
    if (bankStatus.present) {
      map['bank_status'] = Variable<String>(bankStatus.value);
    }
    if (bankStatusDate.present) {
      map['bank_status_date'] = Variable<DateTime>(bankStatusDate.value);
    }
    if (userStatus.present) {
      map['user_status'] = Variable<String>(userStatus.value);
    }
    if (userStatusDate.present) {
      map['user_status_date'] = Variable<DateTime>(userStatusDate.value);
    }
    if (dataStatus.present) {
      map['data_status'] = Variable<String>(dataStatus.value);
    }
    if (removeData.present) {
      map['remove_data'] = Variable<bool>(removeData.value);
    }
    if (userRemarks.present) {
      map['user_remarks'] = Variable<String>(userRemarks.value);
    }
    if (followupDate.present) {
      map['followup_date'] = Variable<DateTime>(followupDate.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (syncPending.present) {
      map['sync_pending'] = Variable<bool>(syncPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('employeeName: $employeeName, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('customerName: $customerName, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('arnNo: $arnNo, ')
          ..write('decisionMonth: $decisionMonth, ')
          ..write('decisionDate: $decisionDate, ')
          ..write('bankStatus: $bankStatus, ')
          ..write('bankStatusDate: $bankStatusDate, ')
          ..write('userStatus: $userStatus, ')
          ..write('userStatusDate: $userStatusDate, ')
          ..write('dataStatus: $dataStatus, ')
          ..write('removeData: $removeData, ')
          ..write('userRemarks: $userRemarks, ')
          ..write('followupDate: $followupDate, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncPending: $syncPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LeadsTable leads = $LeadsTable(this);
  late final $CallLogsTable callLogs = $CallLogsTable(this);
  late final $LoginCasesTable loginCases = $LoginCasesTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $LeaveRequestsTable leaveRequests = $LeaveRequestsTable(this);
  late final $HolidaysTable holidays = $HolidaysTable(this);
  late final $LeadFeedbackTable leadFeedback = $LeadFeedbackTable(this);
  late final $ApplyLinksTable applyLinks = $ApplyLinksTable(this);
  late final $VkycRecordsTable vkycRecords = $VkycRecordsTable(this);
  late final $BkycRecordsTable bkycRecords = $BkycRecordsTable(this);
  late final $ActivationRecordsTable activationRecords =
      $ActivationRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    leads,
    callLogs,
    loginCases,
    attendance,
    leaveRequests,
    holidays,
    leadFeedback,
    applyLinks,
    vkycRecords,
    bkycRecords,
    activationRecords,
  ];
}

typedef $$LeadsTableCreateCompanionBuilder =
    LeadsCompanion Function({
      required String id,
      required String customerName,
      required String mobileNo,
      Value<String?> city,
      Value<String?> segment,
      Value<String?> employer,
      Value<String?> declineReason,
      Value<String?> product,
      Value<String?> assignedTo,
      required DateTime assignedDate,
      Value<String?> employeeName,
      Value<String?> employeeCode,
      required String leadStatus,
      required DateTime leadStatusDate,
      Value<String?> dataStatus,
      Value<DateTime?> followupTime,
      Value<String?> arnNo,
      Value<DateTime?> dateOfBirth,
      Value<String?> remarks,
      Value<bool> syncPending,
      Value<int> rowid,
    });
typedef $$LeadsTableUpdateCompanionBuilder =
    LeadsCompanion Function({
      Value<String> id,
      Value<String> customerName,
      Value<String> mobileNo,
      Value<String?> city,
      Value<String?> segment,
      Value<String?> employer,
      Value<String?> declineReason,
      Value<String?> product,
      Value<String?> assignedTo,
      Value<DateTime> assignedDate,
      Value<String?> employeeName,
      Value<String?> employeeCode,
      Value<String> leadStatus,
      Value<DateTime> leadStatusDate,
      Value<String?> dataStatus,
      Value<DateTime?> followupTime,
      Value<String?> arnNo,
      Value<DateTime?> dateOfBirth,
      Value<String?> remarks,
      Value<bool> syncPending,
      Value<int> rowid,
    });

class $$LeadsTableFilterComposer extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableFilterComposer({
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

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employer => $composableBuilder(
    column: $table.employer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get declineReason => $composableBuilder(
    column: $table.declineReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedDate => $composableBuilder(
    column: $table.assignedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followupTime => $composableBuilder(
    column: $table.followupTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeadsTableOrderingComposer
    extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableOrderingComposer({
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

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employer => $composableBuilder(
    column: $table.employer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get declineReason => $composableBuilder(
    column: $table.declineReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedDate => $composableBuilder(
    column: $table.assignedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followupTime => $composableBuilder(
    column: $table.followupTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get segment =>
      $composableBuilder(column: $table.segment, builder: (column) => column);

  GeneratedColumn<String> get employer =>
      $composableBuilder(column: $table.employer, builder: (column) => column);

  GeneratedColumn<String> get declineReason => $composableBuilder(
    column: $table.declineReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get product =>
      $composableBuilder(column: $table.product, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assignedDate => $composableBuilder(
    column: $table.assignedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get followupTime => $composableBuilder(
    column: $table.followupTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arnNo =>
      $composableBuilder(column: $table.arnNo, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => column,
  );
}

class $$LeadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeadsTable,
          Lead,
          $$LeadsTableFilterComposer,
          $$LeadsTableOrderingComposer,
          $$LeadsTableAnnotationComposer,
          $$LeadsTableCreateCompanionBuilder,
          $$LeadsTableUpdateCompanionBuilder,
          (Lead, BaseReferences<_$AppDatabase, $LeadsTable, Lead>),
          Lead,
          PrefetchHooks Function()
        > {
  $$LeadsTableTableManager(_$AppDatabase db, $LeadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> segment = const Value.absent(),
                Value<String?> employer = const Value.absent(),
                Value<String?> declineReason = const Value.absent(),
                Value<String?> product = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<DateTime> assignedDate = const Value.absent(),
                Value<String?> employeeName = const Value.absent(),
                Value<String?> employeeCode = const Value.absent(),
                Value<String> leadStatus = const Value.absent(),
                Value<DateTime> leadStatusDate = const Value.absent(),
                Value<String?> dataStatus = const Value.absent(),
                Value<DateTime?> followupTime = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadsCompanion(
                id: id,
                customerName: customerName,
                mobileNo: mobileNo,
                city: city,
                segment: segment,
                employer: employer,
                declineReason: declineReason,
                product: product,
                assignedTo: assignedTo,
                assignedDate: assignedDate,
                employeeName: employeeName,
                employeeCode: employeeCode,
                leadStatus: leadStatus,
                leadStatusDate: leadStatusDate,
                dataStatus: dataStatus,
                followupTime: followupTime,
                arnNo: arnNo,
                dateOfBirth: dateOfBirth,
                remarks: remarks,
                syncPending: syncPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerName,
                required String mobileNo,
                Value<String?> city = const Value.absent(),
                Value<String?> segment = const Value.absent(),
                Value<String?> employer = const Value.absent(),
                Value<String?> declineReason = const Value.absent(),
                Value<String?> product = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                required DateTime assignedDate,
                Value<String?> employeeName = const Value.absent(),
                Value<String?> employeeCode = const Value.absent(),
                required String leadStatus,
                required DateTime leadStatusDate,
                Value<String?> dataStatus = const Value.absent(),
                Value<DateTime?> followupTime = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadsCompanion.insert(
                id: id,
                customerName: customerName,
                mobileNo: mobileNo,
                city: city,
                segment: segment,
                employer: employer,
                declineReason: declineReason,
                product: product,
                assignedTo: assignedTo,
                assignedDate: assignedDate,
                employeeName: employeeName,
                employeeCode: employeeCode,
                leadStatus: leadStatus,
                leadStatusDate: leadStatusDate,
                dataStatus: dataStatus,
                followupTime: followupTime,
                arnNo: arnNo,
                dateOfBirth: dateOfBirth,
                remarks: remarks,
                syncPending: syncPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeadsTable,
      Lead,
      $$LeadsTableFilterComposer,
      $$LeadsTableOrderingComposer,
      $$LeadsTableAnnotationComposer,
      $$LeadsTableCreateCompanionBuilder,
      $$LeadsTableUpdateCompanionBuilder,
      (Lead, BaseReferences<_$AppDatabase, $LeadsTable, Lead>),
      Lead,
      PrefetchHooks Function()
    >;
typedef $$CallLogsTableCreateCompanionBuilder =
    CallLogsCompanion Function({
      required String id,
      required String leadId,
      required String employeeId,
      required String employeeCode,
      required String employeeName,
      required String phoneNumber,
      required DateTime callTimestamp,
      required int callDuration,
      required int ringDuration,
      Value<int> sessionDuration,
      required String callType,
      required String callStatus,
      Value<bool> isSynced,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CallLogsTableUpdateCompanionBuilder =
    CallLogsCompanion Function({
      Value<String> id,
      Value<String> leadId,
      Value<String> employeeId,
      Value<String> employeeCode,
      Value<String> employeeName,
      Value<String> phoneNumber,
      Value<DateTime> callTimestamp,
      Value<int> callDuration,
      Value<int> ringDuration,
      Value<int> sessionDuration,
      Value<String> callType,
      Value<String> callStatus,
      Value<bool> isSynced,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CallLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableFilterComposer({
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

  ColumnFilters<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get callTimestamp => $composableBuilder(
    column: $table.callTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callDuration => $composableBuilder(
    column: $table.callDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ringDuration => $composableBuilder(
    column: $table.ringDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionDuration => $composableBuilder(
    column: $table.sessionDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callStatus => $composableBuilder(
    column: $table.callStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableOrderingComposer({
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

  ColumnOrderings<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get callTimestamp => $composableBuilder(
    column: $table.callTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callDuration => $composableBuilder(
    column: $table.callDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ringDuration => $composableBuilder(
    column: $table.ringDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionDuration => $composableBuilder(
    column: $table.sessionDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callStatus => $composableBuilder(
    column: $table.callStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallLogsTable> {
  $$CallLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get callTimestamp => $composableBuilder(
    column: $table.callTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get callDuration => $composableBuilder(
    column: $table.callDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ringDuration => $composableBuilder(
    column: $table.ringDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionDuration => $composableBuilder(
    column: $table.sessionDuration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callType =>
      $composableBuilder(column: $table.callType, builder: (column) => column);

  GeneratedColumn<String> get callStatus => $composableBuilder(
    column: $table.callStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CallLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallLogsTable,
          CallLog,
          $$CallLogsTableFilterComposer,
          $$CallLogsTableOrderingComposer,
          $$CallLogsTableAnnotationComposer,
          $$CallLogsTableCreateCompanionBuilder,
          $$CallLogsTableUpdateCompanionBuilder,
          (CallLog, BaseReferences<_$AppDatabase, $CallLogsTable, CallLog>),
          CallLog,
          PrefetchHooks Function()
        > {
  $$CallLogsTableTableManager(_$AppDatabase db, $CallLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> leadId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<DateTime> callTimestamp = const Value.absent(),
                Value<int> callDuration = const Value.absent(),
                Value<int> ringDuration = const Value.absent(),
                Value<int> sessionDuration = const Value.absent(),
                Value<String> callType = const Value.absent(),
                Value<String> callStatus = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallLogsCompanion(
                id: id,
                leadId: leadId,
                employeeId: employeeId,
                employeeCode: employeeCode,
                employeeName: employeeName,
                phoneNumber: phoneNumber,
                callTimestamp: callTimestamp,
                callDuration: callDuration,
                ringDuration: ringDuration,
                sessionDuration: sessionDuration,
                callType: callType,
                callStatus: callStatus,
                isSynced: isSynced,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String leadId,
                required String employeeId,
                required String employeeCode,
                required String employeeName,
                required String phoneNumber,
                required DateTime callTimestamp,
                required int callDuration,
                required int ringDuration,
                Value<int> sessionDuration = const Value.absent(),
                required String callType,
                required String callStatus,
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallLogsCompanion.insert(
                id: id,
                leadId: leadId,
                employeeId: employeeId,
                employeeCode: employeeCode,
                employeeName: employeeName,
                phoneNumber: phoneNumber,
                callTimestamp: callTimestamp,
                callDuration: callDuration,
                ringDuration: ringDuration,
                sessionDuration: sessionDuration,
                callType: callType,
                callStatus: callStatus,
                isSynced: isSynced,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallLogsTable,
      CallLog,
      $$CallLogsTableFilterComposer,
      $$CallLogsTableOrderingComposer,
      $$CallLogsTableAnnotationComposer,
      $$CallLogsTableCreateCompanionBuilder,
      $$CallLogsTableUpdateCompanionBuilder,
      (CallLog, BaseReferences<_$AppDatabase, $CallLogsTable, CallLog>),
      CallLog,
      PrefetchHooks Function()
    >;
typedef $$LoginCasesTableCreateCompanionBuilder =
    LoginCasesCompanion Function({
      required String id,
      required String customerName,
      required String mobileNumber,
      required String leadStatus,
      required String employeeName,
      required String employeeCode,
      required DateTime leadStatusDate,
      Value<DateTime?> arnDate,
      Value<String?> arnNo,
      Value<String?> leadId,
      Value<int> rowid,
    });
typedef $$LoginCasesTableUpdateCompanionBuilder =
    LoginCasesCompanion Function({
      Value<String> id,
      Value<String> customerName,
      Value<String> mobileNumber,
      Value<String> leadStatus,
      Value<String> employeeName,
      Value<String> employeeCode,
      Value<DateTime> leadStatusDate,
      Value<DateTime?> arnDate,
      Value<String?> arnNo,
      Value<String?> leadId,
      Value<int> rowid,
    });

class $$LoginCasesTableFilterComposer
    extends Composer<_$AppDatabase, $LoginCasesTable> {
  $$LoginCasesTableFilterComposer({
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

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arnDate => $composableBuilder(
    column: $table.arnDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoginCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $LoginCasesTable> {
  $$LoginCasesTableOrderingComposer({
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

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arnDate => $composableBuilder(
    column: $table.arnDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoginCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoginCasesTable> {
  $$LoginCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get arnDate =>
      $composableBuilder(column: $table.arnDate, builder: (column) => column);

  GeneratedColumn<String> get arnNo =>
      $composableBuilder(column: $table.arnNo, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);
}

class $$LoginCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoginCasesTable,
          LoginCase,
          $$LoginCasesTableFilterComposer,
          $$LoginCasesTableOrderingComposer,
          $$LoginCasesTableAnnotationComposer,
          $$LoginCasesTableCreateCompanionBuilder,
          $$LoginCasesTableUpdateCompanionBuilder,
          (
            LoginCase,
            BaseReferences<_$AppDatabase, $LoginCasesTable, LoginCase>,
          ),
          LoginCase,
          PrefetchHooks Function()
        > {
  $$LoginCasesTableTableManager(_$AppDatabase db, $LoginCasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoginCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoginCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoginCasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> mobileNumber = const Value.absent(),
                Value<String> leadStatus = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<DateTime> leadStatusDate = const Value.absent(),
                Value<DateTime?> arnDate = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<String?> leadId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoginCasesCompanion(
                id: id,
                customerName: customerName,
                mobileNumber: mobileNumber,
                leadStatus: leadStatus,
                employeeName: employeeName,
                employeeCode: employeeCode,
                leadStatusDate: leadStatusDate,
                arnDate: arnDate,
                arnNo: arnNo,
                leadId: leadId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerName,
                required String mobileNumber,
                required String leadStatus,
                required String employeeName,
                required String employeeCode,
                required DateTime leadStatusDate,
                Value<DateTime?> arnDate = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<String?> leadId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoginCasesCompanion.insert(
                id: id,
                customerName: customerName,
                mobileNumber: mobileNumber,
                leadStatus: leadStatus,
                employeeName: employeeName,
                employeeCode: employeeCode,
                leadStatusDate: leadStatusDate,
                arnDate: arnDate,
                arnNo: arnNo,
                leadId: leadId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoginCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoginCasesTable,
      LoginCase,
      $$LoginCasesTableFilterComposer,
      $$LoginCasesTableOrderingComposer,
      $$LoginCasesTableAnnotationComposer,
      $$LoginCasesTableCreateCompanionBuilder,
      $$LoginCasesTableUpdateCompanionBuilder,
      (LoginCase, BaseReferences<_$AppDatabase, $LoginCasesTable, LoginCase>),
      LoginCase,
      PrefetchHooks Function()
    >;
typedef $$AttendanceTableCreateCompanionBuilder =
    AttendanceCompanion Function({
      required String id,
      required String employeeId,
      required String employeeCode,
      required String employeeName,
      required DateTime attendanceDate,
      required DateTime checkInTime,
      required String checkInSelfie,
      required double checkInLatitude,
      required double checkInLongitude,
      Value<DateTime?> checkOutTime,
      Value<String?> checkOutSelfie,
      Value<double?> checkOutLatitude,
      Value<double?> checkOutLongitude,
      Value<String?> address,
      Value<bool> syncPending,
      Value<String?> status,
      Value<String?> remarks,
      Value<String?> approvalType,
      Value<int> rowid,
    });
typedef $$AttendanceTableUpdateCompanionBuilder =
    AttendanceCompanion Function({
      Value<String> id,
      Value<String> employeeId,
      Value<String> employeeCode,
      Value<String> employeeName,
      Value<DateTime> attendanceDate,
      Value<DateTime> checkInTime,
      Value<String> checkInSelfie,
      Value<double> checkInLatitude,
      Value<double> checkInLongitude,
      Value<DateTime?> checkOutTime,
      Value<String?> checkOutSelfie,
      Value<double?> checkOutLatitude,
      Value<double?> checkOutLongitude,
      Value<String?> address,
      Value<bool> syncPending,
      Value<String?> status,
      Value<String?> remarks,
      Value<String?> approvalType,
      Value<int> rowid,
    });

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
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

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkInTime => $composableBuilder(
    column: $table.checkInTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkInSelfie => $composableBuilder(
    column: $table.checkInSelfie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get checkInLatitude => $composableBuilder(
    column: $table.checkInLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get checkInLongitude => $composableBuilder(
    column: $table.checkInLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkOutTime => $composableBuilder(
    column: $table.checkOutTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkOutSelfie => $composableBuilder(
    column: $table.checkOutSelfie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get checkOutLatitude => $composableBuilder(
    column: $table.checkOutLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get checkOutLongitude => $composableBuilder(
    column: $table.checkOutLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvalType => $composableBuilder(
    column: $table.approvalType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
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

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkInTime => $composableBuilder(
    column: $table.checkInTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkInSelfie => $composableBuilder(
    column: $table.checkInSelfie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get checkInLatitude => $composableBuilder(
    column: $table.checkInLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get checkInLongitude => $composableBuilder(
    column: $table.checkInLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkOutTime => $composableBuilder(
    column: $table.checkOutTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkOutSelfie => $composableBuilder(
    column: $table.checkOutSelfie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get checkOutLatitude => $composableBuilder(
    column: $table.checkOutLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get checkOutLongitude => $composableBuilder(
    column: $table.checkOutLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvalType => $composableBuilder(
    column: $table.approvalType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkInTime => $composableBuilder(
    column: $table.checkInTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkInSelfie => $composableBuilder(
    column: $table.checkInSelfie,
    builder: (column) => column,
  );

  GeneratedColumn<double> get checkInLatitude => $composableBuilder(
    column: $table.checkInLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get checkInLongitude => $composableBuilder(
    column: $table.checkInLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkOutTime => $composableBuilder(
    column: $table.checkOutTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkOutSelfie => $composableBuilder(
    column: $table.checkOutSelfie,
    builder: (column) => column,
  );

  GeneratedColumn<double> get checkOutLatitude => $composableBuilder(
    column: $table.checkOutLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get checkOutLongitude => $composableBuilder(
    column: $table.checkOutLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get approvalType => $composableBuilder(
    column: $table.approvalType,
    builder: (column) => column,
  );
}

class $$AttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceTable,
          AttendanceData,
          $$AttendanceTableFilterComposer,
          $$AttendanceTableOrderingComposer,
          $$AttendanceTableAnnotationComposer,
          $$AttendanceTableCreateCompanionBuilder,
          $$AttendanceTableUpdateCompanionBuilder,
          (
            AttendanceData,
            BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData>,
          ),
          AttendanceData,
          PrefetchHooks Function()
        > {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<DateTime> attendanceDate = const Value.absent(),
                Value<DateTime> checkInTime = const Value.absent(),
                Value<String> checkInSelfie = const Value.absent(),
                Value<double> checkInLatitude = const Value.absent(),
                Value<double> checkInLongitude = const Value.absent(),
                Value<DateTime?> checkOutTime = const Value.absent(),
                Value<String?> checkOutSelfie = const Value.absent(),
                Value<double?> checkOutLatitude = const Value.absent(),
                Value<double?> checkOutLongitude = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> approvalType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceCompanion(
                id: id,
                employeeId: employeeId,
                employeeCode: employeeCode,
                employeeName: employeeName,
                attendanceDate: attendanceDate,
                checkInTime: checkInTime,
                checkInSelfie: checkInSelfie,
                checkInLatitude: checkInLatitude,
                checkInLongitude: checkInLongitude,
                checkOutTime: checkOutTime,
                checkOutSelfie: checkOutSelfie,
                checkOutLatitude: checkOutLatitude,
                checkOutLongitude: checkOutLongitude,
                address: address,
                syncPending: syncPending,
                status: status,
                remarks: remarks,
                approvalType: approvalType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String employeeId,
                required String employeeCode,
                required String employeeName,
                required DateTime attendanceDate,
                required DateTime checkInTime,
                required String checkInSelfie,
                required double checkInLatitude,
                required double checkInLongitude,
                Value<DateTime?> checkOutTime = const Value.absent(),
                Value<String?> checkOutSelfie = const Value.absent(),
                Value<double?> checkOutLatitude = const Value.absent(),
                Value<double?> checkOutLongitude = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> approvalType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceCompanion.insert(
                id: id,
                employeeId: employeeId,
                employeeCode: employeeCode,
                employeeName: employeeName,
                attendanceDate: attendanceDate,
                checkInTime: checkInTime,
                checkInSelfie: checkInSelfie,
                checkInLatitude: checkInLatitude,
                checkInLongitude: checkInLongitude,
                checkOutTime: checkOutTime,
                checkOutSelfie: checkOutSelfie,
                checkOutLatitude: checkOutLatitude,
                checkOutLongitude: checkOutLongitude,
                address: address,
                syncPending: syncPending,
                status: status,
                remarks: remarks,
                approvalType: approvalType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceTable,
      AttendanceData,
      $$AttendanceTableFilterComposer,
      $$AttendanceTableOrderingComposer,
      $$AttendanceTableAnnotationComposer,
      $$AttendanceTableCreateCompanionBuilder,
      $$AttendanceTableUpdateCompanionBuilder,
      (
        AttendanceData,
        BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData>,
      ),
      AttendanceData,
      PrefetchHooks Function()
    >;
typedef $$LeaveRequestsTableCreateCompanionBuilder =
    LeaveRequestsCompanion Function({
      required String id,
      required String employeeId,
      required String employeeCode,
      required String employeeName,
      required String leaveType,
      required DateTime fromDate,
      required DateTime toDate,
      required int daysCount,
      required String reason,
      required String status,
      required DateTime appliedDate,
      Value<bool> syncPending,
      Value<int> rowid,
    });
typedef $$LeaveRequestsTableUpdateCompanionBuilder =
    LeaveRequestsCompanion Function({
      Value<String> id,
      Value<String> employeeId,
      Value<String> employeeCode,
      Value<String> employeeName,
      Value<String> leaveType,
      Value<DateTime> fromDate,
      Value<DateTime> toDate,
      Value<int> daysCount,
      Value<String> reason,
      Value<String> status,
      Value<DateTime> appliedDate,
      Value<bool> syncPending,
      Value<int> rowid,
    });

class $$LeaveRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableFilterComposer({
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

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leaveType => $composableBuilder(
    column: $table.leaveType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysCount => $composableBuilder(
    column: $table.daysCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedDate => $composableBuilder(
    column: $table.appliedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaveRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leaveType => $composableBuilder(
    column: $table.leaveType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysCount => $composableBuilder(
    column: $table.daysCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedDate => $composableBuilder(
    column: $table.appliedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaveRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leaveType =>
      $composableBuilder(column: $table.leaveType, builder: (column) => column);

  GeneratedColumn<DateTime> get fromDate =>
      $composableBuilder(column: $table.fromDate, builder: (column) => column);

  GeneratedColumn<DateTime> get toDate =>
      $composableBuilder(column: $table.toDate, builder: (column) => column);

  GeneratedColumn<int> get daysCount =>
      $composableBuilder(column: $table.daysCount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedDate => $composableBuilder(
    column: $table.appliedDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => column,
  );
}

class $$LeaveRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaveRequestsTable,
          LeaveRequest,
          $$LeaveRequestsTableFilterComposer,
          $$LeaveRequestsTableOrderingComposer,
          $$LeaveRequestsTableAnnotationComposer,
          $$LeaveRequestsTableCreateCompanionBuilder,
          $$LeaveRequestsTableUpdateCompanionBuilder,
          (
            LeaveRequest,
            BaseReferences<_$AppDatabase, $LeaveRequestsTable, LeaveRequest>,
          ),
          LeaveRequest,
          PrefetchHooks Function()
        > {
  $$LeaveRequestsTableTableManager(_$AppDatabase db, $LeaveRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaveRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaveRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeaveRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> leaveType = const Value.absent(),
                Value<DateTime> fromDate = const Value.absent(),
                Value<DateTime> toDate = const Value.absent(),
                Value<int> daysCount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> appliedDate = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaveRequestsCompanion(
                id: id,
                employeeId: employeeId,
                employeeCode: employeeCode,
                employeeName: employeeName,
                leaveType: leaveType,
                fromDate: fromDate,
                toDate: toDate,
                daysCount: daysCount,
                reason: reason,
                status: status,
                appliedDate: appliedDate,
                syncPending: syncPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String employeeId,
                required String employeeCode,
                required String employeeName,
                required String leaveType,
                required DateTime fromDate,
                required DateTime toDate,
                required int daysCount,
                required String reason,
                required String status,
                required DateTime appliedDate,
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaveRequestsCompanion.insert(
                id: id,
                employeeId: employeeId,
                employeeCode: employeeCode,
                employeeName: employeeName,
                leaveType: leaveType,
                fromDate: fromDate,
                toDate: toDate,
                daysCount: daysCount,
                reason: reason,
                status: status,
                appliedDate: appliedDate,
                syncPending: syncPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaveRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaveRequestsTable,
      LeaveRequest,
      $$LeaveRequestsTableFilterComposer,
      $$LeaveRequestsTableOrderingComposer,
      $$LeaveRequestsTableAnnotationComposer,
      $$LeaveRequestsTableCreateCompanionBuilder,
      $$LeaveRequestsTableUpdateCompanionBuilder,
      (
        LeaveRequest,
        BaseReferences<_$AppDatabase, $LeaveRequestsTable, LeaveRequest>,
      ),
      LeaveRequest,
      PrefetchHooks Function()
    >;
typedef $$HolidaysTableCreateCompanionBuilder =
    HolidaysCompanion Function({
      required String id,
      required String holidayName,
      required DateTime holidayDate,
      required bool active,
      Value<int> rowid,
    });
typedef $$HolidaysTableUpdateCompanionBuilder =
    HolidaysCompanion Function({
      Value<String> id,
      Value<String> holidayName,
      Value<DateTime> holidayDate,
      Value<bool> active,
      Value<int> rowid,
    });

class $$HolidaysTableFilterComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableFilterComposer({
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

  ColumnFilters<String> get holidayName => $composableBuilder(
    column: $table.holidayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get holidayDate => $composableBuilder(
    column: $table.holidayDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HolidaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableOrderingComposer({
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

  ColumnOrderings<String> get holidayName => $composableBuilder(
    column: $table.holidayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get holidayDate => $composableBuilder(
    column: $table.holidayDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HolidaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get holidayName => $composableBuilder(
    column: $table.holidayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get holidayDate => $composableBuilder(
    column: $table.holidayDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$HolidaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolidaysTable,
          Holiday,
          $$HolidaysTableFilterComposer,
          $$HolidaysTableOrderingComposer,
          $$HolidaysTableAnnotationComposer,
          $$HolidaysTableCreateCompanionBuilder,
          $$HolidaysTableUpdateCompanionBuilder,
          (Holiday, BaseReferences<_$AppDatabase, $HolidaysTable, Holiday>),
          Holiday,
          PrefetchHooks Function()
        > {
  $$HolidaysTableTableManager(_$AppDatabase db, $HolidaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> holidayName = const Value.absent(),
                Value<DateTime> holidayDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidaysCompanion(
                id: id,
                holidayName: holidayName,
                holidayDate: holidayDate,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String holidayName,
                required DateTime holidayDate,
                required bool active,
                Value<int> rowid = const Value.absent(),
              }) => HolidaysCompanion.insert(
                id: id,
                holidayName: holidayName,
                holidayDate: holidayDate,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HolidaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolidaysTable,
      Holiday,
      $$HolidaysTableFilterComposer,
      $$HolidaysTableOrderingComposer,
      $$HolidaysTableAnnotationComposer,
      $$HolidaysTableCreateCompanionBuilder,
      $$HolidaysTableUpdateCompanionBuilder,
      (Holiday, BaseReferences<_$AppDatabase, $HolidaysTable, Holiday>),
      Holiday,
      PrefetchHooks Function()
    >;
typedef $$LeadFeedbackTableCreateCompanionBuilder =
    LeadFeedbackCompanion Function({
      required String id,
      required String leadId,
      required String customerName,
      required String mobileNo,
      required String leadStatus,
      required DateTime leadStatusDate,
      required DateTime statusUpdateTime,
      required String user,
      required String employeeName,
      required String employeeCode,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LeadFeedbackTableUpdateCompanionBuilder =
    LeadFeedbackCompanion Function({
      Value<String> id,
      Value<String> leadId,
      Value<String> customerName,
      Value<String> mobileNo,
      Value<String> leadStatus,
      Value<DateTime> leadStatusDate,
      Value<DateTime> statusUpdateTime,
      Value<String> user,
      Value<String> employeeName,
      Value<String> employeeCode,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LeadFeedbackTableFilterComposer
    extends Composer<_$AppDatabase, $LeadFeedbackTable> {
  $$LeadFeedbackTableFilterComposer({
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

  ColumnFilters<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statusUpdateTime => $composableBuilder(
    column: $table.statusUpdateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get user => $composableBuilder(
    column: $table.user,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeadFeedbackTableOrderingComposer
    extends Composer<_$AppDatabase, $LeadFeedbackTable> {
  $$LeadFeedbackTableOrderingComposer({
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

  ColumnOrderings<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statusUpdateTime => $composableBuilder(
    column: $table.statusUpdateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get user => $composableBuilder(
    column: $table.user,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeadFeedbackTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeadFeedbackTable> {
  $$LeadFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leadStatusDate => $composableBuilder(
    column: $table.leadStatusDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get statusUpdateTime => $composableBuilder(
    column: $table.statusUpdateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get user =>
      $composableBuilder(column: $table.user, builder: (column) => column);

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LeadFeedbackTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeadFeedbackTable,
          LeadFeedbackData,
          $$LeadFeedbackTableFilterComposer,
          $$LeadFeedbackTableOrderingComposer,
          $$LeadFeedbackTableAnnotationComposer,
          $$LeadFeedbackTableCreateCompanionBuilder,
          $$LeadFeedbackTableUpdateCompanionBuilder,
          (
            LeadFeedbackData,
            BaseReferences<_$AppDatabase, $LeadFeedbackTable, LeadFeedbackData>,
          ),
          LeadFeedbackData,
          PrefetchHooks Function()
        > {
  $$LeadFeedbackTableTableManager(_$AppDatabase db, $LeadFeedbackTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeadFeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeadFeedbackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeadFeedbackTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> leadId = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String> leadStatus = const Value.absent(),
                Value<DateTime> leadStatusDate = const Value.absent(),
                Value<DateTime> statusUpdateTime = const Value.absent(),
                Value<String> user = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadFeedbackCompanion(
                id: id,
                leadId: leadId,
                customerName: customerName,
                mobileNo: mobileNo,
                leadStatus: leadStatus,
                leadStatusDate: leadStatusDate,
                statusUpdateTime: statusUpdateTime,
                user: user,
                employeeName: employeeName,
                employeeCode: employeeCode,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String leadId,
                required String customerName,
                required String mobileNo,
                required String leadStatus,
                required DateTime leadStatusDate,
                required DateTime statusUpdateTime,
                required String user,
                required String employeeName,
                required String employeeCode,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadFeedbackCompanion.insert(
                id: id,
                leadId: leadId,
                customerName: customerName,
                mobileNo: mobileNo,
                leadStatus: leadStatus,
                leadStatusDate: leadStatusDate,
                statusUpdateTime: statusUpdateTime,
                user: user,
                employeeName: employeeName,
                employeeCode: employeeCode,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeadFeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeadFeedbackTable,
      LeadFeedbackData,
      $$LeadFeedbackTableFilterComposer,
      $$LeadFeedbackTableOrderingComposer,
      $$LeadFeedbackTableAnnotationComposer,
      $$LeadFeedbackTableCreateCompanionBuilder,
      $$LeadFeedbackTableUpdateCompanionBuilder,
      (
        LeadFeedbackData,
        BaseReferences<_$AppDatabase, $LeadFeedbackTable, LeadFeedbackData>,
      ),
      LeadFeedbackData,
      PrefetchHooks Function()
    >;
typedef $$ApplyLinksTableCreateCompanionBuilder =
    ApplyLinksCompanion Function({
      required String id,
      required String linkName,
      required String linkUrl,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$ApplyLinksTableUpdateCompanionBuilder =
    ApplyLinksCompanion Function({
      Value<String> id,
      Value<String> linkName,
      Value<String> linkUrl,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$ApplyLinksTableFilterComposer
    extends Composer<_$AppDatabase, $ApplyLinksTable> {
  $$ApplyLinksTableFilterComposer({
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

  ColumnFilters<String> get linkName => $composableBuilder(
    column: $table.linkName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkUrl => $composableBuilder(
    column: $table.linkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApplyLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $ApplyLinksTable> {
  $$ApplyLinksTableOrderingComposer({
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

  ColumnOrderings<String> get linkName => $composableBuilder(
    column: $table.linkName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkUrl => $composableBuilder(
    column: $table.linkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApplyLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApplyLinksTable> {
  $$ApplyLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get linkName =>
      $composableBuilder(column: $table.linkName, builder: (column) => column);

  GeneratedColumn<String> get linkUrl =>
      $composableBuilder(column: $table.linkUrl, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$ApplyLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApplyLinksTable,
          ApplyLink,
          $$ApplyLinksTableFilterComposer,
          $$ApplyLinksTableOrderingComposer,
          $$ApplyLinksTableAnnotationComposer,
          $$ApplyLinksTableCreateCompanionBuilder,
          $$ApplyLinksTableUpdateCompanionBuilder,
          (
            ApplyLink,
            BaseReferences<_$AppDatabase, $ApplyLinksTable, ApplyLink>,
          ),
          ApplyLink,
          PrefetchHooks Function()
        > {
  $$ApplyLinksTableTableManager(_$AppDatabase db, $ApplyLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplyLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplyLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApplyLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> linkName = const Value.absent(),
                Value<String> linkUrl = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApplyLinksCompanion(
                id: id,
                linkName: linkName,
                linkUrl: linkUrl,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String linkName,
                required String linkUrl,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApplyLinksCompanion.insert(
                id: id,
                linkName: linkName,
                linkUrl: linkUrl,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApplyLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApplyLinksTable,
      ApplyLink,
      $$ApplyLinksTableFilterComposer,
      $$ApplyLinksTableOrderingComposer,
      $$ApplyLinksTableAnnotationComposer,
      $$ApplyLinksTableCreateCompanionBuilder,
      $$ApplyLinksTableUpdateCompanionBuilder,
      (ApplyLink, BaseReferences<_$AppDatabase, $ApplyLinksTable, ApplyLink>),
      ApplyLink,
      PrefetchHooks Function()
    >;
typedef $$VkycRecordsTableCreateCompanionBuilder =
    VkycRecordsCompanion Function({
      required String id,
      required String employeeName,
      required String employeeCode,
      required String customerName,
      required String mobileNo,
      required String bankVkycStatus,
      required String userVkycStatus,
      Value<String?> userRemarks,
      Value<String?> dataStatus,
      Value<DateTime?> vkycExpiryDate,
      Value<bool> removeData,
      Value<String?> vkycLink,
      Value<String?> arnNo,
      required DateTime created,
      required DateTime updated,
      Value<bool> syncPending,
      Value<int> rowid,
    });
typedef $$VkycRecordsTableUpdateCompanionBuilder =
    VkycRecordsCompanion Function({
      Value<String> id,
      Value<String> employeeName,
      Value<String> employeeCode,
      Value<String> customerName,
      Value<String> mobileNo,
      Value<String> bankVkycStatus,
      Value<String> userVkycStatus,
      Value<String?> userRemarks,
      Value<String?> dataStatus,
      Value<DateTime?> vkycExpiryDate,
      Value<bool> removeData,
      Value<String?> vkycLink,
      Value<String?> arnNo,
      Value<DateTime> created,
      Value<DateTime> updated,
      Value<bool> syncPending,
      Value<int> rowid,
    });

class $$VkycRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $VkycRecordsTable> {
  $$VkycRecordsTableFilterComposer({
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

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankVkycStatus => $composableBuilder(
    column: $table.bankVkycStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userVkycStatus => $composableBuilder(
    column: $table.userVkycStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vkycExpiryDate => $composableBuilder(
    column: $table.vkycExpiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vkycLink => $composableBuilder(
    column: $table.vkycLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VkycRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $VkycRecordsTable> {
  $$VkycRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankVkycStatus => $composableBuilder(
    column: $table.bankVkycStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userVkycStatus => $composableBuilder(
    column: $table.userVkycStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vkycExpiryDate => $composableBuilder(
    column: $table.vkycExpiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vkycLink => $composableBuilder(
    column: $table.vkycLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VkycRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VkycRecordsTable> {
  $$VkycRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get bankVkycStatus => $composableBuilder(
    column: $table.bankVkycStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userVkycStatus => $composableBuilder(
    column: $table.userVkycStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get vkycExpiryDate => $composableBuilder(
    column: $table.vkycExpiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vkycLink =>
      $composableBuilder(column: $table.vkycLink, builder: (column) => column);

  GeneratedColumn<String> get arnNo =>
      $composableBuilder(column: $table.arnNo, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => column,
  );
}

class $$VkycRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VkycRecordsTable,
          VkycRecord,
          $$VkycRecordsTableFilterComposer,
          $$VkycRecordsTableOrderingComposer,
          $$VkycRecordsTableAnnotationComposer,
          $$VkycRecordsTableCreateCompanionBuilder,
          $$VkycRecordsTableUpdateCompanionBuilder,
          (
            VkycRecord,
            BaseReferences<_$AppDatabase, $VkycRecordsTable, VkycRecord>,
          ),
          VkycRecord,
          PrefetchHooks Function()
        > {
  $$VkycRecordsTableTableManager(_$AppDatabase db, $VkycRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VkycRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VkycRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VkycRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String> bankVkycStatus = const Value.absent(),
                Value<String> userVkycStatus = const Value.absent(),
                Value<String?> userRemarks = const Value.absent(),
                Value<String?> dataStatus = const Value.absent(),
                Value<DateTime?> vkycExpiryDate = const Value.absent(),
                Value<bool> removeData = const Value.absent(),
                Value<String?> vkycLink = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> updated = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VkycRecordsCompanion(
                id: id,
                employeeName: employeeName,
                employeeCode: employeeCode,
                customerName: customerName,
                mobileNo: mobileNo,
                bankVkycStatus: bankVkycStatus,
                userVkycStatus: userVkycStatus,
                userRemarks: userRemarks,
                dataStatus: dataStatus,
                vkycExpiryDate: vkycExpiryDate,
                removeData: removeData,
                vkycLink: vkycLink,
                arnNo: arnNo,
                created: created,
                updated: updated,
                syncPending: syncPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String employeeName,
                required String employeeCode,
                required String customerName,
                required String mobileNo,
                required String bankVkycStatus,
                required String userVkycStatus,
                Value<String?> userRemarks = const Value.absent(),
                Value<String?> dataStatus = const Value.absent(),
                Value<DateTime?> vkycExpiryDate = const Value.absent(),
                Value<bool> removeData = const Value.absent(),
                Value<String?> vkycLink = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                required DateTime created,
                required DateTime updated,
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VkycRecordsCompanion.insert(
                id: id,
                employeeName: employeeName,
                employeeCode: employeeCode,
                customerName: customerName,
                mobileNo: mobileNo,
                bankVkycStatus: bankVkycStatus,
                userVkycStatus: userVkycStatus,
                userRemarks: userRemarks,
                dataStatus: dataStatus,
                vkycExpiryDate: vkycExpiryDate,
                removeData: removeData,
                vkycLink: vkycLink,
                arnNo: arnNo,
                created: created,
                updated: updated,
                syncPending: syncPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VkycRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VkycRecordsTable,
      VkycRecord,
      $$VkycRecordsTableFilterComposer,
      $$VkycRecordsTableOrderingComposer,
      $$VkycRecordsTableAnnotationComposer,
      $$VkycRecordsTableCreateCompanionBuilder,
      $$VkycRecordsTableUpdateCompanionBuilder,
      (
        VkycRecord,
        BaseReferences<_$AppDatabase, $VkycRecordsTable, VkycRecord>,
      ),
      VkycRecord,
      PrefetchHooks Function()
    >;
typedef $$BkycRecordsTableCreateCompanionBuilder =
    BkycRecordsCompanion Function({
      required String id,
      Value<String?> employeeName,
      Value<String?> employeeCode,
      required String customerName,
      required String mobileNo,
      Value<String?> arnNo,
      Value<String?> bankStatus,
      Value<String?> userStatus,
      Value<String?> userRemarks,
      Value<String?> bankRemarks,
      Value<DateTime?> userStatusDate,
      Value<bool> removeData,
      required DateTime created,
      required DateTime updated,
      Value<String?> dataStatus,
      Value<bool> syncPending,
      Value<int> rowid,
    });
typedef $$BkycRecordsTableUpdateCompanionBuilder =
    BkycRecordsCompanion Function({
      Value<String> id,
      Value<String?> employeeName,
      Value<String?> employeeCode,
      Value<String> customerName,
      Value<String> mobileNo,
      Value<String?> arnNo,
      Value<String?> bankStatus,
      Value<String?> userStatus,
      Value<String?> userRemarks,
      Value<String?> bankRemarks,
      Value<DateTime?> userStatusDate,
      Value<bool> removeData,
      Value<DateTime> created,
      Value<DateTime> updated,
      Value<String?> dataStatus,
      Value<bool> syncPending,
      Value<int> rowid,
    });

class $$BkycRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BkycRecordsTable> {
  $$BkycRecordsTableFilterComposer({
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

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankStatus => $composableBuilder(
    column: $table.bankStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userStatus => $composableBuilder(
    column: $table.userStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankRemarks => $composableBuilder(
    column: $table.bankRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get userStatusDate => $composableBuilder(
    column: $table.userStatusDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BkycRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BkycRecordsTable> {
  $$BkycRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankStatus => $composableBuilder(
    column: $table.bankStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userStatus => $composableBuilder(
    column: $table.userStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankRemarks => $composableBuilder(
    column: $table.bankRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get userStatusDate => $composableBuilder(
    column: $table.userStatusDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BkycRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BkycRecordsTable> {
  $$BkycRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get arnNo =>
      $composableBuilder(column: $table.arnNo, builder: (column) => column);

  GeneratedColumn<String> get bankStatus => $composableBuilder(
    column: $table.bankStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userStatus => $composableBuilder(
    column: $table.userStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankRemarks => $composableBuilder(
    column: $table.bankRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get userStatusDate => $composableBuilder(
    column: $table.userStatusDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => column,
  );
}

class $$BkycRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BkycRecordsTable,
          BkycRecord,
          $$BkycRecordsTableFilterComposer,
          $$BkycRecordsTableOrderingComposer,
          $$BkycRecordsTableAnnotationComposer,
          $$BkycRecordsTableCreateCompanionBuilder,
          $$BkycRecordsTableUpdateCompanionBuilder,
          (
            BkycRecord,
            BaseReferences<_$AppDatabase, $BkycRecordsTable, BkycRecord>,
          ),
          BkycRecord,
          PrefetchHooks Function()
        > {
  $$BkycRecordsTableTableManager(_$AppDatabase db, $BkycRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BkycRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BkycRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BkycRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> employeeName = const Value.absent(),
                Value<String?> employeeCode = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<String?> bankStatus = const Value.absent(),
                Value<String?> userStatus = const Value.absent(),
                Value<String?> userRemarks = const Value.absent(),
                Value<String?> bankRemarks = const Value.absent(),
                Value<DateTime?> userStatusDate = const Value.absent(),
                Value<bool> removeData = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> updated = const Value.absent(),
                Value<String?> dataStatus = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BkycRecordsCompanion(
                id: id,
                employeeName: employeeName,
                employeeCode: employeeCode,
                customerName: customerName,
                mobileNo: mobileNo,
                arnNo: arnNo,
                bankStatus: bankStatus,
                userStatus: userStatus,
                userRemarks: userRemarks,
                bankRemarks: bankRemarks,
                userStatusDate: userStatusDate,
                removeData: removeData,
                created: created,
                updated: updated,
                dataStatus: dataStatus,
                syncPending: syncPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> employeeName = const Value.absent(),
                Value<String?> employeeCode = const Value.absent(),
                required String customerName,
                required String mobileNo,
                Value<String?> arnNo = const Value.absent(),
                Value<String?> bankStatus = const Value.absent(),
                Value<String?> userStatus = const Value.absent(),
                Value<String?> userRemarks = const Value.absent(),
                Value<String?> bankRemarks = const Value.absent(),
                Value<DateTime?> userStatusDate = const Value.absent(),
                Value<bool> removeData = const Value.absent(),
                required DateTime created,
                required DateTime updated,
                Value<String?> dataStatus = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BkycRecordsCompanion.insert(
                id: id,
                employeeName: employeeName,
                employeeCode: employeeCode,
                customerName: customerName,
                mobileNo: mobileNo,
                arnNo: arnNo,
                bankStatus: bankStatus,
                userStatus: userStatus,
                userRemarks: userRemarks,
                bankRemarks: bankRemarks,
                userStatusDate: userStatusDate,
                removeData: removeData,
                created: created,
                updated: updated,
                dataStatus: dataStatus,
                syncPending: syncPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BkycRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BkycRecordsTable,
      BkycRecord,
      $$BkycRecordsTableFilterComposer,
      $$BkycRecordsTableOrderingComposer,
      $$BkycRecordsTableAnnotationComposer,
      $$BkycRecordsTableCreateCompanionBuilder,
      $$BkycRecordsTableUpdateCompanionBuilder,
      (
        BkycRecord,
        BaseReferences<_$AppDatabase, $BkycRecordsTable, BkycRecord>,
      ),
      BkycRecord,
      PrefetchHooks Function()
    >;
typedef $$ActivationRecordsTableCreateCompanionBuilder =
    ActivationRecordsCompanion Function({
      required String id,
      Value<String?> employeeName,
      Value<String?> employeeCode,
      required String customerName,
      required String mobileNo,
      Value<String?> arnNo,
      Value<String?> decisionMonth,
      Value<DateTime?> decisionDate,
      Value<String?> bankStatus,
      Value<DateTime?> bankStatusDate,
      Value<String?> userStatus,
      Value<DateTime?> userStatusDate,
      Value<String?> dataStatus,
      Value<bool> removeData,
      Value<String?> userRemarks,
      Value<DateTime?> followupDate,
      required DateTime created,
      required DateTime updated,
      Value<bool> syncPending,
      Value<int> rowid,
    });
typedef $$ActivationRecordsTableUpdateCompanionBuilder =
    ActivationRecordsCompanion Function({
      Value<String> id,
      Value<String?> employeeName,
      Value<String?> employeeCode,
      Value<String> customerName,
      Value<String> mobileNo,
      Value<String?> arnNo,
      Value<String?> decisionMonth,
      Value<DateTime?> decisionDate,
      Value<String?> bankStatus,
      Value<DateTime?> bankStatusDate,
      Value<String?> userStatus,
      Value<DateTime?> userStatusDate,
      Value<String?> dataStatus,
      Value<bool> removeData,
      Value<String?> userRemarks,
      Value<DateTime?> followupDate,
      Value<DateTime> created,
      Value<DateTime> updated,
      Value<bool> syncPending,
      Value<int> rowid,
    });

class $$ActivationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivationRecordsTable> {
  $$ActivationRecordsTableFilterComposer({
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

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionMonth => $composableBuilder(
    column: $table.decisionMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decisionDate => $composableBuilder(
    column: $table.decisionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankStatus => $composableBuilder(
    column: $table.bankStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bankStatusDate => $composableBuilder(
    column: $table.bankStatusDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userStatus => $composableBuilder(
    column: $table.userStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get userStatusDate => $composableBuilder(
    column: $table.userStatusDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followupDate => $composableBuilder(
    column: $table.followupDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivationRecordsTable> {
  $$ActivationRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arnNo => $composableBuilder(
    column: $table.arnNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionMonth => $composableBuilder(
    column: $table.decisionMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decisionDate => $composableBuilder(
    column: $table.decisionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankStatus => $composableBuilder(
    column: $table.bankStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bankStatusDate => $composableBuilder(
    column: $table.bankStatusDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userStatus => $composableBuilder(
    column: $table.userStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get userStatusDate => $composableBuilder(
    column: $table.userStatusDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followupDate => $composableBuilder(
    column: $table.followupDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivationRecordsTable> {
  $$ActivationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get arnNo =>
      $composableBuilder(column: $table.arnNo, builder: (column) => column);

  GeneratedColumn<String> get decisionMonth => $composableBuilder(
    column: $table.decisionMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decisionDate => $composableBuilder(
    column: $table.decisionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankStatus => $composableBuilder(
    column: $table.bankStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get bankStatusDate => $composableBuilder(
    column: $table.bankStatusDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userStatus => $composableBuilder(
    column: $table.userStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get userStatusDate => $composableBuilder(
    column: $table.userStatusDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataStatus => $composableBuilder(
    column: $table.dataStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get removeData => $composableBuilder(
    column: $table.removeData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userRemarks => $composableBuilder(
    column: $table.userRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get followupDate => $composableBuilder(
    column: $table.followupDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<bool> get syncPending => $composableBuilder(
    column: $table.syncPending,
    builder: (column) => column,
  );
}

class $$ActivationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivationRecordsTable,
          ActivationRecord,
          $$ActivationRecordsTableFilterComposer,
          $$ActivationRecordsTableOrderingComposer,
          $$ActivationRecordsTableAnnotationComposer,
          $$ActivationRecordsTableCreateCompanionBuilder,
          $$ActivationRecordsTableUpdateCompanionBuilder,
          (
            ActivationRecord,
            BaseReferences<
              _$AppDatabase,
              $ActivationRecordsTable,
              ActivationRecord
            >,
          ),
          ActivationRecord,
          PrefetchHooks Function()
        > {
  $$ActivationRecordsTableTableManager(
    _$AppDatabase db,
    $ActivationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivationRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivationRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> employeeName = const Value.absent(),
                Value<String?> employeeCode = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String?> arnNo = const Value.absent(),
                Value<String?> decisionMonth = const Value.absent(),
                Value<DateTime?> decisionDate = const Value.absent(),
                Value<String?> bankStatus = const Value.absent(),
                Value<DateTime?> bankStatusDate = const Value.absent(),
                Value<String?> userStatus = const Value.absent(),
                Value<DateTime?> userStatusDate = const Value.absent(),
                Value<String?> dataStatus = const Value.absent(),
                Value<bool> removeData = const Value.absent(),
                Value<String?> userRemarks = const Value.absent(),
                Value<DateTime?> followupDate = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> updated = const Value.absent(),
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivationRecordsCompanion(
                id: id,
                employeeName: employeeName,
                employeeCode: employeeCode,
                customerName: customerName,
                mobileNo: mobileNo,
                arnNo: arnNo,
                decisionMonth: decisionMonth,
                decisionDate: decisionDate,
                bankStatus: bankStatus,
                bankStatusDate: bankStatusDate,
                userStatus: userStatus,
                userStatusDate: userStatusDate,
                dataStatus: dataStatus,
                removeData: removeData,
                userRemarks: userRemarks,
                followupDate: followupDate,
                created: created,
                updated: updated,
                syncPending: syncPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> employeeName = const Value.absent(),
                Value<String?> employeeCode = const Value.absent(),
                required String customerName,
                required String mobileNo,
                Value<String?> arnNo = const Value.absent(),
                Value<String?> decisionMonth = const Value.absent(),
                Value<DateTime?> decisionDate = const Value.absent(),
                Value<String?> bankStatus = const Value.absent(),
                Value<DateTime?> bankStatusDate = const Value.absent(),
                Value<String?> userStatus = const Value.absent(),
                Value<DateTime?> userStatusDate = const Value.absent(),
                Value<String?> dataStatus = const Value.absent(),
                Value<bool> removeData = const Value.absent(),
                Value<String?> userRemarks = const Value.absent(),
                Value<DateTime?> followupDate = const Value.absent(),
                required DateTime created,
                required DateTime updated,
                Value<bool> syncPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivationRecordsCompanion.insert(
                id: id,
                employeeName: employeeName,
                employeeCode: employeeCode,
                customerName: customerName,
                mobileNo: mobileNo,
                arnNo: arnNo,
                decisionMonth: decisionMonth,
                decisionDate: decisionDate,
                bankStatus: bankStatus,
                bankStatusDate: bankStatusDate,
                userStatus: userStatus,
                userStatusDate: userStatusDate,
                dataStatus: dataStatus,
                removeData: removeData,
                userRemarks: userRemarks,
                followupDate: followupDate,
                created: created,
                updated: updated,
                syncPending: syncPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivationRecordsTable,
      ActivationRecord,
      $$ActivationRecordsTableFilterComposer,
      $$ActivationRecordsTableOrderingComposer,
      $$ActivationRecordsTableAnnotationComposer,
      $$ActivationRecordsTableCreateCompanionBuilder,
      $$ActivationRecordsTableUpdateCompanionBuilder,
      (
        ActivationRecord,
        BaseReferences<
          _$AppDatabase,
          $ActivationRecordsTable,
          ActivationRecord
        >,
      ),
      ActivationRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LeadsTableTableManager get leads =>
      $$LeadsTableTableManager(_db, _db.leads);
  $$CallLogsTableTableManager get callLogs =>
      $$CallLogsTableTableManager(_db, _db.callLogs);
  $$LoginCasesTableTableManager get loginCases =>
      $$LoginCasesTableTableManager(_db, _db.loginCases);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$LeaveRequestsTableTableManager get leaveRequests =>
      $$LeaveRequestsTableTableManager(_db, _db.leaveRequests);
  $$HolidaysTableTableManager get holidays =>
      $$HolidaysTableTableManager(_db, _db.holidays);
  $$LeadFeedbackTableTableManager get leadFeedback =>
      $$LeadFeedbackTableTableManager(_db, _db.leadFeedback);
  $$ApplyLinksTableTableManager get applyLinks =>
      $$ApplyLinksTableTableManager(_db, _db.applyLinks);
  $$VkycRecordsTableTableManager get vkycRecords =>
      $$VkycRecordsTableTableManager(_db, _db.vkycRecords);
  $$BkycRecordsTableTableManager get bkycRecords =>
      $$BkycRecordsTableTableManager(_db, _db.bkycRecords);
  $$ActivationRecordsTableTableManager get activationRecords =>
      $$ActivationRecordsTableTableManager(_db, _db.activationRecords);
}
