import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/application_model.dart';
import '../../providers/application_providers.dart';
import '../../providers/auth_providers.dart';
import '../../utils/alu_theme.dart';
import '../opportunitiesscreens/post_opportunity.dart';

class StartupApplicationsScreen extends ConsumerWidget {
  const StartupApplicationsScreen({super.key});

  Color statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.shortlisted:
        return Colors.green;
      case ApplicationStatus.accepted:
        return AluColors.navy;
      case ApplicationStatus.rejected:
        return AluColors.lightGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final applications = ref.watch(startupApplicationsProvider(user.startupId));

    return Scaffold(
      backgroundColor: AluColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final user = ref.read(loggedInUserProvider);
          if (user == null || user.startupId.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostOpportunityScreen(startupId: user.startupId),
            ),
          );
        },
        backgroundColor: AluColors.red,
        foregroundColor: AluColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post'),
      ),
      body: SafeArea(
        child: applications.when(
          data: (list) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    'Applicants',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AluColors.navy,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    'Students who applied to your opportunities',
                    style: TextStyle(color: AluColors.lightGrey, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('No applications yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final app = item.application;
                            final color = statusColor(app.status);

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
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            AluColors.navy.withValues(alpha: 0.1),
                                        child: Text(
                                          item.studentName.isNotEmpty
                                              ? item.studentName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(color: AluColors.navy),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.studentName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AluColors.navy,
                                              ),
                                            ),
                                            Text(
                                              item.opportunity.title,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AluColors.lightGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          app.status.name,
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _StatusButton(
                                        label: 'Shortlist',
                                        onTap: () => _updateStatus(
                                          ref,
                                          user.startupId,
                                          app.id,
                                          ApplicationStatus.shortlisted,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusButton(
                                        label: 'Accept',
                                        onTap: () => _updateStatus(
                                          ref,
                                          user.startupId,
                                          app.id,
                                          ApplicationStatus.accepted,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusButton(
                                        label: 'Reject',
                                        onTap: () => _updateStatus(
                                          ref,
                                          user.startupId,
                                          app.id,
                                          ApplicationStatus.rejected,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    String startupId,
    String appId,
    ApplicationStatus status,
  ) async {
    await ref.read(applicationRepoProvider).updateStatus(appId, status);
    ref.invalidate(startupApplicationsProvider(startupId));
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AluColors.navy,
          side: BorderSide(color: AluColors.navy.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
