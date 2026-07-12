import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/skill_matcher.dart';
import '../applicationsscreens/apply.dart';
import '../applicationsscreens/myapplication.dart';
import 'post_opportunity.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);
    final opportunities = ref.watch(opportunitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${user?.names ?? 'Student'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyApplicationScreen()),
              );
            },
          ),
          if (user?.role == UserRole.startupAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostOpportunityScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepoProvider).signOut();
              ref.read(loggedInUserProvider.notifier).state = null;
            },
          ),
        ],
      ),
      body: opportunities.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No opportunities yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final opp = list[index];
              final match = user == null
                  ? 0.0
                  : SkillMatcher.calculateMatch(
                      studentSkills: user.skills,
                      requiredSkills: opp.skillsRequired,
                    );
              final matchPercent = (match * 100).round();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(opp.title),
                  subtitle: Text(opp.description),
                  trailing: user?.role == UserRole.student
                      ? Text('$matchPercent% match')
                      : null,
                  onTap: () {
                    if (user?.role != UserRole.student) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplyScreen(opportunity: opp),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
