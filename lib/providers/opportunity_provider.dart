import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/opportunity_repo.dart';
import '../repositories/startup_repo.dart';
import '../models/opportunity_model.dart';
import '../models/startup_model.dart';

final opportunityRepoProvider = Provider<OpportunityRepo>((ref) {
  return OpportunityRepo();
});

final startupRepoProvider = Provider<StartupRepo>((ref) {
  return StartupRepo();
});

final opportunitiesProvider = StreamProvider<List<OpportunityModel>>((ref) {
  final oppRepo = ref.watch(opportunityRepoProvider);
  final startupRepo = ref.watch(startupRepoProvider);

  return oppRepo.watchAllOpen().asyncMap((opportunities) async {
    final verifiedStartups = await startupRepo.getVerified();
    final verifiedIds = verifiedStartups.map((s) => s.id).toSet();

    return opportunities
        .where((opp) => verifiedIds.contains(opp.startupId))
        .toList();
  });
});

final myStartupProvider = FutureProvider.family<StartupModel?, String>((ref, startupId) async {
  if (startupId.isEmpty) return null;
  return ref.watch(startupRepoProvider).getById(startupId);
});

final unverifiedStartupsProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.watch(startupRepoProvider).watchUnverified();
});

final myStartupOpportunitiesProvider =
    StreamProvider.family<List<OpportunityModel>, String>((ref, startupId) {
  if (startupId.isEmpty) return Stream.value([]);
  return ref.watch(opportunityRepoProvider).watchByStartup(startupId);
});
