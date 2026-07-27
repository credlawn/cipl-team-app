import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
import '../services/activation_service.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _LeadActivationCard extends StatelessWidget {
  final ActivationRecord record;
  final VoidCallback onStatusTap;
  final Function(ActivationRecord) onCallTap;

  const _LeadActivationCard({
    required this.record,
    required this.onStatusTap,
    required this.onCallTap,
  });

  String _getDaysLeftText(DateTime decisionDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final decision = DateTime(decisionDate.year, decisionDate.month, decisionDate.day);
    final daysPassed = today.difference(decision).inDays;

    if (daysPassed > 36) return 'Lapsed';
    if (daysPassed > 30) return '0 Days Left';
    return '${30 - daysPassed} Days Left';
  }

  Color _getDaysColor(DateTime decisionDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final decision = DateTime(decisionDate.year, decisionDate.month, decisionDate.day);
    final daysPassed = today.difference(decision).inDays;

    if (daysPassed > 30) return const Color(0xFFEF4444); // Red
    if (daysPassed > 25) return const Color(0xFFF59E0B); // Amber/Orange
    return const Color(0xFF10B981); // Green
  }

  String _getNormalizedStage(String? status) {
    // Robust normalization: lowercase, no spaces, no '+' signs
    final s = (status ?? '').toLowerCase().replaceAll(' ', '').replaceAll('+', '');
    if (s.contains('txn')) return 'Activated';
    if (s.contains('inactive')) return 'Inactive'; 
    if (s.contains('v')) return 'Txn Pending';
    return 'Inactive';
  }

  Color _getStageColor(String normalizedStage) {
    if (normalizedStage == 'Activated') return const Color(0xFF10B981); // Green
    if (normalizedStage == 'Txn Pending') return const Color(0xFFF43F5E); // Rose (Red-ish but distinct)
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    final daysLeftText = record.decisionDate != null ? _getDaysLeftText(record.decisionDate!) : 'N/A';
    final daysColor = record.decisionDate != null ? _getDaysColor(record.decisionDate!) : Colors.grey;
    final normalizedStage = _getNormalizedStage(record.bankStatus);
    final stageColor = _getStageColor(normalizedStage);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.customerName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      if (record.arnNo != null && record.arnNo!.isNotEmpty)
                        Text(
                          record.arnNo!,
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                Text(
                  daysLeftText,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: daysColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: const Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    record.decisionDate != null
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Approved on ',
                                  style: TextStyle(fontSize: 11, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: DateFormat('dd MMM').format(record.decisionDate!),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF4B5563)),
                                ),
                              ],
                            ),
                          )
                        : const Text('N/A', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                  ],
                ),
                Text(
                  normalizedStage,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: stageColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (record.userStatus == 'Pending' || (record.userStatus?.isEmpty ?? true))
                            ? 'No Action Taken'
                            : record.userStatus!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getUserStatusColor(record.userStatus ?? ''),
                        ),
                      ),
                      if (record.followupDate != null && record.userStatus == 'Follow up')
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Follow up on: ${DateFormat('dd MMM').format(record.followupDate!)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                          ),
                        ),
                      if (record.userRemarks != null && record.userRemarks!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            record.userRemarks!,
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (record.syncPending)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF4B5563), size: 20),
                      onPressed: onStatusTap,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.call_rounded, color: Color(0xFF3B82F6), size: 24),
                      onPressed: () => onCallTap(record),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(10),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getUserStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('done')) return const Color(0xFF10B981);
    if (status.contains('follow')) return const Color(0xFF3B82F6);
    if (status.contains('denied')) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }
}

class _ActivationScreenState extends State<ActivationScreen> {
  bool _isManualSyncing = false;
  String _activeChip = 'Inactive';
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ActivationService.syncDown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getUserWeight(String? status) {
    if (status == null || status.isEmpty || status.toLowerCase() == 'pending') return 0;
    final s = status.toLowerCase();
    if (s.contains('follow up')) return 1;
    if (s.contains('help required')) return 2;
    if (s.contains('customer denied')) return 3;
    if (s.contains('activation done')) return 4;
    if (s.contains('transaction done')) return 5;
    return 1; // Default for other actions
  }

  Widget _buildFilterChips() {
    if (_isSearching) return const SizedBox.shrink();
    final chips = ['All', 'Inactive', 'Txn Pending'];
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
    final isSelected = _activeChip == label;
    const color = Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _activeChip = label),
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
    setState(() => _isManualSyncing = true);
    await ActivationService.syncDown();
    if (mounted) setState(() => _isManualSyncing = false);
  }

  Future<void> _makeCall(ActivationRecord record) async {
    final url = 'tel:+91${record.mobileNo}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      ActivationService.markAsSeen(record.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
      }
    }
  }

  void _showStatusUpdateSheet(ActivationRecord record) {
    String selectedStatus = record.userStatus ?? 'Pending';
    final remarksController = TextEditingController(text: record.userRemarks);
    DateTime? selectedFollowupDate = record.followupDate;
    String? errorText;

    // Stage-based Logic:
    final bStatusNormalized = (record.bankStatus ?? '').toLowerCase().replaceAll(' ', '').replaceAll('+', '');
    bool isInactive = bStatusNormalized == 'inactive';
    bool isTxnPending = !isInactive && bStatusNormalized.contains('v');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 16, right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Activation Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              if (isInactive)
                _buildStatusOption('Activation Done', Icons.flash_on_rounded, const Color(0xFF10B981), 
                    selectedStatus == 'Activation Done', () => setModalState(() {
                      if (selectedStatus != 'Activation Done') remarksController.clear();
                      selectedStatus = 'Activation Done';
                    })),
              
              _buildStatusOption('Transaction Done', Icons.shopping_bag_rounded, const Color(0xFF10B981), 
                  selectedStatus == 'Transaction Done', () => setModalState(() {
                    if (selectedStatus != 'Transaction Done') remarksController.clear();
                    selectedStatus = 'Transaction Done';
                  })),
              
              _buildStatusOption('Follow up', Icons.history_rounded, const Color(0xFF3B82F6), 
                  selectedStatus == 'Follow up', () => setModalState(() {
                    if (selectedStatus != 'Follow up') remarksController.clear();
                    selectedStatus = 'Follow up';
                  })),
              
              if (isInactive)
                _buildStatusOption('Help Required', Icons.help_outline_rounded, const Color(0xFFF59E0B), 
                    selectedStatus == 'Help Required', () => setModalState(() {
                      if (selectedStatus != 'Help Required') remarksController.clear();
                      selectedStatus = 'Help Required';
                    })),

              if (isTxnPending)
                _buildStatusOption('Customer Denied', Icons.cancel_rounded, const Color(0xFFEF4444), 
                    selectedStatus == 'Customer Denied', () => setModalState(() {
                      if (selectedStatus != 'Customer Denied') remarksController.clear();
                      selectedStatus = 'Customer Denied';
                    })),
              
              if (selectedStatus == 'Follow up') ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedFollowupDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) setModalState(() => selectedFollowupDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 12),
                        Text(
                          selectedFollowupDate == null 
                            ? 'Select Follow-up Date*' 
                            : 'Date: ${DateFormat('dd MMM yyyy').format(selectedFollowupDate!)}',
                          style: TextStyle(
                            color: selectedFollowupDate == null ? Colors.red : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                onChanged: (_) => setModalState(() => errorText = null),
                decoration: InputDecoration(
                  labelText: 'Remarks*',
                  errorText: errorText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (remarksController.text.trim().isEmpty) {
                      setModalState(() => errorText = 'Remarks are mandatory*');
                      return;
                    }
                    if (selectedStatus == 'Follow up' && selectedFollowupDate == null) {
                      setModalState(() => errorText = 'Please select a follow-up date');
                      return;
                    }

                    ActivationService.updateStatus(
                      id: record.id,
                      status: selectedStatus,
                      remarks: remarksController.text.trim(),
                      followupDate: selectedStatus == 'Follow up' ? selectedFollowupDate : null,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Update', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String label, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 2),
            color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? color : Colors.black87)),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
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
                  hintText: 'Search Name, Mobile or ARN...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                ),
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('Activation Leads', style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold)),
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
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _isSearching = true),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 20),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _isManualSyncing ? null : _handleRefresh,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
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
            child: StreamBuilder<List<ActivationRecord>>(
              stream: ActivationService.getActivationStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                final records = snapshot.data!.where((r) {
                  // Normalization of Bank Status
                  final bStatus = (r.bankStatus ?? '').toLowerCase().replaceAll(' ', '').replaceAll('+', '');
                  final isTxnActive = bStatus.contains('txn');
                  final isInactive = bStatus.contains('inactive');
                  final isTxnPending = !isInactive && bStatus.contains('v');

                  // 1. AUTO-HIDE: On 37th day (Actual TAT is 36)
                  if (r.decisionDate != null) {
                    final daysPassed = today.difference(DateTime(r.decisionDate!.year, r.decisionDate!.month, r.decisionDate!.day)).inDays;
                    if (daysPassed > 36) return false;
                  }

                  // 2. SEARCH: Overrides all filters (including Active status)
                  if (_isSearching && _searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    return r.customerName.toLowerCase().contains(q) || 
                           r.mobileNo.contains(q) || 
                           (r.arnNo?.toLowerCase().contains(q) ?? false);
                  }

                  // 3. BASE FILTER: Exclude Txn Active cases from normal workflow
                  if (isTxnActive) return false;

                  // 4. CHIP FILTER
                  if (_activeChip == 'Inactive') return isInactive;
                  if (_activeChip == 'Txn Pending') return isTxnPending;
                  
                  return true; // For 'All' chip (which excludes isTxnActive from above)
                }).toList();

                // SORTING: Priority 1: Pending Action. Priority 2: Days Passed (Descending - Urgent first)
                records.sort((a, b) {
                  final wA = _getUserWeight(a.userStatus);
                  final wB = _getUserWeight(b.userStatus);
                  if (wA != wB) return wA.compareTo(wB);

                  // Group-specific sorting
                  if (wA == 0) {
                    // No Action: Oldest decision first (Urgent)
                    if (a.decisionDate == null) return 1;
                    if (b.decisionDate == null) return -1;
                    return a.decisionDate!.compareTo(b.decisionDate!);
                  } else if (wA == 1) {
                    // Follow up: Earliest follow-up first
                    if (a.followupDate == null) return 1;
                    if (b.followupDate == null) return -1;
                    return a.followupDate!.compareTo(b.followupDate!);
                  } else {
                    // Help Required, Denied, Done: Oldest status update first (To see delayed cases)
                    if (a.userStatusDate == null) return 1;
                    if (b.userStatusDate == null) return -1;
                    return a.userStatusDate!.compareTo(b.userStatusDate!);
                  }
                });

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isSearching ? Icons.search_off_rounded : Icons.flash_off_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(_isSearching ? 'No results for "$_searchQuery"' : 'No activation leads found', 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    itemCount: records.length,
                    itemBuilder: (context, index) => _LeadActivationCard(
                      record: records[index],
                      onStatusTap: () => _showStatusUpdateSheet(records[index]),
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
