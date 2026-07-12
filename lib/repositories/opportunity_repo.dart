import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class OpportunityRepo {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String collectionName = 'opportunities';

  Future<List<OpportunityModel>> getAllOpen() async {
    final snapshot = await db
        .collection(collectionName)
        .where('status', isEqualTo: 'open')
        .get();

    final List<OpportunityModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(OpportunityModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }

  Future<OpportunityModel?> getById(String id) async {
    final doc = await db.collection(collectionName).doc(id).get();

    if (!doc.exists) return null;

    return OpportunityModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<String> create(OpportunityModel opportunity) async {
    final docRef =
        await db.collection(collectionName).add(opportunity.toFirestore());

    return docRef.id;
  }

  Future<void> update(OpportunityModel opportunity) async {
    await db
        .collection(collectionName)
        .doc(opportunity.id)
        .update(opportunity.toFirestore());
  }

  Future<void> delete(String id) async {
    await db.collection(collectionName).doc(id).delete();
  }

  Future<List<OpportunityModel>> getByStartup(String startupId) async {
    final snapshot = await db
        .collection(collectionName)
        .where('startupId', isEqualTo: startupId)
        .get();

    final List<OpportunityModel> list = [];

    for (final doc in snapshot.docs) {
      list.add(OpportunityModel.fromFirestore(doc.data(), doc.id));
    }

    return list;
  }
}
