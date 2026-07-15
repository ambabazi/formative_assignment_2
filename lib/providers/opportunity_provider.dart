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

final opportunitiesProvider =
    FutureProvider<List<OpportunityModel>>((ref) async {
  final oppRepo = ref.watch(opportunityRepoProvider);
  final startupRepo = ref.watch(startupRepoProvider);

  final verifiedStartups = await startupRepo.getVerified();
  final verifiedIds = verifiedStartups.map((s) => s.id).toSet();

  final allOpen = await oppRepo.getAllOpen();

  return allOpen.where((opp) => verifiedIds.contains(opp.startupId)).toList();
});

final myStartupProvider = FutureProvider.family<StartupModel?, String>((ref, startupId) async {
  if (startupId.isEmpty) return null;
  return ref.watch(startupRepoProvider).getById(startupId);
});

final unverifiedStartupsProvider = FutureProvider<List<StartupModel>>((ref) async {
  return ref.watch(startupRepoProvider).getUnverified();
});

final myStartupOpportunitiesProvider =
    FutureProvider.family<List<OpportunityModel>, String>((ref, startupId) async {
  if (startupId.isEmpty) return [];
  return ref.watch(opportunityRepoProvider).getByStartup(startupId);
});
