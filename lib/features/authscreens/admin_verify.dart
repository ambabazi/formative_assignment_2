import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';

class AdminVerifyScreen extends ConsumerWidget {
  const AdminVerifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startups = ref.watch(unverifiedStartupsProvider);

    return Scaffold(
      backgroundColor: AluColors.surface,
      appBar: AppBar(title: const Text('Verify Startups')),
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

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AluColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup.companyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AluColors.navy,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(startup.description),
                    const SizedBox(height: 4),
                    Text(
                      '${startup.industry} · ${startup.location}',
                      style: const TextStyle(color: AluColors.lightGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await ref
                              .read(startupRepoProvider)
                              .setVerified(startup.id, true);
                          ref.invalidate(unverifiedStartupsProvider);
                          ref.invalidate(opportunitiesProvider);
                        },
                        child: const Text('Verify startup'),
                      ),
                    ),
                  ],
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
