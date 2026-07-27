import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../../services/holiday_service.dart';

class UpcomingHolidaysCard extends StatelessWidget {
  const UpcomingHolidaysCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Holiday>>(
      future: HolidayService.getUpcomingHolidays(),
      builder: (context, snapshot) {
        final holidays = snapshot.data ?? [];
        
        if (holidays.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Holidays',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...holidays.take(3).map((holiday) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final holidayDate = DateTime(holiday.holidayDate.year, holiday.holidayDate.month, holiday.holidayDate.day);
                final daysUntil = holidayDate.difference(today).inDays;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('🎉', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              holiday.holidayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, yyyy').format(holiday.holidayDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: daysUntil == 0 
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          daysUntil == 0 
                              ? 'Today' 
                              : daysUntil == 1 
                                  ? 'Tomorrow' 
                                  : 'in $daysUntil days',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: daysUntil == 0 
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
