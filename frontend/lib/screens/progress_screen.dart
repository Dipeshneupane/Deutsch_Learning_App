import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_ad_banner.dart';
import '../widgets/progress_stat_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppShell(
      title: 'Progress',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 720 ? 3 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    ProgressStatCard(
                      label: 'Learned vocabulary',
                      value: '${appState.totalVocabLearned}',
                      icon: Icons.menu_book,
                    ),
                    ProgressStatCard(
                      label: 'Favorite words',
                      value: '${appState.favoriteVocabIds.length}',
                      icon: Icons.favorite,
                    ),
                    ProgressStatCard(
                      label: 'Grammar quizzes completed',
                      value: '${appState.grammarQuizzesCompleted}',
                      icon: Icons.quiz,
                    ),
                    ProgressStatCard(
                      label: 'Average quiz score',
                      value: '${appState.averageQuizScore.toStringAsFixed(0)}%',
                      icon: Icons.analytics,
                    ),
                    ProgressStatCard(
                      label: 'XP points',
                      value: '${appState.xpPoints}',
                      icon: Icons.bolt,
                    ),
                    ProgressStatCard(
                      label: 'Current streak',
                      value: '${appState.currentStreak}',
                      icon: Icons.local_fire_department,
                    ),
                    ProgressStatCard(
                      label: 'Due reviews',
                      value: '${appState.dueReviewCount}',
                      icon: Icons.auto_stories,
                    ),
                    ProgressStatCard(
                      label: 'Tracked review cards',
                      value: '${appState.reviewDueDatesByVocab.length}',
                      icon: Icons.schedule,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stored locally on this device',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Last daily challenge date: '
                      '${appState.lastDailyChallengeDate ?? 'Not completed yet'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quiz topics with scores saved: '
                      '${appState.quizScoresByTopic.length}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review cards currently tracked: '
                      '${appState.reviewDueDatesByVocab.length}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const PlaceholderAdBanner(),
          ],
        ),
      ),
    );
  }
}
