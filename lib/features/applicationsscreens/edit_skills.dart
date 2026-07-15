import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/alu_theme.dart';

class EditSkillsScreen extends ConsumerStatefulWidget {
  const EditSkillsScreen({super.key});

  @override
  ConsumerState<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends ConsumerState<EditSkillsScreen> {
  final skillController = TextEditingController();
  final locationController = TextEditingController();
  List<String> skills = [];
  bool isLoading = false;
  bool initialized = false;

  void addSkill() {
    final skill = skillController.text.trim();
    if (skill.isEmpty || skills.contains(skill)) return;

    setState(() {
      skills.add(skill);
      skillController.clear();
    });
  }

  Future<void> save() async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      await ref.read(authRepoProvider).updateSkills(user.uuid, skills);
      await ref.read(authRepoProvider).updateLocation(
            user.uuid,
            locationController.text.trim(),
          );

      ref.read(loggedInUserProvider.notifier).state = user.copyWith(
        skills: skills,
        location: locationController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.pop(context);
      }
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
    final user = ref.watch(loggedInUserProvider);

    if (user != null && !initialized) {
      skills = List<String>.from(user.skills);
      locationController.text = user.location;
      initialized = true;
    }

    return Scaffold(
      backgroundColor: AluColors.surface,
      appBar: AppBar(title: const Text('Edit Skills')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
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
              onPressed: isLoading ? null : save,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AluColors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
