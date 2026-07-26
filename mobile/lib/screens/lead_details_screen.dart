import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
import '../services/lead_service.dart';
import '../services/call_log_service.dart';
import '../services/apply_link_service.dart';
import '../core/pb_api.dart';
import 'customer_feedback_screen.dart';
import 'package:intl/intl.dart';

class LeadDetailsScreen extends StatefulWidget {
  final List<String> leadIds;
  final int initialIndex;

  const LeadDetailsScreen({
    super.key,
    required this.leadIds,
    required this.initialIndex,
  });

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  bool _isApplyLinksExpanded = false;
  late Lead lead;
  late PageController _pageController;
  late int _currentIndex;
  String? _currentLeadId;
  String? _employeeId;
  String? _employeeCode;
  String? _employeeName;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addObserver(this);
    _loadEmployeeId();
  }

  Future<void> _loadEmployeeId() async {
    final authModel = PB.pb.authStore.model;
    if (authModel != null) {
      setState(() {
        _employeeId = authModel.id;
        _employeeCode = authModel.data['employee_code'] ?? '';
        _employeeName = authModel.data['employee_name'] ?? '';
      });
    }
  }



  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  Future<void> _makeCall(String number, String leadId) async {
    try {
      final phonePermission = await Permission.phone.request();
      final callLogPermission = await Permission.phone.request(); // Android 9+ needs CALL_LOG group
      // Note: On newer Android, READ_CALL_LOG is in a separate group or needs specific request
      // Let's request both explicitly
      Map<Permission, PermissionStatus> statuses = await [
        Permission.phone,
        Permission.ignoreBatteryOptimizations, // Optional but good for background
      ].request();
      
      // For Call Log specifically
      var callLogStatus = await Permission.contacts.status; // Sometimes grouped
      if (!await Permission.phone.isGranted) {
         await Permission.phone.request();
      }
      
      // We need READ_CALL_LOG permission
      // Since permission_handler 8.0+, we might need to add it to podfile/gradle if not standard
      // But we added it to AndroidManifest.
      
      // Let's just request phone, as it usually covers basic phone state. 
      // BUT for reading call log, we need explicit permission if sensitive.
      // Let's try requesting the specific permission if available in the package, 
      // or just rely on the manifest + phone permission for now as they are often grouped.
      // Wait, we need to be sure.
      
      // Actually, let's request multiple permissions properly
      final permissions = await [
        Permission.phone,
        // Permission.callLog, // Not always available directly in older versions of package
      ].request();

      // Check if phone permission is granted (critical)
      if (permissions[Permission.phone] != PermissionStatus.granted) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone permission required for call logging'),
              backgroundColor: Color(0xFFFF9800),
            ),
          );
        }
        return;
      }
      
      _currentLeadId = leadId;
      
      await CallLogService.callChannel.invokeMethod('startCallTracking', {
        'phoneNumber': number,
        'leadId': leadId,
        'employeeId': _employeeId,
        'employeeCode': _employeeCode,
        'employeeName': _employeeName,
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      await FlutterPhoneDirectCaller.callNumber(number);
    } catch (e) {
      await FlutterPhoneDirectCaller.callNumber(number);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to make call: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }



  Widget _buildInfoRow(String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.isNotEmpty ? value : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF202124),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5F6368),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EAED)),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF1976D2);
      case 'called':
        return const Color(0xFFFF9800);
      case 'hold':
        return const Color(0xFF9C27B0);
      case 'ip approved':
        return const Color(0xFF4CAF50);
      case 'ip decline':
        return const Color(0xFFF44336);
      case 'no docs':
      case 'not eligible':
        return const Color(0xFF795548);
      case 'denied':
        return const Color(0xFFFF9800);
      case 'already carded':
      case 'recently applied':
        return const Color(0xFF607D8B);
      case 'follow up':
        return const Color(0xFF00BCD4);
      case 'cnr':
      case 'voicemail':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Lead ${_currentIndex + 1} / ${widget.leadIds.length}'),
        elevation: 0,
        actions: [
          StreamBuilder<Lead?>(
            stream: LeadService.getLeadByIdStream(widget.leadIds[_currentIndex]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final lead = snapshot.data!;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerFeedbackScreen(
                          leadId: lead.id,
                          customerName: lead.customerName,
                          mobileNo: lead.mobileNo,
                          currentStatus: lead.leadStatus,
                          currentStatusDate: lead.leadStatusDate,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_note,
                      color: Color(0xFF1A73E8),
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.leadIds.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return _buildLeadDetails(widget.leadIds[index]);
        },
      ),
    );
  }

  Widget _buildLeadDetails(String leadId) {
    return StreamBuilder<Lead?>(
      stream: LeadService.getLeadByIdStream(leadId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading lead details'));
          }

          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.active) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lead no longer assigned to you'),
                      backgroundColor: Color(0xFFFF9800),
                    ),
                  );
                }
              });
              return const SizedBox();
            }
            return const Center(child: CircularProgressIndicator());
          }

          final lead = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lead.customerName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF202124),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(lead.leadStatus),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    lead.leadStatus,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (lead.syncPending) ...[
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Icon(Icons.sync, size: 14, color: Color(0xFFFF9800)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Sync Pending...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFF9800),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            FutureBuilder<bool>(
                              future: lead.leadStatus.toLowerCase() == 'new' 
                                  ? LeadService.hasPendingFeedback() 
                                  : Future.value(false),
                              builder: (context, snapshot) {
                                final shouldMask = snapshot.data ?? false;
                                final displayNumber = shouldMask 
                                    ? '${lead.mobileNo.substring(0, 2)}${'*' * (lead.mobileNo.length - 4)}${lead.mobileNo.substring(lead.mobileNo.length - 2)}'
                                    : lead.mobileNo;
                                
                                return _buildCard([
                                  _buildInfoRow('Mobile', displayNumber),
                                  _buildInfoRow('City', lead.city ?? ''),
                                  _buildInfoRow('Employer', lead.employer ?? '', showDivider: false),
                                ]);
                              },
                            ),
                            _buildCard([
                              _buildInfoRow('Segment', lead.segment ?? ''),
                              if (lead.declineReason != null && lead.declineReason!.isNotEmpty)
                                _buildInfoRow('Reason', lead.declineReason!),
                              _buildInfoRow('Product', lead.product ?? '', showDivider: false),
                            ]),
                            StreamBuilder<List<ApplyLink>>(
                              stream: ApplyLinkService.watchLinks(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                
                                final links = snapshot.data!;
                                final defaultLink = links.firstWhere(
                                  (l) => l.isDefault,
                                  orElse: () => links.first,
                                );
                                final otherLinks = links.where((l) => l.id != defaultLink.id).toList();
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 160,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                final uri = Uri.parse(defaultLink.linkUrl);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                }
                                              },
                                              icon: const Icon(Icons.open_in_new, size: 16),
                                              label: Text(
                                                'Apply ${defaultLink.linkName}',
                                                style: const TextStyle(fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1976D2),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (otherLinks.isNotEmpty) ...[
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isApplyLinksExpanded = !_isApplyLinksExpanded;
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    _isApplyLinksExpanded ? 'Hide' : '+${otherLinks.length} More',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Icon(
                                                    _isApplyLinksExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                    size: 16,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),

                                      if (_isApplyLinksExpanded && otherLinks.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 2.5,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemCount: otherLinks.length,
                                          itemBuilder: (context, index) {
                                            final link = otherLinks[index];
                                            return OutlinedButton(
                                              onPressed: () async {
                                                final uri = Uri.parse(link.linkUrl);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                                side: BorderSide(color: Color(0xFFE5E7EB)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: Text(
                                                link.linkName,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF374151),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                            // Recent Calls Section
                            _buildRecentCallsSection(lead),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: FutureBuilder<bool>(
                  future: lead.leadStatus.toLowerCase() == 'new' 
                      ? LeadService.hasPendingFeedback() 
                      : Future.value(false),
                  builder: (context, snapshot) {
                    final shouldDisable = snapshot.data ?? false;
                    
                    return ElevatedButton.icon(
                      onPressed: shouldDisable 
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ Please submit pending feedback'),
                                  backgroundColor: Color(0xFFFF9800),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : () => _makeCall(lead.mobileNo, lead.id),
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text(
                        'Call',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: shouldDisable 
                            ? Colors.grey.shade400 
                            : const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
    );
  }

  Widget _buildRecentCallsSection(Lead lead) {
    return StreamBuilder<List<CallLog>>(
      stream: CallLogService.watchRecentCallLogsForLead(lead.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final calls = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF1976D2), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'RECENT CALLS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...calls.asMap().entries.map((entry) {
                final index = entry.key;
                final call = entry.value;
                return Column(
                  children: [
                    _buildCallItem(call),
                    if (index < calls.length - 1)
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallItem(CallLog call) {
    final duration = Duration(seconds: call.callDuration);
    final durationText = duration.inMinutes > 0
        ? '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s'
        : '${call.callDuration}s';

    Color iconColor;
    IconData icon;
    if (call.callType == 'missed') {
      iconColor = const Color(0xFFEF4444);
      icon = Icons.call_missed;
    } else if (call.callType == 'rejected') {
      iconColor = const Color(0xFFF59E0B);
      icon = Icons.call_end;
    } else if (call.callType == 'incoming') {
      iconColor = const Color(0xFF10B981);
      icon = Icons.call_received;
    } else {
      iconColor = const Color(0xFF3B82F6);
      icon = Icons.call_made;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        call.phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCallTime(call.callTimestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCallTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (checkDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (checkDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('dd MMM, h:mm a').format(timestamp);
    }
  }
}
