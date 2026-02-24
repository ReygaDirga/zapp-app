import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder get field => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  );

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
    final newPassword = passwordCtrl.text;
    final confirmPassword = confirmCtrl.text;

    setState(() => errorText = null);

    if (newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('All fields are required');
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
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/login');
    } on AuthException catch (e) {
      setState(() => errorText = e.message);
    } catch (_) {
      setState(() => errorText = 'Failed to change password');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AuthLayout(
        scrollController: _scrollController,
        buttonText: isLoading ? "Continuing..." : "Continue",
        onButtonPressed: isLoading ? null : _changePassword,
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
              onTap: _scrollToTop,
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
              onTap: _scrollToTop,
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

            const SizedBox(height: 12),

            if (errorText != null)
              Center(
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      )
    );
  }
}
