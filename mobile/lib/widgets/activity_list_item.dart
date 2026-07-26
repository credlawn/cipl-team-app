import 'package:flutter/material.dart';

class ActivityListItem extends StatelessWidget {
  final IconData? iconData;
  final String? emoji;
  final Color? iconColor;
  final String label;
  final String value;
  final String? percentage;

  const ActivityListItem({
    super.key,
    this.iconData,
    this.emoji,
    this.iconColor,
    required this.label,
    required this.value,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (iconData != null)
            Icon(
              iconData,
              size: 16,
              color: iconColor ?? const Color(0xFF6B7280),
            )
          else
            Text(
              emoji ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const Spacer(),
          if (percentage != null) ...[
            Text(
              percentage!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
