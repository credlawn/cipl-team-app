import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BkycShareUtil {
  // Convert label 'May-26' → arn_month key '26E'
  static String _labelToArnMonthKey(String label) {
    const monthToLetter = {
      'Jan': 'A', 'Feb': 'B', 'Mar': 'C', 'Apr': 'D',
      'May': 'E', 'Jun': 'F', 'Jul': 'G', 'Aug': 'H',
      'Sep': 'I', 'Oct': 'J', 'Nov': 'K', 'Dec': 'L',
    };
    final parts = label.split('-');
    if (parts.length != 2) return '';
    final letter = monthToLetter[parts[0]] ?? '';
    return '${parts[1]}$letter'; // e.g. '26E'
  }

  static String _periodKey(String period) {
    // Maps period to employee data key prefix
    switch (period) {
      case 'current': return 'current';
      case 'last':    return 'last';
      case 'prev':    return 'prev';
      default:        return 'total';
    }
  }

  static int _get(Map<String, dynamic> emp, String period, String field) {
    if (period == 'total') {
      if (field == 'inc')   return (emp['total']     ?? 0) as int;
      if (field == 'done')  return (emp['activated'] ?? 0) as int;
      if (field == 'den')   return (emp['denied']    ?? 0) as int;
      if (field == 'today') return (emp['today']     ?? 0) as int;
      return 0;
    }
    final prefix = _periodKey(period);
    if (field == 'inc')   return (emp[prefix] ?? 0) as int;
    if (field == 'done')  return (emp['${prefix}_activated'] ?? 0) as int;
    if (field == 'den')   return (emp['${prefix}_denied']    ?? 0) as int;
    if (field == 'today') return (emp['${prefix}_today']     ?? 0) as int;
    return 0;
  }

  // ── Function 1: Employee Summary Image ───────────────────────────────────
  static Future<void> generateAndShareSummaryImage({
    required BuildContext context,
    required String period,
    required String periodLabel,
    required List<Map<String, dynamic>> filteredEmployees,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final sc = ScreenshotController();

      // Filter out zero-bal + zero-today employees
      final toRender = List<Map<String, dynamic>>.from(filteredEmployees)
        ..removeWhere((emp) {
          final inc   = _get(emp, period, 'inc');
          final done  = _get(emp, period, 'done');
          final den   = _get(emp, period, 'den');
          final today = _get(emp, period, 'today');
          return (inc - done - den) <= 0 && today == 0;
        })
        ..sort((a, b) {
          final balA = _get(a, period, 'inc') - _get(a, period, 'done') - _get(a, period, 'den');
          final balB = _get(b, period, 'inc') - _get(b, period, 'done') - _get(b, period, 'den');
          return balB.compareTo(balA);
        });

      if (toRender.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No BKYC pending data for this period')),
          );
        }
        setLoading(false);
        return;
      }

      final widget = Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'BKYC Summary - $periodLabel',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
                Text(
                  'Date: ${DateTime.now().toString().split(' ').first}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Expanded(flex: 4, child: Text('EMPLOYEE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                  Expanded(flex: 1, child: Text('INC',  textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                  Expanded(flex: 1, child: Text('DONE', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                  Expanded(flex: 1, child: Text('DEN',  textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                  Expanded(flex: 1, child: Text('TOD',  textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                  Expanded(flex: 1, child: Text('BAL',  textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Rows
            ...toRender.map((emp) {
              final name  = emp['employee_name'] ?? 'Unknown';
              final inc   = _get(emp, period, 'inc');
              final done  = _get(emp, period, 'done');
              final den   = _get(emp, period, 'den');
              final today = _get(emp, period, 'today');
              final bal   = inc - done - den;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
                    Expanded(flex: 1, child: Text(inc  == 0 ? '-' : '$inc',  textAlign: TextAlign.right, style: const TextStyle(color: Colors.black))),
                    Expanded(flex: 1, child: Text(done == 0 ? '-' : '$done', textAlign: TextAlign.right, style: TextStyle(color: done  > 0 ? const Color(0xFF059669) : Colors.black))),
                    Expanded(flex: 1, child: Text(den  == 0 ? '-' : '$den',  textAlign: TextAlign.right, style: TextStyle(color: den   > 0 ? const Color(0xFFDC2626) : Colors.black))),
                    Expanded(flex: 1, child: Text(today== 0 ? '-' : '$today',textAlign: TextAlign.right, style: TextStyle(color: today > 0 ? const Color(0xFF3B82F6) : Colors.black))),
                    Expanded(flex: 1, child: Text(bal  == 0 ? '-' : '$bal',  textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: bal > 0 ? const Color(0xFFDC2626) : Colors.black))),
                  ],
                ),
              );
            }),
            // Total Row
            Builder(builder: (ctx) {
              int sInc = 0, sDone = 0, sDen = 0, sToday = 0;
              for (var e in toRender) {
                sInc   += _get(e, period, 'inc');
                sDone  += _get(e, period, 'done');
                sDen   += _get(e, period, 'den');
                sToday += _get(e, period, 'today');
              }
              final sBal = sInc - sDone - sDen;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: const BoxDecoration(color: Color(0xFFECFDF5), border: Border(top: BorderSide(color: Color(0xFF6EE7B7), width: 2))),
                child: Row(
                  children: [
                    const Expanded(flex: 4, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF065F46)))),
                    Expanded(flex: 1, child: Text(sInc  == 0 ? '-' : '$sInc',  textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black))),
                    Expanded(flex: 1, child: Text(sDone == 0 ? '-' : '$sDone', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669)))),
                    Expanded(flex: 1, child: Text(sDen  == 0 ? '-' : '$sDen',  textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)))),
                    Expanded(flex: 1, child: Text(sToday== 0 ? '-' : '$sToday',textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3B82F6)))),
                    Expanded(flex: 1, child: Text(sBal  == 0 ? '-' : '$sBal',  textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)))),
                  ],
                ),
              );
            }),
          ],
        ),
      );

      final height = 180.0 + (toRender.length * 55.0) + 60.0;
      final bytes = await sc.captureFromWidget(
        Directionality(textDirection: TextDirection.ltr, child: Material(color: Colors.white, child: widget)),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0,
        context: context,
        targetSize: Size(500, height),
      );

      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/bkyc_summary_${period}_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)], text: 'BKYC Summary - $periodLabel');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate image: $e')));
      }
    } finally {
      setLoading(false);
    }
  }

  // ── Function 2: Pending Customers Image ──────────────────────────────────
  static Future<void> generateAndSharePendingCustomersImage({
    required BuildContext context,
    required String period,
    required String periodLabel,
    required List<Map<String, dynamic>> rawPendingCustomers,
    required Map<String, dynamic> summary,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final sc = ScreenshotController();

      // Filter by arn_month key derived from period label
      List<Map<String, dynamic>> filtered;
      if (period == 'total') {
        filtered = List.from(rawPendingCustomers);
      } else {
        final label = summary['${period}_month']?['label']?.toString() ?? '';
        final targetKey = _labelToArnMonthKey(label); // e.g. '26E'
        filtered = rawPendingCustomers
            .where((c) => c['arn_month']?.toString() == targetKey)
            .toList();
      }

      if (filtered.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No BKYC pending customers for this period')),
          );
        }
        setLoading(false);
        return;
      }

      // Group by employee, sort alphabetically
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var c in filtered) {
        final emp = c['employee_name']?.toString() ?? 'Unknown';
        grouped.putIfAbsent(emp, () => []).add(c);
      }
      final sortedEmps = grouped.keys.toList()..sort();
      for (var emp in sortedEmps) {
        grouped[emp]!.sort((a, b) =>
            (a['customer_name'] ?? '').toString().compareTo((b['customer_name'] ?? '').toString()));
      }

      // Chunk at 40
      const maxPerChunk = 40;
      final List<List<Map<String, dynamic>>> chunks = [];
      List<Map<String, dynamic>> current = [];
      for (var emp in sortedEmps) {
        final empCusts = grouped[emp]!;
        if (current.isNotEmpty && (current.length + empCusts.length) > maxPerChunk) {
          chunks.add(current);
          current = [];
        }
        current.addAll(empCusts);
        if (current.length >= maxPerChunk) {
          chunks.add(current);
          current = [];
        }
      }
      if (current.isNotEmpty) chunks.add(current);

      final dir = await getTemporaryDirectory();
      final List<XFile> files = [];

      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        final partLabel = chunks.length > 1 ? ' (Part ${i + 1} of ${chunks.length})' : '';

        final widget = Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BKYC Pending - $periodLabel$partLabel',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                  ),
                  Text('Count: ${chunk.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                ],
              ),
              const SizedBox(height: 16),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('EMPLOYEE',      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)))),
                    Expanded(flex: 4, child: Text('CUSTOMER NAME', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)))),
                    Expanded(flex: 3, child: Text('ARN NO',        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...chunk.map((c) {
                final empName = c['employee_name'] ?? '-';
                final empIdx  = sortedEmps.indexOf(empName);
                final empColor = (empIdx % 2 == 0) ? const Color(0xFF0F766E) : const Color(0xFF7F1D1D);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(empName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: empColor))),
                      Expanded(flex: 4, child: Text(c['customer_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF111827)))),
                      Expanded(flex: 3, child: Text(c['arn_no'] ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        final height = 160.0 + (chunk.length * 35.0);
        final bytes = await sc.captureFromWidget(
          Directionality(textDirection: TextDirection.ltr, child: Material(color: Colors.white, child: widget)),
          delay: const Duration(milliseconds: 100),
          pixelRatio: 2.0,
          context: context,
          targetSize: Size(700, height),
        );

        final path = '${dir.path}/bkyc_pending_${period}_part${i + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(path).writeAsBytes(bytes);
        files.add(XFile(path));
      }

      await Share.shareXFiles(files, text: 'BKYC Pending - $periodLabel');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate image: $e')));
      }
    } finally {
      setLoading(false);
    }
  }
}
