class Question {
  final String id;
  final int category;
  final String text;
  final List<String> options;
  final String? packTag;

  const Question({
    required this.id,
    required this.category,
    required this.text,
    required this.options,
    this.packTag,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      category: json['category'] as int,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      packTag: json['packTag'] as String?,
    );
  }
}
