import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PointsPainter extends CustomPainter {
  final List<Offset> points;
  final ui.Image? image;
  final double imageSize;
  final Color paintColor;
  final Color lineColor;

  PointsPainter(this.points, this.image, this.imageSize, this.paintColor, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    if (image != null) {
      // Рисуем изображение вместо точек
      for (final point in points) {
        final srcRect = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
        final dstRect = Rect.fromCenter(center: point, width: imageSize, height: imageSize);
        canvas.drawImageRect(image!, srcRect, dstRect, paint);
      }
    } else {
      // Пока изображение не загружено, рисуем точки
      for (final point in points) {
        canvas.drawCircle(point, imageSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
