import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  final String startupId;

  const PostOpportunityScreen({super.key, required this.startupId});

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

    if (user.startupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register your startup first')),
      );
      return;
    }

    final startup = await ref.read(startupRepoProvider).getById(widget.startupId);
    if (!mounted) return;
    if (startup == null || !startup.verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your startup must be verified by ALU before posting')),
      );
      return;
    }

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
        startupId: widget.startupId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        skillsRequired: skills,
      );

      await ref.read(opportunityRepoProvider).create(opportunity);
      ref.invalidate(opportunitiesProvider);

      titleController.clear();
      descriptionController.clear();
      locationController.clear();
      setState(() => skills.clear());

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
      backgroundColor: AluColors.surface,
      appBar: AppBar(
        title: const Text('Post Opportunity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Share a role with ALU students',
                style: TextStyle(color: AluColors.lightGrey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: skillController,
                      decoration: const InputDecoration(
                        labelText: 'Required skill',
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
                onPressed: isLoading ? null : handlePost,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AluColors.white,
                        ),
                      )
                    : const Text('Publish Opportunity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
