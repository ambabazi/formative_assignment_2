import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/application_repo.dart';
import 'opportunity_provider.dart';
import 'auth_providers.dart';
import '../models/application_model.dart';
import '../models/opportunity_model.dart';

final applicationRepoProvider = Provider<ApplicationRepo>((ref) {
  return ApplicationRepo();
});

final myApplicationsProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, studentId) {
  return ref.watch(applicationRepoProvider).watchByStudent(studentId);
});

class StudentApplicationItem {
  final ApplicationModel application;
  final String opportunityTitle;
  final String startupName;

  StudentApplicationItem({
    required this.application,
    required this.opportunityTitle,
    required this.startupName,
  });
}

final myApplicationsEnrichedProvider =
    StreamProvider.family<List<StudentApplicationItem>, String>((ref, studentId) {
  final appRepo = ref.watch(applicationRepoProvider);
  final oppRepo = ref.watch(opportunityRepoProvider);
  final startupRepo = ref.watch(startupRepoProvider);

  return appRepo.watchByStudent(studentId).asyncMap((applications) async {
    final List<StudentApplicationItem> items = [];

    for (final application in applications) {
      final opportunity = await oppRepo.getById(application.opportunityId);
      var opportunityTitle = 'Opportunity';
      var startupName = 'Unknown startup';

      if (opportunity != null) {
        opportunityTitle = opportunity.title;
        final startup = await startupRepo.getById(opportunity.startupId);
        if (startup != null && startup.companyName.trim().isNotEmpty) {
          startupName = startup.companyName;
        }
      }

      items.add(StudentApplicationItem(
        application: application,
        opportunityTitle: opportunityTitle,
        startupName: startupName,
      ));
    }

    return items;
  });
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
    StreamProvider.family<List<StartupApplicationItem>, String>((ref, startupId) {
  if (startupId.isEmpty) return Stream.value([]);

  final appRepo = ref.watch(applicationRepoProvider);
  final oppRepo = ref.watch(opportunityRepoProvider);
  final authRepo = ref.watch(authRepoProvider);

  return appRepo.watchAll().asyncMap((allApps) async {
    final opportunities = await oppRepo.getByStartup(startupId);
    final oppMap = {for (final opp in opportunities) opp.id: opp};
    final List<StartupApplicationItem> items = [];

    for (final application in allApps) {
      final opportunity = oppMap[application.opportunityId];
      if (opportunity == null) continue;

      final student = await authRepo.getUserById(application.studentId);

      items.add(StartupApplicationItem(
        application: application,
        opportunity: opportunity,
        studentName: student?.names ?? 'Unknown student',
      ));
    }

    return items;
  });
});
