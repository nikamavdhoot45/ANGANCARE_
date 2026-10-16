import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../localization/app_localizations.dart';

class HealthScreen extends StatefulWidget {
  final String childName;
  final String? childId;

  const HealthScreen({
    super.key,
    required this.childName,
    this.childId,
  });

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool isLoading = true;
  bool isUploadingReport = false;
  bool isUploadingVaccinationReport = false;

  String? _resolvedChildId;

  Map<String, dynamic>? childData;

  List<Map<String, dynamic>> healthRecords = [];
  List<Map<String, dynamic>> vaccinationRecords = [];
  List<Map<String, dynamic>> healthReports = [];
  List<Map<String, dynamic>> vaccinationReports = [];

  String _t(
      BuildContext context,
      String english,
      String marathi,
      String hindi,
      ) {
    final languageCode =
        AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') return marathi;
    if (languageCode == 'hi') return hindi;
    return english;
  }

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? id = widget.childId;

      DocumentSnapshot<Map<String, dynamic>>? childDocument;

      if (id != null && id.trim().isNotEmpty) {
        final document =
        await _firestore.collection('children').doc(id).get();

        if (document.exists) {
          childDocument = document;
        }
      }

      if (childDocument == null) {
        final query = await _firestore
            .collection('children')
            .where(
          'name',
          isEqualTo: widget.childName,
        )
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          childDocument = query.docs.first;
          id = childDocument.id;
        }
      }

      if (childDocument == null || id == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          _resolvedChildId = null;
          childData = null;
          healthRecords = [];
          vaccinationRecords = [];
          healthReports = [];
          vaccinationReports = [];
        });

        return;
      }

      _resolvedChildId = id;
      childData = childDocument.data();

      final childRef = _firestore.collection('children').doc(id);

      final List<QuerySnapshot<Map<String, dynamic>>> results =
      await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
        childRef.collection('healthRecords').get(),
        childRef.collection('vaccinationRecords').get(),
        childRef.collection('healthReports').get(),
        childRef.collection('vaccinationReports').get(),
      ]);

      final healthSnapshot = results[0];
      final vaccinationSnapshot = results[1];
      final reportsSnapshot = results[2];
      final vaccinationReportsSnapshot = results[3];

      final loadedHealthRecords =
      healthSnapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['recordId'] = doc.id;
        return data;
      }).toList();

      loadedHealthRecords.sort((a, b) {
        return _getDate(b).compareTo(_getDate(a));
      });

      final loadedVaccinationRecords =
      vaccinationSnapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['recordId'] = doc.id;
        return data;
      }).toList();

      loadedVaccinationRecords.sort((a, b) {
        return _getDate(b).compareTo(_getDate(a));
      });

      final loadedReports =
      reportsSnapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['reportId'] = doc.id;
        return data;
      }).toList();

      loadedReports.sort((a, b) {
        return _getDate(b).compareTo(_getDate(a));
      });

      final loadedVaccinationReports =
      vaccinationReportsSnapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['reportId'] = doc.id;
        return data;
      }).toList();

      loadedVaccinationReports.sort((a, b) {
        return _getDate(b).compareTo(_getDate(a));
      });

      if (!mounted) return;

      setState(() {
        healthRecords = loadedHealthRecords;
        vaccinationRecords = loadedVaccinationRecords;
        healthReports = loadedReports;
        vaccinationReports = loadedVaccinationReports;
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
              'Unable to load health data',
              'आरोग्याची माहिती लोड करता आली नाही',
              'स्वास्थ्य जानकारी लोड नहीं हो सकी',
            )}: $e',
          ),
        ),
      );
    }
  }

  DateTime _getDate(Map<String, dynamic> data) {
    final value = data['date'] ??
        data['checkupDate'] ??
        data['uploadedAt'] ??
        data['createdAt'];

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime(2000);
    }

    return DateTime(2000);
  }

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return _t(
        context,
        'Date not available',
        'तारीख उपलब्ध नाही',
        'तारीख उपलब्ध नहीं',
      );
    }

    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    final languageCode =
        AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') {
      const months = [
        '',
        'जाने',
        'फेब्रु',
        'मार्च',
        'एप्रिल',
        'मे',
        'जून',
        'जुलै',
        'ऑग',
        'सप्टें',
        'ऑक्टो',
        'नोव्हें',
        'डिसें',
      ];
      return months[month];
    }

    if (languageCode == 'hi') {
      const months = [
        '',
        'जन',
        'फर',
        'मार्च',
        'अप्रैल',
        'मई',
        'जून',
        'जुला',
        'अग',
        'सितं',
        'अक्टू',
        'नवं',
        'दिसं',
      ];
      return months[month];
    }

    const months = [
      '',
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

    return months[month];
  }

  String _localizedStatus(String status) {
    final value = status.toLowerCase();

    if (value == 'healthy') {
      return _t(
        context,
        'Healthy',
        'निरोगी',
        'स्वस्थ',
      );
    }

    if (value == 'needs attention') {
      return _t(
        context,
        'Needs Attention',
        'लक्ष देणे आवश्यक',
        'ध्यान देने की आवश्यकता',
      );
    }

    if (value == 'moderate') {
      return _t(
        context,
        'Moderate',
        'मध्यम',
        'मध्यम',
      );
    }

    if (value == 'severe') {
      return _t(
        context,
        'Severe',
        'गंभीर',
        'गंभीर',
      );
    }

    if (value == 'completed') {
      return _t(
        context,
        'Completed',
        'पूर्ण',
        'पूर्ण',
      );
    }

    return status;
  }

  String _latestHealthStatus() {
    if (healthRecords.isEmpty) {
      return _t(
        context,
        'No Record',
        'नोंद नाही',
        'कोई रिकॉर्ड नहीं',
      );
    }

    final record = healthRecords.first;

    return (record['status'] ??
        record['healthStatus'] ??
        record['condition'] ??
        'Recorded')
        .toString();
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('severe') ||
        value.contains('critical')) {
      return const Color(0xFFF44336);
    }

    if (value.contains('attention') ||
        value.contains('moderate') ||
        value.contains('fever') ||
        value.contains('cold') ||
        value.contains('sick')) {
      return const Color(0xFFFF9800);
    }

    if (value.contains('healthy') ||
        value.contains('normal') ||
        value.contains('good')) {
      return const Color(0xFF4CAF50);
    }

    return const Color(0xFF2196F3);
  }

  Color _statusBackground(String status) {
    final value = status.toLowerCase();

    if (value.contains('healthy') ||
        value.contains('normal') ||
        value.contains('good')) {
      return const Color(0xFFE8F5E9);
    }

    if (value.contains('attention') ||
        value.contains('moderate') ||
        value.contains('fever') ||
        value.contains('cold') ||
        value.contains('sick')) {
      return const Color(0xFFFFF3E0);
    }

    if (value.contains('severe') ||
        value.contains('critical')) {
      return const Color(0xFFFFEBEE);
    }

    return const Color(0xFFE3F2FD);
  }

  Future<void> _addHealthRecord() async {
    if (_resolvedChildId == null ||
        _resolvedChildId!.isEmpty) {
      await _loadHealthData();

      if (_resolvedChildId == null ||
          _resolvedChildId!.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'Child record could not be found in Firestore.',
                'Firestore मध्ये मुलाची नोंद सापडली नाही.',
                'Firestore में बच्चे का रिकॉर्ड नहीं मिला।',
              ),
            ),
          ),
        );

        return;
      }
    }

    final conditionController = TextEditingController();
    final temperatureController = TextEditingController();
    final notesController = TextEditingController();

    String selectedStatus = 'Healthy';
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                _t(
                  dialogContext,
                  'Add Health Record',
                  'आरोग्याची नोंद जोडा',
                  'स्वास्थ्य रिकॉर्ड जोड़ें',
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
                      controller: conditionController,
                      decoration: InputDecoration(
                        labelText: _t(
                          dialogContext,
                          'Condition',
                          'स्थिती',
                          'स्थिति',
                        ),
                        hintText: _t(
                          dialogContext,
                          'Fever, Cold, Healthy, etc.',
                          'ताप, सर्दी, निरोगी इ.',
                          'बुखार, सर्दी, स्वस्थ आदि।',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: temperatureController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _t(
                          dialogContext,
                          'Temperature',
                          'तापमान',
                          'तापमान',
                        ),
                        hintText: _t(
                          dialogContext,
                          'Example: 101°F',
                          'उदाहरण: 101°F',
                          'उदाहरण: 101°F',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: _t(
                          dialogContext,
                          'Health Status',
                          'आरोग्य स्थिती',
                          'स्वास्थ्य स्थिति',
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Healthy',
                          child: Text(
                            _localizedStatus('Healthy'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Needs Attention',
                          child: Text(
                            _localizedStatus('Needs Attention'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Moderate',
                          child: Text(
                            _localizedStatus('Moderate'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Severe',
                          child: Text(
                            _localizedStatus('Severe'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked == null) return;

                        if (!dialogContext.mounted) return;

                        setDialogState(() {
                          selectedDate = picked;
                        });
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _t(
                            dialogContext,
                            'Date',
                            'तारीख',
                            'तारीख',
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        child: Text(
                          _formatDate(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: _t(
                          dialogContext,
                          'Notes',
                          'नोंदी',
                          'टिप्पणियाँ',
                        ),
                        hintText: _t(
                          dialogContext,
                          'Additional information',
                          'अतिरिक्त माहिती',
                          'अतिरिक्त जानकारी',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    _t(
                      dialogContext,
                      'Cancel',
                      'रद्द करा',
                      'रद्द करें',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final condition =
                    conditionController.text.trim();

                    if (condition.isEmpty) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              dialogContext,
                              'Please enter the condition.',
                              'कृपया स्थिती प्रविष्ट करा.',
                              'कृपया स्थिति दर्ज करें।',
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    final currentId = _resolvedChildId;

                    if (currentId == null ||
                        currentId.isEmpty) {
                      return;
                    }

                    try {
                      await _firestore
                          .collection('children')
                          .doc(currentId)
                          .collection('healthRecords')
                          .add({
                        'condition': condition,
                        'temperature':
                        temperatureController.text.trim(),
                        'status': selectedStatus,
                        'date': Timestamp.fromDate(selectedDate),
                        'notes': notesController.text.trim(),
                        'createdAt':
                        Timestamp.fromDate(DateTime.now()),
                      });

                      if (!dialogContext.mounted) return;

                      Navigator.of(dialogContext).pop();

                      await _loadHealthData();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              context,
                              'Health record added successfully.',
                              'आरोग्याची नोंद यशस्वीरित्या जोडली.',
                              'स्वास्थ्य रिकॉर्ड सफलतापूर्वक जोड़ा गया।',
                            ),
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${_t(
                              dialogContext,
                              'Unable to save health record',
                              'आरोग्याची नोंद जतन करता आली नाही',
                              'स्वास्थ्य रिकॉर्ड सहेजा नहीं जा सका',
                            )}: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _t(
                      dialogContext,
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

    conditionController.dispose();
    temperatureController.dispose();
    notesController.dispose();
  }

  Future<void> _showHealthReportOptions() async {
    await _showUploadOptions(
      title: _t(
        context,
        'Upload Health Report',
        'आरोग्य अहवाल अपलोड करा',
        'स्वास्थ्य रिपोर्ट अपलोड करें',
      ),
      onCamera: _pickHealthReportFromCamera,
      onGallery: _pickHealthReportFromGallery,
      onFile: _pickHealthReportFile,
    );
  }

  Future<void> _showVaccinationReportOptions() async {
    await _showUploadOptions(
      title: _t(
        context,
        'Upload Vaccination Report',
        'लसीकरण अहवाल अपलोड करा',
        'टीकाकरण रिपोर्ट अपलोड करें',
      ),
      onCamera: _pickVaccinationReportFromCamera,
      onGallery: _pickVaccinationReportFromGallery,
      onFile: _pickVaccinationReportFile,
    );
  }

  Future<void> _showUploadOptions({
    required String title,
    required Future<void> Function() onCamera,
    required Future<void> Function() onGallery,
    required Future<void> Function() onFile,
  }) async {
    if (_resolvedChildId == null ||
        _resolvedChildId!.isEmpty) {
      await _loadHealthData();
    }

    if (_resolvedChildId == null ||
        _resolvedChildId!.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Child record could not be found.',
              'मुलाची नोंद सापडली नाही.',
              'बच्चे का रिकॉर्ड नहीं मिला।',
            ),
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildUploadOption(
                    icon: Icons.camera_alt,
                    title: _t(
                      context,
                      'Camera',
                      'कॅमेरा',
                      'कैमरा',
                    ),
                    subtitle: _t(
                      context,
                      'Take a photo of the report',
                      'अहवालाचा फोटो घ्या',
                      'रिपोर्ट की फोटो लें',
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await onCamera();
                    },
                  ),
                  _buildUploadOption(
                    icon: Icons.photo_library,
                    title: _t(
                      context,
                      'Gallery',
                      'गॅलरी',
                      'गैलरी',
                    ),
                    subtitle: _t(
                      context,
                      'Choose a report image',
                      'अहवालाची प्रतिमा निवडा',
                      'रिपोर्ट की छवि चुनें',
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await onGallery();
                    },
                  ),
                  _buildUploadOption(
                    icon: Icons.insert_drive_file,
                    title: _t(
                      context,
                      'File',
                      'फाइल',
                      'फ़ाइल',
                    ),
                    subtitle: _t(
                      context,
                      'Choose PDF or image',
                      'PDF किंवा प्रतिमा निवडा',
                      'PDF या छवि चुनें',
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await onFile();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1E7),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF45170),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
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
    );
  }

  Future<void> _pickHealthReportFromCamera() async {
    await _pickImageReport(
      source: ImageSource.camera,
      reportType: 'health',
    );
  }

  Future<void> _pickHealthReportFromGallery() async {
    await _pickImageReport(
      source: ImageSource.gallery,
      reportType: 'health',
    );
  }

  Future<void> _pickHealthReportFile() async {
    await _pickFileReport(
      reportType: 'health',
    );
  }

  Future<void> _pickVaccinationReportFromCamera() async {
    await _pickImageReport(
      source: ImageSource.camera,
      reportType: 'vaccination',
    );
  }

  Future<void> _pickVaccinationReportFromGallery() async {
    await _pickImageReport(
      source: ImageSource.gallery,
      reportType: 'vaccination',
    );
  }

  Future<void> _pickVaccinationReportFile() async {
    await _pickFileReport(
      reportType: 'vaccination',
    );
  }

  Future<void> _pickImageReport({
    required ImageSource source,
    required String reportType,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      final imageFile = File(image.path);

      if (!await imageFile.exists()) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'Selected image could not be accessed.',
                'निवडलेल्या प्रतिमेमध्ये प्रवेश करता आला नाही.',
                'चयनित इमेज तक पहुँचा नहीं जा सका।',
              ),
            ),
          ),
        );

        return;
      }

      final prefix = reportType == 'vaccination'
          ? 'vaccination_report'
          : 'health_report';

      await _uploadReport(
        imageFile,
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        reportType,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Could not open image source',
              'प्रतिमा स्रोत उघडता आला नाही',
              'इमेज स्रोत खोला नहीं जा सका',
            )}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _pickFileReport({
    required String reportType,
  }) async {
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'webp',
        ],
      );

      if (file == null) return;

      if (file.path == null || file.path!.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'Unable to access the selected file.',
                'निवडलेल्या फाइलमध्ये प्रवेश करता आला नाही.',
                'चयनित फ़ाइल तक पहुँचा नहीं जा सका।',
              ),
            ),
          ),
        );

        return;
      }

      final selectedFile = File(file.path!);

      if (!await selectedFile.exists()) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'The selected file does not exist.',
                'निवडलेली फाइल उपलब्ध नाही.',
                'चयनित फ़ाइल उपलब्ध नहीं है।',
              ),
            ),
          ),
        );

        return;
      }

      await _uploadReport(
        selectedFile,
        file.name,
        reportType,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'File picker error',
              'फाइल निवड त्रुटी',
              'फ़ाइल चयन त्रुटि',
            )}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _uploadReport(
      File file,
      String fileName,
      String reportType,
      ) async {
    final id = _resolvedChildId;

    if (id == null || id.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Child ID is missing.',
              'मुलाचा ID उपलब्ध नाही.',
              'बच्चे की ID उपलब्ध नहीं है।',
            ),
          ),
        ),
      );

      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'You are not logged in to Firebase.',
              'तुम्ही Firebase मध्ये लॉगिन केलेले नाही.',
              'आप Firebase में लॉगिन नहीं हैं।',
            ),
          ),
        ),
      );

      return;
    }

    if (!await file.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Selected file could not be accessed.',
              'निवडलेल्या फाइलमध्ये प्रवेश करता आला नाही.',
              'चयनित फ़ाइल तक पहुँचा नहीं जा सका।',
            ),
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      if (reportType == 'vaccination') {
        isUploadingVaccinationReport = true;
      } else {
        isUploadingReport = true;
      }
    });

    try {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final safeFileName = fileName.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );

      final folder = reportType == 'vaccination'
          ? 'vaccinationReports'
          : 'healthReports';

      final storagePath =
          'children/$id/$folder/${timestamp}_$safeFileName';

      final storageRef =
      FirebaseStorage.instance.ref().child(storagePath);

      final contentType = _getContentType(fileName);

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'childId': id,
          'reportType': reportType,
          'uploadedBy': currentUser.uid,
        },
      );

      final uploadTask = storageRef.putFile(
        file,
        metadata,
      );

      final uploadSnapshot =
      await uploadTask;

      if (uploadSnapshot.state !=
          TaskState.success) {
        throw Exception(
          'Firebase Storage upload did not complete successfully.',
        );
      }

      final downloadUrl =
      await storageRef.getDownloadURL();

      final collectionName = reportType == 'vaccination'
          ? 'vaccinationReports'
          : 'healthReports';

      await _firestore
          .collection('children')
          .doc(id)
          .collection(collectionName)
          .add({
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'storagePath': storagePath,
        'fileType': _getFileType(fileName),
        'contentType': contentType,
        'reportType': reportType,
        'uploadedBy': currentUser.uid,
        'uploadedAt':
        Timestamp.fromDate(DateTime.now()),
      });

      await _loadHealthData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF4CAF50),
          content: Text(
            reportType == 'vaccination'
                ? _t(
              context,
              'Vaccination report uploaded successfully.',
              'लसीकरण अहवाल यशस्वीरित्या अपलोड झाला.',
              'टीकाकरण रिपोर्ट सफलतापूर्वक अपलोड हुआ।',
            )
                : _t(
              context,
              'Health report uploaded successfully.',
              'आरोग्य अहवाल यशस्वीरित्या अपलोड झाला.',
              'स्वास्थ्य रिपोर्ट सफलतापूर्वक अपलोड हुआ।',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();

      if (e is FirebaseException) {
        errorMessage =
        '${e.code}: ${e.message ?? 'Firebase error'}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(
            reportType == 'vaccination'
                ? '${_t(
              context,
              'Unable to upload vaccination report',
              'लसीकरण अहवाल अपलोड करता आला नाही',
              'टीकाकरण रिपोर्ट अपलोड नहीं हो सका',
            )}: $errorMessage'
                : '${_t(
              context,
              'Unable to upload health report',
              'आरोग्य अहवाल अपलोड करता आला नाही',
              'स्वास्थ्य रिपोर्ट अपलोड नहीं हुआ',
            )}: $errorMessage',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (reportType == 'vaccination') {
            isUploadingVaccinationReport = false;
          } else {
            isUploadingReport = false;
          }
        });
      }
    }
  }

  String _getContentType(String fileName) {
    final extension =
    fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'application/pdf';

      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      default:
        return 'application/octet-stream';
    }
  }

  String _getFileType(String fileName) {
    final extension =
    fileName.split('.').last.toLowerCase();

    return extension == 'pdf' ? 'PDF' : 'Image';
  }

  Widget _buildHealthRecordCard(
      Map<String, dynamic> record,
      ) {
    final status = (record['status'] ??
        record['healthStatus'] ??
        'Recorded')
        .toString();

    final condition =
    (record['condition'] ?? 'Health Checkup').toString();

    final temperature =
    (record['temperature'] ?? '').toString();

    final notes = (record['notes'] ?? '').toString();

    final date = _formatDate(
      record['date'] ??
          record['checkupDate'] ??
          record['createdAt'],
    );

    final color = _statusColor(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _localizedStatus(status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (temperature.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildHealthRow(
              _t(
                context,
                'Temperature',
                'तापमान',
                'तापमान',
              ),
              temperature,
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              notes,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(
      Map<String, dynamic> record,
      ) {
    final vaccine = (record['vaccine'] ??
        record['vaccineName'] ??
        record['name'] ??
        'Vaccination')
        .toString();

    final status = (record['status'] ??
        record['vaccinationStatus'] ??
        'Recorded')
        .toString();

    final date = _formatDate(
      record['date'] ??
          record['vaccinationDate'] ??
          record['createdAt'],
    );

    final completed = status.toLowerCase() == 'completed';

    final color = completed
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);

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
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              completed
                  ? Icons.check
                  : Icons.vaccines_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_localizedStatus(status)} • $date',
                  style: TextStyle(
                    color: color,
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

  Widget _buildHealthReportCard(
      Map<String, dynamic> report,
      ) {
    final fileName =
    (report['fileName'] ?? 'Health Report').toString();

    final fileType =
    (report['fileType'] ?? 'File').toString();

    final uploadedAt =
    _formatDate(report['uploadedAt']);

    final isPdf =
        fileType.toLowerCase() == 'pdf';

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
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE1E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf
                  : Icons.image_outlined,
              color: const Color(0xFFF45170),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileType • $uploadedAt',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationReportCard(
      Map<String, dynamic> report,
      ) {
    final fileName =
    (report['fileName'] ?? 'Vaccination Report').toString();

    final fileType =
    (report['fileType'] ?? 'File').toString();

    final uploadedAt =
    _formatDate(report['uploadedAt']);

    final isPdf =
        fileType.toLowerCase() == 'pdf';

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
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf
                  : Icons.vaccines_outlined,
              color: const Color(0xFF29266F),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileType • $uploadedAt',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFF45170),
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestStatus = _latestHealthStatus();

    final statusColor = _statusColor(latestStatus);

    final statusBackground = _statusBackground(
      latestStatus,
    );

    final localizedLatestStatus =
    _localizedStatus(latestStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t(
            context,
            'Health & Vaccination',
            'आरोग्य आणि लसीकरण',
            'स्वास्थ्य और टीकाकरण',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF45170),
        ),
      )
          : RefreshIndicator(
        color: const Color(0xFFF45170),
        onRefresh: _loadHealthData,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor:
                      Color(0xFFFFE1E7),
                      child: Icon(
                        Icons.child_care,
                        color: Color(0xFFF45170),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t(
                              context,
                              'Health Record',
                              'आरोग्य नोंद',
                              'स्वास्थ्य रिकॉर्ड',
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.childName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                _t(
                  context,
                  'Health Status',
                  'आरोग्य स्थिती',
                  'स्वास्थ्य स्थिति',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      latestStatus.toLowerCase() ==
                          'healthy'
                          ? Icons.check_circle
                          : Icons.health_and_safety,
                      color: statusColor,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedLatestStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            healthRecords.isEmpty
                                ? _t(
                              context,
                              'No health record added yet',
                              'अजून आरोग्याची नोंद जोडलेली नाही',
                              'अभी तक कोई स्वास्थ्य रिकॉर्ड नहीं जोड़ा गया',
                            )
                                : _t(
                              context,
                              'Latest health record',
                              'नवीनतम आरोग्य नोंद',
                              'नवीनतम स्वास्थ्य रिकॉर्ड',
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor
                                  .withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        'Recent Health Checkup',
                        'अलीकडील आरोग्य तपासणी',
                        'हाल की स्वास्थ्य जाँच',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addHealthRecord,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFF45170),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    label: Text(
                      _t(
                        context,
                        'Add',
                        'जोडा',
                        'जोड़ें',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (healthRecords.isEmpty)
                _buildEmptyCard(
                  icon: Icons
                      .medical_information_outlined,
                  title: _t(
                    context,
                    'No Health Records',
                    'आरोग्याच्या नोंदी नाहीत',
                    'कोई स्वास्थ्य रिकॉर्ड नहीं',
                  ),
                  message: _t(
                    context,
                    'Tap Add to create the child health record.',
                    'मुलाची आरोग्य नोंद तयार करण्यासाठी जोडा वर टॅप करा.',
                    'बच्चे का स्वास्थ्य रिकॉर्ड बनाने के लिए जोड़ें पर टैप करें।',
                  ),
                )
              else
                ...healthRecords.map(
                      (record) =>
                      _buildHealthRecordCard(record),
                ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        'Health Reports',
                        'आरोग्य अहवाल',
                        'स्वास्थ्य रिपोर्ट',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isUploadingReport
                        ? null
                        : _showHealthReportOptions,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFF45170),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon: isUploadingReport
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.upload_file,
                      size: 18,
                    ),
                    label: Text(
                      isUploadingReport
                          ? _t(
                        context,
                        'Uploading',
                        'अपलोड होत आहे',
                        'अपलोड हो रहा है',
                      )
                          : _t(
                        context,
                        'Upload',
                        'अपलोड',
                        'अपलोड',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (healthReports.isEmpty)
                _buildEmptyCard(
                  icon: Icons.description_outlined,
                  title: _t(
                    context,
                    'No Reports Uploaded',
                    'अहवाल अपलोड केलेले नाहीत',
                    'कोई रिपोर्ट अपलोड नहीं हुई',
                  ),
                  message: _t(
                    context,
                    'Upload a health report using Camera, Gallery, or File.',
                    'कॅमेरा, गॅलरी किंवा फाइल वापरून आरोग्य अहवाल अपलोड करा.',
                    'कैमरा, गैलरी या फ़ाइल का उपयोग करके स्वास्थ्य रिपोर्ट अपलोड करें।',
                  ),
                )
              else
                ...healthReports.map(
                      (report) =>
                      _buildHealthReportCard(report),
                ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        'Vaccination',
                        'लसीकरण',
                        'टीकाकरण',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                    isUploadingVaccinationReport
                        ? null
                        : _showVaccinationReportOptions,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFF45170),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon:
                    isUploadingVaccinationReport
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.upload_file,
                      size: 18,
                    ),
                    label: Text(
                      isUploadingVaccinationReport
                          ? _t(
                        context,
                        'Uploading',
                        'अपलोड होत आहे',
                        'अपलोड हो रहा है',
                      )
                          : _t(
                        context,
                        'Upload Report',
                        'अहवाल अपलोड करा',
                        'रिपोर्ट अपलोड करें',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (vaccinationRecords.isEmpty)
                _buildEmptyCard(
                  icon: Icons.vaccines_outlined,
                  title: _t(
                    context,
                    'No Vaccination Records',
                    'लसीकरणाच्या नोंदी नाहीत',
                    'कोई टीकाकरण रिकॉर्ड नहीं',
                  ),
                  message: _t(
                    context,
                    'Vaccination information will appear here after it is obtained from the child report.',
                    'मुलाच्या अहवालातून माहिती मिळाल्यानंतर लसीकरणाची माहिती येथे दिसेल.',
                    'बच्चे की रिपोर्ट से जानकारी मिलने के बाद टीकाकरण की जानकारी यहाँ दिखाई देगी।',
                  ),
                )
              else
                ...vaccinationRecords.map(
                      (record) =>
                      _buildVaccinationCard(record),
                ),
              if (vaccinationReports.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _t(
                    context,
                    'Uploaded Vaccination Reports',
                    'अपलोड केलेले लसीकरण अहवाल',
                    'अपलोड की गई टीकाकरण रिपोर्ट',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...vaccinationReports.map(
                      (report) =>
                      _buildVaccinationReportCard(
                        report,
                      ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}