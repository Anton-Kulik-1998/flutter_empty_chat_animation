import 'dart:ui';

class PointModel {
  Offset position;
  Offset velocity;
  bool isOutOfScreen = false;
  int imageNum;

  PointModel({
    required this.position,
    required this.velocity,
    required this.imageNum,
  });
}
