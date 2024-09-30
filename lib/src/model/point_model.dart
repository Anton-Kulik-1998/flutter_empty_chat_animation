import 'dart:ui';

class PointModel {
  Offset position;
  Offset velocity;
  bool isOutOfScreen = false;
  Image? selectedImage;

  PointModel({
    required this.position,
    required this.velocity,
    this.selectedImage
  });
}
