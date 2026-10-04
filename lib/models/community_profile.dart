class CommunityProfile {
  final String uid;
  final String name;
  final String handle;
  final String? photo;
  final String? bio;
  final String? panchayat;
  final String? ward;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final String? updatedAt;
  final DateTime? createdAt;

  const CommunityProfile({
    required this.uid,
    required this.name,
    required this.handle,
    String? photo,
    String? photoUrl,
    this.bio,
    this.panchayat,
    this.ward,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.updatedAt,
    this.createdAt,
  }) : photo = photo ?? photoUrl;

  String? get photoUrl => photo;

  String get initials {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'HH';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory CommunityProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    int parseCount(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    final name = (data['name'] ?? data['displayName'] ?? 'Household').toString();
    final handle = (data['handle'] ?? name.replaceAll(' ', '').toLowerCase()).toString();

    DateTime? created;
    if (data['createdAt'] is String) {
      created = DateTime.tryParse(data['createdAt']);
    }

    return CommunityProfile(
      uid: uid,
      name: name,
      handle: handle.startsWith('@') ? handle.substring(1) : handle,
      photo: (data['photo'] ?? data['photoUrl'] ?? data['avatar'] ?? data['authorPhoto'])?.toString(),
      bio: data['bio']?.toString(),
      panchayat: (data['panchayat'] ?? data['panchayatName'])?.toString(),
      ward: data['ward']?.toString(),
      followersCount: parseCount(data['followersCount']),
      followingCount: parseCount(data['followingCount']),
      postsCount: parseCount(data['postsCount']),
      updatedAt: data['updatedAt']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'handle': handle,
      if (photo != null) 'photo': photo,
      if (photo != null) 'photoUrl': photo,
      if (bio != null) 'bio': bio,
      if (panchayat != null) 'panchayat': panchayat,
      if (ward != null) 'ward': ward,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  CommunityProfile copyWith({
    String? name,
    String? handle,
    String? photo,
    String? bio,
    String? panchayat,
    String? ward,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    DateTime? createdAt,
  }) {
    return CommunityProfile(
      uid: uid,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      panchayat: panchayat ?? this.panchayat,
      ward: ward ?? this.ward,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      updatedAt: updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
