import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grammar_question.dart';
import '../models/vocabulary_word.dart';
import '../providers/app_state.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/flashcard_view.dart';
import '../widgets/placeholder_ad_banner.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final ApiService _apiService = ApiService();
  final Random _random = Random();
  late final Future<_DailyChallengeData> _challengeFuture;
  static const int _targetVocabularyCount = 10;
  static const int _targetGrammarCount = 5;
  int _vocabIndex = 0;
  int _grammarIndex = 0;
  int? _selectedAnswer;
  bool _showBack = false;
  bool _answered = false;
  int _correctGrammarAnswers = 0;
  bool _completionSaved = false;
  bool _savingCompletion = false;
  bool _earnedDailyBonus = false;

  @override
  void initState() {
    super.initState();
    _challengeFuture = _loadChallenge();
    AnalyticsService.instance.logScreenView('daily_challenge_screen');
    AnalyticsService.instance.logEvent('daily_challenge_started');
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Daily Challenge',
      child: FutureBuilder<_DailyChallengeData>(
        future: _challengeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load today\'s challenge.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final challenge = snapshot.data!;
          if (challenge.vocabulary.isEmpty || challenge.questions.isEmpty) {
            return const Center(
              child: Text(
                'Today\'s challenge is not ready yet.\nPlease try again in a moment.',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_vocabIndex < challenge.vocabulary.length) {
            return _buildVocabularyChallenge(
              challenge.vocabulary[_vocabIndex],
              challenge.vocabulary.length,
            );
          }

          if (_grammarIndex < challenge.questions.length) {
            return _buildGrammarChallenge(
              challenge.questions[_grammarIndex],
              challenge.questions.length,
            );
          }

          if (!_completionSaved && !_savingCompletion) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _saveDailyCompletionIfNeeded();
            });
          }

          return _DailyChallengeResult(
            correctGrammarAnswers: _correctGrammarAnswers,
            totalGrammarQuestions: challenge.questions.length,
            completionSaved: _completionSaved,
            savingCompletion: _savingCompletion,
            earnedDailyBonus: _earnedDailyBonus,
            onComplete: _saveDailyCompletionIfNeeded,
            onRestart: () {
              setState(() {
                _vocabIndex = 0;
                _grammarIndex = 0;
                _selectedAnswer = null;
                _showBack = false;
                _answered = false;
                _correctGrammarAnswers = 0;
                _completionSaved = false;
                _savingCompletion = false;
                _earnedDailyBonus = false;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildVocabularyChallenge(VocabularyWord word, int totalVocabulary) {
    final appState = context.watch<AppState>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vocabulary challenge ${_vocabIndex + 1} of $totalVocabulary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FlashcardView(
            word: word,
            showBack: _showBack,
            onTap: () => setState(() => _showBack = !_showBack),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  await context.read<AppState>().markVocabularyKnown(
                    word.id,
                    source: 'daily_challenge',
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() => _advanceVocabulary());
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Know'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(_advanceVocabulary),
                icon: const Icon(Icons.help_outline),
                label: const Text("Don't Know"),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AppState>().toggleFavorite(
                    word.id,
                    source: 'daily_challenge',
                  );
                },
                icon: Icon(
                  appState.isFavorite(word.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: const Text('Favorite'),
              ),
              TextButton.icon(
                onPressed: () => setState(_advanceVocabulary),
                icon: const Icon(Icons.navigate_next),
                label: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const PlaceholderAdBanner(compact: true),
        ],
      ),
    );
  }

  Widget _buildGrammarChallenge(GrammarQuestion question, int totalQuestions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grammar challenge ${_grammarIndex + 1} of $totalQuestions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < question.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.centerLeft,
                            backgroundColor: _dailyQuestionColor(
                              context,
                              question,
                              i,
                            ),
                          ),
                          onPressed: _answered
                              ? null
                              : () => _answerDailyQuestion(question, i),
                          child: Text(question.options[i]),
                        ),
                      ),
                    ),
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    Text(question.explanation),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _grammarIndex++;
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        },
                        child: Text(
                          _grammarIndex == totalQuestions - 1
                              ? 'Finish challenge'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const PlaceholderAdBanner(compact: true),
        ],
      ),
    );
  }

  Future<_DailyChallengeData> _loadChallenge() async {
    final results = await Future.wait([
      _apiService.getVocabulary(),
      _apiService.getGrammarQuestions(),
    ]);
    final vocabulary = results[0] as List<VocabularyWord>;
    final questions = results[1] as List<GrammarQuestion>;

    final vocabularyCopy = List<VocabularyWord>.from(vocabulary)
      ..shuffle(_random);
    final questionCopy = List<GrammarQuestion>.from(questions)
      ..shuffle(_random);

    if (vocabularyCopy.isEmpty || questionCopy.isEmpty) {
      throw Exception('The backend returned an empty daily challenge dataset.');
    }

    return _DailyChallengeData(
      vocabulary: vocabularyCopy.take(_targetVocabularyCount).toList(),
      questions: questionCopy.take(_targetGrammarCount).toList(),
    );
  }

  Future<void> _saveDailyCompletionIfNeeded() async {
    if (_completionSaved || _savingCompletion) {
      return;
    }

    setState(() {
      _savingCompletion = true;
    });

    final didEarn = await context.read<AppState>().markDailyChallengeCompleted();
    if (!mounted) {
      return;
    }

    if (!didEarn) {
      await AnalyticsService.instance.logEvent(
        'daily_challenge_completed',
        parameters: <String, Object?>{'earned_bonus': false},
      );
    }

    setState(() {
      _savingCompletion = false;
      _completionSaved = true;
      _earnedDailyBonus = didEarn;
    });
  }

  void _advanceVocabulary() {
    _vocabIndex++;
    _showBack = false;
  }

  Future<void> _answerDailyQuestion(GrammarQuestion question, int index) async {
    final isCorrect = index == question.correctAnswerIndex;
    if (isCorrect) {
      await context.read<AppState>().addXp(10);
    }
    await AnalyticsService.instance.logEvent(
      'daily_grammar_answered',
      parameters: <String, Object?>{
        'question_id': question.id,
        'level': question.level,
        'correct': isCorrect,
      },
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) {
        _correctGrammarAnswers++;
      }
    });
  }

  Color? _dailyQuestionColor(
    BuildContext context,
    GrammarQuestion question,
    int index,
  ) {
    if (!_answered) {
      return null;
    }

    final colors = Theme.of(context).colorScheme;
    if (index == question.correctAnswerIndex) {
      return colors.primaryContainer;
    }
    if (_selectedAnswer == index) {
      return colors.errorContainer;
    }
    return null;
  }
}

class _DailyChallengeResult extends StatelessWidget {
  const _DailyChallengeResult({
    required this.correctGrammarAnswers,
    required this.totalGrammarQuestions,
    required this.completionSaved,
    required this.savingCompletion,
    required this.earnedDailyBonus,
    required this.onComplete,
    required this.onRestart,
  });

  final int correctGrammarAnswers;
  final int totalGrammarQuestions;
  final bool completionSaved;
  final bool savingCompletion;
  final bool earnedDailyBonus;
  final Future<void> Function() onComplete;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, size: 54),
                const SizedBox(height: 16),
                Text(
                  'Daily challenge complete',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Grammar score: $correctGrammarAnswers / $totalGrammarQuestions',
                ),
                const SizedBox(height: 8),
                Text(
                  savingCompletion
                      ? 'Saving today\'s completion...'
                      : earnedDailyBonus
                      ? 'Daily bonus saved. You earned +20 XP.'
                      : completionSaved
                      ? 'Today\'s completion is already saved. Come back tomorrow for a new streak bonus.'
                      : 'Complete once per day to earn the daily bonus and streak.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: completionSaved || savingCompletion
                      ? null
                      : onComplete,
                  child: Text(
                    completionSaved ? 'Saved' : 'Save daily completion',
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onRestart,
                  child: const Text('Play again'),
                ),
                const SizedBox(height: 18),
                const PlaceholderAdBanner(compact: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeData {
  const _DailyChallengeData({
    required this.vocabulary,
    required this.questions,
  });

  final List<VocabularyWord> vocabulary;
  final List<GrammarQuestion> questions;
}
