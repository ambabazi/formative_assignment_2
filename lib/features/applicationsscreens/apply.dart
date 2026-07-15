import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/application_model.dart';
import '../../models/opportunity_model.dart';
import '../../providers/application_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';

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
    final startupAsync = ref.watch(myStartupProvider(widget.opportunity.startupId));

    return Scaffold(
      backgroundColor: AluColors.surface,
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AluColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.opportunity.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AluColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  startupAsync.when(
                    data: (startup) => startup == null
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              const Icon(
                                Icons.business_outlined,
                                size: 16,
                                color: AluColors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                startup.companyName,
                                style: const TextStyle(
                                  color: AluColors.navy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                    loading: () => const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  if (widget.opportunity.location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AluColors.lightGrey),
                        const SizedBox(width: 4),
                        Text(
                          widget.opportunity.location,
                          style: const TextStyle(color: AluColors.lightGrey),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.opportunity.description,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Skills Required',
              style: TextStyle(fontWeight: FontWeight.bold, color: AluColors.navy),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.opportunity.skillsRequired
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: isLoading ? null : handleApply,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AluColors.white,
                      ),
                    )
                  : const Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }
}
