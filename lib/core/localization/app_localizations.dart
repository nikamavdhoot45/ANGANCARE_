import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('mr'),
    Locale('hi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
          context,
          AppLocalizations,
        ) ??
        AppLocalizations(
          Localizations.localeOf(context),
        );
  }

  static const Map<String, Map<String, String>> _translations = {
    // =========================================================
    // ENGLISH
    // =========================================================
    'en': {
      // COMMON
      'appName': 'ANGANCARE',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'logout': 'Logout',
      'settings': 'Settings',
      'language': 'Language',
      'changePassword': 'Change Password',
      'helpSupport': 'Help & Support',
      'notifications': 'Notifications',
      'dashboard': 'Dashboard',
      'home': 'Home',
      'children': 'Children',
      'alerts': 'Alerts',
      'reports': 'Reports',
      'profile': 'Profile',
      'attendance': 'Attendance',
      'growth': 'Growth',
      'nutrition': 'Nutrition',
      'health': 'Health',
      'vaccination': 'Vaccination',
      'addChild': 'Add Child',
      'addWorker': 'Add Worker',
      'workers': 'Workers',
      'announcements': 'Announcements',
      'adminDashboard': 'Admin Dashboard',
      'workerDashboard': 'Worker Dashboard',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'marathi': 'Marathi',
      'hindi': 'Hindi',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'about': 'About ANGANCARE',
      'version': 'Version 1.0.0',
      'edit': 'Edit',
      'delete': 'Delete',
      'add': 'Add',
      'update': 'Update',
      'submit': 'Submit',
      'search': 'Search',
      'refresh': 'Refresh',
      'retry': 'Try Again',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',
      'done': 'Done',
      'back': 'Back',
      'next': 'Next',
      'loading': 'Loading...',
      'noData': 'No data available',
      'unknown': 'Unknown',
      'error': 'Error',
      'success': 'Success',
      'required': 'Required',
      'name': 'Name',
      'phone': 'Phone Number',
      'address': 'Address',
      'date': 'Date',
      'time': 'Time',
      'status': 'Status',
      'gender': 'Gender',
      'age': 'Age',
      'years': 'Years',
      'months': 'Months',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',

      // WORKER DASHBOARD
      'overview': 'Overview',
      'totalChildren': 'Total Children',
      'normal': 'Normal',
      'moderate': 'Moderate',
      'severe': 'Severe',
      'quickActions': 'Quick Actions',
      'addNewChild': 'Add New Child',
      'vaccinationDue': 'Vaccination Due',
      'healthCheckupDue': 'Health Checkup Due',
      'viewAll': 'View All',
      'childHealthcareManagement': 'Child Healthcare Management',
      'welcomeToAnganCare': 'Welcome to ANGANCARE',
      'manageChildRecords':
          'Manage children health, growth, nutrition and vaccination records.',
      'vaccinationRecordsNeedAttention': 'Vaccination records need attention',
      'upcomingChildHealthCheckup': 'Upcoming child health checkup',
      'pleaseAddChildFirst': 'Please add a child first.',
      'unableToOpenGrowth': 'Unable to open Growth',

      // CHILDREN
      'searchChildren': 'Search children',
      'noChildrenFound': 'No Children Found',
      'addChildToBegin': 'Add a child to begin managing records.',
      'unableToLoadChildren': 'Unable to Load Children',
      'unknownDatabaseError': 'Unknown database error',
      'childDeletedSuccessfully': 'Child deleted successfully.',
      'errorDeletingChild': 'Error deleting child.',
      'deleteChild': 'Delete Child',
      'deleteChildConfirmation': 'Are you sure you want to delete this child?',
      'childDetails': 'Child Details',
      'childName': 'Child Name',
      'fatherName': 'Father Name',
      'motherName': 'Mother Name',
      'dateOfBirth': 'Date of Birth',
      'weight': 'Weight',
      'height': 'Height',
      'centerId': 'Center ID',
      'growthStatus': 'Growth Status',

      // ADD CHILD
      'addNewChildTitle': 'Add New Child',
      'childInformation': 'Child Information',
      'enterChildDetails': 'Enter the details of the child.',
      'enterChildName': 'Enter child name',
      'enterFatherName': 'Enter father name',
      'enterMotherName': 'Enter mother name',
      'enterPhoneNumber': 'Enter phone number',
      'enterCenterId': 'Enter Anganwadi center ID',
      'selectGender': 'Select Gender',
      'selectDateOfBirth': 'Select Date of Birth',
      'childAddedSuccessfully': 'Child added successfully.',
      'unableToAddChild': 'Unable to add child.',
      'pleaseEnterName': 'Please enter name',
      'pleaseEnterPhone': 'Please enter phone number',
      'pleaseEnterCenter': 'Please enter center ID',

      // CHILD DETAILS
      'personalInformation': 'Personal Information',
      'healthInformation': 'Health Information',
      'growthRecords': 'Growth Records',
      'nutritionRecords': 'Nutrition Records',
      'vaccinationRecords': 'Vaccination Records',
      'healthRecords': 'Health Records',
      'noRecordsFound': 'No records found.',

      // GROWTH
      'growthMonitoring': 'Growth Monitoring',
      'addGrowthRecord': 'Add Growth Record',
      'weightKg': 'Weight (kg)',
      'heightCm': 'Height (cm)',
      'bmi': 'BMI',
      'recordDate': 'Record Date',
      'growthRecordAdded': 'Growth record added successfully.',
      'unableToAddGrowth': 'Unable to add growth record.',
      'noGrowthRecords': 'No growth records found.',

      // NUTRITION
      'nutritionAssessment': 'Nutrition Assessment',
      'addNutritionRecord': 'Add Nutrition Record',
      'nutritionStatus': 'Nutrition Status',
      'foodIntake': 'Food Intake',
      'nutritionNotes': 'Nutrition Notes',
      'nutritionRecordAdded': 'Nutrition record added successfully.',
      'unableToAddNutrition': 'Unable to add nutrition record.',
      'noNutritionRecords': 'No nutrition records found.',

      // HEALTH
      'healthCheckup': 'Health Checkup',
      'addHealthRecord': 'Add Health Record',
      'checkupDate': 'Checkup Date',
      'healthStatus': 'Health Status',
      'symptoms': 'Symptoms',
      'diagnosis': 'Diagnosis',
      'treatment': 'Treatment',
      'healthNotes': 'Health Notes',
      'healthRecordAdded': 'Health record added successfully.',
      'unableToAddHealth': 'Unable to add health record.',
      'noHealthRecords': 'No health records found.',

      // VACCINATION
      'vaccinationDetails': 'Vaccination Details',
      'addVaccinationRecord': 'Add Vaccination Record',
      'vaccineName': 'Vaccine Name',
      'vaccinationDate': 'Vaccination Date',
      'nextDueDate': 'Next Due Date',
      'vaccinationStatus': 'Vaccination Status',
      'completed': 'Completed',
      'pending': 'Pending',
      'vaccinationRecordAdded': 'Vaccination record added successfully.',
      'unableToAddVaccination': 'Unable to add vaccination record.',
      'noVaccinationRecords': 'No vaccination records found.',

      // ATTENDANCE
      'attendanceManagement': 'Attendance Management',
      'markAttendance': 'Mark Attendance',
      'present': 'Present',
      'absent': 'Absent',
      'attendanceMarked': 'Attendance marked successfully.',
      'attendanceAlreadyMarked': 'Attendance has already been marked.',
      'noAttendanceRecords': 'No attendance records found.',

      // ALERTS
      'alertManagement': 'Alert Management',
      'noAlerts': 'No Alerts',
      'vaccinationAlert': 'Vaccination Alert',
      'healthAlert': 'Health Alert',
      'growthAlert': 'Growth Alert',
      'attentionRequired': 'Attention Required',

      // REPORTS
      'childrenReport': 'Children Report',
      'growthReport': 'Growth Report',
      'nutritionReport': 'Nutrition Report',
      'vaccinationReport': 'Vaccination Report',
      'healthReport': 'Health Report',
      'total': 'Total',
      'reportDetails': 'Report Details',
      'generateReport': 'Generate Report',
      'noReportData': 'No report data available.',

      // PROFILE
      'workerProfile': 'Worker Profile',
      'adminProfile': 'Admin Profile',
      'personalDetails': 'Personal Details',
      'accountInformation': 'Account Information',
      'changeLanguage': 'Change Language',
      'logoutConfirmation': 'Are you sure you want to logout?',

      // ADMIN
      'admin': 'Admin',
      'worker': 'Worker',
      'adminAccess': 'Admin Access',
      'workerManagement': 'Worker Management',
      'createAnnouncement': 'Create Announcement',
      'announcementHistory': 'Announcement History',
      'adminReports': 'Admin Reports',
      'adminSettings': 'Admin Settings',
      'manageWorkers': 'Manage Workers',
      'manageAnnouncements': 'Manage Announcements',
      'manageReports': 'Manage Reports',

      // ADD WORKER
      'workerInformation': 'Worker Information',
      'enterWorkerDetails': 'Enter the details of the new Anganwadi worker.',
      'workerName': 'Worker Name',
      'enterWorkerName': 'Enter worker name',
      'enterWorkerEmail': 'Enter worker email',
      'temporaryPassword': 'Temporary Password',
      'enterTemporaryPassword': 'Enter temporary password',
      'phoneNumber': 'Phone Number',
      'enterPhoneNumberWorker': 'Enter phone number',
      'enterAnganwadiCenter': 'Enter Anganwadi center ID',
      'workerAddedSuccessfully': 'Worker added successfully.',
      'workerAccountRepaired': 'Worker account repaired successfully.',
      'workerNotFound': 'Worker account was not found.',
      'workerInactive': 'This worker account is inactive.',

      // ANNOUNCEMENTS
      'announcement': 'Announcement',
      'announcementTitle': 'Announcement Title',
      'announcementMessage': 'Announcement Message',
      'enterAnnouncementTitle': 'Enter announcement title',
      'enterAnnouncementMessage': 'Enter announcement message',
      'publish': 'Publish',
      'published': 'Published',
      'announcementCreated': 'Announcement created successfully.',
      'announcementDeleted': 'Announcement deleted successfully.',
      'noAnnouncements': 'No announcements found.',

      // SETTINGS
      'generalSettings': 'General Settings',
      'appSettings': 'App Settings',
      'accountSettings': 'Account Settings',
      'notificationSettings': 'Notification Settings',
      'enableNotifications': 'Enable Notifications',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmPassword': 'Confirm Password',
      'passwordChangedSuccessfully': 'Password changed successfully.',
      'passwordsDoNotMatch': 'Passwords do not match.',
      'incorrectPassword': 'Incorrect current password.',
      'passwordTooWeak': 'Password is too weak.',
      'enterCurrentPassword': 'Enter current password',
      'enterNewPassword': 'Enter new password',
      'confirmNewPassword': 'Confirm new password',

      // LOGIN
      'loginAs': 'Login as',
      'enterYourEmail': 'Enter your email',
      'enterYourPassword': 'Enter your password',
      'forgotPassword': 'Forgot Password?',
      'loginButton': 'LOGIN',
      'invalidEmail': 'Please enter a valid email',
      'emailRequired': 'Please enter your email',
      'passwordRequired': 'Please enter your password',
      'invalidEmailOrPassword': 'Invalid email or password.',
      'accountNotFound': 'No account found with this email.',
      'accountDisabled': 'This account has been disabled.',
      'adminProfileNotFound': 'Admin profile was not found in Firestore.',
      'workerProfileNotFound': 'Worker profile was not found in Firestore.',
      'notAdminAccount': 'This account is not registered as an Admin.',
      'notWorkerAccount': 'This account is not registered as a Worker.',
      'workerAccountInactive': 'Your Worker account is currently inactive.',
      'contactAdministrator': 'Please contact the administrator.',
      'passwordResetEmailSent': 'Password reset email sent. Check your inbox.',
      'enterEmailFirst': 'Enter your email first.',

      // ERRORS
      'somethingWentWrong': 'Something went wrong.',
      'firestoreError': 'Firestore error.',
      'unableToSave': 'Unable to save information.',
      'unableToLoad': 'Unable to load information.',
      'checkInternet': 'Please check your internet connection.',
      'tryAgainLater': 'Please try again later.',
      'tooManyAttempts': 'Too many attempts. Please try again later.',
    },

    // =========================================================
    // MARATHI
    // =========================================================
    'mr': {
      // COMMON
      'appName': 'अंगणकेअर',
      'login': 'लॉगिन',
      'email': 'ई-मेल',
      'password': 'पासवर्ड',
      'logout': 'लॉगआउट',
      'settings': 'सेटिंग्ज',
      'language': 'भाषा',
      'changePassword': 'पासवर्ड बदला',
      'helpSupport': 'मदत आणि सहाय्य',
      'notifications': 'सूचना',
      'dashboard': 'डॅशबोर्ड',
      'home': 'मुख्यपृष्ठ',
      'children': 'मुले',
      'alerts': 'सूचना',
      'reports': 'अहवाल',
      'profile': 'प्रोफाइल',
      'attendance': 'उपस्थिती',
      'growth': 'वाढ',
      'nutrition': 'पोषण',
      'health': 'आरोग्य',
      'vaccination': 'लसीकरण',
      'addChild': 'मूल जोडा',
      'addWorker': 'कार्यकर्ता जोडा',
      'workers': 'कार्यकर्ते',
      'announcements': 'घोषणा',
      'adminDashboard': 'प्रशासक डॅशबोर्ड',
      'workerDashboard': 'कार्यकर्ता डॅशबोर्ड',
      'selectLanguage': 'भाषा निवडा',
      'english': 'इंग्रजी',
      'marathi': 'मराठी',
      'hindi': 'हिंदी',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'close': 'बंद करा',
      'about': 'अंगणकेअर बद्दल',
      'version': 'आवृत्ती 1.0.0',
      'edit': 'संपादित करा',
      'delete': 'हटवा',
      'add': 'जोडा',
      'update': 'अद्यतन करा',
      'submit': 'सबमिट करा',
      'search': 'शोधा',
      'refresh': 'रिफ्रेश करा',
      'retry': 'पुन्हा प्रयत्न करा',
      'yes': 'होय',
      'no': 'नाही',
      'confirm': 'पुष्टी करा',
      'done': 'पूर्ण',
      'back': 'मागे',
      'next': 'पुढे',
      'loading': 'लोड होत आहे...',
      'noData': 'माहिती उपलब्ध नाही',
      'unknown': 'अज्ञात',
      'error': 'त्रुटी',
      'success': 'यशस्वी',
      'required': 'आवश्यक',
      'name': 'नाव',
      'phone': 'फोन नंबर',
      'address': 'पत्ता',
      'date': 'तारीख',
      'time': 'वेळ',
      'status': 'स्थिती',
      'gender': 'लिंग',
      'age': 'वय',
      'years': 'वर्षे',
      'months': 'महिने',
      'male': 'पुरुष',
      'female': 'स्त्री',
      'other': 'इतर',

      // WORKER DASHBOARD
      'overview': 'आढावा',
      'totalChildren': 'एकूण मुले',
      'normal': 'सामान्य',
      'moderate': 'मध्यम',
      'severe': 'गंभीर',
      'quickActions': 'जलद कृती',
      'addNewChild': 'नवीन मूल जोडा',
      'vaccinationDue': 'लसीकरण बाकी',
      'healthCheckupDue': 'आरोग्य तपासणी बाकी',
      'viewAll': 'सर्व पहा',
      'childHealthcareManagement': 'बाल आरोग्य व्यवस्थापन',
      'welcomeToAnganCare': 'अंगणकेअरमध्ये स्वागत आहे',
      'manageChildRecords':
          'मुलांचे आरोग्य, वाढ, पोषण आणि लसीकरणाच्या नोंदी व्यवस्थापित करा.',
      'vaccinationRecordsNeedAttention':
          'लसीकरणाच्या नोंदींकडे लक्ष देणे आवश्यक आहे',
      'upcomingChildHealthCheckup': 'मुलांची आगामी आरोग्य तपासणी',
      'pleaseAddChildFirst': 'कृपया प्रथम एक मूल जोडा.',
      'unableToOpenGrowth': 'वाढ विभाग उघडता आला नाही',

      // CHILDREN
      'searchChildren': 'मुलांचा शोध घ्या',
      'noChildrenFound': 'मुले सापडली नाहीत',
      'addChildToBegin': 'नोंदी व्यवस्थापित करण्यासाठी एक मूल जोडा.',
      'unableToLoadChildren': 'मुले लोड करता आली नाहीत',
      'unknownDatabaseError': 'अज्ञात डेटाबेस त्रुटी',
      'childDeletedSuccessfully': 'मूल यशस्वीरित्या हटवले.',
      'errorDeletingChild': 'मूल हटवताना त्रुटी आली.',
      'deleteChild': 'मूल हटवा',
      'deleteChildConfirmation': 'तुम्हाला हे मूल हटवायचे आहे का?',
      'childDetails': 'मुलाची माहिती',
      'childName': 'मुलाचे नाव',
      'fatherName': 'वडिलांचे नाव',
      'motherName': 'आईचे नाव',
      'dateOfBirth': 'जन्मतारीख',
      'weight': 'वजन',
      'height': 'उंची',
      'centerId': 'केंद्र आयडी',
      'growthStatus': 'वाढीची स्थिती',

      // ADD CHILD
      'addNewChildTitle': 'नवीन मूल जोडा',
      'childInformation': 'मुलाची माहिती',
      'enterChildDetails': 'मुलाची माहिती प्रविष्ट करा.',
      'enterChildName': 'मुलाचे नाव प्रविष्ट करा',
      'enterFatherName': 'वडिलांचे नाव प्रविष्ट करा',
      'enterMotherName': 'आईचे नाव प्रविष्ट करा',
      'enterPhoneNumber': 'फोन नंबर प्रविष्ट करा',
      'enterCenterId': 'अंगणवाडी केंद्र आयडी प्रविष्ट करा',
      'selectGender': 'लिंग निवडा',
      'selectDateOfBirth': 'जन्मतारीख निवडा',
      'childAddedSuccessfully': 'मूल यशस्वीरित्या जोडले.',
      'unableToAddChild': 'मूल जोडता आले नाही.',
      'pleaseEnterName': 'कृपया नाव प्रविष्ट करा',
      'pleaseEnterPhone': 'कृपया फोन नंबर प्रविष्ट करा',
      'pleaseEnterCenter': 'कृपया केंद्र आयडी प्रविष्ट करा',

      // CHILD DETAILS
      'personalInformation': 'वैयक्तिक माहिती',
      'healthInformation': 'आरोग्य माहिती',
      'growthRecords': 'वाढीच्या नोंदी',
      'nutritionRecords': 'पोषणाच्या नोंदी',
      'vaccinationRecords': 'लसीकरणाच्या नोंदी',
      'healthRecords': 'आरोग्याच्या नोंदी',
      'noRecordsFound': 'नोंदी सापडल्या नाहीत.',

      // GROWTH
      'growthMonitoring': 'वाढ निरीक्षण',
      'addGrowthRecord': 'वाढीची नोंद जोडा',
      'weightKg': 'वजन (किलो)',
      'heightCm': 'उंची (सेमी)',
      'bmi': 'बीएमआय',
      'recordDate': 'नोंद तारीख',
      'growthRecordAdded': 'वाढीची नोंद यशस्वीरित्या जोडली.',
      'unableToAddGrowth': 'वाढीची नोंद जोडता आली नाही.',
      'noGrowthRecords': 'वाढीच्या नोंदी सापडल्या नाहीत.',

      // NUTRITION
      'nutritionAssessment': 'पोषण मूल्यांकन',
      'addNutritionRecord': 'पोषण नोंद जोडा',
      'nutritionStatus': 'पोषण स्थिती',
      'foodIntake': 'अन्न सेवन',
      'nutritionNotes': 'पोषण नोंदी',
      'nutritionRecordAdded': 'पोषणाची नोंद यशस्वीरित्या जोडली.',
      'unableToAddNutrition': 'पोषणाची नोंद जोडता आली नाही.',
      'noNutritionRecords': 'पोषणाच्या नोंदी सापडल्या नाहीत.',

      // HEALTH
      'healthCheckup': 'आरोग्य तपासणी',
      'addHealthRecord': 'आरोग्य नोंद जोडा',
      'checkupDate': 'तपासणी तारीख',
      'healthStatus': 'आरोग्य स्थिती',
      'symptoms': 'लक्षणे',
      'diagnosis': 'निदान',
      'treatment': 'उपचार',
      'healthNotes': 'आरोग्य नोंदी',
      'healthRecordAdded': 'आरोग्य नोंद यशस्वीरित्या जोडली.',
      'unableToAddHealth': 'आरोग्य नोंद जोडता आली नाही.',
      'noHealthRecords': 'आरोग्याच्या नोंदी सापडल्या नाहीत.',

      // VACCINATION
      'vaccinationDetails': 'लसीकरण माहिती',
      'addVaccinationRecord': 'लसीकरणाची नोंद जोडा',
      'vaccineName': 'लसीचे नाव',
      'vaccinationDate': 'लसीकरण तारीख',
      'nextDueDate': 'पुढील तारीख',
      'vaccinationStatus': 'लसीकरण स्थिती',
      'completed': 'पूर्ण',
      'pending': 'प्रलंबित',
      'vaccinationRecordAdded': 'लसीकरणाची नोंद यशस्वीरित्या जोडली.',
      'unableToAddVaccination': 'लसीकरणाची नोंद जोडता आली नाही.',
      'noVaccinationRecords': 'लसीकरणाच्या नोंदी सापडल्या नाहीत.',

      // ATTENDANCE
      'attendanceManagement': 'उपस्थिती व्यवस्थापन',
      'markAttendance': 'उपस्थिती नोंदवा',
      'present': 'उपस्थित',
      'absent': 'अनुपस्थित',
      'attendanceMarked': 'उपस्थिती यशस्वीरित्या नोंदवली.',
      'attendanceAlreadyMarked': 'उपस्थिती आधीच नोंदवली आहे.',
      'noAttendanceRecords': 'उपस्थितीच्या नोंदी सापडल्या नाहीत.',

      // ALERTS
      'alertManagement': 'सूचना व्यवस्थापन',
      'noAlerts': 'सूचना नाहीत',
      'vaccinationAlert': 'लसीकरण सूचना',
      'healthAlert': 'आरोग्य सूचना',
      'growthAlert': 'वाढ सूचना',
      'attentionRequired': 'लक्ष देणे आवश्यक',

      // REPORTS
      'childrenReport': 'मुलांचा अहवाल',
      'growthReport': 'वाढीचा अहवाल',
      'nutritionReport': 'पोषण अहवाल',
      'vaccinationReport': 'लसीकरण अहवाल',
      'healthReport': 'आरोग्य अहवाल',
      'total': 'एकूण',
      'reportDetails': 'अहवाल माहिती',
      'generateReport': 'अहवाल तयार करा',
      'noReportData': 'अहवालाची माहिती उपलब्ध नाही.',

      // PROFILE
      'workerProfile': 'कार्यकर्ता प्रोफाइल',
      'adminProfile': 'प्रशासक प्रोफाइल',
      'personalDetails': 'वैयक्तिक माहिती',
      'accountInformation': 'खाते माहिती',
      'changeLanguage': 'भाषा बदला',
      'logoutConfirmation': 'तुम्हाला लॉगआउट करायचे आहे का?',

      // ADMIN
      'admin': 'प्रशासक',
      'worker': 'कार्यकर्ता',
      'adminAccess': 'प्रशासक प्रवेश',
      'workerManagement': 'कार्यकर्ता व्यवस्थापन',
      'createAnnouncement': 'घोषणा तयार करा',
      'announcementHistory': 'घोषणा इतिहास',
      'adminReports': 'प्रशासक अहवाल',
      'adminSettings': 'प्रशासक सेटिंग्ज',
      'manageWorkers': 'कार्यकर्ते व्यवस्थापित करा',
      'manageAnnouncements': 'घोषणा व्यवस्थापित करा',
      'manageReports': 'अहवाल व्यवस्थापित करा',

      // ADD WORKER
      'workerInformation': 'कार्यकर्त्याची माहिती',
      'enterWorkerDetails': 'नवीन अंगणवाडी कार्यकर्त्याची माहिती प्रविष्ट करा.',
      'workerName': 'कार्यकर्त्याचे नाव',
      'enterWorkerName': 'कार्यकर्त्याचे नाव प्रविष्ट करा',
      'enterWorkerEmail': 'कार्यकर्त्याचा ई-मेल प्रविष्ट करा',
      'temporaryPassword': 'तात्पुरता पासवर्ड',
      'enterTemporaryPassword': 'तात्पुरता पासवर्ड प्रविष्ट करा',
      'phoneNumber': 'फोन नंबर',
      'enterPhoneNumberWorker': 'फोन नंबर प्रविष्ट करा',
      'enterAnganwadiCenter': 'अंगणवाडी केंद्र आयडी प्रविष्ट करा',
      'workerAddedSuccessfully': 'कार्यकर्ता यशस्वीरित्या जोडला.',
      'workerAccountRepaired': 'कार्यकर्त्याचे खाते यशस्वीरित्या दुरुस्त केले.',
      'workerNotFound': 'कार्यकर्त्याचे खाते सापडले नाही.',
      'workerInactive': 'हे कार्यकर्ता खाते निष्क्रिय आहे.',

      // ANNOUNCEMENTS
      'announcement': 'घोषणा',
      'announcementTitle': 'घोषणेचे शीर्षक',
      'announcementMessage': 'घोषणेचा संदेश',
      'enterAnnouncementTitle': 'घोषणेचे शीर्षक प्रविष्ट करा',
      'enterAnnouncementMessage': 'घोषणेचा संदेश प्रविष्ट करा',
      'publish': 'प्रकाशित करा',
      'published': 'प्रकाशित',
      'announcementCreated': 'घोषणा यशस्वीरित्या तयार केली.',
      'announcementDeleted': 'घोषणा यशस्वीरित्या हटवली.',
      'noAnnouncements': 'घोषणा सापडल्या नाहीत.',

      // SETTINGS
      'generalSettings': 'सामान्य सेटिंग्ज',
      'appSettings': 'अॅप सेटिंग्ज',
      'accountSettings': 'खाते सेटिंग्ज',
      'notificationSettings': 'सूचना सेटिंग्ज',
      'enableNotifications': 'सूचना सक्षम करा',
      'currentPassword': 'सध्याचा पासवर्ड',
      'newPassword': 'नवीन पासवर्ड',
      'confirmPassword': 'पासवर्डची पुष्टी करा',
      'passwordChangedSuccessfully': 'पासवर्ड यशस्वीरित्या बदलला.',
      'passwordsDoNotMatch': 'पासवर्ड जुळत नाहीत.',
      'incorrectPassword': 'सध्याचा पासवर्ड चुकीचा आहे.',
      'passwordTooWeak': 'पासवर्ड खूप कमजोर आहे.',
      'enterCurrentPassword': 'सध्याचा पासवर्ड प्रविष्ट करा',
      'enterNewPassword': 'नवीन पासवर्ड प्रविष्ट करा',
      'confirmNewPassword': 'नवीन पासवर्डची पुष्टी करा',

      // LOGIN
      'loginAs': 'लॉगिन करा',
      'enterYourEmail': 'तुमचा ई-मेल प्रविष्ट करा',
      'enterYourPassword': 'तुमचा पासवर्ड प्रविष्ट करा',
      'forgotPassword': 'पासवर्ड विसरलात?',
      'loginButton': 'लॉगिन',
      'invalidEmail': 'कृपया वैध ई-मेल प्रविष्ट करा',
      'emailRequired': 'कृपया तुमचा ई-मेल प्रविष्ट करा',
      'passwordRequired': 'कृपया तुमचा पासवर्ड प्रविष्ट करा',
      'invalidEmailOrPassword': 'ई-मेल किंवा पासवर्ड चुकीचा आहे.',
      'accountNotFound': 'या ई-मेलसाठी खाते सापडले नाही.',
      'accountDisabled': 'हे खाते अक्षम केले आहे.',
      'adminProfileNotFound': 'फायरस्टोअरमध्ये प्रशासक प्रोफाइल सापडले नाही.',
      'workerProfileNotFound':
          'फायरस्टोअरमध्ये कार्यकर्ता प्रोफाइल सापडले नाही.',
      'notAdminAccount': 'हे खाते प्रशासक म्हणून नोंदणीकृत नाही.',
      'notWorkerAccount': 'हे खाते कार्यकर्ता म्हणून नोंदणीकृत नाही.',
      'workerAccountInactive': 'तुमचे कार्यकर्ता खाते सध्या निष्क्रिय आहे.',
      'contactAdministrator': 'कृपया प्रशासकाशी संपर्क साधा.',
      'passwordResetEmailSent':
          'पासवर्ड रीसेट ई-मेल पाठवला आहे. तुमचा इनबॉक्स तपासा.',
      'enterEmailFirst': 'प्रथम तुमचा ई-मेल प्रविष्ट करा.',

      // ERRORS
      'somethingWentWrong': 'काहीतरी चूक झाली.',
      'firestoreError': 'फायरस्टोअर त्रुटी.',
      'unableToSave': 'माहिती जतन करता आली नाही.',
      'unableToLoad': 'माहिती लोड करता आली नाही.',
      'checkInternet': 'कृपया तुमचे इंटरनेट कनेक्शन तपासा.',
      'tryAgainLater': 'कृपया नंतर पुन्हा प्रयत्न करा.',
      'tooManyAttempts': 'खूप प्रयत्न झाले. कृपया नंतर पुन्हा प्रयत्न करा.',
    },

    // =========================================================
    // HINDI
    // =========================================================
    'hi': {
      // COMMON
      'appName': 'आंगनकेयर',
      'login': 'लॉगिन',
      'email': 'ई-मेल',
      'password': 'पासवर्ड',
      'logout': 'लॉगआउट',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'changePassword': 'पासवर्ड बदलें',
      'helpSupport': 'मदद और सहायता',
      'notifications': 'सूचनाएँ',
      'dashboard': 'डैशबोर्ड',
      'home': 'होम',
      'children': 'बच्चे',
      'alerts': 'सूचनाएँ',
      'reports': 'रिपोर्ट',
      'profile': 'प्रोफ़ाइल',
      'attendance': 'उपस्थिति',
      'growth': 'विकास',
      'nutrition': 'पोषण',
      'health': 'स्वास्थ्य',
      'vaccination': 'टीकाकरण',
      'addChild': 'बच्चा जोड़ें',
      'addWorker': 'कार्यकर्ता जोड़ें',
      'workers': 'कार्यकर्ता',
      'announcements': 'घोषणाएँ',
      'adminDashboard': 'व्यवस्थापक डैशबोर्ड',
      'workerDashboard': 'कार्यकर्ता डैशबोर्ड',
      'selectLanguage': 'भाषा चुनें',
      'english': 'अंग्रेज़ी',
      'marathi': 'मराठी',
      'hindi': 'हिंदी',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'close': 'बंद करें',
      'about': 'आंगनकेयर के बारे में',
      'version': 'संस्करण 1.0.0',
      'edit': 'संपादित करें',
      'delete': 'हटाएँ',
      'add': 'जोड़ें',
      'update': 'अपडेट करें',
      'submit': 'जमा करें',
      'search': 'खोजें',
      'refresh': 'रीफ्रेश करें',
      'retry': 'पुनः प्रयास करें',
      'yes': 'हाँ',
      'no': 'नहीं',
      'confirm': 'पुष्टि करें',
      'done': 'पूर्ण',
      'back': 'पीछे',
      'next': 'आगे',
      'loading': 'लोड हो रहा है...',
      'noData': 'कोई जानकारी उपलब्ध नहीं है',
      'unknown': 'अज्ञात',
      'error': 'त्रुटि',
      'success': 'सफल',
      'required': 'आवश्यक',
      'name': 'नाम',
      'phone': 'फोन नंबर',
      'address': 'पता',
      'date': 'तारीख',
      'time': 'समय',
      'status': 'स्थिति',
      'gender': 'लिंग',
      'age': 'आयु',
      'years': 'वर्ष',
      'months': 'महीने',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',

      // WORKER DASHBOARD
      'overview': 'अवलोकन',
      'totalChildren': 'कुल बच्चे',
      'normal': 'सामान्य',
      'moderate': 'मध्यम',
      'severe': 'गंभीर',
      'quickActions': 'त्वरित कार्य',
      'addNewChild': 'नया बच्चा जोड़ें',
      'vaccinationDue': 'टीकाकरण बाकी',
      'healthCheckupDue': 'स्वास्थ्य जाँच बाकी',
      'viewAll': 'सभी देखें',
      'childHealthcareManagement': 'बाल स्वास्थ्य प्रबंधन',
      'welcomeToAnganCare': 'आंगनकेयर में आपका स्वागत है',
      'manageChildRecords':
          'बच्चों के स्वास्थ्य, विकास, पोषण और टीकाकरण रिकॉर्ड प्रबंधित करें।',
      'vaccinationRecordsNeedAttention':
          'टीकाकरण रिकॉर्ड पर ध्यान देना आवश्यक है',
      'upcomingChildHealthCheckup': 'बच्चे की आगामी स्वास्थ्य जाँच',
      'pleaseAddChildFirst': 'कृपया पहले एक बच्चा जोड़ें।',
      'unableToOpenGrowth': 'विकास खोलने में असमर्थ',

      // CHILDREN
      'searchChildren': 'बच्चों को खोजें',
      'noChildrenFound': 'कोई बच्चा नहीं मिला',
      'addChildToBegin': 'रिकॉर्ड प्रबंधित करने के लिए एक बच्चा जोड़ें।',
      'unableToLoadChildren': 'बच्चों को लोड नहीं किया जा सका',
      'unknownDatabaseError': 'अज्ञात डेटाबेस त्रुटि',
      'childDeletedSuccessfully': 'बच्चा सफलतापूर्वक हटाया गया।',
      'errorDeletingChild': 'बच्चे को हटाने में त्रुटि हुई।',
      'deleteChild': 'बच्चा हटाएँ',
      'deleteChildConfirmation': 'क्या आप इस बच्चे को हटाना चाहते हैं?',
      'childDetails': 'बच्चे की जानकारी',
      'childName': 'बच्चे का नाम',
      'fatherName': 'पिता का नाम',
      'motherName': 'माता का नाम',
      'dateOfBirth': 'जन्म तिथि',
      'weight': 'वजन',
      'height': 'ऊँचाई',
      'centerId': 'केंद्र आईडी',
      'growthStatus': 'विकास स्थिति',

      // ADD CHILD
      'addNewChildTitle': 'नया बच्चा जोड़ें',
      'childInformation': 'बच्चे की जानकारी',
      'enterChildDetails': 'बच्चे की जानकारी दर्ज करें।',
      'enterChildName': 'बच्चे का नाम दर्ज करें',
      'enterFatherName': 'पिता का नाम दर्ज करें',
      'enterMotherName': 'माता का नाम दर्ज करें',
      'enterPhoneNumber': 'फोन नंबर दर्ज करें',
      'enterCenterId': 'आंगनवाड़ी केंद्र आईडी दर्ज करें',
      'selectGender': 'लिंग चुनें',
      'selectDateOfBirth': 'जन्म तिथि चुनें',
      'childAddedSuccessfully': 'बच्चा सफलतापूर्वक जोड़ा गया।',
      'unableToAddChild': 'बच्चा जोड़ा नहीं जा सका।',
      'pleaseEnterName': 'कृपया नाम दर्ज करें',
      'pleaseEnterPhone': 'कृपया फोन नंबर दर्ज करें',
      'pleaseEnterCenter': 'कृपया केंद्र आईडी दर्ज करें',

      // CHILD DETAILS
      'personalInformation': 'व्यक्तिगत जानकारी',
      'healthInformation': 'स्वास्थ्य जानकारी',
      'growthRecords': 'विकास रिकॉर्ड',
      'nutritionRecords': 'पोषण रिकॉर्ड',
      'vaccinationRecords': 'टीकाकरण रिकॉर्ड',
      'healthRecords': 'स्वास्थ्य रिकॉर्ड',
      'noRecordsFound': 'कोई रिकॉर्ड नहीं मिला।',

      // GROWTH
      'growthMonitoring': 'विकास निगरानी',
      'addGrowthRecord': 'विकास रिकॉर्ड जोड़ें',
      'weightKg': 'वजन (किलो)',
      'heightCm': 'ऊँचाई (सेमी)',
      'bmi': 'बीएमआई',
      'recordDate': 'रिकॉर्ड तारीख',
      'growthRecordAdded': 'विकास रिकॉर्ड सफलतापूर्वक जोड़ा गया।',
      'unableToAddGrowth': 'विकास रिकॉर्ड जोड़ा नहीं जा सका।',
      'noGrowthRecords': 'कोई विकास रिकॉर्ड नहीं मिला।',

      // NUTRITION
      'nutritionAssessment': 'पोषण मूल्यांकन',
      'addNutritionRecord': 'पोषण रिकॉर्ड जोड़ें',
      'nutritionStatus': 'पोषण स्थिति',
      'foodIntake': 'भोजन सेवन',
      'nutritionNotes': 'पोषण नोट्स',
      'nutritionRecordAdded': 'पोषण रिकॉर्ड सफलतापूर्वक जोड़ा गया।',
      'unableToAddNutrition': 'पोषण रिकॉर्ड जोड़ा नहीं जा सका।',
      'noNutritionRecords': 'कोई पोषण रिकॉर्ड नहीं मिला।',

      // HEALTH
      'healthCheckup': 'स्वास्थ्य जाँच',
      'addHealthRecord': 'स्वास्थ्य रिकॉर्ड जोड़ें',
      'checkupDate': 'जाँच तारीख',
      'healthStatus': 'स्वास्थ्य स्थिति',
      'symptoms': 'लक्षण',
      'diagnosis': 'निदान',
      'treatment': 'उपचार',
      'healthNotes': 'स्वास्थ्य नोट्स',
      'healthRecordAdded': 'स्वास्थ्य रिकॉर्ड सफलतापूर्वक जोड़ा गया।',
      'unableToAddHealth': 'स्वास्थ्य रिकॉर्ड जोड़ा नहीं जा सका।',
      'noHealthRecords': 'कोई स्वास्थ्य रिकॉर्ड नहीं मिला।',

      // VACCINATION
      'vaccinationDetails': 'टीकाकरण विवरण',
      'addVaccinationRecord': 'टीकाकरण रिकॉर्ड जोड़ें',
      'vaccineName': 'टीके का नाम',
      'vaccinationDate': 'टीकाकरण तारीख',
      'nextDueDate': 'अगली तारीख',
      'vaccinationStatus': 'टीकाकरण स्थिति',
      'completed': 'पूर्ण',
      'pending': 'लंबित',
      'vaccinationRecordAdded': 'टीकाकरण रिकॉर्ड सफलतापूर्वक जोड़ा गया।',
      'unableToAddVaccination': 'टीकाकरण रिकॉर्ड जोड़ा नहीं जा सका।',
      'noVaccinationRecords': 'कोई टीकाकरण रिकॉर्ड नहीं मिला।',

      // ATTENDANCE
      'attendanceManagement': 'उपस्थिति प्रबंधन',
      'markAttendance': 'उपस्थिति दर्ज करें',
      'present': 'उपस्थित',
      'absent': 'अनुपस्थित',
      'attendanceMarked': 'उपस्थिति सफलतापूर्वक दर्ज की गई।',
      'attendanceAlreadyMarked': 'उपस्थिति पहले ही दर्ज की जा चुकी है।',
      'noAttendanceRecords': 'कोई उपस्थिति रिकॉर्ड नहीं मिला।',

      // ALERTS
      'alertManagement': 'सूचना प्रबंधन',
      'noAlerts': 'कोई सूचनाएँ नहीं',
      'vaccinationAlert': 'टीकाकरण सूचना',
      'healthAlert': 'स्वास्थ्य सूचना',
      'growthAlert': 'विकास सूचना',
      'attentionRequired': 'ध्यान देना आवश्यक',

      // REPORTS
      'childrenReport': 'बच्चों की रिपोर्ट',
      'growthReport': 'विकास रिपोर्ट',
      'nutritionReport': 'पोषण रिपोर्ट',
      'vaccinationReport': 'टीकाकरण रिपोर्ट',
      'healthReport': 'स्वास्थ्य रिपोर्ट',
      'total': 'कुल',
      'reportDetails': 'रिपोर्ट विवरण',
      'generateReport': 'रिपोर्ट बनाएँ',
      'noReportData': 'रिपोर्ट की जानकारी उपलब्ध नहीं है।',

      // PROFILE
      'workerProfile': 'कार्यकर्ता प्रोफ़ाइल',
      'adminProfile': 'व्यवस्थापक प्रोफ़ाइल',
      'personalDetails': 'व्यक्तिगत विवरण',
      'accountInformation': 'खाता जानकारी',
      'changeLanguage': 'भाषा बदलें',
      'logoutConfirmation': 'क्या आप लॉगआउट करना चाहते हैं?',

      // ADMIN
      'admin': 'व्यवस्थापक',
      'worker': 'कार्यकर्ता',
      'adminAccess': 'व्यवस्थापक प्रवेश',
      'workerManagement': 'कार्यकर्ता प्रबंधन',
      'createAnnouncement': 'घोषणा बनाएँ',
      'announcementHistory': 'घोषणा इतिहास',
      'adminReports': 'व्यवस्थापक रिपोर्ट',
      'adminSettings': 'व्यवस्थापक सेटिंग्स',
      'manageWorkers': 'कार्यकर्ताओं का प्रबंधन करें',
      'manageAnnouncements': 'घोषणाओं का प्रबंधन करें',
      'manageReports': 'रिपोर्ट का प्रबंधन करें',

      // ADD WORKER
      'workerInformation': 'कार्यकर्ता की जानकारी',
      'enterWorkerDetails': 'नए आंगनवाड़ी कार्यकर्ता की जानकारी दर्ज करें।',
      'workerName': 'कार्यकर्ता का नाम',
      'enterWorkerName': 'कार्यकर्ता का नाम दर्ज करें',
      'enterWorkerEmail': 'कार्यकर्ता का ई-मेल दर्ज करें',
      'temporaryPassword': 'अस्थायी पासवर्ड',
      'enterTemporaryPassword': 'अस्थायी पासवर्ड दर्ज करें',
      'phoneNumber': 'फोन नंबर',
      'enterPhoneNumberWorker': 'फोन नंबर दर्ज करें',
      'enterAnganwadiCenter': 'आंगनवाड़ी केंद्र आईडी दर्ज करें',
      'workerAddedSuccessfully': 'कार्यकर्ता सफलतापूर्वक जोड़ा गया।',
      'workerAccountRepaired': 'कार्यकर्ता खाता सफलतापूर्वक ठीक किया गया।',
      'workerNotFound': 'कार्यकर्ता खाता नहीं मिला।',
      'workerInactive': 'यह कार्यकर्ता खाता निष्क्रिय है।',

      // ANNOUNCEMENTS
      'announcement': 'घोषणा',
      'announcementTitle': 'घोषणा शीर्षक',
      'announcementMessage': 'घोषणा संदेश',
      'enterAnnouncementTitle': 'घोषणा शीर्षक दर्ज करें',
      'enterAnnouncementMessage': 'घोषणा संदेश दर्ज करें',
      'publish': 'प्रकाशित करें',
      'published': 'प्रकाशित',
      'announcementCreated': 'घोषणा सफलतापूर्वक बनाई गई।',
      'announcementDeleted': 'घोषणा सफलतापूर्वक हटाई गई।',
      'noAnnouncements': 'कोई घोषणा नहीं मिली।',

      // SETTINGS
      'generalSettings': 'सामान्य सेटिंग्स',
      'appSettings': 'ऐप सेटिंग्स',
      'accountSettings': 'खाता सेटिंग्स',
      'notificationSettings': 'सूचना सेटिंग्स',
      'enableNotifications': 'सूचनाएँ सक्षम करें',
      'currentPassword': 'वर्तमान पासवर्ड',
      'newPassword': 'नया पासवर्ड',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'passwordChangedSuccessfully': 'पासवर्ड सफलतापूर्वक बदल दिया गया।',
      'passwordsDoNotMatch': 'पासवर्ड मेल नहीं खाते।',
      'incorrectPassword': 'वर्तमान पासवर्ड गलत है।',
      'passwordTooWeak': 'पासवर्ड बहुत कमजोर है।',
      'enterCurrentPassword': 'वर्तमान पासवर्ड दर्ज करें',
      'enterNewPassword': 'नया पासवर्ड दर्ज करें',
      'confirmNewPassword': 'नए पासवर्ड की पुष्टि करें',

      // LOGIN
      'loginAs': 'लॉगिन करें',
      'enterYourEmail': 'अपना ई-मेल दर्ज करें',
      'enterYourPassword': 'अपना पासवर्ड दर्ज करें',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'loginButton': 'लॉगिन',
      'invalidEmail': 'कृपया वैध ई-मेल दर्ज करें',
      'emailRequired': 'कृपया अपना ई-मेल दर्ज करें',
      'passwordRequired': 'कृपया अपना पासवर्ड दर्ज करें',
      'invalidEmailOrPassword': 'ई-मेल या पासवर्ड गलत है।',
      'accountNotFound': 'इस ई-मेल के लिए कोई खाता नहीं मिला।',
      'accountDisabled': 'यह खाता अक्षम कर दिया गया है।',
      'adminProfileNotFound': 'फायरस्टोर में व्यवस्थापक प्रोफ़ाइल नहीं मिली।',
      'workerProfileNotFound': 'फायरस्टोर में कार्यकर्ता प्रोफ़ाइल नहीं मिली।',
      'notAdminAccount': 'यह खाता व्यवस्थापक के रूप में पंजीकृत नहीं है।',
      'notWorkerAccount': 'यह खाता कार्यकर्ता के रूप में पंजीकृत नहीं है।',
      'workerAccountInactive': 'आपका कार्यकर्ता खाता वर्तमान में निष्क्रिय है।',
      'contactAdministrator': 'कृपया व्यवस्थापक से संपर्क करें।',
      'passwordResetEmailSent':
          'पासवर्ड रीसेट ई-मेल भेज दिया गया है। अपना इनबॉक्स देखें।',
      'enterEmailFirst': 'पहले अपना ई-मेल दर्ज करें।',

      // ERRORS
      'somethingWentWrong': 'कुछ गलत हो गया।',
      'firestoreError': 'फायरस्टोर त्रुटि।',
      'unableToSave': 'जानकारी सहेजी नहीं जा सकी।',
      'unableToLoad': 'जानकारी लोड नहीं की जा सकी।',
      'checkInternet': 'कृपया अपना इंटरनेट कनेक्शन जाँचें।',
      'tryAgainLater': 'कृपया बाद में पुनः प्रयास करें।',
      'tooManyAttempts':
          'बहुत अधिक प्रयास हुए। कृपया बाद में पुनः प्रयास करें।',
    },
  };

  String text(String key) {
    final languageCode = locale.languageCode;

    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  // =========================================================
  // COMMON
  // =========================================================

  String get appName => text('appName');
  String get login => text('login');
  String get email => text('email');
  String get password => text('password');
  String get logout => text('logout');
  String get settings => text('settings');
  String get language => text('language');
  String get changePassword => text('changePassword');
  String get helpSupport => text('helpSupport');
  String get notifications => text('notifications');
  String get dashboard => text('dashboard');
  String get home => text('home');
  String get children => text('children');
  String get alerts => text('alerts');
  String get reports => text('reports');
  String get profile => text('profile');
  String get attendance => text('attendance');
  String get growth => text('growth');
  String get nutrition => text('nutrition');
  String get health => text('health');
  String get vaccination => text('vaccination');
  String get addChild => text('addChild');
  String get addWorker => text('addWorker');
  String get workers => text('workers');
  String get announcements => text('announcements');
  String get adminDashboard => text('adminDashboard');
  String get workerDashboard => text('workerDashboard');
  String get selectLanguage => text('selectLanguage');
  String get english => text('english');
  String get marathi => text('marathi');
  String get hindi => text('hindi');
  String get save => text('save');
  String get cancel => text('cancel');
  String get close => text('close');
  String get about => text('about');
  String get version => text('version');
  String get edit => text('edit');
  String get delete => text('delete');
  String get add => text('add');
  String get update => text('update');
  String get submit => text('submit');
  String get search => text('search');
  String get refresh => text('refresh');
  String get retry => text('retry');
  String get yes => text('yes');
  String get no => text('no');
  String get confirm => text('confirm');
  String get done => text('done');
  String get back => text('back');
  String get next => text('next');
  String get loading => text('loading');
  String get noData => text('noData');
  String get unknown => text('unknown');
  String get error => text('error');
  String get success => text('success');
  String get required => text('required');
  String get name => text('name');
  String get phone => text('phone');
  String get address => text('address');
  String get date => text('date');
  String get time => text('time');
  String get status => text('status');
  String get gender => text('gender');
  String get age => text('age');
  String get years => text('years');
  String get months => text('months');
  String get male => text('male');
  String get female => text('female');
  String get other => text('other');

  // =========================================================
  // WORKER DASHBOARD
  // =========================================================

  String get overview => text('overview');
  String get totalChildren => text('totalChildren');
  String get normal => text('normal');
  String get moderate => text('moderate');
  String get severe => text('severe');
  String get quickActions => text('quickActions');
  String get addNewChild => text('addNewChild');
  String get vaccinationDue => text('vaccinationDue');
  String get healthCheckupDue => text('healthCheckupDue');
  String get viewAll => text('viewAll');
  String get childHealthcareManagement => text('childHealthcareManagement');
  String get welcomeToAnganCare => text('welcomeToAnganCare');
  String get manageChildRecords => text('manageChildRecords');
  String get vaccinationRecordsNeedAttention =>
      text('vaccinationRecordsNeedAttention');
  String get upcomingChildHealthCheckup => text('upcomingChildHealthCheckup');
  String get pleaseAddChildFirst => text('pleaseAddChildFirst');
  String get unableToOpenGrowth => text('unableToOpenGrowth');

  // =========================================================
  // CHILDREN
  // =========================================================

  String get searchChildren => text('searchChildren');
  String get noChildrenFound => text('noChildrenFound');
  String get addChildToBegin => text('addChildToBegin');
  String get unableToLoadChildren => text('unableToLoadChildren');
  String get unknownDatabaseError => text('unknownDatabaseError');
  String get childDeletedSuccessfully => text('childDeletedSuccessfully');
  String get errorDeletingChild => text('errorDeletingChild');
  String get deleteChild => text('deleteChild');
  String get deleteChildConfirmation => text('deleteChildConfirmation');
  String get childDetails => text('childDetails');
  String get childName => text('childName');
  String get fatherName => text('fatherName');
  String get motherName => text('motherName');
  String get dateOfBirth => text('dateOfBirth');
  String get weight => text('weight');
  String get height => text('height');
  String get centerId => text('centerId');
  String get growthStatus => text('growthStatus');

  // =========================================================
  // ADD CHILD
  // =========================================================

  String get addNewChildTitle => text('addNewChildTitle');
  String get childInformation => text('childInformation');
  String get enterChildDetails => text('enterChildDetails');
  String get enterChildName => text('enterChildName');
  String get enterFatherName => text('enterFatherName');
  String get enterMotherName => text('enterMotherName');
  String get enterPhoneNumber => text('enterPhoneNumber');
  String get enterCenterId => text('enterCenterId');
  String get selectGender => text('selectGender');
  String get selectDateOfBirth => text('selectDateOfBirth');
  String get childAddedSuccessfully => text('childAddedSuccessfully');
  String get unableToAddChild => text('unableToAddChild');
  String get pleaseEnterName => text('pleaseEnterName');
  String get pleaseEnterPhone => text('pleaseEnterPhone');
  String get pleaseEnterCenter => text('pleaseEnterCenter');

  // =========================================================
  // CHILD DETAILS
  // =========================================================

  String get personalInformation => text('personalInformation');
  String get healthInformation => text('healthInformation');
  String get growthRecords => text('growthRecords');
  String get nutritionRecords => text('nutritionRecords');
  String get vaccinationRecords => text('vaccinationRecords');
  String get healthRecords => text('healthRecords');
  String get noRecordsFound => text('noRecordsFound');

  // =========================================================
  // GROWTH
  // =========================================================

  String get growthMonitoring => text('growthMonitoring');
  String get addGrowthRecord => text('addGrowthRecord');
  String get weightKg => text('weightKg');
  String get heightCm => text('heightCm');
  String get bmi => text('bmi');
  String get recordDate => text('recordDate');
  String get growthRecordAdded => text('growthRecordAdded');
  String get unableToAddGrowth => text('unableToAddGrowth');
  String get noGrowthRecords => text('noGrowthRecords');

  // =========================================================
  // NUTRITION
  // =========================================================

  String get nutritionAssessment => text('nutritionAssessment');
  String get addNutritionRecord => text('addNutritionRecord');
  String get nutritionStatus => text('nutritionStatus');
  String get foodIntake => text('foodIntake');
  String get nutritionNotes => text('nutritionNotes');
  String get nutritionRecordAdded => text('nutritionRecordAdded');
  String get unableToAddNutrition => text('unableToAddNutrition');
  String get noNutritionRecords => text('noNutritionRecords');

  // =========================================================
  // HEALTH
  // =========================================================

  String get healthCheckup => text('healthCheckup');
  String get addHealthRecord => text('addHealthRecord');
  String get checkupDate => text('checkupDate');
  String get healthStatus => text('healthStatus');
  String get symptoms => text('symptoms');
  String get diagnosis => text('diagnosis');
  String get treatment => text('treatment');
  String get healthNotes => text('healthNotes');
  String get healthRecordAdded => text('healthRecordAdded');
  String get unableToAddHealth => text('unableToAddHealth');
  String get noHealthRecords => text('noHealthRecords');

  // =========================================================
  // VACCINATION
  // =========================================================

  String get vaccinationDetails => text('vaccinationDetails');
  String get addVaccinationRecord => text('addVaccinationRecord');
  String get vaccineName => text('vaccineName');
  String get vaccinationDate => text('vaccinationDate');
  String get nextDueDate => text('nextDueDate');
  String get vaccinationStatus => text('vaccinationStatus');
  String get completed => text('completed');
  String get pending => text('pending');
  String get vaccinationRecordAdded => text('vaccinationRecordAdded');
  String get unableToAddVaccination => text('unableToAddVaccination');
  String get noVaccinationRecords => text('noVaccinationRecords');

  // =========================================================
  // ATTENDANCE
  // =========================================================

  String get attendanceManagement => text('attendanceManagement');
  String get markAttendance => text('markAttendance');
  String get present => text('present');
  String get absent => text('absent');
  String get attendanceMarked => text('attendanceMarked');
  String get attendanceAlreadyMarked => text('attendanceAlreadyMarked');
  String get noAttendanceRecords => text('noAttendanceRecords');

  // =========================================================
  // ALERTS
  // =========================================================

  String get alertManagement => text('alertManagement');
  String get noAlerts => text('noAlerts');
  String get vaccinationAlert => text('vaccinationAlert');
  String get healthAlert => text('healthAlert');
  String get growthAlert => text('growthAlert');
  String get attentionRequired => text('attentionRequired');

  // =========================================================
  // REPORTS
  // =========================================================

  String get childrenReport => text('childrenReport');
  String get growthReport => text('growthReport');
  String get nutritionReport => text('nutritionReport');
  String get vaccinationReport => text('vaccinationReport');
  String get healthReport => text('healthReport');
  String get total => text('total');
  String get reportDetails => text('reportDetails');
  String get generateReport => text('generateReport');
  String get noReportData => text('noReportData');

  // =========================================================
  // PROFILE
  // =========================================================

  String get workerProfile => text('workerProfile');
  String get adminProfile => text('adminProfile');
  String get personalDetails => text('personalDetails');
  String get accountInformation => text('accountInformation');
  String get changeLanguage => text('changeLanguage');
  String get logoutConfirmation => text('logoutConfirmation');

  // =========================================================
  // ADMIN
  // =========================================================

  String get admin => text('admin');
  String get worker => text('worker');
  String get adminAccess => text('adminAccess');
  String get workerManagement => text('workerManagement');
  String get createAnnouncement => text('createAnnouncement');
  String get announcementHistory => text('announcementHistory');
  String get adminReports => text('adminReports');
  String get adminSettings => text('adminSettings');
  String get manageWorkers => text('manageWorkers');
  String get manageAnnouncements => text('manageAnnouncements');
  String get manageReports => text('manageReports');

  // =========================================================
  // ADD WORKER
  // =========================================================

  String get workerInformation => text('workerInformation');
  String get enterWorkerDetails => text('enterWorkerDetails');
  String get workerName => text('workerName');
  String get enterWorkerName => text('enterWorkerName');
  String get enterWorkerEmail => text('enterWorkerEmail');
  String get temporaryPassword => text('temporaryPassword');
  String get enterTemporaryPassword => text('enterTemporaryPassword');
  String get phoneNumber => text('phoneNumber');
  String get enterPhoneNumberWorker => text('enterPhoneNumberWorker');
  String get enterAnganwadiCenter => text('enterAnganwadiCenter');
  String get workerAddedSuccessfully => text('workerAddedSuccessfully');
  String get workerAccountRepaired => text('workerAccountRepaired');
  String get workerNotFound => text('workerNotFound');
  String get workerInactive => text('workerInactive');

  // =========================================================
  // ANNOUNCEMENTS
  // =========================================================

  String get announcement => text('announcement');
  String get announcementTitle => text('announcementTitle');
  String get announcementMessage => text('announcementMessage');
  String get enterAnnouncementTitle => text('enterAnnouncementTitle');
  String get enterAnnouncementMessage => text('enterAnnouncementMessage');
  String get publish => text('publish');
  String get published => text('published');
  String get announcementCreated => text('announcementCreated');
  String get announcementDeleted => text('announcementDeleted');
  String get noAnnouncements => text('noAnnouncements');

  // =========================================================
  // SETTINGS
  // =========================================================

  String get generalSettings => text('generalSettings');
  String get appSettings => text('appSettings');
  String get accountSettings => text('accountSettings');
  String get notificationSettings => text('notificationSettings');
  String get enableNotifications => text('enableNotifications');
  String get currentPassword => text('currentPassword');
  String get newPassword => text('newPassword');
  String get confirmPassword => text('confirmPassword');
  String get passwordChangedSuccessfully => text('passwordChangedSuccessfully');
  String get passwordsDoNotMatch => text('passwordsDoNotMatch');
  String get incorrectPassword => text('incorrectPassword');
  String get passwordTooWeak => text('passwordTooWeak');
  String get enterCurrentPassword => text('enterCurrentPassword');
  String get enterNewPassword => text('enterNewPassword');
  String get confirmNewPassword => text('confirmNewPassword');

  // =========================================================
  // LOGIN
  // =========================================================

  String get loginAs => text('loginAs');
  String get enterYourEmail => text('enterYourEmail');
  String get enterYourPassword => text('enterYourPassword');
  String get forgotPassword => text('forgotPassword');
  String get loginButton => text('loginButton');
  String get invalidEmail => text('invalidEmail');
  String get emailRequired => text('emailRequired');
  String get passwordRequired => text('passwordRequired');
  String get invalidEmailOrPassword => text('invalidEmailOrPassword');
  String get accountNotFound => text('accountNotFound');
  String get accountDisabled => text('accountDisabled');
  String get adminProfileNotFound => text('adminProfileNotFound');
  String get workerProfileNotFound => text('workerProfileNotFound');
  String get notAdminAccount => text('notAdminAccount');
  String get notWorkerAccount => text('notWorkerAccount');
  String get workerAccountInactive => text('workerAccountInactive');
  String get contactAdministrator => text('contactAdministrator');
  String get passwordResetEmailSent => text('passwordResetEmailSent');
  String get enterEmailFirst => text('enterEmailFirst');

  // =========================================================
  // ERRORS
  // =========================================================

  String get somethingWentWrong => text('somethingWentWrong');
  String get firestoreError => text('firestoreError');
  String get unableToSave => text('unableToSave');
  String get unableToLoad => text('unableToLoad');
  String get checkInternet => text('checkInternet');
  String get tryAgainLater => text('tryAgainLater');
  String get tooManyAttempts => text('tooManyAttempts');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) {
    return false;
  }
}
