import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/community_comment.dart';
import '../../models/community_post.dart';
import '../../providers/app_providers.dart';
import 'widgets/post_card.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final auth = ref.read(authServiceProvider);
    final currentUid = auth.currentUid ?? 'anonymous';
    final household = ref.read(currentHouseholdProvider).value;

    setState(() => _isSending = true);

    try {
      final comment = CommunityComment(
        id: '',
        postId: widget.postId,
        authorUid: currentUid,
        authorName: household?.headOfFamily ?? 'Resident',
        authorHandle: (household?.id ?? currentUid).toLowerCase(),
        authorPhoto: household?.photoUrl,
        text: text,
        createdAt: DateTime.now(),
      );

      final repo = ref.read(communityRepositoryProvider);
      await repo.addComment(widget.postId, comment);

      _commentController.clear();
      _focusNode.unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post reply: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.watch(communityRepositoryProvider);
    final currentUid = ref.watch(authServiceProvider).currentUid ?? '';
    final household = ref.watch(currentHouseholdProvider).value;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Conversation'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<CommunityPost?>(
              stream: repo.watchPost(widget.postId),
              builder: (context, postSnap) {
                if (postSnap.connectionState == ConnectionState.waiting && !postSnap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: LoadingSkeleton.card(height: 240),
                  );
                }

                if (postSnap.hasError || !postSnap.hasData || postSnap.data == null) {
                  return ErrorView(
                    message: 'Post not found or has been removed.',
                    onRetry: () => setState(() {}),
                  );
                }

                final post = postSnap.data!;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Main Post Card
                    PostCard(
                      post: post,
                      onProfileTap: () {
                        context.push('/community/user/${post.authorUid}');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Comments Section Header
                    Row(
                      children: [
                        const Text(
                          'Replies',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                            borderRadius: AppRadii.fullRadius,
                          ),
                          child: Text(
                            '${post.commentsCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stream Comments
                    StreamBuilder<List<CommunityComment>>(
                      stream: repo.watchComments(widget.postId),
                      builder: (context, commentSnap) {
                        if (commentSnap.connectionState == ConnectionState.waiting && !commentSnap.hasData) {
                          return const Column(
                            children: [
                              LoadingSkeleton.card(height: 70),
                              SizedBox(height: 8),
                              LoadingSkeleton.card(height: 70),
                            ],
                          );
                        }

                        final comments = commentSnap.data ?? [];
                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: EmptyStateView(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'No replies yet',
                              description: 'Be the first to join the conversation!',
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 16,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final isMyComment = comment.authorUid == currentUid;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.limeAccent,
                                    backgroundImage: comment.authorPhoto != null && comment.authorPhoto!.isNotEmpty
                                        ? NetworkImage(comment.authorPhoto!)
                                        : null,
                                    child: comment.authorPhoto == null || comment.authorPhoto!.isEmpty
                                        ? Text(
                                            comment.authorName.isNotEmpty
                                                ? comment.authorName.substring(0, 1).toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              fontSize: 12,
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
                                        Row(
                                          children: [
                                            Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '• ${comment.relativeTime}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppColors.textSecondaryDark
                                                    : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (isMyComment)
                                              PopupMenuButton<String>(
                                                icon: Icon(
                                                  Icons.more_horiz_rounded,
                                                  size: 16,
                                                  color: isDark ? Colors.white54 : Colors.black54,
                                                ),
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete_outline_rounded,
                                                            color: Colors.redAccent, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (val) {
                                                  if (val == 'delete') {
                                                    repo.deleteComment(widget.postId, comment.id);
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.text,
                                          style: const TextStyle(fontSize: 13, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),

          // Pinned Comment Input Composer
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.limeAccent,
                  backgroundImage: household?.photoUrl != null && household!.photoUrl!.isNotEmpty
                      ? NetworkImage(household.photoUrl!)
                      : null,
                  child: household?.photoUrl == null || household!.photoUrl!.isEmpty
                      ? Text(
                          household != null && household.headOfFamily.isNotEmpty
                              ? household.headOfFamily.substring(0, 1).toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Post your reply...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: AppRadii.fullRadius,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _submitComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, color: AppColors.emeraldBrand),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
