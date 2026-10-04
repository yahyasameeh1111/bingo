import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../models/collection_point.dart';

class CollectionPointRepository {
  final FirebaseFirestore _firestore;

  CollectionPointRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CollectionPoint>> watchCollectionPoints() {
    return _firestore
        .collection(FirebaseConstants.colCollectionPoints)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => CollectionPoint.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  CollectionPoint? findAssignedPoint(
    List<CollectionPoint> points,
    String? assignedPointId,
  ) {
    if (points.isEmpty) return null;
    if (assignedPointId == null || assignedPointId.trim().isEmpty) {
      return points.first;
    }

    final match = points.firstWhere(
      (p) => p.matchesAssigned(assignedPointId),
      orElse: () => points.first,
    );
    return match;
  }
}
