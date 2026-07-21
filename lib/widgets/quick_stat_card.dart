import 'package:flutter/material.dart';

class QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const QuickStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool showValue = value.isNotEmpty;
    
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: showValue ? 20 : 24, color: color),
          if (showValue) ...[
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
          ] else
            const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: showValue ? 9 : 11,
              fontWeight: showValue ? FontWeight.normal : FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuickStatSkeleton extends StatelessWidget {
  const QuickStatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShimmerBox(height: 20, width: 20),
          const SizedBox(height: 6),
          _buildShimmerBox(height: 18, width: 40),
          const SizedBox(height: 2),
          _buildShimmerBox(height: 9, width: 50),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
