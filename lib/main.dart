import 'package:flutter/material.dart';
import 'authentication/welcome.dart';
import 'authentication/login.dart';
import 'authentication/emaill.dart';
import 'authentication/otp.dart';
import 'authentication/register.dart';
import 'password/forgot.dart';
import 'password/verify.dart';
import 'password/reset.dart';
import 'pages/homepage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ZAPP",
      initialRoute: "/",
      routes: {
        "/": (context) => const WelcomePage(),
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
