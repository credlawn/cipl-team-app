import 'package:drift/drift.dart';
import '../core/pb_api.dart';
import '../database/app_database.dart';
import 'lead_service.dart';

class ApplyLinkService {
  static AppDatabase get _db => LeadService.db;

  static Future<void> syncDown() async {
    try {
      final records = await PB.pb.collection('apply_link').getFullList(
        sort: 'link_name',
      );

      await _db.transaction(() async {
        await _db.delete(_db.applyLinks).go();
        
        await _db.batch((batch) {
          for (var record in records) {
            batch.insert(
              _db.applyLinks,
              ApplyLinksCompanion.insert(
                id: record.id,
                linkName: record.data['link_name'] ?? '',
                linkUrl: record.data['link_url'] ?? '',
                isDefault: Value(record.data['is_default'] ?? false),
              ),
            );
          }
        });
      });
    } catch (e) {}
  }

  static Future<List<ApplyLink>> getAllLinks() async {
    return await _db.select(_db.applyLinks).get();
  }

  static Stream<List<ApplyLink>> watchLinks() {
    return _db.select(_db.applyLinks).watch();
  }
}
