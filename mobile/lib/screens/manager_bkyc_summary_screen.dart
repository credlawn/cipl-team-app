import 'package:flutter/material.dart';
import '../services/manager_task_service.dart';
import '../utils/bkyc_share_util.dart';

class ManagerBKYCSummaryScreen extends StatefulWidget {
  const ManagerBKYCSummaryScreen({super.key});

  @override
  State<ManagerBKYCSummaryScreen> createState() => _ManagerBKYCSummaryScreenState();
}

class _ManagerBKYCSummaryScreenState extends State<ManagerBKYCSummaryScreen> {
  bool _isSearching = false;
  bool _isLoading = true;
  bool _isGeneratingImage = false;
  List<Map<String, dynamic>> _allEmployees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  List<Map<String, dynamic>> _rawPendingCustomers = [];
  Map<String, dynamic> _summary = {
    'total': 0,
    'total_activated': 0,
    'total_today': 0,
    'current_month': {'label': '', 'count': 0, 'activated': 0, 'today': 0},
    'last_month': {'label': '', 'count': 0, 'activated': 0, 'today': 0},
    'prev_month': {'label': '', 'count': 0, 'activated': 0, 'today': 0},
  };
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ManagerTaskService.getBKYCDetailedBreakdown();
    if (mounted) {
      setState(() {
        _allEmployees = List<Map<String, dynamic>>.from(data['employees'] ?? []);
        _filteredEmployees = _allEmployees;
        _rawPendingCustomers = List<Map<String, dynamic>>.from(data['pending_customers'] ?? []);
        _summary = data['summary'] ?? _summary;
        _isLoading = false;
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _allEmployees;
      } else {
        _filteredEmployees = _allEmployees
            .where((item) => item['employee_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterData,
                decoration: InputDecoration(
                  hintText: 'Search employee...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
              )
            : const Text(
                'BKYC Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          _buildCompactAction(
            icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
            color: _isSearching ? const Color(0xFFEF4444) : const Color(0xFF4B5563),
            onTap: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filterData('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching) ...[
            const SizedBox(width: 8),
            _buildCompactAction(
              icon: Icons.file_download_outlined,
              onTap: _showPendingShareBottomSheet,
            ),
            _buildCompactAction(
              icon: Icons.share_rounded,
              onTap: _showShareBottomSheet,
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      _buildTeamSummaryCard(),
                      const SizedBox(height: 16),
                      if (_filteredEmployees.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  _allEmployees.isEmpty ? 'No BKYC records found' : 'No employees match your search',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...List.generate(_filteredEmployees.length, (index) {
                          final item = _filteredEmployees[index];
                          return _buildEmployeeCard(item, index + 1);
                        }),
                    ],
                  ),
                ),
          if (_isGeneratingImage)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF10B981)),
                        SizedBox(height: 16),
                        Text('Generating Image...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> item, int rank) {
    final currentLabel = (_summary['current_month']?['label'] ?? '').toString().split('-').first;
    final lastLabel    = (_summary['last_month']?['label'] ?? '').toString().split('-').first;
    final prevLabel    = (_summary['prev_month']?['label'] ?? '').toString().split('-').first;

    final currentCount    = item['current'] ?? 0;
    final currentDone     = item['current_activated'] ?? 0;
    final currentDenied   = item['current_denied'] ?? 0;
    final currentToday    = item['current_today'] ?? 0;
    final lastCount       = item['last'] ?? 0;
    final lastDone        = item['last_activated'] ?? 0;
    final lastDenied      = item['last_denied'] ?? 0;
    final lastToday       = item['last_today'] ?? 0;
    final prevCount       = item['prev'] ?? 0;
    final prevDone        = item['prev_activated'] ?? 0;
    final prevDenied      = item['prev_denied'] ?? 0;
    final prevToday       = item['prev_today'] ?? 0;
    final totalCount      = item['total'] ?? 0;
    final activatedCount  = item['activated'] ?? 0;
    final deniedCount     = item['denied'] ?? 0;
    final todayCount      = item['today'] ?? 0;
    final employeeName    = item['employee_name'] ?? 'Unknown';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee name row
              Row(
                children: [
                  Text('$rank.', style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      employeeName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF059669)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Column headers
              const Row(
                children: [
                  Expanded(flex: 3, child: Text('MONTH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('INC',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('DONE', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('DEN',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('TOD',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('BAL',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5))),
                ],
              ),
              const Divider(height: 16, color: Color(0xFFF3F4F6)),
              _buildDataRow(currentLabel, currentCount, currentDone, currentDenied, currentToday),
              const SizedBox(height: 8),
              _buildDataRow(lastLabel, lastCount, lastDone, lastDenied, lastToday),
              const SizedBox(height: 8),
              _buildDataRow(prevLabel, prevCount, prevDone, prevDenied, prevToday),
              const Divider(height: 16, color: Color(0xFFF3F4F6)),
              _buildDataRow('Total', totalCount, activatedCount, deniedCount, todayCount, isTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, int inc, int done, int den, int today, {bool isTotal = false}) {
    final textColor  = isTotal ? const Color(0xFF111827) : const Color(0xFF4B5563);
    final fontWeight = isTotal ? FontWeight.w700 : FontWeight.w500;
    final balance = inc - done - den;

    final incStr   = inc == 0     ? '-' : inc.toString();
    final doneStr  = done == 0    ? '-' : done.toString();
    final denStr   = den == 0     ? '-' : den.toString();
    final todayStr = today == 0   ? '-' : today.toString();
    final balStr   = balance == 0 ? '-' : balance.toString();

    return Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: fontWeight, color: textColor))),
        Expanded(flex: 2, child: Text(incStr,  textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: isTotal && inc > 0 ? const Color(0xFF111827) : textColor))),
        Expanded(flex: 2, child: Text(doneStr, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: isTotal && done > 0 ? const Color(0xFF059669) : textColor))),
        Expanded(flex: 2, child: Text(denStr,  textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: den > 0 ? const Color(0xFFEF4444) : textColor))),
        Expanded(flex: 2, child: Text(todayStr,textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: today > 0 ? const Color(0xFF3B82F6) : textColor))),
        Expanded(flex: 2, child: Text(balStr,  textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: fontWeight, color: isTotal && balance > 0 ? const Color(0xFFEF4444) : textColor))),
      ],
    );
  }

  Widget _buildTeamSummaryCard() {
    if (_isLoading) return const SizedBox.shrink();

    final currentFullLabel = _summary['current_month']?['label'] ?? 'N/A';
    final lastFullLabel    = _summary['last_month']?['label'] ?? 'N/A';
    final prevFullLabel    = _summary['prev_month']?['label'] ?? 'N/A';
    final currentLabel = currentFullLabel.contains('-') ? currentFullLabel.split('-').first : currentFullLabel;
    final lastLabel    = lastFullLabel.contains('-')    ? lastFullLabel.split('-').first    : lastFullLabel;
    final prevLabel    = prevFullLabel.contains('-')    ? prevFullLabel.split('-').first    : prevFullLabel;

    final currentCount     = _summary['current_month']?['count']     ?? 0;
    final currentActivated = _summary['current_month']?['activated'] ?? 0;
    final currentDenied    = _summary['current_month']?['denied']    ?? 0;
    final currentToday     = _summary['current_month']?['today']     ?? 0;
    final lastCount        = _summary['last_month']?['count']        ?? 0;
    final lastActivated    = _summary['last_month']?['activated']    ?? 0;
    final lastDenied       = _summary['last_month']?['denied']       ?? 0;
    final lastToday        = _summary['last_month']?['today']        ?? 0;
    final prevCount        = _summary['prev_month']?['count']        ?? 0;
    final prevActivated    = _summary['prev_month']?['activated']    ?? 0;
    final prevDenied       = _summary['prev_month']?['denied']       ?? 0;
    final prevToday        = _summary['prev_month']?['today']        ?? 0;
    final totalCount       = _summary['total']           ?? 0;
    final totalActivated   = _summary['total_activated'] ?? 0;
    final totalDenied      = _summary['total_denied']    ?? 0;
    final totalToday       = _summary['total_today']     ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF5EEAD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0xFF0D9488).withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 12)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(flex: 3, child: Text('OVERALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('INC',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('DONE', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('DEN',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('TOD',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('BAL',  textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5))),
            ],
          ),
          const Divider(height: 16, color: Colors.white24),
          _buildSummaryDataRow(currentLabel, currentCount, currentActivated, currentDenied, currentToday),
          const SizedBox(height: 8),
          _buildSummaryDataRow(lastLabel, lastCount, lastActivated, lastDenied, lastToday),
          const SizedBox(height: 8),
          _buildSummaryDataRow(prevLabel, prevCount, prevActivated, prevDenied, prevToday),
          const Divider(height: 16, color: Colors.white24),
          _buildSummaryDataRow('Total', totalCount, totalActivated, totalDenied, totalToday, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryDataRow(String label, int inc, int done, int den, int today, {bool isTotal = false}) {
    final fontWeight = isTotal ? FontWeight.w800 : FontWeight.w500;
    final textColor  = isTotal ? Colors.white : Colors.white.withOpacity(0.9);
    final balance = inc - done - den;

    final incStr   = inc == 0     ? '-' : inc.toString();
    final doneStr  = done == 0    ? '-' : done.toString();
    final denStr   = den == 0     ? '-' : den.toString();
    final todayStr = today == 0   ? '-' : today.toString();
    final balStr   = balance == 0 ? '-' : balance.toString();

    return Row(
      children: [
        Expanded(flex: 3, child: Text(label,   style: TextStyle(fontSize: 12, fontWeight: fontWeight, color: textColor))),
        Expanded(flex: 2, child: Text(incStr,  textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: textColor))),
        Expanded(flex: 2, child: Text(doneStr, textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: isTotal ? const Color(0xFF6EE7B7) : textColor))),
        Expanded(flex: 2, child: Text(denStr,  textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: den > 0 ? const Color(0xFFEF4444) : textColor))),
        Expanded(flex: 2, child: Text(todayStr,textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: today > 0 ? const Color(0xFFFF9800) : textColor))),
        Expanded(flex: 2, child: Text(balStr,  textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: isTotal ? const Color(0xFFF87171) : textColor))),
      ],
    );
  }

  void _showShareBottomSheet() {
    final currentLabel = _summary['current_month']?['label'] ?? 'Current';
    final lastLabel    = _summary['last_month']?['label']    ?? 'Last';
    final prevLabel    = _summary['prev_month']?['label']    ?? 'Prev';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share BKYC Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(height: 8),
              const Text('Select period to generate and share employee summary image.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 24),
              _buildShareOptionRow('current', currentLabel, Icons.calendar_today_outlined),
              _buildShareOptionRow('last',    lastLabel,    Icons.calendar_month_outlined),
              _buildShareOptionRow('prev',    prevLabel,    Icons.history),
              _buildShareOptionRow('total',   'Overall Total', Icons.all_inclusive),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOptionRow(String period, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF10B981)),
      title: Text('Share $label', style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        BkycShareUtil.generateAndShareSummaryImage(
          context: context,
          period: period,
          periodLabel: label,
          filteredEmployees: _filteredEmployees,
          setLoading: (v) => setState(() => _isGeneratingImage = v),
        );
      },
    );
  }

  Widget _buildCompactAction({required IconData icon, required VoidCallback onTap, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color ?? const Color(0xFF4B5563)),
        ),
      ),
    );
  }

  void _showPendingShareBottomSheet() {
    final currentLabel = _summary['current_month']?['label'] ?? 'Current';
    final lastLabel    = _summary['last_month']?['label']    ?? 'Last';
    final prevLabel    = _summary['prev_month']?['label']    ?? 'Prev';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share BKYC Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(height: 8),
              const Text('Select period to export pending customers as image.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 24),
              _buildPendingShareOptionRow('current', currentLabel, Icons.calendar_today_outlined),
              _buildPendingShareOptionRow('last',    lastLabel,    Icons.calendar_month_outlined),
              _buildPendingShareOptionRow('prev',    prevLabel,    Icons.history),
              _buildPendingShareOptionRow('total',   'All Pending', Icons.list),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingShareOptionRow(String period, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFDC2626)),
      title: Text('Share $label', style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        BkycShareUtil.generateAndSharePendingCustomersImage(
          context: context,
          period: period,
          periodLabel: label,
          rawPendingCustomers: _rawPendingCustomers,
          summary: _summary,
          setLoading: (v) => setState(() => _isGeneratingImage = v),
        );
      },
    );
  }
}
