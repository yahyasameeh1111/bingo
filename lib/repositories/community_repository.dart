import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../models/community_comment.dart';
import '../models/community_post.dart';
import '../models/community_profile.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Streams all community posts live
  Stream<List<CommunityPost>> watchPosts() {
    return _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        return CommunityPost.fromFirestore(d.id, d.data());
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Stream single post live
  Stream<CommunityPost?> watchPost(String postId) {
    return _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return CommunityPost.fromFirestore(snap.id, snap.data()!);
    });
  }

  // Check if current user liked a post
  Future<bool> hasLiked(String postId, String uid) async {
    if (uid.isEmpty) return false;
    final doc = await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .get();
    return doc.exists;
  }

  // Check if current user saved a post
  Future<bool> hasSaved(String postId, String uid) async {
    if (uid.isEmpty) return false;
    final doc = await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('saves')
        .doc(uid)
        .get();
    return doc.exists;
  }

  // Check if current user reposted a post
  Future<bool> hasReposted(String postId, String uid) async {
    if (uid.isEmpty) return false;
    final doc = await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('reposts')
        .doc(uid)
        .get();
    return doc.exists;
  }

  // Stream live poll votes for a post
  Stream<Map<String, dynamic>> watchPollVotes(String postId) {
    return _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('pollVotes')
        .snapshots()
        .map((snap) {
      final counts = <int, int>{};
      for (final d in snap.docs) {
        final opt = d.data()['optionIndex'];
        if (opt is int) {
          counts[opt] = (counts[opt] ?? 0) + 1;
        } else if (opt is num) {
          counts[opt.toInt()] = (counts[opt.toInt()] ?? 0) + 1;
        }
      }
      return {
        'counts': counts,
        'total': snap.size,
      };
    });
  }

  Future<int?> getUserPollVote(String postId, String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('pollVotes')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    final opt = doc.data()?['optionIndex'];
    if (opt is int) return opt;
    if (opt is num) return opt.toInt();
    return null;
  }

  // Vote in a poll
  Future<void> votePoll(String postId, String uid, int optionIndex) async {
    if (uid.isEmpty) throw Exception('Must be signed in to vote.');
    final ref = _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('pollVotes')
        .doc(uid);

    await ref.set({
      'uid': uid,
      'optionIndex': optionIndex,
      'createdAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Create Post
  Future<String> createPost(CommunityPost post) async {
    final ref = _firestore.collection(FirebaseConstants.colCommunityPosts).doc();
    final data = post.toMap();
    await ref.set(data);
    return ref.id;
  }

  // Delete Post
  Future<void> deletePost(String postId) async {
    await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .delete();
  }

  // Toggle Like with subcollection + count increment
  Future<bool> toggleLike(String postId, String uid, bool desiredState) async {
    if (uid.isEmpty) throw Exception('Must be signed in.');
    final postRef = _firestore.collection(FirebaseConstants.colCommunityPosts).doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    final existsSnap = await likeRef.get();
    final currentState = existsSnap.exists;
    if (desiredState == currentState) return desiredState;

    if (desiredState) {
      await likeRef.set({'uid': uid, 'createdAt': DateTime.now().toIso8601String()});
      await postRef.update({'likesCount': FieldValue.increment(1)});
    } else {
      await likeRef.delete();
      await postRef.update({'likesCount': FieldValue.increment(-1)});
    }
    return desiredState;
  }

  // Toggle Save
  Future<bool> toggleSave(String postId, String uid) async {
    if (uid.isEmpty) throw Exception('Must be signed in.');
    final saveRef = _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('saves')
        .doc(uid);

    final exists = (await saveRef.get()).exists;
    if (exists) {
      await saveRef.delete();
      return false;
    } else {
      await saveRef.set({'uid': uid, 'createdAt': DateTime.now().toIso8601String()});
      return true;
    }
  }

  // Toggle Repost
  Future<bool> toggleRepost(String postId, String uid, bool desiredState) async {
    if (uid.isEmpty) throw Exception('Must be signed in.');
    final postRef = _firestore.collection(FirebaseConstants.colCommunityPosts).doc(postId);
    final repostRef = postRef.collection('reposts').doc(uid);

    final exists = (await repostRef.get()).exists;
    if (desiredState == exists) return desiredState;

    if (desiredState) {
      await repostRef.set({'uid': uid, 'createdAt': DateTime.now().toIso8601String()});
      await postRef.update({'repostsCount': FieldValue.increment(1)});
    } else {
      await repostRef.delete();
      await postRef.update({'repostsCount': FieldValue.increment(-1)});
    }
    return desiredState;
  }

  // Record Share
  Future<void> recordShare(String postId, String uid) async {
    final postRef = _firestore.collection(FirebaseConstants.colCommunityPosts).doc(postId);
    final shareRef = postRef.collection('shares').doc();
    await shareRef.set({'uid': uid, 'createdAt': DateTime.now().toIso8601String()});
    await postRef.update({'sharesCount': FieldValue.increment(1)});
  }

  // Stream Comments for a post
  Stream<List<CommunityComment>> watchComments(String postId) {
    return _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        return CommunityComment.fromFirestore(d.id, postId, d.data());
      }).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  // Add Comment
  Future<String> addComment(String postId, CommunityComment comment) async {
    final postRef = _firestore.collection(FirebaseConstants.colCommunityPosts).doc(postId);
    final ref = postRef.collection('comments').doc();
    await ref.set(comment.toMap());
    await postRef.update({'commentsCount': FieldValue.increment(1)});
    return ref.id;
  }

  // Delete Comment
  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _firestore.collection(FirebaseConstants.colCommunityPosts).doc(postId);
    await postRef.collection('comments').doc(commentId).delete();
    await postRef.update({'commentsCount': FieldValue.increment(-1)});
  }

  // Check if comment liked
  Future<bool> hasCommentLiked(String postId, String commentId, String uid) async {
    if (uid.isEmpty) return false;
    final doc = await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .doc(uid)
        .get();
    return doc.exists;
  }

  // Toggle Comment Like
  Future<bool> toggleCommentLike(
    String postId,
    String commentId,
    String uid,
    bool desiredState,
  ) async {
    if (uid.isEmpty) throw Exception('Must be signed in.');
    final commentRef = _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final likeRef = commentRef.collection('likes').doc(uid);

    final exists = (await likeRef.get()).exists;
    if (desiredState == exists) return desiredState;

    if (desiredState) {
      await likeRef.set({'uid': uid, 'createdAt': DateTime.now().toIso8601String()});
      await commentRef.update({'likesCount': FieldValue.increment(1)});
    } else {
      await likeRef.delete();
      await commentRef.update({'likesCount': FieldValue.increment(-1)});
    }
    return desiredState;
  }

  // Stream following UIDs for current user
  Stream<Set<String>> watchFollowingUids(String currentUid) {
    if (currentUid.isEmpty) return Stream.value({});
    return _firestore
        .collection(FirebaseConstants.colCommunityFollows)
        .doc(currentUid)
        .collection('following')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  // Toggle follow
  Future<bool> toggleFollow(String currentUid, String targetUid, bool desiredState) async {
    if (currentUid.isEmpty || targetUid.isEmpty || currentUid == targetUid) {
      return false;
    }

    final followRef = _firestore
        .collection(FirebaseConstants.colCommunityFollows)
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);

    final followerRef = _firestore
        .collection(FirebaseConstants.colCommunityFollows)
        .doc(targetUid)
        .collection('followers')
        .doc(currentUid);

    final ownProfileRef =
        _firestore.collection(FirebaseConstants.colCommunityProfiles).doc(currentUid);
    final targetProfileRef =
        _firestore.collection(FirebaseConstants.colCommunityProfiles).doc(targetUid);

    final exists = (await followRef.get()).exists;
    if (desiredState == exists) return desiredState;

    final now = DateTime.now().toIso8601String();
    if (desiredState) {
      await followRef.set({'uid': targetUid, 'createdAt': now});
      await followerRef.set({'uid': currentUid, 'createdAt': now});
      await ownProfileRef.set({
        'uid': currentUid,
        'followingCount': FieldValue.increment(1),
        'updatedAt': now,
      }, SetOptions(merge: true));
      await targetProfileRef.set({
        'uid': targetUid,
        'followersCount': FieldValue.increment(1),
        'updatedAt': now,
      }, SetOptions(merge: true));
    } else {
      await followRef.delete();
      await followerRef.delete();
      await ownProfileRef.set({
        'followingCount': FieldValue.increment(-1),
        'updatedAt': now,
      }, SetOptions(merge: true));
      await targetProfileRef.set({
        'followersCount': FieldValue.increment(-1),
        'updatedAt': now,
      }, SetOptions(merge: true));
    }
    return desiredState;
  }

  // Get list of followed UIDs
  Future<List<String>> getFollowingUidsList(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _firestore
        .collection(FirebaseConstants.colCommunityFollows)
        .doc(uid)
        .collection('following')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  // Get list of follower UIDs
  Future<List<String>> getFollowersUidsList(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _firestore
        .collection(FirebaseConstants.colCommunityFollows)
        .doc(uid)
        .collection('followers')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  // Profiles
  Future<CommunityProfile?> getProfile(String uid) async {
    if (uid.isEmpty) return null;
    final doc =
        await _firestore.collection(FirebaseConstants.colCommunityProfiles).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return CommunityProfile.fromFirestore(doc.id, doc.data()!);
  }

  Stream<CommunityProfile?> watchProfile(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirebaseConstants.colCommunityProfiles)
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return CommunityProfile.fromFirestore(snap.id, snap.data()!);
    });
  }

  Future<void> upsertProfile(CommunityProfile profile) async {
    await _firestore
        .collection(FirebaseConstants.colCommunityProfiles)
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<List<CommunityPost>> getUserPosts(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _firestore
        .collection(FirebaseConstants.colCommunityPosts)
        .where('authorUid', isEqualTo: uid)
        .get();

    final list = snap.docs.map((d) => CommunityPost.fromFirestore(d.id, d.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<CommunityPost>> getUserSavedPosts(String uid) async {
    if (uid.isEmpty) return [];
    final allPosts = await _firestore.collection(FirebaseConstants.colCommunityPosts).get();
    final saved = <CommunityPost>[];

    for (final postDoc in allPosts.docs) {
      final saveSnap = await postDoc.reference.collection('saves').doc(uid).get();
      if (saveSnap.exists) {
        saved.add(CommunityPost.fromFirestore(postDoc.id, postDoc.data(), isSaved: true));
      }
    }
    saved.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return saved;
  }

  Future<List<CommunityComment>> getUserReplies(String uid) async {
    if (uid.isEmpty) return [];
    final allPosts = await _firestore.collection(FirebaseConstants.colCommunityPosts).get();
    final replies = <CommunityComment>[];

    for (final postDoc in allPosts.docs) {
      final commentsSnap = await postDoc.reference
          .collection('comments')
          .where('authorUid', isEqualTo: uid)
          .get();

      for (final commentDoc in commentsSnap.docs) {
        replies.add(CommunityComment.fromFirestore(commentDoc.id, postDoc.id, commentDoc.data()));
      }
    }
    replies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return replies;
  }
}
