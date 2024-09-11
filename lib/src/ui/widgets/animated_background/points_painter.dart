import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PointsPainter extends CustomPainter {
  final List<Offset> points;
  final double maxDistance;
  final Color paintColor;
  final Color lineColor;
  final ui.Image? image;
  final double imageSize; // Добавляем размер изображения

  PointsPainter(
    this.points,
    this.maxDistance,
    this.paintColor,
    this.lineColor,
    this.image, {
    this.imageSize = 50.0, // Размер изображения по умолчанию
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    if (image != null) {
      // Рисуем изображение вместо точек с измененным размером
      for (final point in points) {
        // Исходные размеры изображения
        final srcRect = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());

        // Прямоугольник, куда мы хотим поместить изображение (с центровкой)
        final dstRect = Rect.fromCenter(
          center: point,
          width: imageSize,  // Ширина изображения
          height: imageSize, // Высота изображения
        );

        // Рисуем изображение в новом размере
        canvas.drawImageRect(image!, srcRect, dstRect, paint);
      }
    } else {
      // Пока изображение не загружено, рисуем точки
      for (final point in points) {
        canvas.drawCircle(point, 50.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
