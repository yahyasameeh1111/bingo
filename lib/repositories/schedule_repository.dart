import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/utils/date_formatter.dart';
import '../models/collection_schedule.dart';

class ScheduledEvent {
  final CollectionSchedule schedule;
  final DateTime date;
  final bool isRecurring;

  const ScheduledEvent({
    required this.schedule,
    required this.date,
    this.isRecurring = false,
  });

  DateTime get dateTime => DateFormatter.combineDateAndTime(date, schedule.time);
}

class ScheduleRepository {
  final FirebaseFirestore _firestore;

  ScheduleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CollectionSchedule>> watchSchedules() {
    return _firestore.collection(FirebaseConstants.colSchedule).snapshots().map((snap) {
      return snap.docs
          .map((d) => CollectionSchedule.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  List<ScheduledEvent> resolveEvents(
    List<CollectionSchedule> schedules, {
    String? panchayat,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now().add(const Duration(days: 60));
    final cleanStart = DateTime(start.year, start.month, start.day);
    final cleanEnd = DateTime(end.year, end.month, end.day);

    final applicable = schedules.where((s) => s.matchesPanchayat(panchayat)).toList();
    final events = <ScheduledEvent>[];

    for (final s in applicable) {
      if (s.explicitDate != null) {
        // Date-specific schedule: only applies to that exact date
        final d = s.explicitDate!;
        final cleanD = DateTime(d.year, d.month, d.day);
        if (cleanD.isAfter(cleanStart.subtract(const Duration(days: 1))) &&
            cleanD.isBefore(cleanEnd.add(const Duration(days: 1)))) {
          events.add(ScheduledEvent(schedule: s, date: cleanD, isRecurring: false));
        }
      } else if (s.dayIndex != null) {
        // Recurring weekly schedule
        var cur = DateFormatter.nextDateForWeekday(s.dayIndex!, fromDate: cleanStart);
        while (!cur.isAfter(cleanEnd)) {
          events.add(ScheduledEvent(schedule: s, date: cur, isRecurring: true));
          cur = cur.add(const Duration(days: 7));
        }
      }
    }

    // Sort chronologically and deduplicate
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final seen = <String>{};
    return events.where((e) {
      final key = '${e.schedule.id}|${e.date.year}-${e.date.month}-${e.date.day}|${e.schedule.wasteType}|${e.schedule.time}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  ScheduledEvent? getNextCollection(
    List<CollectionSchedule> schedules, {
    String? panchayat,
  }) {
    final now = DateTime.now();
    final events = resolveEvents(
      schedules,
      panchayat: panchayat,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 45)),
    );

    for (final e in events) {
      if (!e.dateTime.isBefore(now)) {
        return e;
      }
    }
    return events.isNotEmpty ? events.first : null;
  }

  List<ScheduledEvent> getEventsForDate(
    List<CollectionSchedule> schedules,
    DateTime date, {
    String? panchayat,
  }) {
    final clean = DateTime(date.year, date.month, date.day);
    final events = resolveEvents(
      schedules,
      panchayat: panchayat,
      startDate: clean,
      endDate: clean,
    );
    return events.where((e) =>
        e.date.year == clean.year && e.date.month == clean.month && e.date.day == clean.day).toList();
  }

  Map<int, List<ScheduledEvent>> getWeekEvents(
    List<CollectionSchedule> schedules, {
    String? panchayat,
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    // Monday of the reference week
    final cleanRef = DateTime(ref.year, ref.month, ref.day);
    final mondayOffset = (cleanRef.weekday - 1) % 7;
    final monday = cleanRef.subtract(Duration(days: mondayOffset));
    final sunday = monday.add(const Duration(days: 6));

    final events = resolveEvents(
      schedules,
      panchayat: panchayat,
      startDate: monday,
      endDate: sunday,
    );

    final map = <int, List<ScheduledEvent>>{};
    for (int i = 0; i < 7; i++) {
      final targetDate = monday.add(Duration(days: i));
      map[targetDate.weekday] = events
          .where((e) =>
              e.date.year == targetDate.year &&
              e.date.month == targetDate.month &&
              e.date.day == targetDate.day)
          .toList();
    }
    return map;
  }
}
