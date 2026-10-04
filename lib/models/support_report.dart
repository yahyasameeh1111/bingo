import '../core/utils/date_formatter.dart';

class SupportReport {
  final String id;
  final String type; // 'missed_collection', 'account_suspended', 'issue', 'help'
  final String priority; // 'normal', 'urgent'
  final String householdId;
  final String title;
  final String description;
  final String status; // 'open', 'in-progress', 'resolved', 'rejected'
  final String reportedBy;
  final String reportedByName;
  final String? panchayat;
  final String? house;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? uid;

  const SupportReport({
    required this.id,
    required this.type,
    this.priority = 'normal',
    required this.householdId,
    required this.title,
    required this.description,
    this.status = 'open',
    this.reportedBy = 'Household',
    required this.reportedByName,
    this.panchayat,
    this.house,
    required this.createdAt,
    required this.updatedAt,
    this.uid,
  });

  String get relativeTime => DateFormatter.relativeTime(createdAt);

  factory SupportReport.fromFirestore(String id, Map<String, dynamic> data) {
    return SupportReport(
      id: id,
      type: (data['type'] ?? data['category'] ?? 'issue').toString(),
      priority: (data['priority'] ?? 'normal').toString(),
      householdId: (data['householdId'] ?? data['household'] ?? '').toString(),
      title: (data['title'] ?? 'Report').toString(),
      description: (data['description'] ?? '').toString(),
      status: (data['status'] ?? 'open').toString(),
      reportedBy: (data['reportedBy'] ?? 'Household').toString(),
      reportedByName: (data['reportedByName'] ?? 'Household').toString(),
      panchayat: data['panchayat']?.toString(),
      house: data['house']?.toString(),
      createdAt: DateFormatter.parseLiveDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: DateFormatter.parseLiveDate(data['updatedAt']) ?? DateTime.now(),
      uid: data['uid']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'priority': priority,
      'householdId': householdId,
      'title': title,
      'description': description,
      'status': status,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      if (panchayat != null) 'panchayat': panchayat,
      if (house != null) 'house': house,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (uid != null) 'uid': uid,
    };
  }
}
