import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/leads_analytics_service.dart';

class LeadsPivotTableScreen extends StatefulWidget {
  const LeadsPivotTableScreen({super.key});

  @override
  State<LeadsPivotTableScreen> createState() => _LeadsPivotTableScreenState();
}

class _LeadsPivotTableScreenState extends State<LeadsPivotTableScreen> {
  String _selectedFilter = 'today';
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Ensure we return to portrait when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _toggleRotation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await LeadsAnalyticsService.getPivotData(
        filterType: _selectedFilter,
      );
      
      if (mounted) {
        setState(() {
          _data = data;
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
        title: const Text('Lead Status Pivot'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isLandscape ? Icons.screen_lock_portrait : Icons.screen_rotation,
              color: const Color(0xFF3B82F6),
            ),
            onPressed: _toggleRotation,
            tooltip: 'Toggle Rotation',
          ),
          _buildFilterButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildPivotTable(),
              ),
            ),
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: _showFilterMenu,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF374151)),
            const SizedBox(width: 6),
            Text(
              _getFilterLabel(_selectedFilter),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF374151)),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'today': return 'Today';
      case 'yesterday': return 'Yesterday';
      case 'this_week': return 'This Week';
      default: return 'Today';
    }
  }

  void _showFilterMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Today', 'today', Icons.today),
              _buildFilterOption('Yesterday', 'yesterday', Icons.history),
              const Divider(height: 24),
              _buildFilterOption('This Week', 'this_week', Icons.date_range),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
        _loadData();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF374151),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFF3B82F6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPivotTable() {
    // Calculate totals
    int totalPA = 0, totalIPD = 0, totalNew = 0;
    int totalCalled = 0, totalFW = 0, totalCNR = 0, totalDenied = 0;
    int totalND = 0, totalCarded = 0, totalNE = 0, totalAll = 0;

    for (var row in _data) {
      totalPA += (row['ip_approved'] as int?) ?? 0;
      totalIPD += (row['ip_decline'] as int?) ?? 0;
      totalNew += (row['new'] as int?) ?? 0;
      totalCalled += (row['called'] as int?) ?? 0;
      totalFW += (row['follow_up'] as int?) ?? 0;
      totalCNR += (row['cnr'] as int?) ?? 0;
      totalDenied += (row['denied'] as int?) ?? 0;
      totalND += (row['no_docs'] as int?) ?? 0;
      totalCarded += (row['already_carded'] as int?) ?? 0;
      totalNE += (row['not_eligible'] as int?) ?? 0;
      totalAll += (row['total'] as int?) ?? 0;
    }

    int totalWorked = totalAll - totalNew;
    int totalUnproductive = totalCNR + totalDenied;
    double totalProductivity = totalWorked > 0 
        ? ((totalWorked - totalUnproductive) / totalWorked * 100) 
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
          border: TableBorder.all(color: const Color(0xFFE5E7EB), width: 1),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Employee', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Prod%', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('PA', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('IPD', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('New', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('Called', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('FW', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('CNR', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('Denied', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('ND', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('Carded', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('NE', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
          ],
          rows: [
            ..._data.map((row) => DataRow(
              onSelectChanged: null,
              cells: [
                DataCell(
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/manager/employee-lead-detail',
                        arguments: {
                          'employee_code': row['employee_code'],
                          'employee_name': row['employee_name'],
                          'filter_type': _selectedFilter,
                        },
                      );
                    },
                    child: Text(row['employee_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                DataCell(Text(row['productivity'] == 0 || row['productivity'] == '0' ? '-' : '${double.parse(row['productivity'].toString()).round()}%', style: const TextStyle(color: Color(0xFF8B5CF6)))),
                DataCell(Text(row['ip_approved'] == 0 ? '-' : row['ip_approved'].toString(), style: const TextStyle(color: Color(0xFF10B981)))),
                DataCell(Text(row['ip_decline'] == 0 ? '-' : row['ip_decline'].toString(), style: const TextStyle(color: Color(0xFFEF4444)))),
                DataCell(Text(row['new'] == 0 ? '-' : row['new'].toString())),
                DataCell(Text(row['called'] == 0 ? '-' : row['called'].toString())),
                DataCell(Text(row['follow_up'] == 0 ? '-' : row['follow_up'].toString(), style: const TextStyle(color: Color(0xFFF59E0B)))),
                DataCell(Text(row['cnr'] == 0 ? '-' : row['cnr'].toString())),
                DataCell(Text(row['denied'] == 0 ? '-' : row['denied'].toString())),
                DataCell(Text(row['no_docs'] == 0 ? '-' : row['no_docs'].toString())),
                DataCell(Text(row['already_carded'] == 0 ? '-' : row['already_carded'].toString())),
                DataCell(Text(row['not_eligible'] == 0 ? '-' : row['not_eligible'].toString())),
                DataCell(Text(row['total'] == 0 ? '-' : row['total'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))),
              ],
            )),
            DataRow(
              color: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
              cells: [
                const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataCell(Text(totalProductivity == 0 ? '-' : '${totalProductivity.round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)))),
                DataCell(Text(totalPA == 0 ? '-' : totalPA.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)))),
                DataCell(Text(totalIPD == 0 ? '-' : totalIPD.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)))),
                DataCell(Text(totalNew == 0 ? '-' : totalNew.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalCalled == 0 ? '-' : totalCalled.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalFW == 0 ? '-' : totalFW.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)))),
                DataCell(Text(totalCNR == 0 ? '-' : totalCNR.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalDenied == 0 ? '-' : totalDenied.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalND == 0 ? '-' : totalND.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalCarded == 0 ? '-' : totalCarded.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalNE == 0 ? '-' : totalNE.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalAll == 0 ? '-' : totalAll.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
