import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/application_repo.dart';
import '../repositories/opportunity_repo.dart';
import 'auth_providers.dart';
import '../models/application_model.dart';
import '../models/opportunity_model.dart';

final applicationRepoProvider = Provider<ApplicationRepo>((ref) {
  return ApplicationRepo();
});

final myApplicationsProvider =
    FutureProvider.family<List<ApplicationModel>, String>((ref, studentId) async {
  final repo = ref.watch(applicationRepoProvider);
  return repo.getByStudent(studentId);
});

class StartupApplicationItem {
  final ApplicationModel application;
  final OpportunityModel opportunity;
  final String studentName;

  StartupApplicationItem({
    required this.application,
    required this.opportunity,
    required this.studentName,
  });
}

final startupApplicationsProvider =
    FutureProvider.family<List<StartupApplicationItem>, String>((ref, startupId) async {
  final appRepo = ref.watch(applicationRepoProvider);
  final oppRepo = OpportunityRepo();
  final authRepo = ref.watch(authRepoProvider);

  final opportunities = await oppRepo.getByStartup(startupId);
  final List<StartupApplicationItem> items = [];

  for (final opportunity in opportunities) {
    final applications = await appRepo.getByOpportunity(opportunity.id);

    for (final application in applications) {
      final student = await authRepo.getUserById(application.studentId);

      items.add(StartupApplicationItem(
        application: application,
        opportunity: opportunity,
        studentName: student?.names ?? 'Unknown student',
      ));
    }
  }

  return items;
});
