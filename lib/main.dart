import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/core/auth/auth_gate.dart';
import 'package:zapp/routes/route_observer.dart';
import 'core/auth/welcome.dart';
import 'package:zapp/core/auth/login.dart';
import 'core/auth/email.dart';
import 'core/auth/otp.dart';
import 'core/auth/register.dart';
import 'features/password/forgot.dart';
import 'features/password/verify.dart';
import 'features/password/reset.dart';
import 'package:zapp/features/tabs/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Helvetica",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF053886),
        ),
        useMaterial3: true,
      ),
      title: "ZAPP",
      navigatorObservers: [routeObserver],
      home: const AuthGate(),
      routes: {
        "/login": (context) => LoginPage(),
        "/email": (context) => EmailPage(),
        "/otp": (context) =>  OTPPage(),
        "/register": (context) => RegisterPage(),
        "/forgot": (context) => ForgotPage(),
        "/verify": (context) => VerifyPage(),
        "/reset": (context) =>  ResetPage(),
        "/homepage": (context) => HomePage()
      },
    );
  }
}
