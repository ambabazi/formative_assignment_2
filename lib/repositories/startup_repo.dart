import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

class StartupRepo {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String collectionName = 'startups';

  Future<List<StartupModel>> getAll() async {
    final snapshot = await db.collection(collectionName).get();

    final List<StartupModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(StartupModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  Future<List<StartupModel>> getVerified() async {
    final snapshot = await db
        .collection(collectionName)
        .where('verified', isEqualTo: true)
        .get();

    final List<StartupModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(StartupModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  Future<List<StartupModel>> getUnverified() async {
    final snapshot = await db
        .collection(collectionName)
        .where('verified', isEqualTo: false)
        .get();

    final List<StartupModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(StartupModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  Stream<List<StartupModel>> watchUnverified() {
    return db
        .collection(collectionName)
        .where('verified', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final List<StartupModel> list = [];

      for (final doc in snapshot.docs) {
        list.add(StartupModel.fromFirestore(doc.data(), doc.id));
      }

      return list;
    });
  }

  Future<StartupModel?> getById(String id) async {
    final doc = await db.collection(collectionName).doc(id).get();

    if (!doc.exists) return null;

    return StartupModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<StartupModel?> getByAdminId(String adminId) async {
    final startups = await getAllByAdminId(adminId);
    if (startups.isEmpty) return null;
    return startups.first;
  }

  Future<List<StartupModel>> getAllByAdminId(String adminId) async {
    final snapshot = await db
        .collection(collectionName)
        .where('adminId', isEqualTo: adminId)
        .get();

    final List<StartupModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(StartupModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  static const int maxStartupsPerAdmin = 2;

  Future<String> create(StartupModel startup) async {
    final docRef =
        await db.collection(collectionName).add(startup.toFirestore());

    return docRef.id;
  }

  Future<void> update(StartupModel startup) async {
    await db
        .collection(collectionName)
        .doc(startup.id)
        .update(startup.toFirestore());
  }

  Future<void> setVerified(String id, bool verified) async {
    await db.collection(collectionName).doc(id).update({'verified': verified});
  }
}
