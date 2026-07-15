import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/alu_theme.dart';

class StudentOnboardingScreen extends ConsumerStatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  ConsumerState<StudentOnboardingScreen> createState() =>
      _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends ConsumerState<StudentOnboardingScreen> {
  final locationController = TextEditingController(text: 'Kigali, Rwanda');
  final skillController = TextEditingController();
  final List<String> skills = [];
  bool isLoading = false;

  void addSkill() {
    final skill = skillController.text.trim();
    if (skill.isEmpty || skills.contains(skill)) return;

    setState(() {
      skills.add(skill);
      skillController.clear();
    });
  }

  Future<void> finish() async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one skill')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ref.read(authRepoProvider).completeStudentOnboarding(
            uuid: user.uuid,
            location: locationController.text.trim(),
            skills: skills,
          );

      ref.read(loggedInUserProvider.notifier).state = user.copyWith(
        location: locationController.text.trim(),
        skills: skills,
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
                'Welcome to ALU Connect',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AluColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us about your skills so we can match you with the right opportunities.',
                style: TextStyle(color: AluColors.lightGrey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: skillController,
                      decoration: const InputDecoration(
                        labelText: 'Add a skill',
                        prefixIcon: Icon(Icons.psychology_outlined),
                      ),
                      onSubmitted: (_) => addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: addSkill,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AluColors.navy,
                      foregroundColor: AluColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          deleteIconColor: AluColors.red,
                          onDeleted: () => setState(() => skills.remove(skill)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading ? null : finish,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AluColors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
