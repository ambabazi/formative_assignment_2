import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../repositories/auth_repo.dart';
import '../models/user_model.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo();
});

final loggedInUserProvider = StateProvider<UserModel?>((ref) {
  return null;
});
