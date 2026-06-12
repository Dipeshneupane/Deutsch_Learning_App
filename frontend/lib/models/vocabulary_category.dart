class VocabularyCategory {
  const VocabularyCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
  });

  final int id;
  final String name;
  final String description;
  final String iconName;

  factory VocabularyCategory.fromJson(Map<String, dynamic> json) {
    return VocabularyCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
    );
  }
}
