import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grammar_question.dart';
import '../models/grammar_topic.dart';
import '../providers/app_state.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_ad_banner.dart';

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({
    super.key,
    required this.topic,
    this.questionsFutureOverride,
    this.reviewMode = false,
    this.titleOverride,
  });

  final GrammarTopic topic;
  final Future<List<GrammarQuestion>>? questionsFutureOverride;
  final bool reviewMode;
  final String? titleOverride;

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  final ApiService _apiService = ApiService();
  late final Future<List<GrammarQuestion>> _questionsFuture;
  int _currentIndex = 0;
  int? _selectedAnswer;
  int _correctAnswers = 0;
  bool _answered = false;
  bool _resultSaved = false;
  final Set<int> _sessionWrongQuestionIds = <int>{};

  @override
  void initState() {
    super.initState();
    _questionsFuture =
        widget.questionsFutureOverride ??
        _apiService.getGrammarQuestions(topicId: widget.topic.id);
    AnalyticsService.instance.logScreenView('grammar_quiz_screen');
    AnalyticsService.instance.logEvent(
      widget.reviewMode ? 'wrong_answers_review_started' : 'quiz_started',
      parameters: <String, Object?>{
        'topic_id': widget.topic.id,
        'topic_title': widget.topic.title,
        'level': widget.topic.level,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: widget.titleOverride ?? widget.topic.title,
      child: FutureBuilder<List<GrammarQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load quiz questions.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final questions = snapshot.data ?? const [];
          if (_currentIndex >= questions.length) {
            return _QuizResultView(
              topic: widget.topic,
              title: widget.titleOverride ?? widget.topic.title,
              correctAnswers: _correctAnswers,
              totalQuestions: questions.length,
              reviewMode: widget.reviewMode,
              wrongAnswerCount: context.watch<AppState>().wrongQuestionCountForTopic(
                widget.topic.id,
              ),
              onReviewWrongAnswers: widget.reviewMode
                  ? null
                  : () => _openWrongAnswerReview(context),
              onRestart: () {
                setState(() {
                  _currentIndex = 0;
                  _selectedAnswer = null;
                  _correctAnswers = 0;
                  _answered = false;
                  _resultSaved = false;
                  _sessionWrongQuestionIds.clear();
                });
              },
            );
          }

          final question = questions[_currentIndex];
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.reviewMode ? 'Review question' : 'Question'} ${_currentIndex + 1} of ${questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(label: Text('Level ${question.level}')),
                        const SizedBox(height: 16),
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
                                  backgroundColor: _buttonColor(
                                    context,
                                    question,
                                    i,
                                  ),
                                ),
                                onPressed: _answered
                                    ? null
                                    : () => _answerQuestion(question, i),
                                child: Text(question.options[i]),
                              ),
                            ),
                          ),
                        if (_answered) ...[
                          const SizedBox(height: 12),
                          Text(
                            _selectedAnswer == question.correctAnswerIndex
                                ? 'Correct!'
                                : 'Not quite.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(question.explanation),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: () async {
                                if (_currentIndex == questions.length - 1 &&
                                    !_resultSaved &&
                                    !widget.reviewMode) {
                                  await context
                                      .read<AppState>()
                                      .recordQuizCompletion(
                                        topicId: widget.topic.id,
                                        correctAnswers: _correctAnswers,
                                        totalQuestions: questions.length,
                                      );
                                  _resultSaved = true;
                                  if (context.mounted) {
                                    await AdService.showQuizCompletionInterstitial(
                                      context,
                                    );
                                  }
                                }

                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _currentIndex++;
                                  _selectedAnswer = null;
                                  _answered = false;
                                });
                              },
                              child: Text(
                                _currentIndex == questions.length - 1
                                    ? 'See results'
                                    : 'Next question',
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
        },
      ),
    );
  }

  void _answerQuestion(GrammarQuestion question, int selectedIndex) {
    final isCorrect = selectedIndex == question.correctAnswerIndex;
    context.read<AppState>().recordGrammarQuestionResult(
      topicId: widget.topic.id,
      questionId: question.id,
      wasCorrect: isCorrect,
      source: widget.reviewMode ? 'wrong_answer_review' : 'quiz',
    );
    AnalyticsService.instance.logEvent(
      'quiz_answered',
      parameters: <String, Object?>{
        'topic_id': widget.topic.id,
        'question_id': question.id,
        'level': question.level,
        'correct': isCorrect,
      },
    );
    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (isCorrect) {
        _correctAnswers++;
        _sessionWrongQuestionIds.remove(question.id);
      } else {
        _sessionWrongQuestionIds.add(question.id);
      }
    });
  }

  void _openWrongAnswerReview(BuildContext context) {
    final wrongQuestionIds = context.read<AppState>().wrongQuestionIdsForTopic(
      widget.topic.id,
    );
    if (wrongQuestionIds.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GrammarQuizScreen(
          topic: widget.topic,
          titleOverride: '${widget.topic.title} • Review Wrong Answers',
          reviewMode: true,
          questionsFutureOverride: _apiService.getGrammarQuestionsByIds(
            wrongQuestionIds,
          ),
        ),
      ),
    );
  }

  Color? _buttonColor(
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

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.topic,
    required this.title,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.reviewMode,
    required this.wrongAnswerCount,
    required this.onRestart,
    this.onReviewWrongAnswers,
  });

  final GrammarTopic topic;
  final String title;
  final int correctAnswers;
  final int totalQuestions;
  final bool reviewMode;
  final int wrongAnswerCount;
  final VoidCallback onRestart;
  final VoidCallback? onReviewWrongAnswers;

  @override
  Widget build(BuildContext context) {
    final score = totalQuestions == 0
        ? 0
        : (correctAnswers / totalQuestions) * 100;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 54),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$correctAnswers / $totalQuestions correct',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Score: ${score.toStringAsFixed(0)}%'),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onRestart,
                    child: Text(
                      reviewMode ? 'Review again' : 'Retake quiz',
                    ),
                  ),
                  if (!reviewMode && wrongAnswerCount > 0) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onReviewWrongAnswers,
                      icon: const Icon(Icons.refresh),
                      label: Text('Review $wrongAnswerCount wrong answers'),
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
}
