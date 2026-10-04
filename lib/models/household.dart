class Household {
  final String id;
  final String? name;
  final String? house;
  final String? address;
  final String? ward;
  final String? panchayat;
  final String? point;
  final String? phone;
  final String? email;
  final String? photo;
  final bool isVerified;
  final bool emailVerified;
  final String status;
  final String? uid;
  final bool online;
  final String? lastSeen;
  final String? lastLogin;
  final int? score;

  const Household({
    required this.id,
    this.name,
    this.house,
    this.address,
    this.ward,
    this.panchayat,
    this.point,
    this.phone,
    this.email,
    this.photo,
    this.isVerified = false,
    this.emailVerified = false,
    this.status = 'active',
    this.uid,
    this.online = false,
    this.lastSeen,
    this.lastLogin,
    this.score,
  });

  bool get isSuspended => status.toLowerCase() == 'suspended';
  bool get isFullyVerified => isVerified || emailVerified;

  String get headOfFamily => displayName;
  String? get photoUrl => photo;

  String get displayName => (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'Household $id';
  String get shortInitials {
    final n = displayName;
    final parts = n.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'HH';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory Household.fromFirestore(String id, Map<String, dynamic> data) {
    return Household(
      id: id,
      name: data['name']?.toString(),
      house: data['house']?.toString(),
      address: data['address']?.toString(),
      ward: data['ward']?.toString(),
      panchayat: (data['panchayat'] ?? data['panchayatName'])?.toString(),
      point: (data['point'] ?? data['collectionPoint'])?.toString(),
      phone: data['phone']?.toString(),
      email: data['email']?.toString(),
      photo: data['photo']?.toString(),
      isVerified: data['isVerified'] == true || data['verified'] == true,
      emailVerified: data['emailVerified'] == true,
      status: data['status']?.toString() ?? 'active',
      uid: data['uid']?.toString(),
      online: data['online'] == true,
      lastSeen: data['lastSeen']?.toString(),
      lastLogin: data['lastLogin']?.toString(),
      score: data['score'] is int ? data['score'] as int : int.tryParse(data['score']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (house != null) 'house': house,
      if (address != null) 'address': address,
      if (ward != null) 'ward': ward,
      if (panchayat != null) 'panchayat': panchayat,
      if (point != null) 'point': point,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (photo != null) 'photo': photo,
      'isVerified': isVerified,
      'emailVerified': emailVerified,
      'status': status,
      if (uid != null) 'uid': uid,
      'online': online,
      if (lastSeen != null) 'lastSeen': lastSeen,
      if (lastLogin != null) 'lastLogin': lastLogin,
      if (score != null) 'score': score,
    };
  }

  Household copyWith({
    String? name,
    String? house,
    String? address,
    String? ward,
    String? panchayat,
    String? point,
    String? phone,
    String? email,
    String? photo,
    bool? isVerified,
    bool? emailVerified,
    String? status,
    String? uid,
    bool? online,
    String? lastSeen,
    String? lastLogin,
    int? score,
  }) {
    return Household(
      id: id,
      name: name ?? this.name,
      house: house ?? this.house,
      address: address ?? this.address,
      ward: ward ?? this.ward,
      panchayat: panchayat ?? this.panchayat,
      point: point ?? this.point,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      isVerified: isVerified ?? this.isVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      status: status ?? this.status,
      uid: uid ?? this.uid,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
      lastLogin: lastLogin ?? this.lastLogin,
      score: score ?? this.score,
    );
  }
}
