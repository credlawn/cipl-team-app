import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/pb_api.dart';

Widget _buildStyledDropdown({
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  bool nullable = false,
  String hint = '— Skip —',
  Color color = const Color(0xFF3B82F6),
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        isExpanded: true,
        value: value,
        hint: Text(hint,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        items: [
          if (nullable) ...[
            DropdownMenuItem<String?>(
              value: null,
              child: Text(hint,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF))),
            ),
            DropdownMenuItem<String?>(
              value: FieldMappingScreen.manualValue,
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  const Text('Manual Entry',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            DropdownMenuItem<String?>(
              value: FieldMappingScreen.ignoreValue,
              child: Row(
                children: [
                  const Icon(Icons.close, size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  const Text('Ignore Field',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          ...items.toSet().map(
            (h) => DropdownMenuItem<String?>(
              value: h,
              child: Text(h,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF1F2937)),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}

class FieldMappingScreen extends StatefulWidget {
  final String jobId;
  final String collectionName;
  final String upsertKey;
  final String importMode;

  const FieldMappingScreen({
    super.key,
    required this.jobId,
    required this.collectionName,
    required this.upsertKey,
    required this.importMode,
  });

  static const String ignoreValue = "__IGNORE__";
  static const String manualValue = "__MANUAL__";

  @override
  State<FieldMappingScreen> createState() => _FieldMappingScreenState();
}

class _FieldMappingScreenState extends State<FieldMappingScreen>
    with SingleTickerProviderStateMixin {
  bool _mappedSectionExpanded = false;
  bool _ignoredSectionExpanded = false;
  final Map<String, TextEditingController> _manualControllers = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isImporting = false;
  String? _error;

  List<String> _dbFields = [];
  List<String> _excelHeaders = [];
  int _totalRecords = 0;

  // Key: DB field name, Value: selected Excel header (null = skip)
  Map<String, String?> _mapping = {};
  String? _existingMappingId;

  // Upsert key selection (can be changed on this screen)
  late String _selectedUpsertDbField;
  String? _selectedUpsertExcelCol;

  // Duplicate header handling
  List<Map<String, dynamic>> _duplicateHeaders = [];
  String _duplicateHeaderAction = 'use_first';

  // UI State


  @override
  void initState() {
    super.initState();
    _selectedUpsertDbField = widget.upsertKey;
    _loadEverything();
  }

  @override
  void dispose() {
    for (var controller in _manualControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    final oldManualFields = Set<String>.from(_manualControllers.keys);
    super.setState(fn);
    final newManualFields = Set<String>.from(_manualControllers.keys);
    // Dispose controllers for fields that are no longer in manual mode
    for (var field in oldManualFields) {
      if (!newManualFields.contains(field)) {
        _manualControllers[field]?.dispose();
        _manualControllers.remove(field);
      }
    }
  }

  Future<void> _loadEverything() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchExcelHeaders();
    await _fetchSavedMapping();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchExcelHeaders() async {
    try {
      final baseUrl = PB.pb.baseURL;
      final token = PB.pb.authStore.token;
      final url = '$baseUrl/api/import-headers/${widget.jobId}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final duplicateHeaders = data['duplicate_headers'] as List? ?? [];

        setState(() {
          _excelHeaders = List<String>.from(data['headers'] ?? []);
          _totalRecords = data['total_records'] ?? 0;
          _dbFields = List<String>.from(data['db_fields'] ?? []);
          _duplicateHeaders = List<Map<String, dynamic>>.from(duplicateHeaders);
          // Initialize all to null
          for (var field in _dbFields) {
            _mapping[field] = null;
          }
        });

        // Show duplicate header dialog if duplicates found
        if (duplicateHeaders.isNotEmpty && mounted) {
          await _showDuplicateHeaderDialog();
        }
      } else {
        setState(() => _error = 'Server error: ${response.body}');
      }
    } catch (e) {
      setState(() => _error = 'Could not connect to server: $e');
    }
  }

  Future<void> _fetchSavedMapping() async {
    try {
      final results = await PB.pb.collection('import_mappings').getList(
            filter: 'collection_name = "${widget.collectionName}"',
            perPage: 1,
          );

      if (results.items.isNotEmpty) {
        final savedRecord = results.items.first;
        _existingMappingId = savedRecord.id;
        final savedMapping =
            Map<String, dynamic>.from(savedRecord.data['mapping'] ?? {});

        setState(() {
          // Restore field mapping
          savedMapping.forEach((dbField, excelCol) {
            if (_dbFields.contains(dbField)) {
              final val = excelCol as String;
              if (_excelHeaders.contains(val) ||
                  val == FieldMappingScreen.ignoreValue) {
                _mapping[dbField] = val;
              } else if (val.startsWith("__STATIC__:")) {
                // Restore manual mode, but keep the value box empty for new input
                _mapping[dbField] = FieldMappingScreen.manualValue;
                _manualControllers[dbField] = TextEditingController(text: "");
              } else if (val == FieldMappingScreen.manualValue) {
                _mapping[dbField] = FieldMappingScreen.manualValue;
              }
            }
          });

          // Restore upsert DB field
          final savedUpsertKey = savedRecord.data['upsert_key']?.toString();
          if (savedUpsertKey != null && _dbFields.contains(savedUpsertKey)) {
            _selectedUpsertDbField = savedUpsertKey;
          }

          // Restore upsert Excel column (from dedicated field)
          final savedExcelUpsertKey =
              savedRecord.data['excel_upsert_key']?.toString();
          if (savedExcelUpsertKey != null &&
              savedExcelUpsertKey.isNotEmpty &&
              _excelHeaders.contains(savedExcelUpsertKey)) {
            _selectedUpsertExcelCol = savedExcelUpsertKey;
          }
        });
      }
    } catch (e) {
      debugPrint('No saved mapping: $e');
    }
  }

  List<String> get _systemFields {
    if (widget.collectionName == 'adobe_dump') {
      return [
        'arn_month',
        'decision_month',
        'employee_name',
        'employee_code',
        'mobile_no',
        'import_job_id',
        'import_date'
      ];
    }
    if (widget.collectionName == 'database') {
      return [
        'lead_status',
        'lead_status_date',
        'employee_name',
        'employee_code',
        'data_status',
        'no_reallocation',
        'import_job_id',
        'import_date'
      ];
    }
    return ['import_job_id', 'import_date'];
  }

  List<String> get _manualFields => _dbFields
      .where((f) =>
          _mapping[f] == FieldMappingScreen.manualValue &&
          f != _selectedUpsertDbField &&
          !_systemFields.contains(f))
      .toList();

  List<String> get _unmappedFields => _dbFields
      .where((f) =>
          _mapping[f] == null &&
          f != _selectedUpsertDbField &&
          !_systemFields.contains(f))
      .toList();

  List<String> get _mappedFields => _dbFields
      .where((f) =>
          _mapping[f] != null &&
          _mapping[f] != FieldMappingScreen.ignoreValue &&
          _mapping[f] != FieldMappingScreen.manualValue &&
          f != _selectedUpsertDbField &&
          !_systemFields.contains(f))
      .toList();

  List<String> get _ignoredFields => _dbFields
      .where((f) =>
          _mapping[f] == FieldMappingScreen.ignoreValue &&
          f != _selectedUpsertDbField &&
          !_systemFields.contains(f))
      .toList();

  Future<void> _saveMapping() async {
    setState(() => _isSaving = true);

    final cleanMapping = <String, String>{};
    _mapping.forEach((dbField, excelColOrMode) {
      if (excelColOrMode != null && excelColOrMode.isNotEmpty) {
        // Explicitly check for manual mode by string literal to be 100% safe
        if (excelColOrMode == "__MANUAL__") {
          final val = _manualControllers[dbField]?.text.trim() ?? "";
          cleanMapping[dbField] = "__STATIC__:$val";
        } else {
          cleanMapping[dbField] = excelColOrMode;
        }
      }
    });
    // Also save upsert excel col in mapping
    if (_selectedUpsertExcelCol != null) {
      cleanMapping[_selectedUpsertDbField] = _selectedUpsertExcelCol!;
    }

    try {
      final body = {
        'collection_name': widget.collectionName,
        'mapping': cleanMapping,
        'upsert_key': _selectedUpsertDbField,
        'excel_upsert_key': _selectedUpsertExcelCol ?? '',
        'created_by': PB.pb.authStore.record?.id ?? '',
      };

      if (_existingMappingId != null) {
        await PB.pb
            .collection('import_mappings')
            .update(_existingMappingId!, body: body);
      } else {
        final record =
            await PB.pb.collection('import_mappings').create(body: body);
        _existingMappingId = record.id;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mapping saved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
    setState(() => _isSaving = false);
  }

  Future<void> _showDuplicateHeaderDialog() async {
    final duplicateNames = _duplicateHeaders.map((d) => d['name'] as String).join(', ');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Duplicate Headers'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Duplicates found after trimming spaces:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(duplicateNames, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.orange)),
            ),
            const SizedBox(height: 16),
            const Text('You can fix in Excel and re-upload, or proceed using the first occurrence of each duplicate.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Fix in Excel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Use First'),
          ),
        ],
      ),
    );

    // User cancelled - go back to re-upload
    if (result == false && mounted) {
      await PB.pb.collection('import_jobs').delete(widget.jobId);
      if (mounted) {
        Navigator.pop(context, false);
      }
    } else if (result == true) {
      _duplicateHeaderAction = 'use_first';
    }
  }

  Future<void> _startImport() async {
    if (_selectedUpsertExcelCol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please map the Upsert Key column first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // --- Duplicate header confirmation ---
    if (_duplicateHeaders.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF3B82F6)),
              SizedBox(width: 10),
              Text('Confirm Import'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to process $_totalRecords records.',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Import Mode:'),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.importMode == 'create_update'
                      ? '🔄 Create & Update'
                      : widget.importMode == 'create_only'
                          ? '➕ Create Only'
                          : '✏️ Update Only',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action will modify your database and cannot be easily undone. Proceed?',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Yes, Start Import'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    await _saveMapping();

    // Prepare merged mapping for the worker (Mapping with actual manual values)
    final finalMappingForJob = <String, String>{};
    for (var entry in _mapping.entries) {
      final dbField = entry.key;
      final excelColOrMode = entry.value;

      if (excelColOrMode != null && excelColOrMode.isNotEmpty) {
        if (excelColOrMode == FieldMappingScreen.manualValue) {
          final val = _manualControllers[dbField]?.text.trim() ?? "";
          if (val.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter a manual value for $dbField'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          finalMappingForJob[dbField] = "__STATIC__:$val";
        } else {
          finalMappingForJob[dbField] = excelColOrMode;
        }
      }
    }

    setState(() => _isImporting = true);

    try {
      await PB.pb.collection('import_jobs').update(
        widget.jobId,
        body: {
          'status': 'pending',
          'import_mode': widget.importMode,
          'upsert_key': _selectedUpsertDbField,
          'mapping': finalMappingForJob,
          'duplicate_header_action': _duplicateHeaderAction,
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to start: $e')));
      }
    }
  }

  void _showSystemFieldsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF0EA5E9)),
            const SizedBox(width: 10),
            Text('${_systemFields.length} System Fields',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('These fields are automatically handled by the backend and do not need manual mapping.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (widget.collectionName == 'adobe_dump') ...[
                      _buildAutoMappedItem('arn_month', 'Month derived from ARN Date'),
                      _buildAutoMappedItem('decision_month', 'Month derived from Decision Date'),
                      _buildAutoMappedItem('employee_name', 'Enriched via Case Login'),
                      _buildAutoMappedItem('employee_code', 'Enriched via Case Login'),
                      _buildAutoMappedItem('mobile_no', 'Enriched via Case Login'),
                    ],
                    if (widget.collectionName == 'database') ...[
                      _buildAutoMappedItem('lead_status', 'Reset to Fresh/Empty'),
                      _buildAutoMappedItem('lead_status_date', 'Reset to Empty'),
                      _buildAutoMappedItem('employee_name', 'Clear for Reallocation'),
                      _buildAutoMappedItem('employee_code', 'Clear for Reallocation'),
                    ],
                    _buildAutoMappedItem('import_job_id', 'Tracking ID for this import'),
                    _buildAutoMappedItem('import_date', 'Effective date of this import (UTC)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isSaving || _isImporting,
      child: Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Map Fields',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          IconButton(
            onPressed: _showSystemFieldsInfo,
            icon: const Icon(Icons.info_outline, color: Color(0xFF64748B)),
            tooltip: 'System Handled Fields',
          ),
          if (!_isLoading && _error == null)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveMapping,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined, color: Color(0xFF3B82F6)),
              label: const Text('Save',
                  style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Reading Excel headers from server...',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280))),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                            onPressed: _loadEverything,
                            child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // ── Info Bar ──────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(widget.collectionName,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937))),
                              ),
                              Text(
                                  '$_totalRecords records · ${_excelHeaders.length} columns',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _statusPill('${_mappedFields.length}', 'Mapped',
                                    Colors.green),
                                const SizedBox(width: 8),
                                _statusPill('${_ignoredFields.length}', 'Ignored',
                                    Colors.red),
                                const SizedBox(width: 8),
                                _statusPill('${_unmappedFields.length}', 'Pending',
                                    Colors.orange),
                                const SizedBox(width: 8),
                                _statusPill('${_systemFields.length}', 'System',
                                    const Color(0xFF0EA5E9)),
                                if (_existingMappingId != null) ...[
                                  const SizedBox(width: 8),
                                  _statusPill('✓', 'Saved', Colors.blue),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // ── Upsert Key Section ─────────────────
                          _sectionHeader(
                              Icons.key, 'Upsert Key', const Color(0xFF7C3AED)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFF7C3AED), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF7C3AED)
                                        .withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                    'Select which DB field + Excel column forms the unique key for matching records.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280))),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // DB Field
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('DB FIELD',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF9CA3AF),
                                                  letterSpacing: 0.5)),
                                          const SizedBox(height: 6),
                                          _buildStyledDropdown(
                                            value: _selectedUpsertDbField,
                                            items: _dbFields,
                                            nullable: false,
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _selectedUpsertDbField = val;
                                                  _selectedUpsertExcelCol = null;
                                                });
                                              }
                                            },
                                            color: const Color(0xFF7C3AED),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 18),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Icon(Icons.link,
                                            color: Color(0xFF7C3AED), size: 20),
                                      ),
                                    ),
                                    // Excel Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('EXCEL COLUMN',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF9CA3AF),
                                                  letterSpacing: 0.5)),
                                          const SizedBox(height: 6),
                                          _buildStyledDropdown(
                                            value: _selectedUpsertExcelCol,
                                            items: _excelHeaders,
                                            nullable: true,
                                            hint: 'Select column',
                                            onChanged: (val) => setState(
                                                () =>
                                                    _selectedUpsertExcelCol =
                                                        val),
                                            color: const Color(0xFF7C3AED),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Manual Inputs Section (Prominent at Top) ──────────
                          if (_manualFields.isNotEmpty) ...[
                            _sectionHeader(Icons.edit_note_rounded,
                                'Manual Inputs Required', const Color(0xFF7C3AED)),
                            const SizedBox(height: 10),
                            ..._manualFields.map((field) => _mappingRow(field,
                                isHighlighted: true)), // Highlighting manual inputs
                            const SizedBox(height: 24),
                          ],

                          // ── Unmapped Fields ────────────────────
                          if (_unmappedFields.isNotEmpty) ...[
                            _sectionHeader(
                                Icons.warning_amber_rounded,
                                '${_unmappedFields.length} Unmapped Fields',
                                Colors.orange),
                            const SizedBox(height: 10),
                            ..._unmappedFields.map((dbField) =>
                                _mappingRow(dbField, isHighlighted: true)),
                          ],

                          const SizedBox(height: 24),

                          // ── Mapped Fields (Collapsible) ────────
                          if (_mappedFields.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _mappedSectionExpanded =
                                      !_mappedSectionExpanded),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check,
                                          color: Colors.green, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                          '${_mappedFields.length} Mapped Fields',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151))),
                                    ),
                                    Icon(
                                      _mappedSectionExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Expanded mapped fields
                          if (_mappedSectionExpanded && _mappedFields.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                children: _mappedFields
                                    .map((field) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          child: _mappingRow(field,
                                              isHighlighted: false),
                                        ))
                                    .toList(),
                              ),
                            ),

                          const SizedBox(height: 16),
                          if (_ignoredFields.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _ignoredSectionExpanded =
                                      !_ignoredSectionExpanded),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.red, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                          '${_ignoredFields.length} Ignored Fields',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151))),
                                    ),
                                    Icon(
                                      _ignoredSectionExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_ignoredSectionExpanded && _ignoredFields.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Column(
                                children: _ignoredFields
                                    .map((field) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          child: _mappingRow(field,
                                              isHighlighted: false),
                                        ))
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),

                    // ── Start Import Button ────────────────────
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, -4))
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isImporting ? null : _startImport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              disabledBackgroundColor:
                                  const Color(0xFFBFDBFE),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            icon: _isImporting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.cloud_upload,
                                    color: Colors.white),
                            label: Text(
                              _isImporting
                                  ? 'Starting...'
                                  : 'Start Import ($_totalRecords records)',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _mappingRow(String dbField, {required bool isHighlighted}) {
    final isManual = _mapping[dbField] == FieldMappingScreen.manualValue;
    if (isManual && !_manualControllers.containsKey(dbField)) {
      _manualControllers[dbField] = TextEditingController();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isManual
                  ? const Color(0xFF7C3AED)
                  : (isHighlighted
                      ? Colors.orange.withOpacity(0.4)
                      : const Color(0xFFE5E7EB)),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1))
            ],
          ),
          child: Row(
            children: [
              // DB field name
              Expanded(
                flex: 2,
                child: Text(dbField,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937))),
              ),
              const Icon(Icons.arrow_forward,
                  size: 14, color: Color(0xFFD1D5DB)),
              const SizedBox(width: 4),
              // Excel column dropdown
              Expanded(
                flex: 3,
                child: _buildStyledDropdown(
                  value: _mapping[dbField],
                  items: _excelHeaders,
                  nullable: true,
                  hint: '— Skip —',
                  onChanged: (val) => setState(() => _mapping[dbField] = val),
                  color: _mapping[dbField] == FieldMappingScreen.ignoreValue
                      ? Colors.red
                      : (_mapping[dbField] == FieldMappingScreen.manualValue
                          ? const Color(0xFF7C3AED)
                          : (isHighlighted
                              ? Colors.orange
                              : const Color(0xFF3B82F6))),
                ),
              ),
            ],
          ),
        ),
        if (isManual)
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 14, bottom: 12),
            child: TextField(
              controller: _manualControllers[dbField],
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F3FF),
                hintText: 'Enter manual value for $dbField...',
                hintStyle: TextStyle(color: const Color(0xFF7C3AED).withOpacity(0.5), fontSize: 12),
                prefixIcon: const Icon(Icons.edit, size: 14, color: Color(0xFF7C3AED)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }


  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.3)),
      ],
    );
  }

  Widget _statusPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$value $label',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  Widget _buildAutoMappedItem(String field, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0F2FE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('SYSTEM',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1))),
          ),
        ],
      ),
    );
  }
}
