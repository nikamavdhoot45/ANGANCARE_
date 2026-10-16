import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'add_worker_screen.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() =>
      _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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

  Future<void> _openAddWorker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWorkerScreen(),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _updateWorkerStatus(
      String workerId,
      bool currentStatus,
      ) async {
    try {
      await _firestore
          .collection('workers')
          .doc(workerId)
          .update({
        'isActive': !currentStatus,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus
                ? _t(
              context,
              'Worker account deactivated.',
              'कार्यकर्ता खाते निष्क्रिय केले.',
              'कार्यकर्ता खाता निष्क्रिय कर दिया गया।',
            )
                : _t(
              context,
              'Worker account activated.',
              'कार्यकर्ता खाते सक्रिय केले.',
              'कार्यकर्ता खाता सक्रिय कर दिया गया।',
            ),
          ),
          backgroundColor:
          currentStatus ? Colors.orange : Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Unable to update worker.',
              'कार्यकर्त्याची माहिती अपडेट करता आली नाही.',
              'कार्यकर्ता अपडेट नहीं किया जा सका।',
            )}\n${e.message ?? e.code}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWorkerDetails(
      BuildContext context,
      Map<String, dynamic> worker,
      ) {
    final name = worker['name'] ?? 'Unknown';
    final email = worker['email'] ?? 'No email';
    final phone = worker['phone'] ?? 'No phone';
    final centerId = worker['centerId'] ?? 'No center';

    final isActive = worker['isActive'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFBF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                    const Color(0xFFFCE4EC),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFF45170),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29266F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _detailRow(
                Icons.email_outlined,
                _t(
                  context,
                  'Email',
                  'ई-मेल',
                  'ई-मेल',
                ),
                email.toString(),
              ),
              const SizedBox(height: 13),
              _detailRow(
                Icons.phone_outlined,
                _t(
                  context,
                  'Phone',
                  'फोन',
                  'फोन',
                ),
                phone.toString(),
              ),
              const SizedBox(height: 13),
              _detailRow(
                Icons.location_city_outlined,
                _t(
                  context,
                  'Center ID',
                  'केंद्र आयडी',
                  'केंद्र आईडी',
                ),
                centerId.toString(),
              ),
              const SizedBox(height: 13),
              _detailRow(
                Icons.verified_user_outlined,
                _t(
                  context,
                  'Account Status',
                  'खाते स्थिती',
                  'खाता स्थिति',
                ),
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
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    _updateWorkerStatus(
                      worker['id'].toString(),
                      isActive,
                    );
                  },
                  icon: Icon(
                    isActive
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    isActive
                        ? _t(
                      context,
                      'DEACTIVATE WORKER',
                      'कार्यकर्ता निष्क्रिय करा',
                      'कार्यकर्ता निष्क्रिय करें',
                    )
                        : _t(
                      context,
                      'ACTIVATE WORKER',
                      'कार्यकर्ता सक्रिय करा',
                      'कार्यकर्ता सक्रिय करें',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isActive ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFFF45170),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(
      BuildContext context,
      Map<String, dynamic> worker,
      ) {
    final name = worker['name'] ?? 'Unknown Worker';
    final email = worker['email'] ?? 'No email';
    final centerId = worker['centerId'] ?? 'No center';

    final isActive = worker['isActive'] == true;

    return InkWell(
      onTap: () => _showWorkerDetails(
        context,
        worker,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
              const Color(0xFFFCE4EC),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFFF45170),
                size: 27,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29266F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          centerId.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius:
                    BorderRadius.circular(20),
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
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
    AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.workers,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _openAddWorker,
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.person_add_alt_1,
        ),
        label: Text(
          localizations.addWorker,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('workers')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  '${_t(
                    context,
                    'Unable to load workers.',
                    'कार्यकर्ते लोड करता आले नाहीत.',
                    'कार्यकर्ताओं को लोड नहीं किया जा सका।',
                  )}\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF45170),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFFFCE4EC),
                        borderRadius:
                        BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 42,
                        color: Color(0xFFF45170),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _t(
                        context,
                        'No Workers Yet',
                        'अजून कोणतेही कार्यकर्ते नाहीत',
                        'अभी तक कोई कार्यकर्ता नहीं है',
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29266F),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _t(
                        context,
                        'Add a worker to see their information here.',
                        'त्यांची माहिती येथे पाहण्यासाठी कार्यकर्ता जोडा.',
                        'उनकी जानकारी यहाँ देखने के लिए एक कार्यकर्ता जोड़ें।',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: _openAddWorker,
                      icon: const Icon(
                        Icons.person_add_alt_1,
                      ),
                      label: Text(
                        _t(
                          context,
                          'ADD WORKER',
                          'कार्यकर्ता जोडा',
                          'कार्यकर्ता जोड़ें',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final workers = documents.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();

          return RefreshIndicator(
            color: const Color(0xFFF45170),
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                100,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t(
                              context,
                              'Worker Management',
                              'कार्यकर्ता व्यवस्थापन',
                              'कार्यकर्ता प्रबंधन',
                            ),
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF29266F),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _t(
                              context,
                              'Manage registered Anganwadi workers.',
                              'नोंदणीकृत अंगणवाडी कार्यकर्त्यांचे व्यवस्थापन करा.',
                              'पंजीकृत आंगनवाड़ी कार्यकर्ताओं का प्रबंधन करें।',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFFFCE4EC),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${workers.length} ${workers.length == 1 ? _t(context, 'Worker', 'कार्यकर्ता', 'कार्यकर्ता') : _t(context, 'Workers', 'कार्यकर्ते', 'कार्यकर्ता')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF45170),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...workers.map(
                      (worker) => _buildWorkerCard(
                    context,
                    worker,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}