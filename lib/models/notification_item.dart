import '../core/utils/date_formatter.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime receivedAt;
  final DateTime? expiresAt;
  final String? targetHousehold;
  final String? panchayat;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.receivedAt,
    this.expiresAt,
    this.targetHousehold,
    this.panchayat,
    this.isRead = false,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isUrgent =>
      type.toUpperCase().contains('URGENT') ||
      type.toUpperCase().contains('ALERT') ||
      type.toUpperCase().contains('CRITICAL');

  String get relativeTimeText => DateFormatter.relativeTime(receivedAt);

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      receivedAt: receivedAt,
      expiresAt: expiresAt,
      targetHousehold: targetHousehold,
      panchayat: panchayat,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationItem.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    bool isRead = false,
  }) {
    String findVal(List<String> keys, String fallback) {
      for (final k in keys) {
        if (data[k] != null && data[k].toString().trim().isNotEmpty) {
          return data[k].toString().trim();
        }
      }
      return fallback;
    }

    final title = findVal(['title', 'name', 'heading', 'subject'], 'Notification');
    final message = findVal(['message', 'body', 'description', 'text', 'content'], '');
    final type = findVal(['type', 'category', 'priority'], 'INFO');

    final receivedRaw = data['receivedAt'] ??
        data['createdAt'] ??
        data['timestamp'] ??
        data['date'];
    final received = DateFormatter.parseLiveDate(receivedRaw) ?? DateTime.now();

    final expiresRaw = data['expiresAt'] ?? data['expiry'] ?? data['expiration'];
    final expires = DateFormatter.parseLiveDate(expiresRaw);

    final targetH = data['targetHousehold'] ?? data['householdId'] ?? data['household'];
    final panch = data['panchayat'] ?? data['panchayatName'];

    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      receivedAt: received,
      expiresAt: expires,
      targetHousehold: targetH?.toString(),
      panchayat: panch?.toString(),
      isRead: isRead,
    );
  }
}
