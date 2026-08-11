import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/manager_task_service.dart';

class ManagerCardsSummaryScreen extends StatefulWidget {
  const ManagerCardsSummaryScreen({super.key});

  @override
  State<ManagerCardsSummaryScreen> createState() => _ManagerCardsSummaryScreenState();
}

class _ManagerCardsSummaryScreenState extends State<ManagerCardsSummaryScreen> {
  bool _isSearching = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedMonth = '';
  List<String> _availableMonths = [];

  Map<String, dynamic> _summary = {
    'total_cards': 0,
    'total_active': 0,
    'total_inactive': 0,
    'total_closed': 0,
  };

  List<Map<String, dynamic>> _officeEmployees = [];
  List<Map<String, dynamic>> _wfhEmployees = [];
  List<Map<String, dynamic>> _inactiveEmployees = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({String? month}) async {
    setState(() => _isLoading = true);
    try {
      final data = await ManagerTaskService.getCardsDetailedBreakdown(month: month);
      if (mounted) {
        final months = (data['available_months'] as List? ?? []).map((e) => e.toString()).toList();
        final currentMonth = data['current_month']?.toString() ?? '';
        final selMonth = data['selected_month']?.toString() ?? month ?? currentMonth;
        final summary = data['summary'] is Map ? Map<String, dynamic>.from(data['summary']) : <String, dynamic>{};
        final groups = data['groups'] is Map ? Map<String, dynamic>.from(data['groups']) : <String, dynamic>{};

        final office = (groups['office'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final wfh = (groups['wfh'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final inactive = (groups['inactive'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        setState(() {
          _availableMonths = months;
          _selectedMonth = selMonth.isNotEmpty ? selMonth : (months.isNotEmpty ? months.first : currentMonth);
          _summary = summary;
          _officeEmployees = office;
          _wfhEmployees = wfh;
          _inactiveEmployees = inactive;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in CardsSummary _loadData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMonthPicker() {
    if (_availableMonths.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Month',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableMonths.length,
                itemBuilder: (context, index) {
                  final month = _availableMonths[index];
                  final isSelected = month.toLowerCase().trim() == _selectedMonth.toLowerCase().trim();

                  return ListTile(
                    dense: true,
                    title: Text(
                      month,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, size: 18, color: Color(0xFF2563EB))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (month != _selectedMonth) {
                        _loadData(month: month);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterGroup(List<Map<String, dynamic>> group) {
    if (_searchQuery.isEmpty) return group;
    final q = _searchQuery.toLowerCase();
    return group.where((e) {
      final name = (e['employee_name'] ?? '').toString().toLowerCase();
      final code = (e['employee_code'] ?? '').toString().toLowerCase();
      if (name.contains(q) || code.contains(q)) return true;

      // Also search customer name or ARN within employee cards
      final cards = List<Map<String, dynamic>>.from(e['cards'] ?? []);
      return cards.any((c) {
        final custName = (c['customer_name'] ?? '').toString().toLowerCase();
        final arn = (c['arn_no'] ?? '').toString().toLowerCase();
        return custName.contains(q) || arn.contains(q);
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOffice = _filterGroup(_officeEmployees);
    final filteredWfh = _filterGroup(_wfhEmployees);
    final filteredInactive = _filterGroup(_inactiveEmployees);

    final totalCount = _summary['total_cards'] ?? 0;
    final activeCount = _summary['total_active'] ?? 0;
    final inactiveCount = _summary['total_inactive'] ?? 0;
    final closedCount = _summary['total_closed'] ?? 0;

    final hasEmployees = filteredOffice.isNotEmpty || filteredWfh.isNotEmpty || filteredInactive.isNotEmpty;

    int getGroupCardsCount(List<Map<String, dynamic>> group) {
      return group.fold<int>(0, (sum, e) {
        final totalCards = e['total_cards'];
        if (totalCards is int && totalCards > 0) return sum + totalCards;
        final total = e['total'];
        if (total is int && total > 0) return sum + total;
        final cards = e['cards'];
        if (cards is List) return sum + cards.length;
        return sum;
      });
    }

    final officeCardsCount = getGroupCardsCount(filteredOffice);
    final wfhCardsCount = getGroupCardsCount(filteredWfh);
    final inactiveCardsCount = getGroupCardsCount(filteredInactive);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        titleSpacing: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search employee, ARN, customer...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                ),
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 15),
              )
            : Row(
                children: [
                  const Text(
                    'Approved Cards',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (_selectedMonth.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '($_selectedMonth)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ],
              ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: _isSearching ? const Color(0xFFEF4444) : const Color(0xFF4B5563),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF2563EB),
              size: 22,
            ),
            tooltip: 'Select Month',
            onPressed: _showMonthPicker,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            )
          : RefreshIndicator(
              onRefresh: () => _loadData(month: _selectedMonth),
              color: const Color(0xFF2563EB),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Summary Strip
                  _buildSummaryStrip(
                    total: totalCount,
                    active: activeCount,
                    inactive: inactiveCount,
                    closed: closedCount,
                  ),

                  // Employee Grouped List
                  if (!hasEmployees)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No records matching "$_searchQuery"'
                              : 'No approved cards in $_selectedMonth',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ),
                    )
                  else ...[
                    // 1. Office Group
                    if (filteredOffice.isNotEmpty) ...[
                      _buildGroupHeader('🏢 OFFICE', officeCardsCount, const Color(0xFF2563EB)),
                      _buildEmployeeSection(filteredOffice),
                    ],

                    // 2. Work From Home Group
                    if (filteredWfh.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildGroupHeader('🏠 WORK FROM HOME', wfhCardsCount, const Color(0xFF059669)),
                      _buildEmployeeSection(filteredWfh),
                    ],

                    // 3. Inactive Group
                    if (filteredInactive.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildGroupHeader('⚠️ INACTIVE', inactiveCardsCount, const Color(0xFFDC2626)),
                      _buildEmployeeSection(filteredInactive),
                    ],

                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryStrip({
    required int total,
    required int active,
    required int inactive,
    required int closed,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'Total: $total Cards',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 8),
          const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
          const SizedBox(width: 8),
          Text(
            'Active: $active',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 8),
          const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
          const SizedBox(width: 8),
          Text(
            'Inactive: $inactive',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD97706),
            ),
          ),
          if (closed > 0) ...[
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
            const SizedBox(width: 8),
            Text(
              'Closed: $closed',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title, int count, Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSection(List<Map<String, dynamic>> employees) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: employees.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Color(0xFFE5E7EB),
        ),
        itemBuilder: (context, index) {
          final emp = employees[index];
          return _buildEmployeeListItem(emp, index + 1);
        },
      ),
    );
  }

  Widget _buildEmployeeListItem(Map<String, dynamic> emp, int rank) {
    final name = emp['employee_name'] ?? 'Unknown';
    final total = emp['total_cards'] ?? emp['total'] ?? (emp['cards'] as List? ?? []).length;
    final active = emp['active_cards'] ?? emp['active'] ?? 0;
    final inactive = emp['inactive_cards'] ?? emp['inactive'] ?? 0;
    final closed = emp['closed_cards'] ?? emp['closed'] ?? 0;

    return InkWell(
      onTap: () => _showEmployeeCardsModal(emp),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank
            SizedBox(
              width: 26,
              child: Text(
                '$rank.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Name + Subtitles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'Active: $active',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  Inactive: $inactive',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (closed > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•  Closed: $closed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Total count pill badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeCardsModal(Map<String, dynamic> employee) {
    final rawCards = employee['cards'] as List? ?? [];
    final cards = rawCards.map((c) => Map<String, dynamic>.from(c as Map)).toList();
    final name = employee['employee_name']?.toString() ?? 'Unknown';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _EmployeeCardsModal(
          employeeName: name,
          selectedMonth: _selectedMonth,
          cards: cards,
        );
      },
    );
  }
}

class _EmployeeCardsModal extends StatefulWidget {
  final String employeeName;
  final String selectedMonth;
  final List<Map<String, dynamic>> cards;

  const _EmployeeCardsModal({
    required this.employeeName,
    required this.selectedMonth,
    required this.cards,
  });

  @override
  State<_EmployeeCardsModal> createState() => _EmployeeCardsModalState();
}

class _EmployeeCardsModalState extends State<_EmployeeCardsModal> {
  String _filter = 'All'; // 'All', 'Active', 'Inactive'
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredList {
    return widget.cards.where((c) {
      if (_filter == 'Active' && c['is_active'] != true) return false;
      if (_filter == 'Inactive' && c['is_active'] == true) return false;

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final name = (c['customer_name'] ?? '').toString().toLowerCase();
        final arn = (c['arn_no'] ?? '').toString().toLowerCase();
        final mob = (c['mobile_no'] ?? '').toString().toLowerCase();
        final type = (c['customer_type'] ?? '').toString().toLowerCase();
        final prod = (c['product_description'] ?? '').toString().toLowerCase();

        if (!name.contains(q) && !arn.contains(q) && !mob.contains(q) && !type.contains(q) && !prod.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;
    final activeCount = widget.cards.where((c) => c['is_active'] == true).length;
    final inactiveCount = widget.cards.length - activeCount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.selectedMonth} • ${widget.cards.length} Cards Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _search = val.trim()),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                  hintText: 'Search customer, ARN, type...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          // Text Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterText('All (${widget.cards.length})', 'All'),
                const SizedBox(width: 16),
                _buildFilterText('Active ($activeCount)', 'Active'),
                const SizedBox(width: 16),
                _buildFilterText('Inactive ($inactiveCount)', 'Inactive'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Customer Cards List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'No cards found',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (context, index) {
                      final card = list[index];
                      return _buildCustomerItem(card);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterText(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
          decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildCustomerItem(Map<String, dynamic> card) {
    final customerName = card['customer_name'] ?? 'Unknown';
    final arnNo = card['arn_no'] ?? '';
    final decisionDate = card['final_decision_date'] ?? '';
    final product = card['product_description'] ?? card['card_type'] ?? '';
    final customerType = card['customer_type'] ?? '';
    final mobileNo = card['mobile_no'] ?? '';
    final isActive = card['is_active'] == true;
    final isClosed = card['is_closed'] == true;

    // Line 1 details: ARN • Type • Date
    final List<String> line1Parts = [];
    if (arnNo.isNotEmpty) line1Parts.add('ARN: $arnNo');
    if (customerType.isNotEmpty) line1Parts.add('Type: $customerType');
    if (decisionDate.isNotEmpty) line1Parts.add(decisionDate);

    // Line 2 details: Product • Status • Mobile
    final List<String> line2Parts = [];
    if (product.isNotEmpty) line2Parts.add(product);
    if (isClosed) {
      line2Parts.add('Status: Closed');
    } else {
      line2Parts.add(isActive ? 'Status: Active' : 'Status: Inactive');
    }
    if (mobileNo.isNotEmpty && mobileNo != '0') line2Parts.add('Mob: $mobileNo');

    Color statusColor = const Color(0xFFD97706);
    String statusText = 'Inactive';
    if (isClosed) {
      statusColor = const Color(0xFF6B7280);
      statusText = 'Closed';
    } else if (isActive) {
      statusColor = const Color(0xFF059669);
      statusText = 'Active';
    }

    return InkWell(
      onTap: () {
        if (arnNo.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: arnNo));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ARN $arnNo copied to clipboard'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            if (line1Parts.isNotEmpty)
              Text(
                line1Parts.join('  •  '),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            if (line2Parts.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                line2Parts.join('  •  '),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
