import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import '../core/pb_api.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel? _profile;
  bool _isRefreshing = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = ProfileService.getProfile();
    if (profile == null) {
      PB.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() => _profile = profile);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    
    try {
      final profile = await ProfileService.refreshProfile();
      if (mounted) {
        setState(() {
          if (profile != null) _profile = profile;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  String _calculateTenure(String joiningDate) {
    if (joiningDate.isEmpty) return '';
    
    try {
      final joining = DateTime.parse(joiningDate);
      final now = DateTime.now();
      
      int years = now.year - joining.year;
      int months = now.month - joining.month;
      int days = now.day - joining.day;
      
      if (days < 0) {
        months--;
        days += DateTime(now.year, now.month, 0).day;
      }
      
      if (months < 0) {
        years--;
        months += 12;
      }
      
      List<String> parts = [];
      if (years > 0) parts.add('${years}y');
      if (months > 0) parts.add('${months}m');
      if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
      
      if (parts.isEmpty) return '0 days with company';
      return '${parts.join(' ')} with company';
    } catch (_) {
      return '';
    }
  }

  void _showFullImage() {
    if (_profile?.avatar.isEmpty ?? true) return;
    
    final record = PB.pb.authStore.record;
    if (record == null) return;
    
    final avatarUrl = PB.pb.files.getUrl(record, _profile!.avatar).toString();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.contain,
            httpHeaders: {
              'Authorization': PB.pb.authStore.token,
            },
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return;
      if (!mounted) return;
      
      final bytes = await image.readAsBytes();
      
      if (bytes.length > 5 * 1024 * 1024) {
        if (mounted) {
          _showError('Image too large. Please select an image under 5MB.');
        }
        return;
      }
      
      await _uploadImageBytes(bytes);
    } catch (e, stackTrace) {
      debugPrint('Error picking image: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showError('Failed to select image. Please try again.');
      }
    }
  }

  Future<void> _uploadImageBytes(List<int> bytes) async {
    setState(() => _isUploading = true);
    
    try {
      final updatedRecord = await PB.pb.collection('users').update(
        _profile!.id,
        files: [
          http.MultipartFile.fromBytes(
            'avatar',
            bytes,
            filename: 'avatar.jpg',
          ),
        ],
      );
      
      PB.pb.authStore.save(PB.pb.authStore.token, updatedRecord);
      
      if (mounted) {
        setState(() {
          _profile = ProfileModel.fromJson(updatedRecord.toJson());
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile photo updated successfully'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to upload image. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final record = PB.pb.authStore.record;
    final avatarUrl = (_profile!.avatar.isNotEmpty && record != null)
        ? PB.pb.files.getUrl(record, _profile!.avatar).toString()
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _showFullImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => const CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            child: Text(
                              _profile!.employeeName.isNotEmpty
                                  ? _profile!.employeeName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          child: Text(
                            _profile!.employeeName.isNotEmpty
                                ? _profile!.employeeName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                ),
              ),
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              if (!_isUploading)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _profile!.employeeName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _profile!.designation.isNotEmpty
                ? _profile!.designation
                : _profile!.role,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          if (_profile!.dateOfJoining.isNotEmpty) ...[ 
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.work_history_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _calculateTenure(_profile!.dateOfJoining),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, {IconData? icon, Color? iconColor}) {
    final color = iconColor ?? const Color(0xFF3B82F6);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
          if (icon != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                children: [
                  _buildHeader(),
                  _buildSection(
                    'PERSONAL INFORMATION',
                    [
                      _buildItem('Employee Code', _profile!.employeeCode,
                          icon: Icons.badge_outlined, iconColor: const Color(0xFF3B82F6)),
                      _buildItem('Email', _profile!.email,
                          icon: Icons.email_outlined, iconColor: const Color(0xFF10B981)),
                      _buildItem('Username', _profile!.username,
                          icon: Icons.person_outline, iconColor: const Color(0xFF8B5CF6)),
                      _buildItem('Date of Birth', _formatDate(_profile!.dateOfBirth),
                          icon: Icons.cake_outlined, iconColor: const Color(0xFFF59E0B)),
                    ],
                  ),
                  _buildSection(
                    'WORK INFORMATION',
                    [
                      _buildItem('Designation', _profile!.designation,
                          icon: Icons.work_outline, iconColor: const Color(0xFF6366F1)),
                      _buildItem('Department', _profile!.department,
                          icon: Icons.business_outlined, iconColor: const Color(0xFF14B8A6)),
                      _buildItem('Vertical', _profile!.vertical,
                          icon: Icons.category_outlined, iconColor: const Color(0xFFEC4899)),
                      _buildItem('Date of Joining', _formatDate(_profile!.dateOfJoining),
                          icon: Icons.calendar_today_outlined, iconColor: const Color(0xFF06B6D4)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
