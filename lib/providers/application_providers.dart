import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/application_repo.dart';
import '../models/application_model.dart';

final applicationRepoProvider = Provider<ApplicationRepo>((ref) {
  return ApplicationRepo();
});

final myApplicationsProvider =
    FutureProvider.family<List<ApplicationModel>, String>((ref, studentId) async {
  final repo = ref.watch(applicationRepoProvider);
  return repo.getByStudent(studentId);
});
