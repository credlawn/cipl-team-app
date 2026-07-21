import 'dart:async';
import 'package:flutter/material.dart';
import '../models/login_case_model.dart';
import '../services/login_case_service.dart';
import '../widgets/login_case_card.dart';
import '../widgets/section_header.dart';

class MyLoginScreen extends StatefulWidget {
  final StatusFilterType? initialStatusFilter;

  const MyLoginScreen({
    super.key,
    this.initialStatusFilter,
  });

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  DateFilterType _dateFilter = DateFilterType.thisMonth;
  StatusFilterType _statusFilter = StatusFilterType.all;
  bool _isSyncing = false;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialStatusFilter != null) {
      _statusFilter = widget.initialStatusFilter!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncFromServer() async {
    setState(() => _isSyncing = true);
    
    try {
      await LoginCaseService.syncFromServer();
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Sync failed';
        
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Failed host lookup')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Connection timeout';
        } else if (e.toString().contains('401') || 
                   e.toString().contains('403')) {
          errorMessage = 'Authentication failed';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by name, mobile, ARN...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 400), () {
                    setState(() {
                      _searchQuery = value;
                    });
                  });
                },
              )
            : Row(
                children: [
                  Flexible(
                    child: _buildDateFilterDropdown(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildStatusFilterDropdown(),
                  ),
                ],
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              tooltip: 'Close search',
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              tooltip: 'Search',
            ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncFromServer,
            tooltip: 'Sync',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<LoginCase>>(
        stream: LoginCaseService.watchCases(
          dateFilter: _dateFilter,
          statusFilter: _statusFilter,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final cases = snapshot.data ?? [];
          
          if (cases.isEmpty) {
            return _buildEmptyState();
          }

          final groupedCases = LoginCaseService.groupByDate(cases);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedCases.length,
            itemBuilder: (context, index) {
              final dateKey = groupedCases.keys.elementAt(index);
              final casesForDate = groupedCases[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: dateKey),
                  const SizedBox(height: 8),
                  ...casesForDate.map((loginCase) => LoginCaseCard(
                        loginCase: loginCase,
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateFilterDropdown() {
    return PopupMenuButton<DateFilterType>(
      initialValue: _dateFilter,
      onSelected: (value) {
        setState(() {
          _dateFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getDateFilterLabel(_dateFilter),
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: DateFilterType.thisMonth,
          child: Text('This Month'),
        ),
        const PopupMenuItem(
          value: DateFilterType.lastMonth,
          child: Text('Last Month'),
        ),
      ],
    );
  }

  Widget _buildStatusFilterDropdown() {
    return PopupMenuButton<StatusFilterType>(
      initialValue: _statusFilter,
      onSelected: (value) {
        setState(() {
          _statusFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStatusFilterLabel(_statusFilter),
              style: TextStyle(
                fontSize: 12,
                color: _statusFilter == StatusFilterType.approved
                    ? const Color(0xFF10B981)
                    : _statusFilter == StatusFilterType.declined
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _statusFilter == StatusFilterType.approved
                  ? const Color(0xFF10B981)
                  : _statusFilter == StatusFilterType.declined
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: StatusFilterType.all,
          child: Text('All Status'),
        ),
        PopupMenuItem(
          value: StatusFilterType.approved,
          child: Text(
            'IP Approved',
            style: TextStyle(color: const Color(0xFF10B981)),
          ),
        ),
        PopupMenuItem(
          value: StatusFilterType.declined,
          child: Text(
            'IP Decline',
            style: TextStyle(color: const Color(0xFFEF4444)),
          ),
        ),
      ],
    );
  }

  String _getDateFilterLabel(DateFilterType filter) {
    switch (filter) {
      case DateFilterType.thisMonth:
        return 'This Month';
      case DateFilterType.lastMonth:
        return 'Last Month';
    }
  }

  String _getStatusFilterLabel(StatusFilterType filter) {
    switch (filter) {
      case StatusFilterType.all:
        return 'All Status';
      case StatusFilterType.approved:
        return 'IP Approved';
      case StatusFilterType.declined:
        return 'IP Decline';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No logins found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'for this period',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
