import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'localization/app_localizations.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    AnganCareApp(
      key: AnganCareApp.appKey,
    ),
  );
}

class AnganCareApp extends StatefulWidget {
  const AnganCareApp({super.key});

  static final GlobalKey<_AnganCareAppState> appKey =
  GlobalKey<_AnganCareAppState>();

  // Keep the old method format so your existing screens
  // do not produce errors.
  static void changeLanguage(
      BuildContext context,
      Locale locale,
      ) {
    appKey.currentState?.changeLanguage(locale);
  }

  @override
  State<AnganCareApp> createState() =>
      _AnganCareAppState();
}

class _AnganCareAppState extends State<AnganCareApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(Locale locale) {
    if (_locale.languageCode == locale.languageCode) {
      return;
    }

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ANGANCARE',

      locale: _locale,

      supportedLocales:
      AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF45170),
        ),

        scaffoldBackgroundColor:
        const Color(0xFFFFFBF8),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF45170),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        inputDecorationTheme:
        InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFF45170),
              width: 1.5,
            ),
          ),
        ),

        elevatedButtonTheme:
        ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            const Color(0xFFF45170),
            foregroundColor: Colors.white,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}