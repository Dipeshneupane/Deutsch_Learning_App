import 'package:flutter/material.dart';

import '../models/vocabulary_category.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_ad_banner.dart';
import 'flashcard_screen.dart';

class VocabularyCategoriesScreen extends StatefulWidget {
  const VocabularyCategoriesScreen({super.key});

  @override
  State<VocabularyCategoriesScreen> createState() =>
      _VocabularyCategoriesScreenState();
}

class _VocabularyCategoriesScreenState extends State<VocabularyCategoriesScreen> {
  static const List<String> _levels = ['A1', 'A2', 'B1'];
  final ApiService _apiService = ApiService();
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Vocabulary Categories',
      child: FutureBuilder<List<VocabularyCategory>>(
        future: _apiService.getVocabularyCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(error: snapshot.error.toString());
          }

          final categories = snapshot.data ?? const [];
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a study level',
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
                const SizedBox(height: 12),
                Text(
                  _selectedLevel == null
                      ? 'Browse every category and study mixed A1 to B1 vocabulary.'
                      : 'Browse every category and study only $_selectedLevel vocabulary.',
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.4,
                      ),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => FlashcardScreen(
                                    category: category,
                                    selectedLevel: _selectedLevel,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        child: Icon(_iconFor(category.iconName)),
                                      ),
                                      const Spacer(),
                                      if (_selectedLevel != null)
                                        Chip(
                                          label: Text(_selectedLevel!),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    category.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(category.description),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  IconData _iconFor(String iconName) {
    return switch (iconName) {
      'family_restroom' => Icons.family_restroom,
      'restaurant' => Icons.restaurant,
      'train' => Icons.train,
      'school' => Icons.school,
      'work' => Icons.work,
      'shopping_bag' => Icons.shopping_bag,
      'health_and_safety' => Icons.health_and_safety,
      'pin' => Icons.pin,
      'palette' => Icons.palette,
      'calendar_today' => Icons.calendar_today,
      _ => Icons.category,
    };
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Could not load categories.\n$error',
        textAlign: TextAlign.center,
      ),
    );
  }
}
