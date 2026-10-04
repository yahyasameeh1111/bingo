class PollOption {
  final int index;
  final String text;
  final int votes;

  const PollOption({
    required this.index,
    required this.text,
    this.votes = 0,
  });

  PollOption copyWith({int? votes}) {
    return PollOption(
      index: index,
      text: text,
      votes: votes ?? this.votes,
    );
  }
}

class CommunityPoll {
  final String question;
  final List<PollOption> options;
  final int? userVoteIndex;
  final int totalVotes;

  const CommunityPoll({
    required this.question,
    required this.options,
    this.userVoteIndex,
    this.totalVotes = 0,
  });

  bool get hasVoted => userVoteIndex != null;

  double percentageFor(int optionIndex) {
    if (totalVotes == 0) return 0.0;
    if (optionIndex < 0 || optionIndex >= options.length) return 0.0;
    return (options[optionIndex].votes / totalVotes) * 100;
  }

  factory CommunityPoll.fromMap(
    Map<String, dynamic> data, {
    int? userVote,
    Map<int, int>? counts,
    int? total,
  }) {
    final q = data['question']?.toString() ?? 'Poll';
    final rawOptions = data['options'] as List? ?? [];

    int calcTotal = 0;
    final options = <PollOption>[];
    for (int i = 0; i < rawOptions.length; i++) {
      final item = rawOptions[i];
      final txt = item is Map ? (item['text'] ?? '').toString() : item.toString();
      final voteCount = counts != null ? (counts[i] ?? 0) : 0;
      calcTotal += voteCount;
      options.add(PollOption(index: i, text: txt, votes: voteCount));
    }

    return CommunityPoll(
      question: q,
      options: options,
      userVoteIndex: userVote,
      totalVotes: total ?? calcTotal,
    );
  }
}
