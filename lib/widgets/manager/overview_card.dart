import 'package:flutter/material.dart';
import '../../models/employee_performance.dart';

class OverviewCard extends StatelessWidget {
  final bool isLoading;
  final List<EmployeePerformance> employees;
  final VoidCallback? onRefresh;

  const OverviewCard({
    super.key,
    required this.isLoading,
    required this.employees,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final totalIpa = employees.fold<int>(0, (sum, emp) => sum + emp.ipa);
    final totalIpd = employees.fold<int>(0, (sum, emp) => sum + emp.ipd);
    final totalIp = totalIpa + totalIpd;
    final ipaPercentage = totalIp > 0 ? ((totalIpa / totalIp) * 100).toStringAsFixed(0) : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'OVERVIEW',
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
              await Navigator.pushNamed(context, '/manager/ipa-detail');
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
                          value: totalIpa.toString(),
                          label: 'IPA',
                          color: const Color(0xFF10B981),
                        ),
                        _buildStatItem(
                          value: totalIpd.toString(),
                          label: 'IPD',
                          color: const Color(0xFFEF4444),
                        ),
                        _buildStatItem(
                          value: totalIp.toString(),
                          label: 'Total',
                          color: const Color(0xFF3B82F6),
                        ),
                        _buildStatItem(
                          value: '$ipaPercentage%',
                          label: 'IPA%',
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
