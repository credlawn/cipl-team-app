import 'dart:io';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';
import 'holiday_service.dart';

class AttendanceService {
  static const _uuid = Uuid();
  static AppDatabase get _db => LeadService.db;

  // FIX B: Per-record in-flight lock.
  // Prevents concurrent _syncAttendanceToPocketBase() calls for the same
  // local temp record, which was causing duplicate server records.
  static final Set<String> _inFlightIds = {};

  static Future<Map<String, dynamic>> getFreshLocation() async {
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        throw Exception('Location permission is required for attendance. Please enable location access in settings.');
      }
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: false,
        timeLimit: const Duration(seconds: 30),
      );
    } catch (e) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: false,
        timeLimit: const Duration(seconds: 30),
      );
    }

    String address = '';
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}'.trim();
        if (address.startsWith(',')) address = address.substring(1).trim();
      }
    } catch (e) {
      address = 'Address unavailable';
    }

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'address': address,
    };
  }

  static Future<void> checkIn({
    required String selfiePath,
    required Map<String, dynamic> locationData,
  }) async {
    final user = PB.pb.authStore.record;
    if (user == null) throw Exception('User not logged in');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final existing = await (_db.select(_db.attendance)
      ..where((t) => 
        t.employeeId.equals(user.id) &
        t.attendanceDate.isBiggerOrEqualValue(today) &
        t.attendanceDate.isSmallerThanValue(today.add(const Duration(days: 1)))
      )).getSingleOrNull();

    if (existing != null) {
      throw Exception('Already checked in today');
    }

    final attendance = AttendanceCompanion.insert(
      id: _uuid.v4(),
      employeeId: user.id,
      employeeCode: user.getStringValue('employee_code'),
      employeeName: user.getStringValue('employee_name'),
      attendanceDate: today,
      checkInTime: now,
      checkInSelfie: selfiePath,
      checkInLatitude: locationData['latitude'],
      checkInLongitude: locationData['longitude'],
      address: Value(locationData['address']),
      syncPending: const Value(true),
    );

    await _db.into(_db.attendance).insert(attendance);
    
    _syncAttendanceToPocketBase(attendance);
  }

  static Future<void> checkOut({
    required String attendanceId,
    required String selfiePath,
    required Map<String, dynamic> locationData,
  }) async {
    await (_db.update(_db.attendance)
      ..where((t) => t.id.equals(attendanceId)))
      .write(AttendanceCompanion(
        checkOutTime: Value(DateTime.now()),
        checkOutSelfie: Value(selfiePath),
        checkOutLatitude: Value(locationData['latitude']),
        checkOutLongitude: Value(locationData['longitude']),
        syncPending: const Value(true),
      ));
    
    // Re-fetch updated record for sync
    final updatedRecord = await (_db.select(_db.attendance)
      ..where((t) => t.id.equals(attendanceId))).getSingle();

    _syncAttendanceUpdateToPocketBase(updatedRecord);
  }

  static Future<String> calculateAttendanceStatus({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    required DateTime date,
    required String officeStartTime,
  }) async {
    // Priority 1: If checked in
    if (checkInTime != null) {
      // If not checked out yet -> "Working"
      if (checkOutTime == null) {
        return 'Working';
      }
      
      // If checked out, calculate Present/Late based on check-in time
      try {
        // Handle empty or null office start time - use fallback
        String timeString = officeStartTime.trim();
        if (timeString.isEmpty) {
          timeString = '10:15 AM'; // Use fallback instead of returning
        }
        
        final dateFormat = DateFormat('h:mm a');
        final officeStart = dateFormat.parse(timeString);
        final officeStartDateTime = DateTime(
          date.year, date.month, date.day,
          officeStart.hour, officeStart.minute
        );
        
        // Compare check-in time with office start time
        if (checkInTime.isAfter(officeStartDateTime)) {
          return 'Late';
        } else {
          return 'Present';
        }
      } catch (e) {
        return 'Present'; // Default to Present if parsing fails
      }
    }
    
    // Priority 2: Not checked in - check if Holiday
    final isHoliday = await HolidayService.isHoliday(date);
    if (isHoliday) {
      return 'Holiday';
    }
    
    // Priority 3: Not checked in - check if On Leave
    final user = PB.pb.authStore.record;
    if (user != null) {
      final leaves = await (_db.select(_db.leaveRequests)
        ..where((t) => 
          t.employeeId.equals(user.id) &
          t.status.equals('approved')
        )).get();
      
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isOnLeave = leaves.any((leave) {
        final fromDate = DateTime(leave.fromDate.year, leave.fromDate.month, leave.fromDate.day);
        final toDate = DateTime(leave.toDate.year, leave.toDate.month, leave.toDate.day);
        return dateOnly.compareTo(fromDate) >= 0 && dateOnly.compareTo(toDate) <= 0;
      });
      
      if (isOnLeave) {
        return 'On Leave';
      }
    }
    
    // Priority 4: None of the above - Absent
    return 'Absent';
  }

  static Future<AttendanceData?> getTodayAttendance() async {
    final user = PB.pb.authStore.record;
    if (user == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return await (_db.select(_db.attendance)
      ..where((t) => 
        t.employeeId.equals(user.id) &
        t.attendanceDate.isBiggerOrEqualValue(today) &
        t.attendanceDate.isSmallerThanValue(today.add(const Duration(days: 1)))
      )).getSingleOrNull();
  }

  static Future<Map<String, int>> getMonthlyStats() async {
    final user = PB.pb.authStore.record;
    if (user == null) return {};

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final officeStartTimeStr = user.data['office_start_time'] ?? '10:15 AM';

    // Fetch all attendance data for the month
    final attendanceRecords = await (_db.select(_db.attendance)
      ..where((t) => 
        t.employeeId.equals(user.id) &
        t.attendanceDate.isBiggerOrEqualValue(startOfMonth) &
        t.attendanceDate.isSmallerOrEqualValue(now)
      )).get();

    int present = 0, late = 0, absent = 0, holidayCount = 0, leaveCount = 0;

    // Iterate from start of month to today
    final daysToProcess = now.difference(startOfMonth).inDays + 1;

    for (int i = 0; i < daysToProcess; i++) {
      final date = startOfMonth.add(Duration(days: i));
      
      // Find attendance for this date
      final attendance = attendanceRecords.where((a) => 
        a.attendanceDate.year == date.year && 
        a.attendanceDate.month == date.month && 
        a.attendanceDate.day == date.day
      ).firstOrNull;

      // Calculate status using centralized helper
      final status = await calculateAttendanceStatus(
        checkInTime: attendance?.checkInTime,
        checkOutTime: attendance?.checkOutTime,
        date: date,
        officeStartTime: officeStartTimeStr,
      );

      // Count based on status
      switch (status.toLowerCase()) {
        case 'present':
        case 'working': // Count working as present for stats
          present++;
          break;
        case 'late':
          late++;
          break;
        case 'holiday':
          holidayCount++;
          break;
        case 'on leave':
          leaveCount++;
          break;
        case 'absent':
          absent++;
          break;
      }
    }

    return {
      'present': present,
      'late': late,
      'absent': absent,
      'holiday': holidayCount,
      'leave': leaveCount,
    };
  }

  static Stream<AttendanceData?> watchTodayAttendance() {
    final user = PB.pb.authStore.record;
    if (user == null) return Stream.value(null);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return (_db.select(_db.attendance)
      ..where((t) => 
        t.employeeId.equals(user.id) &
        t.attendanceDate.isBiggerOrEqualValue(today) &
        t.attendanceDate.isSmallerThanValue(today.add(const Duration(days: 1)))
      )).watchSingleOrNull();
  }

  static Future<void> _syncAttendanceToPocketBase(AttendanceCompanion attendance) async {
    // FIX B: Acquire per-record lock. If this local ID is already being synced
    // (e.g. by a concurrent syncPendingAttendance call), skip — it will clean up.
    final localId = attendance.id.value;
    if (_inFlightIds.contains(localId)) return;
    _inFlightIds.add(localId);

    try {
      final selfieFile = await http.MultipartFile.fromPath(
        'check_in_selfie',
        attendance.checkInSelfie.value,
        filename: 'checkin_${attendance.id.value}.jpg',
      );

      // Convert attendance date to UTC date-only (noon to avoid timezone edge cases)
      final localDate = attendance.attendanceDate.value;
      final utcDateNoon = DateTime.utc(localDate.year, localDate.month, localDate.day, 12, 0, 0);

      // Idempotent create — handle server duplicate gracefully
      dynamic serverRecord;
      try {
        serverRecord = await PB.pb.collection('attendance').create(
          body: {
            'user': attendance.employeeId.value,
            'employee_code': attendance.employeeCode.value,
            'employee_name': attendance.employeeName.value,
            'attendance_date': utcDateNoon.toIso8601String(),
            'check_in_time': attendance.checkInTime.value.toUtc().toIso8601String(),
            'check_in_latitude': attendance.checkInLatitude.value,
            'check_in_longitude': attendance.checkInLongitude.value,
            'address': attendance.address.value,
          },
          files: [selfieFile],
        );
      } catch (createError) {
        final errStr = createError.toString().toLowerCase();
        if (errStr.contains('400') || errStr.contains('unique') || errStr.contains('already')) {
          // Server rejected as duplicate — recover the existing record
          final userId = attendance.employeeId.value;
          final dateStr = DateFormat('yyyy-MM-dd').format(attendance.attendanceDate.value);
          try {
            serverRecord = await PB.pb.collection('attendance').getFirstListItem(
              'user="$userId" && attendance_date~"$dateStr"',
            );
          } catch (_) {
            return; // Cannot recover — leave syncPending=true for next attempt
          }
        } else {
          rethrow;
        }
      }

      final filename = serverRecord.data['check_in_selfie'];
      final serverUrl = '${PB.pb.baseUrl}/api/files/${serverRecord.collectionId}/${serverRecord.id}/$filename';

      final localFile = File(attendance.checkInSelfie.value);
      if (await localFile.exists()) {
        await localFile.delete();
      }

      // FIX A: INSERT the server record FIRST, then DELETE the temp record.
      // Previous order (DELETE then INSERT) caused Drift's watchSingleOrNull()
      // to emit null between the two statements, making the UI show "Not Checked In".
      // With INSERT first, the stream always sees at least one valid row.
      await _db.transaction(() async {
        await _db.into(_db.attendance).insertOnConflictUpdate(
          AttendanceCompanion.insert(
            id: serverRecord.id,
            employeeId: attendance.employeeId.value,
            employeeCode: attendance.employeeCode.value,
            employeeName: attendance.employeeName.value,
            attendanceDate: attendance.attendanceDate.value,
            checkInTime: attendance.checkInTime.value,
            checkInSelfie: serverUrl,
            checkInLatitude: attendance.checkInLatitude.value,
            checkInLongitude: attendance.checkInLongitude.value,
            address: attendance.address,
            syncPending: const Value(false),
          ),
        );
        // Now safe to delete: stream already sees the server record above
        await (_db.delete(_db.attendance)
              ..where((t) => t.id.equals(attendance.id.value)))
            .go();
      });

    } catch (e) {
      PB.handleAuthError(e);
    } finally {
      // Always release the lock, even on error
      _inFlightIds.remove(localId);
    }
  }

  static Future<void> _syncAttendanceUpdateToPocketBase(AttendanceData record) async {
    try {
      

      List<http.MultipartFile> files = [];
      if (record.checkOutSelfie != null) {
        final selfieFile = await http.MultipartFile.fromPath(
          'check_out_selfie',
          record.checkOutSelfie!,
          filename: 'checkout_${record.id}.jpg',
        );
        files.add(selfieFile);
      }

      final updatedRecord = await PB.pb.collection('attendance').update(
        record.id,
        body: {
          'check_out_time': record.checkOutTime?.toUtc().toIso8601String(),
          'check_out_latitude': record.checkOutLatitude,
          'check_out_longitude': record.checkOutLongitude,
        },
        files: files,
      );
      

      String? serverUrl;
      if (record.checkOutSelfie != null) {
        final filename = updatedRecord.data['check_out_selfie'];
        serverUrl = '${PB.pb.baseUrl}/api/files/${updatedRecord.collectionId}/${updatedRecord.id}/$filename';
        
        final localFile = File(record.checkOutSelfie!);
        if (await localFile.exists()) {
          await localFile.delete();
        }
      }

      await (_db.update(_db.attendance)
        ..where((t) => t.id.equals(record.id)))
        .write(AttendanceCompanion(
          checkOutSelfie: serverUrl != null ? Value(serverUrl) : const Value.absent(),
          syncPending: const Value(false),
        ));
      
    } catch (e) {
      PB.handleAuthError(e);
    }
  }

  static Future<void> syncPendingAttendance() async {
    final pending = await (_db.select(_db.attendance)
      ..where((t) => t.syncPending.equals(true))).get();

    for (var record in pending) {
      if (record.checkOutTime == null) {
        final companion = AttendanceCompanion(
          id: Value(record.id),
          employeeId: Value(record.employeeId),
          employeeCode: Value(record.employeeCode),
          employeeName: Value(record.employeeName),
          attendanceDate: Value(record.attendanceDate),
          checkInTime: Value(record.checkInTime),
          checkInSelfie: Value(record.checkInSelfie),
          checkInLatitude: Value(record.checkInLatitude),
          checkInLongitude: Value(record.checkInLongitude),
          address: Value(record.address),
        );
        await _syncAttendanceToPocketBase(companion);
      } else {
        await _syncAttendanceUpdateToPocketBase(record);
      }
    }
  }

  static Future<List<AttendanceData>> getWeeklyAttendance() async {
    final user = PB.pb.authStore.record;
    if (user == null) return [];

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Convert to date-only (midnight) for proper comparison
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEndDate = weekStartDate.add(const Duration(days: 7));

    final results = await (_db.select(_db.attendance)
      ..where((t) => 
        t.employeeId.equals(user.id) &
        t.attendanceDate.isBiggerOrEqualValue(weekStartDate) &
        t.attendanceDate.isSmallerThanValue(weekEndDate)
      )
      ..orderBy([(t) => OrderingTerm(expression: t.attendanceDate)])
    ).get();
    
    return results;
  }

  static Future<void> syncUp() async {
    await syncPendingAttendance();
  }

  static Future<void> syncDown({bool isRetry = false}) async {
    try {
      final user = PB.pb.authStore.record;
      if (user == null) return;

      // FIX C: syncPendingAttendance() is intentionally NOT called here anymore.
      // Previously calling it inside syncDown() caused a double-create race:
      // callers doing Future.wait([syncUp(), syncDown()]) would trigger
      // syncPendingAttendance() from BOTH paths simultaneously, leading to
      // two concurrent PB.create() calls for the same record → duplicate records.
      //
      // Records with syncPending=true are already protected from deletion below
      // (see the !localRecord.syncPending guard), so this removal is safe.
      // Callers must call syncUp() before syncDown() if they want to flush pending.

      final records = await PB.pb.collection('attendance').getFullList(
        filter: 'user = "${user.id}" && remove_data = false',
        sort: '-attendance_date',
      );

      final serverIds = records.map((r) => r.id).toSet();

      for (var record in records) {
        final attendanceDate = DateTime.parse(record.getStringValue('attendance_date')).toLocal();
        final checkInTime = DateTime.parse(record.getStringValue('check_in_time')).toLocal();
        
        final checkOutTimeStr = record.getStringValue('check_out_time');
        final checkOutTime = checkOutTimeStr.isNotEmpty ? DateTime.parse(checkOutTimeStr).toLocal() : null;

        final checkInSelfieFilename = record.getStringValue('check_in_selfie');
        final checkInSelfieUrl = checkInSelfieFilename.isNotEmpty
            ? '${PB.pb.baseUrl}/api/files/${record.collectionId}/${record.id}/$checkInSelfieFilename'
            : '';

        final checkOutSelfieFilename = record.getStringValue('check_out_selfie');
        final checkOutSelfieUrl = checkOutSelfieFilename.isNotEmpty
            ? '${PB.pb.baseUrl}/api/files/${record.collectionId}/${record.id}/$checkOutSelfieFilename'
            : '';

        await _db.into(_db.attendance).insertOnConflictUpdate(
          AttendanceCompanion.insert(
            id: record.id,
            employeeId: record.getStringValue('user'),
            employeeCode: record.getStringValue('employee_code'),
            employeeName: record.getStringValue('employee_name'),
            attendanceDate: attendanceDate,
            checkInTime: checkInTime,
            checkInSelfie: checkInSelfieUrl,
            checkInLatitude: record.getDoubleValue('check_in_latitude'),
            checkInLongitude: record.getDoubleValue('check_in_longitude'),
            checkOutTime: Value(checkOutTime),
            checkOutSelfie: Value(checkOutSelfieUrl),
            checkOutLatitude: Value(record.getDoubleValue('check_out_latitude')),
            checkOutLongitude: Value(record.getDoubleValue('check_out_longitude')),
            address: Value(record.getStringValue('address')),
            status: Value(record.getStringValue('status')),
            remarks: Value(record.getStringValue('remarks')),
            approvalType: Value(record.getStringValue('approval_type')),
            syncPending: const Value(false),
          ),
        );
      }

      final localRecords = await (_db.select(_db.attendance)).get();
      for (var localRecord in localRecords) {
        // Layer 1: NEVER delete unsynced records — they haven't reached server yet.
        // syncPending=true means the record is queued; deleting it causes "Not Marked" bug.
        if (!serverIds.contains(localRecord.id) && !localRecord.syncPending) {
          await (_db.delete(_db.attendance)..where((t) => t.id.equals(localRecord.id))).go();
        }
      }
      
    } catch (e) {
      PB.handleAuthError(e);
      final errorStr = e.toString().toLowerCase();
      // Handle schema mismatch errors by wiping and retrying
      if (!isRetry && (errorStr.contains('no such column') || errorStr.contains('sqlite_error'))) {
        debugPrint('Safe Wipe: Schema mismatch detected. Wiping local attendance and retrying...');
        await (_db.delete(_db.attendance).go());
        await syncDown(isRetry: true);
      } else {
        rethrow;
      }
    }
  }

  // ============ MANAGER METHODS ============
  
  /// Get all active employees for manager dashboard
  static Future<List<Map<String, dynamic>>> getActiveEmployeesForManager() async {
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: '(role ~ "employee" || role ~ "manager") && disabled = false && no_atn = false',
        sort: 'employee_name',
      );
      
      return records.map((record) => record.toJson()).toList();
    } catch (e) {
      PB.handleAuthError(e);
      return [];
    }
  }

  /// Get attendance records for a specific date for manager
  static Future<List<Map<String, dynamic>>> getAttendanceByDateForManager(DateTime date) async {
    try {
      // Use date range instead of exact match
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(startOfDay);
      final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(endOfDay);
      
      // Try multiple filter approaches
      List<dynamic> records = [];
      
      // Approach 1: Date range filter
      try {
        records = await PB.pb.collection('attendance').getFullList(
          filter: 'attendance_date >= "$startStr" && attendance_date < "$endStr"',
        );
      } catch (e) {
        // Approach 2: Simple date match
        try {
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          records = await PB.pb.collection('attendance').getFullList(
            filter: 'attendance_date ~ "$dateStr"',
          );
        } catch (e) {
          // Approach 3: Get all and filter in Dart
          try {
            records = await PB.pb.collection('attendance').getFullList();
            
            // Filter by date in Dart
            records = records.where((record) {
              try {
                final attendanceDate = record.data['attendance_date'];
                if (attendanceDate == null) return false;
                
                final recordDate = DateTime.parse(attendanceDate);
                return recordDate.year == date.year &&
                       recordDate.month == date.month &&
                       recordDate.day == date.day;
              } catch (e) {
                return false;
              }
            }).toList();
          } catch (e) {
            // Silent fail
          }
        }
      }
      
      return records.map((record) => record.toJson() as Map<String, dynamic>).toList();
    } catch (e) {
      PB.handleAuthError(e);
      return [];
    }
  }

  /// Get today's attendance summary for manager dashboard
  static Future<Map<String, int>> getManagerAttendanceSummary() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final employees = await getActiveEmployeesForManager();
      final totalActive = employees.length;
      
      final attendanceRecords = await getAttendanceByDateForManager(today);
      
      final attendanceMap = <String, Map<String, dynamic>>{};
      for (var record in attendanceRecords) {
        final empCode = record['employee_code'];
        if (empCode != null && empCode.toString().isNotEmpty) {
          attendanceMap[empCode.toString()] = record;
        }
      }
      
      int present = 0;
      int late = 0;
      
      for (var employee in employees) {
        final empCode = employee['employee_code']?.toString() ?? '';
        
        if (empCode.isNotEmpty && attendanceMap.containsKey(empCode)) {
          final attendance = attendanceMap[empCode]!;
          
          if (attendance['check_in_time'] != null && attendance['check_in_time'].toString().isNotEmpty) {
            try {
              // Parse check-in time (could be space-separated or ISO format)
              final checkInStr = attendance['check_in_time'].toString().trim();
              final checkInUtc = DateTime.parse(checkInStr.replaceAll(' ', 'T'));
              final checkInIst = checkInUtc.add(const Duration(hours: 5, minutes: 30));
              
              present++;
              
              // Extract just the time portion for comparison
              final checkInHour = checkInIst.hour;
              final checkInMinute = checkInIst.minute;
              
              // Late if after 10:15 AM (10 hours 15 minutes)
              final isLate = checkInHour > 10 || (checkInHour == 10 && checkInMinute > 15);
              
              if (isLate) {
                late++;
              }
            } catch (e) {
              // Silent fail
            }
          }
        }
      }
      
      final absent = totalActive - present;
      
      return {
        'active': totalActive,
        'present': present,
        'absent': absent,
        'late': late,
      };
    } catch (e) {
      
      return {
        'active': 0,
        'present': 0,
        'absent': 0,
        'late': 0,
      };
    }
  }

  /// Get detailed attendance records for manager detail screen
  static Future<List<Map<String, dynamic>>> getManagerDetailedAttendance(DateTime date) async {
    try {
      final employees = await getActiveEmployeesForManager();
      final attendanceRecords = await getAttendanceByDateForManager(date);
      
      final attendanceMap = <String, Map<String, dynamic>>{};
      for (var record in attendanceRecords) {
        final empCode = record['employee_code'];
        if (empCode != null && empCode.toString().isNotEmpty) {
          attendanceMap[empCode.toString()] = record;
        }
      }
      
      final List<Map<String, dynamic>> records = [];
      
      for (var employee in employees) {
        final empCode = employee['employee_code']?.toString() ?? '';
        final empName = employee['employee_name']?.toString() ?? '';
        final wfh = employee['wfh'] ?? false;
        final dateOfJoining = employee['date_of_joining'];
        
        if (empCode.isEmpty) continue;
        
        if (attendanceMap.containsKey(empCode)) {
          final attendance = attendanceMap[empCode]!;
          
          DateTime? checkInIst;
          DateTime? checkOutIst;
          bool isLate = false;
          
          if (attendance['check_in_time'] != null && attendance['check_in_time'].toString().isNotEmpty) {
            try {
              final checkInStr = attendance['check_in_time'].toString().trim();
              final checkInUtc = DateTime.parse(checkInStr.replaceAll(' ', 'T'));
              checkInIst = checkInUtc.add(const Duration(hours: 5, minutes: 30));
              
              // Late if after 10:15 AM
              final checkInHour = checkInIst.hour;
              final checkInMinute = checkInIst.minute;
              isLate = checkInHour > 10 || (checkInHour == 10 && checkInMinute > 15);
            } catch (e) {
              // Silent fail
            }
          }
          
          if (attendance['check_out_time'] != null && attendance['check_out_time'].toString().isNotEmpty) {
            try {
              final checkOutStr = attendance['check_out_time'].toString().trim();
              final checkOutUtc = DateTime.parse(checkOutStr.replaceAll(' ', 'T'));
              checkOutIst = checkOutUtc.add(const Duration(hours: 5, minutes: 30));
            } catch (e) {
              // Silent fail
            }
          }
          
          records.add({
            'employee_code': empCode,
            'employee_name': empName,
            'designation': employee['designation']?.toString() ?? '',
            'wfh': wfh,
            'date_of_joining': dateOfJoining,
            'check_in_time': checkInIst,
            'check_out_time': checkOutIst,
            'check_in_selfie': attendance['check_in_selfie'],
            'check_out_selfie': attendance['check_out_selfie'],
            'is_present': true,
            'is_late': isLate,
            'status': attendance['status'],
            'remarks': attendance['remarks'],
            'record_id': attendance['id'],
            'collection_id': attendance['collectionId'],
          });
        } else {
          records.add({
            'employee_code': empCode,
            'employee_name': empName,
            'designation': employee['designation']?.toString() ?? '',
            'wfh': wfh,
            'date_of_joining': dateOfJoining,
            'check_in_time': null,
            'check_out_time': null,
            'check_in_selfie': null,
            'check_out_selfie': null,
            'is_present': false,
            'is_late': false,
            'status': null,
            'remarks': null,
            'record_id': null,
            'collection_id': null,
          });
        }
      }
      
      // Sort: Present first (on-time, then late), then absent
      records.sort((a, b) {
        if (a['is_present'] && !b['is_present']) return -1;
        if (!a['is_present'] && b['is_present']) return 1;
        
        if (a['is_present'] && b['is_present']) {
          if (a['is_late'] && !b['is_late']) return 1;
          if (!a['is_late'] && b['is_late']) return -1;
          
          if (a['check_in_time'] != null && b['check_in_time'] != null) {
            return (a['check_in_time'] as DateTime).compareTo(b['check_in_time'] as DateTime);
          }
        }
        
        return (a['employee_name'] as String).compareTo(b['employee_name'] as String);
      });
      
      return records;
    } catch (e) {
      
      return [];
    }
  }

  /// Get individual employee's attendance history for date range
  static Future<List<Map<String, dynamic>>> getEmployeeAttendanceHistory({
    required String employeeCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch all attendance records for the employee within date range in ONE call
      final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate.add(const Duration(days: 1)));
      
      List<dynamic> attendanceRecords = [];
      
      try {
        attendanceRecords = await PB.pb.collection('attendance').getFullList(
          filter: 'employee_code = "$employeeCode" && attendance_date >= "$startStr" && attendance_date < "$endStr"',
          sort: '-attendance_date',
        );
      } catch (e) {
      
      }
      
      // Fetch holidays for the date range
      List<dynamic> holidayRecords = [];
      try {
        holidayRecords = await PB.pb.collection('holiday').getFullList(
          filter: 'active = true && holiday_date >= "$startStr" && holiday_date < "$endStr"',
        );
      } catch (e) {
      
      }
      
      // Create a map of date -> attendance record
      final attendanceMap = <String, Map<String, dynamic>>{};
      for (var record in attendanceRecords) {
        try {
          final attendanceDate = record.data['attendance_date'];
          if (attendanceDate != null) {
            final date = DateTime.parse(attendanceDate);
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            attendanceMap[dateKey] = record.toJson();
          }
        } catch (e) {
          // Skip invalid records
        }
      }
      
      // Create a map of date -> holiday name
      final holidayMap = <String, String>{};
      for (var record in holidayRecords) {
        try {
          final holidayDate = record.data['holiday_date'];
          final holidayName = record.data['holiday_name'];
          if (holidayDate != null && holidayName != null) {
            final date = DateTime.parse(holidayDate);
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            holidayMap[dateKey] = holidayName.toString();
          }
        } catch (e) {
          // Skip invalid records
        }
      }
      
      // Build result list for each date in range
      final records = <Map<String, dynamic>>[];
      DateTime currentDate = startDate;
      
      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
        final employeeRecord = attendanceMap[dateKey] ?? {};
        final holidayName = holidayMap[dateKey];
        
        DateTime? checkInIst;
        DateTime? checkOutIst;
        bool isLate = false;
        bool isPresent = false;
        bool isHoliday = holidayName != null;
        
        if (employeeRecord.isNotEmpty && employeeRecord['check_in_time'] != null) {
          isPresent = true;
          
          try {
            final checkInStr = employeeRecord['check_in_time'].toString().trim();
            final checkInUtc = DateTime.parse(checkInStr.replaceAll(' ', 'T'));
            checkInIst = checkInUtc.add(const Duration(hours: 5, minutes: 30));
            
            // Late if after 10:15 AM
            final checkInHour = checkInIst.hour;
            final checkInMinute = checkInIst.minute;
            isLate = checkInHour > 10 || (checkInHour == 10 && checkInMinute > 15);
          } catch (e) {
            // Silent fail
          }
          
          if (employeeRecord['check_out_time'] != null && employeeRecord['check_out_time'].toString().isNotEmpty) {
            try {
              final checkOutStr = employeeRecord['check_out_time'].toString().trim();
              final checkOutUtc = DateTime.parse(checkOutStr.replaceAll(' ', 'T'));
              checkOutIst = checkOutUtc.add(const Duration(hours: 5, minutes: 30));
            } catch (e) {
              // Silent fail
            }
          }
        }
        
        records.add({
          'date': currentDate,
          'check_in_time': checkInIst,
          'check_out_time': checkOutIst,
          'check_in_selfie': employeeRecord['check_in_selfie'],
          'check_out_selfie': employeeRecord['check_out_selfie'],
          'is_present': isPresent,
          'is_late': isLate,
          'is_holiday': isHoliday,
          'holiday_name': holidayName,
          'status': employeeRecord['status'],
          'remarks': employeeRecord['remarks'],
          'record_id': employeeRecord['id'],
          'collection_id': employeeRecord['collectionId'],
        });
        
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      // Sort by date (newest first)
      records.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      return records;
    } catch (e) {
      return [];
    }
  }

  /// Update attendance status (Certification by BH) with full audit trail
  static Future<void> updateAttendanceStatus({
    required String recordId,
    required String status,
    required String remarks,
    required String approvedBy,
    required String approvalDate,
  }) async {
    try {
      await PB.pb.collection('attendance').update(recordId, body: {
        'status': status,
        'remarks': remarks,
        'approved_by': approvedBy,
        'approval_date': approvalDate,
        'approval_type': 'Manager',
      });
    } catch (e) {
      throw Exception('Failed to certify attendance: $e');
    }
  }

  /// Get a single attendance record for an employee on a specific date
  static Future<Map<String, dynamic>?> getSingleAttendanceRecord(String employeeCode, DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final records = await PB.pb.collection('attendance').getList(
        filter: 'employee_code = "$employeeCode" && attendance_date ~ "$dateStr"',
        perPage: 1,
      );
      
      if (records.items.isNotEmpty) {
        return records.items.first.toJson();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

