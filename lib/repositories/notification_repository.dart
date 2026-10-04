import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../models/notification_item.dart';
import '../services/preferences_service.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final PreferencesService _prefs;

  NotificationRepository({
    FirebaseFirestore? firestore,
    required PreferencesService prefs,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs;

  Stream<List<NotificationItem>> watchNotifications({
    String? householdId,
    String? panchayat,
  }) {
    return _firestore
        .collection(FirebaseConstants.colNotifications)
        .snapshots()
        .map((snap) {
      final readIds = _prefs.getReadNotifications();
      final cleanHid = householdId?.trim().toUpperCase();
      final cleanPanch = panchayat?.trim().toLowerCase();

      final list = <NotificationItem>[];

      for (final doc in snap.docs) {
        final item = NotificationItem.fromFirestore(
          doc.id,
          doc.data(),
          isRead: readIds.contains(doc.id),
        );

        // Hide expired items immediately
        if (item.isExpired) continue;

        // Target household filtering
        if (item.targetHousehold != null && item.targetHousehold!.trim().isNotEmpty) {
          if (cleanHid == null || item.targetHousehold!.trim().toUpperCase() != cleanHid) {
            continue;
          }
        }

        // Target panchayat filtering
        if (item.panchayat != null && item.panchayat!.trim().isNotEmpty) {
          if (cleanPanch != null &&
              cleanPanch.isNotEmpty &&
              item.panchayat!.trim().toLowerCase() != cleanPanch) {
            continue;
          }
        }

        list.add(item);
      }

      // Sort newest first
      list.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      return list;
    });
  }

  Future<void> markAsRead(String id) async {
    await _prefs.markNotificationRead(id);
  }
}
