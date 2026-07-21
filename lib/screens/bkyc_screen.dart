import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
import '../services/bkyc_service.dart';

class BkycScreen extends StatefulWidget {
  const BkycScreen({super.key});

  @override
  State<BkycScreen> createState() => _BkycScreenState();
}

class _LeadBkycCard extends StatelessWidget {
  final BkycRecord record;
  final VoidCallback onStatusTap;
  final Function(BkycRecord) onCallTap;

  const _LeadBkycCard({
    required this.record,
    required this.onStatusTap,
    required this.onCallTap,
  });

  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('complete')) return const Color(0xFF10B981);
    if (s.contains('appointment')) return const Color(0xFFF59E0B);
    if (s.contains('called')) return const Color(0xFF3B82F6);
    if (s.contains('denied')) return const Color(0xFFEF4444);
    if (s.contains('no message')) return const Color(0xFF6B7280);
    return const Color(0xFF9CA3AF); // Pending
  }

  String _userStatusLabel() {
    final s = record.userStatus;
    if (s == null || s.isEmpty || s == 'Pending') return 'Pending';
    return s;
  }

  String _shortDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('dd MMM').format(date);
  }

  // Parse ARN date: D26D27... → day=27, month=D(Apr) → "27-Apr"
  String? _arnDate() {
    final arn = record.arnNo;
    if (arn == null || arn.length < 6) return null;
    try {
      final day = int.parse(arn.substring(4, 6));
      final letter = arn[3];
      const monthMap = {
        'A': 'Jan', 'B': 'Feb', 'C': 'Mar', 'D': 'Apr',
        'E': 'May', 'F': 'Jun', 'G': 'Jul', 'H': 'Aug',
        'I': 'Sep', 'J': 'Oct', 'K': 'Nov', 'L': 'Dec',
      };
      final month = monthMap[letter];
      if (month == null) return null;
      return '$day-$month';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(record.userStatus);
    final isPending = (record.userStatus == null || record.userStatus!.isEmpty || record.userStatus == 'Pending');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name + Action buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  record.customerName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_arnDate() != null) ...[  
                                const SizedBox(width: 6),
                                Text(
                                  _arnDate()!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (record.syncPending)
                          Container(
                            width: 6, height: 6,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          ),
                        GestureDetector(
                          onTap: onStatusTap,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF4B5563)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onCallTap(record),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.call_rounded, size: 16, color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Row 2: ARN + Bank Remarks
                    Row(
                      children: [
                        if (record.arnNo != null && record.arnNo!.isNotEmpty) ...[  
                          Text(
                            record.arnNo!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600),
                          ),
                          if (record.bankRemarks != null && record.bankRemarks!.isNotEmpty)
                            const Text('  ·  ', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        ],
                        if (record.bankRemarks != null && record.bankRemarks!.isNotEmpty)
                          Expanded(
                            child: Text(
                              record.bankRemarks!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Row 3: Status pill + remarks (left) | date (right)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _userStatusLabel(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (record.userRemarks != null && record.userRemarks!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          const Text('·', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.userRemarks!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          const Spacer(),
                        // Date — always right-aligned
                        if (!isPending && record.userStatusDate != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _shortDate(record.userStatusDate!),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _BkycScreenState extends State<BkycScreen> {
  bool _isManualSyncing = false;
  String _activeFilter = 'Pending';
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedMonthFilter = '';
  bool _showTodayOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedMonthFilter = 'all'; // Show all by default; user can filter by month
    BkycService.syncDown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Month Filter Helpers ───────────────────────────────────────────────

  String _monthLetterToName(String letter) {
    const months = {
      'A': 'Jan', 'B': 'Feb', 'C': 'Mar', 'D': 'Apr',
      'E': 'May', 'F': 'Jun', 'G': 'Jul', 'H': 'Aug',
      'I': 'Sep', 'J': 'Oct', 'K': 'Nov', 'L': 'Dec',
    };
    return months[letter] ?? letter;
  }

  List<Map<String, String>> _getMonthOptions() {
    final now = DateTime.now();
    final options = <Map<String, String>>[];
    for (int i = 0; i < 3; i++) {
      final m = DateTime(now.year, now.month - i);
      final letter = String.fromCharCode(64 + m.month);
      final year = (m.year % 100).toString().padLeft(2, '0');
      options.add({'label': '${_monthLetterToName(letter)}-$year', 'value': '$year$letter'});
    }
    options.add({'label': 'All', 'value': 'all'}); // All at bottom
    return options;
  }

  String get _selectedMonthLabel {
    if (_selectedMonthFilter == 'all') return 'All';
    if (_selectedMonthFilter.length < 3) return 'Month';
    final year = _selectedMonthFilter.substring(0, 2);
    final letter = _selectedMonthFilter[2];
    return '${_monthLetterToName(letter)}-$year';
  }

  int _getStatusWeight(String? status) {
    if (status == null || status.isEmpty || status.toLowerCase() == 'pending') return 0;
    final s = status.toLowerCase();
    if (s.contains('no message')) return 1;
    if (s.contains('appointment booked')) return 2;
    if (s.contains('complete')) return 3;
    if (s.contains('denied')) return 4;
    return 1; // Default for actioned
  }

  Widget _buildFilterChips() {
    if (_isSearching) return const SizedBox.shrink();
    final chips = ['All', 'Pending', 'Actioned', 'Denied'];
    return Column(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chips.map((chip) => _buildFilterChip(chip)).toList(),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    const color = Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _activeFilter = label),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isManualSyncing = true;
      _showTodayOnly = false; // reset temp filter on refresh
    });
    await BkycService.syncDown();
    if (mounted) setState(() => _isManualSyncing = false);
  }

  Future<void> _makeCall(BkycRecord record) async {
    final url = 'tel:+91${record.mobileNo}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      BkycService.markAsSeen(record.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer')),
        );
      }
    }
  }

  void _showStatusUpdateSheet(BkycRecord record) {
    String selectedStatus = record.userStatus ?? 'Pending';
    final remarksController = TextEditingController(text: record.userRemarks);
    String? statusError;
    String? remarksError;

    // Status options: label, icon, color
    final statuses = [
      ('Complete',          Icons.check_circle_rounded,    const Color(0xFF10B981)),
      ('Appointment Booked',Icons.calendar_month_rounded,  const Color(0xFFF59E0B)),
      ('Called',            Icons.phone_rounded,            const Color(0xFF3B82F6)),
      ('Customer Denied',   Icons.cancel_rounded,           const Color(0xFFEF4444)),
      ('No Message',        Icons.speaker_notes_off_rounded,const Color(0xFF6B7280)),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 12, left: 16, right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                        SizedBox(height: 1),
                        Text('Select status and add remarks', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Status chips (2 per row using Wrap)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuses.map((s) {
                  final label = s.$1;
                  final icon  = s.$2;
                  final color = s.$3;
                  final isSelected = selectedStatus == label;
                  return GestureDetector(
                    onTap: () => setModalState(() {
                      if (selectedStatus != label) remarksController.clear();
                      selectedStatus = label;
                      statusError = null;
                      remarksError = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: isSelected ? color : const Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? color : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (statusError != null) ...[  
                const SizedBox(height: 6),
                Text(statusError!, style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ],
              const SizedBox(height: 14),
              // Remarks field
              TextField(
                controller: remarksController,
                onChanged: (_) {
                  if (remarksError != null) setModalState(() => remarksError = null);
                },
                decoration: InputDecoration(
                  labelText: 'Remarks*',
                  hintText: 'Add your internal remarks...',
                  errorText: remarksError,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFEF4444)),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    bool hasError = false;
                    if (selectedStatus == 'Pending') {
                      setModalState(() => statusError = 'Please select a status');
                      hasError = true;
                    }
                    if (remarksController.text.trim().isEmpty) {
                      setModalState(() => remarksError = 'Remarks are required');
                      hasError = true;
                    }
                    if (hasError) return;
                    BkycService.updateUserStatus(record.id, selectedStatus, remarksController.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                decoration: const InputDecoration(
                  hintText: 'Search Name or Mobile...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                ),
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('BKYC Leads', style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.arrow_back, color: const Color(0xFF1F2937)),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isSearching) ...[
            // Month filter dropdown
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: PopupMenuButton<String>(
                initialValue: _selectedMonthFilter,
                onSelected: (val) => setState(() => _selectedMonthFilter = val),
                itemBuilder: (_) => _getMonthOptions().map((opt) => PopupMenuItem(
                  value: opt['value']!,
                  child: Text(
                    opt['label']!,
                    style: TextStyle(
                      fontWeight: opt['value'] == _selectedMonthFilter
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                )).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedMonthLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.expand_more_rounded, size: 16, color: Color(0xFF7C3AED)),
                    ],
                  ),
                ),
              ),
            ),
            // Eye toggle — today's activity
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() {
                    _showTodayOnly = !_showTodayOnly;
                    if (_showTodayOnly) {
                      _activeFilter = 'Actioned'; // show today's actioned records
                    } else {
                      _activeFilter = 'Pending';  // reset to default
                    }
                  }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showTodayOnly ? const Color(0xFF3B82F6) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _showTodayOnly ? Icons.visibility_rounded : Icons.visibility_outlined,
                    color: _showTodayOnly ? Colors.white : const Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
              ),
            ),
            // Search button
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _isSearching = true),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 18),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _isManualSyncing ? null : _handleRefresh,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isManualSyncing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)))
                    : const Icon(Icons.sync_rounded, color: Color(0xFF16A34A), size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<BkycRecord>>(
              stream: BkycService.getBkycStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                // 1. Filtration
                final filtered = snapshot.data!.where((r) {
                  // IF Searching: Ignore ALL filters (User Status & Bank Status)
                  if (_isSearching && _searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    final matchesName = r.customerName.toLowerCase().contains(query);
                    final matchesMobile = r.mobileNo.contains(query);
                    final matchesArn = r.arnNo?.toLowerCase().contains(query) ?? false;
                    return matchesName || matchesMobile || matchesArn;
                  }

                  // Default View Logic:
                  // Must be bank pending first
                  final isBankPending = r.bankStatus?.toLowerCase() == 'pending';
                  if (!isBankPending) return false;

                  // Month filter from ARN (e.g. D26D27... → year=26, month=D)
                  if (_selectedMonthFilter != 'all' && _selectedMonthFilter.length >= 3 &&
                      r.arnNo != null && r.arnNo!.length >= 4) {
                    final arnYear = r.arnNo!.substring(1, 3);
                    final arnLetter = r.arnNo![3];
                    final filterYear = _selectedMonthFilter.substring(0, 2);
                    final filterLetter = _selectedMonthFilter[2];
                    if (arnYear != filterYear || arnLetter != filterLetter) return false;
                  }

                  // Today filter
                  if (_showTodayOnly) {
                    if (r.userStatusDate == null) return false;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final d = DateTime(r.userStatusDate!.year, r.userStatusDate!.month, r.userStatusDate!.day);
                    if (d != today) return false;
                  }

                  if (_activeFilter == 'All') return true;
                  
                  final uStatus = r.userStatus?.toLowerCase() ?? 'pending';
                  final isUserPending = uStatus == 'pending' || uStatus.isEmpty;
                  final isDenied = uStatus.contains('denied');

                  if (_activeFilter == 'Pending') return isUserPending;
                  if (_activeFilter == 'Denied') return isDenied;
                  if (_activeFilter == 'Actioned') return !isUserPending && !isDenied;
                  
                  return false; // Default fallthrough for filtered cases
                }).toList();

                // 2. Prioritized Sorting
                filtered.sort((a, b) {
                  // Primary: Status Priority
                  final weightA = _getStatusWeight(a.userStatus);
                  final weightB = _getStatusWeight(b.userStatus);
                  if (weightA != weightB) return weightA.compareTo(weightB);

                  // Secondary: Updated Date (Oldest First - Ascending)
                  // Use userStatusDate as primary, fallback to updated
                  final dateA = a.userStatusDate ?? a.updated;
                  final dateB = b.userStatusDate ?? b.updated;
                  return dateA.compareTo(dateB);
                });

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView(
                      children: [
                         SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                         Center(
                            child: Column(
                              children: [
                                Icon(_isSearching ? Icons.search_off_rounded : Icons.fingerprint_rounded, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  _isSearching ? 'No results for "$_searchQuery"' : 'No $_activeFilter records found', 
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)
                                ),
                              ],
                            ),
                         ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _LeadBkycCard(
                      record: filtered[index],
                      onStatusTap: () => _showStatusUpdateSheet(filtered[index]),
                      onCallTap: _makeCall,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
