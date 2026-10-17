import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

import '../../children/screens/children_screen.dart';
import '../../children/screens/add_child_screen.dart';
import '../../children/screens/growth_screen.dart';
import '../../children/screens/nutrition_screen.dart';
import '../../children/screens/health_screen.dart';
import '../../children/screens/attendance_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final Color primaryColor = const Color(0xFFF45170);
  final Color darkBlue = const Color(0xFF29266F);
  final Color backgroundColor = const Color(0xFFFFFBF8);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalChildren = 0;
  int normalChildren = 0;
  int moderateChildren = 0;
  int severeChildren = 0;

  bool isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardCounts();
  }

  Future<void> _loadDashboardCounts() async {
    try {
      final snapshot = await _firestore.collection('children').get();

      int normal = 0;
      int moderate = 0;
      int severe = 0;

      for (final document in snapshot.docs) {
        final data = document.data();

        final status = (data['growthStatus'] ??
                data['growth_status'] ??
                data['healthStatus'] ??
                data['health_status'] ??
                'Normal')
            .toString()
            .toLowerCase();

        if (status == 'normal') {
          normal++;
        } else if (status == 'moderate') {
          moderate++;
        } else if (status == 'severe') {
          severe++;
        }
      }

      if (!mounted) return;

      setState(() {
        totalChildren = snapshot.docs.length;
        normalChildren = normal;
        moderateChildren = moderate;
        severeChildren = severe;
        isLoadingCounts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingCounts = false;
      });
    }
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return const ChildrenScreen();
      case 2:
        return const AlertsScreen();
      case 3:
        return const ReportsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildDashboardHome();
    }
  }

  void _openAddChild() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddChildScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadDashboardCounts();
      setState(() {});
    }
  }

  void _openHealthCheckup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HealthScreen(
          childName: 'All Children',
        ),
      ),
    );
  }

  Future<void> _openGrowth() async {
    final l = AppLocalizations.of(context);

    try {
      final snapshot = await _firestore
          .collection('children')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.pleaseAddChildFirst),
          ),
        );
        return;
      }

      final child = snapshot.docs.first;
      final childId = child.id;
      final childName = (child.data()['name'] ?? 'Child').toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrowthScreen(
            childId: childId,
            childName: childName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.unableToOpenGrowth}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScreen(),
      ),
    );
  }

  Widget _buildDashboardHome() {
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardCounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildWelcomeCard(),
              const SizedBox(height: 22),
              Text(
                l.overview,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      title: l.totalChildren,
                      value: isLoadingCounts ? '...' : totalChildren.toString(),
                      icon: Icons.child_care,
                      iconColor: primaryColor,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      title: l.normal,
                      value:
                          isLoadingCounts ? '...' : normalChildren.toString(),
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      title: l.moderate,
                      value:
                          isLoadingCounts ? '...' : moderateChildren.toString(),
                      icon: Icons.warning_amber_outlined,
                      iconColor: Colors.orange,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      title: l.severe,
                      value:
                          isLoadingCounts ? '...' : severeChildren.toString(),
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                l.quickActions,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      title: l.addChild,
                      icon: Icons.person_add_alt_1,
                      onTap: _openAddChild,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      title: l.growth,
                      icon: Icons.monitor_weight_outlined,
                      onTap: _openGrowth,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      title: l.nutrition,
                      icon: Icons.restaurant_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NutritionScreen(
                              childName: 'All Children',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      title: l.health,
                      icon: Icons.health_and_safety_outlined,
                      onTap: _openHealthCheckup,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      title: l.attendance,
                      icon: Icons.fact_check_outlined,
                      onTap: _openAttendance,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildSectionHeader(
                title: l.alerts,
                buttonText: l.viewAll,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildAlertCard(
                title: l.vaccinationDue,
                subtitle: l.vaccinationRecordsNeedAttention,
                icon: Icons.vaccines_outlined,
                iconColor: Colors.orange,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildAlertCard(
                title: l.healthCheckupDue,
                subtitle: l.upcomingChildHealthCheckup,
                icon: Icons.medical_services_outlined,
                iconColor: primaryColor,
                onTap: _openHealthCheckup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.child_care,
                  color: primaryColor,
                  size: 32,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANGANCARE',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.childHealthcareManagement,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          icon: Icon(
            Icons.notifications_none,
            color: darkBlue,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    final l = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            const Color(0xFFFF718A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.20),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.welcomeToAnganCare,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  l.manageChildRecords,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _openAddChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFF45170),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    l.addNewChild,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.family_restroom,
            color: Colors.white,
            size: 75,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 105,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: darkBlue,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            buttonText,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Material(
        color: backgroundColor,
        child: _getScreen(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l.children,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            selectedIcon: const Icon(Icons.notifications),
            label: l.alerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assessment_outlined),
            selectedIcon: const Icon(Icons.assessment),
            label: l.reports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}
