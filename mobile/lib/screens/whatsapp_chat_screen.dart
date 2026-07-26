import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:intl/intl.dart';
import '../core/pb_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class WhatsAppChatScreen extends StatefulWidget {
  final RecordModel conversation;

  const WhatsAppChatScreen({super.key, required this.conversation});

  @override
  State<WhatsAppChatScreen> createState() => _WhatsAppChatScreenState();
}

class _WhatsAppChatScreenState extends State<WhatsAppChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  bool _isSending = false;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isPaginationLoading = false;
  List<RecordModel> _messages = [];
  Map<String, String> _agentNames = {};
  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageId;
  RecordModel? _replyingToMessage;
  
  Timer? _windowTimer;
  Duration? _windowRemainingTime;
  bool _isWindowExpired = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _windowTimer?.cancel();
    // Unsubscribe from real-time updates to prevent leaks
    PB.pb.collection('whatsapp_messages').unsubscribe('*');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _start24HourTimer() async {
    _windowTimer?.cancel();

    RecordModel? lastIncoming;
    for (var m in _messages) {
      if (m.getStringValue('direction') == 'incoming') {
        lastIncoming = m;
        break;
      }
    }

    if (lastIncoming == null) {
      try {
        final result = await PB.pb.collection('whatsapp_messages').getList(
              page: 1,
              perPage: 1,
              filter: 'conversation = "${widget.conversation.id}" && direction = "incoming"',
              sort: '-timestamp',
            );
        if (result.items.isNotEmpty) {
          lastIncoming = result.items.first;
        }
      } catch (e) {
        // Fallback silently if API fails
      }
    }

    if (lastIncoming == null) {
      setState(() {
        _isWindowExpired = false;
        _windowRemainingTime = null;
      });
      return;
    }

    final lastMessageTime = DateTime.parse(lastIncoming.getStringValue('timestamp')).toLocal();
    final expiryTime = lastMessageTime.add(const Duration(hours: 24));

    void updateTimer() {
      final diff = expiryTime.difference(DateTime.now());
      if (diff.isNegative) {
        _windowTimer?.cancel();
        setState(() {
          _windowRemainingTime = Duration.zero;
          _isWindowExpired = true;
        });
      } else {
        setState(() {
          _windowRemainingTime = diff;
          _isWindowExpired = false;
        });
      }
    }

    updateTimer();

    if (_isWindowExpired) return;

    _windowTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTimer();
    });
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "";
    if (d == Duration.zero) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _fetchMessages() async {
    try {
      final result = await PB.pb.collection('whatsapp_messages').getList(
            page: 1,
            perPage: 20,
            filter: 'conversation = "${widget.conversation.id}"',
            sort: '-timestamp',
          );

      final fetchedMessages = result.items; // Latest first

      // Extract unique sender IDs to load agent names
      final senderIds = fetchedMessages
          .map((r) => r.getStringValue('sender'))
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (senderIds.isNotEmpty) {
        final users = await PB.pb.collection('users').getFullList(
              filter: senderIds.map((id) => 'id = "$id"').join(' || '),
            );
        for (var user in users) {
          final empName = user.getStringValue('employee_name');
          _agentNames[user.id] = empName.isNotEmpty ? empName : user.getStringValue('name');
        }
      }

      if (mounted) {
        setState(() {
          _messages = fetchedMessages;
          _currentPage = 1;
          _hasMore = result.totalItems > _messages.length;
          _isLoading = false;
        });
        _start24HourTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isPaginationLoading || !_hasMore) return;

    setState(() {
      _isPaginationLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await PB.pb.collection('whatsapp_messages').getList(
            page: nextPage,
            perPage: 20,
            filter: 'conversation = "${widget.conversation.id}"',
            sort: '-timestamp',
          );

      final newMessages = result.items; // Sorted latest first

      // Extract unique sender IDs to load agent names for the new messages
      final senderIds = newMessages
          .map((r) => r.getStringValue('sender'))
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (senderIds.isNotEmpty) {
        final users = await PB.pb.collection('users').getFullList(
              filter: senderIds.map((id) => 'id = "$id"').join(' || '),
            );
        for (var user in users) {
          final empName = user.getStringValue('employee_name');
          _agentNames[user.id] = empName.isNotEmpty ? empName : user.getStringValue('name');
        }
      }

      if (mounted) {
        setState(() {
          _messages.addAll(newMessages); // Append older messages to end
          _currentPage = nextPage;
          _hasMore = result.totalItems > _messages.length;
          _isPaginationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPaginationLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more messages: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _subscribeToMessages() {
    PB.pb.collection('whatsapp_messages').subscribe('*', (e) {
      if (!mounted) return;

      final msgConvId = e.record?.getStringValue('conversation');
      if (msgConvId != widget.conversation.id) return;

      if (e.action == 'create' && e.record != null) {
        setState(() {
          if (!_messages.any((m) => m.id == e.record!.id)) {
            _messages.insert(0, e.record!); // Insert at index 0 (bottom)
          }
        });
        _start24HourTimer();
        _scrollToBottom();
      } else if (e.action == 'update' && e.record != null) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == e.record!.id);
          if (index != -1) {
            _messages[index] = e.record!;
          }
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final offset = _scrollController.offset;
        if (offset > 0.0) {
          _scrollController.animateTo(
            0.0, // In reversed list, 0.0 is the bottom (latest messages)
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUserId = PB.pb.authStore.model?.id;
    if (currentUserId == null) return;

    final parentMsgId = _replyingToMessage?.getStringValue('message_id');

    setState(() {
      _isSending = true;
    });

    try {
      await PB.pb.collection('whatsapp_messages').create(body: {
        'conversation': widget.conversation.id,
        'direction': 'outgoing',
        'body': text,
        'type': 'text',
        'status': 'pending',
        'sender': currentUserId,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        if (parentMsgId != null && parentMsgId.isNotEmpty) 'reply_to_id': parentMsgId,
      });
      _messageController.clear();
      setState(() {
        _replyingToMessage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _detectMessageType(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', '3gp'].contains(ext)) {
      return 'video';
    } else if (['mp3', 'ogg', 'wav', 'aac', 'm4a', 'amr'].contains(ext)) {
      return 'audio';
    } else {
      return 'document';
    }
  }

  Future<void> _pickAndSendFile(FileType type) async {
    if (_isSending) return;
    try {
      final result = await FilePicker.pickFiles(type: type);
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final currentUserId = PB.pb.authStore.model?.id;
      if (currentUserId == null) return;

      final ext = file.extension ?? '';
      final msgType = _detectMessageType(ext);

      final parentMsgId = _replyingToMessage?.getStringValue('message_id');
      final caption = _messageController.text.trim();

      setState(() {
        _isSending = true;
      });

      http.MultipartFile multipartFile;
      if (file.bytes != null) {
        multipartFile = http.MultipartFile.fromBytes(
          'media_file',
          file.bytes!,
          filename: file.name,
        );
      } else if (file.path != null) {
        multipartFile = await http.MultipartFile.fromPath(
          'media_file',
          file.path!,
          filename: file.name,
        );
      } else {
        throw 'No file data available';
      }

      await PB.pb.collection('whatsapp_messages').create(
        body: {
          'conversation': widget.conversation.id,
          'direction': 'outgoing',
          'type': msgType,
          'status': 'pending',
          'sender': currentUserId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'body': caption,
          if (parentMsgId != null && parentMsgId.isNotEmpty) 'reply_to_id': parentMsgId,
        },
        files: [multipartFile],
      );

      _messageController.clear();
      setState(() {
        _replyingToMessage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload file: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Attachment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image_rounded,
                    color: Colors.purple,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendFile(FileType.image);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.video_collection_rounded,
                    color: Colors.pink,
                    label: 'Video',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendFile(FileType.video);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.audiotrack_rounded,
                    color: Colors.orange,
                    label: 'Audio',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendFile(FileType.audio);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file_rounded,
                    color: Colors.blue,
                    label: 'Document',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendFile(FileType.any);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(RecordModel msg) {
    final mediaFile = msg.getStringValue('media_file');
    if (mediaFile.isEmpty) return const SizedBox.shrink();

    final type = msg.getStringValue('type');
    final body = msg.getStringValue('body');
    
    final fileUrl = PB.pb.files.getURL(msg, mediaFile).toString();

    Widget mediaWidget;
    
    switch (type) {
      case 'image':
        mediaWidget = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenImageViewer(imageUrl: fileUrl),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: fileUrl,
              placeholder: (context, url) => Container(
                width: 200,
                height: 200,
                color: Colors.black.withOpacity(0.05),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF128C7E)),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 200,
                color: Colors.black.withOpacity(0.05),
                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
              fit: BoxFit.cover,
              width: 200,
              height: 200,
            ),
          ),
        );
        break;
        
      case 'video':
        mediaWidget = GestureDetector(
          onTap: () => _openMedia(fileUrl),
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.video_collection_rounded, size: 48, color: Colors.grey),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'VIDEO',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
        
      case 'audio':
      case 'voice':
        mediaWidget = Container(
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type == 'voice' ? Icons.mic_rounded : Icons.audiotrack_rounded,
                color: const Color(0xFF128C7E),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == 'voice' ? 'Voice Message' : 'Audio File',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Text(
                      'Audio',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF128C7E), size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _openMedia(fileUrl),
              ),
            ],
          ),
        );
        break;
        
      case 'document':
      default:
        mediaWidget = GestureDetector(
          onTap: () => _openMedia(fileUrl),
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_rounded, color: Colors.redAccent, size: 36),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mediaFile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Document',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.download_for_offline_rounded, color: Color(0xFF128C7E), size: 24),
              ],
            ),
          ),
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mediaWidget,
        if (body.isNotEmpty && body != mediaFile) ...[
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openMedia(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _highlightMessage(String id) {
    setState(() {
      _highlightedMessageId = id;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _highlightedMessageId == id) {
        setState(() {
          _highlightedMessageId = null;
        });
      }
    });
  }

  Widget _buildStatusTicks(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey);
      case 'failed':
        return const Icon(Icons.error_outline_rounded, size: 12, color: Color(0xFFEF4444));
      case 'sent':
        return const Icon(Icons.check_rounded, size: 14, color: Colors.grey);
      case 'delivered':
        return const Icon(Icons.done_all_rounded, size: 14, color: Colors.grey);
      case 'read':
        return const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF3B82F6)); // Blue ticks
      default:
        return const Icon(Icons.check_rounded, size: 14, color: Colors.grey);
    }
  }

  String _formatMsgTime(String? utcString) {
    if (utcString == null || utcString.isEmpty) return '';
    try {
      final localDateTime = DateTime.parse(utcString).toLocal();
      return DateFormat('hh:mm a').format(localDateTime);
    } catch (_) {
      return '';
    }
  }

  Widget _buildReplyPreview(RecordModel repliedMsg, String customerName) {
    final isIncoming = repliedMsg.getStringValue('direction') == 'incoming';
    final senderName = isIncoming
        ? (customerName.isNotEmpty ? customerName : repliedMsg.getStringValue('sender_phone'))
        : (_agentNames[repliedMsg.getStringValue('sender')] ?? 'Agent');
    final body = repliedMsg.getStringValue('body');

    return GestureDetector(
      onTap: () {
        _highlightMessage(repliedMsg.id);
        final key = _messageKeys[repliedMsg.id];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // If the item is off-screen, context is null. Calculate estimated offset
          // to bring it into the viewport, and then snap it using layout context.
          final idx = _messages.indexWhere((m) => m.id == repliedMsg.id);
          if (idx != -1) {
            double offset = 0.0;
            // No button height offset addition is needed since the button is at the end (top) of a reversed list
            for (int i = 0; i < idx; i++) {
              final m = _messages[i];
              final type = m.getStringValue('type');
              final mediaFile = m.getStringValue('media_file');
              final hasReply = m.getStringValue('reply_to_id').isNotEmpty;
              
              double itemHeight = 60.0;
              if (mediaFile.isNotEmpty) {
                if (type == 'image') {
                  itemHeight = 240.0;
                } else if (type == 'video') {
                  itemHeight = 160.0;
                } else {
                  itemHeight = 100.0; // doc/audio
                }
              } else {
                final bodyLen = m.getStringValue('body').length;
                if (bodyLen > 100) {
                  itemHeight = 120.0;
                } else if (bodyLen > 50) {
                  itemHeight = 90.0;
                }
              }
              if (hasReply) {
                itemHeight += 50.0;
              }
              offset += itemHeight + 8.0; // Bubble spacing
            }

            if (offset > _scrollController.position.maxScrollExtent) {
              offset = _scrollController.position.maxScrollExtent;
            }

            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).then((_) {
              // Wait a split second for layout compilation on screen, then center/snap it!
              Future.delayed(const Duration(milliseconds: 100), () {
                if (key != null && key.currentContext != null) {
                  Scrollable.ensureVisible(
                    key.currentContext!,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                  );
                }
              });
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Original message is not loaded. Try scrolling up.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isIncoming ? const Color(0xFF128C7E) : const Color(0xFF3B82F6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isIncoming ? const Color(0xFF128C7E) : const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body.isNotEmpty ? body : '[Media]',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreviewPanel() {
    if (_replyingToMessage == null) return const SizedBox.shrink();

    final customerName = widget.conversation.getStringValue('customer_name');
    final customerPhone = widget.conversation.getStringValue('customer_phone');
    
    final isIncoming = _replyingToMessage!.getStringValue('direction') == 'incoming';
    final senderName = isIncoming
        ? (customerName.isNotEmpty ? customerName : _replyingToMessage!.getStringValue('sender_phone'))
        : (_agentNames[_replyingToMessage!.getStringValue('sender')] ?? 'Agent');
        
    final body = _replyingToMessage!.getStringValue('body');
    final mediaFile = _replyingToMessage!.getStringValue('media_file');

    return Container(
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isIncoming ? const Color(0xFF128C7E) : const Color(0xFF3B82F6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isIncoming ? const Color(0xFF128C7E) : const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mediaFile.isNotEmpty
                            ? '[Media] ${body.isNotEmpty ? body : ""}'
                            : body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _replyingToMessage = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.conversation.getStringValue('customer_name');
    final customerPhone = widget.conversation.getStringValue('customer_phone');

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // Standard WhatsApp background color tint
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName.isNotEmpty ? customerName : customerPhone,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customerPhone,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_windowRemainingTime != null || _isWindowExpired)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: Text(
                  _isWindowExpired ? 'Expired' : _formatDuration(_windowRemainingTime),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: _isWindowExpired
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF128C7E),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Message List area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF128C7E)))
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Anchor list at the bottom (index 0 is latest message)
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_hasMore && index == _messages.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: _isPaginationLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF128C7E),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: _loadMoreMessages,
                                    child: const Text(
                                      'Load older messages',
                                      style: TextStyle(
                                        color: Color(0xFF128C7E),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isIncoming = msg.getStringValue('direction') == 'incoming';
                      final body = msg.getStringValue('body');
                      final timestamp = msg.getStringValue('timestamp');
                      final status = msg.getStringValue('status');
                      final senderId = msg.getStringValue('sender');
                      final senderName = _agentNames[senderId];
                      final mediaFile = msg.getStringValue('media_file');

                      final replyToId = msg.getStringValue('reply_to_id');
                      RecordModel? repliedMsg;
                      if (replyToId.isNotEmpty) {
                        try {
                          repliedMsg = _messages.firstWhere((m) => m.getStringValue('message_id') == replyToId);
                        } catch (_) {}
                      }

                      final msgKey = _messageKeys.putIfAbsent(msg.id, () => GlobalKey());
                      final isHighlighted = msg.id == _highlightedMessageId;
                      final bubbleColor = isHighlighted
                          ? const Color(0xFFFEF08A) // Soft WhatsApp-style yellow highlight
                          : (isIncoming ? Colors.white : const Color(0xFFDCF8C6));

                      return Align(
                        key: msgKey,
                        alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
                        child: SwipeToReply(
                          onReply: () {
                            setState(() {
                              _replyingToMessage = msg;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.only(bottom: 8),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isIncoming ? Radius.zero : const Radius.circular(12),
                                bottomRight: isIncoming ? const Radius.circular(12) : Radius.zero,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isHighlighted
                                      ? const Color(0xFFEAB308).withOpacity(0.2)
                                      : Colors.black.withOpacity(0.04),
                                  blurRadius: isHighlighted ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Outgoing: Show which agent sent the message
                                if (!isIncoming && senderName != null && senderName.isNotEmpty) ...[
                                  Text(
                                    senderName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF128C7E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],

                                // Render Reply Quote Block if parent message exists
                                if (repliedMsg != null)
                                  _buildReplyPreview(repliedMsg, customerName),

                                if (mediaFile.isNotEmpty)
                                  _buildMediaContent(msg)
                                else
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                      height: 1.3,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatMsgTime(timestamp),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (!isIncoming) ...[
                                      const SizedBox(width: 4),
                                      _buildStatusTicks(status),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_replyingToMessage != null) _buildReplyPreviewPanel(),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFFF0F0F0),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              enabled: !_isWindowExpired,
                              maxLines: 4,
                              minLines: 1,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: _isWindowExpired
                                    ? '24-hour window expired. Cannot reply.'
                                    : 'Type a message',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
                            onPressed: _isSending || _isWindowExpired ? null : _showAttachmentMenu,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending || _isWindowExpired ? null : _sendMessage,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: _isSending || _isWindowExpired ? Colors.grey : const Color(0xFF128C7E), // WhatsApp Send Button Green
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.white),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragOffset = 0.0;
  double _startDragOffset = 0.0;
  bool _triggered = false;

  static const double _threshold = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(() {
      setState(() {
        _dragOffset = _controller.value * _startDragOffset;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      setState(() {
        _dragOffset += details.delta.dx * 0.6;
        if (_dragOffset > _threshold && !_triggered) {
          _triggered = true;
          Feedback.forLongPress(context);
        }
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_triggered) {
      widget.onReply();
    }
    _startDragOffset = _dragOffset;
    _controller.reverse(from: 1.0);
    _triggered = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: -40 + (_dragOffset.clamp(0.0, _threshold) / _threshold) * 50,
            child: Opacity(
              opacity: (_dragOffset / _threshold).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: (_dragOffset / _threshold).clamp(0.5, 1.2),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF128C7E),
                  child: Icon(
                    Icons.reply_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_dragOffset.clamp(0.0, _threshold + 20), 0.0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
