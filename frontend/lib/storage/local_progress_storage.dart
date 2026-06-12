import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_snapshot.dart';

class LocalProgressStorage {
  LocalProgressStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _learnedVocabIdsKey = 'learned_vocab_ids';
  static const _favoriteVocabIdsKey = 'favorite_vocab_ids';
  static const _reviewDueDatesByVocabKey = 'review_due_dates_by_vocab';
  static const _reviewStageByVocabKey = 'review_stage_by_vocab';
  static const _wrongGrammarQuestionIdsByTopicKey =
      'wrong_grammar_question_ids_by_topic';
  static const _quizScoresByTopicKey = 'quiz_scores_by_topic';
  static const _grammarQuizzesCompletedKey = 'grammar_quizzes_completed';
  static const _totalVocabLearnedKey = 'total_vocab_learned';
  static const _averageQuizScoreKey = 'average_quiz_score';
  static const _xpPointsKey = 'xp_points';
  static const _currentStreakKey = 'current_streak';
  static const _lastDailyChallengeDateKey = 'last_daily_challenge_date';
  static const _darkModeKey = 'dark_mode_enabled';

  Future<ProgressSnapshot> load() async {
    final learnedIds = _prefs.getStringList(_learnedVocabIdsKey) ?? const [];
    final favoriteIds = _prefs.getStringList(_favoriteVocabIdsKey) ?? const [];
    final rawQuizScores = _prefs.getString(_quizScoresByTopicKey);
    final decodedQuizScores = rawQuizScores == null
        ? <String, dynamic>{}
        : jsonDecode(rawQuizScores) as Map<String, dynamic>;
    final rawReviewDueDates = _prefs.getString(_reviewDueDatesByVocabKey);
    final decodedReviewDueDates = rawReviewDueDates == null
        ? <String, dynamic>{}
        : jsonDecode(rawReviewDueDates) as Map<String, dynamic>;
    final rawReviewStages = _prefs.getString(_reviewStageByVocabKey);
    final decodedReviewStages = rawReviewStages == null
        ? <String, dynamic>{}
        : jsonDecode(rawReviewStages) as Map<String, dynamic>;
    final rawWrongGrammarQuestions = _prefs.getString(
      _wrongGrammarQuestionIdsByTopicKey,
    );
    final decodedWrongGrammarQuestions = rawWrongGrammarQuestions == null
        ? <String, dynamic>{}
        : jsonDecode(rawWrongGrammarQuestions) as Map<String, dynamic>;

    return ProgressSnapshot(
      learnedVocabIds: learnedIds.map(int.parse).toSet(),
      favoriteVocabIds: favoriteIds.map(int.parse).toSet(),
      reviewDueDatesByVocab: decodedReviewDueDates.map(
        (key, value) => MapEntry(int.parse(key), value as String),
      ),
      reviewStageByVocab: decodedReviewStages.map(
        (key, value) => MapEntry(int.parse(key), (value as num).toInt()),
      ),
      wrongGrammarQuestionIdsByTopic: decodedWrongGrammarQuestions.map(
        (key, value) => MapEntry(
          int.parse(key),
          (value as List<dynamic>).map((id) => (id as num).toInt()).toSet(),
        ),
      ),
      quizScoresByTopic: decodedQuizScores.map(
        (key, value) => MapEntry(int.parse(key), (value as num).toDouble()),
      ),
      grammarQuizzesCompleted: _prefs.getInt(_grammarQuizzesCompletedKey) ?? 0,
      xpPoints: _prefs.getInt(_xpPointsKey) ?? 0,
      currentStreak: _prefs.getInt(_currentStreakKey) ?? 0,
      lastDailyChallengeDate: _prefs.getString(_lastDailyChallengeDateKey),
      isDarkMode: _prefs.getBool(_darkModeKey) ?? false,
    );
  }

  Future<void> save(ProgressSnapshot snapshot) async {
    await _prefs.setStringList(
      _learnedVocabIdsKey,
      snapshot.learnedVocabIds.map((id) => id.toString()).toList(),
    );
    await _prefs.setStringList(
      _favoriteVocabIdsKey,
      snapshot.favoriteVocabIds.map((id) => id.toString()).toList(),
    );
    await _prefs.setString(
      _reviewDueDatesByVocabKey,
      jsonEncode(
        snapshot.reviewDueDatesByVocab.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      ),
    );
    await _prefs.setString(
      _reviewStageByVocabKey,
      jsonEncode(
        snapshot.reviewStageByVocab.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      ),
    );
    await _prefs.setString(
      _wrongGrammarQuestionIdsByTopicKey,
      jsonEncode(
        snapshot.wrongGrammarQuestionIdsByTopic.map(
          (key, value) => MapEntry(
            key.toString(),
            value.toList()..sort(),
          ),
        ),
      ),
    );
    await _prefs.setString(
      _quizScoresByTopicKey,
      jsonEncode(
        snapshot.quizScoresByTopic.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      ),
    );
    await _prefs.setInt(
      _grammarQuizzesCompletedKey,
      snapshot.grammarQuizzesCompleted,
    );
    await _prefs.setInt(_totalVocabLearnedKey, snapshot.totalVocabLearned);
    await _prefs.setDouble(_averageQuizScoreKey, snapshot.averageQuizScore);
    await _prefs.setInt(_xpPointsKey, snapshot.xpPoints);
    await _prefs.setInt(_currentStreakKey, snapshot.currentStreak);

    if (snapshot.lastDailyChallengeDate == null) {
      await _prefs.remove(_lastDailyChallengeDateKey);
    } else {
      await _prefs.setString(
        _lastDailyChallengeDateKey,
        snapshot.lastDailyChallengeDate!,
      );
    }

    await _prefs.setBool(_darkModeKey, snapshot.isDarkMode);
  }
}
