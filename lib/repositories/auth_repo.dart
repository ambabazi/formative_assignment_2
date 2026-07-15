import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepo {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool isAluEmail(String email) {
    if (email.endsWith('@alustudent.com')) return true;
    if (email.endsWith('@alueducation.com')) return true;
    return false;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String names,
    required UserRole role,
  }) async {
    if (!isAluEmail(email)) {
      throw Exception('Only ALU emails can register');
    }

    if (role == UserRole.admin && !email.endsWith('@alueducation.com')) {
      throw Exception('Admin accounts must use @alueducation.com email');
    }

    final result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final newUser = UserModel(
      uuid: result.user!.uid,
      email: email,
      names: names,
      role: role,
    );

    await db.collection('users').doc(newUser.uuid).set(newUser.toFirestore());

    return newUser;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await db.collection('users').doc(result.user!.uid).get();

    if (!doc.exists) {
      throw Exception('No profile found for this account');
    }

    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? get currentUser {
    return auth.currentUser;
  }

  Future<UserModel?> getUserById(String uuid) async {
    final doc = await db.collection('users').doc(uuid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> updateSkills(String uuid, List<String> skills) async {
    await db.collection('users').doc(uuid).update({'skills': skills});
  }

  Future<void> updateLocation(String uuid, String location) async {
    await db.collection('users').doc(uuid).update({'location': location});
  }

  Future<void> completeStudentOnboarding({
    required String uuid,
    required String location,
    required List<String> skills,
  }) async {
    await db.collection('users').doc(uuid).update({
      'location': location,
      'skills': skills,
      'onboardingComplete': true,
    });
  }

  Future<void> linkStartupToUser({
    required String uuid,
    required String startupId,
  }) async {
    await db.collection('users').doc(uuid).update({
      'startupId': startupId,
      'onboardingComplete': true,
    });
  }
}
