import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/holiday_service.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';

class HolidayListScreen extends StatefulWidget {
  const HolidayListScreen({super.key});

  @override
  State<HolidayListScreen> createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends State<HolidayListScreen> {
  bool _isLoading = true;
  List<Holiday> _allHolidays = [];
  late DateTime _selectedMonth;
  late final List<DateTime> _monthOptions;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);

    // Dynamic 14 months: Jan of current year → Jan of next year
    _monthOptions = [];
    final int currentYear = now.year;
    for (int i = 0; i < 14; i++) {
      final date = DateTime(currentYear, 1 + i);
      _monthOptions.add(date);
    }

    _loadHolidays();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadHolidays() async {
    setState(() => _isLoading = true);
    try {
      await HolidayService.syncHolidays();
      final allHolidays = await HolidayService.getAllHolidays();
      if (mounted) {
        setState(() {
          _allHolidays = allHolidays;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  Future<void> _showAddHolidayDialog() async {
    final nameController = TextEditingController();
    DateTime? selectedDate;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.celebration_rounded, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'New Holiday',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.85, // Wider popup
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Date Selection
                  _buildCompactLabel("DATE"),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2027),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : "${DateFormat('dd MMM yyyy').format(selectedDate!)} (${DateFormat('EEEE').format(selectedDate!)})",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selectedDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Holiday Name
                  _buildCompactLabel("TITLE"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'e.g. Diwali',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (nameController.text.isEmpty || selectedDate == null) {
                    _showSnackBar('Fill all details', isError: true);
                    return;
                  }

                  String? existingId;
                  String? existingName;
                  for (var h in _allHolidays) {
                    if (h.holidayDate.year == selectedDate!.year &&
                        h.holidayDate.month == selectedDate!.month &&
                        h.holidayDate.day == selectedDate!.day) {
                      existingId = h.id;
                      existingName = h.holidayName;
                      break;
                    }
                  }

                  if (existingId != null) {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: const Text('Update Holiday?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        content: Text('"$existingName" already exists. Update it?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Update')),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                  }

                  setDialogState(() => isSaving = true);
                  try {
                    String rawName = nameController.text.trim();
                    String formattedName = "";
                    
                    // Normalize "Week off" variations
                    String normalizedSearch = rawName.toLowerCase().replaceAll(' ', '');
                    if (normalizedSearch == 'weekoff') {
                      formattedName = 'Week off';
                    } else {
                      formattedName = rawName.isNotEmpty 
                          ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase()
                          : '';
                    }

                    final dateStr = DateTime.utc(selectedDate!.year, selectedDate!.month, selectedDate!.day, 12, 0, 0).toIso8601String();

                    if (existingId != null) {
                      await PB.pb.collection('holiday').update(existingId, body: {
                        'holiday_name': formattedName,
                        'active': true,
                        'holiday_date': dateStr,
                      });
                    } else {
                      await PB.pb.collection('holiday').create(body: {
                        'holiday_name': formattedName,
                        'holiday_date': dateStr,
                        'active': true,
                      });
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      _loadHolidays();
                      _showSnackBar(existingId != null ? 'Updated' : 'Added');
                    }
                  } catch (e) {
                    if (mounted) {
                      setDialogState(() => isSaving = false);
                      _showSnackBar('Error: $e', isError: true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
    );
  }

  Future<void> _toggleActive(Holiday holiday) async {
    final originalValue = holiday.active;
    final newValue = !originalValue;

    if (mounted) {
      setState(() {
        final index = _allHolidays.indexWhere((h) => h.id == holiday.id);
        if (index != -1) {
          _allHolidays[index] = Holiday(
            id: holiday.id,
            holidayName: holiday.holidayName,
            holidayDate: holiday.holidayDate,
            active: newValue,
          );
        }
      });
    }

    try {
      await PB.pb.collection('holiday').update(
        holiday.id,
        body: {'active': newValue},
      );
      await HolidayService.syncHolidays();
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _allHolidays.indexWhere((h) => h.id == holiday.id);
          if (index != -1) {
            _allHolidays[index] = Holiday(
              id: holiday.id,
              holidayName: holiday.holidayName,
              holidayDate: holiday.holidayDate,
              active: originalValue,
            );
          }
        });
        _showSnackBar('Failed to update: $e', isError: true);
      }
    }
  }

  List<Holiday> get _filteredHolidays {
    final bool isBHAccess = PB.pb.authStore.record?.data['bh_access'] == true;

    final list = _allHolidays.where((h) {
      final matchesMonth = h.holidayDate.year == _selectedMonth.year &&
          h.holidayDate.month == _selectedMonth.month;
      final matchesAccess = isBHAccess ? true : h.active;
      return matchesMonth && matchesAccess;
    }).toList();
    list.sort((a, b) => b.holidayDate.compareTo(a.holidayDate));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bool isBHAccess = PB.pb.authStore.record?.data['bh_access'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Holiday List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          if (isBHAccess)
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  size: 24, color: Color(0xFF1D4ED8)),
              onPressed: _showAddHolidayDialog,
              tooltip: 'Add Holiday',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DateTime>(
                value: _selectedMonth,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
                onChanged: (DateTime? newMonth) {
                  if (newMonth != null) {
                    setState(() => _selectedMonth = newMonth);
                  }
                },
                items: _monthOptions.map((DateTime month) {
                  return DropdownMenuItem<DateTime>(
                    value: month,
                    child: Text(
                      DateFormat('MMM yy').format(month),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadHolidays,
                    child: _filteredHolidays.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredHolidays.length,
                            itemBuilder: (context, index) {
                              return _buildHolidayCard(_filteredHolidays[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Column(
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No holidays in ${DateFormat('MMM yy').format(_selectedMonth)}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Change month from top right',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHolidayCard(Holiday holiday) {
    final date = holiday.holidayDate;
    final today = DateTime.now();
    final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final bool isBHAccess = PB.pb.authStore.record?.data['bh_access'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFF3B82F6)
                : isPast
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM').format(date).toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? Colors.white
                      : isPast
                          ? Colors.grey[400]
                          : const Color(0xFF3B82F6),
                ),
              ),
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? Colors.white
                      : isPast
                          ? Colors.grey[500]
                          : const Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          holiday.holidayName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isPast ? Colors.grey[400] : const Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            DateFormat('EEEE').format(date),
            style: TextStyle(
              fontSize: 12,
              color: isPast ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
          ),
        ),
        trailing: isBHAccess
            ? GestureDetector(
                onTap: () => _toggleActive(holiday),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: holiday.active
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        left: holiday.active ? 20 : 0,
                        right: holiday.active ? 0 : 20,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : isToday
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  )
                : isPast
                    ? null
                    : const Icon(
                        Icons.celebration_outlined,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
      ),
    );
  }
}
