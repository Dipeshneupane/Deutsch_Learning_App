import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vocabulary_word.dart';
import '../providers/app_state.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/flashcard_view.dart';
import '../widgets/placeholder_ad_banner.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ApiService _apiService = ApiService();
  late final Future<void> _loadFuture;
  final List<int> _queue = <int>[];
  final Map<int, VocabularyWord> _wordsById = <int, VocabularyWord>{};
  bool _showBack = false;
  int _initialCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadDeck();
    AnalyticsService.instance.logScreenView('review_screen');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppShell(
      title: 'Review Mode',
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load your review deck.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_queue.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  EmptyState(
                    icon: Icons.auto_stories,
                    title: 'No reviews due right now',
                    message:
                        'You are all caught up. Learn more words today and come back when your next reviews are due.',
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review summary',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tracked review words: ${appState.reviewDueDatesByVocab.length}',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Learned vocabulary: ${appState.totalVocabLearned}',
                          ),
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

          final currentWord = _wordsById[_queue.first];
          if (currentWord == null) {
            return const Center(
              child: Text(
                'A review card could not be loaded.\nPlease reopen review mode.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final currentPosition = (_initialCount - _queue.length) + 1;
          final currentStage = appState.reviewStageFor(currentWord.id) + 1;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due review $currentPosition of $_initialCount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.today, size: 18),
                      label: Text('${appState.dueReviewCount} due today'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.timeline, size: 18),
                      label: Text('Stage $currentStage'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FlashcardView(
                  word: currentWord,
                  showBack: _showBack,
                  onTap: () => setState(() => _showBack = !_showBack),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _markCurrentWord(knewIt: true),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Got It'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _markCurrentWord(knewIt: false),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Review Again'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<AppState>().toggleFavorite(
                          currentWord.id,
                          source: 'review',
                        );
                      },
                      icon: Icon(
                        appState.isFavorite(currentWord.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        appState.isFavorite(currentWord.id)
                            ? 'Favorited'
                            : 'Favorite',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _skipCurrentWord,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Skip'),
                    ),
                  ],
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

  Future<void> _loadDeck() async {
    final dueIds = context.read<AppState>().dueReviewVocabIds;
    _queue
      ..clear()
      ..addAll(dueIds);
    _initialCount = dueIds.length;

    await AnalyticsService.instance.logEvent(
      'review_started',
      parameters: <String, Object?>{'cards_due': _initialCount},
    );

    if (dueIds.isEmpty) {
      return;
    }

    final words = await _apiService.getVocabularyByIds(dueIds);
    _wordsById
      ..clear()
      ..addEntries(words.map((word) => MapEntry(word.id, word)));
  }

  Future<void> _markCurrentWord({required bool knewIt}) async {
    if (_queue.isEmpty) {
      return;
    }

    final currentId = _queue.first;
    await context.read<AppState>().recordReviewResult(
      currentId,
      knewIt: knewIt,
      awardXp: knewIt,
      source: 'review',
    );
    if (!mounted) {
      return;
    }

    final completedSession = _queue.length == 1 && knewIt;
    setState(() {
      _showBack = false;
      _queue.removeAt(0);
      if (!knewIt) {
        _queue.add(currentId);
      }
    });

    if (completedSession) {
      await AnalyticsService.instance.logEvent(
        'review_completed',
        parameters: <String, Object?>{'cards_reviewed': _initialCount},
      );
    }
  }

  void _skipCurrentWord() {
    if (_queue.length < 2) {
      return;
    }

    setState(() {
      _showBack = false;
      final currentId = _queue.removeAt(0);
      _queue.add(currentId);
    });
  }
}
