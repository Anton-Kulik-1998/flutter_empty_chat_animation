import 'dart:ui';

class PointModel {
  Offset position;
  Offset velocity;
  bool isOutOfScreen = false;

  PointModel({
    required this.position,
    required this.velocity,
  });
}
