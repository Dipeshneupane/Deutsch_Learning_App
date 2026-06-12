class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.german,
    required this.english,
    required this.categoryId,
    required this.categoryName,
    required this.level,
    required this.exampleGerman,
    required this.exampleEnglish,
  });

  final int id;
  final String german;
  final String english;
  final int categoryId;
  final String categoryName;
  final String level;
  final String exampleGerman;
  final String exampleEnglish;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as int,
      german: json['german'] as String,
      english: json['english'] as String,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      level: json['level'] as String,
      exampleGerman: json['exampleGerman'] as String,
      exampleEnglish: json['exampleEnglish'] as String,
    );
  }
}
