import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/bingo_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/community_comment.dart';
import '../../models/community_post.dart';
import '../../models/community_profile.dart';
import '../../providers/app_providers.dart';
import 'widgets/post_card.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = ref.watch(authServiceProvider).currentUid ?? '';
    final isOwnProfile = widget.uid == currentUid;
    final repo = ref.watch(communityRepositoryProvider);
    final followingUids = ref.watch(followingUidsStreamProvider).value ?? {};
    final isFollowing = followingUids.contains(widget.uid);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<CommunityProfile?>(
        stream: repo.watchProfile(widget.uid),
        builder: (context, profileSnap) {
          final profile = profileSnap.data ??
              CommunityProfile(
                uid: widget.uid,
                name: 'Neighborhood Member',
                handle: widget.uid.toLowerCase(),
                createdAt: DateTime.now(),
              );

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Follow Button Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.limeAccent,
                              backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                                  ? NetworkImage(profile.photoUrl!)
                                  : null,
                              child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                                  ? Text(
                                      profile.initials,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    )
                                  : null,
                            ),
                            const Spacer(),
                            if (isOwnProfile)
                              BingoButton(
                                label: 'Edit Profile',
                                variant: BingoButtonVariant.outline,
                                size: BingoButtonSize.small,
                                icon: Icons.edit_outlined,
                                onPressed: () {
                                  context.push('/profile');
                                },
                              )
                            else
                              BingoButton(
                                label: isFollowing ? 'Following' : 'Follow',
                                variant: isFollowing
                                    ? BingoButtonVariant.outline
                                    : BingoButtonVariant.primary,
                                size: BingoButtonSize.small,
                                onPressed: () {
                                  repo.toggleFollow(currentUid, widget.uid, !isFollowing);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Name & Handle
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${profile.handle}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),

                        // Bio if available
                        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            profile.bio!,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ],

                        // Location chips
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (profile.panchayat != null && profile.panchayat!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: AppRadii.fullRadius,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.emeraldBrand),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile.panchayat!,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            if (profile.ward != null && profile.ward!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: AppRadii.fullRadius,
                                ),
                                child: Text(
                                  'Ward ${profile.ward!}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),

                        // Followers / Following Row
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push('/community/network/${widget.uid}?tab=0');
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '${profile.followersCount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Followers',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                context.push('/community/network/${widget.uid}?tab=1');
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '${profile.followingCount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Following',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: isDark ? AppColors.limeAccent : AppColors.darkPillSurface,
                      indicatorWeight: 3,
                      labelColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                      unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Replies'),
                        Tab(text: 'Saved'),
                      ],
                    ),
                    backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _UserPostsTab(uid: widget.uid),
                _UserRepliesTab(uid: widget.uid),
                isOwnProfile
                    ? _UserSavedTab(uid: widget.uid)
                    : const EmptyStateView(
                        icon: Icons.lock_outline_rounded,
                        title: 'Private List',
                        description: 'Saved posts are private to each user.',
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserPostsTab extends ConsumerWidget {
  final String uid;

  const _UserPostsTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<CommunityPost>>(
      future: ref.watch(communityRepositoryProvider).getUserPosts(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => const LoadingSkeleton.card(height: 160),
          );
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const EmptyStateView(
            icon: Icons.post_add_rounded,
            title: 'No posts yet',
            description: 'Posts shared by this resident will appear here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: posts[index],
              onTap: () => context.push('/community/post/${posts[index].id}'),
            );
          },
        );
      },
    );
  }
}

class _UserRepliesTab extends ConsumerWidget {
  final String uid;

  const _UserRepliesTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<CommunityComment>>(
      future: ref.watch(communityRepositoryProvider).getUserReplies(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => const LoadingSkeleton.card(height: 80),
          );
        }

        final replies = snapshot.data ?? [];
        if (replies.isEmpty) {
          return const EmptyStateView(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No replies yet',
            description: 'Replies made by this resident will appear here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BingoCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/community/post/${reply.postId}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Replied to conversation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          reply.relativeTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reply.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _UserSavedTab extends ConsumerWidget {
  final String uid;

  const _UserSavedTab({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<CommunityPost>>(
      future: ref.watch(communityRepositoryProvider).getUserSavedPosts(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => const LoadingSkeleton.card(height: 160),
          );
        }

        final saved = snapshot.data ?? [];
        if (saved.isEmpty) {
          return const EmptyStateView(
            icon: Icons.bookmark_border_rounded,
            title: 'No saved posts',
            description: 'Posts you bookmark will be kept here for easy reference.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: saved.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: saved[index],
              onTap: () => context.push('/community/post/${saved[index].id}'),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverAppBarDelegate(this._tabBar, {required this.backgroundColor});

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
