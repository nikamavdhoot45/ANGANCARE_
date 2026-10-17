import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../main.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _t(BuildContext context, String key, String fallback) {
    final value = AppLocalizations.of(context).text(key);
    return value == key ? fallback : value;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String email =
        user?.email ?? _t(context, 'noEmailAvailable', 'No email available');

    final String workerName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : _t(context, 'anganwadiWorker', 'Anganwadi Worker');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFFFFE1E7),
                  child: Icon(
                    Icons.person,
                    size: 52,
                    color: Color(0xFFF45170),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  workerName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _t(
                    context,
                    'anganwadiWorker',
                    'Anganwadi Worker',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFF45170),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _t(context, 'account', 'Account'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _profileOption(
            context,
            icon: Icons.lock_outline,
            title: _t(
              context,
              'changePassword',
              'Change Password',
            ),
            subtitle: _t(
              context,
              'updateAccountPassword',
              'Update your account password',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _profileOption(
            context,
            icon: Icons.notifications_none,
            title: _t(
              context,
              'notifications',
              'Notifications',
            ),
            subtitle: _t(
              context,
              'manageNotificationPreferences',
              'Manage notification preferences',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _profileOption(
            context,
            icon: Icons.language,
            title: _t(
              context,
              'language',
              'Language',
            ),
            subtitle: _t(
              context,
              'english',
              'English',
            ),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _t(context, 'support', 'Support'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _profileOption(
            context,
            icon: Icons.help_outline,
            title: _t(
              context,
              'helpSupport',
              'Help & Support',
            ),
            subtitle: _t(
              context,
              'getHelpContactSupport',
              'Get help or contact support',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _profileOption(
            context,
            icon: Icons.info_outline,
            title: _t(
              context,
              'about',
              'About ANGANCARE',
            ),
            subtitle: _t(
              context,
              'appInformation',
              'App information',
            ),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFF44336),
              ),
              label: Text(
                _t(context, 'logout', 'Logout'),
                style: const TextStyle(
                  color: Color(0xFFF44336),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFF44336),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _t(context, 'appName', 'ANGANCARE'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _t(context, 'version', 'Version 1.0.0'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),

          // COPYRIGHT
          const Text(
            '© 2026 ANGANCARE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Developed by Avdhoot Sunil Nikam',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'All Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _profileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
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
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLanguage = AppLocalizations.of(context).locale.languageCode;

    String selectedLanguage;

    if (currentLanguage == 'mr') {
      selectedLanguage = 'Marathi';
    } else if (currentLanguage == 'hi') {
      selectedLanguage = 'Hindi';
    } else {
      selectedLanguage = 'English';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(
                _t(
                  dialogContext,
                  'selectLanguage',
                  'Select Language',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: RadioGroup<String>(
                groupValue: selectedLanguage,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedLanguage = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'English',
                      title: Text(
                        _t(
                          dialogContext,
                          'english',
                          'English',
                        ),
                      ),
                      activeColor: const Color(0xFFF45170),
                    ),
                    RadioListTile<String>(
                      value: 'Hindi',
                      title: Text(
                        _t(
                          dialogContext,
                          'hindi',
                          'हिन्दी',
                        ),
                      ),
                      activeColor: const Color(0xFFF45170),
                    ),
                    RadioListTile<String>(
                      value: 'Marathi',
                      title: Text(
                        _t(
                          dialogContext,
                          'marathi',
                          'मराठी',
                        ),
                      ),
                      activeColor: const Color(0xFFF45170),
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
                      dialogContext,
                      'cancel',
                      'Cancel',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String languageCode = 'en';
                    Locale newLocale = const Locale('en');

                    if (selectedLanguage == 'Marathi') {
                      languageCode = 'mr';
                      newLocale = const Locale('mr');
                    } else if (selectedLanguage == 'Hindi') {
                      languageCode = 'hi';
                      newLocale = const Locale('hi');
                    }

                    final user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('workers')
                          .doc(user.uid)
                          .set(
                        {
                          'language': languageCode,
                        },
                        SetOptions(merge: true),
                      );
                    }

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    AnganCareApp.changeLanguage(
                      context,
                      newLocale,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_t(
                            context,
                            'languageSelected',
                            'Language selected',
                          )}: $selectedLanguage',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    _t(
                      dialogContext,
                      'save',
                      'Save',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'ANGANCARE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF45170),
            ),
          ),
          content: Text(
            _t(
              context,
              'aboutDescription',
              'ANGANCARE is a child health monitoring application '
                  'designed to help Anganwadi Workers manage children, '
                  'growth, nutrition, health and vaccination records.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                _t(context, 'close', 'Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _t(context, 'logout', 'Logout'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            _t(
              context,
              'confirmLogout',
              'Are you sure you want to logout?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                _t(context, 'cancel', 'Cancel'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) {
                  return;
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                _t(context, 'logout', 'Logout'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// CHANGE PASSWORD
// ============================================================

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;
  bool isLoading = false;

  String _t(String key, String fallback) {
    final value = AppLocalizations.of(context).text(key);
    return value == key ? fallback : value;
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    final current = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'pleaseFillAllFields',
              'Please fill all fields',
            ),
          ),
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'passwordMinimumSix',
              'New password must contain at least 6 characters',
            ),
          ),
        ),
      );
      return;
    }

    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'passwordMismatch',
              'New password and confirm password do not match',
            ),
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'noLoggedInAccount',
              'No logged-in account found.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'passwordChangedSuccessfully',
              'Password changed successfully',
            ),
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String message = _t(
        'unableToChangePassword',
        'Unable to change password.',
      );

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = _t(
          'currentPasswordIncorrect',
          'Current password is incorrect.',
        );
      } else if (e.code == 'weak-password') {
        message = _t(
          'newPasswordWeak',
          'The new password is too weak.',
        );
      } else if (e.code == 'requires-recent-login') {
        message = _t(
          'pleaseLoginAgain',
          'Please login again before changing your password.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
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
            _t(
              'somethingWentWrong',
              'Something went wrong. Please try again.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t('changePassword', 'Change Password'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 55,
                    color: Color(0xFFF45170),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t(
                      'updatePassword',
                      'Update Password',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _t(
                      'createNewPassword',
                      'Create a new password for your account',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _passwordField(
              controller: currentPasswordController,
              label: _t(
                'currentPassword',
                'Current Password',
              ),
              hidden: hideCurrent,
              onToggle: () {
                setState(() {
                  hideCurrent = !hideCurrent;
                });
              },
            ),
            const SizedBox(height: 14),
            _passwordField(
              controller: newPasswordController,
              label: _t(
                'newPassword',
                'New Password',
              ),
              hidden: hideNew,
              onToggle: () {
                setState(() {
                  hideNew = !hideNew;
                });
              },
            ),
            const SizedBox(height: 14),
            _passwordField(
              controller: confirmPasswordController,
              label: _t(
                'confirmNewPassword',
                'Confirm New Password',
              ),
              hidden: hideConfirm,
              onToggle: () {
                setState(() {
                  hideConfirm = !hideConfirm;
                });
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : changePassword,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _t(
                          'changePassword',
                          'Change Password',
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool hidden,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: hidden,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFFF45170),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOTIFICATION SETTINGS
// ============================================================

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool allNotifications = true;
  bool vaccination = true;
  bool health = true;
  bool growth = true;
  bool nutrition = false;

  String _t(String key, String fallback) {
    final value = AppLocalizations.of(context).text(key);
    return value == key ? fallback : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t('notifications', 'Notifications'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _notificationTile(
              title: _t(
                'allNotifications',
                'All Notifications',
              ),
              subtitle: _t(
                'enableDisableNotifications',
                'Enable or disable all notifications',
              ),
              value: allNotifications,
              onChanged: (value) {
                setState(() {
                  allNotifications = value;
                  vaccination = value;
                  health = value;
                  growth = value;
                  nutrition = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _notificationTile(
              title: _t(
                'vaccinationReminders',
                'Vaccination Reminders',
              ),
              subtitle: _t(
                'upcomingVaccinationReminders',
                'Get reminders for upcoming vaccinations',
              ),
              value: vaccination,
              onChanged: allNotifications
                  ? (value) {
                      setState(() {
                        vaccination = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 10),
            _notificationTile(
              title: _t(
                'healthCheckups',
                'Health Checkups',
              ),
              subtitle: _t(
                'healthCheckupReminders',
                'Get reminders for health checkups',
              ),
              value: health,
              onChanged: allNotifications
                  ? (value) {
                      setState(() {
                        health = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 10),
            _notificationTile(
              title: _t(
                'growthUpdates',
                'Growth Updates',
              ),
              subtitle: _t(
                'growthMonitoringReminders',
                'Receive growth monitoring reminders',
              ),
              value: growth,
              onChanged: allNotifications
                  ? (value) {
                      setState(() {
                        growth = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 10),
            _notificationTile(
              title: _t(
                'nutritionUpdates',
                'Nutrition Updates',
              ),
              subtitle: _t(
                'nutritionReminders',
                'Receive nutrition reminders',
              ),
              value: nutrition,
              onChanged: allNotifications
                  ? (value) {
                      setState(() {
                        nutrition = value;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
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
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFF45170),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFF45170),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELP & SUPPORT
// ============================================================

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  String selectedIssue = 'Technical Issue';

  final List<String> issues = [
    'Technical Issue',
    'Account Problem',
    'Children Records',
    'Growth Report',
    'Nutrition',
    'Vaccination',
    'Health',
    'Other',
  ];

  String _t(String key, String fallback) {
    final value = AppLocalizations.of(context).text(key);
    return value == key ? fallback : value;
  }

  String _issueText(String issue) {
    final map = <String, String>{
      'Technical Issue': _t('technicalIssue', 'Technical Issue'),
      'Account Problem': _t('accountProblem', 'Account Problem'),
      'Children Records': _t('childrenRecords', 'Children Records'),
      'Growth Report': _t('growthReport', 'Growth Report'),
      'Nutrition': _t('nutrition', 'Nutrition'),
      'Vaccination': _t('vaccination', 'Vaccination'),
      'Health': _t('health', 'Health'),
      'Other': _t('other', 'Other'),
    };

    return map[issue] ?? issue;
  }

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      emailController.text = user.email ?? '';
      nameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'pleaseFillRequiredFields',
              'Please fill all required fields',
            ),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _t(
            'supportRequestSubmitted',
            'Support request submitted successfully',
          ),
        ),
      ),
    );

    messageController.clear();

    setState(() {
      selectedIssue = 'Technical Issue';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t('helpSupport', 'Help & Support'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 50,
                    color: Color(0xFFF45170),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _t(
                      'howCanWeHelp',
                      'How can we help?',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _t(
                      'supportFormDescription',
                      'Fill out the form and our support team will help you.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              _t(
                'contactSupport',
                'Contact Support',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: _t(
                  'yourName',
                  'Your Name',
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFF45170),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _t(
                  'emailAddress',
                  'Email Address',
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFF45170),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedIssue,
              decoration: InputDecoration(
                labelText: _t(
                  'issueType',
                  'Issue Type',
                ),
                prefixIcon: const Icon(
                  Icons.category_outlined,
                  color: Color(0xFFF45170),
                ),
              ),
              items: issues.map((issue) {
                return DropdownMenuItem<String>(
                  value: issue,
                  child: Text(
                    _issueText(issue),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedIssue = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: _t(
                  'describeIssue',
                  'Describe your issue',
                ),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(
                    bottom: 75,
                  ),
                  child: Icon(
                    Icons.message_outlined,
                    color: Color(0xFFF45170),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: submitForm,
                icon: const Icon(Icons.send),
                label: Text(
                  _t(
                    'submitRequest',
                    'Submit Request',
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'otherWaysToGetHelp',
                      'Other Ways to Get Help',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFF45170),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _t(
                            'supportEmailWillBeAdded',
                            'Support email will be added',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        color: Color(0xFFF45170),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _t(
                            'supportPhoneWillBeAdded',
                            'Support phone will be added',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
