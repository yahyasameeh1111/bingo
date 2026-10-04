import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/community_profile.dart';
import '../../providers/app_providers.dart';

class FollowListScreen extends ConsumerStatefulWidget {
  final String uid;
  final int initialTabIndex; // 0: Followers, 1: Following

  const FollowListScreen({
    super.key,
    required this.uid,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Network'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.limeAccent : AppColors.darkPillSurface,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : AppColors.textPrimaryLight,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserListView(uid: widget.uid, isFollowers: true),
          _UserListView(uid: widget.uid, isFollowers: false),
        ],
      ),
    );
  }
}

class _UserListView extends ConsumerStatefulWidget {
  final String uid;
  final bool isFollowers;

  const _UserListView({required this.uid, required this.isFollowers});

  @override
  ConsumerState<_UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends ConsumerState<_UserListView> {
  late Future<List<CommunityProfile>> _future;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _future = _fetchProfiles();
    });
  }

  Future<List<CommunityProfile>> _fetchProfiles() async {
    final repo = ref.read(communityRepositoryProvider);
    final uids = widget.isFollowers
        ? await repo.getFollowersUidsList(widget.uid)
        : await repo.getFollowingUidsList(widget.uid);

    final profiles = <CommunityProfile>[];
    for (final u in uids) {
      final p = await repo.getProfile(u);
      if (p != null) {
        profiles.add(p);
      } else {
        profiles.add(CommunityProfile(
          uid: u,
          name: 'Resident $u',
          handle: u.toLowerCase(),
          createdAt: DateTime.now(),
        ));
      }
    }
    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = ref.watch(authServiceProvider).currentUid ?? '';
    final followingUids = ref.watch(followingUidsStreamProvider).value ?? {};

    return FutureBuilder<List<CommunityProfile>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => const LoadingSkeleton.card(height: 60),
          );
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return EmptyStateView(
            icon: Icons.people_outline_rounded,
            title: widget.isFollowers ? 'No followers yet' : 'Not following anyone yet',
            description: widget.isFollowers
                ? 'When neighbors follow this profile, they will appear here.'
                : 'Connect with neighbors to see their posts and updates.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(
              height: 16,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              final isMe = user.uid == currentUid;
              final isFollowing = followingUids.contains(user.uid);

              return InkWell(
                onTap: () => context.push('/community/user/${user.uid}'),
                borderRadius: AppRadii.mdRadius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.limeAccent,
                        backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null || user.photoUrl!.isEmpty
                            ? Text(
                                user.initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '@${user.handle}${user.panchayat != null ? " • ${user.panchayat}" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isMe)
                        BingoButton(
                          label: isFollowing ? 'Following' : 'Follow',
                          variant: isFollowing
                              ? BingoButtonVariant.outline
                              : BingoButtonVariant.primary,
                          size: BingoButtonSize.small,
                          onPressed: () {
                            ref
                                .read(communityRepositoryProvider)
                                .toggleFollow(currentUid, user.uid, !isFollowing);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
