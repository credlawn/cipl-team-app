import 'package:flutter/material.dart';
import '../core/pb_api.dart';
import '../services/employee_presence_service.dart';

class AllocateLeadsSettingScreen extends StatefulWidget {
  const AllocateLeadsSettingScreen({super.key});

  @override
  State<AllocateLeadsSettingScreen> createState() => _AllocateLeadsSettingScreenState();
}

class _AllocateLeadsSettingScreenState extends State<AllocateLeadsSettingScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _employees = [];
  Set<String> _presentEmployeeCodes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = false && role != "admin" && no_atn = false',
        sort: 'employee_name',
      );

      final presenceData = await EmployeePresenceService.getPresentEmployees();
      _presentEmployeeCodes = Set<String>.from(presenceData['all'] ?? []);

      if (mounted) {
        setState(() {
          _employees = records.map((e) => {
            'id': e.id,
            'employee_code': e.data['employee_code'] ?? '',
            'employee_name': e.data['employee_name'] ?? 'N/A',
            'wfh': e.data['wfh'] ?? false,
            'stop_auto_leads': e.data['stop_auto_leads'] ?? false,
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleAutoLeads(int index, bool dbValue) async {
    final emp = _employees[index];
    final String id = emp['id'];
    
    if (mounted) {
      setState(() {
        _employees[index]['stop_auto_leads'] = dbValue;
      });
    }

    try {
      await PB.pb.collection('users').update(id, body: {
        'stop_auto_leads': dbValue,
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _employees[index]['stop_auto_leads'] = !dbValue;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officeEmps = _employees.where((e) => e['wfh'] == false).toList();
    final wfhEmps = _employees.where((e) => e['wfh'] == true).toList();
    final totalFlowOn = _employees.where((e) => !e['stop_auto_leads']).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auto Allocate Leads', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827), fontSize: 18)),
            Text('Manage employee wise lead auto allocation', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF3B82F6),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      if (officeEmps.isNotEmpty) ...[
                        _buildSectionLabel('OFFICE INFRASTRUCTURE', const Color(0xFF3B82F6)),
                        _buildModernCard(officeEmps),
                      ],
                      const SizedBox(height: 32),
                      if (wfhEmps.isNotEmpty) ...[
                        _buildSectionLabel('REMOTE WORKFORCE', const Color(0xFF8B5CF6)),
                        _buildModernCard(wfhEmps),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
          
          // Bottom Summary Toast
          if (!_isLoading)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _buildSummaryBar(totalFlowOn),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Container(width: 4, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildModernCard(List<Map<String, dynamic>> emps) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: List.generate(emps.length, (index) {
          final emp = emps[index];
          final globalIndex = _employees.indexOf(emp);
          return Column(
            children: [
              _buildModernRow(emp, index + 1, globalIndex),
              if (index != emps.length - 1)
                const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF3F4F6)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildModernRow(Map<String, dynamic> emp, int sn, int globalIndex) {
    final isPresent = _presentEmployeeCodes.contains(emp['employee_code']);
    final isFlowOn = !emp['stop_auto_leads'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Serial Number
          SizedBox(
            width: 28,
            child: Text(
              '$sn',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      emp['employee_name'],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                    ),
                    if (!isPresent) ...[
                      const SizedBox(width: 8),
                      _buildAbsentBadge(),
                    ],
                  ],
                ),
                Text(
                   isFlowOn ? 'Allocating' : 'Paused',
                   style: TextStyle(
                     fontSize: 11, 
                     color: isFlowOn ? const Color(0xFF14B8A6) : const Color(0xFFEF4444), 
                     fontWeight: FontWeight.bold,
                   ),
                ),
              ],
            ),
          ),
          _buildPremiumSquareToggle(
            isOn: isFlowOn,
            onChanged: (val) => _toggleAutoLeads(globalIndex, !val),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Text('A', style: TextStyle(color: Color(0xFFEF4444), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildPremiumSquareToggle({required bool isOn, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isOn ? const Color(0xFF14B8A6) : const Color(0xFFE5E7EB), // Professional Teal
          boxShadow: [
            if (isOn) BoxShadow(color: const Color(0xFF14B8A6).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(int flowOnCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB), // Distinct Medium-Light Grey
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFF1F2937), size: 18),
              const SizedBox(width: 8),
              Text(
                '$flowOnCount/${_employees.length} employees getting auto leads',
                style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          // Green Dot Indicator
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0xFF10B981), blurRadius: 4, spreadRadius: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
