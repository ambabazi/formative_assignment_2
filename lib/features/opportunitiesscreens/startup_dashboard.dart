import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/startup_model.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../repositories/startup_repo.dart';
import '../../utils/alu_theme.dart';
import 'post_opportunity.dart';

class StartupDashboardScreen extends ConsumerStatefulWidget {
  const StartupDashboardScreen({super.key});

  @override
  ConsumerState<StartupDashboardScreen> createState() =>
      _StartupDashboardScreenState();
}

class _StartupDashboardScreenState extends ConsumerState<StartupDashboardScreen> {
  bool showRegisterForm = false;

  Future<void> switchStartup(String startupId) async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    await ref.read(authRepoProvider).selectActiveStartup(
          uuid: user.uuid,
          startupId: startupId,
        );
    ref.read(loggedInUserProvider.notifier).state =
        user.copyWith(startupId: startupId);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final myStartupsAsync = ref.watch(myStartupsProvider(user.uuid));

    return Scaffold(
      backgroundColor: AluColors.surface,
      body: SafeArea(
        child: myStartupsAsync.when(
          data: (startups) {
            if (startups.isEmpty || showRegisterForm) {
              return _RegisterStartupView(
                existingCount: startups.length,
                onCancel: startups.isEmpty
                    ? null
                    : () => setState(() => showRegisterForm = false),
                onRegistered: (startupId) async {
                  final current = ref.read(loggedInUserProvider);
                  if (current == null) return;

                  await ref.read(authRepoProvider).linkStartupToUser(
                        uuid: current.uuid,
                        startupId: startupId,
                      );
                  ref.read(loggedInUserProvider.notifier).state =
                      current.copyWith(startupId: startupId, onboardingComplete: true);
                  ref.invalidate(myStartupsProvider(current.uuid));
                  if (mounted) setState(() => showRegisterForm = false);
                },
              );
            }

            final activeId = user.startupId.isNotEmpty &&
                    startups.any((s) => s.id == user.startupId)
                ? user.startupId
                : startups.first.id;

            if (user.startupId != activeId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                switchStartup(activeId);
              });
            }

            final activeStartup =
                startups.firstWhere((s) => s.id == activeId, orElse: () => startups.first);

            return _StartupDashboardContent(
              userName: user.names,
              startups: startups,
              activeStartup: activeStartup,
              onSelectStartup: switchStartup,
              onRegisterAnother: startups.length < StartupRepo.maxStartupsPerAdmin
                  ? () => setState(() => showRegisterForm = true)
                  : null,
              onDeleteOpportunity: (opp) => _deleteOpportunity(context, ref, opp),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Future<void> _deleteOpportunity(
    BuildContext context,
    WidgetRef ref,
    OpportunityModel opp,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete opportunity?'),
        content: Text('Remove "${opp.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(opportunityRepoProvider).delete(opp.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }
}

class _StartupDashboardContent extends ConsumerWidget {
  final String userName;
  final List<StartupModel> startups;
  final StartupModel activeStartup;
  final ValueChanged<String> onSelectStartup;
  final VoidCallback? onRegisterAnother;
  final void Function(OpportunityModel opp) onDeleteOpportunity;

  const _StartupDashboardContent({
    required this.userName,
    required this.startups,
    required this.activeStartup,
    required this.onSelectStartup,
    required this.onRegisterAnother,
    required this.onDeleteOpportunity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync =
        ref.watch(myStartupOpportunitiesProvider(activeStartup.id));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Hello, $userName 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AluColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your registered startups',
          style: TextStyle(color: AluColors.lightGrey),
        ),
        const SizedBox(height: 16),
        if (startups.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: startups.map((startup) {
              final selected = startup.id == activeStartup.id;
              return ChoiceChip(
                label: Text(startup.companyName),
                selected: selected,
                onSelected: (_) => onSelectStartup(startup.id),
                selectedColor: AluColors.navy.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected ? AluColors.navy : AluColors.lightGrey,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          activeStartup.companyName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AluColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        _VerificationBanner(startup: activeStartup),
        if (onRegisterAnother != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRegisterAnother,
            icon: const Icon(Icons.add_business_outlined),
            label: Text(
              'Register another startup (${startups.length}/${StartupRepo.maxStartupsPerAdmin})',
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Opportunities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AluColors.navy,
              ),
            ),
            if (activeStartup.verified)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PostOpportunityScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: AluColors.red),
                label: const Text('Post', style: TextStyle(color: AluColors.red)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        opportunitiesAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AluColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  activeStartup.verified
                      ? 'No opportunities posted yet. Tap Post to add one.'
                      : 'Register and wait for ALU verification before posting opportunities.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AluColors.lightGrey),
                ),
              );
            }

            return Column(
              children: list.map((opp) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AluColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opp.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AluColors.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              opp.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AluColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AluColors.red),
                        onPressed: () => onDeleteOpportunity(opp),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }
}

class _RegisterStartupView extends ConsumerStatefulWidget {
  final int existingCount;
  final VoidCallback? onCancel;
  final ValueChanged<String> onRegistered;

  const _RegisterStartupView({
    required this.existingCount,
    required this.onCancel,
    required this.onRegistered,
  });

  @override
  ConsumerState<_RegisterStartupView> createState() => _RegisterStartupViewState();
}

class _RegisterStartupViewState extends ConsumerState<_RegisterStartupView> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final industryController = TextEditingController();
  final locationController = TextEditingController(text: 'ALU Campus');
  final websiteController = TextEditingController();
  bool isLoading = false;

  Future<void> submit() async {
    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    if (widget.existingCount >= StartupRepo.maxStartupsPerAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only register up to 2 startups per account'),
        ),
      );
      return;
    }

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

      final startupId = await ref.read(startupRepoProvider).create(startup);
      widget.onRegistered(startupId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Startup submitted — waiting for ALU verification'),
          ),
        );
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
    final isFirst = widget.existingCount == 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          if (widget.onCancel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to dashboard'),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            isFirst ? 'Register your startup' : 'Register another startup',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AluColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFirst
                ? 'As a student startup admin, register your venture here. ALU will verify it before students can see your opportunities.'
                : 'You can register up to ${StartupRepo.maxStartupsPerAdmin} startups (${widget.existingCount} registered so far).',
            style: const TextStyle(color: AluColors.lightGrey),
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
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final StartupModel startup;

  const _VerificationBanner({required this.startup});

  @override
  Widget build(BuildContext context) {
    if (startup.verified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Verified by ALU — your opportunities are visible to students',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pending ALU verification — students cannot see your opportunities yet',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
