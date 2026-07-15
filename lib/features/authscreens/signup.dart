import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../utils/alu_theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final namesController = TextEditingController();
  UserRole selectedRole = UserRole.student;
  bool isLoading = false;

  Future<void> handleSignUp() async {
    setState(() => isLoading = true);

    try {
      final user = await ref.read(authRepoProvider).signUp(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            names: namesController.text.trim(),
            role: selectedRole,
          );

      ref.read(loggedInUserProvider.notifier).state = user;

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AluColors.surface,
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: namesController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@alustudent.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AluColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserRole>(
                  value: selectedRole,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.student,
                      child: Text('Student'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.startupAdmin,
                      child: Text('Startup Admin'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.admin,
                      child: Text('ALU Admin (staff only)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedRole = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isLoading ? null : handleSignUp,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AluColors.white,
                      ),
                    )
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
