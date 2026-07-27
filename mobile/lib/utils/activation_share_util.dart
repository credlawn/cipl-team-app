import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ActivationShareUtil {
  static Future<void> generateAndShareSummaryImage({
    required BuildContext context,
    required String period,
    required String periodLabel,
    required List<Map<String, dynamic>> filteredEmployees,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    
    try {
      final ScreenshotController screenshotController = ScreenshotController();
      // Filter out employees where balance and today are both 0 for the selected period
      final employeesToRender = List<Map<String, dynamic>>.from(filteredEmployees);
      employeesToRender.removeWhere((emp) {
        final pending = emp[period == 'total' ? 'total' : period] ?? 0;
        final done = emp[period == 'total' ? 'activated' : '${period}_activated'] ?? 0;
        final today = emp[period == 'total' ? 'today' : '${period}_today'] ?? 0;
        final bal = pending - done;
        return bal <= 0 && today == 0;
      });

      // Sort employees based on selected period's balance descending
      employeesToRender.sort((a, b) {
        final pendingA = a[period == 'total' ? 'total' : period] ?? 0;
        final doneA = a[period == 'total' ? 'activated' : '${period}_activated'] ?? 0;
        final balA = pendingA - doneA;

        final pendingB = b[period == 'total' ? 'total' : period] ?? 0;
        final doneB = b[period == 'total' ? 'activated' : '${period}_activated'] ?? 0;
        final balB = pendingB - doneB;

        return balB.compareTo(balA);
      });

      // Build offscreen widget
      final widgetToCapture = Container(
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
                  'Activation Summary - $periodLabel',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
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
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 4, child: Text('EMPLOYEE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                  Expanded(flex: 1, child: Text('INC', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                  Expanded(flex: 1, child: Text('DONE', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                  Expanded(flex: 1, child: Text('TOD', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                  Expanded(flex: 1, child: Text('BAL', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Employee Rows
            ...employeesToRender.map((emp) {
              final name = emp['employee_name'] ?? 'Unknown';
              final pending = emp[period == 'total' ? 'total' : period] ?? 0;
              final done = emp[period == 'total' ? 'activated' : '${period}_activated'] ?? 0;
              final today = emp[period == 'total' ? 'today' : '${period}_today'] ?? 0;
              final bal = pending - done;
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
                    Expanded(flex: 1, child: Text(pending == 0 ? '-' : pending.toString(), textAlign: TextAlign.right, style: const TextStyle(color: Colors.black))),
                    Expanded(flex: 1, child: Text(done == 0 ? '-' : done.toString(), textAlign: TextAlign.right, style: TextStyle(color: done > 0 ? const Color(0xFF059669) : Colors.black))),
                    Expanded(flex: 1, child: Text(today == 0 ? '-' : today.toString(), textAlign: TextAlign.right, style: TextStyle(color: today > 0 ? const Color(0xFF3B82F6) : Colors.black))),
                    Expanded(flex: 1, child: Text(bal == 0 ? '-' : bal.toString(), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: bal > 0 ? const Color(0xFFDC2626) : Colors.black))),
                  ],
                ),
              );
            }),
            
            // Total Row
            Builder(
              builder: (context) {
                int sumPending = 0;
                int sumDone = 0;
                int sumToday = 0;
                for (var emp in employeesToRender) {
                  sumPending += (emp[period == 'total' ? 'total' : period] ?? 0) as int;
                  sumDone += (emp[period == 'total' ? 'activated' : '${period}_activated'] ?? 0) as int;
                  sumToday += (emp[period == 'total' ? 'today' : '${period}_today'] ?? 0) as int;
                }
                final sumBal = sumPending - sumDone;
                
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    border: Border(top: BorderSide(color: Color(0xFFBFDBFE), width: 2)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(flex: 4, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)))),
                      Expanded(flex: 1, child: Text(sumPending == 0 ? '-' : sumPending.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black))),
                      Expanded(flex: 1, child: Text(sumDone == 0 ? '-' : sumDone.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669)))),
                      Expanded(flex: 1, child: Text(sumToday == 0 ? '-' : sumToday.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3B82F6)))),
                      Expanded(flex: 1, child: Text(sumBal == 0 ? '-' : sumBal.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)))),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      );

      // Capture to image
      final double calculatedHeight = 180.0 + (employeesToRender.length * 55.0) + 60.0;
      
      final imageBytes = await screenshotController.captureFromWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.white,
            child: widgetToCapture,
          ),
        ),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0, // High quality for crisp text
        context: context,
        targetSize: Size(500, calculatedHeight),
      );

      // Save and share
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/activation_summary_${period}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(imagePath)], text: 'Activation Summary - $periodLabel');
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate image: $e')));
      }
    } finally {
      setLoading(false);
    }
  }

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
      final ScreenshotController screenshotController = ScreenshotController();
      // 1. Filter records based on selected period
      List<Map<String, dynamic>> filteredCustomers;
      if (period == 'total') {
        filteredCustomers = List<Map<String, dynamic>>.from(rawPendingCustomers);
      } else {
        final targetMonthLabel = summary['${period}_month']?['label']?.toString().toLowerCase().trim() ?? '';
        filteredCustomers = rawPendingCustomers.where((c) {
          return c['decision_month']?.toString().toLowerCase().trim() == targetMonthLabel;
        }).toList();
      }

      if (filteredCustomers.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No activation pending customers for this period')));
        }
        setLoading(false);
        return;
      }

      // 2. Group by employee
      final Map<String, List<Map<String, dynamic>>> groupedByEmployee = {};
      for (var cust in filteredCustomers) {
        final empName = cust['employee_name']?.toString() ?? 'Unknown';
        groupedByEmployee.putIfAbsent(empName, () => []).add(cust);
      }

      // Sort employees alphabetically
      final sortedEmployeeNames = groupedByEmployee.keys.toList()..sort();

      // Sort customers within each employee alphabetically
      for (var empName in sortedEmployeeNames) {
        groupedByEmployee[empName]!.sort((a, b) {
          final custA = a['customer_name']?.toString() ?? '';
          final custB = b['customer_name']?.toString() ?? '';
          return custA.compareTo(custB);
        });
      }

      // 3. Smart Chunking (Max ~40 per image)
      const int MAX_PER_IMAGE = 40;
      final List<List<Map<String, dynamic>>> chunks = [];
      List<Map<String, dynamic>> currentChunk = [];

      for (var empName in sortedEmployeeNames) {
        final empCustomers = groupedByEmployee[empName]!;
        
        // If adding this employee exceeds max AND the chunk is not empty, start a new chunk
        if (currentChunk.isNotEmpty && (currentChunk.length + empCustomers.length) > MAX_PER_IMAGE) {
          chunks.add(currentChunk);
          currentChunk = [];
        }
        
        currentChunk.addAll(empCustomers);
        
        // Edge case: if a single employee has > 40 on their own, we add them and immediately start a new chunk next time
        if (currentChunk.length >= MAX_PER_IMAGE) {
          chunks.add(currentChunk);
          currentChunk = [];
        }
      }
      
      // Add the final chunk if not empty
      if (currentChunk.isNotEmpty) {
        chunks.add(currentChunk);
      }

      // 4. Generate Images
      final directory = await getTemporaryDirectory();
      final List<XFile> generatedFiles = [];

      for (int i = 0; i < chunks.length; i++) {
        final chunkCustomers = chunks[i];
        final partLabel = chunks.length > 1 ? ' (Part ${i + 1} of ${chunks.length})' : '';
        
        final widgetToCapture = Container(
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
                    'Activation Pending - $periodLabel$partLabel',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                  ),
                  Text(
                    'Count: ${chunkCustomers.length}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // Light red header
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('EMPLOYEE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)))),
                    Expanded(flex: 4, child: Text('CUSTOMER NAME', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)))),
                    Expanded(flex: 3, child: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              ...chunkCustomers.map((cust) {
                final empName = cust['employee_name'] ?? '-';
                final empIndex = sortedEmployeeNames.indexOf(empName);
                final empColor = (empIndex % 2 == 0) ? const Color(0xFF0F766E) : const Color(0xFF7F1D1D); // Alternate Teal and Deep Maroon

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(empName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: empColor))),
                      Expanded(flex: 4, child: Text(cust['customer_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF111827)))),
                      Expanded(flex: 3, child: Text(cust['product'] ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        // Capture to image
        final double calculatedHeight = 160.0 + (chunkCustomers.length * 35.0);
        
        if (!context.mounted) return;
        final imageBytes = await screenshotController.captureFromWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.white,
              child: widgetToCapture,
            ),
          ),
          delay: const Duration(milliseconds: 100),
          pixelRatio: 2.0, // High quality
          context: context,
          targetSize: Size(700, calculatedHeight),
        );

        final imagePath = '${directory.path}/activation_pending_${period}_part${i+1}_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(imageBytes);
        generatedFiles.add(XFile(imagePath));
      }

      await Share.shareXFiles(generatedFiles, text: 'Activation Pending - $periodLabel');
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate activation pending image: $e')));
      }
    } finally {
      setLoading(false);
    }
  }
}
