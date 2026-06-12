class GrammarTopic {
  const GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
  });

  final int id;
  final String title;
  final String description;
  final String level;

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
    );
  }
}
