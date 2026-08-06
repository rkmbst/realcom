import 'package:flutter/material.dart';
import '../models/question.dart';

class ResultScreen extends StatelessWidget {
  final Question question;
  final String userAnswer;
  final Map<String, double> results;
  final String wheelCategory;

  const ResultScreen({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.results,
    required this.wheelCategory,
  });

  @override
  Widget build(BuildContext context) {
    // فرز النتائج تنازلياً
    final sortedResults = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = sortedResults.isNotEmpty ? sortedResults.first.value : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text("📊 النتيجة"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // السؤال
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                question.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // إجابة المستخدم
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Text(
                "إجابتك: $userAnswer",
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // الأعمدة البيانية
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sortedResults.map((entry) {
                    final percentage = entry.value;
                    final isUserChoice = entry.key == userAnswer;
                    final barColor = isUserChoice
                        ? const Color(0xFFD4AF37)
                        : Colors.white.withOpacity(0.7);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isUserChoice)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(Icons.check_circle,
                                          color: Color(0xFFD4AF37), size: 16),
                                    ),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isUserChoice
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${percentage.round()}%",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: barColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Stack(
                            children: [
                              // خلفية الشريط
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              // الشريط المملوء
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                height: 12,
                                width: (MediaQuery.of(context).size.width -
                                        64) *
                                    (percentage / maxValue),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isUserChoice
                                        ? [
                                            const Color(0xFFD4AF37),
                                            const Color(0xFFFFD700)
                                          ]
                                        : [
                                            Colors.white.withOpacity(0.5),
                                            Colors.white.withOpacity(0.3)
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: isUserChoice
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFD4AF37)
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // أزرار الإجراءات
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.casino),
                    label: const Text("دور مجدداً"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
