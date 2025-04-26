import 'package:flutter/material.dart';
import 'dart:math' as math;

class SaglikBakanligiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.57;

    // Hilal (Ay) - ince, uçları sivri, içi tamamen boş
    final hilalPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;
    final hilalRadius = size.width * 0.39;
    final hilalRect = Rect.fromCircle(center: Offset(cx, cy), radius: hilalRadius);
    // Büyük yay (hilal)
    canvas.drawArc(hilalRect, 5.2, 4.1, false, hilalPaint);
    // Küçük yay (hilalin iç boşluğu)
    final icHilalPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09;
    final icHilalRect = Rect.fromCircle(center: Offset(cx + size.width * 0.11, cy + size.height * 0.06), radius: size.width * 0.285);
    canvas.drawArc(icHilalRect, 5.23, 4.05, false, icHilalPaint);

    // Yıldız - düzgün beş köşeli, kırmızı
    final starPaint = Paint()..color = const Color(0xFFD32F2F);
    final starPath = Path();
    final starCx = cx;
    final starCy = cy - size.height * 0.38;
    final starR = size.width * 0.12;
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * math.pi / 180;
      double x = starCx + starR * math.cos(angle);
      double y = starCy + starR * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
      double angle2 = ((i + 0.5) * 72 - 90) * math.pi / 180;
      double x2 = starCx + starR * 0.45 * math.cos(angle2);
      double y2 = starCy + starR * 0.45 * math.sin(angle2);
      starPath.lineTo(x2, y2);
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // İnsan figürü - zarif, kolu yıldızın ucuna doğru
    final figPaint = Paint()
      ..color = const Color(0xFF22B8C9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;
    // Gövde (kavisli çizgi)
    final bodyPath = Path();
    bodyPath.moveTo(cx, cy + size.height * 0.13);
    bodyPath.quadraticBezierTo(cx + size.width * 0.09, cy - size.height * 0.04, cx, cy - size.height * 0.13);
    canvas.drawPath(bodyPath, figPaint);
    // Kol (yukarı yıldızın ucuna doğru)
    final armPath = Path();
    armPath.moveTo(cx, cy - size.height * 0.06);
    armPath.quadraticBezierTo(cx + size.width * 0.15, cy - size.height * 0.22, starCx, starCy + starR * 0.13);
    canvas.drawPath(armPath, figPaint);
    // Kafa (küçük daire)
    final headPaint = Paint()
      ..color = const Color(0xFF22B8C9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - size.height * 0.13), size.width * 0.045, headPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => oldDelegate != this;
}
