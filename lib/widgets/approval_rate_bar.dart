import 'package:flutter/material.dart';

class ApprovalRateBar extends StatelessWidget {
  final double rate;
  final String trend;

  const ApprovalRateBar({
    super.key,
    required this.rate,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final trendIcon = trend == 'up' ? '▲' : (trend == 'down' ? '▼' : '—');
    final trendColor = trend == 'up'
        ? const Color(0xFF10B981)
        : (trend == 'down' ? const Color(0xFFEF4444) : const Color(0xFF6B7280));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Approval Rate',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${rate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendIcon,
                    style: TextStyle(
                      fontSize: 12,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getGradientColor(rate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradientColor(double rate) {
    if (rate >= 70) return const Color(0xFF10B981);
    if (rate >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
