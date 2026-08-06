import 'package:flutter/material.dart';
import '../models/question.dart';
import '../data/questions_repository.dart';
import '../utils/haptic_helper.dart';
import 'result_screen.dart';

class QuestionScreen extends StatefulWidget {
  final Question question;
  final QuestionsRepository repository;
  final String wheelCategory;

  const QuestionScreen({
    super.key,
    required this.question,
    required this.repository,
    required this.wheelCategory,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAnswer;
  bool _isRevealed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _isRevealed = true;
    });
    HapticHelper.lightImpact();
  }

  void _proceedToResults() {
    if (_selectedAnswer == null) return;
    final results = widget.repository.getFakeResults(widget.question);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          question: widget.question,
          userAnswer: _selectedAnswer!,
          results: results,
          wheelCategory: widget.wheelCategory,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const categoryColors = {
      1: Color(0xFF6C5CE7),
      2: Color(0xFF00B894),
      3: Color(0xFF0984E3),
      4: Color(0xFFE17055),
      5: Color(0xFFD63031),
      6: Color(0xFFFDCB6E),
    };
    const categoryNames = {
      1: "نعم / لا",
      2: "محايد",
      3: "تصويت جماعي",
      4: "اختر بين اثنين",
      5: "اعتراف",
      6: "تحدي",
    };

    final catColor =
        categoryColors[widget.question.category] ?? const Color(0xFF6C5CE7);
    final catName =
        categoryNames[widget.question.category] ?? "غير معروف";

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: Text("📋 $catName")),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: catColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category, color: catColor, size: 20),
                  const SizedBox(width: 8),
                  Text(catName,
                      style: TextStyle(
                          color: catColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedBuilder(   // ✅ تم التصحيح
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRevealed ? 1.0 : _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    const Icon(Icons.help_outline,
                        size: 48, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 20),
                    Text(
                      widget.question.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: widget.question.options.map((option) {
                  final isSelected = option == _selectedAnswer;
                  return GestureDetector(
                    onTap:
                        _isRevealed ? null : () => _selectAnswer(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? catColor
                              : Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: catColor.withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 1)
                              ]
                            : [],
                      ),
                      child: Text(option,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            if (_isRevealed)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: _proceedToResults,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black87,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("شاهد النتيجة 📊"),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
}
