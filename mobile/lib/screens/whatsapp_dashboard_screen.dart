import 'package:flutter/material.dart';
import 'whatsapp_inbox_screen.dart';
import '../widgets/whatsapp_status_banner.dart';

class WhatsAppDashboardScreen extends StatelessWidget {
  const WhatsAppDashboardScreen({super.key});

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
                'WhatsApp Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Inbox, Campaigns & Configuration',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WhatsAppStatusBanner(),
            const SizedBox(height: 28),

            const Text(
              'MODULES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Modules Grid
            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              childAspectRatio: 2.8,
              children: [
                _buildModuleCard(
                  context,
                  icon: Icons.forum_outlined,
                  title: 'Chat Inbox',
                  description: 'Interact with active customer chats and assign chats to agents.',
                  color: const Color(0xFF25D366),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WhatsAppInboxScreen()),
                  ),
                ),
                _buildModuleCard(
                  context,
                  icon: Icons.campaign_outlined,
                  title: 'Bulk Campaigns',
                  description: 'Broadcast pre-approved templates to targeted lists of leads.',
                  color: const Color(0xFF3B82F6),
                  isComingSoon: true,
                  onTap: null,
                ),
                _buildModuleCard(
                  context,
                  icon: Icons.text_snippet_outlined,
                  title: 'Template Manager',
                  description: 'View and sync approved WhatsApp templates from Meta.',
                  color: const Color(0xFFF59E0B),
                  isComingSoon: true,
                  onTap: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    final bool isEnabled = onTap != null;

    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Wrapper
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEnabled ? color.withOpacity(0.1) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isEnabled ? color : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isEnabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                            ),
                          ),
                          if (isComingSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SOON',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isEnabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEnabled)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
