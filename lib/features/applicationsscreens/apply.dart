import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/application_model.dart';
import '../../models/opportunity_model.dart';
import '../../providers/application_providers.dart';
import '../../providers/auth_providers.dart';
import '../../utils/skill_matcher.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final OpportunityModel opportunity;

  const ApplyScreen({super.key, required this.opportunity});

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  bool isLoading = false;

  Future<void> handleApply() async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final application = ApplicationModel(
        id: const Uuid().v4(),
        studentId: user.uuid,
        opportunityId: widget.opportunity.id,
        appliedAt: DateTime.now(),
      );

      await ref.read(applicationRepoProvider).submit(application);
      ref.invalidate(myApplicationsProvider(user.uuid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted')),
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
    final match = user == null
        ? 0.0
        : SkillMatcher.calculateMatch(
            studentSkills: user.skills,
            requiredSkills: widget.opportunity.skillsRequired,
          );
    final matchPercent = (match * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(widget.opportunity.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.opportunity.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text('Your match: $matchPercent%'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.opportunity.skillsRequired
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : handleApply,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
