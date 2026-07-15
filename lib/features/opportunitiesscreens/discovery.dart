import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/opportunity_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';
import '../applicationsscreens/apply.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final searchController = TextEditingController();
  String selectedCategory = 'All';

  final categories = ['All', 'Design', 'Engineering', 'Marketing', 'Data'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserProvider);
    final opportunities = ref.watch(opportunitiesProvider);

    return Scaffold(
      backgroundColor: AluColors.surface,
      body: SafeArea(
        child: opportunities.when(
          data: (list) {
            final filtered = list.where((opp) {
              final matchesSearch = opp.title
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()) ||
                  opp.description
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase());
              final matchesCategory = selectedCategory == 'All' ||
                  opp.skillsRequired.any(
                    (s) => s.toLowerCase().contains(selectedCategory.toLowerCase()),
                  );
              return matchesSearch && matchesCategory;
            }).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(opportunitiesProvider),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello,',
                              style: TextStyle(color: AluColors.lightGrey, fontSize: 14),
                            ),
                            Text(
                              '${user?.names ?? 'Student'} 👋',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AluColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AluColors.navy,
                        child: Text(
                          user?.names.isNotEmpty == true
                              ? user!.names[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: AluColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search opportunities...',
                      prefixIcon: const Icon(Icons.search, color: AluColors.lightGrey),
                      suffixIcon: Icon(Icons.tune, color: AluColors.navy.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat == selectedCategory;

                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(() => selectedCategory = cat),
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
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Opportunities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AluColors.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No opportunities found')),
                    )
                  else
                    ...filtered.map((opp) {
                      return _OpportunityCard(
                        opportunity: opp,
                        onTap: () => _openApply(context, opp, user),
                        canApply: user?.role == UserRole.student,
                      );
                    }),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  void _openApply(BuildContext context, OpportunityModel opportunity, UserModel? user) {
    if (user?.role != UserRole.student) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ApplyScreen(opportunity: opportunity)),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final bool canApply;
  final VoidCallback onTap;

  const _OpportunityCard({
    required this.opportunity,
    required this.canApply,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AluColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AluColors.navy.withValues(alpha: 0.1),
          child: const Icon(Icons.work_outline, color: AluColors.navy, size: 20),
        ),
        title: Text(
          opportunity.title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AluColors.navy),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              opportunity.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            if (opportunity.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                opportunity.location,
                style: const TextStyle(fontSize: 11, color: AluColors.lightGrey),
              ),
            ],
          ],
        ),
        trailing: canApply ? const Icon(Icons.chevron_right, color: AluColors.lightGrey) : null,
        onTap: canApply ? onTap : null,
      ),
    );
  }
}
