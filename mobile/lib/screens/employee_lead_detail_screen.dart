import 'package:flutter/material.dart';
import '../services/leads_analytics_service.dart';

class EmployeeLeadDetailScreen extends StatefulWidget {
  const EmployeeLeadDetailScreen({super.key});

  @override
  State<EmployeeLeadDetailScreen> createState() => _EmployeeLeadDetailScreenState();
}

class _EmployeeLeadDetailScreenState extends State<EmployeeLeadDetailScreen> {
  String _employeeCode = '';
  String _employeeName = '';
  String _filterType = 'today';
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _employeeCode = args['employee_code'] ?? '';
          _employeeName = args['employee_name'] ?? '';
          _filterType = args['filter_type'] ?? 'today';
        });
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await LeadsAnalyticsService.getPivotData(
        filterType: _filterType,
        employeeCode: _employeeCode,
      );
      
      if (mounted) {
        setState(() {
          _data = data.isNotEmpty ? data.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_employeeName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No data available'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 16),
                          _buildStatusBreakdown(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    final total = _data?['total'] ?? 0;
    final productivity = _data?['productivity'] ?? '0.0';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Leads', total.toString(), const Color(0xFF3B82F6)),
              _buildSummaryItem('Productivity', '$productivity%', const Color(0xFF10B981)),
            ],
          ),
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

  Widget _buildStatusBreakdown() {
    final statuses = [
      {'label': 'IP Approved', 'count': _data?['ip_approved'] ?? 0, 'color': const Color(0xFF10B981)},
      {'label': 'IP Decline', 'count': _data?['ip_decline'] ?? 0, 'color': const Color(0xFFEF4444)},
      {'label': 'New', 'count': _data?['new'] ?? 0, 'color': const Color(0xFF3B82F6)},
      {'label': 'Called', 'count': _data?['called'] ?? 0, 'color': const Color(0xFF8B5CF6)},
      {'label': 'Follow Up', 'count': _data?['follow_up'] ?? 0, 'color': const Color(0xFFF59E0B)},
      {'label': 'CNR', 'count': _data?['cnr'] ?? 0, 'color': const Color(0xFFF97316)},
      {'label': 'Denied', 'count': _data?['denied'] ?? 0, 'color': const Color(0xFFDC2626)},
      {'label': 'No Docs', 'count': _data?['no_docs'] ?? 0, 'color': const Color(0xFF6B7280)},
      {'label': 'Already Carded', 'count': _data?['already_carded'] ?? 0, 'color': const Color(0xFF64748B)},
      {'label': 'Not Eligible', 'count': _data?['not_eligible'] ?? 0, 'color': const Color(0xFF475569)},
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

  Widget _buildStatusItem(String label, int count, Color color) {
    return Padding(
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
              count.toString(),
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
    );
  }
}
