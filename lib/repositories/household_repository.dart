import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../models/household.dart';

class HouseholdRepository {
  final FirebaseFirestore _firestore;

  HouseholdRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<Household?> watchHousehold(String id) {
    if (id.trim().isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirebaseConstants.colHouseholds)
        .doc(id.trim().toUpperCase())
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Household.fromFirestore(snap.id, snap.data()!);
    });
  }

  Future<Household?> getHousehold(String id) async {
    if (id.trim().isEmpty) return null;
    final doc = await _firestore
        .collection(FirebaseConstants.colHouseholds)
        .doc(id.trim().toUpperCase())
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return Household.fromFirestore(doc.id, doc.data()!);
  }

  Future<void> updateHousehold(Household household) async {
    final payload = household.toMap();
    // emailVerified is security-sensitive and not updated by ordinary profile edits
    payload.remove('emailVerified');
    await _firestore
        .collection(FirebaseConstants.colHouseholds)
        .doc(household.id.trim().toUpperCase())
        .set(payload, SetOptions(merge: true));
  }

  Future<void> markEmailVerified(String id) async {
    await _firestore
        .collection(FirebaseConstants.colHouseholds)
        .doc(id.trim().toUpperCase())
        .set({'emailVerified': true}, SetOptions(merge: true));
  }
}
