import 'package:flutter/material.dart';
import 'dart:io';
import '../services/version_service.dart';
import '../services/apk_download_service.dart';

class UpdateDialog extends StatefulWidget {
  final AppVersionInfo versionInfo;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> with WidgetsBindingObserver {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  String? _downloadedApkPath;
  bool _isInstalling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInstalling) {
      // User returned from installer - likely cancelled
      setState(() {
        _isInstalling = false;
        if (_errorMessage == null) {
          _errorMessage = 'Installation cancelled. You can try again.';
        }
      });
    }
  }

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _downloadedApkPath = null;
    });

    try {
      final filePath = await ApkDownloadService.downloadApk(
        widget.versionInfo.downloadUrl,
        (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadedApkPath = filePath;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _downloadedApkPath = null;
        final errorStr = e.toString();
        if (errorStr.contains('INSTALL_PERMISSION_DENIED')) {
          _errorMessage = 'Please enable "Install unknown apps" permission in settings.';
        } else if (errorStr.contains('timeout')) {
          _errorMessage = 'Network timeout. Check connection and retry.';
        } else {
          _errorMessage = 'Download failed. Please try again.';
        }
      });
    }
  }

  Future<void> _installApk() async {
    if (_downloadedApkPath == null || _isInstalling) return;

    setState(() {
      _isInstalling = true;
      _errorMessage = null;
    });

    try {
      await ApkDownloadService.installApk(_downloadedApkPath!);
      // If install succeeds, app will be killed. No cleanup needed here.
    } catch (e) {
      // Intent failed to launch (rare)
      if (mounted) {
        setState(() {
          _isInstalling = false;
          _errorMessage = 'Failed to launch installer. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canInstall = _downloadedApkPath != null && !_isInstalling;
    final showProgress = _isDownloading || _isInstalling;
    final progressValue = _isInstalling ? 1.0 : _downloadProgress;

    return WillPopScope(
      onWillPop: () async => !_isInstalling,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_alt,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version ${widget.versionInfo.versionNo}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What's New",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.versionInfo.changelog.isNotEmpty
                          ? widget.versionInfo.changelog
                          : 'Bug fixes and performance improvements',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: showProgress
                    ? Column(
                        children: [
                          LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isInstalling
                                ? 'Installing...'
                                : '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: canInstall ? _installApk : _handleDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667EEA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _downloadedApkPath != null ? Icons.system_update_alt : Icons.download,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _downloadedApkPath != null ? 'Install Now' : 'Download Now',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
