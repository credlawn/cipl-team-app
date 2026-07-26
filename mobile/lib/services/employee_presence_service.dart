import '../utils/employee_filter_utils.dart';

/// Service for managing employee presence data with caching
/// Reduces repeated API calls for present employee list
class EmployeePresenceService {
  static Map<String, List<String>>? _cachedPresence;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// Get present employees with Office/WFH grouping
  /// Uses 5-minute cache to reduce API calls
  /// 
  /// Returns:
  /// {
  ///   'office': ['EMP001', 'EMP002'],
  ///   'wfh': ['EMP003'],
  ///   'all': ['EMP001', 'EMP002', 'EMP003']
  /// }
  static Future<Map<String, List<String>>> getPresentEmployees({
    bool forceRefresh = false,
    DateTime? date,
  }) async {
    // Return cached data if valid and date is today
    final isToday = date == null || 
        (date.year == DateTime.now().year && 
         date.month == DateTime.now().month && 
         date.day == DateTime.now().day);
    
    if (!forceRefresh && 
        isToday &&
        _cachedPresence != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedPresence!;
    }

    // Fetch fresh data from attendance
    final data = await EmployeeFilterUtils.getPresentEmployeesWithGrouping(date: date);
    
    // Update cache only for today
    if (isToday) {
      _cachedPresence = data;
      _cacheTime = DateTime.now();
    }
    
    return data;
  }

  /// Clear the cache
  /// Call this when you need to force refresh on next call
  static void clearCache() {
    _cachedPresence = null;
    _cacheTime = null;
  }

  /// Check if cache is valid
  static bool isCacheValid() {
    return _cachedPresence != null && 
           _cacheTime != null && 
           DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }

  /// Get cache age in seconds
  static int? getCacheAge() {
    if (_cacheTime == null) return null;
    return DateTime.now().difference(_cacheTime!).inSeconds;
  }
}
