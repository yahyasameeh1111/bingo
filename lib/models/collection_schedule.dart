import '../core/utils/date_formatter.dart';

class CollectionSchedule {
  final String id;
  final String wasteType;
  final String? rawDay;
  final DateTime? explicitDate;
  final String time;
  final String? panchayat;
  final String? instruction;

  const CollectionSchedule({
    required this.id,
    required this.wasteType,
    this.rawDay,
    this.explicitDate,
    required this.time,
    this.panchayat,
    this.instruction,
  });

  bool get isRecurring => explicitDate == null && rawDay != null && rawDay!.trim().isNotEmpty;

  int? get dayIndex => DateFormatter.normalizeDay(rawDay);

  bool matchesPanchayat(String? targetPanchayat) {
    if (targetPanchayat == null || targetPanchayat.trim().isEmpty) return true;
    if (panchayat == null || panchayat!.trim().isEmpty) return true;
    return panchayat!.trim().toLowerCase() == targetPanchayat.trim().toLowerCase();
  }

  factory CollectionSchedule.fromFirestore(String id, Map<String, dynamic> data) {
    final type = (data['wasteType'] ??
            data['waste type'] ??
            data['type'] ??
            data['name'] ??
            'General')
        .toString();

    final rawDate = data['collection date'] ??
        data['collectionDate'] ??
        data['collection_date'] ??
        data['Collection Date'] ??
        data['scheduledDate'] ??
        data['scheduled date'] ??
        data['dateOfCollection'] ??
        data['Date of Collection'] ??
        data['Date'] ??
        data['date'];

    final explicit = DateFormatter.parseLiveDate(rawDate);

    final rawDay = (data['day'] ??
            data['weekday'] ??
            data['dayOfWeek'] ??
            data['dayIndex'] ??
            data['collection day'])
        ?.toString();

    final time = (data['time'] ??
            data['collectionTime'] ??
            data['collection time'] ??
            data['beforeTime'] ??
            data['collection before'] ??
            '8:00 AM')
        .toString();

    final panchayat = (data['panchayat'] ??
            data['panchayatName'] ??
            data['Panchayat'])
        ?.toString();

    final directInstructionKeys = [
      'instruction',
      'instructions',
      'collection instruction',
      'collection instructions',
      'collectionInstruction',
      'collectionInstructions',
      'message',
      'description',
      'note',
      'notes',
    ];

    String? instruction;
    for (final k in directInstructionKeys) {
      if (data[k] != null && data[k].toString().trim().isNotEmpty) {
        instruction = data[k].toString().trim();
        break;
      }
    }

    return CollectionSchedule(
      id: id,
      wasteType: type,
      rawDay: rawDay,
      explicitDate: explicit,
      time: time,
      panchayat: panchayat,
      instruction: instruction,
    );
  }
}
