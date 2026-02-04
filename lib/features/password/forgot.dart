import 'package:flutter/material.dart';
import 'package:zapp/core/components/layout.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final field = OutlineInputBorder(borderRadius: BorderRadius.circular(10));

    return AuthLayout(
      buttonText: "Continue",
      onButtonPressed: () {
        Navigator.pushNamed(context, '/verify');
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "ZAPP!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 150,
            child: Center(
              child: Image.asset(
                'assets/icon/email.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Enter email to access forgot password"),
          const SizedBox(height: 6),
          TextField(decoration: InputDecoration(border: field)),
        ],
      ),
    );
  }
}
