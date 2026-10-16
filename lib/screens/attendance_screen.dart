import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  DateTime _selectedDate = DateTime.now();

  bool _loading = true;
  bool _saving = false;

  List<Map<String, dynamic>> _children = [];
  final Map<String, String> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  // =========================
  // LOCALIZATION
  // =========================

  String _t(String key) {
    return AppLocalizations.of(context).text(key);
  }

  String _attendanceText(String key) {
    final language =
        AppLocalizations.of(context).locale.languageCode;

    const translations = {
      'en': {
        'attendanceDate': 'Attendance Date',
        'present': 'Present',
        'absent': 'Absent',
        'saving': 'Saving...',
        'saveAttendance': 'Save Attendance',
        'noChildrenAvailable': 'No children available',
        'addChildrenFirst':
        'Add children first to mark attendance.',
        'unableToLoadAttendance':
        'Unable to load attendance',
        'unableToSaveAttendance':
        'Unable to save attendance',
        'attendanceSaved':
        'Attendance saved successfully.',
        'age': 'Age',
      },
      'mr': {
        'attendanceDate': 'उपस्थितीची तारीख',
        'present': 'उपस्थित',
        'absent': 'अनुपस्थित',
        'saving': 'जतन करत आहे...',
        'saveAttendance': 'उपस्थिती जतन करा',
        'noChildrenAvailable': 'कोणतीही मुले उपलब्ध नाहीत',
        'addChildrenFirst':
        'उपस्थिती नोंदवण्यासाठी प्रथम मुले जोडा.',
        'unableToLoadAttendance':
        'उपस्थिती लोड करता आली नाही',
        'unableToSaveAttendance':
        'उपस्थिती जतन करता आली नाही',
        'attendanceSaved':
        'उपस्थिती यशस्वीरित्या जतन झाली.',
        'age': 'वय',
      },
      'hi': {
        'attendanceDate': 'उपस्थिति की तारीख',
        'present': 'उपस्थित',
        'absent': 'अनुपस्थित',
        'saving': 'सहेजा जा रहा है...',
        'saveAttendance': 'उपस्थिति सहेजें',
        'noChildrenAvailable': 'कोई बच्चे उपलब्ध नहीं हैं',
        'addChildrenFirst':
        'उपस्थिति दर्ज करने के लिए पहले बच्चे जोड़ें।',
        'unableToLoadAttendance':
        'उपस्थिति लोड नहीं हो सकी',
        'unableToSaveAttendance':
        'उपस्थिति सहेजी नहीं जा सकी',
        'attendanceSaved':
        'उपस्थिति सफलतापूर्वक सहेजी गई।',
        'age': 'आयु',
      },
    };

    return translations[language]?[key] ??
        translations['en']![key]!;
  }

  // =========================
  // DATE KEY
  // =========================

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================
  // LOAD ATTENDANCE
  // =========================

  Future<void> _loadAttendance() async {
    setState(() {
      _loading = true;
    });

    try {
      final childrenSnapshot = await _firestore
          .collection('children')
          .orderBy('createdAt', descending: true)
          .get();

      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where(
        'date',
        isEqualTo: _dateKey(_selectedDate),
      )
          .get();

      final children =
      childrenSnapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name':
          data['name']?.toString() ??
              'Unnamed Child',
          'age': data['age']?.toString() ?? '',
          'gender':
          data['gender']?.toString() ?? '',
        };
      }).toList();

      final attendance = <String, String>{};

      for (final doc in attendanceSnapshot.docs) {
        final data = doc.data();

        final childId =
        data['childId']?.toString();

        if (childId != null &&
            childId.isNotEmpty) {
          attendance[childId] =
              data['status']?.toString() ??
                  'Present';
        }
      }

      if (!mounted) return;

      setState(() {
        _children = children;
        _attendance
          ..clear()
          ..addAll(attendance);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _children = [];
        _attendance.clear();
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_attendanceText('unableToLoadAttendance')}: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // SELECT DATE
  // =========================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });

    await _loadAttendance();
  }

  // =========================
  // SET ATTENDANCE
  // =========================

  void _setAttendance(
      String childId,
      String status,
      ) {
    setState(() {
      _attendance[childId] = status;
    });
  }

  // =========================
  // SAVE ATTENDANCE
  // =========================

  Future<void> _saveAttendance() async {
    if (_children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _attendanceText(
              'noChildrenAvailable',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final batch = _firestore.batch();
      final date = _dateKey(_selectedDate);

      for (final child in _children) {
        final childId =
        child['id'].toString();

        final status =
            _attendance[childId] ?? 'Absent';

        final documentId =
            '${date}_$childId';

        final attendanceRef = _firestore
            .collection('attendance')
            .doc(documentId);

        batch.set(
          attendanceRef,
          {
            'childId': childId,
            'childName': child['name'],
            'status': status,
            'date': date,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _attendanceText('attendanceSaved'),
          ),
        ),
      );

      await _loadAttendance();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_attendanceText('unableToSaveAttendance')}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // =========================
  // PRESENT COUNT
  // =========================

  int get _presentCount {
    return _children.where((child) {
      final id = child['id'].toString();

      return _attendance[id] == 'Present';
    }).length;
  }

  // =========================
  // ABSENT COUNT
  // =========================

  int get _absentCount {
    return _children.where((child) {
      final id = child['id'].toString();

      return _attendance[id] == 'Absent';
    }).length;
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    const primaryColor =
    Color(0xFFF45170);

    return Scaffold(
      backgroundColor:
      const Color(0xFFFFFBF8),

      appBar: AppBar(
        title: Text(
          _t('attendance'),
        ),
        backgroundColor:
        primaryColor,
        foregroundColor:
        Colors.white,
      ),

      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : _children.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
              children: [
                // =========================
                // DATE SELECTOR
                // =========================

                InkWell(
                  onTap:
                  _selectDate,
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                  child:
                  Container(
                    width:
                    double.infinity,
                    padding:
                    const EdgeInsets
                        .all(
                      16,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),
                    child:
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_month_outlined,
                          color:
                          primaryColor,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                _attendanceText(
                                  'attendanceDate',
                                ),
                                style:
                                TextStyle(
                                  fontSize:
                                  13,
                                  color:
                                  Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _dateKey(
                                  _selectedDate,
                                ),
                                style:
                                const TextStyle(
                                  fontSize:
                                  17,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons
                              .arrow_drop_down,
                          color:
                          Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // =========================
                // SUMMARY
                // =========================

                Row(
                  children: [
                    Expanded(
                      child:
                      _summaryCard(
                        _attendanceText(
                          'present',
                        ),
                        _presentCount,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                      _summaryCard(
                        _attendanceText(
                          'absent',
                        ),
                        _absentCount,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // =========================
          // CHILDREN LIST
          // =========================

          Expanded(
            child:
            ListView.builder(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                0,
                16,
                100,
              ),
              itemCount:
              _children.length,
              itemBuilder:
                  (context, index) {
                final child =
                _children[index];

                final childId =
                child['id']
                    .toString();

                final name =
                child['name']
                    .toString();

                final status =
                    _attendance[
                    childId] ??
                        'Absent';

                return Container(
                  margin:
                  const EdgeInsets
                      .only(
                    bottom: 10,
                  ),
                  padding:
                  const EdgeInsets
                      .all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius
                        .circular(
                      14,
                    ),
                  ),
                  child:
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFFCE4EC,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                        child:
                        const Icon(
                          Icons
                              .child_care,
                          color:
                          primaryColor,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              name,
                              style:
                              const TextStyle(
                                fontSize:
                                16,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            if (child[
                            'age']
                                .toString()
                                .isNotEmpty)
                              Text(
                                '${_attendanceText('age')}: ${child['age']}',
                                style:
                                TextStyle(
                                  fontSize:
                                  12,
                                  color:
                                  Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          _attendanceButton(
                            childId:
                            childId,
                            label:
                            'P',
                            status:
                            'Present',
                            selected:
                            status ==
                                'Present',
                            color:
                            Colors
                                .green,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          _attendanceButton(
                            childId:
                            childId,
                            label:
                            'A',
                            status:
                            'Absent',
                            selected:
                            status ==
                                'Absent',
                            color:
                            Colors
                                .red,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // =========================
      // SAVE BUTTON
      // =========================

      floatingActionButton:
      _children.isEmpty
          ? null
          : FloatingActionButton
          .extended(
        onPressed:
        _saving
            ? null
            : _saveAttendance,
        backgroundColor:
        primaryColor,
        foregroundColor:
        Colors.white,
        icon: _saving
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color:
            Colors.white,
          ),
        )
            : const Icon(
          Icons
              .save_outlined,
        ),
        label: Text(
          _saving
              ? _attendanceText(
            'saving',
          )
              : _attendanceText(
            'saveAttendance',
          ),
        ),
      ),
    );
  }

  // =========================
  // SUMMARY CARD
  // =========================

  Widget _summaryCard(
      String title,
      int count,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            title ==
                _attendanceText(
                  'present',
                )
                ? Icons
                .check_circle_outline
                : Icons.cancel_outlined,
            color: color,
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style:
                const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // ATTENDANCE BUTTON
  // =========================

  Widget _attendanceButton({
    required String childId,
    required String label,
    required String status,
    required bool selected,
    required Color color,
  }) {
    return InkWell(
      onTap: () =>
          _setAttendance(
            childId,
            status,
          ),
      borderRadius:
      BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        alignment:
        Alignment.center,
        decoration:
        BoxDecoration(
          color: selected
              ? color
              : color.withValues(
            alpha: 0.08,
          ),
          borderRadius:
          BorderRadius.circular(8),
          border: Border.all(
            color:
            color.withValues(
              alpha: 0.35,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : color,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 70,
              color:
              Colors.grey.shade400,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              _attendanceText(
                'noChildrenAvailable',
              ),
              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _attendanceText(
                'addChildrenFirst',
              ),
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}