import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationRepo {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String collectionName = 'applications';

  Future<void> submit(ApplicationModel application) async {
    await db
        .collection(collectionName)
        .doc(application.id)
        .set(application.toFirestore());
  }

  Future<List<ApplicationModel>> getByStudent(String studentId) async {
    final snapshot = await db
        .collection(collectionName)
        .where('studentId', isEqualTo: studentId)
        .get();

    final List<ApplicationModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(ApplicationModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  Stream<List<ApplicationModel>> watchByStudent(String studentId) {
    return db
        .collection(collectionName)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final List<ApplicationModel> list = [];

      for (final doc in snapshot.docs) {
        list.add(ApplicationModel.fromFirestore(doc.data(), doc.id));
      }

      return list;
    });
  }

  Stream<List<ApplicationModel>> watchAll() {
    return db.collection(collectionName).snapshots().map((snapshot) {
      final List<ApplicationModel> list = [];

      for (final doc in snapshot.docs) {
        list.add(ApplicationModel.fromFirestore(doc.data(), doc.id));
      }

      return list;
    });
  }

  Future<List<ApplicationModel>> getByOpportunity(String opportunityId) async {
    final snapshot = await db
        .collection(collectionName)
        .where('opportunityId', isEqualTo: opportunityId)
        .get();

    final List<ApplicationModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(ApplicationModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  Future<void> updateStatus(String id, ApplicationStatus newStatus) async {
    await db.collection(collectionName).doc(id).update({
      'status': newStatus.name,
    });
  }
}
