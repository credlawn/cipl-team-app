import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/lead_service.dart';
import '../database/app_database.dart';
import '../services/lead_feedback_service.dart';
import '../services/apply_link_service.dart';
import 'lead_details_screen.dart';
import 'add_lead_screen.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  String _selectedFilter = 'New';
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isSyncing = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final Map<String, List<String>> _filterMap = {
    'New': ['New'],
    'Called': ['Called'],
    'CNR': ['CNR', 'Voicemail'],
    'Hold': ['Hold'],
    'Follow Up': ['Follow Up'],
    'Others': ['No Docs', 'Not Eligible', 'Denied', 'Already Carded', 'Recently Applied'],
  };

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

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'New':
        return const Color(0xFF1976D2);
      case 'Called':
        return const Color(0xFFFF9800);
      case 'CNR':
        return const Color(0xFFF44336);
      case 'Hold':
        return const Color(0xFF9C27B0);
      case 'Follow Up':
        return const Color(0xFF00BCD4);
      case 'Others':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getDateTimeText(Lead lead) {
    if (lead.leadStatus.toLowerCase() == 'new') {
      return '';
    }
    
    if (lead.leadStatus.toLowerCase() == 'follow up' && lead.followupTime != null) {
      final date = DateFormat('d MMM yy').format(lead.followupTime!);
      final time = DateFormat('h:mm a').format(lead.followupTime!);
      return '$date, $time';
    }
    
    return DateFormat('d MMM yy').format(lead.leadStatusDate);
  }

  String? _getSortBy(String filter) {
    switch (filter) {
      case 'New':
        return null;
      case 'Follow Up':
        return 'followup_time';
      default:
        return 'lead_status_date';
    }
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final leadDate = DateTime(date.year, date.month, date.day);

    if (leadDate == today) {
      return 'TODAY';
    } else if (leadDate == yesterday) {
      return 'YESTERDAY';
    } else {
      return DateFormat('d MMM yy').format(date).toUpperCase();
    }
  }

  Map<String, List<Lead>> _groupLeadsByDate(List<Lead> leads) {
    final grouped = <String, List<Lead>>{};
    for (final lead in leads) {
      final header = _getDateHeader(lead.leadStatusDate);
      if (!grouped.containsKey(header)) {
        grouped[header] = [];
      }
      grouped[header]!.add(lead);
    }
    return grouped;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }

  List<Lead> _filterLeads(List<Lead> leads) {
    if (_searchQuery.isEmpty) return leads;
    
    return leads.where((lead) {
      final nameMatch = lead.customerName.toLowerCase().contains(_searchQuery);
      final mobileMatch = lead.mobileNo.contains(_searchQuery);
      final statusMatches = _isSearching || _filterMap[_selectedFilter]!.contains(lead.leadStatus);
      return (nameMatch || mobileMatch) && statusMatches;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    await LeadService.manualRefresh();
    await LeadFeedbackService.syncUp();
    await LeadFeedbackService.syncDown();
    await ApplyLinkService.syncDown();
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final color = _getFilterColor(label);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 0 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by name or mobile...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                ),
                style: const TextStyle(color: Color(0xFF1A1A1A)),
                onChanged: _onSearchChanged,
              )
            : const Text(
                'Leads',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded, color: Color(0xFFDC2626), size: 18),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _isSearching = true),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, color: Color(0xFF1A73E8), size: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _isSyncing ? null : () async {
                  setState(() => _isSyncing = true);
                  try {
                    await LeadService.manualRefresh();
                    await LeadFeedbackService.syncUp();
                    await LeadFeedbackService.syncDown();
                    await ApplyLinkService.syncDown();
                  } finally {
                    if (mounted) setState(() => _isSyncing = false);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF16A34A),
                          ),
                        )
                      : const Icon(Icons.sync_rounded, color: Color(0xFF16A34A), size: 18),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Sticky filter chip strip — stays fixed while list scrolls
          if (!_isSearching)
            Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _buildFilterChip('New'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Called'),
                        const SizedBox(width: 8),
                        _buildFilterChip('CNR'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Hold'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Follow Up'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Others'),
                      ],
                    ),
                  ),
                  Container(height: 1, color: const Color(0xFFE5E7EB)),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Lead>>(
        stream: _isSearching
            ? LeadService.getLeadsStream()
            : LeadService.getFilteredLeadsStream(
                _filterMap[_selectedFilter]!,
                sortBy: _getSortBy(_selectedFilter),
              ),
        builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading leads"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allLeads = snapshot.data!;
                final leads = _filterLeads(allLeads);

                if (leads.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF1A73E8),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No $_selectedFilter leads',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_selectedFilter == 'Others') {
                  final groupedLeads = _groupLeadsByDate(leads);
                  final headers = groupedLeads.keys.toList();

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF1A73E8),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: headers.fold<int>(0, (sum, header) => sum + groupedLeads[header]!.length + 1),
                      itemBuilder: (context, index) {
                        int currentIndex = 0;
                        for (final header in headers) {
                          if (index == currentIndex) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Text(
                                header,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          }
                          currentIndex++;

                          final leadsInGroup = groupedLeads[header]!;
                          final leadIndexInGroup = index - currentIndex;

                          if (leadIndexInGroup < leadsInGroup.length) {
                            final lead = leadsInGroup[leadIndexInGroup];
                            final dateTimeText = _getDateTimeText(lead);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                onTap: () {
                                  final leadIds = leads.map((l) => l.id).toList();
                                  final actualIndex = leads.indexOf(lead);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => LeadDetailsScreen(leadIds: leadIds, initialIndex: actualIndex),
                                  ));
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(lead.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF202124)))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: _getStatusColor(lead.leadStatus), borderRadius: BorderRadius.circular(12)),
                                            child: Text(lead.leadStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (lead.city != null && lead.city!.isNotEmpty)
                                        Row(children: [
                                          const Icon(Icons.location_city_outlined, size: 14, color: Color(0xFF5F6368)),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(lead.city!, style: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)))),
                                          if (dateTimeText.isNotEmpty)
                                            Text(dateTimeText, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368))),
                                        ]),
                                      if (lead.employer != null && lead.employer!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          const Icon(Icons.business_outlined, size: 14, color: Color(0xFF5F6368)),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(lead.employer!, style: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ]),
                                      ],
                                      if (lead.syncPending) ...[
                                        const SizedBox(height: 8),
                                        const Row(children: [
                                          Icon(Icons.sync, size: 12, color: Color(0xFFFF9800)),
                                          SizedBox(width: 4),
                                          Text('Sync Pending...', style: TextStyle(fontSize: 11, color: Color(0xFFFF9800), fontStyle: FontStyle.italic)),
                                        ]),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          currentIndex += leadsInGroup.length;
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: const Color(0xFF1A73E8),
                  child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    final dateTimeText = _getDateTimeText(lead);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          final leadIds = leads.map((l) => l.id).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LeadDetailsScreen(
                                leadIds: leadIds,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lead.customerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF202124),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(lead.leadStatus),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      lead.leadStatus,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (lead.city != null && lead.city!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_city_outlined, size: 14, color: Color(0xFF5F6368)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        lead.city!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF5F6368),
                                        ),
                                      ),
                                    ),
                                    if (dateTimeText.isNotEmpty)
                                      Text(
                                        dateTimeText,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5F6368),
                                        ),
                                      ),
                                  ],
                                ),
                              if (lead.employer != null && lead.employer!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.business_outlined, size: 14, color: Color(0xFF5F6368)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        lead.employer!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF5F6368),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (lead.syncPending) ...[
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(Icons.sync, size: 12, color: Color(0xFFFF9800)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Sync Pending...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFFF9800),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                );
        },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLeadScreen()),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
