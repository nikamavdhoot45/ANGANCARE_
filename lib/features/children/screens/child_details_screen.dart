import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/localization/app_localizations.dart';
import 'add_child_screen.dart';
import 'growth_screen.dart';
import 'nutrition_screen.dart';
import 'health_screen.dart';

class ChildDetailsScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String age;
  final String gender;
  final String status;

  const ChildDetailsScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.age,
    required this.gender,
    required this.status,
  });

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? childData;

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  // =========================
  // LOCALIZATION
  // =========================

  String _t(String key) {
    return AppLocalizations.of(context).text(key);
  }

  String _localizedGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return _t('male');
      case 'female':
        return _t('female');
      case 'other':
        return _t('other');
      default:
        return gender;
    }
  }

  String _localizedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'healthy':
        return _t('normal');
      case 'moderate':
        return _t('moderate');
      case 'needs attention':
        return _t('needsAttention');
      case 'severe':
        return _t('severe');
      case 'under treatment':
        return _t('underTreatment');
      default:
        return status;
    }
  }

  // =========================
  // LOAD CHILD
  // =========================

  Future<void> _loadChild() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final document =
          await _firestore.collection('children').doc(widget.childId).get();

      if (!document.exists) {
        if (!mounted) {
          return;
        }

        setState(() {
          isLoading = false;
          errorMessage = _t('childRecordNotFound');
        });

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        childData = {
          'id': document.id,
          ...document.data()!,
        };

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = '${_t('unableToLoadChildDetails')}: $e';
      });
    }
  }

  // =========================
  // EDIT CHILD
  // =========================

  Future<void> _editChild() async {
    if (childData == null) {
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildScreen(
          childId: widget.childId,
          existingChild: childData,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadChild();
    }
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'healthy':
        return const Color(0xFF4CAF50);

      case 'moderate':
      case 'needs attention':
        return const Color(0xFFFF9800);

      case 'severe':
      case 'under treatment':
        return const Color(0xFFF44336);

      default:
        return Colors.grey;
    }
  }

  // =========================
  // GENDER ICON
  // =========================

  IconData _getGenderIcon(String gender) {
    if (gender.toLowerCase() == 'female') {
      return Icons.girl;
    }

    if (gender.toLowerCase() == 'male') {
      return Icons.boy;
    }

    return Icons.person;
  }

  // =========================
  // SAFE VALUE
  // =========================

  String _value(
    String key, {
    String defaultValue = 'Not provided',
  }) {
    final value = childData?[key];

    if (value == null || value.toString().trim().isEmpty) {
      return defaultValue == 'Not provided' ? _t('notProvided') : defaultValue;
    }

    return value.toString();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFBF8),
        appBar: AppBar(
          title: Text(
            _t('childDetails'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF45170),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFBF8),
        appBar: AppBar(
          title: Text(
            _t('childDetails'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _errorState(),
      );
    }

    final data = childData ?? {};

    final String name = (data['name'] ?? widget.childName).toString();

    final String age = (data['age'] ?? widget.age).toString();

    final String gender = (data['gender'] ?? widget.gender).toString();

    final String growthStatus = (data['growthStatus'] ?? 'Normal').toString();

    final String nutritionStatus =
        (data['nutritionStatus'] ?? 'Normal').toString();

    final String healthStatus =
        (data['healthStatus'] ?? widget.status).toString();

    final Color statusColor = _getStatusColor(healthStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t('childDetails'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _editChild,
            tooltip: _t('editChild'),
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF45170),
        onRefresh: _loadChild,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // =========================
              // CHILD PROFILE
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFFFE1E7),
                      child: Icon(
                        _getGenderIcon(gender),
                        size: 52,
                        color: const Color(0xFFF45170),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29266F),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$age ${_t('years')} • ${_localizedGender(gender)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _localizedStatus(healthStatus),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _editChild,
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label: Text(
                          _t('editChildDetails').toUpperCase(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // BASIC INFORMATION
              // =========================

              _buildSectionTitle(
                _t('basicInformation'),
              ),

              const SizedBox(height: 10),

              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    _t('childName'),
                    name,
                  ),
                  _buildInfoRow(
                    _t('dateOfBirth'),
                    _value('dateOfBirth'),
                  ),
                  _buildInfoRow(
                    _t('age'),
                    '$age ${_t('years')}',
                  ),
                  _buildInfoRow(
                    _t('gender'),
                    _localizedGender(gender),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // PARENT INFORMATION
              // =========================

              _buildSectionTitle(
                _t('parentGuardianInformation'),
              ),

              const SizedBox(height: 10),

              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    _t('mothersName'),
                    _value('motherName'),
                  ),
                  _buildInfoRow(
                    _t('mothersContact'),
                    _value('motherContact'),
                  ),
                  _buildInfoRow(
                    _t('fathersName'),
                    _value('fatherName'),
                  ),
                  _buildInfoRow(
                    _t('fathersContact'),
                    _value('fatherContact'),
                  ),
                  _buildInfoRow(
                    _t('guardiansName'),
                    _value('guardianName'),
                  ),
                  _buildInfoRow(
                    _t('address'),
                    _value('address'),
                  ),
                  _buildInfoRow(
                    _t('anganwadiCenter'),
                    _value('anganwadiCenter'),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // GROWTH INFORMATION
              // =========================

              _buildSectionTitle(
                _t('growthInformation'),
              ),

              const SizedBox(height: 10),

              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    _t('height'),
                    _formatMeasurement(
                      data['height'],
                      'cm',
                    ),
                  ),
                  _buildInfoRow(
                    _t('weight'),
                    _formatMeasurement(
                      data['weight'],
                      'kg',
                    ),
                  ),
                  _buildInfoRow(
                    _t('bmi'),
                    _formatMeasurement(
                      data['bmi'],
                      '',
                    ),
                  ),
                  _buildInfoRow(
                    _t('muac'),
                    _formatMeasurement(
                      data['muac'],
                      'cm',
                    ),
                  ),
                  _buildInfoRow(
                    _t('growthStatus'),
                    _localizedStatus(growthStatus),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // NUTRITION INFORMATION
              // =========================

              _buildSectionTitle(
                _t('nutritionInformation'),
              ),

              const SizedBox(height: 10),

              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    _t('nutritionStatus'),
                    _localizedStatus(
                      nutritionStatus,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // HEALTH INFORMATION
              // =========================

              _buildSectionTitle(
                _t('healthInformation'),
              ),

              const SizedBox(height: 10),

              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    _t('healthStatus'),
                    _localizedStatus(healthStatus),
                  ),
                  _buildInfoRow(
                    _t('lastCheckup'),
                    _value('lastCheckup'),
                  ),
                  _buildInfoRow(
                    _t('nextCheckup'),
                    _value('nextCheckup'),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // MEDICAL NOTES
              // =========================

              _buildSectionTitle(
                _t('medicalNotes'),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  _value(
                    'medicalNotes',
                    defaultValue: _t('noMedicalNotesAvailable'),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =========================
              // HEALTH & GROWTH MODULES
              // =========================

              _buildSectionTitle(
                _t('healthAndGrowth'),
              ),

              const SizedBox(height: 10),

              _buildMenuCard(
                context,
                icon: Icons.show_chart,
                title: _t('growthMonitoring'),
                subtitle: _t('viewHeightWeightGrowth'),
                page: GrowthScreen(
                  childId: widget.childId,
                  childName: name,
                ),
              ),

              const SizedBox(height: 10),

              _buildMenuCard(
                context,
                icon: Icons.restaurant_outlined,
                title: _t('nutrition'),
                subtitle: _t('nutritionAndDietInformation'),
                page: NutritionScreen(
                  childName: name,
                ),
              ),

              const SizedBox(height: 10),

              _buildMenuCard(
                context,
                icon: Icons.medical_services_outlined,
                title: _t('healthAndVaccination'),
                subtitle: _t('healthRecordsAndVaccinations'),
                page: HealthScreen(
                  childId: widget.childId,
                  childName: name,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF29266F),
        ),
      ),
    );
  }

  // =========================
  // INFO CARD
  // =========================

  Widget _buildInfoCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // =========================
  // INFO ROW
  // =========================

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF29266F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MEASUREMENT FORMAT
  // =========================

  String _formatMeasurement(
    dynamic value,
    String unit,
  ) {
    if (value == null) {
      return _t('notRecorded');
    }

    final number = double.tryParse(
      value.toString(),
    );

    if (number == null) {
      return '$value$unit';
    }

    final formatted =
        number % 1 == 0 ? number.toInt().toString() : number.toStringAsFixed(2);

    if (unit.isEmpty) {
      return formatted;
    }

    return '$formatted $unit';
  }

  // =========================
  // MENU CARD
  // =========================

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF45170),
                size: 25,
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
                      color: Color(0xFF29266F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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

  // =========================
  // ERROR STATE
  // =========================

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 15),
            Text(
              _t('unableToLoadChild'),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29266F),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage ?? _t('unknownDatabaseError'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadChild,
              icon: const Icon(
                Icons.refresh,
              ),
              label: Text(
                _t('tryAgain'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
