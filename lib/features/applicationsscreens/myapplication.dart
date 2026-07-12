import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/application_providers.dart';
import '../../providers/auth_providers.dart';

class MyApplicationScreen extends ConsumerWidget {
  const MyApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }

    final applications = ref.watch(myApplicationsProvider(user.uuid));

    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: applications.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No applications yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final app = list[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Opportunity: ${app.opportunityId}'),
                  subtitle: Text('Applied: ${app.appliedAt.toString().split(' ')[0]}'),
                  trailing: Chip(label: Text(app.status.name)),
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
