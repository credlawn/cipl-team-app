import 'package:flutter/material.dart';
import '../../core/pb_api.dart';
import '../../services/attendance_service.dart';
import '../quick_stat_card.dart';
import '../../screens/leave_application_screen.dart';

class MonthlyMetricsCard extends StatelessWidget {
  final VoidCallback? onLeaveTap;

  const MonthlyMetricsCard({
    super.key,
    this.onLeaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: AttendanceService.getMonthlyStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'present': 0, 'late': 0, 'absent': 0, 'holiday': 0, 'leave': 0};
        final user = PB.pb.authStore.record;
        final leaveBalance = user?.getIntValue('paid_leave_balance') ?? 0;
        
        return SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              QuickStatCard(
                icon: Icons.check_circle_rounded,
                value: '${stats['present']}',
                label: 'Present',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 12),
              QuickStatCard(
                icon: Icons.cancel_rounded,
                value: '${stats['absent']}',
                label: 'Absent',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 12),
              QuickStatCard(
                icon: Icons.schedule_rounded,
                value: '${stats['late']}',
                label: 'Late',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaveApplicationScreen()),
                  );
                  onLeaveTap?.call();
                },
                child: QuickStatCard(
                  icon: Icons.event_available_rounded,
                  value: '$leaveBalance',
                  label: 'Leave',
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
