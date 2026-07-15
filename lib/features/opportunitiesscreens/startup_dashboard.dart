import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/startup_model.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';
import 'post_opportunity.dart';

class StartupDashboardScreen extends ConsumerWidget {
  const StartupDashboardScreen({super.key});

  Future<void> deleteOpportunity(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null || user.startupId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Startup profile not found')));
    }

    final startupAsync = ref.watch(myStartupProvider(user.startupId));
    final opportunitiesAsync = ref.watch(myStartupOpportunitiesProvider(user.startupId));

    return Scaffold(
      backgroundColor: AluColors.surface,
      body: SafeArea(
        child: startupAsync.when(
          data: (startup) {
            if (startup == null) {
              return const Center(child: Text('Startup not found'));
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Hello, ${user.names} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AluColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  startup.companyName,
                  style: const TextStyle(color: AluColors.lightGrey),
                ),
                const SizedBox(height: 20),
                _VerificationBanner(startup: startup),
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
                    if (startup.verified)
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
                        label: const Text(
                          'Post',
                          style: TextStyle(color: AluColors.red),
                        ),
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
                          startup.verified
                              ? 'No opportunities posted yet. Tap Post to add one.'
                              : 'You can post opportunities after ALU verifies your startup.',
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
                                onPressed: () => deleteOpportunity(context, ref, opp),
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
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
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
