# ANGANCARE

**AnganCare** is a cross-platform mobile application built with Flutter and Firebase designed to empower Anganwadi workers and administrative staff in tracking child health, growth monitoring, nutrition distribution, daily attendance, and healthcare records.

---

## 📌 Problem Statement & Objectives

### Problem Statement
Anganwadi centers across India play a crucial role in early childhood care, maternal health, and combating malnutrition. However, record-keeping relies heavily on manual paper registers, leading to data fragmentation, delays in detecting severe acute malnutrition (SAM/MAM), difficulty in tracking health intervention history, and administrative overhead.

### Objectives
* **Digitize Child Health Records**: Centralize demographic, growth, health, vaccination, and nutrition logs into a secure cloud database.
* **Early Detection of Malnutrition**: Streamline growth monitoring with WHO-aligned status flags (Normal, Moderate, Severe).
* **Role-Based Access**: Provide dedicated dashboards tailored for Field Workers (Anganwadi Workers) and System Administrators.
* **Multilingual Accessibility**: Support localized user interfaces in **English**, **Marathi (मराठी)**, and **Hindi (हिंदी)** for field usability.
* **Administrative Oversight**: Enable administrative staff to create and manage worker accounts, broadcast announcements, and monitor regional reports.

---

## 🌟 Feature Breakdown

### Implemented Features

#### 🔐 Authentication & Access Control
* **Role-Based Login**: Dedicated authentication flow routing users to either the **Worker Dashboard** or **Admin Dashboard** based on Firestore `users` role claims.
* **Password Reset**: Self-service email reset links via Firebase Authentication.
* **Admin Worker Account Creation**: Cloud Function (`createWorkerAccount`) and secondary auth creation for administrative worker provisioning.

#### 👶 Child Health & Growth Management
* **Child Profile Management**: Register, search, filter, and view detailed records for enrolled children.
* **Growth Tracking**: Log height, weight, and status (Normal, Moderate / MAM, Severe / SAM).
* **Health & Vaccination Records**: Record checkup histories, immunization events, and attach medical documents/prescriptions via Firebase Storage.
* **Nutrition Logs**: Log daily supplementary nutrition distributions (Take-Home Ration / Hot Cooked Meals).
* **Attendance Monitoring**: Mark daily center attendance per child.

#### 🔔 Alerts & Reports
* **Health & Growth Alerts**: Centralized dashboard view highlighting children flagged with severe or moderate growth concerns.
* **Center Reports**: Summarized reports on enrollment, growth distribution, and health checks.

#### ⚙️ Multilingual & Profile Management
* **Language Selector**: Seamlessly toggle between **English**, **Marathi (मराठी)**, and **Hindi (हिंदी)** without restarting the app.
* **Profile Settings**: View account information, update passwords, and adjust preferences.

#### 👑 Admin Features
* **Worker Directory**: View, search, and manage registered Anganwadi worker accounts.
* **Worker Onboarding**: Provision worker accounts securely.
* **Announcements**: Publish center-wide broadcasts and notices.
* **System Settings**: Configure administrative preferences and system parameters.

---

### Planned / Future Features 🚀
* [ ] **WHO Growth Charts**: Visual growth velocity percentile graphs (Weight-for-Age, Height-for-Age).
* [ ] **Offline Sync**: Local SQLite caching with automated sync when internet connectivity is restored.
* [ ] **Push Notifications**: Firebase Cloud Messaging (FCM) alerts for upcoming vaccination schedules.
* [ ] **PDF/Excel Export**: Export monthly center registers to standardized PDF/Excel formats.

---

## 🛠️ Technology Stack

* **Framework**: [Flutter](https://flutter.dev) (Dart SDK `>=3.0.0 <4.0.0`)
* **Backend & Database**: [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)
* **Authentication**: [Firebase Authentication](https://firebase.google.com/docs/auth)
* **File Storage**: [Firebase Storage](https://firebase.google.com/docs/storage)
* **Serverless Logic**: [Firebase Cloud Functions](https://firebase.google.com/docs/functions) (Node.js 24 runtime, Firebase Admin SDK)
* **Localization**: `flutter_localizations` with custom `AppLocalizations`

---

## 📁 Project Architecture & Directory Structure

The project follows a **Feature-Driven Architecture** separating UI, core utilities, services, and cloud functions:

```
first_app/
├── android/                   # Android native platform code and configuration
├── assets/
│   └── images/                # Brand assets (e.g. app_logo.png)
├── functions/                 # Firebase Cloud Functions (Node.js)
│   ├── index.js               # createWorkerAccount serverless endpoint
│   ├── package.json
│   └── .env.example
├── ios/                       # iOS native platform code
├── lib/
│   ├── core/                  # Global app config and localization
│   │   ├── firebase_options.dart
│   │   └── localization/
│   │       └── app_localizations.dart
│   ├── features/              # Modular feature domains
│   │   ├── admin/             # Worker management, announcements, admin reports
│   │   ├── alerts/            # Critical malnutrition & health alerts
│   │   ├── auth/              # Login & role-based routing
│   │   ├── children/          # Profiles, growth, health, attendance, nutrition
│   │   ├── dashboard/         # Worker & Admin dashboards
│   │   ├── profile/           # Worker settings & language selection
│   │   └── reports/           # Analytics & center summary screens
│   ├── models/                # Data models directory (reserved)
│   ├── services/              # Shared data access helpers (database_helper.dart)
│   └── main.dart              # Application entry point & MaterialApp configuration
├── .env.example               # Template for environment variables
├── firebase.json              # Firebase CLI configuration
├── pubspec.yaml               # Flutter package configuration & dependencies
└── README.md
```

---

## 🚀 Setup & Local Development

### Prerequisites
1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.0.0`)
2. [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter/Dart extensions.
3. [Node.js](https://nodejs.org/) (`>=20` or `24`) for Firebase Cloud Functions.
4. [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`).

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/first_app.git
   cd first_app
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   * Create a Firebase Project at [Firebase Console](https://console.firebase.google.com/).
   * Enable **Authentication** (Email/Password).
   * Enable **Cloud Firestore** and **Firebase Storage**.
   * Run FlutterFire CLI to configure client credentials:
     ```bash
     flutterfire configure
     ```

4. **Deploy Cloud Functions (Optional)**:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

5. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🔐 Credentials & Security Model

* **Public Configuration**: `lib/core/firebase_options.dart` and `android/app/google-services.json` contain Firebase **Client API keys** (`AIzaSy...`). According to Google Firebase security guidelines, client API keys identify the Firebase project to Google Cloud servers and are safe to include in client mobile applications.
* **Private Credentials**: Service Account JSON files (`*service-account*.json`), keystore files (`*.jks`, `key.properties`), and `.env` files are strictly excluded from Git via `.gitignore`.
* **Database Security**: Ensure Cloud Firestore Security Rules enforce role-based access control (`request.auth != null`) in production.

---

## 📸 Screenshots

*(Add screenshots of Worker Dashboard, Child Health Record, Growth Tracking, Admin Panel, and Multilingual Interfaces here)*

| Worker Dashboard | Child Details | Growth Tracking |
| :---: | :---: | :---: |
| ![Dashboard](assets/images/app_logo.png) | ![Child Details](assets/images/app_logo.png) | ![Growth](assets/images/app_logo.png) |

---

## 🧪 Testing & Code Quality

Validate project health and code formatting:

```bash
# Analyze Dart code for errors/warnings
flutter analyze

# Format Dart source files
dart format .

# Run test suite
flutter test
```

### Current Status
* **Analyzer**: Passed with `0` errors.
* **Formatting**: Formatted with `dart format`.

---

## ⚠️ Known Limitations

1. **Connectivity Requirement**: Active internet connection is required for Firestore live updates and Cloud Storage image/document uploads.
2. **Growth Velocity**: Growth evaluation is logged per entry; graphical WHO percentile growth curves are currently planned for a future update.
