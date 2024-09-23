import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';

class PointsPainter extends CustomPainter {
  final List<PointModel> points;
  final ui.Image? image;
  final double imageSize;
  final double pointSize;
  final Color paintColor;
  final Color lineColor;
  final double maxDistance;
  final bool enableLines;

  PointsPainter({
    required this.points,
    required this.image,
    required this.imageSize,
    required this.pointSize,
    required this.paintColor,
    required this.lineColor,
    required this.maxDistance,
    required this.enableLines,
  });

  void _addLines(Canvas canvas, Paint paint) {
    // Draw lines between nearest points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i].position - points[j].position).distance;
        if (distance < maxDistance) {
          paint.color = lineColor.withOpacity(1.0 - (distance / maxDistance));
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
    for (final point in points) {
      final srcRect = Rect.fromLTWH(
          0, 0, image!.width.toDouble(), image!.height.toDouble());
      final dstRect = Rect.fromCenter(
        center: point.position,
        width: imageSize,
        height: imageSize,
      );
      canvas.drawImageRect(image!, srcRect, dstRect, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    (image != null) ? _drawImages(canvas, paint) : _drawPoints(canvas, paint);

    if (enableLines) _addLines(canvas, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
