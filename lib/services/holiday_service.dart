import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';

class HolidayService {
  static AppDatabase get _db => LeadService.db;

  static Future<void> syncHolidays() async {
    try {
      final records = await PB.pb.collection('holiday').getFullList(
        sort: 'holiday_date',
      );


      final serverIds = records.map((r) => r.id).toSet();

      for (var record in records) {
        
        final utcDate = DateTime.parse(record.data['holiday_date']);
        final localTime = utcDate.toLocal();
        final localDate = DateTime(localTime.year, localTime.month, localTime.day);
        
        
        await _db.into(_db.holidays).insertOnConflictUpdate(
          HolidaysCompanion.insert(
            id: record.id,
            holidayName: record.data['holiday_name'] ?? '',
            holidayDate: localDate,
            active: record.data['active'] ?? true,
          ),
        );
      }

      final localRecords = await (_db.select(_db.holidays)).get();
      
      for (var localRecord in localRecords) {
        if (!serverIds.contains(localRecord.id)) {
          await (_db.delete(_db.holidays)..where((t) => t.id.equals(localRecord.id))).go();
        }
      }
      
    } catch (e) {
      print('Holiday sync error: $e');
    }
  }

  static Future<bool> isHoliday(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final holidays = await (_db.select(_db.holidays)
      ..where((t) => 
        t.holidayDate.isBiggerOrEqualValue(startOfDay) &
        t.holidayDate.isSmallerThanValue(endOfDay)
      )).get();

    return holidays.isNotEmpty;
  }

  static Future<List<Holiday>> getUpcomingHolidays({int limit = 5}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return await (_db.select(_db.holidays)
      ..where((t) => t.holidayDate.isBiggerOrEqualValue(today))
      ..orderBy([(t) => OrderingTerm.asc(t.holidayDate)])
      ..limit(limit)).get();
  }

  static Future<List<Holiday>> getAllHolidays() async {
    return await (_db.select(_db.holidays)
      ..orderBy([(t) => OrderingTerm.asc(t.holidayDate)])).get();
  }

  static Future<void> syncDown() async {
    await syncHolidays();
  }
}
