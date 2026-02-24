import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/core/components/layout.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController otpCtrl = TextEditingController();

  bool isVerifying = false;
  String? errorText;

  int countdown = 60;
  Timer? timer;
  Timer? errorTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    timer?.cancel();
    errorTimer?.cancel();
    otpCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    countdown = 60;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 0) {
        t.cancel();
      } else {
        setState(() => countdown--);
      }
    });
  }

  void _showError(String message) {
    setState(() => errorText = message);

    errorTimer?.cancel();
    errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => errorText = null);
    });
  }

  Future<void> _verifyOtp(String email, String otp) async {
    if (isVerifying) return;

    isVerifying = true;

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/reset',
      );
    } catch (e) {
      otpCtrl.clear();
      _showError('Invalid or expired OTP');
      isVerifying = false;
    }
  }

  Future<void> _resendOtp(String email) async {
    await Supabase.instance.client.auth.signInWithOtp(email: email);
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final String email =
      ModalRoute
        .of(context)!
        .settings
        .arguments as String;
    
    return PopScope(
      canPop: false,
      child: AuthLayout(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Verify Email",
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
                  "Enter the 6-digits verification code",
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
              enableActiveFill: true,
              cursorColor: Colors.black,
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

              onChanged: (value) {
                if (value.length == 6) {
                  _verifyOtp(email, value);
                }
              },
            ),
            
            const SizedBox(height: 8),

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

            Center(
              child: countdown > 0
                  ? Text(
                "Resend code in ${countdown}s",
                style: const TextStyle(fontSize: 12),
              )
                  : TextButton(
                onPressed: () => _resendOtp(email),
                child: const Text("Resend OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
