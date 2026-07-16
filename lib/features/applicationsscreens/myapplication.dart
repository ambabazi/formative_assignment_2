import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/application_model.dart';
import '../../providers/application_providers.dart';
import '../../providers/auth_providers.dart';
import '../../utils/alu_theme.dart';

class MyApplicationScreen extends ConsumerStatefulWidget {
  const MyApplicationScreen({super.key});

  @override
  ConsumerState<MyApplicationScreen> createState() => _MyApplicationScreenState();
}

class _MyApplicationScreenState extends ConsumerState<MyApplicationScreen> {
  String selectedFilter = 'All';

  final filters = ['All', 'pending', 'shortlisted', 'accepted', 'rejected'];

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

  String statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final applications = ref.watch(myApplicationsEnrichedProvider(user.uuid));

    return Scaffold(
      backgroundColor: AluColors.surface,
      body: SafeArea(
        child: applications.when(
          data: (list) {
            final filtered = selectedFilter == 'All'
                ? list
                : list
                    .where((a) => a.application.status.name == selectedFilter)
                    .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    'My Applications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AluColors.navy,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = filter == selectedFilter;
                      final label = filter == 'All'
                          ? 'All'
                          : filter[0].toUpperCase() + filter.substring(1);

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => selectedFilter = filter),
                        selectedColor: AluColors.red,
                        labelStyle: TextStyle(
                          color: isSelected ? AluColors.white : AluColors.navy,
                          fontSize: 12,
                        ),
                        backgroundColor: AluColors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No applications yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final app = item.application;
                            final color = statusColor(app.status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AluColors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AluColors.navy.withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.work_outline,
                                      color: AluColors.navy,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.opportunityTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AluColors.navy,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.startupName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AluColors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Applied ${app.appliedAt.toString().split(' ')[0]}',
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
                                      statusLabel(app.status),
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
}
