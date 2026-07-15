import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/startup_model.dart';
import '../../providers/auth_providers.dart';
import '../../repositories/startup_repo.dart';
import '../../utils/alu_theme.dart';

class StartupOnboardingScreen extends ConsumerStatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  ConsumerState<StartupOnboardingScreen> createState() =>
      _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends ConsumerState<StartupOnboardingScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final industryController = TextEditingController();
  final locationController = TextEditingController(text: 'ALU Campus');
  final websiteController = TextEditingController();
  bool isLoading = false;

  Future<void> submit() async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in company name and description')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final startup = StartupModel(
        id: '',
        companyName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        industry: industryController.text.trim(),
        location: locationController.text.trim(),
        website: websiteController.text.trim(),
        adminId: user.uuid,
        verified: false,
      );

      final startupId = await StartupRepo().create(startup);

      await ref.read(authRepoProvider).linkStartupToUser(
            uuid: user.uuid,
            startupId: startupId,
          );

      ref.read(loggedInUserProvider.notifier).state = user.copyWith(
        startupId: startupId,
        onboardingComplete: true,
      );
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Register your startup',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AluColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ALU will verify your startup before you can post opportunities. Only recognized ALU ventures appear to students.',
                style: TextStyle(color: AluColors.lightGrey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Company name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'What does your startup do?',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: industryController,
                decoration: const InputDecoration(
                  labelText: 'Industry',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website (optional)',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AluColors.white,
                        ),
                      )
                    : const Text('Submit for ALU verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
