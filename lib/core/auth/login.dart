import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/core/components/layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  return emailRegex.hasMatch(email);
}

class _LoginPageState extends State<LoginPage> {
  bool passwordVisible = false;
  bool isLoading = false;
  String? errorText;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  final OutlineInputBorder field = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
  );

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorText = 'Email and password are required');
      return;
    }

    if (!isValidEmail(email)) {
      setState(() => errorText = 'Invalid email address');
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      setState(() => errorText = e.message);
    } catch (_) {
      setState(() => errorText = 'Login failed');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      buttonText: "Create New Account",
      onButtonPressed: () {
        Navigator.pushNamed(context, '/email');
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Login",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Email"),
          const SizedBox(height: 6),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: field,
              enabledBorder: field,
              focusedBorder: field.copyWith(
                borderSide:
                const BorderSide(color: Color(0xFF2E64A5), width: 2),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),

          const SizedBox(height: 16),
          const Text("Password"),
          const SizedBox(height: 6),
          TextField(
            controller: passwordCtrl,
            obscureText: !passwordVisible,
            decoration: InputDecoration(
              border: field,
              enabledBorder: field,
              focusedBorder: field.copyWith(
                borderSide:
                const BorderSide(color: Color(0xFF2E64A5), width: 2),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),
          if (errorText != null)
            Center(
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E64A5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isLoading ? "Logging in..." : "Log In"),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot');
              },
              child: const Text("Forgot Password?"),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}