class ProgressSnapshot {
  const ProgressSnapshot({
    required this.learnedVocabIds,
    required this.favoriteVocabIds,
    required this.reviewDueDatesByVocab,
    required this.reviewStageByVocab,
    required this.wrongGrammarQuestionIdsByTopic,
    required this.quizScoresByTopic,
    required this.grammarQuizzesCompleted,
    required this.xpPoints,
    required this.currentStreak,
    required this.lastDailyChallengeDate,
    required this.isDarkMode,
  });

  final Set<int> learnedVocabIds;
  final Set<int> favoriteVocabIds;
  final Map<int, String> reviewDueDatesByVocab;
  final Map<int, int> reviewStageByVocab;
  final Map<int, Set<int>> wrongGrammarQuestionIdsByTopic;
  final Map<int, double> quizScoresByTopic;
  final int grammarQuizzesCompleted;
  final int xpPoints;
  final int currentStreak;
  final String? lastDailyChallengeDate;
  final bool isDarkMode;

  factory ProgressSnapshot.initial() {
    return const ProgressSnapshot(
      learnedVocabIds: <int>{},
      favoriteVocabIds: <int>{},
      reviewDueDatesByVocab: <int, String>{},
      reviewStageByVocab: <int, int>{},
      wrongGrammarQuestionIdsByTopic: <int, Set<int>>{},
      quizScoresByTopic: <int, double>{},
      grammarQuizzesCompleted: 0,
      xpPoints: 0,
      currentStreak: 0,
      lastDailyChallengeDate: null,
      isDarkMode: false,
    );
  }

  ProgressSnapshot copyWith({
    Set<int>? learnedVocabIds,
    Set<int>? favoriteVocabIds,
    Map<int, String>? reviewDueDatesByVocab,
    Map<int, int>? reviewStageByVocab,
    Map<int, Set<int>>? wrongGrammarQuestionIdsByTopic,
    Map<int, double>? quizScoresByTopic,
    int? grammarQuizzesCompleted,
    int? xpPoints,
    int? currentStreak,
    String? lastDailyChallengeDate,
    bool clearDailyChallengeDate = false,
    bool? isDarkMode,
  }) {
    return ProgressSnapshot(
      learnedVocabIds: learnedVocabIds ?? this.learnedVocabIds,
      favoriteVocabIds: favoriteVocabIds ?? this.favoriteVocabIds,
      reviewDueDatesByVocab:
          reviewDueDatesByVocab ?? this.reviewDueDatesByVocab,
      reviewStageByVocab: reviewStageByVocab ?? this.reviewStageByVocab,
      wrongGrammarQuestionIdsByTopic:
          wrongGrammarQuestionIdsByTopic ?? this.wrongGrammarQuestionIdsByTopic,
      quizScoresByTopic: quizScoresByTopic ?? this.quizScoresByTopic,
      grammarQuizzesCompleted:
          grammarQuizzesCompleted ?? this.grammarQuizzesCompleted,
      xpPoints: xpPoints ?? this.xpPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      lastDailyChallengeDate: clearDailyChallengeDate
          ? null
          : lastDailyChallengeDate ?? this.lastDailyChallengeDate,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  int get totalVocabLearned => learnedVocabIds.length;

  double get averageQuizScore {
    if (quizScoresByTopic.isEmpty) {
      return 0;
    }
    final total = quizScoresByTopic.values.fold<double>(
      0,
      (sum, score) => sum + score,
    );
    return total / quizScoresByTopic.length;
  }
}
