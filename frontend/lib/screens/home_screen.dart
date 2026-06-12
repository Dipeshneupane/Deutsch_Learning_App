import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/app_shell.dart';
import '../widgets/feature_card.dart';
import '../widgets/placeholder_ad_banner.dart';
import 'daily_challenge_screen.dart';
import 'favorites_screen.dart';
import 'grammar_topics_screen.dart';
import 'progress_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';
import 'vocabulary_categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppShell(
      title: 'Deutsch Starter',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beginner-friendly German in short daily sessions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Review flashcards, practice grammar, keep favorites, and track progress locally with no login.',
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.bolt, size: 18),
                          label: Text('${appState.xpPoints} XP'),
                        ),
                        Chip(
                          avatar: const Icon(
                            Icons.local_fire_department,
                            size: 18,
                          ),
                          label: Text('${appState.currentStreak} day streak'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.menu_book, size: 18),
                          label: Text(
                            '${appState.totalVocabLearned} vocab learned',
                          ),
                        ),
                        Chip(
                          avatar: const Icon(Icons.auto_stories, size: 18),
                          label: Text('${appState.dueReviewCount} reviews due'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.refresh, size: 18),
                          label: Text(
                            '${appState.totalWrongGrammarQuestions} wrong answers to review',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 720 ? 2 : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.35,
                  children: [
                    FeatureCard(
                      icon: Icons.style,
                      title: 'Vocabulary',
                      subtitle: 'Learn common German words with flashcards.',
                      onTap: () =>
                          _open(context, const VocabularyCategoriesScreen()),
                    ),
                    FeatureCard(
                      icon: Icons.quiz,
                      title: 'Grammar Quiz',
                      subtitle:
                          'Practice grammar, search topics, and review mistakes.',
                      onTap: () => _open(context, const GrammarTopicsScreen()),
                    ),
                    FeatureCard(
                      icon: Icons.auto_stories,
                      title: 'Review Mode',
                      subtitle:
                          'Review due flashcards with spaced repetition.',
                      onTap: () => _open(context, const ReviewScreen()),
                    ),
                    FeatureCard(
                      icon: Icons.today,
                      title: 'Daily Challenge',
                      subtitle: 'Complete 10 words and 5 grammar questions.',
                      onTap: () => _open(context, const DailyChallengeScreen()),
                    ),
                    FeatureCard(
                      icon: Icons.favorite,
                      title: 'Favorites',
                      subtitle: 'Keep your most useful vocabulary close by.',
                      onTap: () => _open(context, const FavoritesScreen()),
                    ),
                    FeatureCard(
                      icon: Icons.insights,
                      title: 'Progress',
                      subtitle:
                          'See XP, streaks, learned words, and quiz results.',
                      onTap: () => _open(context, const ProgressScreen()),
                    ),
                    FeatureCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle:
                          'Switch themes, reset progress, and see app info.',
                      onTap: () => _open(context, const SettingsScreen()),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const PlaceholderAdBanner(),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
