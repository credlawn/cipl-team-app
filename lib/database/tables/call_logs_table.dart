import 'package:drift/drift.dart';

class CallLogs extends Table {
  TextColumn get id => text()();
  TextColumn get leadId => text()();
  TextColumn get employeeId => text()();
  TextColumn get employeeCode => text()();
  TextColumn get employeeName => text()();
  TextColumn get phoneNumber => text()();
  DateTimeColumn get callTimestamp => dateTime()();
  IntColumn get callDuration => integer()();
  IntColumn get ringDuration => integer()();
  IntColumn get sessionDuration => integer().withDefault(const Constant(0))();
  TextColumn get callType => text()();
  TextColumn get callStatus => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
