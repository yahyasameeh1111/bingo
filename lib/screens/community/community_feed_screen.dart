import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/community_post.dart';
import '../../providers/app_providers.dart';
import 'post_composer_sheet.dart';
import 'widgets/post_card.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  int _selectedFeedIndex = 0; // 0: For You, 1: Following
  String _selectedFilter = 'all'; // 'all', 'poll', 'photo', 'link'
  String _searchQuery = '';
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final household = ref.watch(currentHouseholdProvider).value;
    final currentUid = ref.watch(authServiceProvider).currentUid ?? '';
    final followingUids = ref.watch(followingUidsStreamProvider).value ?? {};

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Community',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          household?.panchayat ?? 'Local Neighborhood Hub',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                        if (!_isSearchExpanded) _searchQuery = '';
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  // User Avatar button leading to user profile
                  GestureDetector(
                    onTap: () {
                      if (currentUid.isNotEmpty) {
                        context.push('/community/user/$currentUid');
                      }
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.limeAccent,
                      backgroundImage: household?.photoUrl != null && household!.photoUrl!.isNotEmpty
                          ? NetworkImage(household.photoUrl!)
                          : null,
                      child: household?.photoUrl == null || household!.photoUrl!.isEmpty
                          ? Text(
                              household != null && household.headOfFamily.isNotEmpty
                                  ? household.headOfFamily.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.textPrimaryLight,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar if expanded
            if (_isSearchExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search community posts, tips, polls...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: AppRadii.fullRadius,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // Segment Tabs (For You | Following)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                  borderRadius: AppRadii.fullRadius,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFeedIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedFeedIndex == 0
                                ? (isDark ? AppColors.surfaceDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppRadii.fullRadius,
                            boxShadow: _selectedFeedIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'For You',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedFeedIndex == 0 ? FontWeight.w800 : FontWeight.w600,
                                color: _selectedFeedIndex == 0
                                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                    : (isDark ? Colors.white54 : Colors.black45),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFeedIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedFeedIndex == 1
                                ? (isDark ? AppColors.surfaceDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppRadii.fullRadius,
                            boxShadow: _selectedFeedIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Following',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedFeedIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                                color: _selectedFeedIndex == 1
                                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                    : (isDark ? Colors.white54 : Colors.black45),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  BingoChip(
                    label: 'All Posts',
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  BingoChip(
                    label: 'Polls',
                    icon: Icons.poll_outlined,
                    isSelected: _selectedFilter == 'poll',
                    onTap: () => setState(() => _selectedFilter = 'poll'),
                  ),
                  const SizedBox(width: 8),
                  BingoChip(
                    label: 'Photos',
                    icon: Icons.image_outlined,
                    isSelected: _selectedFilter == 'photo',
                    onTap: () => setState(() => _selectedFilter = 'photo'),
                  ),
                  const SizedBox(width: 8),
                  BingoChip(
                    label: 'Links',
                    icon: Icons.link_rounded,
                    isSelected: _selectedFilter == 'link',
                    onTap: () => setState(() => _selectedFilter = 'link'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Live Posts Feed
            Expanded(
              child: Builder(
                builder: (context) {
                  final postsAsync = ref.watch(communityPostsStreamProvider);

                  if (postsAsync.isLoading && !postsAsync.hasValue) {
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: 4,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => const LoadingSkeleton.card(height: 180),
                    );
                  }

                  List<CommunityPost> posts = postsAsync.value ?? [];

                  // Apply Following filter if selected
                  if (_selectedFeedIndex == 1) {
                    posts = posts.where((p) => followingUids.contains(p.authorUid)).toList();
                  }

                  // Apply type filter
                  if (_selectedFilter != 'all') {
                    posts = posts.where((p) => p.postType == _selectedFilter).toList();
                  }

                  // Apply search query
                  if (_searchQuery.isNotEmpty) {
                    posts = posts.where((p) {
                      return p.text.toLowerCase().contains(_searchQuery) ||
                          p.authorName.toLowerCase().contains(_searchQuery) ||
                          p.authorHandle.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (posts.isEmpty) {
                    return Center(
                      child: EmptyStateView(
                        icon: _selectedFeedIndex == 1
                            ? Icons.people_outline_rounded
                            : Icons.forum_outlined,
                        title: _selectedFeedIndex == 1
                            ? 'No posts from people you follow'
                            : 'No community posts yet',
                        description: _selectedFeedIndex == 1
                            ? 'Discover and follow neighbors to see their posts here.'
                            : 'Be the first to share an update or start a poll for your neighborhood!',
                        actionLabel: 'Create Post',
                        onAction: () => PostComposerSheet.show(context),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(communityPostsStreamProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () {
                            context.push('/community/post/${post.id}');
                          },
                          onProfileTap: () {
                            context.push('/community/user/${post.authorUid}');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: isDark ? AppColors.limeAccent : AppColors.darkPillSurface,
          foregroundColor: isDark ? AppColors.textPrimaryLight : Colors.white,
          elevation: 4,
          shape: const StadiumBorder(),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'New Post',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          onPressed: () => PostComposerSheet.show(context),
        ),
      ),
    );
  }
}
