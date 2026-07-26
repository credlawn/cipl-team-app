import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'allocate_distribution_screen.dart';

class AllocateFilterScreen extends StatefulWidget {
  final String mode; // "allocate" or "reallocate"

  const AllocateFilterScreen({
    super.key,
    required this.mode,
  });

  @override
  State<AllocateFilterScreen> createState() => _AllocateFilterScreenState();
}

class _AllocateFilterScreenState extends State<AllocateFilterScreen> {
  bool _isLoading = true;
  bool _isLoadingCounts = false;
  bool _isFilterSectionCollapsed = false; // NEW: Collapse filter after counts load

  // Filter enable flags
  bool _enableDataCodeFilter = false;
  bool _enableDataSubCodeFilter = false;
  bool _enableCustomCodeFilter = false;
  bool _enableDeclineReasonFilter = false;

  // Filter values
  List<String> _availableDataCodes = [];
  List<String> _availableDataSubCodes = [];
  List<String> _availableCustomCodes = [];
  List<String> _availableDeclineReasons = [];

  // Filtered lists (for search)
  List<String> _filteredDataCodes = [];
  List<String> _filteredDataSubCodes = [];
  List<String> _filteredCustomCodes = [];
  List<String> _filteredDeclineReasons = [];

  // Search controllers
  TextEditingController _dataCodeSearchController = TextEditingController();
  TextEditingController _dataSubCodeSearchController = TextEditingController();
  TextEditingController _customCodeSearchController = TextEditingController();
  TextEditingController _declineReasonSearchController = TextEditingController();

  // Selected filters
  Set<String> _selectedDataCodes = {};
  Set<String> _selectedDataSubCodes = {};
  Set<String> _selectedCustomCodes = {};

  // For reallocation - Lead Status
  bool _includeCNR = false;
  bool _includeDenied = false;

  // Decline Reasons
  Set<String> _selectedDeclineReasons = {};

  // For reallocation - Allocation/Employee counts
  TextEditingController _minAllocCountController = TextEditingController();
  TextEditingController _maxAllocCountController = TextEditingController();
  TextEditingController _minEmpCountController = TextEditingController();
  TextEditingController _maxEmpCountController = TextEditingController();

  // Count breakdown
  List<Map<String, dynamic>> _customCodeBreakdown = [];
  int _totalCount = 0;

  // Selected counts per custom_code
  Map<String, TextEditingController> _countControllers = {};

  @override
  void initState() {
    super.initState();
    _loadFilterValues();
    
    // Add search listeners
    _dataCodeSearchController.addListener(_filterDataCodes);
    _dataSubCodeSearchController.addListener(_filterDataSubCodes);
    _customCodeSearchController.addListener(_filterCustomCodes);
    _declineReasonSearchController.addListener(_filterDeclineReasons);
  }

  @override
  void dispose() {
    _dataCodeSearchController.dispose();
    _dataSubCodeSearchController.dispose();
    _customCodeSearchController.dispose();
    _declineReasonSearchController.dispose();
    _minAllocCountController.dispose();
    _maxAllocCountController.dispose();
    _minEmpCountController.dispose();
    _maxEmpCountController.dispose();
    for (var controller in _countControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _filterDataCodes() {
    setState(() {
      final query = _dataCodeSearchController.text.toLowerCase();
      _filteredDataCodes = _availableDataCodes
          .where((code) => code.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filterDataSubCodes() {
    setState(() {
      final query = _dataSubCodeSearchController.text.toLowerCase();
      _filteredDataSubCodes = _availableDataSubCodes
          .where((code) => code.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filterCustomCodes() {
    setState(() {
      final query = _customCodeSearchController.text.toLowerCase();
      _filteredCustomCodes = _availableCustomCodes
          .where((code) => code.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filterDeclineReasons() {
    setState(() {
      final query = _declineReasonSearchController.text.toLowerCase();
      _filteredDeclineReasons = _availableDeclineReasons
          .where((reason) => reason.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadFilterValues() async {
    setState(() => _isLoading = true);

    try {
      final filterValues = await DatabaseService.getFilterValues();

      if (mounted) {
        setState(() {
          _availableDataCodes = filterValues['data_codes'] ?? [];
          _availableDataSubCodes = filterValues['data_sub_codes'] ?? [];
          _availableCustomCodes = filterValues['custom_codes'] ?? [];
          _availableDeclineReasons = filterValues['decline_reasons'] ?? [];
          
          // Initialize filtered lists
          _filteredDataCodes = _availableDataCodes;
          _filteredDataSubCodes = _availableDataSubCodes;
          _filteredCustomCodes = _availableCustomCodes;
          _filteredDeclineReasons = _availableDeclineReasons;
          
          _isLoading = false;
        });

        // Load initial counts
        _loadCounts();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading filters: $e')),
        );
      }
    }
  }

  Future<void> _loadCounts() async {
    // Validate lead status for reallocation
    if (widget.mode == 'reallocate' && !_includeCNR && !_includeDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one lead status (CNR or Denied)')),
      );
      return;
    }

    setState(() => _isLoadingCounts = true);

    try {
      // Build lead status list for reallocation
      List<String>? leadStatuses;
      if (widget.mode == 'reallocate') {
        leadStatuses = [];
        if (_includeCNR) {
          leadStatuses.addAll(['CNR', 'CNR+Voicemail']);
        }
        if (_includeDenied) {
          leadStatuses.add('Denied');
        }
      }

      final result = await DatabaseService.getCountByCustomCode(
        dataStatus: widget.mode == 'allocate' ? 'new' : 'used',
        dataCodes: _selectedDataCodes.isEmpty ? null : _selectedDataCodes.toList(),
        dataSubCodes: _selectedDataSubCodes.isEmpty ? null : _selectedDataSubCodes.toList(),
        customCodes: _selectedCustomCodes.isEmpty ? null : _selectedCustomCodes.toList(),
        leadStatuses: leadStatuses,
        declineReasons: _selectedDeclineReasons.isEmpty ? null : _selectedDeclineReasons.toList(),
        minAllocCount: _minAllocCountController.text.isEmpty ? null : int.tryParse(_minAllocCountController.text),
        maxAllocCount: _maxAllocCountController.text.isEmpty ? null : int.tryParse(_maxAllocCountController.text),
        minEmpCount: _minEmpCountController.text.isEmpty ? null : int.tryParse(_minEmpCountController.text),
        maxEmpCount: _maxEmpCountController.text.isEmpty ? null : int.tryParse(_maxEmpCountController.text),
      );

      if (mounted) {
        setState(() {
          _customCodeBreakdown = result['breakdown'];
          _totalCount = result['total_count'];

          // Initialize controllers for each custom_code
          _countControllers.clear();
          for (var item in _customCodeBreakdown) {
            _countControllers[item['custom_code']] = TextEditingController();
          }

          _isLoadingCounts = false;
          
          // Auto-collapse filter section if counts loaded successfully
          if (_customCodeBreakdown.isNotEmpty) {
            _isFilterSectionCollapsed = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCounts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading counts: $e')),
        );
      }
    }
  }

  int get _totalSelected {
    int total = 0;
    for (var controller in _countControllers.values) {
      total += int.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  void _proceedToDistribution() {
    // Build selections list
    List<Map<String, dynamic>> selections = [];

    for (var item in _customCodeBreakdown) {
      final customCode = item['custom_code'];
      final count = int.tryParse(_countControllers[customCode]?.text ?? '') ?? 0;

      if (count > 0) {
        final Map<String, dynamic> filters = {
          'data_codes': _selectedDataCodes.toList(),
          'data_sub_codes': _selectedDataSubCodes.toList(),
        };

        // Add decline_reasons filter (for both allocate and reallocate)
        if (_selectedDeclineReasons.isNotEmpty) {
          filters['decline_reasons'] = _selectedDeclineReasons.toList();
        }

        // Add lead_statuses for reallocate mode
        if (widget.mode == 'reallocate') {
          List<String> leadStatuses = [];
          if (_includeCNR) {
            leadStatuses.addAll(['CNR', 'CNR+Voicemail']);
          }
          if (_includeDenied) {
            leadStatuses.add('Denied');
          }
          if (leadStatuses.isNotEmpty) {
            filters['lead_statuses'] = leadStatuses;
          }

          // Add numeric range filters for reallocation
          if (_minAllocCountController.text.isNotEmpty) {
            filters['min_alloc_count'] = int.tryParse(_minAllocCountController.text);
          }
          if (_maxAllocCountController.text.isNotEmpty) {
            filters['max_alloc_count'] = int.tryParse(_maxAllocCountController.text);
          }
          if (_minEmpCountController.text.isNotEmpty) {
            filters['min_emp_count'] = int.tryParse(_minEmpCountController.text);
          }
          if (_maxEmpCountController.text.isNotEmpty) {
            filters['max_emp_count'] = int.tryParse(_maxEmpCountController.text);
          }
        }

        selections.add({
          'custom_code': customCode,
          'count': count,
          'filters': filters,
        });
      }
    }

    if (selections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one record')),
      );
      return;
    }

    // Navigate to distribution screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllocateDistributionScreen(
          mode: widget.mode,
          selections: selections,
          totalCount: _totalSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.mode == 'allocate' ? 'Allocate Leads (New Data)' : 'Reallocate Leads (Used Data)',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          // Filter selection icon
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_enableDataCodeFilter || _enableDataSubCodeFilter || _enableCustomCodeFilter || _enableDeclineReasonFilter)
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.tune,
                color: (_enableDataCodeFilter || _enableDataSubCodeFilter || _enableCustomCodeFilter || _enableDeclineReasonFilter)
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            tooltip: 'Select Filters',
            onPressed: _showFilterSelectionSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filters Section
                        _buildFiltersSection(),

                        // Count Breakdown Section
                        if (!_isLoadingCounts && _customCodeBreakdown.isNotEmpty)
                          _buildCountBreakdownSection(),

                        if (_isLoadingCounts)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),

                        const SizedBox(height: 80), // Space for footer
                      ],
                    ),
                  ),
                ),

                // Sticky Footer
                if (_totalSelected > 0) _buildFooter(),
              ],
            ),
    );
  }

  void _showFilterSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Filters to Apply',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('Data Code', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                  '${_availableDataCodes.length} options available',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                value: _enableDataCodeFilter,
                onChanged: (value) {
                  setState(() {
                    _enableDataCodeFilter = value ?? false;
                    if (!_enableDataCodeFilter) {
                      _selectedDataCodes.clear();
                      _dataCodeSearchController.clear();
                    }
                  });
                  setModalState(() {});
                },
                activeColor: const Color(0xFF3B82F6),
              ),

              CheckboxListTile(
                title: const Text('Data Sub Code', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                  '${_availableDataSubCodes.length} options available',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                value: _enableDataSubCodeFilter,
                onChanged: (value) {
                  setState(() {
                    _enableDataSubCodeFilter = value ?? false;
                    if (!_enableDataSubCodeFilter) {
                      _selectedDataSubCodes.clear();
                      _dataSubCodeSearchController.clear();
                    }
                  });
                  setModalState(() {});
                },
                activeColor: const Color(0xFF3B82F6),
              ),

              CheckboxListTile(
                title: const Text('Custom Code', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                  '${_availableCustomCodes.length} options available',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                value: _enableCustomCodeFilter,
                onChanged: (value) {
                  setState(() {
                    _enableCustomCodeFilter = value ?? false;
                    if (!_enableCustomCodeFilter) {
                      _selectedCustomCodes.clear();
                      _customCodeSearchController.clear();
                    }
                  });
                  setModalState(() {});
                },
                activeColor: const Color(0xFF3B82F6),
              ),

              CheckboxListTile(
                title: const Text('Decline Reason', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                  '${_availableDeclineReasons.length} options available',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                value: _enableDeclineReasonFilter,
                onChanged: (value) {
                  setState(() {
                    _enableDeclineReasonFilter = value ?? false;
                    if (!_enableDeclineReasonFilter) {
                      _selectedDeclineReasons.clear();
                      _declineReasonSearchController.clear();
                    }
                  });
                  setModalState(() {});
                },
                activeColor: const Color(0xFF3B82F6),
              ),

              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  // Will continue with widget methods in next part...

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          // Header with collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isFilterSectionCollapsed = !_isFilterSectionCollapsed;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Color(0xFF6B7280), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'FILTERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (_customCodeBreakdown.isNotEmpty)
                  Icon(
                    _isFilterSectionCollapsed ? Icons.expand_more : Icons.expand_less,
                    color: const Color(0xFF6B7280),
                  ),
              ],
            ),
          ),
          
          // Show active filters summary when collapsed
          if (_isFilterSectionCollapsed && (_enableDataCodeFilter || _enableDataSubCodeFilter || _enableCustomCodeFilter)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_enableDataCodeFilter && _selectedDataCodes.isNotEmpty)
                  _buildFilterChip('Data Code', _selectedDataCodes.length),
                if (_enableDataSubCodeFilter && _selectedDataSubCodes.isNotEmpty)
                  _buildFilterChip('Data Sub Code', _selectedDataSubCodes.length),
                if (_enableCustomCodeFilter && _selectedCustomCodes.isNotEmpty)
                  _buildFilterChip('Custom Code', _selectedCustomCodes.length),
                if (_enableDeclineReasonFilter && _selectedDeclineReasons.isNotEmpty)
                  _buildFilterChip('Decline Reason', _selectedDeclineReasons.length),
              ],
            ),
          ],

          // Expanded filter content
          if (!_isFilterSectionCollapsed) ...[
            const SizedBox(height: 16),

            // Data Code Filter (conditional)
            if (_enableDataCodeFilter) ...[
              _buildMultiSelectFilter(
                label: 'Data Code',
                options: _filteredDataCodes,
                selectedValues: _selectedDataCodes,
                searchController: _dataCodeSearchController,
                onChanged: (values) {
                  setState(() => _selectedDataCodes = values);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Data Sub Code Filter (conditional)
            if (_enableDataSubCodeFilter) ...[
              _buildMultiSelectFilter(
                label: 'Data Sub Code',
                options: _filteredDataSubCodes,
                selectedValues: _selectedDataSubCodes,
                searchController: _dataSubCodeSearchController,
                onChanged: (values) {
                  setState(() => _selectedDataSubCodes = values);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Custom Code Filter (conditional)
            if (_enableCustomCodeFilter) ...[
              _buildMultiSelectFilter(
                label: 'Custom Code',
                options: _filteredCustomCodes,
                selectedValues: _selectedCustomCodes,
                searchController: _customCodeSearchController,
                onChanged: (values) {
                  setState(() => _selectedCustomCodes = values);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Decline Reason Filter (conditional)
            if (_enableDeclineReasonFilter) ...[
              _buildMultiSelectFilter(
                label: 'Decline Reason',
                options: _filteredDeclineReasons,
                selectedValues: _selectedDeclineReasons,
                searchController: _declineReasonSearchController,
                onChanged: (values) {
                  setState(() => _selectedDeclineReasons = values);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Show message if no filters selected
            if (!_enableDataCodeFilter && !_enableDataSubCodeFilter && !_enableCustomCodeFilter && !_enableDeclineReasonFilter)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap the filter icon (${String.fromCharCode(0x2699)}) in the app bar to select filters',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Reallocation specific filters
            if (widget.mode == 'reallocate') ...[
              if (_enableDataCodeFilter || _enableDataSubCodeFilter || _enableCustomCodeFilter || _enableDeclineReasonFilter)
                const Divider(),
              const SizedBox(height: 16),

              // Lead Status Filter (Mandatory for Reallocation)
              const Text(
                'Lead Status (Required)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('CNR (includes CNR+Voicemail)', style: TextStyle(fontSize: 14)),
                      value: _includeCNR,
                      onChanged: (value) {
                        setState(() => _includeCNR = value ?? false);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF3B82F6),
                    ),
                    CheckboxListTile(
                      title: const Text('Denied', style: TextStyle(fontSize: 14)),
                      value: _includeDenied,
                      onChanged: (value) {
                        setState(() => _includeDenied = value ?? false);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF3B82F6),
                    ),
                  ],
                ),
              ),

              if (!_includeCNR && !_includeDenied)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Please select at least one lead status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFF59E0B),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Allocation Count Range
              const Text(
                'Allocation Count Range (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minAllocCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxAllocCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Employee Count Range
              const Text(
                'Employee Count Range (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minEmpCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxEmpCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadCounts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildMultiSelectFilter({
    required String label,
    required List<String> options,
    required Set<String> selectedValues,
    required TextEditingController searchController,
    required Function(Set<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (selectedValues.isNotEmpty)
              TextButton(
                onPressed: () {
                  onChanged({});
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Search box
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search $label...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      searchController.clear();
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: options.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedValues.contains(option);
                    
                    return InkWell(
                      onTap: () {
                        final newValues = Set<String>.from(selectedValues);
                        if (isSelected) {
                          newValues.remove(option);
                        } else {
                          newValues.add(option);
                        }
                        onChanged(newValues);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : null,
                          border: Border(
                            bottom: index < options.length - 1
                                ? const BorderSide(color: Color(0xFFF3F4F6))
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                final newValues = Set<String>.from(selectedValues);
                                if (value == true) {
                                  newValues.add(option);
                                } else {
                                  newValues.remove(option);
                                }
                                onChanged(newValues);
                              },
                              activeColor: const Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${selectedValues.length} selected',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountBreakdownSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF6B7280), size: 20),
              SizedBox(width: 8),
              Text(
                'AVAILABLE RECORDS (by Custom Code)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom code breakdown cards
          ..._customCodeBreakdown.map((item) {
            final customCode = item['custom_code'] ?? 'Unknown';
            final count = item['count'] ?? 0;
            final controller = _countControllers[customCode]!;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        customCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count available',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Select Count',
                            hintText: 'Max: $count',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          controller.text = count.toString();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Max', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Total selected
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL SELECTED',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$_totalSelected records',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Records',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '$_totalSelected',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _proceedToDistribution,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Next: Select Employees',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
