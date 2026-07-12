import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  ConsumerState<PostOpportunityScreen> createState() =>
      _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
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

  Future<void> handlePost() async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields and add skills')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final opportunity = OpportunityModel(
        id: '',
        startupId: user.uuid,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        skillsRequired: skills,
      );

      await ref.read(opportunityRepoProvider).create(opportunity);
      ref.invalidate(opportunitiesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity posted')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Post Opportunity')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skillController,
                    decoration: const InputDecoration(labelText: 'Skill'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addSkill,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () => setState(() => skills.remove(skill)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : handlePost,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
