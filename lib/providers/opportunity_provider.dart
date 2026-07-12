import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/opportunity_repo.dart';
import '../models/opportunity_model.dart';

final opportunityRepoProvider = Provider<OpportunityRepo>((ref) {
  return OpportunityRepo();
});

final opportunitiesProvider =
    FutureProvider<List<OpportunityModel>>((ref) async {
  final repo = ref.watch(opportunityRepoProvider);
  return repo.getAllOpen();
});
