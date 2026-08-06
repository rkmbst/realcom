import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionsRepository {
  List<Question> _allQuestions = [];
  final Set<String> _usedQuestionIds = {};

  Future<void> loadQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _allQuestions = jsonList
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الأسئلة: $e');
    }
  }

  Question? getRandomQuestion(int category) {
    // ✅ إصلاح: فحص الفئة الفارغة قبل أي شيء
    final allInCategory =
        _allQuestions.where((q) => q.category == category).toList();
    if (allInCategory.isEmpty) {
      return null;
    }

    var pool = allInCategory
        .where((q) => !_usedQuestionIds.contains(q.id))
        .toList();

    if (pool.isEmpty) {
      _usedQuestionIds.clear();
      pool = allInCategory;
    }

    final randomIndex = Random().nextInt(pool.length);
    final question = pool[randomIndex];
    _usedQuestionIds.add(question.id);

    final shuffledOptions = List<String>.from(question.options)..shuffle();

    return Question(
      id: question.id,
      category: question.category,
      text: question.text,
      options: shuffledOptions,
      packTag: question.packTag,
    );
  }

  Map<String, double> getFakeResults(Question question) {
    final random = Random();
    final total = 100;
    final results = <String, double>{};
    final remainingOptions = List<String>.from(question.options)..shuffle();

    for (int i = 0; i < remainingOptions.length; i++) {
      if (i == remainingOptions.length - 1) {
        final sumSoFar = results.values.fold(0.0, (a, b) => a + b);
        results[remainingOptions[i]] = (total - sumSoFar).toDouble();
      } else {
        final maxShare = total -
            results.values.fold(0.0, (a, b) => a + b) -
            (remainingOptions.length - i - 1) * 5;
        results[remainingOptions[i]] =
            (5 + random.nextInt(maxShare.toInt() - 5)).toDouble();
      }
    }
    return results;
  }

  bool get hasQuestions => _allQuestions.isNotEmpty;
}
