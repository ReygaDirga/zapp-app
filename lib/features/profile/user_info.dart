import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/core/cache/user_cache.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPage();
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  return emailRegex.hasMatch(email);
}

class _UserInfoPage extends State<UserInfoPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();

  bool _isLoading = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    fullNameController.text = UserCache.fullname ?? '';
    emailController.text = UserCache.email ?? '';
    usernameController.text = UserCache.username ?? '';
  }

  Future<void> _saveChanges() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final newEmail = emailController.text.trim();
    final newFullname = fullNameController.text.trim();
    final newUsername = usernameController.text.trim();


    if (newEmail.isEmpty || newFullname.isEmpty || newUsername.isEmpty) {
      setState(() => errorText = 'All fields are required');
      return;
    }

    if (!isValidEmail(newEmail)) {
      setState(() => errorText = 'Invalid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      errorText = null;
    });

    try {
      if (newEmail != user.email) {
        await supabase.auth.updateUser(
          UserAttributes(email: newEmail),
          emailRedirectTo: 'zapp://auth-callback',
        );

        setState(() {
          errorText = "Verification email sent. Please confirm before changes apply.";
        });

        emailController.text = newEmail;

        await Future.delayed(const Duration(seconds: 5));

        await supabase.auth.signOut();
        UserCache.clear();

        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      await supabase.from('profiles').update({
        'fullname': newFullname,
        'username': newUsername,
      }).eq('user_id', user.id);

      UserCache.fullname = newFullname;
      UserCache.username = newUsername;

      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthException catch (e) {
      setState(() {
        errorText = e.message;
      });

    } catch (e) {
      setState(() => errorText = 'Failed to update profile');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            const Text(
              'Account Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Email',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Username',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
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

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5DAA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isLoading ? 
                  const Text(
                    "Saving...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                  : const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}