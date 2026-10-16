import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_workers_screen.dart';
import 'add_worker_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_reports_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  void _openAnnouncements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AdminAnnouncementsScreen(),
      ),
    );
  }

  void _openWorkers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AdminWorkersScreen(),
      ),
    );
  }

  void _openAddWorker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AddWorkerScreen(),
      ),
    );
  }

  void _openReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AdminReportsScreen(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AdminSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29266F),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage ANGANCARE operations and announcements.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'Administration',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAdminCard(
                    context,
                    icon:
                    Icons.campaign_outlined,
                    title: 'Announcements',
                    subtitle:
                    'Create and manage notices',
                    color:
                    const Color(0xFFF45170),
                    onTap: () =>
                        _openAnnouncements(
                          context,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAdminCard(
                    context,
                    icon:
                    Icons.people_outline,
                    title: 'Workers',
                    subtitle:
                    'Manage worker accounts',
                    color:
                    const Color(0xFF2196F3),
                    onTap: () =>
                        _openWorkers(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAdminCard(
                    context,
                    icon:
                    Icons.assessment_outlined,
                    title: 'Reports',
                    subtitle:
                    'View system reports',
                    color:
                    const Color(0xFF4CAF50),
                    onTap: () =>
                        _openReports(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAdminCard(
                    context,
                    icon:
                    Icons.settings_outlined,
                    title: 'Settings',
                    subtitle:
                    'Manage app settings',
                    color:
                    const Color(0xFF29266F),
                    onTap: () =>
                        _openSettings(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle(
              'Quick Actions',
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              context,
              icon:
              Icons.add_alert_outlined,
              title:
              'Create Announcement',
              subtitle:
              'Send a holiday, health, meal or general notice',
              onTap: () =>
                  _openAnnouncements(
                    context,
                  ),
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              context,
              icon:
              Icons.person_add_alt_1_outlined,
              title: 'Add Worker',
              subtitle:
              'Create a new worker account',
              onTap: () =>
                  _openAddWorker(context),
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              context,
              icon: Icons.history_outlined,
              title:
              'Announcement History',
              subtitle:
              'View previously published announcements',
              onTap: () =>
                  _openAnnouncements(
                    context,
                  ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                const Color(0xFFFCE4EC),
                borderRadius:
                BorderRadius.circular(15),
              ),
              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .admin_panel_settings_outlined,
                    color:
                    Color(0xFFF45170),
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator Access',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            Color(0xFF29266F),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'This area is intended for authorized '
                              'ANGANCARE administrators.',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                            Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF29266F),
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding:
        const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                color.withValues(alpha: 0.12),
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color:
                const Color(0xFFFCE4EC),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                const Color(0xFFF45170),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                    const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}