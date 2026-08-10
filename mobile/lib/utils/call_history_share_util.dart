import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../services/manager_call_log_service.dart';

class CallHistoryShareUtil {
  static Future<void> shareHourlyReportImage({
    required BuildContext context,
    required String employeeName,
    required String employeeCode,
    required DateTime selectedDate,
    required List<Map<String, dynamic>> hourlyData,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    final ScreenshotController sc = ScreenshotController();
    try {
      final now = DateTime.now();
      final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
      final dateStr = isToday 
          ? DateFormat('dd MMM, hh:mm a').format(now) 
          : DateFormat('dd MMM, yyyy').format(selectedDate);
      final totalCalls = hourlyData.fold<int>(0, (sum, h) => sum + (h['call_count'] as int? ?? 0));
      final totalDuration = hourlyData.fold<int>(0, (sum, h) => sum + (h['total_duration'] as int? ?? 0));
      final totalIdle = hourlyData.fold<int>(0, (sum, h) => sum + (h['idle_time'] as int? ?? 0));
      final totalIPA = hourlyData.fold<int>(0, (sum, h) => sum + (h['ipa_count'] as int? ?? 0));
      final totalCases = hourlyData.fold<int>(0, (sum, h) => sum + (h['total_cases'] as int? ?? 0));
      final totalWorkSecs = totalDuration + totalIdle;
      final efficiencyPct = totalWorkSecs > 0 ? ((totalDuration / totalWorkSecs) * 100).round() : 0;

      String formatHourBlock(int endHour) {
        String fmt(int hour) {
          final norm = (hour + 24) % 24;
          if (norm == 0) return '12:00 AM';
          if (norm < 12) return '$norm:00 AM';
          if (norm == 12) return '12:00 PM';
          return '${norm - 12}:00 PM';
        }
        return '${fmt(endHour - 1)} - ${fmt(endHour)}';
      }

      Widget widget = Container(
        width: 480,
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Clean Light Top Header (No dark mode box) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Call Report • $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF2563EB), size: 24),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Key Summary Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('$totalCalls', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                      const SizedBox(height: 2),
                      const Text('Total Calls', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                    ],
                  ),
                  Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                  Column(
                    children: [
                      Text(ManagerCallLogService.formatDuration(totalDuration), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                      const SizedBox(height: 2),
                      const Text('Duration', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                    ],
                  ),
                  if (totalIPA > 0 || (totalCases - totalIPA) > 0) ...[
                    Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                    Column(
                      children: [
                        _buildIpaIpdWidget(
                          ipa: totalIPA,
                          ipd: totalCases - totalIPA,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 2),
                        const Text('IPA / IPD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                  Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                  Column(
                    children: [
                      Text('$efficiencyPct%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: efficiencyPct >= 50 ? const Color(0xFF16A34A) : (efficiencyPct >= 30 ? const Color(0xFFD97706) : const Color(0xFFDC2626)))),
                      const SizedBox(height: 2),
                      const Text('Efficiency', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Hourly Rows List (Exact Replica of App Screen 2-Liner Design) ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: List.generate(hourlyData.length, (idx) {
                  final item = hourlyData[idx];
                  final displayHour = item['hour'] as int? ?? 11;
                  final calls = item['call_count'] as int? ?? 0;
                  final duration = item['total_duration'] as int? ?? 0;
                  final idle = item['idle_time'] as int? ?? 0;
                  final ipaCount = item['ipa_count'] as int? ?? 0;
                  final totalCases = item['total_cases'] as int? ?? 0;
                  final totalHourSecs = duration + idle;
                  final activePct = totalHourSecs > 0 ? ((duration / totalHourSecs) * 100).round() : 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: idx < hourlyData.length - 1
                          ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line 1: Time Range & Active %
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatHourBlock(displayHour),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (calls > 0)
                              Text(
                                '$activePct% active',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Line 2: Elegant Metrics
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone_in_talk_rounded, size: 13, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text(
                                  '$calls',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'Calls',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('•', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 11)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 13, color: Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  ManagerCallLogService.formatDuration(duration),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF14532D),
                                  ),
                                ),
                              ],
                            ),
                            if (ipaCount > 0 || (totalCases - ipaCount) > 0) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('•', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 11)),
                              ),
                              _buildIpaIpdWidget(
                                ipa: ipaCount,
                                ipd: totalCases - ipaCount,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );

      final bytes = await sc.captureFromWidget(
        Material(child: widget),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/call_history_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      setLoading(false);
      await Share.shareXFiles([XFile(file.path)], text: 'Call Report - $employeeName ($dateStr)');
    } catch (e) {
      setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report image: $e')),
        );
      }
    }
  }

  static Widget _buildIpaIpdWidget({
    required int ipa,
    required int ipd,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    if (ipa == 0 && ipd == 0) {
      return const SizedBox.shrink();
    }

    const fw = FontWeight.w600;

    if (ipa > 0 && ipd == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
        ),
        child: Text(
          '${ipa}A',
          style: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: fw,
            color: const Color(0xFF15803D),
          ),
        ),
      );
    } else if (ipa == 0 && ipd > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
        ),
        child: Text(
          '${ipd}D',
          style: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: fw,
            color: const Color(0xFFB91C1C),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${ipa}A',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: fw,
                color: const Color(0xFF15803D),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: fw,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              '${ipd}D',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: fw,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      );
    }
  }
}
