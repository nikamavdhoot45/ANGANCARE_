import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class GrowthScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const GrowthScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  late Future<Map<String, dynamic>?> _childDataFuture;
  late Future<List<Map<String, dynamic>>> _growthRecordsFuture;
  late Future<Map<String, dynamic>> _screenDataFuture;

  String _t(
    BuildContext context,
    String english,
    String marathi,
    String hindi,
  ) {
    final languageCode = AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') return marathi;
    if (languageCode == 'hi') return hindi;
    return english;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _childDataFuture = _getChildData();
    _growthRecordsFuture = _getGrowthRecords();

    _screenDataFuture = Future.wait<dynamic>([
      _childDataFuture,
      _growthRecordsFuture,
    ]).then(
      (values) => {
        'childData': values[0],
        'records': values[1],
      },
    );
  }

  Future<Map<String, dynamic>?> _getChildData() async {
    final document = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  Future<List<Map<String, dynamic>>> _getGrowthRecords() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .collection('growthRecords')
        .get();

    final records = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    records.sort((a, b) {
      final aDate = _toDate(a['createdAt'] ?? a['date']);
      final bDate = _toDate(b['createdAt'] ?? b['date']);

      return bDate.compareTo(aDate);
    });

    return records;
  }

  DateTime _toDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
          value?.toString() ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value != null) {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) {
      return _t(
        context,
        'No Date',
        'तारीख नाही',
        'कोई तारीख नहीं',
      );
    }

    final languageCode = AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') {
      const months = [
        'जानेवारी',
        'फेब्रुवारी',
        'मार्च',
        'एप्रिल',
        'मे',
        'जून',
        'जुलै',
        'ऑगस्ट',
        'सप्टेंबर',
        'ऑक्टोबर',
        'नोव्हेंबर',
        'डिसेंबर',
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    if (languageCode == 'hi') {
      const months = [
        'जनवरी',
        'फरवरी',
        'मार्च',
        'अप्रैल',
        'मई',
        'जून',
        'जुलाई',
        'अगस्त',
        'सितंबर',
        'अक्टूबर',
        'नवंबर',
        'दिसंबर',
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Map<String, double> _getExpectedRange(
    double age,
    String type,
  ) {
    if (type == 'weight') {
      if (age < 0.5) {
        return {'min': 2.5, 'max': 8.5};
      } else if (age < 1) {
        return {'min': 5.7, 'max': 12.0};
      } else if (age < 2) {
        return {'min': 7.7, 'max': 15.3};
      } else if (age < 3) {
        return {'min': 9.7, 'max': 18.3};
      } else if (age < 4) {
        return {'min': 10.8, 'max': 21.8};
      } else if (age < 5) {
        return {'min': 12.3, 'max': 24.9};
      } else {
        return {'min': 14.0, 'max': 27.5};
      }
    }

    if (age < 0.5) {
      return {'min': 45.0, 'max': 68.0};
    } else if (age < 1) {
      return {'min': 60.0, 'max': 82.0};
    } else if (age < 2) {
      return {'min': 69.0, 'max': 93.0};
    } else if (age < 3) {
      return {'min': 81.0, 'max': 104.0};
    } else if (age < 4) {
      return {'min': 88.0, 'max': 112.0};
    } else if (age < 5) {
      return {'min': 94.0, 'max': 120.0};
    } else {
      return {'min': 100.0, 'max': 127.0};
    }
  }

  double _getChildAge(Map<String, dynamic> childData) {
    final ageValue = childData['age'];

    if (ageValue is num) {
      return ageValue.toDouble();
    }

    if (ageValue != null) {
      final ageText = ageValue.toString().toLowerCase();

      final numberMatch = RegExp(
        r'(\d+(?:\.\d+)?)',
      ).firstMatch(ageText);

      if (numberMatch != null) {
        final value = double.tryParse(numberMatch.group(1)!);

        if (value != null) {
          if (ageText.contains('month')) {
            return value / 12;
          }

          return value;
        }
      }
    }

    return 0;
  }

  String _getGrowthAssessment(
    double value,
    double min,
    double max,
  ) {
    if (value < min) {
      return _t(
        context,
        'Below Expected',
        'अपेक्षितपेक्षा कमी',
        'अपेक्षा से कम',
      );
    }

    if (value > max) {
      return _t(
        context,
        'Above Expected',
        'अपेक्षितपेक्षा जास्त',
        'अपेक्षा से अधिक',
      );
    }

    return _t(
      context,
      'Within Expected Range',
      'अपेक्षित श्रेणीत',
      'अपेक्षित सीमा में',
    );
  }

  Color _getAssessmentColor(
    double value,
    double min,
    double max,
  ) {
    if (value < min || value > max) {
      return const Color(0xFFFF9800);
    }

    return const Color(0xFF4CAF50);
  }

  Widget _buildGrowthAssessmentCard({
    required String title,
    required String value,
    required String expected,
    required String assessment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_t(
                    context,
                    'Current',
                    'सध्याचे',
                    'वर्तमान',
                  )}: $value',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_t(
                    context,
                    'Expected',
                    'अपेक्षित',
                    'अपेक्षित',
                  )}: $expected',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  assessment,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
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

  Future<void> _addGrowthRecord() async {
    final heightController = TextEditingController();
    final weightController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    bool isSaving = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                _t(
                  context,
                  'Add Growth Record',
                  'वाढीची नोंद जोडा',
                  'विकास रिकॉर्ड जोड़ें',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Height (cm)',
                          'उंची (सेमी)',
                          'ऊंचाई (सेमी)',
                        ),
                        hintText: _t(
                          context,
                          'Example: 98',
                          'उदाहरण: 98',
                          'उदाहरण: 98',
                        ),
                        prefixIcon: const Icon(Icons.height),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Weight (kg)',
                          'वजन (किलो)',
                          'वज़न (किलो)',
                        ),
                        hintText: _t(
                          context,
                          'Example: 14.5',
                          'उदाहरण: 14.5',
                          'उदाहरण: 14.5',
                        ),
                        prefixIcon: const Icon(
                          Icons.monitor_weight_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null && dialogContext.mounted) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _t(
                            context,
                            'Date',
                            'तारीख',
                            'तारीख',
                          ),
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        child: Text(
                          _formatDate(selectedDate),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                  child: Text(
                    _t(
                      context,
                      'Cancel',
                      'रद्द करा',
                      'रद्द करें',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (isSaving) return;

                          setDialogState(() {
                            isSaving = true;
                          });

                          final heightText = heightController.text.trim();

                          final weightText = weightController.text.trim();

                          if (heightText.isEmpty || weightText.isEmpty) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _t(
                                    context,
                                    'Please enter height and weight.',
                                    'कृपया उंची आणि वजन भरा.',
                                    'कृपया ऊंचाई और वज़न भरें।',
                                  ),
                                ),
                              ),
                            );

                            return;
                          }

                          final height = double.tryParse(heightText);

                          final weight = double.tryParse(weightText);

                          if (height == null || weight == null) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _t(
                                    context,
                                    'Please enter valid numbers.',
                                    'कृपया योग्य संख्या भरा.',
                                    'कृपया सही संख्या भरें।',
                                  ),
                                ),
                              ),
                            );

                            return;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection('children')
                                .doc(widget.childId)
                                .collection('growthRecords')
                                .add({
                              'height': height,
                              'weight': weight,
                              'date': Timestamp.fromDate(selectedDate),
                              'createdAt': Timestamp.fromDate(DateTime.now()),
                            });

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!dialogContext.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${_t(
                                    context,
                                    'Unable to save growth record',
                                    'वाढीची नोंद जतन करता आली नाही',
                                    'विकास रिकॉर्ड सहेजने में असमर्थ',
                                  )}: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: Text(
                    _t(
                      context,
                      'Save',
                      'जतन करा',
                      'सहेजें',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    heightController.dispose();
    weightController.dispose();

    if (result == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _loadData();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'Growth record added successfully.',
                'वाढीची नोंद यशस्वीरित्या जोडली.',
                'विकास रिकॉर्ड सफलतापूर्वक जोड़ा गया।',
              ),
            ),
          ),
        );
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });

    await _childDataFuture;
    await _growthRecordsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t(
            context,
            'Growth Monitoring',
            'वाढ निरीक्षण',
            'विकास निगरानी',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGrowthRecord,
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          _t(
            context,
            'Add Growth',
            'वाढ जोडा',
            'विकास जोड़ें',
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _screenDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF45170),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${_t(
                    context,
                    'Unable to load growth data.',
                    'वाढीची माहिती लोड करता आली नाही.',
                    'विकास की जानकारी लोड नहीं हो सकी।',
                  )}\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data ?? <String, dynamic>{};

          final childData = (data['childData'] as Map<String, dynamic>?) ??
              <String, dynamic>{};

          final records = (data['records'] as List<Map<String, dynamic>>?) ??
              <Map<String, dynamic>>[];

          Map<String, dynamic>? latestRecord;

          if (records.isNotEmpty) {
            latestRecord = records.first;
          }

          final String height =
              (latestRecord?['height'] ?? childData['height'] ?? '0')
                  .toString();

          final String weight =
              (latestRecord?['weight'] ?? childData['weight'] ?? '0')
                  .toString();

          final String growthStatus = (childData['growthStatus'] ??
                  childData['growth_status'] ??
                  'Normal')
              .toString();

          double growthProgress = 0.72;

          final progressValue =
              childData['growthProgress'] ?? latestRecord?['growthProgress'];

          if (progressValue is num) {
            growthProgress = progressValue.toDouble();

            if (growthProgress > 1) {
              growthProgress = growthProgress / 100;
            }

            growthProgress = growthProgress.clamp(0.0, 1.0).toDouble();
          }

          Color statusColor;

          if (growthStatus.toLowerCase() == 'normal') {
            statusColor = const Color(0xFF4CAF50);
          } else if (growthStatus.toLowerCase() == 'moderate') {
            statusColor = const Color(0xFFFF9800);
          } else {
            statusColor = const Color(0xFFF44336);
          }

          final localizedGrowthStatus = growthStatus.toLowerCase() == 'normal'
              ? _t(
                  context,
                  'Normal',
                  'सामान्य',
                  'सामान्य',
                )
              : growthStatus.toLowerCase() == 'moderate'
                  ? _t(
                      context,
                      'Moderate',
                      'मध्यम',
                      'मध्यम',
                    )
                  : _t(
                      context,
                      'Severe',
                      'गंभीर',
                      'गंभीर',
                    );

          final childAge = _getChildAge(childData);

          final heightValue = double.tryParse(
            height.replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            ),
          );

          final weightValue = double.tryParse(
            weight.replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            ),
          );

          final heightRange = _getExpectedRange(
            childAge,
            'height',
          );

          final weightRange = _getExpectedRange(
            childAge,
            'weight',
          );

          final heightAssessment = heightValue == null || heightValue == 0
              ? _t(
                  context,
                  'No height data',
                  'उंचीची माहिती नाही',
                  'ऊंचाई की जानकारी नहीं',
                )
              : _getGrowthAssessment(
                  heightValue,
                  heightRange['min']!,
                  heightRange['max']!,
                );

          final weightAssessment = weightValue == null || weightValue == 0
              ? _t(
                  context,
                  'No weight data',
                  'वजनाची माहिती नाही',
                  'वज़न की जानकारी नहीं',
                )
              : _getGrowthAssessment(
                  weightValue,
                  weightRange['min']!,
                  weightRange['max']!,
                );

          final heightColor = heightValue == null || heightValue == 0
              ? Colors.grey
              : _getAssessmentColor(
                  heightValue,
                  heightRange['min']!,
                  heightRange['max']!,
                );

          final weightColor = weightValue == null || weightValue == 0
              ? Colors.grey
              : _getAssessmentColor(
                  weightValue,
                  weightRange['min']!,
                  weightRange['max']!,
                );

          return RefreshIndicator(
            color: const Color(0xFFF45170),
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFFFFE1E7),
                          child: Icon(
                            Icons.child_care,
                            color: Color(0xFFF45170),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.childName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _t(
                                  context,
                                  'Growth Monitoring',
                                  'वाढ निरीक्षण',
                                  'विकास निगरानी',
                                ),
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t(
                      context,
                      'Current Measurements',
                      'सध्याची मोजमापे',
                      'वर्तमान माप',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeasurementCard(
                          icon: Icons.height,
                          title: _t(
                            context,
                            'Height',
                            'उंची',
                            'ऊंचाई',
                          ),
                          value: height == '0' ? '-' : '$height cm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMeasurementCard(
                          icon: Icons.monitor_weight_outlined,
                          title: _t(
                            context,
                            'Weight',
                            'वजन',
                            'वज़न',
                          ),
                          value: weight == '0' ? '-' : '$weight kg',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t(
                      context,
                      'Growth Assessment',
                      'वाढ मूल्यांकन',
                      'विकास मूल्यांकन',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGrowthAssessmentCard(
                    title: _t(
                      context,
                      'Height',
                      'उंची',
                      'ऊंचाई',
                    ),
                    value: height == '0' ? '-' : '$height cm',
                    expected:
                        '${heightRange['min']!.toStringAsFixed(0)} - ${heightRange['max']!.toStringAsFixed(0)} cm',
                    assessment: heightAssessment,
                    color: heightColor,
                    icon: Icons.height,
                  ),
                  _buildGrowthAssessmentCard(
                    title: _t(
                      context,
                      'Weight',
                      'वजन',
                      'वज़न',
                    ),
                    value: weight == '0' ? '-' : '$weight kg',
                    expected:
                        '${weightRange['min']!.toStringAsFixed(1)} - ${weightRange['max']!.toStringAsFixed(1)} kg',
                    assessment: weightAssessment,
                    color: weightColor,
                    icon: Icons.monitor_weight_outlined,
                  ),
                  if (childAge > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_t(
                          context,
                          'Based on age',
                          'वयावर आधारित',
                          'आयु के आधार पर',
                        )}: ${childAge.toStringAsFixed(1)} ${_t(
                          context,
                          'years',
                          'वर्षे',
                          'वर्ष',
                        )}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    _t(
                      context,
                      'Growth Status',
                      'वाढीची स्थिती',
                      'विकास की स्थिति',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8F5E9,
                                ),
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Icon(
                                growthStatus.toLowerCase() == 'normal'
                                    ? Icons.check_circle_outline
                                    : Icons.info_outline,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$localizedGrowthStatus ${_t(
                                      context,
                                      'Growth',
                                      'वाढ',
                                      'विकास',
                                    )}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    growthStatus.toLowerCase() == 'normal'
                                        ? _t(
                                            context,
                                            'Growth is within normal range',
                                            'वाढ सामान्य श्रेणीत आहे',
                                            'विकास सामान्य सीमा में है',
                                          )
                                        : _t(
                                            context,
                                            'Growth needs attention',
                                            'वाढीकडे लक्ष देणे आवश्यक आहे',
                                            'विकास पर ध्यान देने की आवश्यकता है',
                                          ),
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
                        const SizedBox(height: 20),
                        Text(
                          _t(
                            context,
                            'Growth Progress',
                            'वाढीची प्रगती',
                            'विकास की प्रगति',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: growthProgress,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _t(
                                context,
                                'Below',
                                'कमी',
                                'कम',
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _t(
                                context,
                                'Normal',
                                'सामान्य',
                                'सामान्य',
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _t(
                                context,
                                'High',
                                'जास्त',
                                'अधिक',
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _t(
                          context,
                          'Growth History',
                          'वाढीचा इतिहास',
                          'विकास इतिहास',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (records.isNotEmpty)
                        Text(
                          '${records.length} ${_t(
                            context,
                            records.length == 1 ? 'record' : 'records',
                            records.length == 1 ? 'नोंद' : 'नोंदी',
                            records.length == 1 ? 'रिकॉर्ड' : 'रिकॉर्ड',
                          )}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${_t(
                            context,
                            'No growth records found.',
                            'वाढीच्या नोंदी आढळल्या नाहीत.',
                            'विकास रिकॉर्ड नहीं मिले।',
                          )}\n${_t(
                            context,
                            'Tap "Add Growth" to add the first measurement.',
                            '"वाढ जोडा" वर टॅप करून पहिली नोंद जोडा.',
                            'पहला माप जोड़ने के लिए "विकास जोड़ें" पर टैप करें।',
                          )}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...records.map(
                      (record) {
                        final recordHeight =
                            (record['height'] ?? '0').toString();

                        final recordWeight =
                            (record['weight'] ?? '0').toString();

                        return _buildRecord(
                          date: _formatDate(
                            record['date'] ?? record['createdAt'],
                          ),
                          height: recordHeight.contains('cm')
                              ? recordHeight
                              : '$recordHeight cm',
                          weight: recordWeight.contains('kg')
                              ? recordWeight
                              : '$recordWeight kg',
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFF45170),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecord({
    required String date,
    required String height,
    required String weight,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFFF45170),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
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
}
