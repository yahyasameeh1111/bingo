import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../models/community_poll.dart';
import '../../../models/community_post.dart';
import '../../../providers/app_providers.dart';

class PollWidget extends ConsumerStatefulWidget {
  final CommunityPost post;
  final CommunityPoll poll;

  const PollWidget({
    super.key,
    required this.post,
    required this.poll,
  });

  @override
  ConsumerState<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends ConsumerState<PollWidget> {
  int? _localVote;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _localVote = widget.poll.userVoteIndex;
    _checkServerVote();
  }

  Future<void> _checkServerVote() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    final vote = await ref.read(communityRepositoryProvider).getUserPollVote(widget.post.id, user.uid);
    if (mounted && vote != null) {
      setState(() => _localVote = vote);
    }
  }

  Future<void> _handleVote(int optionIndex) async {
    if (_isVoting) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote.')),
      );
      return;
    }

    // Optimistic UI update
    final previousVote = _localVote;
    setState(() {
      _localVote = optionIndex;
      _isVoting = true;
    });

    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.votePoll(widget.post.id, user.uid, optionIndex);
    } catch (e) {
      if (mounted) {
        setState(() => _localVote = previousVote);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record vote: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final poll = widget.poll;

    // Stream real-time votes from Firestore subcollection
    final pollVotesStream = ref.watch(communityRepositoryProvider).watchPollVotes(widget.post.id);

    return StreamBuilder<Map<String, dynamic>>(
      stream: pollVotesStream,
      builder: (context, snapshot) {
        final counts = snapshot.data?['counts'] as Map<int, int>?;
        final total = snapshot.data?['total'] as int? ?? poll.totalVotes;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2428) : const Color(0xFFF9FAF8),
            borderRadius: AppRadii.lgRadius,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poll Question
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  poll.question,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Options
              ...List.generate(poll.options.length, (i) {
                final opt = poll.options[i];
                final count = counts != null ? (counts[i] ?? 0) : opt.votes;
                final pct = total > 0 ? (count / total) * 100 : 0.0;
                final isSelected = _localVote == i;

                return GestureDetector(
                  onTap: () => _handleVote(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B1E) : Colors.white,
                      borderRadius: AppRadii.mdRadius,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.emeraldBrand
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Vote percentage progress bar
                        FractionallySizedBox(
                          widthFactor: (pct / 100).clamp(0.0, 1.0),
                          child: Container(
                            color: isSelected
                                ? (isDark ? AppColors.limeAccent.withValues(alpha: 0.3) : AppColors.limeAccent)
                                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEDF2EA)),
                          ),
                        ),
                        // Label and percentage
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AppColors.emeraldBrand,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    opt.text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${pct.round()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Footer count
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  '$total ${total == 1 ? 'vote' : 'votes'} · ${_localVote != null ? 'You voted' : 'Tap an option to vote'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
