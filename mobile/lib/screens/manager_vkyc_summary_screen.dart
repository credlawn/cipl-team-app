import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/pb_api.dart';
import '../services/manager_task_service.dart';
import '../utils/vkyc_share_util.dart';

class ManagerVKYCSummaryScreen extends StatefulWidget {
  const ManagerVKYCSummaryScreen({super.key});

  @override
  State<ManagerVKYCSummaryScreen> createState() => _ManagerVKYCSummaryScreenState();
}

class _ManagerVKYCSummaryScreenState extends State<ManagerVKYCSummaryScreen> {
  bool _isSearching = false;
  bool _isLoading = true;
  bool _isGeneratingImage = false;
  String _selectedTab = 'pending'; // 'pending', 'complete', 'expired'
  List<Map<String, dynamic>> _allEmployees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  List<Map<String, dynamic>> _rawPendingCustomers = [];
  Map<String, dynamic> _summary = {
    'active_pending': 0,
    'today_done': 0,
    'expired': 0,
    'total': 0,
  };
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await ManagerTaskService.getVKYCDetailedBreakdown();
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
      backgroundColor: const Color(0xFFF3F4F6), // Clean FB-style light grey bg
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterData,
                decoration: InputDecoration(
                  hintText: 'Search employee...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                ),
                style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
              )
            : const Text(
                'VKYC Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          _buildCompactHeaderAction(
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
            const SizedBox(width: 12),
            _buildCompactHeaderAction(
              icon: Icons.chat_outlined,
              color: const Color(0xFF16A34A),
              onTap: () => VkycShareUtil.sharePendingText(
                context: context,
                rawPendingCustomers: _rawPendingCustomers,
              ),
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFooterMetric('Pending', '${_summary['active_pending'] ?? 0}', const Color(0xFFDC2626)),
                    Container(width: 1, height: 22, color: const Color(0xFFE5E7EB)),
                    _buildFooterMetric('Done Today', '${_summary['today_done'] ?? 0}', const Color(0xFF166534)),
                    Container(width: 1, height: 22, color: const Color(0xFFE5E5EB)),
                    _buildFooterMetric('Expired', '${_summary['expired'] ?? 0}', const Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : Column(
                  children: [
                    // ── 3 Filter Chips Bar ─────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFilterChip('Pending', 'pending', const Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          _buildFilterChip('Complete', 'complete', const Color(0xFF166534)),
                          const SizedBox(width: 8),
                          _buildFilterChip('Expired', 'expired', const Color(0xFF6B7280)),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: Builder(builder: (ctx) {
                          final displayEmployees = _filteredEmployees.where((emp) {
                            final custs = List<Map<String, dynamic>>.from(emp['customers'] ?? []);
                            return custs.any((c) => (c['category'] ?? 'pending') == _selectedTab);
                          }).toList();

                          if (displayEmployees.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No ${_selectedTab.toUpperCase()} records',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            itemCount: displayEmployees.length,
                            itemBuilder: (context, index) {
                              final item = displayEmployees[index];
                              return _buildEmployeeCardFBStyle(item, index + 1);
                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
          if (_isGeneratingImage)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF2563EB)),
                        SizedBox(height: 16),
                        Text('Generating Report Image...', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildEmployeeCardFBStyle(Map<String, dynamic> item, int rank) {
    final activePending = item['active_pending'] ?? 0;
    final todayDone     = item['today_done'] ?? 0;
    final expiredCount  = item['expired'] ?? 0;
    final employeeName  = (item['employee_name'] ?? 'Unknown').toString().trim();
    final List<Map<String, dynamic>> customers = List<Map<String, dynamic>>.from(item['customers'] ?? []);



    // Build subtitle metrics string
    final List<Widget> subtitleWidgets = [];
    if (activePending > 0) {
      subtitleWidgets.add(Text(
        '$activePending Pending',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)),
      ));
    }
    if (todayDone > 0) {
      if (subtitleWidgets.isNotEmpty) {
        subtitleWidgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('•', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ));
      }
      subtitleWidgets.add(Text(
        '$todayDone Done Today',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
      ));
    }
    if (expiredCount > 0) {
      if (subtitleWidgets.isNotEmpty) {
        subtitleWidgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('•', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ));
      }
      subtitleWidgets.add(Text(
        '$expiredCount Expired',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
      ));
    }
    if (subtitleWidgets.isEmpty) {
      subtitleWidgets.add(const Text(
        '0 Pending',
        style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Employee Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111827)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(children: subtitleWidgets),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Customer Item Rows ─────────────────────────────────────────────
          Builder(builder: (ctx) {
            final matchingCustomers = customers.where((c) => (c['category'] ?? 'pending') == _selectedTab).toList();
            if (matchingCustomers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No records in this tab', style: TextStyle(fontSize: 12, color: Colors.grey)),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matchingCustomers.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (ctx, idx) => _buildCustomerRowFBStyle(matchingCustomers[idx]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerRowFBStyle(Map<String, dynamic> c) {
    final name = (c['customer_name'] ?? 'Unknown').toString().trim().toUpperCase();
    final arn = c['arn_no'] ?? '';
    final link = c['vkyc_link'] ?? '';
    final isTodayDone = c['is_today_done'] == true;
    final isExpired = c['is_expired'] == true;
    final expiryLabel = c['expiry_label'] ?? '';
    final mobileNo = c['mobile_no'] ?? '';

    Color badgeColor = const Color(0xFF4B5563);
    Color badgeBg = const Color(0xFFF3F4F6);
    if (isTodayDone) {
      badgeColor = const Color(0xFF15803D);
      badgeBg = const Color(0xFFDCFCE7);
    } else if (isExpired) {
      badgeColor = const Color(0xFF9CA3AF);
      badgeBg = const Color(0xFFF3F4F6);
    } else if (expiryLabel.contains('Today')) {
      badgeColor = const Color(0xFFDC2626);
      badgeBg = const Color(0xFFFEF2F2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _showStatusUpdateBottomSheet(c),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1F2937), letterSpacing: 0.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('ARN: $arn', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isTodayDone ? 'Completed Today' : expiryLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (link.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Action Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFBActionButton(
                      icon: Icons.chat_outlined,
                      label: 'WhatsApp',
                      color: const Color(0xFF16A34A),
                      onTap: () async {
                        final msg = 'Customer Name: $name\nARN: $arn\n\nLink:\n$link';
                        final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(msg)}';
                        final uri = Uri.parse(whatsappUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          Share.share(msg);
                        }
                      },
                    ),
                  ),
                  Container(width: 1, height: 14, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child: _buildFBActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy Link',
                      color: const Color(0xFF4B5563),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('VKYC link copied')),
                        );
                      },
                    ),
                  ),
                  Container(width: 1, height: 14, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child: _buildFBActionButton(
                      icon: Icons.open_in_new_rounded,
                      label: 'Open Link',
                      color: const Color(0xFF4B5563),
                      onTap: () async {
                        final uri = Uri.parse(link);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFBActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterMetric(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildCompactHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF4B5563),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showStatusUpdateBottomSheet(Map<String, dynamic> c) {
    final recordId = c['id']?.toString() ?? '';
    final custName = c['customer_name']?.toString() ?? 'Customer';
    final arn = c['arn_no']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        custName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 2),
                      Text('ARN: $arn', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Verified Status:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFBBF7D0)),
              ),
              tileColor: const Color(0xFFF0FDF4),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.check_circle_outline_rounded, color: Color(0xFF166534)),
              ),
              title: const Text(
                'Mark as Complete',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534), fontSize: 14),
              ),
              subtitle: const Text(
                'Move to Complete tab',
                style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _updateVkycRecord(recordId, {
                  'user_vkyc_status': 'Complete',
                  'bank_vkyc_status': 'Success',
                  'user_status_date': DateTime.now().toIso8601String(),
                }, 'Moved to Complete');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              tileColor: const Color(0xFFFEF2F2),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEE2E2),
                child: Icon(Icons.history_toggle_off_rounded, color: Color(0xFFDC2626)),
              ),
              title: const Text(
                'Mark as Expired',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 14),
              ),
              subtitle: const Text(
                'Move to Expired tab',
                style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _updateVkycRecord(recordId, {
                  'user_vkyc_status': 'Expired',
                  'bank_vkyc_status': 'Failed',
                }, 'Moved to Expired');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              tileColor: const Color(0xFFF9FAFB),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3F4F6),
                child: Icon(Icons.pending_actions_rounded, color: Color(0xFF4B5563)),
              ),
              title: const Text(
                'Mark as Pending',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 14),
              ),
              subtitle: const Text(
                'Move back to Pending tab',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _updateVkycRecord(recordId, {
                  'user_vkyc_status': 'Pending',
                  'bank_vkyc_status': 'Pending',
                }, 'Moved to Pending');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, Color activeColor) {
    final isSelected = _selectedTab == key;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = key;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? activeColor : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Future<void> _updateVkycRecord(String recordId, Map<String, dynamic> body, String successMsg) async {
    setState(() => _isLoading = true);
    try {
      await PB.pb.collection('vkyc').update(recordId, body: body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: const Color(0xFF10B981)),
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
