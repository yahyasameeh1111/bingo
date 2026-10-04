class CollectionPoint {
  final String id;
  final String name;
  final String? location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? panchayat;
  final String status;

  const CollectionPoint({
    required this.id,
    required this.name,
    this.location,
    this.address,
    this.latitude,
    this.longitude,
    this.panchayat,
    this.status = 'active',
  });

  String get displayLocation {
    final parts = [location, address].where((s) => s != null && s.trim().isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' · ');
    return 'Collection Point $id';
  }

  bool matchesAssigned(String? assignedPoint) {
    if (assignedPoint == null || assignedPoint.trim().isEmpty) return false;
    final cleanAssigned = assignedPoint.trim().toLowerCase();
    final candidates = [
      id,
      name,
      location,
      address,
    ].where((s) => s != null).map((s) => s!.trim().toLowerCase());

    return candidates.any((c) => c == cleanAssigned || cleanAssigned.contains(c) || c.contains(cleanAssigned));
  }

  factory CollectionPoint.fromFirestore(String id, Map<String, dynamic> data) {
    final name = (data['name'] ?? data['point'] ?? data['title'] ?? id).toString();
    final loc = data['location']?.toString();
    final addr = data['address']?.toString();
    final panch = (data['panchayat'] ?? data['panchayatName'])?.toString();
    final st = data['status']?.toString() ?? 'active';

    double? parseCoord(List<String> keys) {
      for (final k in keys) {
        final v = data[k];
        if (v is num) return v.toDouble();
        if (v is String) {
          final parsed = double.tryParse(v);
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    final lat = parseCoord(['latitude', 'lat', 'Latitude']);
    final lng = parseCoord(['longitude', 'lng', 'lon', 'Longitude']);

    return CollectionPoint(
      id: id,
      name: name,
      location: loc,
      address: addr,
      latitude: lat,
      longitude: lng,
      panchayat: panch,
      status: st,
    );
  }
}
