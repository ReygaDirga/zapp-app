import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:zapp/core/components/layout.dart';

class VerifyPage extends StatelessWidget {
  VerifyPage({super.key});

  final TextEditingController otpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      buttonText: "Continue",
      onButtonPressed: () {
        Navigator.pushNamed(context, '/reset');
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child : Image.asset(
                  'assets/icon/email.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Verify your email",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              const Text(
                "Enter the 6-digits verification code)",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 32),

          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,

            cursorColor: Colors.black,
            enableActiveFill: true,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 48,
              fieldWidth: 40,

              activeFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              selectedFillColor: Colors.white,

              activeColor: Colors.black54,
              inactiveColor: Colors.black26,
              selectedColor: const Color(0xFF2E64A5),
            ),

            onChanged: (value) {},
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
