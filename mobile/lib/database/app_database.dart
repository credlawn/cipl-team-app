import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/call_logs_table.dart';
import 'tables/login_cases_table.dart';

part 'app_database.g.dart';

class Attendance extends Table {
  TextColumn get id => text()();
  TextColumn get employeeId => text()();
  TextColumn get employeeCode => text()();
  TextColumn get employeeName => text()();
  DateTimeColumn get attendanceDate => dateTime()();
  DateTimeColumn get checkInTime => dateTime()();
  TextColumn get checkInSelfie => text()();
  RealColumn get checkInLatitude => real()();
  RealColumn get checkInLongitude => real()();
  DateTimeColumn get checkOutTime => dateTime().nullable()();
  TextColumn get checkOutSelfie => text().nullable()();
  RealColumn get checkOutLatitude => real().nullable()();
  RealColumn get checkOutLongitude => real().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get syncPending => boolean().withDefault(const Constant(false))();
  
  TextColumn get status => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get approvalType => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class LeaveRequests extends Table {
  TextColumn get id => text()();
  TextColumn get employeeId => text()();
  TextColumn get employeeCode => text()();
  TextColumn get employeeName => text()();
  TextColumn get leaveType => text()();
  DateTimeColumn get fromDate => dateTime()();
  DateTimeColumn get toDate => dateTime()();
  IntColumn get daysCount => integer()();
  TextColumn get reason => text()();
  TextColumn get status => text()();
  DateTimeColumn get appliedDate => dateTime()();
  BoolColumn get syncPending => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Holidays extends Table {
  TextColumn get id => text()();
  TextColumn get holidayName => text()();
  DateTimeColumn get holidayDate => dateTime()();
  BoolColumn get active => boolean()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Leads extends Table {
  TextColumn get id => text()();
  TextColumn get customerName => text()();
  TextColumn get mobileNo => text()();
  TextColumn get city => text().nullable()();
  TextColumn get segment => text().nullable()();
  TextColumn get employer => text().nullable()();
  TextColumn get declineReason => text().nullable()();
  TextColumn get product => text().nullable()();
  TextColumn get assignedTo => text().nullable()();
  DateTimeColumn get assignedDate => dateTime()();
  TextColumn get employeeName => text().nullable()();
  TextColumn get employeeCode => text().nullable()();
  TextColumn get leadStatus => text()();
  DateTimeColumn get leadStatusDate => dateTime()();
  TextColumn get dataStatus => text().nullable()();
  DateTimeColumn get followupTime => dateTime().nullable()();
  TextColumn get arnNo => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get remarks => text().nullable()();
  BoolColumn get syncPending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LeadFeedback extends Table {
  TextColumn get id => text()();
  TextColumn get leadId => text()();
  TextColumn get customerName => text()();
  TextColumn get mobileNo => text()();
  TextColumn get leadStatus => text()();
  DateTimeColumn get leadStatusDate => dateTime()();
  DateTimeColumn get statusUpdateTime => dateTime()();
  TextColumn get user => text()();
  TextColumn get employeeName => text()();
  TextColumn get employeeCode => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class VkycRecords extends Table {
  TextColumn get id               => text()();
  TextColumn get employeeName     => text()();
  TextColumn get employeeCode     => text()();
  TextColumn get customerName     => text()();
  TextColumn get mobileNo         => text()();
  TextColumn get bankVkycStatus   => text()();
  TextColumn get userVkycStatus   => text()();
  TextColumn get userRemarks      => text().nullable()();
  TextColumn get dataStatus       => text().nullable()();
  DateTimeColumn get vkycExpiryDate => dateTime().nullable()();
  BoolColumn get removeData       => boolean().withDefault(const Constant(false))();
  TextColumn get vkycLink         => text().nullable()();
  TextColumn get arnNo            => text().nullable()();
  DateTimeColumn get created      => dateTime()();
  DateTimeColumn get updated      => dateTime()();
  BoolColumn get syncPending      => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class BkycRecords extends Table {
  TextColumn get id               => text()();
  TextColumn get employeeName     => text().nullable()();
  TextColumn get employeeCode     => text().nullable()();
  TextColumn get customerName     => text()();
  TextColumn get mobileNo         => text()();
  TextColumn get arnNo            => text().nullable()();
  TextColumn get bankStatus       => text().nullable()();
  TextColumn get userStatus       => text().nullable()();
  TextColumn get userRemarks      => text().nullable()();
  TextColumn get bankRemarks      => text().nullable()();
  DateTimeColumn get userStatusDate => dateTime().nullable()();
  BoolColumn get removeData       => boolean().withDefault(const Constant(false))();
  DateTimeColumn get created      => dateTime()();
  DateTimeColumn get updated      => dateTime()();
  TextColumn get dataStatus       => text().nullable()();
  BoolColumn get syncPending      => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ActivationRecords extends Table {
  TextColumn get id               => text()();
  TextColumn get employeeName     => text().nullable()();
  TextColumn get employeeCode     => text().nullable()();
  TextColumn get customerName     => text()();
  TextColumn get mobileNo         => text()();
  TextColumn get arnNo            => text().nullable()();
  TextColumn get decisionMonth    => text().nullable()();
  DateTimeColumn get decisionDate => dateTime().nullable()();
  TextColumn get bankStatus       => text().nullable()();
  DateTimeColumn get bankStatusDate => dateTime().nullable()();
  TextColumn get userStatus       => text().nullable()();
  DateTimeColumn get userStatusDate => dateTime().nullable()();
  TextColumn get dataStatus       => text().nullable()();
  BoolColumn get removeData       => boolean().withDefault(const Constant(false))();
  TextColumn get userRemarks      => text().nullable()();
  DateTimeColumn get followupDate => dateTime().nullable()();
  DateTimeColumn get created      => dateTime()();
  DateTimeColumn get updated      => dateTime()();
  BoolColumn get syncPending      => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ApplyLinks extends Table {
  TextColumn get id => text()();
  TextColumn get linkName => text()();
  TextColumn get linkUrl => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Leads, CallLogs, LoginCases, Attendance, LeaveRequests, Holidays, LeadFeedback, ApplyLinks, VkycRecords, BkycRecords, ActivationRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 22;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) {
          await m.createTable(callLogs);
        }
        if (from < 6) {
          await m.addColumn(callLogs, callLogs.sessionDuration);
        }
        if (from < 7) {
          await m.addColumn(callLogs, callLogs.employeeCode);
          await m.addColumn(callLogs, callLogs.employeeName);
        }
        if (from < 8) {
          await m.createTable(loginCases);
        }
        if (from < 9) {
          await m.addColumn(leads, leads.followupTime);
        }
        if (from < 10) {
          await m.createTable(attendance);
        }
        if (from < 11) {
          await m.createTable(leaveRequests);
        }
        if (from < 12) {
          await m.createTable(holidays);
        }
        if (from < 13) {
          await m.createTable(leadFeedback);
        }
        if (from < 14) {
          await m.addColumn(leads, leads.arnNo);
          await m.addColumn(leads, leads.dateOfBirth);
          await m.addColumn(leads, leads.remarks);
        }
        if (from < 15) {
          await m.addColumn(leads, leads.employeeName);
          await m.addColumn(leads, leads.employeeCode);
        }
        if (from < 16) {
          await m.createTable(applyLinks);
        }
        if (from < 17) {
          await m.addColumn(applyLinks, applyLinks.isDefault);
        }
        if (from < 18) {
          await customStatement('ALTER TABLE attendance ADD COLUMN status TEXT;');
          await customStatement('ALTER TABLE attendance ADD COLUMN remarks TEXT;');
          await customStatement('ALTER TABLE attendance ADD COLUMN approval_type TEXT;');
        }
        if (from < 19) {
          await m.createTable(vkycRecords);
        }
        if (from < 20) {
          await m.addColumn(vkycRecords, vkycRecords.arnNo);
        }
        if (from < 21) {
          await m.createTable(bkycRecords);
        }
        if (from < 22) {
          await m.createTable(activationRecords);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
