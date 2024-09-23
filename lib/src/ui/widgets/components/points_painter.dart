import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';

class PointsPainter extends CustomPainter {
  final List<PointModel> points;
  final ui.Image? image;
  final double imageSize;
  final double pointSize;
  final Color paintColor;
  final Color lineColor;

  PointsPainter({
    required this.points,
    required this.image,
    required this.imageSize,
    required this.pointSize,
    required this.paintColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    if (image != null) {
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
    } else {
      // Draw points
      for (final point in points) {
        canvas.drawCircle(point.position, pointSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
