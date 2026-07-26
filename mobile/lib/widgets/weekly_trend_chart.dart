import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyTrendChart extends StatelessWidget {
  final Map<String, int> callsByDay;
  final Map<String, int> durationByDay;

  const WeeklyTrendChart({
    super.key,
    required this.callsByDay,
    required this.durationByDay,
  });

  @override
  Widget build(BuildContext context) {
    final maxCalls = callsByDay.values.isEmpty
        ? 10
        : callsByDay.values.reduce((a, b) => a > b ? a : b);
    
    final maxDuration = durationByDay.values.isEmpty
        ? 60
        : durationByDay.values.reduce((a, b) => a > b ? a : b);
    
    final maxValue = (maxCalls > maxDuration / 60) ? maxCalls.toDouble() : (maxDuration / 60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Connected Calls',
              style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Duration (min)',
              style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue + 4,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.black87,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final days = callsByDay.keys.toList();
                    final day = days[group.x.toInt()];
                    if (rodIndex == 0) {
                      return BarTooltipItem(
                        '${callsByDay[day]} calls',
                        const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    } else {
                      final mins = (durationByDay[day]! / 60).toStringAsFixed(1);
                      return BarTooltipItem(
                        '${mins}m',
                        const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    }
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final days = callsByDay.keys.toList();
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final days = callsByDay.keys.toList();
    return List.generate(days.length, (index) {
      final callCount = callsByDay[days[index]] ?? 0;
      final duration = durationByDay[days[index]] ?? 0;
      final durationInMinutes = duration / 60;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: callCount.toDouble(),
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
            color: const Color(0xFF10B981),
          ),
          BarChartRodData(
            toY: durationInMinutes,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
            color: const Color(0xFF3B82F6),
          ),
        ],
      );
    });
  }
}
