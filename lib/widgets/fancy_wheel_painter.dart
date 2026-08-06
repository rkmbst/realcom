import 'dart:math';
import 'package:flutter/material.dart';

class WheelSegment {
  final String title;
  final Color color;
  final IconData icon;
  const WheelSegment(this.title, this.color, this.icon);
}

const List<WheelSegment> kSegments = [
  WheelSegment("نعم / لا", Color(0xFF6C5CE7), Icons.check_circle_outline),
  WheelSegment("محايد", Color(0xFF00B894), Icons.thumbs_up_down_outlined),
  WheelSegment("تصويت جماعي", Color(0xFF0984E3), Icons.people_outline),
  WheelSegment("اختر بين اثنين", Color(0xFFE17055), Icons.compare_arrows),
  WheelSegment("اعتراف", Color(0xFFD63031), Icons.favorite_border),
  WheelSegment("تحدي", Color(0xFFFDCB6E), Icons.bolt),
];

class FancyWheelPainter extends CustomPainter {
  final double rotation;
  final double wheelRadius;

  FancyWheelPainter(this.rotation, this.wheelRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double segmentAngle = 2 * pi / kSegments.length;

    // طبقة زجاجية شفافة خارجية
    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.03)],
      ).createShader(Rect.fromCircle(center: center, radius: wheelRadius));
    canvas.drawCircle(center, wheelRadius, glassPaint);

    // رسم الأقسام الستة
    for (int i = 0; i < kSegments.length; i++) {
      final startAngle = rotation + i * segmentAngle;
      final sweepAngle = segmentAngle;

      // تدرج لوني داخل القسم
      final gradient = SweepGradient(
        startAngle: 0.0,
        endAngle: pi * 2,
        colors: [
          kSegments[i].color.withOpacity(0.9),
          kSegments[i].color,
          kSegments[i].color.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: wheelRadius));

      final paint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: wheelRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // حدود ذهبية بين الأقسام
      final borderPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: wheelRadius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // النص والأيقونة
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = wheelRadius * 0.72;
      final textOffset = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );

      // رسم الأيقونة
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(kSegments[i].icon.codePoint),
          style: TextStyle(
            fontSize: 24,
            fontFamily: kSegments[i].icon.fontFamily,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        textOffset - Offset(iconPainter.width / 2, iconPainter.height / 2 + 10),
      );

      // رسم اسم الفئة
      final titlePainter = TextPainter(
        text: TextSpan(
          text: kSegments[i].title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.rtl, // دعم العربية
      )..layout();
      titlePainter.paint(
        canvas,
        textOffset - Offset(titlePainter.width / 2, -iconPainter.height / 2),
      );
    }

    // دائرة مركزية ذهبية
    final centerCirclePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.grey.shade200],
      ).createShader(Rect.fromCircle(center: center, radius: wheelRadius * 0.18));
    canvas.drawCircle(center, wheelRadius * 0.18, centerCirclePaint);

    // حلقة ذهبية
    final centerBorder = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, wheelRadius * 0.18, centerBorder);

    // نجمة في المركز
    _drawStar(canvas, center, wheelRadius * 0.08, Colors.black87);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
