import 'package:flutter/material.dart';
import '../../models/dashboard_summary.dart';

class DataUsageCard extends StatelessWidget {
  final bool isLoading;
  final DashboardSummary? summary;
  final VoidCallback? onRefresh;
  final int? zeroNewLeadsCount; // Badge count

  const DataUsageCard({
    super.key,
    required this.isLoading,
    required this.summary,
    this.onRefresh,
    this.zeroNewLeadsCount,
  });

  @override
  Widget build(BuildContext context) {
    // Use API summary values directly (no calculation needed)
    // summary.used = total_activity from API
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'DATA USAGE',
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
              await Navigator.pushNamed(context, '/manager/leads-detail');
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
                        _buildStatItemWithBadge(
                          value: summary?.newLeads.toString() ?? '0',
                          label: 'New',
                          color: const Color(0xFF10B981),
                          badgeCount: zeroNewLeadsCount,
                        ),
                        _buildStatItem(
                          value: summary?.worked.toString() ?? '0',
                          label: 'Worked',
                          color: const Color(0xFF3B82F6),
                        ),
                        _buildStatItem(
                          value: summary?.used.toString() ?? '0',
                          label: 'Used',
                          color: const Color(0xFFF59E0B),
                        ),
                        _buildStatItem(
                          value: '${summary?.productivity.round() ?? 0}%',
                          label: 'Prod%',
                          color: const Color(0xFF8B5CF6),
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
      mainAxisAlignment: MainAxisAlignment.center,
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
      mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildStatItemWithBadge({
    required String value,
    required String label,
    required Color color,
    int? badgeCount,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            top: -12,
            right: -14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                badgeCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
