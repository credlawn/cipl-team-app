import 'package:drift/drift.dart';

class LoginCases extends Table {
  TextColumn get id => text()();
  TextColumn get customerName => text()();
  TextColumn get mobileNumber => text()();
  TextColumn get leadStatus => text()();
  TextColumn get employeeName => text()();
  TextColumn get employeeCode => text()();
  DateTimeColumn get leadStatusDate => dateTime()();
  DateTimeColumn get arnDate => dateTime().nullable()();
  TextColumn get arnNo => text().nullable()();
  TextColumn get leadId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
