import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  // =========================
  // LOCALIZATION
  // =========================

  String _alertText(String key) {
    final language =
        AppLocalizations.of(context).locale.languageCode;

    const translations = {
      'en': {
        'alertsAnnouncements':
        'Alerts & Announcements',
        'importantMessages':
        'Important messages and reminders from the administrator.',
        'noTimeSpecified':
        'No time specified',
        'today': 'Today',
        'noAlertsAvailable':
        'No Alerts Available',
        'noAnnouncements':
        'There are no announcements or reminders at the moment.',
        'unableToLoadAlerts':
        'Unable to Load Alerts',
        'unknownError':
        'Unknown error',
        'tryAgain':
        'Try Again',
        'announcementInfo':
        'Announcements and reminders are managed by the administrator. '
            'Workers receive the same information through the app.',
        'meal': 'Meal',
        'attendance': 'Attendance',
        'health': 'Health',
        'healthCheckup': 'Health Checkup',
        'vaccination': 'Vaccination',
        'announcement': 'Announcement',
        'general': 'General',
      },
      'mr': {
        'alertsAnnouncements':
        'सूचना आणि घोषणा',
        'importantMessages':
        'प्रशासकाकडून महत्त्वाचे संदेश आणि स्मरणपत्रे.',
        'noTimeSpecified':
        'वेळ निर्दिष्ट केलेली नाही',
        'today': 'आज',
        'noAlertsAvailable':
        'कोणत्याही सूचना उपलब्ध नाहीत',
        'noAnnouncements':
        'सध्या कोणत्याही घोषणा किंवा स्मरणपत्रे नाहीत.',
        'unableToLoadAlerts':
        'सूचना लोड करता आल्या नाहीत',
        'unknownError':
        'अज्ञात त्रुटी',
        'tryAgain':
        'पुन्हा प्रयत्न करा',
        'announcementInfo':
        'घोषणा आणि स्मरणपत्रे प्रशासकाद्वारे व्यवस्थापित केली जातात. '
            'कार्यकर्त्यांना हीच माहिती अॅपद्वारे मिळते.',
        'meal': 'आहार',
        'attendance': 'उपस्थिती',
        'health': 'आरोग्य',
        'healthCheckup': 'आरोग्य तपासणी',
        'vaccination': 'लसीकरण',
        'announcement': 'घोषणा',
        'general': 'सामान्य',
      },
      'hi': {
        'alertsAnnouncements':
        'सूचनाएँ और घोषणाएँ',
        'importantMessages':
        'व्यवस्थापक की महत्वपूर्ण सूचनाएँ और अनुस्मारक।',
        'noTimeSpecified':
        'समय निर्दिष्ट नहीं है',
        'today': 'आज',
        'noAlertsAvailable':
        'कोई सूचनाएँ उपलब्ध नहीं हैं',
        'noAnnouncements':
        'इस समय कोई घोषणा या अनुस्मारक नहीं है।',
        'unableToLoadAlerts':
        'सूचनाएँ लोड नहीं हो सकीं',
        'unknownError':
        'अज्ञात त्रुटि',
        'tryAgain':
        'पुनः प्रयास करें',
        'announcementInfo':
        'घोषणाएँ और अनुस्मारक व्यवस्थापक द्वारा प्रबंधित किए जाते हैं। '
            'कार्यकर्ताओं को वही जानकारी ऐप के माध्यम से मिलती है।',
        'meal': 'भोजन',
        'attendance': 'उपस्थिति',
        'health': 'स्वास्थ्य',
        'healthCheckup': 'स्वास्थ्य जाँच',
        'vaccination': 'टीकाकरण',
        'announcement': 'घोषणा',
        'general': 'सामान्य',
      },
    };

    return translations[language]?[key] ??
        translations['en']![key]!;
  }

  String _localizedType(String type) {
    switch (type.toLowerCase()) {
      case 'meal':
        return _alertText('meal');

      case 'attendance':
        return _alertText('attendance');

      case 'health':
        return _alertText('health');

      case 'health checkup':
        return _alertText('healthCheckup');

      case 'vaccination':
        return _alertText('vaccination');

      case 'announcement':
        return _alertText('announcement');

      case 'general':
        return _alertText('general');

      default:
        return type;
    }
  }

  // =========================
  // LOAD ALERTS
  // =========================

  Future<void> _loadAlerts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy(
        'scheduledAt',
        descending: false,
      )
          .get();

      final now = DateTime.now();

      final loadedAlerts = snapshot.docs
          .map((doc) {
        final data = doc.data();

        DateTime? scheduledAt;

        final timestamp =
        data['scheduledAt'];

        if (timestamp is Timestamp) {
          scheduledAt =
              timestamp.toDate();
        }

        final isActive =
            data['isActive'] ?? true;

        if (!isActive) {
          return null;
        }

        if (scheduledAt != null &&
            scheduledAt.isBefore(
              now.subtract(
                const Duration(
                  days: 1,
                ),
              ),
            )) {
          return null;
        }

        return {
          'id': doc.id,
          'title':
          (data['title'] ??
              'Announcement')
              .toString(),
          'message':
          (data['message'] ?? '')
              .toString(),
          'type':
          (data['type'] ??
              'General')
              .toString(),
          'scheduledAt':
          scheduledAt,
        };
      })
          .whereType<
          Map<String, dynamic>>()
          .toList();

      loadedAlerts.sort((a, b) {
        final aDate =
        a['scheduledAt'] as DateTime?;

        final bDate =
        b['scheduledAt'] as DateTime?;

        if (aDate == null &&
            bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return aDate.compareTo(bDate);
      });

      if (!mounted) return;

      setState(() {
        alerts = loadedAlerts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // =========================
  // ICON
  // =========================

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meal':
        return Icons.restaurant_outlined;

      case 'attendance':
        return Icons.people_outline;

      case 'health':
      case 'health checkup':
        return Icons.medical_services_outlined;

      case 'vaccination':
        return Icons.vaccines_outlined;

      case 'announcement':
      case 'general':
      default:
        return Icons.campaign_outlined;
    }
  }

  // =========================
  // COLOR
  // =========================

  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'meal':
        return const Color(0xFFFF9800);

      case 'attendance':
        return const Color(0xFF2196F3);

      case 'health':
      case 'health checkup':
        return const Color(0xFFF45170);

      case 'vaccination':
        return const Color(0xFF4CAF50);

      case 'announcement':
      case 'general':
      default:
        return const Color(0xFF29266F);
    }
  }

  // =========================
  // FORMAT DATE
  // =========================

  String _formatDateTime(
      DateTime? dateTime,
      ) {
    if (dateTime == null) {
      return _alertText(
        'noTimeSpecified',
      );
    }

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;

    final minute =
    dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    final today =
    DateTime.now();

    final isToday =
        dateTime.year ==
            today.year &&
            dateTime.month ==
                today.month &&
            dateTime.day ==
                today.day;

    if (isToday) {
      return '${_alertText('today')}, '
          '$hour:$minute $period';
    }

    return '${dateTime.day}/'
        '${dateTime.month}/'
        '${dateTime.year}, '
        '$hour:$minute $period';
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      color: const Color(0xFFFFFBF8),
      child: RefreshIndicator(
        color: const Color(0xFFF45170),
        onRefresh: _loadAlerts,
        child: ListView(
          padding:
          const EdgeInsets.all(16),
          children: [
            Text(
              _alertText(
                'alertsAnnouncements',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              _alertText(
                'importantMessages',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            if (isLoading)
              const Padding(
                padding:
                EdgeInsets.symmetric(
                  vertical: 50,
                ),
                child: Center(
                  child:
                  CircularProgressIndicator(
                    color:
                    Color(0xFFF45170),
                  ),
                ),
              )
            else if (errorMessage != null)
              _buildErrorState()
            else if (alerts.isEmpty)
                _buildNoAlertsState()
              else
                ...alerts.map(
                      (alert) =>
                      _buildAlert(alert),
                ),

            const SizedBox(
              height: 20,
            ),

            _buildInformationCard(),
          ],
        ),
      ),
    );
  }

  // =========================
  // ALERT CARD
  // =========================

  Widget _buildAlert(
      Map<String, dynamic> alert,
      ) {
    final type =
    alert['type'].toString();

    final title =
    alert['title'].toString();

    final message =
    alert['message'].toString();

    final scheduledAt =
    alert['scheduledAt']
    as DateTime?;

    final color =
    _getColor(type);

    final icon =
    _getIcon(type);

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
            BoxDecoration(
              color:
              color.withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        color.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          8,
                        ),
                      ),
                      child: Text(
                        _localizedType(
                          type,
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight
                              .w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  message,
                  style:
                  const TextStyle(
                    fontSize: 12,
                    color:
                    Colors.grey,
                    height: 1.4,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color:
                      Colors.grey,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      _formatDateTime(
                        scheduledAt,
                      ),
                      style:
                      const TextStyle(
                        fontSize: 11,
                        color:
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // NO ALERTS
  // =========================

  Widget _buildNoAlertsState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none,
            color:
            Color(0xFFF45170),
            size: 50,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            _alertText(
              'noAlertsAvailable',
            ),
            style:
            const TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            _alertText(
              'noAnnouncements',
            ),
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR STATE
  // =========================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 45,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            _alertText(
              'unableToLoadAlerts',
            ),
            style:
            const TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            errorMessage ??
                _alertText(
                  'unknownError',
                ),
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ElevatedButton.icon(
            onPressed:
            _loadAlerts,
            icon: const Icon(
              Icons.refresh,
            ),
            label: Text(
              _alertText(
                'tryAgain',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INFORMATION CARD
  // =========================

  Widget _buildInformationCard() {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color:
            Color(0xFFF45170),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              _alertText(
                'announcementInfo',
              ),
              style:
              const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}