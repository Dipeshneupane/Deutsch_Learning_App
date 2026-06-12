import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grammar_topic.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_ad_banner.dart';
import 'grammar_quiz_screen.dart';

class GrammarTopicsScreen extends StatefulWidget {
  const GrammarTopicsScreen({super.key});

  @override
  State<GrammarTopicsScreen> createState() => _GrammarTopicsScreenState();
}

class _GrammarTopicsScreenState extends State<GrammarTopicsScreen> {
  static const List<String> _levels = ['A1', 'A2', 'B1'];
  final ApiService _apiService = ApiService();
  String? _selectedLevel;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bestScores = context.watch<AppState>().quizScoresByTopic;

    return AppShell(
      title: 'Grammar Topics',
      child: FutureBuilder<List<GrammarTopic>>(
        future: _apiService.getGrammarTopics(level: _selectedLevel),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load grammar topics.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final topics = snapshot.data ?? const [];
          final filteredTopics = topics.where((topic) {
            if (_searchQuery.isEmpty) {
              return true;
            }
            final query = _searchQuery.toLowerCase();
            return topic.title.toLowerCase().contains(query) ||
                topic.description.toLowerCase().contains(query);
          }).toList();
          final groupedTopics = <String, List<GrammarTopic>>{};
          final visibleLevels = _selectedLevel == null ? _levels : [_selectedLevel!];
          for (final level in visibleLevels) {
            groupedTopics[level] = filteredTopics
                .where((topic) => topic.level == level)
                .toList();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a grammar level',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('All Levels'),
                      selected: _selectedLevel == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedLevel = null;
                        });
                      },
                    ),
                    for (final level in _levels)
                      ChoiceChip(
                        label: Text(level),
                        selected: _selectedLevel == level,
                        onSelected: (_) {
                          setState(() {
                            _selectedLevel = level;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search grammar topics',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${filteredTopics.length} topic${filteredTopics.length == 1 ? '' : 's'} found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (filteredTopics.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Text(
                      'No grammar topics match this search and level yet.',
                    ),
                  ),
                for (final level in visibleLevels) ...[
                  if ((groupedTopics[level] ?? const []).isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '$level Grammar',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groupedTopics[level]!.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final topic = groupedTopics[level]![index];
                        final bestScore = bestScores[topic.id];
                        final wrongAnswerCount = context
                            .watch<AppState>()
                            .wrongQuestionCountForTopic(topic.id);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(child: Text(topic.level)),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            topic.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            bestScore == null
                                                ? topic.description
                                                : '${topic.description}\nBest score: ${bestScore.toStringAsFixed(0)}%',
                                          ),
                                          if (wrongAnswerCount > 0) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              '$wrongAnswerCount wrong answer${wrongAnswerCount == 1 ? '' : 's'} ready to review',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                GrammarQuizScreen(topic: topic),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                GrammarQuizScreen(topic: topic),
                                          ),
                                        );
                                      },
                                      child: const Text('Start quiz'),
                                    ),
                                    if (wrongAnswerCount > 0)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) => GrammarQuizScreen(
                                                topic: topic,
                                                titleOverride:
                                                    '${topic.title} • Review Wrong Answers',
                                                reviewMode: true,
                                                questionsFutureOverride:
                                                    _apiService
                                                        .getGrammarQuestionsByIds(
                                                          context
                                                              .read<AppState>()
                                                              .wrongQuestionIdsForTopic(
                                                                topic.id,
                                                              ),
                                                        ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: Text(
                                          'Review wrong answers',
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
                const SizedBox(height: 18),
                const PlaceholderAdBanner(),
              ],
            ),
          );
        },
      ),
    );
  }
}
