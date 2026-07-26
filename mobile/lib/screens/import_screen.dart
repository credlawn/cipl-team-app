import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:http/http.dart' as http;
import '../core/pb_api.dart';
import 'field_mapping_screen.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String _selectedCollection = 'adobe_dump';
  String _upsertKey = 'arn_no';
  DateTime? _effectiveDate;
  String _importMode = 'create_update';
  fp.PlatformFile? _selectedFile;

  bool _isProcessing = false;
  String _statusMessage = '';

  String? _jobId;
  int _totalRecords = 0;
  int _createdRecords = 0;
  int _updatedRecords = 0;
  int _skippedRecords = 0;
  int _failedRecords = 0;
  String _jobStatus = '';
  List<Map<String, String>> _collectionOptions = [];
  bool _isLoadingCollections = true;

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  Future<void> _fetchCollections() async {
    try {
      final records = await PB.pb.collection('import_mappings').getFullList(
        sort: 'collection_name',
      ).timeout(const Duration(seconds: 10));

      final List<Map<String, String>> options = records.map((r) {
        final val = r.getStringValue('collection_name');
        final key = r.getStringValue('upsert_key');
        String name = val.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');

        return {'name': name, 'value': val, 'key': key};
      }).toList();

      setState(() {
        _collectionOptions = options;
        if (options.isNotEmpty) {
          _selectedCollection = options.first['value']!;
          _upsertKey = options.first['key']!;
        }
        _isLoadingCollections = false;
      });
    } catch (e) {
      debugPrint('Error fetching collections: $e');
      if (mounted) {
        setState(() => _isLoadingCollections = false);
        String errorMessage = 'Failed to load collections';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Connection timeout';
        }
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _fetchCollections,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _jobId = null;
        _createdRecords = 0;
        _updatedRecords = 0;
        _skippedRecords = 0;
        _failedRecords = 0;
        _jobStatus = '';
        _statusMessage = '';
      });
    }
  }

  Future<void> _uploadAndGoToMapping() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Uploading...';
    });

    try {
      final record = await PB.pb.collection('import_jobs').create(
        body: {
          'target_collection': _selectedCollection,
          'upsert_key': _upsertKey,
          'import_mode': _importMode,
          'status': 'needs_mapping',
          'import_date': _effectiveDate == null
              ? null
              : DateTime.utc(_effectiveDate!.year, _effectiveDate!.month,
                      _effectiveDate!.day, 12, 0, 0)
                  .toIso8601String(),
          'total_records': 0,
          'processed_records': 0,
        },
        files: [
          http.MultipartFile.fromBytes(
            'file',
            Uint8List.fromList(_selectedFile!.bytes!),
            filename: _selectedFile!.name,
          ),
        ],
      );

      final jobId = record.id;
      setState(() => _isProcessing = false);

      if (!mounted) return;

      final importStarted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => FieldMappingScreen(
            jobId: jobId,
            collectionName: _selectedCollection,
            upsertKey: _upsertKey,
            importMode: _importMode,
          ),
        ),
      );

      if (importStarted == true) {
        setState(() {
          _jobId = jobId;
          _isProcessing = true;
          _statusMessage = 'Reading Excel...';
        });
        _listenToProgress();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _listenToProgress() {
    if (_jobId == null) return;

    PB.pb.collection('import_jobs').subscribe(_jobId!, (e) {
      if (mounted && e.action == 'update') {
        final total = e.record?.getIntValue('total_records') ?? 0;
        final status = e.record?.getStringValue('status') ?? '';

        setState(() {
          _totalRecords = total;
          _createdRecords = e.record?.getIntValue('created_records') ?? 0;
          _updatedRecords = e.record?.getIntValue('updated_records') ?? 0;
          _skippedRecords = e.record?.getIntValue('skipped_records') ?? 0;
          _failedRecords = e.record?.getIntValue('failed_records') ?? 0;
          _jobStatus = status;

          if (status == 'completed' || status == 'failed') {
            _isProcessing = false;
            if (status == 'completed') {
              _statusMessage = 'Import completed successfully';
            } else {
              final error = e.record?.getStringValue('error') ?? '';
              _statusMessage =
                  error.isNotEmpty ? 'Import failed: $error' : 'Import failed';
            }
            PB.pb.collection('import_jobs').unsubscribe(_jobId!);
          } else {
            if (status == 'reading') {
              _statusMessage = 'Reading Excel...';
            } else if (status == 'validating') {
              _statusMessage = 'Validating Dates...';
            } else if (status == 'processing') {
              _statusMessage = 'Importing...';
            }
          }
        });
      }
    });

    PB.pb.collection('import_jobs').getOne(_jobId!).then((record) {
      if (!mounted) return;
      final status = record.getStringValue('status');
      setState(() {
        _totalRecords = record.getIntValue('total_records');
        _createdRecords = record.getIntValue('created_records');
        _updatedRecords = record.getIntValue('updated_records');
        _skippedRecords = record.getIntValue('skipped_records');
        _failedRecords = record.getIntValue('failed_records');
        _jobStatus = status;

        if (status == 'completed' || status == 'failed') {
          _isProcessing = false;
          if (status == 'completed') {
            _statusMessage = 'Import completed successfully';
          } else {
            final error = record.getStringValue('error');
            _statusMessage =
                error.isNotEmpty ? 'Import failed: $error' : 'Import failed';
          }
          PB.pb.collection('import_jobs').unsubscribe(_jobId!);
        } else if (status == 'reading') {
          _statusMessage = 'Reading Excel...';
        } else if (status == 'validating') {
          _statusMessage = 'Validating Dates...';
        } else if (status == 'processing') {
          _statusMessage = 'Importing...';
        }
      });
    }).catchError((_) {});
  }

  @override
  void dispose() {
    if (_jobId != null) {
      PB.pb.collection('import_jobs').unsubscribe(_jobId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Data Import',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Compact Step Indicator ──
            _buildStepIndicator(),
            const SizedBox(height: 12),

            // ── Main Card ──
            Flexible(
              fit: FlexFit.tight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 2))
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Config Row ──
                      _buildConfigRow(),
                      const SizedBox(height: 16),

                      // ── File Section ──
                      _buildFileSection(),
                      const SizedBox(height: 16),

                      // ── Date + Action Row ──
                      if (_selectedFile != null && _jobId == null) ...[
                        _buildDateAndActionRow(),
                      ],

                      // ── Processing / Result ──
                      if (_jobId != null) ...[
                        _buildProcessingCard(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final isFileSelected = _selectedFile != null;
    final isMappingDone = _jobId != null;
    final isCompleted = _jobStatus == 'completed';
    final isFailed = _jobStatus == 'failed';

    return Row(
      children: [
        _stepDot(1, isFileSelected || isMappingDone || isCompleted,
            isFileSelected || isMappingDone || isCompleted),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
        _stepDot(2, isMappingDone || isCompleted, isFileSelected),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
        _stepDot(3, isCompleted, isFailed ? false : isMappingDone),
      ],
    );
  }

  Widget _stepDot(int num, bool active, bool current) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: current
            ? const Color(0xFF2563EB)
            : active
                ? const Color(0xFF10B981)
                : Colors.transparent,
        border: Border.all(
          color: current
              ? const Color(0xFF2563EB)
              : active
                  ? const Color(0xFF10B981)
                  : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          '$num',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: current || active ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collection
        const Text('Collection',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        _isLoadingCollections
            ? _loadingBox()
            : _buildCollectionCards(),
        const SizedBox(height: 12),

        // Mode
        const Text('Mode',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        _buildDropdown(
          value: _importMode,
          items: const [
            DropdownMenuItem(
                value: 'create_update',
                child: Text('Create & Update', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'create_only',
                child: Text('Create Only', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'update_only',
                child: Text('Update Only', style: TextStyle(fontSize: 12))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _importMode = val);
          },
        ),
      ],
    );
  }

  Widget _buildFileSection() {
    if (_selectedFile == null) {
      return InkWell(
        onTap: _isProcessing ? null : _pickFile,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFF93C5FD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text('Select Excel File',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB))),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_chart, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedFile!.name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${(_selectedFile!.size / 1024).toStringAsFixed(0)} KB',
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          if (!_isProcessing)
            GestureDetector(
              onTap: () => setState(() => _selectedFile = null),
              child: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  Widget _buildDateAndActionRow() {
    return Row(
      children: [
        const Text('Date:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => _effectiveDate = date);
            }
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _effectiveDate == null
                      ? 'Select Date'
                      : '${_effectiveDate!.day}/${_effectiveDate!.month}/${_effectiveDate!.year}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _effectiveDate == null
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.calendar_today,
                    size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: (_isProcessing ||
                    _selectedFile == null ||
                    _effectiveDate == null)
                ? null
                : _uploadAndGoToMapping,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              disabledBackgroundColor: const Color(0xFF93C5FD),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Continue',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingCard() {
    final isCompleted = _jobStatus == 'completed';
    final isFailed = _jobStatus == 'failed';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFF0FDF4)
            : isFailed
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFBBF7D0)
              : isFailed
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981))
              else if (isFailed)
                const Icon(Icons.error, size: 18, color: Color(0xFFEF4444))
              else
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(width: 8),
              Text(
                isCompleted
                    ? 'Import completed'
                    : isFailed
                        ? 'Import failed'
                        : _statusMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : isFailed
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (!isCompleted && !isFailed)
                Text('$_totalRecords records',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 12),
            _buildCompactStats(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _jobId = null;
                    _jobStatus = '';
                    _statusMessage = '';
                    _effectiveDate = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Import Another',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
          if (isFailed) ...[
            const SizedBox(height: 4),
            Text(_statusMessage,
                style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactStats() {
    return Row(
      children: [
        _statItem('New', _createdRecords, const Color(0xFF2563EB)),
        _statDivider(),
        _statItem('Updated', _updatedRecords, const Color(0xFF8B5CF6)),
        _statDivider(),
        _statItem('Skipped', _skippedRecords, const Color(0xFF64748B)),
        _statDivider(),
        _statItem('Failed', _failedRecords, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _statItem(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 28, color: const Color(0xFFE2E8F0));
  }

  Widget _buildDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 16, color: Color(0xFF64748B)),
          items: items,
          onChanged: _isProcessing ? null : onChanged,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCards() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _collectionOptions.length,
      itemBuilder: (context, index) {
        final option = _collectionOptions[index];
        final value = option['value']!;
        final name = option['name']!;
        final keyField = option['key']!;
        final isSelected = _selectedCollection == value;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCollection = value;
              _upsertKey = keyField;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCollectionIcon(value),
                        size: 16,
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SELECTED',
                            style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Key: $keyField',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCollectionIcon(String collection) {
    if (collection.contains('adobe')) {
      return Icons.photo_library;
    } else if (collection.contains('database') || collection.contains('db')) {
      return Icons.storage;
    } else if (collection.contains('lead')) {
      return Icons.people;
    } else if (collection.contains('call')) {
      return Icons.phone;
    }
    return Icons.upload_file;
  }

  Widget _loadingBox() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5)),
          SizedBox(width: 8),
          Text('Loading...',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}