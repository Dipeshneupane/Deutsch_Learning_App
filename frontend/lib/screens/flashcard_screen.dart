import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vocabulary_category.dart';
import '../models/vocabulary_word.dart';
import '../providers/app_state.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/flashcard_view.dart';
import '../widgets/placeholder_ad_banner.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({
    super.key,
    required this.category,
    this.selectedLevel,
  });

  final VocabularyCategory category;
  final String? selectedLevel;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final ApiService _apiService = ApiService();
  late final Future<List<VocabularyWord>> _wordsFuture;
  int _currentIndex = 0;
  bool _showBack = false;
  int _knownCount = 0;

  @override
  void initState() {
    super.initState();
    _wordsFuture = _apiService.getVocabulary(
      categoryId: widget.category.id,
      level: widget.selectedLevel,
    );
    AnalyticsService.instance.logScreenView('flashcard_screen');
    AnalyticsService.instance.logEvent(
      'vocab_category_opened',
      parameters: <String, Object?>{
        'category_id': widget.category.id,
        'category_name': widget.category.name,
        'level': widget.selectedLevel ?? 'all',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: widget.selectedLevel == null
          ? widget.category.name
          : '${widget.category.name} • ${widget.selectedLevel}',
      child: FutureBuilder<List<VocabularyWord>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load vocabulary.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final words = snapshot.data ?? const [];
          if (words.isEmpty) {
            return const EmptyState(
              icon: Icons.style,
              title: 'No flashcards yet',
              message: 'This category does not have any vocabulary right now.',
            );
          }

          if (_currentIndex >= words.length) {
            return _CompletionState(
              totalWords: words.length,
              knownCount: _knownCount,
              onRestart: () {
                setState(() {
                  _currentIndex = 0;
                  _showBack = false;
                  _knownCount = 0;
                });
              },
            );
          }

          final word = words[_currentIndex];
          final appState = context.watch<AppState>();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selectedLevel != null) ...[
                  Chip(
                    avatar: const Icon(Icons.school, size: 18),
                    label: Text('Level ${widget.selectedLevel}'),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Card ${_currentIndex + 1} of ${words.length}',
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
                          source: 'flashcard',
                        );
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _knownCount++;
                          _advance();
                        });
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Know'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(_advance);
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text("Don't Know"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<AppState>().toggleFavorite(
                          word.id,
                          source: 'flashcard',
                        );
                      },
                      icon: Icon(
                        appState.isFavorite(word.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        appState.isFavorite(word.id) ? 'Favorited' : 'Favorite',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(_advance),
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
        },
      ),
    );
  }

  void _advance() {
    _currentIndex++;
    _showBack = false;
  }
}

class _CompletionState extends StatelessWidget {
  const _CompletionState({
    required this.totalWords,
    required this.knownCount,
    required this.onRestart,
  });

  final int totalWords;
  final int knownCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.celebration, size: 52),
                  const SizedBox(height: 16),
                  Text(
                    'Flashcard set complete',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text('You marked $knownCount of $totalWords words as known.'),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onRestart,
                    child: const Text('Restart deck'),
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
}
