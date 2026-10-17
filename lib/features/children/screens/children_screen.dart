import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'child_details_screen.dart';
import 'add_child_screen.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> filteredChildren = [];

  bool isLoading = true;
  String? errorMessage;

  String _tr(
    BuildContext context,
    String english,
    String marathi,
    String hindi,
  ) {
    final language = Localizations.localeOf(context).languageCode;

    if (language == 'mr') {
      return marathi;
    }

    if (language == 'hi') {
      return hindi;
    }

    return english;
  }

  String _statusText(
    BuildContext context,
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'normal':
        return _tr(
          context,
          'Normal',
          'सामान्य',
          'सामान्य',
        );

      case 'moderate':
        return _tr(
          context,
          'Moderate',
          'मध्यम',
          'मध्यम',
        );

      case 'severe':
        return _tr(
          context,
          'Severe',
          'गंभीर',
          'गंभीर',
        );

      default:
        return status;
    }
  }

  String _genderText(
    BuildContext context,
    String gender,
  ) {
    switch (gender.toLowerCase()) {
      case 'male':
        return _tr(
          context,
          'Male',
          'मुलगा',
          'लड़का',
        );

      case 'female':
        return _tr(
          context,
          'Female',
          'मुलगी',
          'लड़की',
        );

      default:
        return gender;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  // =========================
  // LOAD CHILDREN FROM FIRESTORE
  // =========================

  Future<void> _loadChildren() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final snapshot = await _firestore
          .collection('children')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .get();

      final data = snapshot.docs.map((doc) {
        final child = doc.data();

        return {
          'id': doc.id,
          ...child,
        };
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        children = data;
        filteredChildren = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // =========================
  // SEARCH
  // =========================

  void _searchChildren(String value) {
    final searchText = value.toLowerCase().trim();

    setState(() {
      if (searchText.isEmpty) {
        filteredChildren = children;
      } else {
        filteredChildren = children.where((child) {
          final name = (child['name'] ?? '').toString().toLowerCase();

          final gender = (child['gender'] ?? '').toString().toLowerCase();

          final status = _getChildStatus(child).toLowerCase();

          return name.contains(searchText) ||
              gender.contains(searchText) ||
              status.contains(searchText);
        }).toList();
      }
    });
  }

  // =========================
  // CHILD STATUS
  // =========================

  String _getChildStatus(
    Map<String, dynamic> child,
  ) {
    final growthStatus = child['growthStatus'];

    if (growthStatus != null && growthStatus.toString().trim().isNotEmpty) {
      return growthStatus.toString();
    }

    final healthStatus = child['healthStatus'];

    if (healthStatus != null && healthStatus.toString().trim().isNotEmpty) {
      return healthStatus.toString();
    }

    return 'Normal';
  }

  // =========================
  // EDIT CHILD
  // =========================

  Future<void> _editChild(
    Map<String, dynamic> child,
  ) async {
    final childId = child['id'];

    if (childId == null) {
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildScreen(
          childId: childId.toString(),
          existingChild: child,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadChildren();
    }
  }

  // =========================
  // DELETE CHILD
  // =========================

  Future<void> _deleteChild(
    Map<String, dynamic> child,
  ) async {
    final childId = child['id'];

    if (childId == null) {
      return;
    }

    final childName = (child['name'] ?? '').toString();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _tr(
              context,
              'Delete Child',
              'मूल हटवा',
              'बच्चे को हटाएँ',
            ),
          ),
          content: Text(
            _tr(
              context,
              'Are you sure you want to delete $childName?',
              'तुम्हाला $childName हे मूल हटवायचे आहे का?',
              'क्या आप $childName को हटाना चाहते हैं?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: Text(
                _tr(
                  context,
                  'Cancel',
                  'रद्द करा',
                  'रद्द करें',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _tr(
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

    if (shouldDelete != true) {
      return;
    }

    try {
      final childReference =
          _firestore.collection('children').doc(childId.toString());

      // Delete growth records.
      final growthRecords =
          await childReference.collection('growthRecords').get();

      for (final record in growthRecords.docs) {
        await record.reference.delete();
      }

      // Delete nutrition records.
      final nutritionRecords =
          await childReference.collection('nutritionRecords').get();

      for (final record in nutritionRecords.docs) {
        await record.reference.delete();
      }

      // Delete vaccination records.
      final vaccinationRecords =
          await childReference.collection('vaccinationRecords').get();

      for (final record in vaccinationRecords.docs) {
        await record.reference.delete();
      }

      // Delete health records.
      final healthRecords =
          await childReference.collection('healthRecords').get();

      for (final record in healthRecords.docs) {
        await record.reference.delete();
      }

      // Finally delete the child.
      await childReference.delete();

      await _loadChildren();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Child deleted successfully',
              'मूल यशस्वीरित्या हटवले',
              'बच्चा सफलतापूर्वक हटाया गया',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Error deleting child: $e',
              'मूल हटवताना त्रुटी: $e',
              'बच्चे को हटाने में त्रुटि: $e',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color _getStatusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Color(
          0xFF4CAF50,
        );

      case 'moderate':
        return const Color(
          0xFFFF9800,
        );

      case 'severe':
        return const Color(
          0xFFF44336,
        );

      default:
        return Colors.grey;
    }
  }

  // =========================
  // GENDER ICON
  // =========================

  IconData _getGenderIcon(
    String gender,
  ) {
    if (gender.toLowerCase() == 'female') {
      return Icons.girl;
    }

    if (gender.toLowerCase() == 'male') {
      return Icons.boy;
    }

    return Icons.person;
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFBF8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              10,
            ),
            child: TextField(
              onChanged: _searchChildren,
              decoration: InputDecoration(
                hintText: _tr(
                  context,
                  'Search children...',
                  'मुलांचा शोध घ्या...',
                  'बच्चों को खोजें...',
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFF45170),
                ),
                suffixIcon: IconButton(
                  onPressed: _loadChildren,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFFF45170),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF45170),
                    ),
                  )
                : errorMessage != null
                    ? _errorState()
                    : filteredChildren.isEmpty
                        ? _emptyState()
                        : RefreshIndicator(
                            color: const Color(0xFFF45170),
                            onRefresh: _loadChildren,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                5,
                                16,
                                20,
                              ),
                              itemCount: filteredChildren.length,
                              itemBuilder: (context, index) {
                                final child = filteredChildren[index];

                                return _childCard(
                                  child,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CHILD CARD
  // =========================

  Widget _childCard(
    Map<String, dynamic> child,
  ) {
    final String name = (child['name'] ?? 'Unknown').toString();

    final String age = (child['age'] ?? 0).toString();

    final String gender = (child['gender'] ?? 'Unknown').toString();

    final String status = _getChildStatus(child);

    final statusColor = _getStatusColor(status);

    final String childId = (child['id'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildDetailsScreen(
                childId: childId,
                childName: name,
                age: '$age ${_tr(
                  context,
                  'Years',
                  'वर्षे',
                  'वर्ष',
                )}',
                gender: _genderText(
                  context,
                  gender,
                ),
                status: status,
              ),
            ),
          );

          if (mounted) {
            _loadChildren();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFCE4EC),
                child: Icon(
                  _getGenderIcon(gender),
                  size: 32,
                  color: const Color(0xFFF45170),
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29266F),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$age ${_tr(
                        context,
                        'Years',
                        'वर्षे',
                        'वर्ष',
                      )} • ${_genderText(
                        context,
                        gender,
                      )}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusText(
                          context,
                          status,
                        ),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editChild(child);
                  } else if (value == 'delete') {
                    _deleteChild(child);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFF45170),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _tr(
                              context,
                              'Edit',
                              'संपादित करा',
                              'संपादित करें',
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _tr(
                              context,
                              'Delete',
                              'हटवा',
                              'हटाएँ',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care,
                size: 48,
                color: Color(0xFFF45170),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              _tr(
                context,
                'No Children Found',
                'कोणतीही मुले आढळली नाहीत',
                'कोई बच्चे नहीं मिले',
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29266F),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _tr(
                context,
                'Add a child to start managing their health records.',
                'मुलाच्या आरोग्य नोंदी व्यवस्थापित करण्यासाठी एक मूल जोडा.',
                'बच्चे के स्वास्थ्य रिकॉर्ड प्रबंधित करने के लिए एक बच्चा जोड़ें।',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddChildScreen(),
                  ),
                );

                if (mounted) {
                  _loadChildren();
                }
              },
              icon: const Icon(
                Icons.person_add,
              ),
              label: Text(
                _tr(
                  context,
                  'Add Child',
                  'मूल जोडा',
                  'बच्चा जोड़ें',
                ),
              ),
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
            const SizedBox(
              height: 15,
            ),
            Text(
              _tr(
                context,
                'Unable to Load Children',
                'मुलांची माहिती लोड करता आली नाही',
                'बच्चों की जानकारी लोड नहीं हो सकी',
              ),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29266F),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              errorMessage ??
                  _tr(
                    context,
                    'Unknown database error',
                    'अज्ञात डेटाबेस त्रुटी',
                    'अज्ञात डेटाबेस त्रुटि',
                  ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: _loadChildren,
              icon: const Icon(
                Icons.refresh,
              ),
              label: Text(
                _tr(
                  context,
                  'Try Again',
                  'पुन्हा प्रयत्न करा',
                  'फिर से प्रयास करें',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
