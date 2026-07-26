import 'package:flutter/material.dart';
import '../services/manager_call_log_service.dart';

class CallLogsCard extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? summary;
  final VoidCallback? onRefresh;

  const CallLogsCard({
    super.key,
    required this.isLoading,
    required this.summary,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate average duration per call
    final totalCalls = summary?['total_calls'] ?? 0;
    final totalDuration = summary?['total_duration'] ?? 0;
    final avgDuration = totalCalls > 0 ? (totalDuration / totalCalls).round() : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'CALL ACTIVITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/manager/call-logs-detail');
              onRefresh?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        4,
                        (index) => _buildStatItemSkeleton(),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          value: summary?['present_count']?.toString() ?? '0',
                          label: 'Present',
                          color: const Color(0xFF3B82F6),
                        ),
                        _buildStatItem(
                          value: summary?['total_calls']?.toString() ?? '0',
                          label: 'Calls',
                          color: const Color(0xFF10B981),
                        ),
                        _buildStatItem(
                          value: ManagerCallLogService.formatDuration(summary?['total_duration'] ?? 0),
                          label: 'Duration',
                          color: const Color(0xFF8B5CF6),
                        ),
                        _buildStatItem(
                          value: ManagerCallLogService.formatDuration(avgDuration),
                          label: 'Avg',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      children: [
        Container(
          height: 20,
          width: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          width: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
