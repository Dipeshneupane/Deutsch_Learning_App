import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vocabulary_word.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/placeholder_ad_banner.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<AppState>().favoriteVocabIds.toList();
    final apiService = ApiService();

    return AppShell(
      title: 'Favorites',
      child: favoriteIds.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message:
                  'Tap Favorite on any flashcard to build your own review list.',
            )
          : FutureBuilder<List<VocabularyWord>>(
              future: apiService.getVocabularyByIds(favoriteIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load favorites.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final words = snapshot.data ?? const [];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: words.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final word = words[index];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(18),
                              title: Text(word.german),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${word.english}\n${word.exampleGerman}\n${word.exampleEnglish}',
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  await context.read<AppState>().toggleFavorite(
                                    word.id,
                                  );
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          );
                        },
                      ),
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
