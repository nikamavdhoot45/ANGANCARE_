import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController centerController = TextEditingController();

  bool isSaving = false;
  bool obscurePassword = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    centerController.dispose();
    super.dispose();
  }

  // =========================
  // ADD / REPAIR WORKER
  // =========================

  Future<void> _addWorker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    FirebaseApp? secondaryApp;

    User? workerUser;

    // True only when this screen created a brand-new
    // Firebase Authentication account.
    bool createdNewAuthAccount = false;

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();
      final phone = phoneController.text.trim();
      final centerId = centerController.text.trim();

      // ============================================================
      // CREATE SECONDARY FIREBASE APP
      // ============================================================

      secondaryApp = await Firebase.initializeApp(
        name:
        'workerCreation_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final workerAuth = FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      // ============================================================
      // TRY TO CREATE NEW AUTH ACCOUNT
      // ============================================================

      try {
        final credential =
        await workerAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        workerUser = credential.user;
        createdNewAuthAccount = true;
      } on FirebaseAuthException catch (e) {
        // ==========================================================
        // EXISTING AUTH ACCOUNT
        //
        // This repairs a worker account that was created in Firebase
        // Authentication earlier but never received its Firestore
        // workers/{uid} document.
        // ==========================================================

        if (e.code != 'email-already-in-use') {
          rethrow;
        }

        try {
          final existingCredential =
          await workerAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          workerUser = existingCredential.user;
          createdNewAuthAccount = false;
        } on FirebaseAuthException catch (loginError) {
          if (loginError.code == 'wrong-password' ||
              loginError.code == 'invalid-credential') {
            throw FirebaseAuthException(
              code: 'existing-account-password-mismatch',
              message:
              'This email already exists in Firebase Authentication, '
                  'but the temporary password entered here is incorrect.',
            );
          }

          rethrow;
        }
      }

      if (workerUser == null) {
        throw Exception(
          'Worker Firebase Authentication account could not be created or found.',
        );
      }

      // ============================================================
      // SAVE / REPAIR WORKER FIRESTORE DOCUMENT
      // ============================================================

      await _firestore
          .collection('workers')
          .doc(workerUser.uid)
          .set(
        {
          'uid': workerUser.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'centerId': centerId,
          'role': 'worker',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ============================================================
      // CLEAN UP SECONDARY AUTH SESSION
      // ============================================================

      try {
        await workerAuth.signOut();
      } catch (_) {}

      try {
        await secondaryApp.delete();
      } catch (_) {}

      secondaryApp = null;

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      // ============================================================
      // SUCCESS MESSAGE
      // ============================================================

      final String message = createdNewAuthAccount
          ? 'Worker added successfully.\n\n'
          'The worker can now log in using the email and temporary password.'
          : 'Worker account repaired successfully.\n\n'
          'The existing Firebase Authentication account is now linked '
          'to the worker profile in Firestore.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      // ============================================================
      // CLEANUP
      // ============================================================

      if (createdNewAuthAccount && workerUser != null) {
        try {
          await workerUser.delete();
        } catch (_) {}
      }

      if (secondaryApp != null) {
        try {
          await FirebaseAuth.instanceFor(
            app: secondaryApp,
          ).signOut();
        } catch (_) {}

        try {
          await secondaryApp.delete();
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      String message = 'Unable to create worker account.';

      switch (e.code) {
        case 'email-already-in-use':
          message =
          'This email is already registered in Firebase Authentication.';
          break;

        case 'existing-account-password-mismatch':
          message =
          'This email already exists in Firebase Authentication, '
              'but the temporary password entered here is incorrect.\n\n'
              'Enter the existing account password to repair the worker profile.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'The temporary password is too weak.';
          break;

        case 'operation-not-allowed':
          message =
          'Email and password authentication is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message =
          'The existing Firebase account password is incorrect.';
          break;

        case 'user-disabled':
          message =
          'This Firebase Authentication account has been disabled.';
          break;

        default:
          message =
          'Unable to create worker account.\n\n'
              'Firebase error: ${e.message ?? e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } on FirebaseException catch (e) {
      // ============================================================
      // FIRESTORE ERROR
      // ============================================================

      if (createdNewAuthAccount && workerUser != null) {
        try {
          await workerUser.delete();
        } catch (_) {}
      }

      if (secondaryApp != null) {
        try {
          await FirebaseAuth.instanceFor(
            app: secondaryApp,
          ).signOut();
        } catch (_) {}

        try {
          await secondaryApp.delete();
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save worker information.\n\n'
                'Code: ${e.code}\n'
                'Message: ${e.message ?? 'Unknown Firestore error'}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      // ============================================================
      // GENERAL ERROR
      // ============================================================

      if (createdNewAuthAccount && workerUser != null) {
        try {
          await workerUser.delete();
        } catch (_) {}
      }

      if (secondaryApp != null) {
        try {
          await FirebaseAuth.instanceFor(
            app: secondaryApp,
          ).signOut();
        } catch (_) {}

        try {
          await secondaryApp.delete();
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong.\n\n$e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  // =========================
  // INPUT DECORATION
  // =========================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFF45170),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF45170),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Worker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Worker Information',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF29266F),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Enter the details of the new Anganwadi worker.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // WORKER NAME
              // =========================

              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                enabled: !isSaving,
                decoration: _inputDecoration(
                  label: 'Worker Name',
                  hint: 'Enter worker name',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter worker name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // EMAIL
              // =========================

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isSaving,
                decoration: _inputDecoration(
                  label: 'Email',
                  hint: 'Enter worker email',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }

                  final email = value.trim();

                  if (!email.contains('@') ||
                      !email.contains('.')) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // TEMPORARY PASSWORD
              // =========================

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                enabled: !isSaving,
                decoration: _inputDecoration(
                  label: 'Temporary Password',
                  hint: 'Enter temporary password',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: isSaving
                        ? null
                        : () {
                      setState(() {
                        obscurePassword =
                        !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter temporary password';
                  }

                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              const Text(
                'Give this temporary password to the worker for the first login.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // PHONE
              // =========================

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                enabled: !isSaving,
                decoration: _inputDecoration(
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  icon: Icons.phone_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }

                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // CENTER ID
              // =========================

              TextFormField(
                controller: centerController,
                textCapitalization: TextCapitalization.words,
                enabled: !isSaving,
                decoration: _inputDecoration(
                  label: 'Center ID',
                  hint: 'Enter Anganwadi center ID',
                  icon: Icons.location_city_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter center ID';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              // =========================
              // INFORMATION BOX
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFF45170),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A Firebase login account will be created for this worker using the email and temporary password. If the email already exists, the existing account can be linked to the worker profile.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF29266F),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // ADD WORKER BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _addWorker,
                  child: isSaving
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'ADD WORKER',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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