import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends State<AdminAnnouncementsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  List<Map<String, dynamic>> announcements = [];

  final List<String> announcementTypes = [
    'Holiday',
    'Meal',
    'Attendance',
    'Vaccination',
    'Health',
    'General',
    'Urgent',
  ];

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

  String _typeText(
      BuildContext context,
      String type,
      ) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return _t(
          context,
          'Holiday',
          'सुट्टी',
          'छुट्टी',
        );
      case 'meal':
        return _t(
          context,
          'Meal',
          'आहार',
          'भोजन',
        );
      case 'attendance':
        return _t(
          context,
          'Attendance',
          'उपस्थिती',
          'उपस्थिति',
        );
      case 'vaccination':
        return _t(
          context,
          'Vaccination',
          'लसीकरण',
          'टीकाकरण',
        );
      case 'health':
        return _t(
          context,
          'Health',
          'आरोग्य',
          'स्वास्थ्य',
        );
      case 'urgent':
        return _t(
          context,
          'Urgent',
          'तातडीचे',
          'जरूरी',
        );
      case 'general':
      default:
        return _t(
          context,
          'General',
          'सामान्य',
          'सामान्य',
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy(
        'scheduledAt',
        descending: true,
      )
          .get();

      final loaded = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        announcements = loaded;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Unable to load announcements.',
              'घोषणा लोड करता आल्या नाहीत.',
              'घोषणाएँ लोड नहीं की जा सकीं।',
            )}\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createAnnouncement() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    String selectedType = 'General';

    DateTime selectedDate = DateTime.now();

    TimeOfDay selectedTime = TimeOfDay.now();

    bool dialogSaving = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: Text(
                _t(
                  context,
                  'Create Announcement',
                  'घोषणा तयार करा',
                  'घोषणा बनाएँ',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF29266F),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Announcement Type',
                          'घोषणेचा प्रकार',
                          'घोषणा का प्रकार',
                        ),
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: Color(0xFFF45170),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      items: announcementTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getIcon(type),
                                size: 19,
                                color: _getColor(type),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _typeText(
                                  context,
                                  type,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: dialogSaving
                          ? null
                          : (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      enabled: !dialogSaving,
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Title',
                          'शीर्षक',
                          'शीर्षक',
                        ),
                        hintText: _t(
                          context,
                          'Enter announcement title',
                          'घोषणेचे शीर्षक प्रविष्ट करा',
                          'घोषणा का शीर्षक दर्ज करें',
                        ),
                        prefixIcon: const Icon(
                          Icons.title,
                          color: Color(0xFFF45170),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: messageController,
                      enabled: !dialogSaving,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Message',
                          'संदेश',
                          'संदेश',
                        ),
                        hintText: _t(
                          context,
                          'Enter announcement message',
                          'घोषणेचा संदेश प्रविष्ट करा',
                          'घोषणा का संदेश दर्ज करें',
                        ),
                        prefixIcon: const Padding(
                          padding:
                          EdgeInsets.only(bottom: 65),
                          child: Icon(
                            Icons.message_outlined,
                            color: Color(0xFFF45170),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _t(
                          context,
                          'Schedule Announcement',
                          'घोषणा वेळापत्रक',
                          'घोषणा शेड्यूल करें',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: dialogSaving
                                ? null
                                : () async {
                              final pickedDate =
                              await showDatePicker(
                                context: context,
                                initialDate:
                                selectedDate,
                                firstDate:
                                DateTime.now(),
                                lastDate:
                                DateTime.now().add(
                                  const Duration(
                                    days: 365,
                                  ),
                                ),
                              );

                              if (pickedDate ==
                                  null) {
                                return;
                              }

                              setDialogState(() {
                                selectedDate =
                                    pickedDate;
                              });
                            },
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                            label: Text(
                              '${selectedDate.day}/'
                                  '${selectedDate.month}/'
                                  '${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: dialogSaving
                                ? null
                                : () async {
                              final pickedTime =
                              await showTimePicker(
                                context: context,
                                initialTime:
                                selectedTime,
                              );

                              if (pickedTime ==
                                  null) {
                                return;
                              }

                              setDialogState(() {
                                selectedTime =
                                    pickedTime;
                              });
                            },
                            icon: const Icon(
                              Icons.access_time,
                              size: 18,
                            ),
                            label: Text(
                              selectedTime.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogSaving
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
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: dialogSaving
                      ? null
                      : () async {
                    final title =
                    titleController.text.trim();

                    final message =
                    messageController.text.trim();

                    if (title.isEmpty ||
                        message.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              context,
                              'Please enter title and message.',
                              'कृपया शीर्षक आणि संदेश प्रविष्ट करा.',
                              'कृपया शीर्षक और संदेश दर्ज करें।',
                            ),
                          ),
                          backgroundColor:
                          Colors.red,
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      dialogSaving = true;
                    });

                    final scheduledAt = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    try {
                      final user = FirebaseAuth
                          .instance.currentUser;

                      await _firestore
                          .collection(
                        'announcements',
                      )
                          .add({
                        'title': title,
                        'message': message,
                        'type': selectedType,
                        'scheduledAt':
                        Timestamp.fromDate(
                          scheduledAt,
                        ),
                        'createdAt':
                        FieldValue
                            .serverTimestamp(),
                        'createdBy':
                        user?.uid ?? '',
                        'isActive': true,
                      });

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        true,
                      );
                    } catch (e) {
                      setDialogState(() {
                        dialogSaving = false;
                      });

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            '${_t(
                              context,
                              'Failed to create announcement.',
                              'घोषणा तयार करता आली नाही.',
                              'घोषणा बनाने में विफल।',
                            )}\n$e',
                          ),
                          backgroundColor:
                          Colors.red,
                        ),
                      );
                    }
                  },
                  child: dialogSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _t(
                      context,
                      'Publish',
                      'प्रकाशित करा',
                      'प्रकाशित करें',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    messageController.dispose();

    if (result == true && mounted) {
      await _loadAnnouncements();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Announcement created successfully.',
              'घोषणा यशस्वीरित्या तयार झाली.',
              'घोषणा सफलतापूर्वक बनाई गई।',
            ),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  Future<void> _toggleAnnouncement(
      String id,
      bool currentStatus,
      ) async {
    try {
      await _firestore
          .collection('announcements')
          .doc(id)
          .update({
        'isActive': !currentStatus,
      });

      await _loadAnnouncements();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Unable to update announcement.',
              'घोषणा अपडेट करता आली नाही.',
              'घोषणा अपडेट नहीं की जा सकी।',
            )}\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAnnouncement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _t(
              context,
              'Delete Announcement',
              'घोषणा हटवा',
              'घोषणा हटाएँ',
            ),
          ),
          content: Text(
            _t(
              context,
              'Are you sure you want to delete this announcement?',
              'तुम्हाला ही घोषणा हटवायची आहे का?',
              'क्या आप यह घोषणा हटाना चाहते हैं?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
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
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _t(
                  context,
                  'Delete',
                  'हटवा',
                  'हटाएँ',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _firestore
          .collection('announcements')
          .doc(id)
          .delete();

      await _loadAnnouncements();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Announcement deleted.',
              'घोषणा हटवली.',
              'घोषणा हटा दी गई।',
            ),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Unable to delete announcement.',
              'घोषणा हटवता आली नाही.',
              'घोषणा हटाई नहीं जा सकी।',
            )}\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return Icons.celebration_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      case 'attendance':
        return Icons.people_outline;
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      case 'urgent':
        return Icons.warning_amber_outlined;
      case 'general':
      default:
        return Icons.campaign_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return const Color(0xFF9C27B0);
      case 'meal':
        return const Color(0xFFFF9800);
      case 'attendance':
        return const Color(0xFF2196F3);
      case 'vaccination':
        return const Color(0xFF4CAF50);
      case 'health':
        return const Color(0xFFF45170);
      case 'urgent':
        return Colors.red;
      case 'general':
      default:
        return const Color(0xFF29266F);
    }
  }

  String _formatDateTime(
      dynamic value,
      ) {
    if (value is! Timestamp) {
      return _t(
        context,
        'No schedule',
        'वेळापत्रक नाही',
        'कोई शेड्यूल नहीं',
      );
    }

    final date = value.toDate();

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute =
    date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12
        ? 'PM'
        : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t(
            context,
            'Manage Announcements',
            'घोषणा व्यवस्थापित करा',
            'घोषणाएँ प्रबंधित करें',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _createAnnouncement,
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_alert_outlined,
        ),
        label: Text(
          _t(
            context,
            'Create',
            'तयार करा',
            'बनाएँ',
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF45170),
        onRefresh: _loadAnnouncements,
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF45170),
          ),
        )
            : announcements.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding:
          const EdgeInsets.all(16),
          itemCount:
          announcements.length,
          itemBuilder:
              (context, index) {
            return _buildAnnouncementCard(
              announcements[index],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
      Map<String, dynamic> announcement,
      ) {
    final type =
    (announcement['type'] ?? 'General')
        .toString();

    final title =
    (announcement['title'] ?? 'Announcement')
        .toString();

    final message =
    (announcement['message'] ?? '')
        .toString();

    final isActive =
        announcement['isActive'] == true;

    final color = _getColor(type);
    final icon = _getIcon(type);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
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
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  color.withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _typeText(
                        context,
                        type,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  final id =
                  announcement['id'].toString();

                  if (value == 'toggle') {
                    _toggleAnnouncement(
                      id,
                      isActive,
                    );
                  } else if (value == 'delete') {
                    _deleteAnnouncement(id);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'toggle',
                      child: Text(
                        isActive
                            ? _t(
                          context,
                          'Deactivate',
                          'निष्क्रिय करा',
                          'निष्क्रिय करें',
                        )
                            : _t(
                          context,
                          'Activate',
                          'सक्रिय करा',
                          'सक्रिय करें',
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        _t(
                          context,
                          'Delete',
                          'हटवा',
                          'हटाएँ',
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 15,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _formatDateTime(
                    announcement['scheduledAt'],
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration:
                BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey.shade200,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Text(
                  isActive
                      ? _t(
                    context,
                    'Active',
                    'सक्रिय',
                    'सक्रिय',
                  )
                      : _t(
                    context,
                    'Inactive',
                    'निष्क्रिय',
                    'निष्क्रिय',
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w600,
                    color: isActive
                        ? const Color(
                      0xFF2E7D32,
                    )
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 80),
        Container(
          padding:
          const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.campaign_outlined,
                size: 60,
                color: Color(0xFFF45170),
              ),
              const SizedBox(height: 15),
              Text(
                _t(
                  context,
                  'No Announcements Yet',
                  'अजून कोणत्याही घोषणा नाहीत',
                  'अभी तक कोई घोषणा नहीं है',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xFF29266F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                  context,
                  'Create an announcement for holidays, health programs, meals, vaccination, attendance or other Anganwadi updates.',
                  'सुट्ट्या, आरोग्य कार्यक्रम, आहार, लसीकरण, उपस्थिती किंवा इतर अंगणवाडी अपडेट्ससाठी घोषणा तयार करा.',
                  'छुट्टियों, स्वास्थ्य कार्यक्रमों, भोजन, टीकाकरण, उपस्थिति या अन्य आंगनवाड़ी अपडेट्स के लिए घोषणा बनाएँ।',
                ),
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}