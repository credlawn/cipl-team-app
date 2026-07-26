import '../core/pb_api.dart';

class ManagerTaskService {
  static Future<Map<String, int>> getTaskCounts() async {
    try {
      final now = DateTime.now();
      // Start of today in IST (local time)
      final todayIST = DateTime(now.year, now.month, now.day);
      // Convert to UTC for PocketBase comparison
      final todayUTC = todayIST.toUtc();
      final dateStr = todayUTC.toIso8601String().replaceFirst('T', ' ').split('.').first;

      // Fetch counts for each category from PocketBase
      // We use getList with perPage: 1 to get the totalItems efficiently
      final results = await Future.wait([
        PB.pb.collection('vkyc').getList(
          page: 1,
          perPage: 1,
          filter: 'bank_vkyc_status ~ "pending" && vkyc_expiry_date >= "$dateStr" && remove_data = false',
        ),
        PB.pb.collection('bkyc').getList(
          page: 1,
          perPage: 1,
          filter: 'bank_status ~ "pending" && remove_data = false',
        ),
        PB.pb.collection('activation').getList(
          page: 1,
          perPage: 1,
          filter: 'bank_status ~ "inactive" && remove_data = false',
        ),
      ]);

      return {
        'vkyc': results[0].totalItems,
        'bkyc': results[1].totalItems,
        'activation': results[2].totalItems,
      };
    } catch (e) {
      print('Error fetching manager task counts: $e');
      return {
        'vkyc': 0,
        'bkyc': 0,
        'activation': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> getActivationDetailedBreakdown() async {
    try {
      // Check if current user has bh_access
      final model = PB.pb.authStore.model;
      // Depending on PB SDK version/setup, it might be a Map or a RecordModel
      bool hasBHAccess = false;
      if (model != null) {
        // Try accessing via data map (standard for RecordModel)
        try {
          hasBHAccess = model.data['bh_access'] == true;
        } catch (e) {
          // Fallback if it's treated as a dynamic/map
          hasBHAccess = (model as dynamic).data['bh_access'] == true;
        }
      }

      String filter = 'bank_status ~ "inactive"';
      if (!hasBHAccess) {
        filter += ' && remove_data = false';
      }

      // Fetch all pending activation records from the server
      final records = await PB.pb.collection('activation').getFullList(
        filter: filter,
      );

      // 1. Calculate Month Strings (e.g., "Apr-26")
      final now = DateTime.now();
      final lastMonthDate = DateTime(now.year, now.month - 1);
      
      final currentMonthStr = _formatDecisionMonth(now);
      final lastMonthStr = _formatDecisionMonth(lastMonthDate);

      // 2. Aggregate Data
      final Map<String, Map<String, int>> employeeData = {};
      final Map<String, List<Map<String, dynamic>>> employeeCustomers = {};
      final List<Map<String, dynamic>> pendingCustomersRaw = [];
      
      int currentMonthTotal = 0;
      int lastMonthTotal = 0;
      int currentMonthActivated = 0;
      int lastMonthActivated = 0;
      int totalActivated = 0;
      
      int currentMonthToday = 0;
      int lastMonthToday = 0;
      int totalToday = 0;

      final nowIST = DateTime.now(); // Flutter runs in device local time (IST)

      final normalizedCurrentMonth = currentMonthStr.toLowerCase().trim();
      final normalizedLastMonth = lastMonthStr.toLowerCase().trim();

      for (var record in records) {
        final rawName = record.data['employee_name']?.toString() ?? 'Unknown';
        final name = rawName.trim();
        
        final month = record.data['decision_month']?.toString().toLowerCase().trim() ?? '';

        // Check if user_status_date is today in IST
        bool isTodayIST = false;
        final statusDateStr = record.data['user_status_date']?.toString() ?? '';
        if (statusDateStr.isNotEmpty) {
          try {
            // PB returns UTC string. Parse it as UTC explicitly.
            final utcDate = DateTime.parse(statusDateStr.endsWith('Z') ? statusDateStr : '${statusDateStr}Z');
            final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));
            if (istDate.year == nowIST.year && istDate.month == nowIST.month && istDate.day == nowIST.day) {
              isTodayIST = true;
            }
          } catch (e) {
            // ignore
          }
        }

        // Initialize employee data if not exists
        if (!employeeData.containsKey(name)) {
          employeeData[name] = {
            'total': 0,
            'current': 0,
            'last': 0,
            'activated': 0,
            'current_activated': 0,
            'last_activated': 0,
            'today': 0,
            'current_today': 0,
            'last_today': 0,
          };
        }

        // Increment counts
        employeeData[name]!['total'] = (employeeData[name]!['total'] ?? 0) + 1;

        final rawUserStatus = record.data['user_status']?.toString().toLowerCase() ?? '';
        final userStatus = rawUserStatus.replaceAll(RegExp(r'\s+'), ''); // Remove all spaces for safe matching
        final isActivated = userStatus.contains('activationdone') || userStatus.contains('transactiondone');
        
        // Store raw customer for detail view
        employeeCustomers.putIfAbsent(name, () => []).add({
          'id': record.id,
          'customer_name': record.data['customer_name']?.toString().trim() ?? 'Unknown',
          'product': record.data['product_name']?.toString().trim() ?? record.data['product']?.toString().trim() ?? 'Unknown',
          'user_status': record.data['user_status']?.toString().trim() ?? 'Pending', // Original case
          'decision_month': month,
          'is_today': isTodayIST,
          'is_activated': isActivated,
          'decision_date': record.data['decision_date']?.toString().trim() ?? '',
          'arn_no': record.data['arn_no']?.toString().trim() ?? '',
          'user_status_date': record.data['user_status_date']?.toString().trim() ?? '',
          'user_remarks': record.data['user_remarks']?.toString().trim() ?? '',
          'mobile_no': record.data['mobile_no']?.toString().trim() ?? '',
          'remove_data': record.data['remove_data'] == true,
        });

        if (!isActivated) {
          pendingCustomersRaw.add({
            'employee_name': name,
            'customer_name': record.data['customer_name']?.toString().trim() ?? 'Unknown',
            'product': record.data['product_name']?.toString().trim() ?? record.data['product']?.toString().trim() ?? 'Unknown',
            'decision_month': month,
            'is_today': isTodayIST,
            'is_activated': isActivated,
            'decision_date': record.data['decision_date']?.toString().trim() ?? '',
            'arn_no': record.data['arn_no']?.toString().trim() ?? '',
            'user_status_date': record.data['user_status_date']?.toString().trim() ?? '',
            'user_remarks': record.data['user_remarks']?.toString().trim() ?? '',
            'mobile_no': record.data['mobile_no']?.toString().trim() ?? '',
            'remove_data': record.data['remove_data'] == true,
          });
        }
        
        if (isActivated) {
          employeeData[name]!['activated'] = (employeeData[name]!['activated'] ?? 0) + 1;
          totalActivated++;
          if (isTodayIST) {
            employeeData[name]!['today'] = (employeeData[name]!['today'] ?? 0) + 1;
            totalToday++;
          }
        }

        if (month == normalizedCurrentMonth) {
          employeeData[name]!['current'] = (employeeData[name]!['current'] ?? 0) + 1;
          if (isActivated) {
            employeeData[name]!['current_activated'] = (employeeData[name]!['current_activated'] ?? 0) + 1;
            currentMonthActivated++;
            if (isTodayIST) {
              employeeData[name]!['current_today'] = (employeeData[name]!['current_today'] ?? 0) + 1;
              currentMonthToday++;
            }
          }
          currentMonthTotal++;
        } else if (month == normalizedLastMonth) {
          employeeData[name]!['last'] = (employeeData[name]!['last'] ?? 0) + 1;
          if (isActivated) {
            employeeData[name]!['last_activated'] = (employeeData[name]!['last_activated'] ?? 0) + 1;
            lastMonthActivated++;
            if (isTodayIST) {
              employeeData[name]!['last_today'] = (employeeData[name]!['last_today'] ?? 0) + 1;
              lastMonthToday++;
            }
          }
          lastMonthTotal++;
        }
      }

      // 3. Prepare Employee List
      final employeeList = employeeData.entries.map((e) => {
        'employee_name': e.key,
        'total': e.value['total'],
        'current': e.value['current'],
        'last': e.value['last'],
        'activated': e.value['activated'],
        'current_activated': e.value['current_activated'],
        'last_activated': e.value['last_activated'],
        'today': e.value['today'],
        'current_today': e.value['current_today'],
        'last_today': e.value['last_today'],
        'customers': employeeCustomers[e.key] ?? [],
      }).toList();
      
      employeeList.sort((a, b) {
        final balA = (a['total'] as int) - (a['activated'] as int);
        final balB = (b['total'] as int) - (b['activated'] as int);
        return balB.compareTo(balA);
      });

      return {
        'employees': employeeList,
        'pending_customers': pendingCustomersRaw,
        'summary': {
          'total': records.length,
          'total_activated': totalActivated,
          'total_today': totalToday,
          'current_month': {
            'label': currentMonthStr,
            'count': currentMonthTotal,
            'activated': currentMonthActivated,
            'today': currentMonthToday,
          },
          'last_month': {
            'label': lastMonthStr,
            'count': lastMonthTotal,
            'activated': lastMonthActivated,
            'today': lastMonthToday,
          },
        }
      };
    } catch (e) {
      print('Error fetching activation detailed breakdown: $e');
      return {
        'employees': [],
        'pending_customers': [],
        'summary': {
          'total': 0,
          'total_activated': 0,
          'total_today': 0,
          'current_month': {'label': 'N/A', 'count': 0, 'activated': 0, 'today': 0},
          'last_month': {'label': 'N/A', 'count': 0, 'activated': 0, 'today': 0},
        }
      };
    }
  }

  static Future<Map<String, dynamic>> getBKYCDetailedBreakdown() async {
    try {
      final model = PB.pb.authStore.model;
      bool hasBHAccess = false;
      if (model != null) {
        try {
          hasBHAccess = model.data['bh_access'] == true;
        } catch (e) {
          hasBHAccess = (model as dynamic).data['bh_access'] == true;
        }
      }

      String filter = 'bank_status ~ "pending"';
      if (!hasBHAccess) {
        filter += ' && remove_data = false';
      }

      final records = await PB.pb.collection('bkyc').getFullList(filter: filter);

      // ARN month keys: arn_no format D26E09... → year='26', letter='E'
      // key = '26E', label = 'May-26'
      final now = DateTime.now();
      final currentLetter = String.fromCharCode(64 + now.month);
      final currentYear = (now.year % 100).toString().padLeft(2, '0');
      final currentArnMonthKey = '$currentYear$currentLetter';

      final lastMonthDate = DateTime(now.year, now.month - 1);
      final lastLetter = String.fromCharCode(64 + lastMonthDate.month);
      final lastYear = (lastMonthDate.year % 100).toString().padLeft(2, '0');
      final lastArnMonthKey = '$lastYear$lastLetter';

      final prevMonthDate = DateTime(now.year, now.month - 2);
      final prevLetter = String.fromCharCode(64 + prevMonthDate.month);
      final prevYear = (prevMonthDate.year % 100).toString().padLeft(2, '0');
      final prevArnMonthKey = '$prevYear$prevLetter';

      final currentMonthLabel = _arnMonthLabel(currentArnMonthKey);
      final lastMonthLabel = _arnMonthLabel(lastArnMonthKey);
      final prevMonthLabel = _arnMonthLabel(prevArnMonthKey);

      final Map<String, Map<String, int>> employeeData = {};
      final Map<String, List<Map<String, dynamic>>> employeeCustomers = {};
      final List<Map<String, dynamic>> pendingCustomersRaw = [];

      int total = 0, totalActivated = 0, totalDenied = 0, totalToday = 0;
      int currentMonthTotal = 0, lastMonthTotal = 0, prevMonthTotal = 0;
      int currentMonthActivated = 0, lastMonthActivated = 0, prevMonthActivated = 0;
      int currentMonthDenied = 0, lastMonthDenied = 0, prevMonthDenied = 0;
      int currentMonthToday = 0, lastMonthToday = 0, prevMonthToday = 0;

      final nowIST = DateTime.now();

      for (var record in records) {
        final rawName = record.data['employee_name']?.toString() ?? 'Unknown';
        final name = rawName.trim();

        // Parse ARN month key from arn_no
        final arnNo = record.data['arn_no']?.toString().trim() ?? '';
        final arnMonthKey = (arnNo.length >= 4) ? '${arnNo.substring(1, 3)}${arnNo[3]}' : '';

        // Check if user_status_date is today in IST
        bool isTodayIST = false;
        final statusDateStr = record.data['user_status_date']?.toString() ?? '';
        if (statusDateStr.isNotEmpty) {
          try {
            final utcDate = DateTime.parse(statusDateStr.endsWith('Z') ? statusDateStr : '${statusDateStr}Z');
            final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));
            if (istDate.year == nowIST.year && istDate.month == nowIST.month && istDate.day == nowIST.day) {
              isTodayIST = true;
            }
          } catch (e) {}
        }

        if (!employeeData.containsKey(name)) {
          employeeData[name] = {
            'total': 0, 'activated': 0, 'denied': 0, 'today': 0,
            'current': 0, 'current_activated': 0, 'current_denied': 0, 'current_today': 0,
            'last': 0, 'last_activated': 0, 'last_denied': 0, 'last_today': 0,
            'prev': 0, 'prev_activated': 0, 'prev_denied': 0, 'prev_today': 0,
          };
        }

        employeeData[name]!['total'] = (employeeData[name]!['total'] ?? 0) + 1;
        total++;

        final rawUserStatus = record.data['user_status']?.toString().toLowerCase() ?? '';
        final userStatus = rawUserStatus.replaceAll(RegExp(r'\s+'), '');
        final isActivated = userStatus.contains('complete') || userStatus.contains('appointmentbooked');
        final isDenied = userStatus.contains('denied');

        if (isActivated) {
          employeeData[name]!['activated'] = (employeeData[name]!['activated'] ?? 0) + 1;
          totalActivated++;
          if (isTodayIST) {
            employeeData[name]!['today'] = (employeeData[name]!['today'] ?? 0) + 1;
            totalToday++;
          }
        } else if (isDenied) {
          employeeData[name]!['denied'] = (employeeData[name]!['denied'] ?? 0) + 1;
          totalDenied++;
        }

        // ARN month bucketing
        if (arnMonthKey == currentArnMonthKey) {
          employeeData[name]!['current'] = (employeeData[name]!['current'] ?? 0) + 1;
          currentMonthTotal++;
          if (isActivated) {
            employeeData[name]!['current_activated'] = (employeeData[name]!['current_activated'] ?? 0) + 1;
            currentMonthActivated++;
            if (isTodayIST) {
              employeeData[name]!['current_today'] = (employeeData[name]!['current_today'] ?? 0) + 1;
              currentMonthToday++;
            }
          } else if (isDenied) {
            employeeData[name]!['current_denied'] = (employeeData[name]!['current_denied'] ?? 0) + 1;
            currentMonthDenied++;
          }
        } else if (arnMonthKey == lastArnMonthKey) {
          employeeData[name]!['last'] = (employeeData[name]!['last'] ?? 0) + 1;
          lastMonthTotal++;
          if (isActivated) {
            employeeData[name]!['last_activated'] = (employeeData[name]!['last_activated'] ?? 0) + 1;
            lastMonthActivated++;
            if (isTodayIST) {
              employeeData[name]!['last_today'] = (employeeData[name]!['last_today'] ?? 0) + 1;
              lastMonthToday++;
            }
          } else if (isDenied) {
            employeeData[name]!['last_denied'] = (employeeData[name]!['last_denied'] ?? 0) + 1;
            lastMonthDenied++;
          }
        } else if (arnMonthKey == prevArnMonthKey) {
          employeeData[name]!['prev'] = (employeeData[name]!['prev'] ?? 0) + 1;
          prevMonthTotal++;
          if (isActivated) {
            employeeData[name]!['prev_activated'] = (employeeData[name]!['prev_activated'] ?? 0) + 1;
            prevMonthActivated++;
            if (isTodayIST) {
              employeeData[name]!['prev_today'] = (employeeData[name]!['prev_today'] ?? 0) + 1;
              prevMonthToday++;
            }
          } else if (isDenied) {
            employeeData[name]!['prev_denied'] = (employeeData[name]!['prev_denied'] ?? 0) + 1;
            prevMonthDenied++;
          }
        }

        employeeCustomers.putIfAbsent(name, () => []).add({
          'id': record.id,
          'customer_name': record.data['customer_name']?.toString().trim() ?? 'Unknown',
          'arn_no': arnNo,
          'arn_month': arnMonthKey,
          'user_status': record.data['user_status']?.toString().trim() ?? 'Pending',
          'bank_status': record.data['bank_status']?.toString().trim() ?? 'Pending',
          'user_status_date': statusDateStr,
          'is_today': isTodayIST,
          'is_activated': isActivated,
          'user_remarks': record.data['user_remarks']?.toString().trim() ?? '',
          'bank_remarks': record.data['bank_remarks']?.toString().trim() ?? '',
          'mobile_no': record.data['mobile_no']?.toString().trim() ?? '',
          'remove_data': record.data['remove_data'] == true,
        });

        if (!isActivated && !isDenied) {
          pendingCustomersRaw.add({
            'employee_name': name,
            'customer_name': record.data['customer_name']?.toString().trim() ?? 'Unknown',
            'arn_no': arnNo,
            'arn_month': arnMonthKey,
            'user_status': record.data['user_status']?.toString().trim() ?? 'Pending',
            'bank_status': record.data['bank_status']?.toString().trim() ?? 'Pending',
            'user_status_date': statusDateStr,
            'is_today': isTodayIST,
            'is_activated': isActivated,
            'user_remarks': record.data['user_remarks']?.toString().trim() ?? '',
            'bank_remarks': record.data['bank_remarks']?.toString().trim() ?? '',
            'mobile_no': record.data['mobile_no']?.toString().trim() ?? '',
            'remove_data': record.data['remove_data'] == true,
          });
        }
      }

      final employeeList = employeeData.entries.map((e) => {
        'employee_name': e.key,
        'total': e.value['total'],
        'activated': e.value['activated'],
        'denied': e.value['denied'],
        'today': e.value['today'],
        'current': e.value['current'],
        'current_activated': e.value['current_activated'],
        'current_denied': e.value['current_denied'],
        'current_today': e.value['current_today'],
        'last': e.value['last'],
        'last_activated': e.value['last_activated'],
        'last_denied': e.value['last_denied'],
        'last_today': e.value['last_today'],
        'prev': e.value['prev'],
        'prev_activated': e.value['prev_activated'],
        'prev_denied': e.value['prev_denied'],
        'prev_today': e.value['prev_today'],
        'customers': employeeCustomers[e.key] ?? [],
      }).toList();

      employeeList.sort((a, b) {
        final balA = (a['total'] as int) - (a['activated'] as int) - (a['denied'] as int);
        final balB = (b['total'] as int) - (b['activated'] as int) - (b['denied'] as int);
        return balB.compareTo(balA);
      });

      return {
        'employees': employeeList,
        'pending_customers': pendingCustomersRaw,
        'summary': {
          'total': total,
          'total_activated': totalActivated,
          'total_denied': totalDenied,
          'total_today': totalToday,
          'current_month': {
            'label': currentMonthLabel,
            'count': currentMonthTotal,
            'activated': currentMonthActivated,
            'denied': currentMonthDenied,
            'today': currentMonthToday,
          },
          'last_month': {
            'label': lastMonthLabel,
            'count': lastMonthTotal,
            'activated': lastMonthActivated,
            'denied': lastMonthDenied,
            'today': lastMonthToday,
          },
          'prev_month': {
            'label': prevMonthLabel,
            'count': prevMonthTotal,
            'activated': prevMonthActivated,
            'denied': prevMonthDenied,
            'today': prevMonthToday,
          },
        },
      };
    } catch (e) {
      print('Error fetching BKYC detailed breakdown: $e');
      return {
        'employees': [],
        'pending_customers': [],
        'summary': {
          'total': 0,
          'total_activated': 0,
          'total_denied': 0,
          'total_today': 0,
          'current_month': {'label': 'N/A', 'count': 0, 'activated': 0, 'denied': 0, 'today': 0},
          'last_month': {'label': 'N/A', 'count': 0, 'activated': 0, 'denied': 0, 'today': 0},
          'prev_month': {'label': 'N/A', 'count': 0, 'activated': 0, 'denied': 0, 'today': 0},
        },
      };
    }
  }

  // ARN month key '26E' → 'May-26'
  static String _arnMonthLabel(String key) {
    if (key.length < 3) return key;
    const m = {
      'A': 'Jan', 'B': 'Feb', 'C': 'Mar', 'D': 'Apr',
      'E': 'May', 'F': 'Jun', 'G': 'Jul', 'H': 'Aug',
      'I': 'Sep', 'J': 'Oct', 'K': 'Nov', 'L': 'Dec',
    };
    return '${m[key[2]] ?? key[2]}-${key.substring(0, 2)}';
  }

  static Future<bool> updateCustomerStatus(String id, String status) async {
    try {
      final now = DateTime.now().toUtc();
      final dateStr = now.toIso8601String().replaceFirst('T', ' ').split('.').first;

      await PB.pb.collection('activation').update(id, body: {
        'user_status': status,
        'user_status_date': dateStr,
      });
      return true;
    } catch (e) {
      print('Error updating customer status: $e');
      return false;
    }
  }

  static String _formatDecisionMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthStr = months[date.month - 1];
    final yearStr = date.year.toString().substring(2);
    return '$monthStr-$yearStr';
  }
  static Future<bool> updateRemoveDataStatus(String id, bool remove) async {
    try {
      await PB.pb.collection('activation').update(id, body: {
        'remove_data': remove,
      });
      return true;
    } catch (e) {
      print('Error updating remove_data: $e');
      return false;
    }
  }
}
