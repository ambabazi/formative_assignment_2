import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/opportunity_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/skill_matcher.dart';
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
                  if (filtered.isNotEmpty) ...[
                    const Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AluColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FeaturedCard(
                      opportunity: filtered.first,
                      user: user,
                      onTap: () => _openApply(context, filtered.first, user),
                    ),
                    const SizedBox(height: 24),
                  ],
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
                      final match = user == null
                          ? 0.0
                          : SkillMatcher.calculateMatch(
                              studentSkills: user.skills,
                              requiredSkills: opp.skillsRequired,
                            );
                      final matchPercent = (match * 100).round();

                      return _OpportunityCard(
                        opportunity: opp,
                        matchPercent: matchPercent,
                        showMatch: user?.role == UserRole.student,
                        onTap: () => _openApply(context, opp, user),
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

class _FeaturedCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final UserModel? user;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.opportunity,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: user?.role == UserRole.student ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AluColors.navy, Color(0xFF003D7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AluColors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Featured',
                style: TextStyle(color: AluColors.white, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              opportunity.title,
              style: const TextStyle(
                color: AluColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              opportunity.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AluColors.lightGrey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (opportunity.skillsRequired.isNotEmpty)
              Wrap(
                spacing: 6,
                children: opportunity.skillsRequired
                    .take(3)
                    .map<Widget>((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AluColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(color: AluColors.white, fontSize: 11),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final int matchPercent;
  final bool showMatch;
  final VoidCallback onTap;

  const _OpportunityCard({
    required this.opportunity,
    required this.matchPercent,
    required this.showMatch,
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
        trailing: showMatch
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AluColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$matchPercent%',
                  style: const TextStyle(
                    color: AluColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        onTap: showMatch ? onTap : null,
      ),
    );
  }
}
