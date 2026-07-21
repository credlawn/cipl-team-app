import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/attendance_service.dart';
import '../services/native_camera_service.dart';

class CheckInScreen extends StatefulWidget {
  final String? attendanceId;
  
  const CheckInScreen({super.key, this.attendanceId});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with WidgetsBindingObserver {
  String? _capturedImagePath;
  Map<String, dynamic>? _locationData;
  bool _isLoading = false;
  String? _error;
  DateTime? _pausedAt;

  bool get _isCheckOut => widget.attendanceId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    }
    
    if (state == AppLifecycleState.resumed && _pausedAt != null) {
      final pauseDuration = DateTime.now().difference(_pausedAt!);
      
      if (pauseDuration.inSeconds > 30) {
        setState(() {
          _capturedImagePath = null;
          _locationData = null;
          _error = 'Data cleared for security. Please recapture selfie and wait for location.';
        });
        _fetchLocation();
      }
    }
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final location = await AttendanceService.getFreshLocation();
      if (!mounted) return;
      
      setState(() {
        _locationData = location;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _captureSelfieFrontCamera() async {
    try {
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          _showError('Camera permission is required to take selfie');
          return;
        }
      }

      final imagePath = await NativeCameraService.captureFrontSelfie();

      if (imagePath != null) {
        setState(() {
          _capturedImagePath = imagePath;
        });
      }
    } catch (e) {
      _showError('Failed to capture selfie: ${e.toString()}');
    }
  }

  Future<void> _confirm() async {
    // Layer 5: UI Guard — verify local DB before proceeding (handles stale UI state)
    if (!_isCheckOut) {
      final existingRecord = await AttendanceService.getTodayAttendance();
      if (existingRecord != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already checked in today.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          Navigator.pop(context, false);
        }
        return;
      }
    }

    if (_capturedImagePath == null) {
      _showError('Please capture a selfie first');
      return;
    }

    if (_locationData == null) {
      _showError('Location not available. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isCheckOut) {
        await AttendanceService.checkOut(
          attendanceId: widget.attendanceId!,
          selfiePath: _capturedImagePath!,
          locationData: _locationData!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checked out successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await AttendanceService.checkIn(
          selfiePath: _capturedImagePath!,
          locationData: _locationData!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checked in successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isCheckOut ? 'Check Out' : 'Check In'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelfieSection(),
            const SizedBox(height: 20),
            _buildLocationSection(),
            if (_error != null) ...[
              const SizedBox(height: 20),
              _buildErrorSection(),
            ],
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfieSection() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SELFIE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_capturedImagePath == null)
            _buildCaptureButton()
          else
            _buildCapturedImage(),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return InkWell(
      onTap: _captureSelfieFrontCamera,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
              SizedBox(height: 12),
              Text(
                'Tap to capture selfie',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedImage() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_capturedImagePath!),
            height: 300,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _captureSelfieFrontCamera,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retake'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'LOCATION',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (_locationData != null)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: _fetchLocation,
                  color: const Color(0xFF6B7280),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading && _locationData == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_locationData != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationRow(
                  'Latitude',
                  _locationData!['latitude'].toStringAsFixed(9),
                  Icons.my_location_rounded,
                ),
                const SizedBox(height: 12),
                _buildLocationRow(
                  'Longitude',
                  _locationData!['longitude'].toStringAsFixed(9),
                  Icons.explore_rounded,
                ),
                const SizedBox(height: 12),
                _buildLocationRow(
                  'Accuracy',
                  '±${_locationData!['accuracy'].toStringAsFixed(1)}m',
                  Icons.gps_fixed_rounded,
                ),

              ],
            )
          else
            Center(
              child: TextButton.icon(
                onPressed: _fetchLocation,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canConfirm = _capturedImagePath != null && _locationData != null && !_isLoading;

    return ElevatedButton(
      onPressed: canConfirm ? _confirm : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isCheckOut ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        disabledBackgroundColor: const Color(0xFFE5E7EB),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _isCheckOut ? 'Confirm Check Out' : 'Confirm Check In',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
