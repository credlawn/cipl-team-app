import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
import '../services/vkyc_service.dart';

class VkycScreen extends StatefulWidget {
  const VkycScreen({super.key});

  @override
  State<VkycScreen> createState() => _VkycScreenState();
}

class _LeadVkycCard extends StatelessWidget {
  final VkycRecord record;
  final VoidCallback onStatusTap;
  final Function(VkycRecord) onWhatsappTap;
  final Function(VkycRecord) onCopyTap;
  final Function(VkycRecord) onCallTap;

  const _LeadVkycCard({
    required this.record,
    required this.onStatusTap,
    required this.onWhatsappTap,
    required this.onCopyTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = record.vkycExpiryDate != null && record.vkycExpiryDate!.isBefore(DateTime.now());
    final isExpiringSoon = record.vkycExpiryDate != null && 
        !isExpired && 
        record.vkycExpiryDate!.isBefore(DateTime.now().add(const Duration(hours: 24)));

    Color expiryColor = Colors.green;
    if (isExpired) expiryColor = Colors.red;
    else if (isExpiringSoon) expiryColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      Row(
                        children: [
                          Text(
                            record.customerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (record.arnNo != null && record.arnNo!.isNotEmpty)
                        Text(
                          record.arnNo!,
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2), // Very soft pink-red
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFECDD3)), // Soft pink border
                      ),
                      child: Text(
                        record.bankVkycStatus,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF43F5E), // Pink-red
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (record.syncPending) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onStatusTap,
              child: _buildStatusBadge(
                'Emp', 
                (record.userVkycStatus == 'Pending' || record.userVkycStatus.isEmpty) 
                    ? 'Pending' 
                    : record.userVkycStatus, 
                Colors.teal, 
                isInteractive: true
              ),
            ),
            const SizedBox(height: 12),
            if (record.userRemarks != null && record.userRemarks!.isNotEmpty)
               Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  record.userRemarks!,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF4B5563)),
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Link Expiry',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      record.vkycExpiryDate != null 
                        ? DateFormat('dd MMM, hh:mm a').format(record.vkycExpiryDate!)
                        : 'No Expiry Set',
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w600,
                        color: expiryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call_rounded, color: Color(0xFF3B82F6), size: 20),
                      onPressed: () => onCallTap(record),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.content_copy_rounded, color: Color(0xFF6B7280), size: 20),
                      onPressed: () => onCopyTap(record),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: Color(0xFF10B981), size: 20),
                      onPressed: () => onWhatsappTap(record),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
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

  Color _getStatusColor(String status, Color defaultColor) {
    status = status.toLowerCase();
    if (status.contains('kyc done')) return const Color(0xFF10B981); // Green
    if (status.contains('denied')) return const Color(0xFFEF4444); // Red
    if (status.contains('docs issue')) return const Color(0xFFF59E0B); // Orange/Amber
    return defaultColor;
  }

  Widget _buildStatusBadge(String title, String status, Color color, {bool isInteractive = false}) {
    final statusColor = _getStatusColor(status, color);
    return Row(
      children: [
        Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        if (isInteractive) ...[
          const Spacer(),
          Icon(Icons.edit_outlined, size: 16, color: statusColor.withOpacity(0.7)),
        ],
      ],
    );
  }
}

class _VkycScreenState extends State<VkycScreen> {
  bool _isManualSyncing = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    VkycService.syncDown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isManualSyncing = true);
    await VkycService.syncDown();
    if (mounted) setState(() => _isManualSyncing = false);
  }

  void _copyToClipboard(VkycRecord record) {
    if (record.vkycLink == null) return;
    Clipboard.setData(ClipboardData(text: record.vkycLink!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VKYC Link copied to clipboard')),
    );
    VkycService.markAsSeen(record.id);
  }

  Future<void> _shareOnWhatsapp(VkycRecord record) async {
    final name = record.customerName;
    final link = record.vkycLink ?? '';
    
    final msg = Uri.encodeComponent(
      'Hello *$name* Ji,\n\n'
      'Your VKYC Link is:\n'
      '$link\n\n'
      'Please complete the verification before the link expires.\n\n'
      'Thank you!'
    );
    
    final url = 'https://wa.me/91${record.mobileNo}?text=$msg';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      VkycService.markAsSeen(record.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _makeCall(VkycRecord record) async {
    final url = 'tel:+91${record.mobileNo}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      VkycService.markAsSeen(record.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer')),
        );
      }
    }
  }

  int _getStatusWeight(String status) {
    status = status.toLowerCase();
    if (status == 'pending' || status.isEmpty) return 0; // Unactioned / Fresh
    return 1; // Anything else (Actioned)
  }

  void _showStatusUpdateSheet(VkycRecord record) {
    String selectedStatus = record.userVkycStatus;
    final remarksController = TextEditingController(text: record.userRemarks);
    String? errorText;
    
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
              const Text('Update VKYC Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildStatusOption(
                'KYC Done', 
                Icons.check_circle_rounded, 
                const Color(0xFF10B981), 
                selectedStatus == 'KYC Done',
                () => setModalState(() {
                  if (selectedStatus != 'KYC Done') remarksController.clear();
                  selectedStatus = 'KYC Done';
                  errorText = null;
                })
              ),
              _buildStatusOption(
                'Customer Denied', 
                Icons.cancel_rounded, 
                const Color(0xFFEF4444), 
                selectedStatus == 'Customer Denied',
                () => setModalState(() {
                  if (selectedStatus != 'Customer Denied') remarksController.clear();
                  selectedStatus = 'Customer Denied';
                  errorText = null;
                })
              ),
              _buildStatusOption(
                'Docs Issue', 
                Icons.description_rounded, 
                const Color(0xFFF59E0B), 
                selectedStatus == 'Docs Issue',
                () => setModalState(() {
                  if (selectedStatus != 'Docs Issue') remarksController.clear();
                  selectedStatus = 'Docs Issue';
                  errorText = null;
                })
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                onChanged: (_) {
                  if (errorText != null) setModalState(() => errorText = null);
                },
                decoration: InputDecoration(
                  labelText: 'Remarks*',
                  hintText: 'Enter reason for denial or issue',
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
                    final statusNeedsRemarks = (selectedStatus == 'Customer Denied' || selectedStatus == 'Docs Issue');
                    if (statusNeedsRemarks && remarksController.text.trim().isEmpty) {
                      setModalState(() => errorText = 'Remarks are mandatory*');
                      return;
                    }
                    VkycService.updateUserStatus(record.id, selectedStatus, remarksController.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 2),
            color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
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
                  hintText: 'Search VKYC Name or Mobile...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                ),
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('VKYC Leads', style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold)),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 18),
                ),
              ),
            ),
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
      body: StreamBuilder<List<VkycRecord>>(
        stream: VkycService.getVkycStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final records = snapshot.data!.where((r) {
            // IF Searching: Ignore ALL filters (User Status, Bank Status, Expiry)
            if (_isSearching && _searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchesName = r.customerName.toLowerCase().contains(query);
              final matchesMobile = r.mobileNo.contains(query);
              final matchesArn = r.arnNo?.toLowerCase().contains(query) ?? false;
              return matchesName || matchesMobile || matchesArn;
            }

            // Default View Logic:
            // 1. Expiry Filter (Today or Future)
            bool isNotExpired = true;
            if (r.vkycExpiryDate != null) {
              final expiryDate = DateTime(r.vkycExpiryDate!.year, r.vkycExpiryDate!.month, r.vkycExpiryDate!.day);
              isNotExpired = expiryDate.isAtSameMomentAs(today) || expiryDate.isAfter(today);
            }

            // 2. Bank Status Filter (Only show Pending)
            final isPending = r.bankVkycStatus.toLowerCase() == 'pending';

            return isNotExpired && isPending;
          }).toList();

          // SMART SORTING SEQUENCE:
          // 1. Unactioned (Pending) at the top, sorted by Expiry Date (Urgent first).
          // 2. Actioned leads at the bottom, sorted by updated date (Latest first).
          records.sort((a, b) {
            final weightA = _getStatusWeight(a.userVkycStatus);
            final weightB = _getStatusWeight(b.userVkycStatus);

            if (weightA != weightB) return weightA.compareTo(weightB);

            if (weightA == 0) {
              // Both Pending: Sort by Expiry Date (Ascending - Earliest first)
              if (a.vkycExpiryDate == null && b.vkycExpiryDate == null) return 0;
              if (a.vkycExpiryDate == null) return 1;
              if (b.vkycExpiryDate == null) return -1;
              return a.vkycExpiryDate!.compareTo(b.vkycExpiryDate!);
            } else {
              // Both Actioned: Sort by Updated Date (Descending - Latest first)
              return b.updated.compareTo(a.updated);
            }
          });

          if (records.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                children: [
                   SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                   Center(
                      child: Column(
                        children: [
                          Icon(_isSearching ? Icons.search_off_rounded : Icons.videocam_off_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching ? 'No results for "$_searchQuery"' : 'No VKYC records found', 
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
              itemCount: records.length,
              itemBuilder: (context, index) => _LeadVkycCard(
                record: records[index],
                onStatusTap: () => _showStatusUpdateSheet(records[index]),
                onWhatsappTap: _shareOnWhatsapp,
                onCopyTap: _copyToClipboard,
                onCallTap: _makeCall,
              ),
            ),
          );
        },
      ),
    );
  }
}
