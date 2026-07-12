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
}
