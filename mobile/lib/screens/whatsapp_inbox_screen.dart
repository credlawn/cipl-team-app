import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';
import '../core/pb_api.dart';
import 'whatsapp_chat_screen.dart';

class WhatsAppInboxScreen extends StatefulWidget {
  const WhatsAppInboxScreen({super.key});

  @override
  State<WhatsAppInboxScreen> createState() => _WhatsAppInboxScreenState();
}

class _WhatsAppInboxScreenState extends State<WhatsAppInboxScreen> {
  bool _isLoading = true;
  List<RecordModel> _conversations = [];
  Map<String, String> _agentNames = {}; // Store agent ID to name mapping for convenience
  Map<String, DateTime> _lastIncomingTimes = {}; // Store conversation ID to last incoming message time

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _subscribeToConversations();
  }

  @override
  void dispose() {
    PB.pb.collection('whatsapp_conversations').unsubscribe('*');
    super.dispose();
  }

  void _subscribeToConversations() {
    PB.pb.collection('whatsapp_conversations').subscribe('*', (e) {
      if (!mounted) return;
      // Re-fetch conversation list to dynamically update last messages and order
      _fetchConversations();
    });
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Fetch active conversations sorted by last message time
      final records = await PB.pb.collection('whatsapp_conversations').getFullList(
            sort: '-last_message_time',
          );

      // Fetch latest incoming messages from the last 24 hours to check if window is open
      final timeLimit = DateTime.now().toUtc().subtract(const Duration(hours: 24));
      final formattedTimeLimit = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timeLimit) + 'Z';
      final recentIncoming = await PB.pb.collection('whatsapp_messages').getFullList(
            filter: 'direction = "incoming" && timestamp >= "$formattedTimeLimit"',
            sort: '-timestamp',
          );

      final Map<String, DateTime> lastIncomingTimes = {};
      for (var msg in recentIncoming) {
        final convId = msg.getStringValue('conversation');
        final timestampStr = msg.getStringValue('timestamp');
        if (convId.isNotEmpty && timestampStr.isNotEmpty) {
          try {
            final time = DateTime.parse(timestampStr).toLocal();
            if (!lastIncomingTimes.containsKey(convId)) {
              lastIncomingTimes[convId] = time;
            }
          } catch (_) {}
        }
      }

      // Fetch user names for assignment display
      final agentIds = records
          .map((r) => r.getStringValue('assigned_to'))
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (agentIds.isNotEmpty) {
        final users = await PB.pb.collection('users').getFullList(
              filter: agentIds.map((id) => 'id = "$id"').join(' || '),
            );
        for (var user in users) {
          _agentNames[user.id] = user.getStringValue('name');
        }
      }

      if (mounted) {
        setState(() {
          _conversations = records;
          _lastIncomingTimes = lastIncomingTimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load conversations: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  String _formatDateTime(String? utcString) {
    if (utcString == null || utcString.isEmpty) return '';
    try {
      final localDateTime = DateTime.parse(utcString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(localDateTime);

      if (difference.inDays == 0) {
        return DateFormat('hh:mm a').format(localDateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(localDateTime); // Day name
      } else {
        return DateFormat('dd/MM/yyyy').format(localDateTime);
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Inbox',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Active customer conversations',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        actions: [
          IconButton(
            onPressed: _fetchConversations,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF25D366)),
            )
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active conversations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Incoming WhatsApp messages will appear here.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchConversations,
                  color: const Color(0xFF25D366),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 80,
                      endIndent: 16,
                      color: Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final phone = conv.getStringValue('customer_phone');
                      final name = conv.getStringValue('customer_name');
                      final lastMsg = conv.getStringValue('last_message');
                      final lastMsgTime = conv.getStringValue('last_message_time');
                      final assignedTo = conv.getStringValue('assigned_to');
                      final agentName = _agentNames[assignedTo];

                      // Calculate 24-hour reply window status
                      final lastIncomingTime = _lastIncomingTimes[conv.id];
                      final isWindowOpen = lastIncomingTime != null &&
                          DateTime.now().isBefore(lastIncomingTime.add(const Duration(hours: 24)));

                      // Custom Initials Avatar
                      final initials = name.isNotEmpty
                          ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                          : 'U';

                      return ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WhatsAppChatScreen(conversation: conv),
                            ),
                          );
                          _fetchConversations(); // Reload lists when back in case changes were made
                        },
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF128C7E).withOpacity(0.1),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Color(0xFF128C7E),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          name.isNotEmpty ? name : phone,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDateTime(lastMsgTime),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isWindowOpen && lastIncomingTime != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF25D366),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InboxCountdownTimer(
                                    expiryTime: lastIncomingTime.add(const Duration(hours: 24)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lastMsg.isNotEmpty ? lastMsg : '[Media message]',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (agentName != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    'Assigned to: $agentName',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      );
                    },
                  ),
                ),
    );
  }
}

class InboxCountdownTimer extends StatefulWidget {
  final DateTime expiryTime;

  const InboxCountdownTimer({super.key, required this.expiryTime});

  @override
  State<InboxCountdownTimer> createState() => _InboxCountdownTimerState();
}

class _InboxCountdownTimerState extends State<InboxCountdownTimer> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  void _calculateRemaining() {
    _remaining = widget.expiryTime.difference(DateTime.now());
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return const SizedBox.shrink();
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours:$minutes:$seconds',
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF25D366),
        fontWeight: FontWeight.bold,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
