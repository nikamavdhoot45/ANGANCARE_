import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;

  int totalChildren = 0;
  int normalChildren = 0;
  int moderateChildren = 0;
  int severeChildren = 0;

  int totalWorkers = 0;
  int activeWorkers = 0;
  int inactiveWorkers = 0;

  String _t(
      BuildContext context,
      String english,
      String marathi,
      String hindi,
      ) {
    final languageCode =
        AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') {
      return marathi;
    }

    if (languageCode == 'hi') {
      return hindi;
    }

    return english;
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      isLoading = true;
    });

    try {
      final childrenSnapshot =
      await _firestore.collection('children').get();

      final workersSnapshot =
      await _firestore.collection('workers').get();

      int normal = 0;
      int moderate = 0;
      int severe = 0;

      for (final doc in childrenSnapshot.docs) {
        final data = doc.data();

        final status = data['growthStatus']
            ?.toString()
            .trim()
            .toLowerCase();

        if (status == 'normal') {
          normal++;
        } else if (status == 'moderate') {
          moderate++;
        } else if (status == 'severe') {
          severe++;
        }
      }

      int active = 0;
      int inactive = 0;

      for (final doc in workersSnapshot.docs) {
        final data = doc.data();

        if (data['isActive'] == true) {
          active++;
        } else {
          inactive++;
        }
      }

      if (!mounted) return;

      setState(() {
        totalChildren = childrenSnapshot.docs.length;
        normalChildren = normal;
        moderateChildren = moderate;
        severeChildren = severe;

        totalWorkers = workersSnapshot.docs.length;
        activeWorkers = active;
        inactiveWorkers = inactive;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Unable to load reports.',
              'अहवाल लोड करता आले नाहीत.',
              'रिपोर्ट लोड नहीं की जा सकीं।',
            )}\n$e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29266F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String title,
    required int value,
    required Color color,
  }) {
    final percentage = totalChildren == 0
        ? 0.0
        : value / totalChildren;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF29266F),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
              AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerStatusCard() {
    final activePercentage =
    totalWorkers == 0
        ? 0.0
        : activeWorkers / totalWorkers;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            _t(
              context,
              'Worker Status',
              'कार्यकर्ता स्थिती',
              'कार्यकर्ता स्थिति',
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF29266F),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWorkerStatusItem(
                  title: _t(
                    context,
                    'Active',
                    'सक्रिय',
                    'सक्रिय',
                  ),
                  value: activeWorkers,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWorkerStatusItem(
                  title: _t(
                    context,
                    'Inactive',
                    'निष्क्रिय',
                    'निष्क्रिय',
                  ),
                  value: inactiveWorkers,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: activePercentage,
              minHeight: 9,
              backgroundColor:
              Colors.orange.withValues(alpha: 0.15),
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerStatusItem({
    required String title,
    required int value,
    required Color color,
  }) {
    final isActive = title == _t(
      context,
      'Active',
      'सक्रिय',
      'सक्रिय',
    );

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isActive
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29266F),
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
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _t(
            context,
            'Admin Reports',
            'प्रशासक अहवाल',
            'व्यवस्थापक रिपोर्ट',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadReports,
            icon: const Icon(Icons.refresh),
            tooltip: _t(
              context,
              'Refresh Reports',
              'अहवाल रीफ्रेश करा',
              'रिपोर्ट रीफ्रेश करें',
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF45170),
        ),
      )
          : RefreshIndicator(
        color: const Color(0xFFF45170),
        onRefresh: _loadReports,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  context,
                  'System Reports',
                  'सिस्टम अहवाल',
                  'सिस्टम रिपोर्ट',
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF29266F),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _t(
                  context,
                  'Overview of children and worker data.',
                  'मुले आणि कार्यकर्त्यांच्या डेटाचा आढावा.',
                  'बच्चों और कार्यकर्ताओं के डेटा का अवलोकन।',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                _t(
                  context,
                  'Children Overview',
                  'मुलांचा आढावा',
                  'बच्चों का अवलोकन',
                ),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF29266F),
                ),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.child_care_outlined,
                title: _t(
                  context,
                  'Total Children',
                  'एकूण मुले',
                  'कुल बच्चे',
                ),
                value: totalChildren,
                color: const Color(0xFFF45170),
              ),
              const SizedBox(height: 12),
              _buildStatusRow(
                title: _t(
                  context,
                  'Normal',
                  'सामान्य',
                  'सामान्य',
                ),
                value: normalChildren,
                color: Colors.green,
              ),
              _buildStatusRow(
                title: _t(
                  context,
                  'Moderate',
                  'मध्यम',
                  'मध्यम',
                ),
                value: moderateChildren,
                color: Colors.orange,
              ),
              _buildStatusRow(
                title: _t(
                  context,
                  'Severe',
                  'गंभीर',
                  'गंभीर',
                ),
                value: severeChildren,
                color: Colors.red,
              ),
              const SizedBox(height: 18),
              Text(
                _t(
                  context,
                  'Worker Overview',
                  'कार्यकर्ता आढावा',
                  'कार्यकर्ता अवलोकन',
                ),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF29266F),
                ),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.people_outline,
                title: _t(
                  context,
                  'Total Workers',
                  'एकूण कार्यकर्ते',
                  'कुल कार्यकर्ता',
                ),
                value: totalWorkers,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 12),
              _buildWorkerStatusCard(),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFF45170),
                      size: 24,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        _t(
                          context,
                          'These reports are calculated from the current data stored in Firebase Firestore.',
                          'हे अहवाल Firebase Firestore मध्ये साठवलेल्या सध्याच्या डेटावर आधारित आहेत.',
                          'ये रिपोर्ट Firebase Firestore में संग्रहीत वर्तमान डेटा के आधार पर तैयार की गई हैं।',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF29266F),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}