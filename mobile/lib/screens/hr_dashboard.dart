import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' hide Column;
import '../database/app_database.dart';
import '../core/pb_api.dart';
import '../services/attendance_service.dart';
import '../services/leave_service.dart';
import '../services/holiday_service.dart';
import '../services/lead_service.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/hr/monthly_metrics_card.dart';
import '../widgets/hr/upcoming_holidays_card.dart';
import 'check_in_screen.dart';
import 'leave_application_screen.dart';
import '../services/daily_security_service.dart';

class HRDashboard extends StatefulWidget {
  const HRDashboard({super.key});

  @override
  State<HRDashboard> createState() => _HRDashboardState();
}

class _HRDashboardState extends State<HRDashboard> {
  bool _isLoading = false;
  bool _isSyncing = false;
  late final Stream<AttendanceData?> _attendanceStream;
  AttendanceData? _lastKnownAttendance;

  // FIX D: Debounce timer to absorb transient null emissions from the Drift
  // stream that occur when _syncAttendanceToPocketBase swaps temp-UUID records
  // for server-ID records inside a DB transaction.
  Timer? _nullDebounceTimer;

  @override
  void initState() {
    super.initState();
    DailySecurityService.checkDailyVerification(context);
    _attendanceStream = AttendanceService.watchTodayAttendance();
  }

  @override
  void dispose() {
    _nullDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = PB.pb.authStore.record;
    final userName = user?.getStringValue('employee_name') ?? 'User';
    final firstName = userName.split(' ').first;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('HR', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        actions: [
          IconButton(
            icon: _isSyncing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _isSyncing ? null : _manualSync,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<AttendanceData?>(
        stream: _attendanceStream,
        builder: (context, snapshot) {

          // FIX D: Null-debounce guard.
          //
          // The Drift stream fires after EVERY SQL statement inside a transaction.
          // When _syncAttendanceToPocketBase runs, it does:
          //   1. INSERT server-record  → stream emits the record ✅
          //   2. DELETE temp-record    → stream briefly emits null ← this was the bug
          // (With FIX A, the order is now INSERT-then-DELETE, but as defense-in-depth
          //  we also keep this debounce to handle any future edge cases.)
          //
          // Logic:
          // • Non-null data  → cancel any pending debounce, update immediately ✅
          // • Null data      → if we previously had a record, wait 3 s before
          //                    accepting null (absorbs the transaction gap)
          // • Null data      → if _lastKnownAttendance is already null (user
          //                    genuinely not checked in), accept immediately ✅
          if (snapshot.data != null) {
            _nullDebounceTimer?.cancel();
            _nullDebounceTimer = null;
            _lastKnownAttendance = snapshot.data;
          } else if (_lastKnownAttendance != null) {
            // We had a record — don't wipe it instantly. Debounce.
            _nullDebounceTimer ??= Timer(const Duration(seconds: 3), () {
              if (mounted) setState(() => _lastKnownAttendance = null);
            });
          }
          // If _lastKnownAttendance is already null and snapshot.data is null,
          // nothing to do — user is genuinely not checked in.

          return RefreshIndicator(
            onRefresh: _manualSync,
            child: _buildContent(_lastKnownAttendance),
          );
        },
      ),
    );
  }

  Widget _buildContent(AttendanceData? attendance) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(_getFirstName()),
          const SizedBox(height: 16),
          _buildStatusCard(attendance),
          const SizedBox(height: 16),
          _buildMonthlyMetrics(),
          const SizedBox(height: 16),
          _buildWeeklyTimeline(),
          const SizedBox(height: 16),
          _buildUpcomingHolidays(),
          _buildRecentManagerActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentManagerActions() {
    final user = PB.pb.authStore.record;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<List<AttendanceData>>(
      future: (LeadService.db.select(LeadService.db.attendance)
            ..where((t) => t.employeeId.equals(user.id) & t.approvalType.equals('Manager'))
            ..orderBy([(t) => OrderingTerm.desc(t.attendanceDate)])
            ..limit(4))
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final actions = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 0, 10),
              child: Text(
                'APPROVAL ALERT BY MANAGER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                children: actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  final dateStr = DateFormat('dd MMM').format(action.attendanceDate);
                  final status = action.status ?? 'Updated';
                  final statusColor = _getStatusColor(status);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.assignment_turned_in_outlined, size: 16, color: statusColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Marked $status',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      children: [
                                        if (action.remarks?.isNotEmpty == true)
                                          const TextSpan(
                                            text: 'Reason: ',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        TextSpan(
                                          text: action.remarks?.isNotEmpty == true 
                                              ? action.remarks! 
                                              : 'Certified by Manager',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < actions.length - 1)
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('full') || s == 'present') {
      return const Color(0xFF10B981); // Green
    } else if (s.contains('half')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (s.contains('absent')) {
      return const Color(0xFFEF4444); // Red
    } else if (s.contains('leave')) {
      return const Color(0xFF34D399); // Light Green
    } else if (s == 'holiday') {
      return const Color(0xFF8B5CF6); // Purple
    }
    return const Color(0xFF6B7280); // Grey
  }

  String _getFirstName() {
    final user = PB.pb.authStore.record;
    final userName = user?.getStringValue('employee_name') ?? 'User';
    return userName.split(' ').first;
  }

  Widget _buildGreetingSection(String firstName) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';
    
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final user = PB.pb.authStore.record;
    final avatar = user?.getStringValue('avatar') ?? '';
    final avatarUrl = avatar.isNotEmpty
        ? '${PB.pb.baseUrl}/api/files/users/${user!.id}/$avatar'
        : '';
    
    return Row(
      children: [
        avatarUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                imageBuilder: (context, imageProvider) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                placeholder: (context, url) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $firstName! 👋',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(AttendanceData? attendance) {
    final user = PB.pb.authStore.record;
    final officeStartTime = user?.data['office_start_time'] ?? '10:15 AM';
    final today = DateTime.now();
    
    return FutureBuilder<String>(
      future: AttendanceService.calculateAttendanceStatus(
        checkInTime: attendance?.checkInTime,
        checkOutTime: attendance?.checkOutTime,
        date: today,
        officeStartTime: officeStartTime,
      ),
      builder: (context, snapshot) {
        
        // Show loading indicator only on first load, not on refresh
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If we have data or if we're refreshing with old data, show the card
        if (!snapshot.hasData) {

          return _buildNotCheckedInCard();
        }
        
        final status = snapshot.data!;

        
        // Handle cases where attendance is required
        if (status == 'Working' || status == 'Present' || status == 'Late') {
          if (attendance == null) {

            return _buildNotCheckedInCard();
          }
        }
        
        switch (status) {
          case 'Working':
            return _buildWorkingCard(attendance!);
          case 'Present':
          case 'Late':
            return _buildDayCompleteCard(attendance!, status);
          case 'Holiday':
            return _buildHolidayCard();
          case 'On Leave':
            return _buildOnLeaveCard();
          case 'Absent':
          default:
            return _buildNotCheckedInCard();
        }
      },
    );
  }

  Widget _buildNotCheckedInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFFEF4444)),
                    SizedBox(width: 6),
                    Text(
                      'Not Checked In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _navigateToCheckIn,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Check In Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.celebration, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      'Holiday',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _navigateToCheckIn,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Check In Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnLeaveCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_available, size: 16, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 6),
                    Text(
                      'On Leave',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _navigateToCheckIn,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Check In Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingCard(AttendanceData attendance) {
    final checkInTime = DateFormat('h:mm a').format(attendance.checkInTime);
    
    // Status is already calculated by _buildStatusCard, just display Working
    const status = 'Working';
    const statusColor = Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (attendance.checkInSelfie.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.photo_camera, size: 20),
                  color: const Color(0xFF3B82F6),
                  onPressed: () => _showSelfieOptions(attendance),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.login_rounded, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                'Checked in at $checkInTime',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _navigateToCheckOut(attendance.id),
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Check Out',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCompleteCard(AttendanceData attendance, String status) {
    final checkInTime = DateFormat('h:mm a').format(attendance.checkInTime);
    final checkOutTime = DateFormat('h:mm a').format(attendance.checkOutTime!);
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (attendance.checkInSelfie.isNotEmpty || 
                  (attendance.checkOutSelfie != null && attendance.checkOutSelfie!.isNotEmpty))
                IconButton(
                  icon: const Icon(Icons.photo_camera, size: 20),
                  color: const Color(0xFF3B82F6),
                  onPressed: () => _showSelfieOptions(attendance),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(Icons.login_rounded, 'In', checkInTime),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildTimeInfo(Icons.logout_rounded, 'Out', checkOutTime),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(IconData icon, String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyMetrics() {
    return MonthlyMetricsCard(
      onLeaveTap: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildWeeklyTimeline() {
    final user = PB.pb.authStore.record;
    final officeStartTime = user?.data['office_start_time'] ?? '10:15 AM';
    
    return FutureBuilder<List<AttendanceData>>(
      future: AttendanceService.getWeeklyAttendance(),
      builder: (context, snapshot) {
        final weekData = snapshot.data ?? [];
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final date = weekStart.add(Duration(days: index));
                  final dayName = DateFormat('E').format(date).substring(0, 1);
                  
                  // Use date-only comparison
                  final today = DateTime(now.year, now.month, now.day);
                  final dateOnly = DateTime(date.year, date.month, date.day);
                  final isToday = dateOnly.isAtSameMomentAs(today);
                  final isFuture = dateOnly.isAfter(today);
                  
                  // Find attendance for this date using date-only comparison
                  final attendance = weekData.firstWhere(
                    (a) {
                      final aDate = DateTime(a.attendanceDate.year, a.attendanceDate.month, a.attendanceDate.day);
                      return aDate.isAtSameMomentAs(dateOnly);
                    },
                    orElse: () => AttendanceData(
                      id: '',
                      employeeId: '',
                      employeeCode: '',
                      employeeName: '',
                      attendanceDate: date,
                      checkInTime: DateTime.now(),
                      checkInSelfie: '',
                      checkInLatitude: 0,
                      checkInLongitude: 0,
                      syncPending: false,
                    ),
                  );
                  
                  // Use FutureBuilder to calculate status for each day
                  return Expanded(
                    child: FutureBuilder<String>(
                      future: isFuture 
                        ? Future.value('Future')
                        : AttendanceService.calculateAttendanceStatus(
                            checkInTime: attendance.id.isNotEmpty ? attendance.checkInTime : null,
                            checkOutTime: attendance.checkOutTime,
                            date: date,
                            officeStartTime: officeStartTime,
                          ),
                      builder: (context, statusSnapshot) {
                        Color statusColor = const Color(0xFFE5E7EB);
                        IconData? statusIcon;
                        
                        if (statusSnapshot.hasData && !isFuture) {
                          final status = statusSnapshot.data!;
                          
                          // Show green check for: Check-in, Holiday, Leave
                          // Show blank for: Absent, Future
                          if (status == 'Working' || status == 'Present' || 
                              status == 'Late' || status == 'Holiday' || 
                              status == 'On Leave') {
                            statusColor = const Color(0xFF10B981); // Green
                            statusIcon = Icons.check_circle;
                          }
                        }
                        
                        return Column(
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                                color: isToday ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                                color: isToday ? const Color(0xFF3B82F6) : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 6),
                            statusIcon != null
                                ? Icon(
                                    statusIcon,
                                    size: 20,
                                    color: statusColor,
                                  )
                                : Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isToday 
                                            ? const Color(0xFF3B82F6)
                                            : const Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingHolidays() {
    return const UpcomingHolidaysCard();
  }


  void _showSelfieOptions(AttendanceData attendance) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_camera, color: Color(0xFF3B82F6), size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'View Selfies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (attendance.checkInSelfie.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _viewSelfie(attendance.checkInSelfie, 'Check-in Selfie');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.login, color: Color(0xFF3B82F6), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Check-in Selfie',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
              if (attendance.checkInSelfie.isNotEmpty && 
                  attendance.checkOutSelfie != null && 
                  attendance.checkOutSelfie!.isNotEmpty)
                const SizedBox(height: 12),
              if (attendance.checkOutSelfie != null && attendance.checkOutSelfie!.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _viewSelfie(attendance.checkOutSelfie!, 'Check-out Selfie');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Check-out Selfie',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewSelfie(String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                        SizedBox(height: 16),
                        Text('Failed to load image'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);

    try {
      // Auth refresh + non-attendance services run in parallel (safe)
      await Future.wait([
        PB.pb.collection('users').authRefresh(),
        LeaveService.syncUp(),
        LeaveService.syncDown(),
        HolidayService.syncDown(),
      ]);

      // FIX C2: Attendance sync runs SEQUENTIALLY — syncUp() first to flush
      // any pending local records, then syncDown() to reconcile with server.
      // Running them in parallel via Future.wait() caused syncPendingAttendance()
      // to be called from both paths simultaneously, triggering two concurrent
      // PB.create() calls for the same record → duplicate server records.
      await AttendanceService.syncUp();
      await AttendanceService.syncDown();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synced successfully'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync failed'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _navigateToCheckIn() async {
    setState(() => _isLoading = true);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckInScreen()),
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _navigateToCheckOut(String attendanceId) async {
    setState(() => _isLoading = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckInScreen(attendanceId: attendanceId),
      ),
    );
    if (mounted) setState(() => _isLoading = false);
  }
}
