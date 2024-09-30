import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';

class PointsPainter extends CustomPainter {
  final List<PointModel> points;
  final List<ui.Image> images; // Список изображений
  final double imageSize;
  final double pointSize;
  final Color paintColor;
  final Color lineColor;
  final double maxDistance;
  final bool enableLines;
  final bool lineColorFading;
  final bool imagesLoaded;

  PointsPainter({
    required this.points,
    required this.images,
    required this.imageSize,
    required this.pointSize,
    required this.paintColor,
    required this.lineColor,
    required this.maxDistance,
    required this.enableLines,
    required this.lineColorFading,
    required this.imagesLoaded,
  });

  final Random _random = Random();

  void _addLines(Canvas canvas, Paint paint) {
    // Draw lines between nearest points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i].position - points[j].position).distance;
        if (distance < maxDistance) {
          paint.color = lineColorFading
              ? lineColor.withOpacity(1.0 - (distance / maxDistance))
              : lineColor;
          canvas.drawLine(points[i].position, points[j].position, paint);
        }
      }
    }
  }

  void _drawPoints(Canvas canvas, Paint paint) {
    // Draw points
    for (final point in points) {
      canvas.drawCircle(point.position, pointSize, paint);
    }
  }

  void _drawImages(Canvas canvas, Paint paint) {
    // Проверяем, что список изображений не пуст
    if (images.isEmpty) {
      return; // Если нет изображений, не рисуем
    }

    for (final point in points) {
      point.selectedImage ??= images[_random.nextInt(images.length)];

      // Определяем исходный и целевой прямоугольники для отрисовки изображения
      final srcRect = Rect.fromLTWH(0, 0, point.selectedImage!.width.toDouble(),
          point.selectedImage!.height.toDouble());
      final dstRect = Rect.fromCenter(
        center: point.position,
        width: imageSize,
        height: imageSize,
      );

      // Рисуем выбранное изображение
      canvas.drawImageRect(point.selectedImage!, srcRect, dstRect, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    // Если изображения присутствуют, рисуем их, иначе рисуем точки
    (imagesLoaded) ? _drawImages(canvas, paint) : _drawPoints(canvas, paint);

    if (enableLines) _addLines(canvas, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
