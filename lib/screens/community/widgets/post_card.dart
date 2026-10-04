import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/widgets/bingo_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../models/community_post.dart';
import '../../../providers/app_providers.dart';
import 'poll_widget.dart';

class PostCard extends ConsumerStatefulWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onProfileTap,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late bool _isLiked;
  late int _likesCount;
  late bool _isSaved;
  late bool _isReposted;
  late int _repostsCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
    _isSaved = widget.post.isSaved;
    _isReposted = widget.post.isReposted;
    _repostsCount = widget.post.repostsCount;
    _checkServerStates();
  }

  Future<void> _checkServerStates() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    final repo = ref.read(communityRepositoryProvider);

    final liked = await repo.hasLiked(widget.post.id, user.uid);
    final saved = await repo.hasSaved(widget.post.id, user.uid);
    final reposted = await repo.hasReposted(widget.post.id, user.uid);

    if (mounted) {
      setState(() {
        _isLiked = liked;
        _isSaved = saved;
        _isReposted = reposted;
      });
    }
  }

  Future<void> _toggleLike() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final nextState = !_isLiked;
    setState(() {
      _isLiked = nextState;
      _likesCount = nextState ? _likesCount + 1 : (_likesCount > 0 ? _likesCount - 1 : 0);
    });

    try {
      await ref.read(communityRepositoryProvider).toggleLike(widget.post.id, user.uid, nextState);
    } catch (_) {
      // Reconcile on error
      if (mounted) {
        setState(() {
          _isLiked = !nextState;
          _likesCount = !nextState ? _likesCount + 1 : (_likesCount > 0 ? _likesCount - 1 : 0);
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final nextState = !_isSaved;
    setState(() => _isSaved = nextState);

    try {
      await ref.read(communityRepositoryProvider).toggleSave(widget.post.id, user.uid);
    } catch (_) {
      if (mounted) setState(() => _isSaved = !nextState);
    }
  }

  Future<void> _toggleRepost() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final nextState = !_isReposted;
    setState(() {
      _isReposted = nextState;
      _repostsCount = nextState ? _repostsCount + 1 : (_repostsCount > 0 ? _repostsCount - 1 : 0);
    });

    try {
      await ref.read(communityRepositoryProvider).toggleRepost(widget.post.id, user.uid, nextState);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isReposted = !nextState;
          _repostsCount = !nextState ? _repostsCount + 1 : (_repostsCount > 0 ? _repostsCount - 1 : 0);
        });
      }
    }
  }

  Future<void> _handleFollowToggle(bool isFollowing, String targetUid) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null || user.uid == targetUid) return;

    await ref.read(communityRepositoryProvider).toggleFollow(user.uid, targetUid, !isFollowing);
    ref.invalidate(followingUidsStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authServiceProvider).currentUser;
    final followingIds = ref.watch(followingUidsStreamProvider).value ?? {};

    final isOwnPost = currentUser != null && currentUser.uid == post.authorUid;
    final isFollowing = followingIds.contains(post.authorUid);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: BingoCard(
        onTap: widget.onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Row
            Row(
              children: [
                // Author Avatar
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.limeAccent,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: post.authorPhoto != null && post.authorPhoto!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: post.authorPhoto!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                post.initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              post.initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Author Details
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onProfileTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '· ${post.relativeTime}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '@${post.authorHandle}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Follow / Following Button (Only for other accounts)
                if (!isOwnPost && post.authorUid.isNotEmpty)
                  GestureDetector(
                    onTap: () => _handleFollowToggle(isFollowing, post.authorUid),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? (isDark ? const Color(0xFF22282C) : AppColors.sageSurfaceLight)
                            : (isDark ? AppColors.limeAccent : AppColors.darkPill),
                        borderRadius: AppRadii.pillRadius,
                        border: isFollowing
                            ? Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              )
                            : null,
                      ),
                      child: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isFollowing
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textPrimaryLight : AppColors.darkPillText),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Text Content
            if (post.text.isNotEmpty) ...[
              Text(
                post.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Image Attachment
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: AppRadii.mdRadius,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const LoadingSkeleton.card(height: 200),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Poll Attachment
            if (post.poll != null) ...[
              PollWidget(post: post, poll: post.poll!),
              const SizedBox(height: 10),
            ],

            // Link Attachment
            if (post.linkUrl != null && post.linkUrl!.isNotEmpty) ...[
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(post.linkUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2428) : const Color(0xFFF7F9F5),
                    borderRadius: AppRadii.mdRadius,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 20, color: AppColors.emeraldBrand),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.linkTitle != null && post.linkTitle!.isNotEmpty)
                              Text(
                                post.linkTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            Text(
                              post.linkUrl!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Social Action Buttons Bar (Like, Comment, Repost, Save, Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like Button
                _actionButton(
                  icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  count: _likesCount,
                  color: _isLiked ? AppColors.error : null,
                  onTap: _toggleLike,
                ),

                // Comment / Reply Button
                _actionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: post.commentsCount,
                  onTap: widget.onTap,
                ),

                // Repost Button
                _actionButton(
                  icon: Icons.repeat_rounded,
                  count: _repostsCount,
                  color: _isReposted ? AppColors.emeraldBrand : null,
                  onTap: _toggleRepost,
                ),

                // Save / Bookmark Button
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 20,
                    color: _isSaved ? AppColors.emeraldBrand : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                  ),
                  onPressed: _toggleSave,
                ),

                // Share Button
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    size: 19,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    ref.read(communityRepositoryProvider).recordShare(
                          post.id,
                          currentUser?.uid ?? 'anonymous',
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post link copied to share!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required int count,
    Color? color,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pillRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color ?? defaultColor),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color ?? defaultColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
