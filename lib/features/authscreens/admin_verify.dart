import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';
import 'admin_startup_detail.dart';

class AdminVerifyScreen extends ConsumerWidget {
  const AdminVerifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startups = ref.watch(unverifiedStartupsProvider);

    return Scaffold(
      backgroundColor: AluColors.surface,
      appBar: AppBar(
        title: const Text('Verify Startups'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authRepoProvider).signOut();
              ref.read(loggedInUserProvider.notifier).state = null;
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: startups.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No startups waiting for verification'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final startup = list[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminStartupDetailScreen(startup: startup),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AluColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              startup.companyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AluColors.navy,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AluColors.lightGrey),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        startup.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${startup.industry} · ${startup.location}',
                        style: const TextStyle(color: AluColors.lightGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to view full details and verify',
                        style: TextStyle(color: AluColors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
