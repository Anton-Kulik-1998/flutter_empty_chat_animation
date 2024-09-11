import 'package:flutter/material.dart';

class PointsPainter extends CustomPainter {
  final List<Offset> points;
  final double maxDistance;
  final Color paintColor;
  final Color lineColor;
  PointsPainter(this.points, this.maxDistance, this.paintColor, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 1.0, paint);
    }

    // Draw lines between nearest points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < maxDistance) {
          paint.color =
              lineColor.withOpacity(1.0 - (distance / maxDistance));
          canvas.drawLine(points[i], points[j], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


// const Color.fromARGB(255, 0, 0, 0)

//  Colors.black.withOpacity(1.0 - (distance / maxDistance));