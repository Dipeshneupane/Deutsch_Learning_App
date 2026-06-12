import 'package:flutter/material.dart';

import '../models/vocabulary_word.dart';

class FlashcardView extends StatelessWidget {
  const FlashcardView({
    super.key,
    required this.word,
    required this.showBack,
    required this.onTap,
  });

  final VocabularyWord word;
  final bool showBack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [colors.primaryContainer, colors.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: showBack
                  ? _FlashcardBack(key: const ValueKey('back'), word: word)
                  : _FlashcardFront(key: const ValueKey('front'), word: word),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardFront extends StatelessWidget {
  const _FlashcardFront({super.key, required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Chip(label: Text(word.categoryName)),
          const SizedBox(height: 24),
          Text(word.german, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Tap to reveal the meaning and examples.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _FlashcardBack extends StatelessWidget {
  const _FlashcardBack({super.key, required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Chip(label: Text('Level ${word.level}')),
          const SizedBox(height: 24),
          Text(word.english, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text('German example: ${word.exampleGerman}'),
          const SizedBox(height: 10),
          Text('English example: ${word.exampleEnglish}'),
        ],
      ),
    );
  }
}
