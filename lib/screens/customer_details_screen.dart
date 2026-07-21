import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/pb_api.dart';
import '../services/customer_leads_service.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final List<Map<String, dynamic>> _leads = [];
  final List<Map<String, dynamic>> _employees = [];
  final List<String> _availableStatuses = [
    'All',
    'Follow Up',
    'Hold',
    'CNR',
    'Voicemail',
    'IP Approved',
    'IP Decline',
    'Denied',
    'Already Carded',
    'Not Eligible',
    'No Docs',
    'Recently Applied',
  ];

  String _selectedEmployee = 'All';
  String _selectedStatus = 'All';
  bool _excludeNegative = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = false && role != "Manager"',
        sort: 'employee_name',
      );
      if (mounted) {
        setState(() {
          _employees.clear();
          _employees.add({'employee_code': 'All', 'employee_name': 'All Employees'});
          _employees.addAll(records.map((e) => {
            'employee_code': e.data['employee_code'],
            'employee_name': e.data['employee_name'],
          }));
        });
      }
    } catch (_) {}
  }


  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _leads.clear();
    }

    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await CustomerLeadsService.getCustomerLeads(
        page: _currentPage,
        perPage: 20,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
        employeeCode: _selectedEmployee == 'All' ? null : _selectedEmployee,
        excludeNegative: _excludeNegative,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _leads.addAll(List<Map<String, dynamic>>.from(result['items']));
          _totalPages = result['totalPages'];
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leads: $e')),
        );
      }
    }
  }

  void _loadMore() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _loadData();
    }
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
        _leads.clear();
        _isLoading = true;
      });
      _loadData();
    });
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
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Name or Mobile...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: _onSearchChanged,
              )
            : const Text('Customers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  if (_searchQuery.isNotEmpty) {
                    _searchQuery = '';
                    _currentPage = 1;
                    _leads.clear();
                    _loadData();
                  }
                } else {
                  _isSearching = true;
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 8), // Smoother spacing
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSearching ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: _isSearching ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)) : null,
              ),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                size: 20,
                color: _isSearching ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
              ),
            ),
          ),
          if (!_isSearching) ...[
            _buildEmployeeFilter(),
            _buildStatusFilter(),
            _buildNegativeFilterToggle(),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadData(isRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _leads.length + (_currentPage < _totalPages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _leads.length) {
                    return _buildLoadMoreButton();
                  }
                  return _buildLeadCard(_leads[index]);
                },
              ),
            ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _isLoadingMore
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: _loadMore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B82F6),
                elevation: 0,
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('More Leads', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead) {
    String status = lead['lead_status'] ?? 'Unknown';
    // Display Voicemail as CNR
    if (status.toLowerCase() == 'voicemail') status = 'CNR';
    
    String formattedDate = 'N/A';
    if (lead['lead_status_date'] != null) {
      DateTime dt = DateTime.parse(lead['lead_status_date'].toString());
      // Convert to IST (UTC +5:30)
      DateTime istDate = dt.toUtc().add(const Duration(hours: 5, minutes: 30));
      
      final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
      final today = DateTime(now.year, now.month, now.day);
      final leadDay = DateTime(istDate.year, istDate.month, istDate.day);
      
      if (leadDay == today) {
        formattedDate = DateFormat('h:mm a').format(istDate);
      } else {
        formattedDate = DateFormat('d MMM, h:mm a').format(istDate);
      }
    }

    dynamic rawMobVal = lead['mobile_no'];
    String rawMobile = '';
    if (rawMobVal != null) {
      if (rawMobVal is num) {
        rawMobile = rawMobVal.toInt().toString();
      } else {
        rawMobile = rawMobVal.toString().trim();
      }
    }
    
    String maskedMobile = 'N/A';
    if (rawMobile.isNotEmpty) {
      if (rawMobile.length > 5) {
        maskedMobile = 'x' * (rawMobile.length - 5) + rawMobile.substring(rawMobile.length - 5);
      } else {
        maskedMobile = rawMobile; // Show as is if very short
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/manager/lead-feedback-history',
          arguments: {
            'mobileNo': rawMobile,
            'customerName': lead['customer_name'] ?? 'Unknown Customer',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead['employee_name'] ?? 'Unknown Employee',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lead['data_code'] ?? 'N/A'}${lead['custom_code'] != null && lead['custom_code'].toString().trim().isNotEmpty ? " (${lead['custom_code']})" : ""}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600),
                    ),
                    if (lead['remarks'] != null && lead['remarks'].toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        lead['remarks'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: status.toLowerCase() == 'ip decline' || status.toLowerCase() == 'denied'
                          ? Border.all(color: _getStatusColor(status), width: 1)
                          : null,
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                    ),
                  ),
                  if (formattedDate != 'N/A') ...[
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Details Grid
          _buildInfoRow(
            Icons.person_outline, 
            '', 
            lead['customer_name'] ?? 'N/A',
            valueStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
          ),
          _buildInfoRow(Icons.phone_outlined, '', rawMobile),
          // Combined Segment / Product / City row
          _buildInfoRow(
            Icons.info_outline, 
            '', 
            [
              lead['segment']?.toString() ?? '',
              lead['product']?.toString() ?? '',
              lead['city']?.toString() ?? ''
            ].where((s) => s.trim().isNotEmpty).join(' / ').isNotEmpty 
                ? [
                    lead['segment']?.toString() ?? '',
                    lead['product']?.toString() ?? '',
                    lead['city']?.toString() ?? ''
                  ].where((s) => s.trim().isNotEmpty).join(' / ')
                : 'N/A'
          ),
          _buildInfoRow(Icons.business_outlined, '', lead['employer'] ?? 'N/A'),
          _buildInfoRow(Icons.error_outline, '', lead['decline_reason'] ?? 'N/A'),
          
          const Divider(height: 24),

          // Call Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCallStat(Icons.call, 'Total', lead['total_calls']?.toString() ?? '0'),
              _buildCallStat(Icons.call_made, 'Connected', lead['connected_calls']?.toString() ?? '0'),
              _buildCallStat(Icons.timer_outlined, 'Duration', '${lead['total_duration'] ?? 0}s'),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    ),
   );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {dynamic extra, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          if (label.isNotEmpty) ...[
            Text('$label: ', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
          Expanded(
            child: Text(
              extra != null ? '$value ($extra)' : value,
              style: valueStyle ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildSubHeader(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
      ],
    );
  }

  Widget _buildNegativeFilterToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _excludeNegative = !_excludeNegative;
          _loadData(isRefresh: true);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: !_excludeNegative ? Colors.grey.withOpacity(0.05) : const Color(0xFFEF4444).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10), // Pro Square/Squircle look
          border: _excludeNegative ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)) : null,
        ),
        child: Icon(
          _excludeNegative ? Icons.do_disturb_on_outlined : Icons.do_disturb_off_outlined,
          size: 20,
          color: !_excludeNegative ? const Color(0xFF6B7280) : const Color(0xFFEF4444),
        ),
      ),
    );
  }

  Widget _buildEmployeeFilter() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedEmployee = value;
          _loadData(isRefresh: true);
        });
      },
      itemBuilder: (context) => _employees.map((emp) {
        return PopupMenuItem<String>(
          value: emp['employee_code'],
          child: Text(emp['employee_name']),
        );
      }).toList(),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _selectedEmployee == 'All' ? Colors.grey.withOpacity(0.05) : const Color(0xFF3B82F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: 20,
          color: _selectedEmployee == 'All' ? const Color(0xFF6B7280) : const Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedStatus = value;
          _loadData(isRefresh: true);
        });
      },
      itemBuilder: (context) => _availableStatuses.map((status) {
        return PopupMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _selectedStatus == 'All' ? Colors.grey.withOpacity(0.05) : const Color(0xFF3B82F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: _selectedStatus == 'All' ? const Color(0xFF6B7280) : const Color(0xFF3B82F6),
        ),
      ),
    );
  }
}
