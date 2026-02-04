import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPasswordController =
  TextEditingController();
  final TextEditingController newPasswordController =
  TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;

  bool isLoading = false;

  void _showError(String message) {
    setState(() => errorText = message);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => errorText = null);
    });
  }

  String? errorText;

  final supabase = Supabase.instance.client;

  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain a special character';
    }
    return null;
  }

  Future<void> _changePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() => errorText = null);

    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('All fields are required');
      return;
    }

    final oldPasswordError = validatePassword(oldPassword);
    if (oldPasswordError != null) {
      _showError(oldPasswordError);
      return;
    }

    final newPasswordError = validatePassword(newPassword);
    if (newPasswordError != null) {
      _showError(newPasswordError);
      return;
    }

    final confirmPasswordError = validatePassword(confirmPassword);
    if (confirmPasswordError != null) {
      _showError(confirmPasswordError);
      return;
    }

    if (oldPassword == newPassword) {
      _showError('Old password and new password cannot be same');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Password and confirmation do not match');
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      _showError('Session expired, please login again');
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPassword,
      );

      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      setState(() => errorText = e.message);
    } catch (_) {
      setState(() => errorText = 'Failed to change password');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ScrollConfiguration(
        behavior: const _NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/icon/locked.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reset Password to access ZAPP\nMobile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              _label('Old Password'),
              _passwordField(
                controller: oldPasswordController,
                isVisible: oldPasswordVisible,
                onToggle: () =>
                    setState(() => oldPasswordVisible = !oldPasswordVisible),
              ),

              const SizedBox(height: 16),
              _label('New Password'),
              _passwordField(
                controller: newPasswordController,
                isVisible: newPasswordVisible,
                onToggle: () =>
                    setState(() => newPasswordVisible = !newPasswordVisible),
              ),

              const SizedBox(height: 16),
              _label('Confirm Password'),
              _passwordField(
                controller: confirmPasswordController,
                isVisible: confirmPasswordVisible,
                onToggle: () =>
                    setState(() => confirmPasswordVisible = !confirmPasswordVisible),
              ),

              const SizedBox(height: 12),
              if (errorText != null)
                Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5DAA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  // child: const Text(
                  //   'Continue',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  child: Text(isLoading ? 'Continuing...' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
    ),
  );

  Widget _passwordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      children: [
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF2E64A5), width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}