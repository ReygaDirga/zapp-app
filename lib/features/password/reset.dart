import 'package:flutter/material.dart';
import 'package:zapp/core/components/layout.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  OutlineInputBorder get field => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  );

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      buttonText: "Continue",
      onButtonPressed: () {
        // TODO: Add real validation
        Navigator.pushNamed(context, '/login');
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "ZAPP!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),

          Center(
            child: Image.asset(
              'assets/icon/locked.png',
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Reset Password to access ZAPP Mobile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          const Text("Password"),
          const SizedBox(height: 6),
          TextField(
            controller: passwordCtrl,
            obscureText: !passwordVisible,
            decoration: InputDecoration(
              border: field,
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 16),

          const Text("Confirm password"),
          const SizedBox(height: 6),
          TextField(
            controller: confirmCtrl,
            obscureText: !confirmPasswordVisible,
            decoration: InputDecoration(
              border: field,
              suffixIcon: IconButton(
                icon: Icon(
                  confirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    confirmPasswordVisible = !confirmPasswordVisible;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
