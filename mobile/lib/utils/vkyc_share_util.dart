import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VkycShareUtil {
  // ── Function 1: Employee Summary Image ───────────────────────────────────
  static Future<void> generateAndShareSummaryImage({
    required BuildContext context,
    required List<Map<String, dynamic>> filteredEmployees,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final sc = ScreenshotController();

      final toRender = List<Map<String, dynamic>>.from(filteredEmployees)
        ..removeWhere((emp) {
          final pending = emp['active_pending'] as int? ?? 0;
          final todayDone = emp['today_done'] as int? ?? 0;
          return pending <= 0 && todayDone <= 0;
        })
        ..sort((a, b) {
          final pendingA = a['active_pending'] as int? ?? 0;
          final pendingB = b['active_pending'] as int? ?? 0;
          return pendingB.compareTo(pendingA);
        });

      if (toRender.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active VKYC pending data')),
          );
        }
        setLoading(false);
        return;
      }

      final totalPending = toRender.fold<int>(0, (s, e) => s + (e['active_pending'] as int? ?? 0));
      final totalDone = toRender.fold<int>(0, (s, e) => s + (e['today_done'] as int? ?? 0));
      final totalExpired = toRender.fold<int>(0, (s, e) => s + (e['expired'] as int? ?? 0));

      final widget = Container(
        width: 480,
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'VKYC Actionable Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Pending: $totalPending',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFF0F9FF),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: const Row(
                      children: [
                        SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                        Expanded(flex: 3, child: Text('EMPLOYEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                        Expanded(flex: 2, child: Text('PENDING', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)))),
                        Expanded(flex: 2, child: Text('DONE', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                        Expanded(flex: 2, child: Text('EXPIRED', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                      ],
                    ),
                  ),
                  ...toRender.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final emp = entry.value;
                    final pending = emp['active_pending'] as int? ?? 0;
                    final done = emp['today_done'] as int? ?? 0;
                    final exp = emp['expired'] as int? ?? 0;

                    return Container(
                      color: idx % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 24, child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                          Expanded(flex: 3, child: Text(emp['employee_name'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                          Expanded(flex: 2, child: Text(pending == 0 ? '-' : '$pending', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)))),
                          Expanded(flex: 2, child: Text(done == 0 ? '-' : '$done', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                          Expanded(flex: 2, child: Text(exp == 0 ? '-' : '$exp', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))),
                        ],
                      ),
                    );
                  }),
                  Container(
                    color: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        const Expanded(flex: 3, child: Text('Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                        Expanded(flex: 2, child: Text(totalPending == 0 ? '-' : '$totalPending', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)))),
                        Expanded(flex: 2, child: Text(totalDone == 0 ? '-' : '$totalDone', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                        Expanded(flex: 2, child: Text(totalExpired == 0 ? '-' : '$totalExpired', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                      ],
                    ),
                  ),
                ],
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
      final file = File('${tempDir.path}/vkyc_summary_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      setLoading(false);
      await Share.shareXFiles([XFile(file.path)], text: 'VKYC Actionable Summary Report');
    } catch (e) {
      setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating image: $e')),
        );
      }
    }
  }

  // ── Function 2: Share Active Pending Text ────────────────────────────────
  static void sharePendingText({
    required BuildContext context,
    required List<Map<String, dynamic>> rawPendingCustomers,
  }) {
    if (rawPendingCustomers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active pending VKYC links to share')),
      );
      return;
    }

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var c in rawPendingCustomers) {
      final empName = c['employee_name']?.toString() ?? 'Unknown';
      grouped.putIfAbsent(empName, () => []).add(c);
    }

    final buffer = StringBuffer();
    buffer.writeln('📋 *VKYC Pending ${rawPendingCustomers.length}*\n');

    grouped.forEach((emp, customers) {
      buffer.writeln('👤 *${emp.toUpperCase()}* (${customers.length})');
      for (var i = 0; i < customers.length; i++) {
        final cust = customers[i];
        final name = (cust['customer_name'] ?? 'Unknown').toString().trim();
        final arn = cust['arn_no'] ?? '';
        final link = cust['vkyc_link'] ?? '';

        buffer.writeln('${i + 1}. *$name*');
        buffer.writeln('   ARN: $arn');
        if (link.isNotEmpty) {
          buffer.writeln();
          buffer.writeln('   Link:');
          buffer.writeln('   $link');
        }
        buffer.writeln();
      }
    });

    Share.share(buffer.toString());
  }
}
