import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../models/support_report.dart';

class SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<SupportReport>> watchMyReports(String householdId) {
    if (householdId.trim().isEmpty) return Stream.value([]);
    final cleanHid = householdId.trim().toUpperCase();

    return _firestore
        .collection(FirebaseConstants.colReports)
        .where('householdId', isEqualTo: cleanHid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => SupportReport.fromFirestore(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> createReport(SupportReport report) async {
    final payload = report.toMap();
    await _firestore
        .collection(FirebaseConstants.colReports)
        .doc(report.id)
        .set(payload, SetOptions(merge: false));
  }
}
