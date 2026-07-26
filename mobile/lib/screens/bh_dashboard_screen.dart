import 'package:flutter/material.dart';
import 'import_screen.dart';
import 'whatsapp_dashboard_screen.dart';
import '../widgets/quick_stat_card.dart';

class BHDashboardScreen extends StatelessWidget {
  const BHDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'BH Workspace',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF475569), size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── GRID MODULES SECTION ──────────────────────────────────────────
            const Text(
              'OPERATIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Responsive Grid for SaaS look
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildSaaSCard(
                  context,
                  icon: Icons.cloud_upload_outlined,
                  label: 'Bulk Import',
                  sub: 'Excel Sync',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())),
                ),
                _buildSaaSCard(
                  context,
                  icon: Icons.groups_outlined,
                  label: 'Lead Master',
                  sub: 'Customer Data',
                  color: const Color(0xFF10B981),
                  onTap: () {},
                ),
                _buildSaaSCard(
                  context,
                  icon: Icons.badge_outlined,
                  label: 'HR Portal',
                  sub: 'Employee List',
                  color: const Color(0xFFF59E0B),
                  onTap: () {},
                ),
                _buildSaaSCard(
                  context,
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  sub: 'Performance',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {},
                ),
                _buildSaaSCard(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'WhatsApp Hub',
                  sub: 'Inbox & Campaigns',
                  color: const Color(0xFF25D366),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WhatsAppDashboardScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── SYSTEM STATUS SECTION ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('All background syncs are active.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statusTag('Sync: Active', Colors.green),
                      const SizedBox(width: 8),
                      _statusTag('DB: Connected', Colors.blue),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaaSCard(BuildContext context, {
    required IconData icon, 
    required String label, 
    required String sub,
    required Color color, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
