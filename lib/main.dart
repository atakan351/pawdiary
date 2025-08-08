import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
// import 'services/auth_service.dart'; // İleride eklenecek
// import 'l10n/app_localizations.dart'; // İleride eklenecek

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  await NotificationService.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const PawDiaryApp(),
    ),
  );
}

class PawDiaryApp extends StatelessWidget {
  const PawDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      title: AppLocalizations.of(context)?.translate('app_title') ?? 'Pawdiary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: themeService.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tr')],
      home: AuthGate(),
      routes: {'/register': (context) => const RegisterScreen()},
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigation();
        }
        return const LoginScreen();
      },
    );
  }
}
