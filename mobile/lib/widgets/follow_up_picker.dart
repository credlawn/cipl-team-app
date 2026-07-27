import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FollowUpPicker extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(DateTime) onDateTimeSelected;

  const FollowUpPicker({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onDateTimeSelected,
  });

  @override
  State<FollowUpPicker> createState() => _FollowUpPickerState();
}

class _FollowUpPickerState extends State<FollowUpPicker> {
  late DateTime selectedDate;
  late int selectedHour;
  late int selectedMinute;
  late String selectedAmPm;

  final ScrollController _dateController = FixedExtentScrollController();
  final ScrollController _hourController = FixedExtentScrollController();
  final ScrollController _minuteController = FixedExtentScrollController();
  final ScrollController _amPmController = FixedExtentScrollController();

  final List<DateTime> _dates = [];
  final List<int> _hours = List.generate(12, (index) => index + 1);
  final List<int> _minutes = List.generate(12, (index) => index * 5);
  final List<String> _amPm = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _generateDates();
    _initializeSelection();
  }

  void _generateDates() {
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      _dates.add(now.add(Duration(days: i)));
    }
  }

  void _initializeSelection() {
    final now = DateTime.now();
    DateTime initial = widget.initialDate ?? now.add(const Duration(days: 1)); // Default tomorrow
    
    // If initial date is before today (e.g. from previous selection), reset to today
    if (initial.isBefore(DateTime(now.year, now.month, now.day))) {
      initial = now;
    }

    selectedDate = initial;
    
    int hour = widget.initialTime?.hour ?? 10; // Default 10 AM
    int minute = widget.initialTime?.minute ?? 0;

    // Round minute to nearest 5
    minute = (minute / 5).round() * 5;
    if (minute >= 60) {
      minute = 0;
      hour++;
    }

    selectedAmPm = hour >= 12 ? 'PM' : 'AM';
    selectedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    selectedMinute = minute;

    // Scroll to initial positions after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToPositions();
    });
  }

  void _scrollToPositions() {
    if (!_dateController.hasClients) return;

    // Find date index
    int dateIndex = _dates.indexWhere((d) => 
      d.year == selectedDate.year && 
      d.month == selectedDate.month && 
      d.day == selectedDate.day
    );
    if (dateIndex == -1) dateIndex = 0;

    // Find time indices
    int hourIndex = _hours.indexOf(selectedHour);
    int minuteIndex = _minutes.indexOf(selectedMinute);
    int amPmIndex = _amPm.indexOf(selectedAmPm);

    ( _dateController as FixedExtentScrollController).jumpToItem(dateIndex);
    ( _hourController as FixedExtentScrollController).jumpToItem(hourIndex);
    ( _minuteController as FixedExtentScrollController).jumpToItem(minuteIndex);
    ( _amPmController as FixedExtentScrollController).jumpToItem(amPmIndex);
  }

  void _applyPreset(String type) {
    final now = DateTime.now();
    DateTime newDate;
    int newHour;
    String newAmPm;

    switch (type) {
      case 'Tomorrow Morning':
        newDate = now.add(const Duration(days: 1));
        newHour = 10;
        newAmPm = 'AM';
        break;
      case 'Tomorrow Evening':
        newDate = now.add(const Duration(days: 1));
        newHour = 4;
        newAmPm = 'PM';
        break;
      case 'After 2 Days':
        newDate = now.add(const Duration(days: 2));
        newHour = 10;
        newAmPm = 'AM';
        break;
      case 'Next Week':
        // Find next Monday
        int daysUntilMonday = DateTime.monday - now.weekday;
        if (daysUntilMonday <= 0) daysUntilMonday += 7;
        newDate = now.add(Duration(days: daysUntilMonday));
        newHour = 10;
        newAmPm = 'AM';
        break;
      default:
        return;
    }

    setState(() {
      selectedDate = newDate;
      selectedHour = newHour; // 10 or 4
      selectedMinute = 0;
      selectedAmPm = newAmPm;
    });

    _scrollToPositions();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B82F6);
    
    return Container(
      height: 500,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Follow-up',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip('Tomorrow Morning', Icons.wb_sunny_outlined),
                const SizedBox(width: 8),
                _buildPresetChip('Tomorrow Evening', Icons.nights_stay_outlined),
                const SizedBox(width: 8),
                _buildPresetChip('After 2 Days', Icons.calendar_today_outlined),
                const SizedBox(width: 8),
                _buildPresetChip('Next Week', Icons.next_week_outlined),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Wheel Pickers
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection Highlight
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                Row(
                  children: [
                    // Date Wheel (Larger)
                    Expanded(
                      flex: 4,
                      child: _buildWheel(
                        controller: _dateController,
                        itemCount: _dates.length,
                        onChanged: (index) {
                          setState(() => selectedDate = _dates[index]);
                        },
                        itemBuilder: (index) {
                          final date = _dates[index];
                          String label;
                          final now = DateTime.now();
                          
                          if (date.year == now.year && date.month == now.month && date.day == now.day) {
                            label = 'Today';
                          } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
                            label = 'Tomorrow';
                          } else {
                            label = DateFormat('EEE, d MMM').format(date);
                          }
                          
                          return Center(
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Hour Wheel
                    Expanded(
                      flex: 2,
                      child: _buildWheel(
                        controller: _hourController,
                        itemCount: _hours.length,
                        onChanged: (index) {
                          setState(() => selectedHour = _hours[index]);
                        },
                        itemBuilder: (index) => Center(
                          child: Text(
                            _hours[index].toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    
                    const Text(':', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    
                    // Minute Wheel
                    Expanded(
                      flex: 2,
                      child: _buildWheel(
                        controller: _minuteController,
                        itemCount: _minutes.length,
                        onChanged: (index) {
                          setState(() => selectedMinute = _minutes[index]);
                        },
                        itemBuilder: (index) => Center(
                          child: Text(
                            _minutes[index].toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    
                    // AM/PM Wheel
                    Expanded(
                      flex: 2,
                      child: _buildWheel(
                        controller: _amPmController,
                        itemCount: _amPm.length,
                        onChanged: (index) {
                          setState(() => selectedAmPm = _amPm[index]);
                        },
                        itemBuilder: (index) => Center(
                          child: Text(
                            _amPm[index],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Combine date and time
                    int hour24 = selectedHour;
                    if (selectedAmPm == 'PM' && hour24 != 12) hour24 += 12;
                    if (selectedAmPm == 'AM' && hour24 == 12) hour24 = 0;
                    
                    final finalDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      hour24,
                      selectedMinute,
                    );
                    
                    widget.onDateTimeSelected(finalDateTime);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Set Follow-up',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF3B82F6),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _applyPreset(label),
    );
  }

  Widget _buildWheel({
    required ScrollController controller,
    required int itemCount,
    required Function(int) onChanged,
    required Widget Function(int) itemBuilder,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) => itemBuilder(index),
      ),
    );
  }
}
