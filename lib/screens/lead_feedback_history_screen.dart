import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/lead_feedback_service.dart';
import '../services/call_log_service.dart';

class LeadFeedbackHistoryScreen extends StatefulWidget {
  final String mobileNo;
  final String customerName;

  const LeadFeedbackHistoryScreen({
    super.key,
    required this.mobileNo,
    required this.customerName,
  });

  @override
  State<LeadFeedbackHistoryScreen> createState() => _LeadFeedbackHistoryScreenState();
}

class _LeadFeedbackHistoryScreenState extends State<LeadFeedbackHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _callLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final feedbackData = await LeadFeedbackService.getHistoryByMobile(widget.mobileNo);
    final callData = await CallLogService.getCallHistoryByPhone(widget.mobileNo);

    // Deduplication logic for Call Logs
    final Map<String, Map<String, dynamic>> uniqueCalls = {};
    for (var log in callData) {
      if (log['call_timestamp'] == null) continue;
      
      // Parse and normalize timestamp to "Second" level (ignore milliseconds)
      DateTime dt = DateTime.parse(log['call_timestamp'].toString());
      final String tsKey = DateFormat('yyyyMMddHHmmss').format(dt);
      
      final String dur = log['call_duration']?.toString() ?? '';
      
      // Create a unique key using Normalized Timestamp + Duration (Employee ignored)
      final String key = "${tsKey}_${dur}";

      if (!uniqueCalls.containsKey(key)) {
        uniqueCalls[key] = log;
      }
    }

    if (mounted) {
      setState(() {
        _history = feedbackData;
        // Take top 20 unique records from the deduplicated map
        _callLogs = uniqueCalls.values.toList().take(20).toList();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ip approved': return const Color(0xFF10B981); // Green
      case 'ip decline':
      case 'denied': return const Color(0xFFEF4444);      // Red
      case 'follow up':
      case 'hold': return const Color(0xFF6366F1);        // Modern Indigo
      case 'cnr': 
      case 'voicemail': return const Color(0xFFF59E0B);   // Orange
      case 'already carded':
      case 'recently applied':
      case 'not eligible': return const Color(0xFF64748B); // Slate Blue
      default: return const Color(0xFF6B7280);            // Default Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.mobileNo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              color: const Color(0xFF3B82F6),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Feedback History
                    const Text(
                      'FEEDBACK LOGS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 1.2),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _history.isEmpty
                        ? Padding(padding: const EdgeInsets.all(20), child: _buildEmptyState())
                        : Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1.3), // Employee
                              1: IntrinsicColumnWidth(), // Status (Fits content exactly)
                              2: FlexColumnWidth(1.2), // Date Time
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              // Header Row
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                ),
                                children: [
                                  _buildTableHeader('Employee'),
                                  _buildTableHeader('Status'),
                                  _buildTableHeader('Status Time', textAlign: TextAlign.center),
                                ],
                              ),
                              // Data Rows
                              ..._history.map((feedback) => _buildTableRow(feedback)),
                            ],
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Section: Call History
                  const Text(
                    'CALL HISTORY',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _callLogs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: _buildEmptyState(message: 'No Call Logs Found'),
                          )
                        : Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1.2), // Employee
                              1: FlexColumnWidth(0.5), // Ring (Small)
                              2: FlexColumnWidth(0.8), // Duration
                              3: FlexColumnWidth(1.3), // Time
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                ),
                                children: [
                                  _buildTableHeader('Employee'),
                                  _buildTableHeader('Ring'),
                                  _buildTableHeader('Duration'),
                                  _buildTableHeader('Call Time', textAlign: TextAlign.center),
                                ],
                              ),
                              ..._callLogs.map((log) => _buildCallTableRow(log)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTableHeader(String text, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF374151)),
        textAlign: textAlign,
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> feedback) {
    String status = feedback['lead_status'] ?? 'Unknown';
    if (status.toLowerCase() == 'voicemail') status = 'CNR';

    String formattedDate = 'N/A';
    if (feedback['lead_status_date'] != null) {
      DateTime dt = DateTime.parse(feedback['lead_status_date'].toString());
      DateTime istDate = dt.toUtc().add(const Duration(hours: 5, minutes: 30));
      formattedDate = DateFormat('d MMM, h:mm a').format(istDate);
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(feedback['employee_name'] ?? 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: status.toLowerCase() == 'ip decline' || status.toLowerCase() == 'denied'
                    ? Border.all(color: _getStatusColor(status).withOpacity(0.5), width: 0.8)
                    : null,
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _getStatusColor(status), letterSpacing: 0.3),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            formattedDate, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  TableRow _buildCallTableRow(Map<String, dynamic> log) {
    int duration = log['call_duration'] is int ? log['call_duration'] : (int.tryParse(log['call_duration']?.toString() ?? '0') ?? 0);
    int ringDuration = log['ring_duration'] is int ? log['ring_duration'] : (int.tryParse(log['ring_duration']?.toString() ?? '0') ?? 0);
    
    String formattedDuration = '';
    bool isCNR = duration == 0;
    
    if (isCNR) {
      formattedDuration = 'CNR';
    } else if (duration < 60) {
      formattedDuration = '${duration}s';
    } else {
      formattedDuration = '${duration ~/ 60}m ${duration % 60}s';
    }

    String formattedDate = 'N/A';
    if (log['call_timestamp'] != null) {
      DateTime dt = DateTime.parse(log['call_timestamp'].toString());
      DateTime istDate = dt.toUtc().add(const Duration(hours: 5, minutes: 30));
      formattedDate = DateFormat('d MMM, h:mm a').format(istDate);
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(log['employee_name'] ?? 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(ringDuration.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCNR 
                ? Icon(Icons.call_missed, color: Colors.red.withOpacity(0.8), size: 16)
                : Text(
                    formattedDuration,
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF059669)
                    ),
                  ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            formattedDate, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({String message = 'No History Found'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
