class GrammarQuestion {
  const GrammarQuestion({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.level,
  });

  final int id;
  final int topicId;
  final String topicTitle;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String level;

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>)
        .map((option) => option as String)
        .toList();

    return GrammarQuestion(
      id: json['id'] as int,
      topicId: json['topicId'] as int,
      topicTitle: json['topicTitle'] as String,
      question: json['question'] as String,
      options: options,
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      level: json['level'] as String,
    );
  }
}
