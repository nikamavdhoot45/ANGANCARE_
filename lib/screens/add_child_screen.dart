import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../localization/app_localizations.dart';

class AddChildScreen extends StatefulWidget {
  final String? childId;
  final Map<String, dynamic>? existingChild;

  const AddChildScreen({
    super.key,
    this.childId,
    this.existingChild,
  });

  bool get isEditMode => childId != null;

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final dobController = TextEditingController();

  final motherNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final guardianNameController = TextEditingController();

  final motherContactController = TextEditingController();
  final fatherContactController = TextEditingController();

  final addressController = TextEditingController();
  final anganwadiController = TextEditingController();

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final muacController = TextEditingController();

  final medicalNotesController = TextEditingController();

  String? selectedGender;
  String? selectedGrowthStatus;
  String? selectedNutritionStatus;
  String? selectedHealthStatus;

  int calculatedAge = 0;

  bool isSaving = false;

  // =========================
  // LOCALIZATION
  // =========================

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

  String _genderText(BuildContext context, String value) {
    switch (value) {
      case 'Male':
        return _t(context, 'Male', 'पुरुष', 'पुरुष');
      case 'Female':
        return _t(context, 'Female', 'महिला', 'महिला');
      case 'Other':
        return _t(context, 'Other', 'इतर', 'अन्य');
      default:
        return value;
    }
  }

  String _statusText(BuildContext context, String value) {
    switch (value) {
      case 'Normal':
        return _t(context, 'Normal', 'सामान्य', 'सामान्य');
      case 'Moderate':
        return _t(context, 'Moderate', 'मध्यम', 'मध्यम');
      case 'Severe':
        return _t(context, 'Severe', 'गंभीर', 'गंभीर');
      case 'Healthy':
        return _t(context, 'Healthy', 'निरोगी', 'स्वस्थ');
      case 'Needs Attention':
        return _t(
          context,
          'Needs Attention',
          'लक्ष देणे आवश्यक',
          'ध्यान देने की आवश्यकता',
        );
      case 'Under Treatment':
        return _t(
          context,
          'Under Treatment',
          'उपचार सुरू आहे',
          'उपचार चल रहा है',
        );
      default:
        return value;
    }
  }

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    if (widget.existingChild != null) {
      _loadExistingChild(widget.existingChild!);
    }
  }

  void _loadExistingChild(Map<String, dynamic> child) {
    nameController.text =
        (child['name'] ?? '').toString();

    dobController.text =
        (child['dateOfBirth'] ?? '').toString();

    motherNameController.text =
        (child['motherName'] ?? '').toString();

    fatherNameController.text =
        (child['fatherName'] ?? '').toString();

    guardianNameController.text =
        (child['guardianName'] ?? '').toString();

    motherContactController.text =
        (child['motherContact'] ?? '').toString();

    fatherContactController.text =
        (child['fatherContact'] ?? '').toString();

    addressController.text =
        (child['address'] ?? '').toString();

    anganwadiController.text =
        (child['anganwadiCenter'] ?? '').toString();

    heightController.text =
    child['height'] != null
        ? child['height'].toString()
        : '';

    weightController.text =
    child['weight'] != null
        ? child['weight'].toString()
        : '';

    muacController.text =
    child['muac'] != null
        ? child['muac'].toString()
        : '';

    medicalNotesController.text =
        (child['medicalNotes'] ?? '').toString();

    selectedGender =
        child['gender']?.toString();

    selectedGrowthStatus =
        child['growthStatus']?.toString();

    selectedNutritionStatus =
        child['nutritionStatus']?.toString();

    selectedHealthStatus =
        child['healthStatus']?.toString();

    calculatedAge =
        int.tryParse(
          (child['age'] ?? 0).toString(),
        ) ??
            0;
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();

    motherNameController.dispose();
    fatherNameController.dispose();
    guardianNameController.dispose();

    motherContactController.dispose();
    fatherContactController.dispose();

    addressController.dispose();
    anganwadiController.dispose();

    heightController.dispose();
    weightController.dispose();
    muacController.dispose();

    medicalNotesController.dispose();

    super.dispose();
  }

  // =========================
  // DATE OF BIRTH
  // =========================

  Future<void> _selectDateOfBirth() async {
    DateTime initialDate = DateTime.now();

    if (dobController.text.trim().isNotEmpty) {
      try {
        final parts =
        dobController.text.trim().split('/');

        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }

    final DateTime? pickedDate =
    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    final today = DateTime.now();

    int age =
        today.year - pickedDate.year;

    if (today.month < pickedDate.month ||
        (today.month == pickedDate.month &&
            today.day < pickedDate.day)) {
      age--;
    }

    setState(() {
      calculatedAge = age;

      dobController.text =
      '${pickedDate.day.toString().padLeft(2, '0')}/'
          '${pickedDate.month.toString().padLeft(2, '0')}/'
          '${pickedDate.year}';
    });
  }

  // =========================
  // BMI
  // =========================

  double? _calculateBMI() {
    final height =
    double.tryParse(heightController.text);

    final weight =
    double.tryParse(weightController.text);

    if (height == null ||
        weight == null ||
        height <= 0 ||
        weight <= 0) {
      return null;
    }

    final heightInMeters =
        height / 100;

    return weight /
        (heightInMeters * heightInMeters);
  }

  // =========================
  // SAVE / UPDATE
  // =========================

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedGender == null ||
        selectedGender!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Please select gender',
              'कृपया लिंग निवडा',
              'कृपया लिंग चुनें',
            ),
          ),
        ),
      );
      return;
    }

    if (calculatedAge < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Invalid date of birth',
              'जन्मतारीख चुकीची आहे',
              'जन्म तिथि अमान्य है',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final bmi = _calculateBMI();

      final childData = <String, dynamic>{
        'name': nameController.text.trim(),

        'dateOfBirth':
        dobController.text.trim(),

        'age': calculatedAge,

        'gender':
        selectedGender!,

        'motherName':
        motherNameController.text.trim(),

        'fatherName':
        fatherNameController.text.trim(),

        'guardianName':
        guardianNameController.text.trim(),

        'motherContact':
        motherContactController.text.trim(),

        'fatherContact':
        fatherContactController.text.trim(),

        'address':
        addressController.text.trim(),

        'anganwadiCenter':
        anganwadiController.text.trim(),

        'height':
        double.tryParse(
          heightController.text.trim(),
        ),

        'weight':
        double.tryParse(
          weightController.text.trim(),
        ),

        'bmi': bmi,

        'muac':
        double.tryParse(
          muacController.text.trim(),
        ),

        'growthStatus':
        selectedGrowthStatus ?? 'Normal',

        'nutritionStatus':
        selectedNutritionStatus ?? 'Normal',

        'healthStatus':
        selectedHealthStatus ?? 'Healthy',

        'lastCheckup': null,

        'nextCheckup': null,

        'medicalNotes':
        medicalNotesController.text.trim(),
      };

      // =========================
      // EDIT EXISTING CHILD
      // =========================

      if (widget.isEditMode) {
        await _firestore
            .collection('children')
            .doc(widget.childId)
            .update({
          ...childData,
          'updatedAt':
          FieldValue.serverTimestamp(),
        });

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'Child details updated successfully',
                'मुलाची माहिती यशस्वीरित्या अपडेट झाली',
                'बच्चे की जानकारी सफलतापूर्वक अपडेट की गई',
              ),
            ),
          ),
        );
      }

      // =========================
      // ADD NEW CHILD
      // =========================

      else {
        childData['createdAt'] =
            FieldValue.serverTimestamp();

        await _firestore
            .collection('children')
            .add(childData);

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                context,
                'Child added successfully',
                'मूल यशस्वीरित्या जोडले',
                'बच्चा सफलतापूर्वक जोड़ा गया',
              ),
            ),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_t(
              context,
              'Error saving child',
              'मूल जतन करताना त्रुटी',
              'बच्चे को सहेजते समय त्रुटि',
            )}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // =========================
  // INPUT DECORATION
  // =========================

  InputDecoration _inputDecoration(
      String label, {
        IconData? icon,
        String? hint,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color:
        const Color(0xFFF45170),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        BorderSide.none,
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Color(0xFFF45170),
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _sectionTitle(
      String title,
      IconData icon,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        top: 20,
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
            const Color(0xFFF45170),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
              color:
              Color(0xFF29266F),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // DROPDOWN
  // =========================

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
    bool isGender = false,
    bool isStatus = false,
  }) {
    return DropdownButtonFormField<String>(
      initialValue:
      items.contains(value)
          ? value
          : null,
      decoration:
      _inputDecoration(
        requiredField
            ? '$label *'
            : label,
      ),
      items: items.map(
            (item) {
          String displayItem = item;

          if (isGender) {
            displayItem =
                _genderText(context, item);
          } else if (isStatus) {
            displayItem =
                _statusText(context, item);
          }

          return DropdownMenuItem<String>(
            value: item,
            child: Text(displayItem),
          );
        },
      ).toList(),
      onChanged: onChanged,
      validator: requiredField
          ? (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return _t(
            context,
            'Please select $label',
            'कृपया $label निवडा',
            'कृपया $label चुनें',
          );
        }

        return null;
      }
          : null,
    );
  }

  // =========================
  // REQUIRED TEXT FIELD
  // =========================

  Widget _requiredTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: _inputDecoration(
        '$label *',
        icon: icon,
        hint: hint,
      ),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return _t(
            context,
            'Please enter $label',
            'कृपया $label प्रविष्ट करा',
            'कृपया $label दर्ज करें',
          );
        }

        return null;
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI();

    final isEditMode = widget.isEditMode;

    final title = isEditMode
        ? _t(
      context,
      'Edit Child',
      'मुलाची माहिती संपादित करा',
      'बच्चे की जानकारी संपादित करें',
    )
        : _t(
      context,
      'Add Child',
      'मूल जोडा',
      'बच्चा जोड़ें',
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFFFFBF8),

      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // =========================
              // CHILD INFORMATION
              // =========================

              _sectionTitle(
                _t(
                  context,
                  'Child Information',
                  'मुलाची माहिती',
                  'बच्चे की जानकारी',
                ),
                Icons.child_care,
              ),

              _requiredTextField(
                controller:
                nameController,
                label: _t(
                  context,
                  'Full Name',
                  'पूर्ण नाव',
                  'पूरा नाम',
                ),
                icon:
                Icons.person_outline,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                dobController,
                readOnly: true,
                onTap:
                _selectDateOfBirth,
                decoration:
                _inputDecoration(
                  _t(
                    context,
                    'Date of Birth *',
                    'जन्मतारीख *',
                    'जन्म तिथि *',
                  ),
                  icon: Icons
                      .calendar_today_outlined,
                  hint:
                  _t(
                    context,
                    'Select date of birth',
                    'जन्मतारीख निवडा',
                    'जन्म तिथि चुनें',
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return _t(
                      context,
                      'Please select date of birth',
                      'कृपया जन्मतारीख निवडा',
                      'कृपया जन्म तिथि चुनें',
                    );
                  }

                  return null;
                },
              ),

              const SizedBox(height: 10),

              if (calculatedAge >= 0 &&
                  dobController.text
                      .trim()
                      .isNotEmpty)
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    12,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFCE4EC,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                  child: Text(
                    '${_t(
                      context,
                      'Calculated Age',
                      'गणना केलेले वय',
                      'गणना की गई आयु',
                    )}: $calculatedAge ${_t(
                      context,
                      'Years',
                      'वर्षे',
                      'वर्ष',
                    )}',
                    style:
                    const TextStyle(
                      color:
                      Color(0xFFF45170),
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              _dropdown(
                label: _t(
                  context,
                  'Gender',
                  'लिंग',
                  'लिंग',
                ),
                value:
                selectedGender,
                items: const [
                  'Male',
                  'Female',
                  'Other',
                ],
                isGender: true,
                requiredField: true,
                onChanged:
                    (value) {
                  setState(() {
                    selectedGender =
                        value;
                  });
                },
              ),

              // =========================
              // PARENT INFORMATION
              // =========================

              _sectionTitle(
                _t(
                  context,
                  'Parent / Guardian Information',
                  'पालक / संरक्षकाची माहिती',
                  'माता-पिता / अभिभावक की जानकारी',
                ),
                Icons.family_restroom,
              ),

              _requiredTextField(
                controller:
                motherNameController,
                label: _t(
                  context,
                  "Mother's Name",
                  'आईचे नाव',
                  'माता का नाम',
                ),
                icon:
                Icons.woman_outlined,
              ),

              const SizedBox(height: 14),

              _requiredTextField(
                controller:
                fatherNameController,
                label: _t(
                  context,
                  "Father's Name",
                  'वडिलांचे नाव',
                  'पिता का नाम',
                ),
                icon:
                Icons.man_outlined,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                guardianNameController,
                decoration:
                _inputDecoration(
                  _t(
                    context,
                    "Guardian's Name",
                    'पालकाचे नाव',
                    'अभिभावक का नाम',
                  ),
                  icon:
                  Icons.people_outline,
                ),
              ),

              const SizedBox(height: 14),

              _requiredTextField(
                controller:
                motherContactController,
                label: _t(
                  context,
                  "Mother's Contact Number",
                  'आईचा संपर्क क्रमांक',
                  'माता का संपर्क नंबर',
                ),
                icon:
                Icons.phone_outlined,
                keyboardType:
                TextInputType.phone,
                maxLength: 10,
              ),

              const SizedBox(height: 5),

              _requiredTextField(
                controller:
                fatherContactController,
                label: _t(
                  context,
                  "Father's Contact Number",
                  'वडिलांचा संपर्क क्रमांक',
                  'पिता का संपर्क नंबर',
                ),
                icon:
                Icons.phone_outlined,
                keyboardType:
                TextInputType.phone,
                maxLength: 10,
              ),

              const SizedBox(height: 5),

              _requiredTextField(
                controller:
                addressController,
                label: _t(
                  context,
                  'Address',
                  'पत्ता',
                  'पता',
                ),
                icon:
                Icons.location_on_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                anganwadiController,
                decoration:
                _inputDecoration(
                  _t(
                    context,
                    'Anganwadi Center',
                    'अंगणवाडी केंद्र',
                    'आंगनवाड़ी केंद्र',
                  ),
                  icon:
                  Icons.home_work_outlined,
                ),
              ),

              // =========================
              // GROWTH
              // =========================

              _sectionTitle(
                _t(
                  context,
                  'Growth Information',
                  'वाढीची माहिती',
                  'विकास की जानकारी',
                ),
                Icons.monitor_weight_outlined,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                    TextFormField(
                      controller:
                      heightController,
                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),
                      onChanged:
                          (_) {
                        setState(
                              () {},
                        );
                      },
                      decoration:
                      _inputDecoration(
                        _t(
                          context,
                          'Height',
                          'उंची',
                          'ऊंचाई',
                        ),
                        hint: 'cm',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                    TextFormField(
                      controller:
                      weightController,
                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),
                      onChanged:
                          (_) {
                        setState(
                              () {},
                        );
                      },
                      decoration:
                      _inputDecoration(
                        _t(
                          context,
                          'Weight',
                          'वजन',
                          'वज़न',
                        ),
                        hint: 'kg',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                muacController,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                _inputDecoration(
                  'MUAC',
                  hint:
                  _t(
                    context,
                    'cm (optional)',
                    'सेमी (ऐच्छिक)',
                    'सेमी (वैकल्पिक)',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (bmi != null)
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFCE4EC,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                  child: Text(
                    '${_t(
                      context,
                      'Calculated BMI',
                      'गणना केलेला BMI',
                      'गणना किया गया BMI',
                    )}: ${bmi.toStringAsFixed(2)}',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Color(0xFF29266F),
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              _dropdown(
                label:
                _t(
                  context,
                  'Growth Status',
                  'वाढीची स्थिती',
                  'विकास की स्थिति',
                ),
                value:
                selectedGrowthStatus,
                items: const [
                  'Normal',
                  'Moderate',
                  'Severe',
                ],
                isStatus: true,
                onChanged:
                    (value) {
                  setState(() {
                    selectedGrowthStatus =
                        value;
                  });
                },
              ),

              // =========================
              // NUTRITION
              // =========================

              _sectionTitle(
                _t(
                  context,
                  'Nutrition Information',
                  'पोषणाची माहिती',
                  'पोषण की जानकारी',
                ),
                Icons.restaurant_outlined,
              ),

              _dropdown(
                label:
                _t(
                  context,
                  'Nutrition Status',
                  'पोषण स्थिती',
                  'पोषण की स्थिति',
                ),
                value:
                selectedNutritionStatus,
                items: const [
                  'Normal',
                  'Moderate',
                  'Severe',
                ],
                isStatus: true,
                onChanged:
                    (value) {
                  setState(() {
                    selectedNutritionStatus =
                        value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // =========================
              // HEALTH
              // =========================

              _sectionTitle(
                _t(
                  context,
                  'Health Information',
                  'आरोग्याची माहिती',
                  'स्वास्थ्य की जानकारी',
                ),
                Icons.health_and_safety_outlined,
              ),

              _dropdown(
                label:
                _t(
                  context,
                  'Health Status',
                  'आरोग्य स्थिती',
                  'स्वास्थ्य की स्थिति',
                ),
                value:
                selectedHealthStatus,
                items: const [
                  'Healthy',
                  'Needs Attention',
                  'Under Treatment',
                ],
                isStatus: true,
                onChanged:
                    (value) {
                  setState(() {
                    selectedHealthStatus =
                        value;
                  });
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                medicalNotesController,
                maxLines: 4,
                decoration:
                _inputDecoration(
                  _t(
                    context,
                    'Medical Notes',
                    'वैद्यकीय नोंदी',
                    'चिकित्सा नोट्स',
                  ),
                  icon:
                  Icons.notes_outlined,
                  hint:
                  _t(
                    context,
                    'Enter any relevant notes',
                    'संबंधित नोंदी प्रविष्ट करा',
                    'संबंधित नोट्स दर्ज करें',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // SAVE BUTTON
              // =========================

              SizedBox(
                width:
                double.infinity,
                height: 55,
                child:
                ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : _saveChild,
                  icon: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons
                        .save_outlined,
                  ),
                  label: Text(
                    isSaving
                        ? _t(
                      context,
                      'SAVING...',
                      'जतन करत आहे...',
                      'सहेजा जा रहा है...',
                    )
                        : widget.isEditMode
                        ? _t(
                      context,
                      'UPDATE CHILD',
                      'मुलाची माहिती अपडेट करा',
                      'बच्चे की जानकारी अपडेट करें',
                    )
                        : _t(
                      context,
                      'SAVE CHILD',
                      'मूल जतन करा',
                      'बच्चे को सहेजें',
                    ),
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                      letterSpacing:
                      0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width:
                double.infinity,
                height: 50,
                child:
                OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                  Text(
                    _t(
                      context,
                      'CANCEL',
                      'रद्द करा',
                      'रद्द करें',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}