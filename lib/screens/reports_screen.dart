import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFFFE1E7),
                  child: Icon(
                    Icons.bar_chart,
                    color: Color(0xFFF45170),
                    size: 30,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View and manage child health reports',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Reports',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _reportCard(
            context,
            icon: Icons.people_outline,
            title: 'Children Report',
            subtitle: 'View registered children and their status',
            iconColor: const Color(0xFF4CAF50),
            page: const ChildrenReportPage(),
          ),
          const SizedBox(height: 12),
          _reportCard(
            context,
            icon: Icons.show_chart,
            title: 'Growth Report',
            subtitle: 'Height, weight and growth monitoring',
            iconColor: const Color(0xFF2196F3),
            page: const GrowthReportPage(),
          ),
          const SizedBox(height: 12),
          _reportCard(
            context,
            icon: Icons.restaurant_outlined,
            title: 'Nutrition Report',
            subtitle: 'Nutrition and dietary information',
            iconColor: const Color(0xFFFF9800),
            page: const NutritionReportPage(),
          ),
          const SizedBox(height: 12),
          _reportCard(
            context,
            icon: Icons.vaccines_outlined,
            title: 'Vaccination Report',
            subtitle: 'Vaccination records and upcoming doses',
            iconColor: const Color(0xFF9C27B0),
            page: const VaccinationReportPage(),
          ),
          const SizedBox(height: 12),
          _reportCard(
            context,
            icon: Icons.medical_services_outlined,
            title: 'Health Report',
            subtitle: 'Health checkups and medical information',
            iconColor: const Color(0xFFF45170),
            page: const HealthReportPage(),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFF45170),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select a report above to view detailed information.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _reportCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color iconColor,
        required Widget page,
      }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FIRESTORE HELPERS
// ============================================================

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String _stringValue(dynamic value, [String fallback = '']) {
  if (value == null) {
    return fallback;
  }

  return value.toString();
}

String _childStatus(Map<String, dynamic> data) {
  final growthStatus = _stringValue(data['growthStatus']).trim();

  final healthStatus = _stringValue(data['healthStatus']).trim();

  if (growthStatus.isNotEmpty) {
    return _normaliseStatus(growthStatus);
  }

  if (healthStatus.isNotEmpty) {
    return _normaliseStatus(healthStatus);
  }

  final oldGrowthStatus = _stringValue(data['growth_status']).trim();

  final oldHealthStatus = _stringValue(data['health_status']).trim();

  if (oldGrowthStatus.isNotEmpty) {
    return _normaliseStatus(oldGrowthStatus);
  }

  if (oldHealthStatus.isNotEmpty) {
    return _normaliseStatus(oldHealthStatus);
  }

  return 'Normal';
}

String _normaliseStatus(String status) {
  final value = status.toLowerCase().trim();

  if (value.contains('severe')) {
    return 'Severe';
  }

  if (value.contains('moderate')) {
    return 'Moderate';
  }

  if (value.contains('attention')) {
    return 'Moderate';
  }

  if (value.contains('normal') || value.contains('healthy')) {
    return 'Normal';
  }

  return status;
}

Color _statusColor(String status) {
  if (status == 'Severe') {
    return const Color(0xFFF44336);
  }

  if (status == 'Moderate') {
    return const Color(0xFFFF9800);
  }

  return const Color(0xFF4CAF50);
}

Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
_getChildren() async {
  final snapshot = await _firestore.collection('children').get();

  final children = snapshot.docs.toList();

  children.sort((a, b) {
    final aTime = a.data()['createdAt'];
    final bTime = b.data()['createdAt'];

    if (aTime is Timestamp && bTime is Timestamp) {
      return bTime.compareTo(aTime);
    }

    return 0;
  });

  return children;
}

Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
_getRecordsForAllChildren(String collectionName) async {
  final children = await _getChildren();

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> records = [];

  for (final child in children) {
    final snapshot = await child.reference
        .collection(collectionName)
        .get();

    records.addAll(snapshot.docs);
  }

  return records;
}

Widget _loadingWidget() {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(30),
      child: CircularProgressIndicator(
        color: Color(0xFFF45170),
      ),
    ),
  );
}

Widget _errorWidget(Object error) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFF44336),
            size: 45,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load report data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _emptyWidget(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insert_chart_outlined,
            color: Colors.grey,
            size: 55,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// CHILDREN REPORT
// ============================================================

class ChildrenReportPage extends StatelessWidget {
  const ChildrenReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _reportScaffold(
      context,
      title: 'Children Report',
      icon: Icons.people_outline,
      children: [
        FutureBuilder<
            List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _getChildren(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingWidget();
            }

            if (snapshot.hasError) {
              return _errorWidget(snapshot.error!);
            }

            final children = snapshot.data ?? [];

            if (children.isEmpty) {
              return _emptyWidget(
                'No children have been registered yet.',
              );
            }

            int normal = 0;
            int moderate = 0;
            int severe = 0;

            for (final child in children) {
              final status = _childStatus(child.data());

              if (status == 'Severe') {
                severe++;
              } else if (status == 'Moderate') {
                moderate++;
              } else {
                normal++;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCard(
                  title: 'Total Children',
                  value: '${children.length}',
                  icon: Icons.people,
                  iconColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _smallSummary(
                        title: 'Normal',
                        value: '$normal',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallSummary(
                        title: 'Moderate',
                        value: '$moderate',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallSummary(
                        title: 'Severe',
                        value: '$severe',
                        color: const Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Children Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...children.map((child) {
                  final data = child.data();

                  final name =
                  _stringValue(data['name'], 'Unnamed Child');

                  final age =
                  _stringValue(data['age'], 'Age not available');

                  final status = _childStatus(data);

                  return _childReportRow(
                    name: name,
                    age: age.contains('Year')
                        ? age
                        : '$age Years',
                    status: status,
                    color: _statusColor(status),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// GROWTH REPORT
// ============================================================

class GrowthReportPage extends StatelessWidget {
  const GrowthReportPage({super.key});

  Future<List<Map<String, dynamic>>> _getGrowthData() async {
    final children = await _getChildren();

    final List<Map<String, dynamic>> result = [];

    for (final child in children) {
      final childData = child.data();

      final recordsSnapshot = await child.reference
          .collection('growthRecords')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      double? height;
      double? weight;

      if (recordsSnapshot.docs.isNotEmpty) {
        final record = recordsSnapshot.docs.first.data();

        height = _toDouble(record['height']);
        weight = _toDouble(record['weight']);
      }

      height ??= _toDouble(childData['height']);
      weight ??= _toDouble(childData['weight']);

      if (height != null || weight != null) {
        result.add({
          'name': _stringValue(
            childData['name'],
            'Unnamed Child',
          ),
          'height': height,
          'weight': weight,
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return _reportScaffold(
      context,
      title: 'Growth Report',
      icon: Icons.show_chart,
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getGrowthData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingWidget();
            }

            if (snapshot.hasError) {
              return _errorWidget(snapshot.error!);
            }

            final data = snapshot.data ?? [];

            return FutureBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              future: _getChildren(),
              builder: (context, childrenSnapshot) {
                if (childrenSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _loadingWidget();
                }

                if (childrenSnapshot.hasError) {
                  return _errorWidget(childrenSnapshot.error!);
                }

                final children = childrenSnapshot.data ?? [];

                if (children.isEmpty) {
                  return _emptyWidget(
                    'No children have been registered yet.',
                  );
                }

                int heightAvailable = 0;
                int weightAvailable = 0;

                for (final item in data) {
                  if (item['height'] != null) {
                    heightAvailable++;
                  }

                  if (item['weight'] != null) {
                    weightAvailable++;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryCard(
                      title: 'Children Monitored',
                      value: '${data.length}',
                      icon: Icons.monitor_weight_outlined,
                      iconColor: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Growth Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _informationCard(
                      icon: Icons.height,
                      title: 'Height Monitoring',
                      value: data.isEmpty
                          ? 'No height records available'
                          : '$heightAvailable children have height records',
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 10),
                    _informationCard(
                      icon: Icons.monitor_weight_outlined,
                      title: 'Weight Monitoring',
                      value: data.isEmpty
                          ? 'No weight records available'
                          : '$weightAvailable children have weight records',
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 10),
                    _informationCard(
                      icon: Icons.trending_up,
                      title: 'Growth Progress',
                      value: data.isEmpty
                          ? 'No growth data available'
                          : '${data.length} children have growth data',
                      color: const Color(0xFFF45170),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Recent Measurements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (data.isEmpty)
                      _emptyWidget(
                        'No growth measurements have been recorded yet.',
                      )
                    else
                      ...data.map(
                            (item) => _measurementRow(
                          name: item['name'] as String,
                          height: item['height'] == null
                              ? 'Not recorded'
                              : '${_formatNumber(item['height'])} cm',
                          weight: item['weight'] == null
                              ? 'Not recorded'
                              : '${_formatNumber(item['weight'])} kg',
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// NUTRITION REPORT
// ============================================================

class NutritionReportPage extends StatelessWidget {
  const NutritionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _reportScaffold(
      context,
      title: 'Nutrition Report',
      icon: Icons.restaurant_outlined,
      children: [
        FutureBuilder<
            List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _getRecordsForAllChildren('nutritionRecords'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingWidget();
            }

            if (snapshot.hasError) {
              return _errorWidget(snapshot.error!);
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return _emptyWidget(
                'No nutrition records have been added yet.',
              );
            }

            int normal = 0;
            int attention = 0;
            int risk = 0;

            for (final record in records) {
              final data = record.data();

              final status = _nutritionStatusValue(data);

              if (status == 'Normal') {
                normal++;
              } else if (status == 'Risk') {
                risk++;
              } else {
                attention++;
              }
            }

            final total = records.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCard(
                  title: 'Children Assessed',
                  value: '$total',
                  icon: Icons.restaurant,
                  iconColor: const Color(0xFFFF9800),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Nutrition Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _nutritionStatus(
                  title: 'Normal Nutrition',
                  value: '$normal Children',
                  percentage: _percentage(normal, total),
                  color: const Color(0xFF4CAF50),
                ),
                _nutritionStatus(
                  title: 'Needs Attention',
                  value: '$attention Children',
                  percentage: _percentage(attention, total),
                  color: const Color(0xFFFF9800),
                ),
                _nutritionStatus(
                  title: 'Malnutrition Risk',
                  value: '$risk Children',
                  percentage: _percentage(risk, total),
                  color: const Color(0xFFF44336),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Diet Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _informationCard(
                  icon: Icons.local_dining,
                  title: 'Balanced Diet',
                  value:
                  'Protein, vegetables, fruits and grains',
                  color: const Color(0xFFFF9800),
                ),
                const SizedBox(height: 10),
                _informationCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Hydration',
                  value:
                  'Ensure adequate daily water intake',
                  color: const Color(0xFF2196F3),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _nutritionStatusValue(Map<String, dynamic> data) {
  final status = _stringValue(
    data['status'] ??
        data['nutritionStatus'] ??
        data['nutrition_status'],
  ).toLowerCase();

  if (status.contains('risk') ||
      status.contains('malnutrition') ||
      status.contains('severe')) {
    return 'Risk';
  }

  if (status.contains('normal') ||
      status.contains('healthy') ||
      status.contains('good')) {
    return 'Normal';
  }

  return 'Attention';
}

// ============================================================
// VACCINATION REPORT
// ============================================================

class VaccinationReportPage extends StatelessWidget {
  const VaccinationReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _reportScaffold(
      context,
      title: 'Vaccination Report',
      icon: Icons.vaccines_outlined,
      children: [
        FutureBuilder<
            List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _getRecordsForAllChildren('vaccinationRecords'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingWidget();
            }

            if (snapshot.hasError) {
              return _errorWidget(snapshot.error!);
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return _emptyWidget(
                'No vaccination records have been added yet.',
              );
            }

            int complete = 0;
            int due = 0;
            int pending = 0;

            final List<Map<String, dynamic>> upcoming = [];

            for (final record in records) {
              final data = record.data();

              final status = _vaccinationStatus(data);

              if (status == 'Complete') {
                complete++;
              } else if (status == 'Due') {
                due++;
              } else {
                pending++;
              }

              if (status == 'Due' || status == 'Pending') {
                upcoming.add(data);
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCard(
                  title: 'Total Records',
                  value: '${records.length}',
                  icon: Icons.vaccines,
                  iconColor: const Color(0xFF9C27B0),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _smallSummary(
                        title: 'Complete',
                        value: '$complete',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallSummary(
                        title: 'Due',
                        value: '$due',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallSummary(
                        title: 'Pending',
                        value: '$pending',
                        color: const Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Upcoming Vaccinations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  _emptyWidget(
                    'No upcoming vaccination records.',
                  )
                else
                  ...upcoming.map((data) {
                    final name = _stringValue(
                      data['childName'],
                      'Child',
                    );

                    final vaccine = _stringValue(
                      data['vaccine'] ??
                          data['vaccineName'] ??
                          data['name'],
                      'Vaccination',
                    );

                    final date = _formatDateValue(
                      data['date'] ??
                          data['dueDate'] ??
                          data['vaccinationDate'],
                    );

                    final status =
                    _vaccinationStatus(data);

                    return _vaccinationRow(
                      name: name,
                      vaccine: vaccine,
                      date: date,
                      color: status == 'Pending'
                          ? const Color(0xFFF44336)
                          : const Color(0xFFFF9800),
                      status: status,
                    );
                  }),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _vaccinationStatus(Map<String, dynamic> data) {
  final status = _stringValue(
    data['status'] ?? data['vaccinationStatus'],
  ).toLowerCase();

  if (status.contains('complete') ||
      status.contains('completed') ||
      status.contains('done')) {
    return 'Complete';
  }

  if (status.contains('pending')) {
    return 'Pending';
  }

  return 'Due';
}

// ============================================================
// HEALTH REPORT
// ============================================================

class HealthReportPage extends StatelessWidget {
  const HealthReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _reportScaffold(
      context,
      title: 'Health Report',
      icon: Icons.medical_services_outlined,
      children: [
        FutureBuilder<
            List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _getRecordsForAllChildren('healthRecords'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingWidget();
            }

            if (snapshot.hasError) {
              return _errorWidget(snapshot.error!);
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return _emptyWidget(
                'No health checkup records have been added yet.',
              );
            }

            int healthy = 0;
            int followUp = 0;
            int attention = 0;

            final List<Map<String, dynamic>> recentRecords = [];

            for (final record in records) {
              final data = record.data();

              final status = _healthStatus(data);

              if (status == 'Healthy') {
                healthy++;
              } else if (status == 'Follow-up') {
                followUp++;
              } else {
                attention++;
              }

              recentRecords.add(data);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCard(
                  title: 'Health Checkups',
                  value: '${records.length}',
                  icon: Icons.health_and_safety_outlined,
                  iconColor: const Color(0xFFF45170),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Health Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _informationCard(
                  icon: Icons.check_circle_outline,
                  title: 'Healthy Children',
                  value: '$healthy healthy records',
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 10),
                _informationCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Needs Follow-up',
                  value: '$followUp records need follow-up',
                  color: const Color(0xFFFF9800),
                ),
                const SizedBox(height: 10),
                _informationCard(
                  icon: Icons.medical_information_outlined,
                  title: 'Medical Attention',
                  value: '$attention records require attention',
                  color: const Color(0xFFF44336),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Recent Checkups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...recentRecords.map((data) {
                  final status = _healthStatus(data);

                  return _healthCheckupRow(
                    name: _stringValue(
                      data['childName'],
                      'Child',
                    ),
                    date: _formatDateValue(
                      data['checkupDate'] ??
                          data['date'],
                    ),
                    status: status,
                    color: status == 'Healthy'
                        ? const Color(0xFF4CAF50)
                        : status == 'Follow-up'
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFF44336),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _healthStatus(Map<String, dynamic> data) {
  final status = _stringValue(
    data['status'] ??
        data['healthStatus'] ??
        data['health_status'],
  ).toLowerCase();

  if (status.contains('healthy') ||
      status.contains('normal') ||
      status.contains('good')) {
    return 'Healthy';
  }

  if (status.contains('follow')) {
    return 'Follow-up';
  }

  return 'Attention';
}

// ============================================================
// COMMON REPORT SCAFFOLD
// ============================================================

Widget _reportScaffold(
    BuildContext context, {
      required String title,
      required IconData icon,
      required List<Widget> children,
    }) {
  return Scaffold(
    backgroundColor: const Color(0xFFFFFBF8),
    appBar: AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

// ============================================================
// COMMON WIDGETS
// ============================================================

Widget _summaryCard({
  required String title,
  required String value,
  required IconData icon,
  required Color iconColor,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
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
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _smallSummary({
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 15,
      horizontal: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

Widget _informationCard({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
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
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _childReportRow({
  required String name,
  required String age,
  required String status,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFFFE1E7),
          child: Icon(
            Icons.child_care,
            color: Color(0xFFF45170),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                age,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _measurementRow({
  required String name,
  required String height,
  required String weight,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.child_care,
          color: Color(0xFFF45170),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              height,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              weight,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _nutritionStatus({
  required String title,
  required String value,
  required String percentage,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 45,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _vaccinationRow({
  required String name,
  required String vaccine,
  required String date,
  required Color color,
  required String status,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFF3E5F5),
          child: Icon(
            Icons.vaccines,
            color: Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vaccine,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              date,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _healthCheckupRow({
  required String name,
  required String date,
  required String status,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFFFE1E7),
          child: Icon(
            Icons.health_and_safety_outlined,
            color: Color(0xFFF45170),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// UTILITY FUNCTIONS
// ============================================================

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}

String _percentage(int value, int total) {
  if (total == 0) {
    return '0%';
  }

  final percentage = ((value / total) * 100).round();

  return '$percentage%';
}

String _formatDateValue(dynamic value) {
  if (value == null) {
    return 'Date not available';
  }

  DateTime? date;

  if (value is Timestamp) {
    date = value.toDate();
  } else if (value is DateTime) {
    date = value;
  } else {
    date = DateTime.tryParse(value.toString());
  }

  if (date == null) {
    return value.toString();
  }

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}