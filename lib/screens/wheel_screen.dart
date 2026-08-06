import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/fancy_wheel_painter.dart';
import '../widgets/error_banner.dart';
import '../data/questions_repository.dart';
import '../utils/haptic_helper.dart';
import 'question_screen.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  final QuestionsRepository _repo = QuestionsRepository();
  double _currentRotation = 0.0;
  bool _isSpinning = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          _currentRotation = _spinController.value * 2 * pi * 10;
        });
      });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _repo.loadQuestions();
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الأسئلة. تأكد من الاتصال وحاول مجدداً.';
      });
    }
  }

  Future<void> _spinWheel() async {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);
    HapticHelper.mediumImpact();

    final randomDuration = 3000 + Random().nextInt(2000);
    _spinController.reset();
    _spinController.duration = Duration(milliseconds: randomDuration);

    // ✅ إصلاح: استخدام try/catch بدلاً من .orCancel
    try {
      await _spinController.forward();
    } catch (_) {}

    if (!mounted) return;

    final normalizedAngle = _currentRotation % (2 * pi);
    final segmentAngle = 2 * pi / kSegments.length;
    final pointerAngle = (2 * pi - normalizedAngle + pi / 2) % (2 * pi);
    final selectedIndex = (pointerAngle / segmentAngle).floor();

    setState(() => _isSpinning = false);

    final question = _repo.getRandomQuestion(selectedIndex + 1);
    if (question != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionScreen(
            question: question,
            repository: _repo,
            wheelCategory: kSegments[selectedIndex].title,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('لا توجد أسئلة في هذه الفئة بعد. يمكنك اقتراح سؤال جديد!'),
          backgroundColor: Color(0xFFD63031),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wheelDiameter = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: const Text("🎡 عجلة الأسئلة")),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _errorMessage != null
              ? Center(
                  child: ErrorBanner(
                    message: _errorMessage!,
                    onRetry: _loadData,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIndicator(),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onVerticalDragEnd:
                          _isSpinning ? null : (_) => _spinWheel(),
                      onTap: _isSpinning ? null : () => _spinWheel(),
                      child: Container(
                        width: wheelDiameter,
                        height: wheelDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 30,
                                spreadRadius: 5),
                            BoxShadow(
                                color: Colors.white10,
                                blurRadius: 15,
                                spreadRadius: -5),
                          ],
                        ),
                        child: CustomPaint(
                          painter: FancyWheelPainter(
                              _currentRotation, wheelDiameter / 2),
                          child: Center(
                            child: _isSpinning
                                ? const SizedBox.shrink()
                                : const Icon(Icons.touch_app,
                                    color: Colors.white54, size: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isSpinning ? null : _spinWheel,
                      icon: const Icon(Icons.casino),
                      label:
                          Text(_isSpinning ? "جاري الدوران..." : "دور العجلة"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 18),
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black87,
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildIndicator() {
    return CustomPaint(
      size: const Size(30, 24),
      painter: _IndicatorPainter(),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
