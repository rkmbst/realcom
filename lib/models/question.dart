class Question {
  final String id;
  final int category;        // 1-6
  final String text;         // نص السؤال
  final List<String> options; // خيارات الإجابة (نعم/لا/محايد...)
  final String? packTag;     // حزمة موضوعية (اختياري)

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'text': text,
      'options': options,
      'packTag': packTag,
    };
  }
}
