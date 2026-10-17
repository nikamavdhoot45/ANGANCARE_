import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../dashboard/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  // Selected login type
  String selectedRole = 'worker';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // APPLY USER LANGUAGE
  // ============================================================

  Future<void> _applyUserLanguage(
    Map<String, dynamic>? data,
  ) async {
    String languageCode = 'en';

    final savedLanguage = data?['language'];

    if (savedLanguage == 'mr') {
      languageCode = 'mr';
    } else if (savedLanguage == 'hi') {
      languageCode = 'hi';
    } else if (savedLanguage == 'en') {
      languageCode = 'en';
    }

    Locale locale;

    if (languageCode == 'mr') {
      locale = const Locale('mr');
    } else if (languageCode == 'hi') {
      locale = const Locale('hi');
    } else {
      locale = const Locale('en');
    }

    if (!mounted) return;

    AnganCareApp.changeLanguage(
      context,
      locale,
    );

    // Give Flutter a moment to apply the new locale
    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Firebase Authentication
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Firebase did not return a user.');
      }

      // ============================================================
      // ADMIN LOGIN
      // ============================================================
      if (selectedRole == 'admin') {
        final userDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDocument.exists) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showError(
            'Login successful, but your Admin profile was not found in Firestore.',
          );

          return;
        }

        final data = userDocument.data();

        final String role =
            (data?['role'] ?? '').toString().trim().toLowerCase();

        if (role != 'admin') {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showError(
            'This account is not registered as an Admin.',
          );

          return;
        }

        // Load THIS ADMIN'S saved language
        await _applyUserLanguage(data);

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // ============================================================
      // WORKER LOGIN
      // ============================================================
      if (selectedRole == 'worker') {
        final workerDocument = await FirebaseFirestore.instance
            .collection('workers')
            .doc(user.uid)
            .get();

        if (!workerDocument.exists) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showError(
            'Login successful, but your Worker account was not found in Firestore.',
          );

          return;
        }

        final data = workerDocument.data();

        final String role =
            (data?['role'] ?? '').toString().trim().toLowerCase();

        if (role != 'worker') {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showError(
            'This account is not registered as a Worker.',
          );

          return;
        }

        final bool isActive = data?['isActive'] == true;

        if (!isActive) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showError(
            'Your Worker account is currently inactive.\n\n'
            'Please contact the administrator.',
          );

          return;
        }

        // Load THIS WORKER'S saved language
        await _applyUserLanguage(data);

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // ============================================================
      // INVALID LOGIN TYPE
      // ============================================================
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showError(
        'Invalid login type.\n\n'
        'Please select Admin or Worker.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = 'Login failed.\n\n'
              'Firebase error: ${e.message ?? e.code}';
      }

      _showError(message);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showError(
        'Firestore error.\n\n'
        'Code: ${e.code}\n'
        'Message: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showError(
        'Something went wrong.\n\n$e',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter your email first.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your inbox.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showError(
        e.message ?? 'Unable to send password reset email.',
      );
    }
  }

  Widget _buildRoleButton({
    required String role,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () {
                setState(() {
                  selectedRole = role;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 58,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF45170) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFFF45170) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 23,
                color: isSelected ? Colors.white : const Color(0xFF29266F),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF29266F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // LOGO
                  Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCE4EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.child_care,
                      size: 55,
                      color: Color(0xFFF45170),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // APP NAME
                  const Text(
                    'ANGANCARE',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29266F),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Child Health & Nutrition Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOGIN TYPE
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login as',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29266F),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildRoleButton(
                        role: 'admin',
                        title: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildRoleButton(
                        role: 'worker',
                        title: 'Worker',
                        icon: Icons.person_outline,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // EMAIL
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFF45170),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFF45170),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }

                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFFF45170),
                      ),
                      suffixIcon: IconButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFF45170),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFF45170),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFFF45170),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // INFORMATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Login using the email and password registered in Firebase Authentication.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF29266F),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
