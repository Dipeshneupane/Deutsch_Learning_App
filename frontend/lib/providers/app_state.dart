import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_snapshot.dart';
import '../services/analytics_service.dart';
import '../storage/local_progress_storage.dart';

class AppState extends ChangeNotifier {
  static const List<int> _reviewIntervalsInDays = [1, 3, 7, 14, 30, 60];

  ProgressSnapshot _snapshot = ProgressSnapshot.initial();
  LocalProgressStorage? _storage;
  bool _isReady = false;

  bool get isReady => _isReady;
  bool get isDarkMode => _snapshot.isDarkMode;
  Set<int> get learnedVocabIds => _snapshot.learnedVocabIds;
  Set<int> get favoriteVocabIds => _snapshot.favoriteVocabIds;
  Map<int, String> get reviewDueDatesByVocab => _snapshot.reviewDueDatesByVocab;
  Map<int, int> get reviewStageByVocab => _snapshot.reviewStageByVocab;
  Map<int, Set<int>> get wrongGrammarQuestionIdsByTopic =>
      _snapshot.wrongGrammarQuestionIdsByTopic;
  Map<int, double> get quizScoresByTopic => _snapshot.quizScoresByTopic;
  int get grammarQuizzesCompleted => _snapshot.grammarQuizzesCompleted;
  int get totalVocabLearned => _snapshot.totalVocabLearned;
  double get averageQuizScore => _snapshot.averageQuizScore;
  int get xpPoints => _snapshot.xpPoints;
  int get currentStreak => _snapshot.currentStreak;
  String? get lastDailyChallengeDate => _snapshot.lastDailyChallengeDate;
  int get dueReviewCount => dueReviewVocabIds.length;
  List<int> get dueReviewVocabIds {
    final todayKey = _dateKey(DateTime.now());
    final dueIds = reviewDueDatesByVocab.entries
        .where((entry) => entry.value.compareTo(todayKey) <= 0)
        .map((entry) => entry.key)
        .toList();
    dueIds.sort((left, right) {
      final leftDate = reviewDueDatesByVocab[left] ?? todayKey;
      final rightDate = reviewDueDatesByVocab[right] ?? todayKey;
      final dateComparison = leftDate.compareTo(rightDate);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return left.compareTo(right);
    });
    return dueIds;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _storage = LocalProgressStorage(prefs);
    _snapshot = await _storage!.load();
    _snapshot = _normalizeReviewSnapshot(_snapshot);
    _isReady = true;
    await _persist();
    notifyListeners();
  }

  bool isFavorite(int vocabId) => favoriteVocabIds.contains(vocabId);

  bool isLearned(int vocabId) => learnedVocabIds.contains(vocabId);

  int get totalWrongGrammarQuestions => wrongGrammarQuestionIdsByTopic.values
      .fold<int>(0, (sum, ids) => sum + ids.length);

  int reviewStageFor(int vocabId) => reviewStageByVocab[vocabId] ?? 0;

  String? nextReviewDateFor(int vocabId) => reviewDueDatesByVocab[vocabId];

  Set<int> wrongQuestionIdsForTopic(int topicId) =>
      wrongGrammarQuestionIdsByTopic[topicId] ?? const <int>{};

  int wrongQuestionCountForTopic(int topicId) =>
      wrongQuestionIdsForTopic(topicId).length;

  Future<void> toggleDarkMode(bool enabled) async {
    _snapshot = _snapshot.copyWith(isDarkMode: enabled);
    await _persist();
    await AnalyticsService.instance.logEvent(
      'theme_changed',
      parameters: <String, Object?>{'dark_mode': enabled},
    );
  }

  Future<void> markVocabularyKnown(
    int vocabId, {
    String source = 'flashcard',
  }) async {
    await recordReviewResult(
      vocabId,
      knewIt: true,
      awardXp: true,
      source: source,
    );
  }

  Future<void> recordReviewResult(
    int vocabId, {
    required bool knewIt,
    bool awardXp = false,
    String source = 'review',
  }) async {
    final updatedIds = Set<int>.from(learnedVocabIds);
    final updatedDueDates = Map<int, String>.from(reviewDueDatesByVocab);
    final updatedStages = Map<int, int>.from(reviewStageByVocab);

    if (knewIt) {
      updatedIds.add(vocabId);
      final previousStage = updatedStages[vocabId] ?? 0;
      final nextStage = previousStage >= _reviewIntervalsInDays.length - 1
          ? previousStage
          : previousStage + 1;
      updatedStages[vocabId] = nextStage;
      updatedDueDates[vocabId] = _dateKey(
        DateTime.now().add(
          Duration(days: _reviewIntervalsInDays[nextStage]),
        ),
      );
    } else if (updatedIds.contains(vocabId)) {
      updatedStages[vocabId] = 0;
      updatedDueDates[vocabId] = _dateKey(DateTime.now());
    }

    _snapshot = _snapshot.copyWith(
      learnedVocabIds: updatedIds,
      reviewDueDatesByVocab: updatedDueDates,
      reviewStageByVocab: updatedStages,
      xpPoints: awardXp && knewIt ? xpPoints + 5 : xpPoints,
    );
    await _persist();
    await AnalyticsService.instance.logEvent(
      knewIt ? 'vocab_known' : 'review_again',
      parameters: <String, Object?>{
        'vocab_id': vocabId,
        'source': source,
        'review_stage': updatedStages[vocabId] ?? 0,
        'awarded_xp': awardXp && knewIt,
      },
    );
  }

  Future<void> toggleFavorite(
    int vocabId, {
    String source = 'unknown',
  }) async {
    final updatedFavorites = Set<int>.from(favoriteVocabIds);
    final added = updatedFavorites.add(vocabId);
    if (!added) {
      updatedFavorites.remove(vocabId);
    }
    _snapshot = _snapshot.copyWith(favoriteVocabIds: updatedFavorites);
    await _persist();
    await AnalyticsService.instance.logEvent(
      added ? 'favorite_added' : 'favorite_removed',
      parameters: <String, Object?>{
        'vocab_id': vocabId,
        'source': source,
      },
    );
  }

  Future<void> recordGrammarQuestionResult({
    required int topicId,
    required int questionId,
    required bool wasCorrect,
    String source = 'quiz',
  }) async {
    final updatedWrongAnswers = wrongGrammarQuestionIdsByTopic.map(
      (key, value) => MapEntry(key, Set<int>.from(value)),
    );
    final topicWrongAnswers = Set<int>.from(
      updatedWrongAnswers[topicId] ?? const <int>{},
    );

    if (wasCorrect) {
      topicWrongAnswers.remove(questionId);
    } else {
      topicWrongAnswers.add(questionId);
    }

    if (topicWrongAnswers.isEmpty) {
      updatedWrongAnswers.remove(topicId);
    } else {
      updatedWrongAnswers[topicId] = topicWrongAnswers;
    }

    _snapshot = _snapshot.copyWith(
      wrongGrammarQuestionIdsByTopic: updatedWrongAnswers,
    );
    await _persist();
    await AnalyticsService.instance.logEvent(
      wasCorrect ? 'wrong_answer_cleared' : 'grammar_answer_marked_wrong',
      parameters: <String, Object?>{
        'topic_id': topicId,
        'question_id': questionId,
        'source': source,
        'remaining_wrong_answers': topicWrongAnswers.length,
      },
    );
  }

  Future<void> recordQuizCompletion({
    required int topicId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final updatedScores = Map<int, double>.from(quizScoresByTopic);
    final scorePercent = totalQuestions == 0
        ? 0.0
        : (correctAnswers / totalQuestions) * 100;
    final previousScore = updatedScores[topicId] ?? 0.0;
    updatedScores[topicId] = scorePercent > previousScore
        ? scorePercent
        : previousScore;

    _snapshot = _snapshot.copyWith(
      quizScoresByTopic: updatedScores,
      grammarQuizzesCompleted: grammarQuizzesCompleted + 1,
      xpPoints: xpPoints + (correctAnswers * 10),
    );
    await _persist();
    await AnalyticsService.instance.logEvent(
      'quiz_finished',
      parameters: <String, Object?>{
        'topic_id': topicId,
        'correct_answers': correctAnswers,
        'total_questions': totalQuestions,
        'score_percent': scorePercent.round(),
      },
    );
  }

  Future<void> addXp(int amount) async {
    _snapshot = _snapshot.copyWith(xpPoints: xpPoints + amount);
    await _persist();
  }

  Future<bool> markDailyChallengeCompleted() async {
    final todayKey = _dateKey(DateTime.now());
    if (lastDailyChallengeDate == todayKey) {
      return false;
    }

    final yesterdayKey = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final nextStreak = lastDailyChallengeDate == yesterdayKey
        ? currentStreak + 1
        : 1;

    _snapshot = _snapshot.copyWith(
      xpPoints: xpPoints + 20,
      currentStreak: nextStreak,
      lastDailyChallengeDate: todayKey,
    );
    await _persist();
    await AnalyticsService.instance.logEvent(
      'daily_challenge_completed',
      parameters: <String, Object?>{
        'earned_bonus': true,
        'streak': nextStreak,
      },
    );
    return true;
  }

  Future<void> resetProgress() async {
    _snapshot = ProgressSnapshot.initial();
    await _persist();
    await AnalyticsService.instance.logEvent('progress_reset');
  }

  Future<void> _persist() async {
    if (_storage == null) {
      return;
    }
    await _storage!.save(_snapshot);
    notifyListeners();
  }

  ProgressSnapshot _normalizeReviewSnapshot(ProgressSnapshot snapshot) {
    final normalizedDueDates = Map<int, String>.from(snapshot.reviewDueDatesByVocab);
    final normalizedStages = Map<int, int>.from(snapshot.reviewStageByVocab);
    final todayKey = _dateKey(DateTime.now());

    for (final vocabId in snapshot.learnedVocabIds) {
      normalizedDueDates.putIfAbsent(vocabId, () => todayKey);
      normalizedStages.putIfAbsent(vocabId, () => 0);
    }

    normalizedDueDates.removeWhere(
      (vocabId, _) => !snapshot.learnedVocabIds.contains(vocabId),
    );
    normalizedStages.removeWhere(
      (vocabId, _) => !snapshot.learnedVocabIds.contains(vocabId),
    );

    return snapshot.copyWith(
      reviewDueDatesByVocab: normalizedDueDates,
      reviewStageByVocab: normalizedStages,
    );
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
