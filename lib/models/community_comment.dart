import '../core/utils/date_formatter.dart';

class CommunityComment {
  final String id;
  final String postId;
  final String authorUid;
  final String authorName;
  final String authorHandle;
  final String? authorPhoto;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorUid,
    required this.authorName,
    required this.authorHandle,
    this.authorPhoto,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  String get relativeTime => DateFormatter.relativeTime(createdAt);

  String get initials {
    final parts = authorName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'HH';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  CommunityComment copyWith({
    int? likesCount,
    bool? isLiked,
  }) {
    return CommunityComment(
      id: id,
      postId: postId,
      authorUid: authorUid,
      authorName: authorName,
      authorHandle: authorHandle,
      authorPhoto: authorPhoto,
      text: text,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory CommunityComment.fromFirestore(
    String id,
    String postId,
    Map<String, dynamic> data, {
    bool isLiked = false,
  }) {
    final name = (data['authorName'] ?? data['name'] ?? 'Household').toString();
    final handle = (data['authorHandle'] ?? data['handle'] ?? name.replaceAll(' ', '').toLowerCase()).toString();
    final photo = data['authorPhoto'] ?? data['photo'] ?? data['avatar'];
    final text = (data['text'] ?? data['content'] ?? '').toString();
    final created = DateFormatter.parseLiveDate(data['createdAt'] ?? data['timestamp']) ?? DateTime.now();

    int parseCount(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return CommunityComment(
      id: id,
      postId: postId,
      authorUid: (data['authorUid'] ?? data['uid'] ?? '').toString(),
      authorName: name,
      authorHandle: handle.startsWith('@') ? handle.substring(1) : handle,
      authorPhoto: photo?.toString(),
      text: text,
      createdAt: created,
      likesCount: parseCount(data['likesCount']),
      isLiked: isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorHandle': authorHandle,
      if (authorPhoto != null) 'authorPhoto': authorPhoto,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
    };
  }
}
