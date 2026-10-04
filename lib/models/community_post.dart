import '../core/utils/date_formatter.dart';
import 'community_poll.dart';

class CommunityPost {
  final String id;
  final String authorUid;
  final String authorName;
  final String authorHandle;
  final String? authorPhoto;
  final String? householdId;
  final String? panchayat;
  final String? ward;
  final String text;
  final String postType; // 'post', 'photo', 'poll', 'link'
  final String? imageUrl;
  final String? linkUrl;
  final String? linkTitle;
  final CommunityPoll? poll;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final int sharesCount;
  final DateTime createdAt;

  // Local/Optimistic states
  final bool isLiked;
  final bool isSaved;
  final bool isReposted;
  final bool isFollowingAuthor;

  const CommunityPost({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.authorHandle,
    this.authorPhoto,
    this.householdId,
    this.panchayat,
    this.ward,
    required this.text,
    this.postType = 'post',
    this.imageUrl,
    this.linkUrl,
    this.linkTitle,
    this.poll,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
    this.isReposted = false,
    this.isFollowingAuthor = false,
  });

  String get relativeTime => DateFormatter.relativeTime(createdAt);

  String get initials {
    final parts = authorName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'HH';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  CommunityPost copyWith({
    String? text,
    String? imageUrl,
    CommunityPoll? poll,
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isSaved,
    bool? isReposted,
    bool? isFollowingAuthor,
  }) {
    return CommunityPost(
      id: id,
      authorUid: authorUid,
      authorName: authorName,
      authorHandle: authorHandle,
      authorPhoto: authorPhoto,
      householdId: householdId,
      panchayat: panchayat,
      ward: ward,
      text: text ?? this.text,
      postType: postType,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl,
      linkTitle: linkTitle,
      poll: poll ?? this.poll,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isReposted: isReposted ?? this.isReposted,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
    );
  }

  factory CommunityPost.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    bool isLiked = false,
    bool isSaved = false,
    bool isReposted = false,
    bool isFollowingAuthor = false,
    int? userPollVote,
    Map<int, int>? pollVoteCounts,
    int? pollTotalVotes,
  }) {
    final authorUid = (data['authorUid'] ?? data['uid'] ?? '').toString();
    final name = (data['authorName'] ?? data['name'] ?? 'Household').toString();
    final handle = (data['authorHandle'] ?? data['handle'] ?? name.replaceAll(' ', '').toLowerCase()).toString();
    final photo = data['authorPhoto'] ?? data['photo'] ?? data['avatar'];
    final hid = data['householdId']?.toString();
    final panch = data['panchayat']?.toString();
    final ward = data['ward']?.toString();
    final text = (data['text'] ?? data['content'] ?? '').toString();
    final postType = (data['postType'] ?? 'post').toString();
    final img = data['imageUrl'] ?? data['imageData'] ?? data['image'];
    final link = data['linkUrl']?.toString();
    final linkTitle = data['linkTitle']?.toString();

    CommunityPoll? poll;
    if (data['poll'] is Map<String, dynamic>) {
      poll = CommunityPoll.fromMap(
        data['poll'] as Map<String, dynamic>,
        userVote: userPollVote,
        counts: pollVoteCounts,
        total: pollTotalVotes,
      );
    }

    final created = DateFormatter.parseLiveDate(data['createdAt'] ?? data['timestamp']) ?? DateTime.now();

    int parseCount(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return CommunityPost(
      id: id,
      authorUid: authorUid,
      authorName: name,
      authorHandle: handle.startsWith('@') ? handle.substring(1) : handle,
      authorPhoto: photo?.toString(),
      householdId: hid,
      panchayat: panch,
      ward: ward,
      text: text,
      postType: postType,
      imageUrl: img?.toString(),
      linkUrl: link,
      linkTitle: linkTitle,
      poll: poll,
      likesCount: parseCount(data['likesCount']),
      commentsCount: parseCount(data['commentsCount']),
      repostsCount: parseCount(data['repostsCount']),
      sharesCount: parseCount(data['sharesCount']),
      createdAt: created,
      isLiked: isLiked,
      isSaved: isSaved,
      isReposted: isReposted,
      isFollowingAuthor: isFollowingAuthor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorHandle': authorHandle,
      if (authorPhoto != null) 'authorPhoto': authorPhoto,
      if (householdId != null) 'householdId': householdId,
      if (panchayat != null) 'panchayat': panchayat,
      if (ward != null) 'ward': ward,
      'text': text,
      'postType': postType,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (linkUrl != null) 'linkUrl': linkUrl,
      if (linkTitle != null) 'linkTitle': linkTitle,
      if (poll != null)
        'poll': {
          'question': poll!.question,
          'options': poll!.options.map((o) => {'text': o.text}).toList(),
        },
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
