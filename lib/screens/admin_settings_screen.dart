import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../main.dart';
import 'login_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool notificationsEnabled = true;

  String selectedLanguage = 'English';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  String _languageName(BuildContext context) {
    final languageCode =
        AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') {
      return 'मराठी';
    }

    if (languageCode == 'hi') {
      return 'हिंदी';
    }

    return 'English';
  }

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // =========================
  // LOAD ADMIN LANGUAGE
  // =========================

  Future<void> _loadLanguagePreference() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final document =
      await _firestore.collection('users').doc(user.uid).get();

      if (!document.exists) return;

      final data = document.data();

      if (data == null) return;

      final savedLanguage = data['language'];

      if (savedLanguage != 'en' &&
          savedLanguage != 'mr' &&
          savedLanguage != 'hi') {
        return;
      }

      String languageName = 'English';

      if (savedLanguage == 'mr') {
        languageName = 'Marathi';
      } else if (savedLanguage == 'hi') {
        languageName = 'Hindi';
      }

      if (!mounted) return;

      setState(() {
        selectedLanguage = languageName;
      });

      final currentLanguage =
          AppLocalizations.of(context).locale.languageCode;

      if (currentLanguage != savedLanguage) {
        Locale savedLocale = const Locale('en');

        if (savedLanguage == 'mr') {
          savedLocale = const Locale('mr');
        } else if (savedLanguage == 'hi') {
          savedLocale = const Locale('hi');
        }

        AnganCareApp.changeLanguage(
          context,
          savedLocale,
        );
      }
    } catch (e) {
      // Keep the default English language if preference loading fails.
    }
  }

  // =========================
  // SAVE ADMIN LANGUAGE
  // =========================

  Future<void> _saveLanguagePreference(String languageCode) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'language': languageCode,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Language preference could not be saved.',
              'भाषेची निवड जतन करता आली नाही.',
              'भाषा प्राथमिकता सहेजी नहीं जा सकी।',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // =========================
  // LANGUAGE
  // =========================

  void _showLanguageDialog() {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        String temporaryLanguage = selectedLanguage;

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: Text(
                localizations.selectLanguage,
                style: const TextStyle(
                  color: Color(0xFF29266F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: RadioGroup<String>(
                groupValue: temporaryLanguage,
                onChanged: (value) {
                  if (value == null) return;

                  setDialogState(() {
                    temporaryLanguage = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'English',
                      activeColor: const Color(0xFFF45170),
                      title: Text(localizations.english),
                    ),
                    RadioListTile<String>(
                      value: 'Marathi',
                      activeColor: const Color(0xFFF45170),
                      title: Text(localizations.marathi),
                    ),
                    RadioListTile<String>(
                      value: 'Hindi',
                      activeColor: const Color(0xFFF45170),
                      title: Text(localizations.hindi),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    localizations.cancel,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Locale newLocale;
                    String languageCode;

                    if (temporaryLanguage == 'Marathi') {
                      newLocale = const Locale('mr');
                      languageCode = 'mr';
                    } else if (temporaryLanguage == 'Hindi') {
                      newLocale = const Locale('hi');
                      languageCode = 'hi';
                    } else {
                      newLocale = const Locale('en');
                      languageCode = 'en';
                    }

                    setState(() {
                      selectedLanguage = temporaryLanguage;
                    });

                    Navigator.pop(dialogContext);

                    // Change language for the current Admin session.
                    AnganCareApp.changeLanguage(
                      context,
                      newLocale,
                    );

                    // Save language only for this Admin account.
                    await _saveLanguagePreference(
                      languageCode,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF45170),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    localizations.save,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // CHANGE PASSWORD
  // =========================

  Future<Map<String, String>?> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final result = await showDialog<Map<String, String>>(
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
                  'Change Password',
                  'पासवर्ड बदला',
                  'पासवर्ड बदलें',
                ),
                style: const TextStyle(
                  color: Color(0xFF29266F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Current Password',
                          'सध्याचा पासवर्ड',
                          'वर्तमान पासवर्ड',
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureCurrent = !obscureCurrent;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'New Password',
                          'नवीन पासवर्ड',
                          'नया पासवर्ड',
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: _t(
                          context,
                          'Confirm New Password',
                          'नवीन पासवर्डची पुष्टी करा',
                          'नए पासवर्ड की पुष्टि करें',
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _t(
                          context,
                          'Password must be at least 6 characters.',
                          'पासवर्ड किमान 6 अक्षरांचा असावा.',
                          'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।',
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    _t(
                      context,
                      'CANCEL',
                      'रद्द करा',
                      'रद्द करें',
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final currentPassword =
                    currentPasswordController.text.trim();

                    final newPassword =
                    newPasswordController.text.trim();

                    final confirmPassword =
                    confirmPasswordController.text.trim();

                    if (currentPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              context,
                              'Please enter your current password.',
                              'कृपया तुमचा सध्याचा पासवर्ड प्रविष्ट करा.',
                              'कृपया अपना वर्तमान पासवर्ड दर्ज करें।',
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              context,
                              'Please enter a new password.',
                              'कृपया नवीन पासवर्ड प्रविष्ट करा.',
                              'कृपया नया पासवर्ड दर्ज करें।',
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPassword.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              context,
                              'New password must be at least 6 characters.',
                              'नवीन पासवर्ड किमान 6 अक्षरांचा असावा.',
                              'नया पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।',
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              context,
                              'New passwords do not match.',
                              'नवीन पासवर्ड जुळत नाहीत.',
                              'नए पासवर्ड मेल नहीं खाते।',
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      {
                        'currentPassword': currentPassword,
                        'newPassword': newPassword,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF45170),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _t(
                      context,
                      'CHANGE PASSWORD',
                      'पासवर्ड बदला',
                      'पासवर्ड बदलें',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    return result;
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Unable to find administrator account.',
              'प्रशासक खाते शोधता आले नाही.',
              'व्यवस्थापक खाता नहीं मिल सका।',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final passwordData = await _showChangePasswordDialog();

    if (passwordData == null) return;

    final currentPassword = passwordData['currentPassword']!;
    final newPassword = passwordData['newPassword']!;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      await user.updatePassword(
        newPassword,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              _t(
                context,
                'Password Changed',
                'पासवर्ड बदलला',
                'पासवर्ड बदल दिया गया',
              ),
              style: const TextStyle(
                color: Color(0xFF29266F),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              _t(
                context,
                'Your administrator password has been changed successfully.',
                'तुमचा प्रशासक पासवर्ड यशस्वीरित्या बदलला आहे.',
                'आपका व्यवस्थापक पासवर्ड सफलतापूर्वक बदल दिया गया है।',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFFF45170),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = _t(
        context,
        'Unable to change password.',
        'पासवर्ड बदलता आला नाही.',
        'पासवर्ड बदलने में असमर्थ।',
      );

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = _t(
          context,
          'Current password is incorrect.',
          'सध्याचा पासवर्ड चुकीचा आहे.',
          'वर्तमान पासवर्ड गलत है।',
        );
      } else if (e.code == 'weak-password') {
        message = _t(
          context,
          'The new password is too weak.',
          'नवीन पासवर्ड खूप कमकुवत आहे.',
          'नया पासवर्ड बहुत कमजोर है।',
        );
      } else if (e.code == 'requires-recent-login') {
        message = _t(
          context,
          'Please log in again and try changing the password.',
          'कृपया पुन्हा लॉगिन करून पासवर्ड बदलण्याचा प्रयत्न करा.',
          'कृपया फिर से लॉगिन करके पासवर्ड बदलने का प्रयास करें।',
        );
      } else if (e.code == 'network-request-failed') {
        message = _t(
          context,
          'Please check your internet connection.',
          'कृपया तुमचे इंटरनेट कनेक्शन तपासा.',
          'कृपया अपना इंटरनेट कनेक्शन जांचें।',
        );
      } else if (e.code == 'too-many-requests') {
        message = _t(
          context,
          'Too many attempts. Please try again later.',
          'खूप प्रयत्न झाले आहेत. कृपया नंतर पुन्हा प्रयत्न करा.',
          'बहुत अधिक प्रयास हुए। कृपया बाद में फिर प्रयास करें।',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Something went wrong. Please try again.',
              'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.',
              'कुछ गलत हो गया। कृपया फिर प्रयास करें।',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // HELP & SUPPORT
  // =========================

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _t(
              context,
              'Help & Support',
              'मदत आणि सहाय्य',
              'मदद और सहायता',
            ),
            style: const TextStyle(
              color: Color(0xFF29266F),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  context,
                  'ANGANCARE Support',
                  'अंगणकेअर सहाय्य',
                  'आंगनकेयर सहायता',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF45170),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t(
                  context,
                  'If you are facing a problem with the ANGANCARE application, please contact your system administrator or support team.',
                  'अंगणकेअर अनुप्रयोगात काही समस्या येत असल्यास, कृपया तुमच्या सिस्टम प्रशासकाशी किंवा सहाय्य टीमशी संपर्क साधा.',
                  'यदि आपको आंगनकेयर एप्लिकेशन में कोई समस्या आ रही है, तो कृपया अपने सिस्टम व्यवस्थापक या सहायता टीम से संपर्क करें।',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF45170),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        'For account, worker, child records, or announcement-related issues, contact the authorized administrator.',
                        'खाते, कार्यकर्ता, मुलांच्या नोंदी किंवा घोषणांशी संबंधित समस्यांसाठी अधिकृत प्रशासकाशी संपर्क साधा.',
                        'खाते, कार्यकर्ता, बच्चे के रिकॉर्ड या घोषणा संबंधी समस्याओं के लिए अधिकृत व्यवस्थापक से संपर्क करें।',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                _t(
                  context,
                  'CLOSE',
                  'बंद करा',
                  'बंद करें',
                ),
                style: const TextStyle(
                  color: Color(0xFFF45170),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.settings,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t(
                context,
                'Admin Settings',
                'प्रशासक सेटिंग्ज',
                'व्यवस्थापक सेटिंग्स',
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29266F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                context,
                'Manage your administrator preferences.',
                'तुमच्या प्रशासकाच्या प्राधान्यक्रमांचे व्यवस्थापन करा.',
                'अपनी व्यवस्थापक प्राथमिकताओं को प्रबंधित करें।',
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 25),
            _sectionTitle(
              _t(
                context,
                'Account',
                'खाते',
                'खाता',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 27,
                    backgroundColor: Color(0xFFFCE4EC),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFFF45170),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(
                            context,
                            'Administrator',
                            'प्रशासक',
                            'व्यवस्थापक',
                          ),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF29266F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Admin account',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _sectionTitle(
              _t(
                context,
                'Preferences',
                'प्राधान्ये',
                'प्राथमिकताएँ',
              ),
            ),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.notifications_outlined,
              title: localizations.notifications,
              subtitle: _t(
                context,
                'Receive admin notifications',
                'प्रशासक सूचना प्राप्त करा',
                'व्यवस्थापक सूचनाएँ प्राप्त करें',
              ),
              trailing: Switch(
                value: notificationsEnabled,
                activeThumbColor: const Color(0xFFF45170),
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.language_outlined,
              title: localizations.language,
              subtitle: _languageName(context),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
              onTap: _showLanguageDialog,
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.lock_outline,
              title: localizations.changePassword,
              subtitle: _t(
                context,
                'Change your administrator password',
                'तुमचा प्रशासक पासवर्ड बदला',
                'अपना व्यवस्थापक पासवर्ड बदलें',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
              onTap: _changePassword,
            ),
            const SizedBox(height: 25),
            _sectionTitle(
              _t(
                context,
                'Application',
                'अनुप्रयोग',
                'एप्लिकेशन',
              ),
            ),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.info_outline,
              title: localizations.about,
              subtitle: localizations.version,
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        localizations.appName,
                        style: const TextStyle(
                          color: Color(0xFF29266F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        _t(
                          context,
                          'ANGANCARE is a healthcare management application for Anganwadi workers and administrators.',
                          'अंगणकेअर हे अंगणवाडी कार्यकर्ते आणि प्रशासकांसाठी आरोग्य व्यवस्थापन अनुप्रयोग आहे.',
                          'आंगनकेयर आंगनवाड़ी कार्यकर्ताओं और व्यवस्थापकों के लिए स्वास्थ्य प्रबंधन एप्लिकेशन है।',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            localizations.close,
                            style: const TextStyle(
                              color: Color(0xFFF45170),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.help_outline,
              title: localizations.helpSupport,
              subtitle: _t(
                context,
                'Get help with ANGANCARE',
                'अंगणकेअरबद्दल मदत मिळवा',
                'आंगनकेयर के लिए सहायता प्राप्त करें',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
              onTap: _showHelpSupport,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: Text(
                  localizations.logout.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: Text(
                '${localizations.appName} • ${_t(context, 'Admin Panel', 'प्रशासक पॅनेल', 'व्यवस्थापक पैनल')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF29266F),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF45170),
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}