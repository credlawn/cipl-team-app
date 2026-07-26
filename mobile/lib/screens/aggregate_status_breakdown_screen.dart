import 'package:flutter/material.dart';

class AggregateStatusBreakdownScreen extends StatelessWidget {
  const AggregateStatusBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final summary = args?['summary'] as Map<String, dynamic>?;
    final filterType = args?['filter_type'] as String? ?? 'Today';

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Status Breakdown'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: Text('No data available')),
      );
    }

    final breakdown = summary['breakdown'] as Map<String, dynamic>?;
    final productive = breakdown?['productive'] as Map<String, dynamic>? ?? {};
    final unproductive = breakdown?['unproductive'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Status Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              filterType,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh handled by parent screen
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(summary),
                const SizedBox(height: 16),
                _buildStatusBreakdown(productive, unproductive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final totalActivity = summary['total_activity'] ?? 0;
    final productivity = summary['productivity'] ?? '0.0';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Activity', totalActivity == 0 ? '-' : totalActivity.toString(), const Color(0xFF2563EB)),
          _buildSummaryItem('Productivity', '$productivity%', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(Map<String, dynamic> productive, Map<String, dynamic> unproductive) {
    final statuses = [
      {'label': 'IP Approved', 'count': productive['ip_approved'] ?? 0, 'color': const Color(0xFF10B981)},
      {'label': 'IP Decline', 'count': productive['ip_decline'] ?? 0, 'color': const Color(0xFFEF4444)},
      {'label': 'Follow Up', 'count': productive['follow_up'] ?? 0, 'color': const Color(0xFFF59E0B)},
      {'label': 'No Docs', 'count': productive['no_docs'] ?? 0, 'color': const Color(0xFF6B7280)},
      {'label': 'Already Carded', 'count': productive['already_carded'] ?? 0, 'color': const Color(0xFF64748B)},
      {'label': 'Not Eligible', 'count': productive['not_eligible'] ?? 0, 'color': const Color(0xFF475569)},
      {'label': 'CNR / Voicemail', 'count': unproductive['cnr'] ?? 0, 'color': const Color(0xFFF97316)},
      {'label': 'Denied', 'count': unproductive['denied'] ?? 0, 'color': const Color(0xFFDC2626)},
      {'label': 'Called', 'count': unproductive['called'] ?? 0, 'color': const Color(0xFF8B5CF6)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'COUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          // Status Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statuses.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final status = statuses[index];
              return _buildStatusItem(
                context,
                status['label'] as String,
                status['count'] as int,
                status['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, int count, Color color) {
    return InkWell(
      onTap: () {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final employees = (args?['employees'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        
        // Map label to field name
        final fieldMap = {
          'IP Approved': 'ip_approved',
          'IP Decline': 'ip_decline',
          'Follow Up': 'follow_up',
          'No Docs': 'no_docs',
          'Already Carded': 'already_carded',
          'Not Eligible': 'not_eligible',
          'CNR / Voicemail': 'cnr',
          'Denied': 'denied',
          'Called': 'called',
        };
        
        final statusField = fieldMap[label];
        if (statusField != null && employees.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/manager/status-employee-breakdown',
            arguments: {
              'employees': employees,
              'status_label': label,
              'status_field': statusField,
              'status_color': color,
            },
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                count == 0 ? '-' : count.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
