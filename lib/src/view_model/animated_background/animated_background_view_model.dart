import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';

class AnimatedBackgroundViewModel extends ChangeNotifier {
  final double width;
  final double height;
  final int numPoints;
  final double maxSpeed;
  final double imageSize;
  final double maxLineDistance;

  late List<PointModel> _points;
  ui.Image? _image;
  final Random _random = Random();
  late AnimationController _controller;

  List<PointModel> get points => _points;
  ui.Image? get image => _image;

  AnimatedBackgroundViewModel({
    required this.width,
    required this.height,
    required this.numPoints,
    this.maxSpeed = 0.5,
    this.imageSize = 50.0,
    this.maxLineDistance = 100.0,
    required TickerProvider vsync,
  }) {
    _points = List.generate(numPoints, (index) {
      return PointModel(
        position:
            Offset(_random.nextDouble() * width, _random.nextDouble() * height),
        velocity: Offset(_random.nextDouble() * maxSpeed * 2 - maxSpeed,
            _random.nextDouble() * maxSpeed * 2 - maxSpeed),
      );
    });

    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePoints);

    _controller.repeat();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/images/ufo.png');
    final Uint8List bytes = Uint8List.view(data.buffer);
    ui.decodeImageFromList(bytes, (img) {
      _image = img;
      notifyListeners();
    });
  }

  void _returnPointToScreen(int i) {
    // //Возврат точек, которые попали за поле
    if (_points[i].position.dx < -5) {
      _points[i].velocity = Offset(1, _points[i].velocity.dy);
    }
    if (_points[i].position.dx > width + 5) {
      _points[i].velocity = Offset(-1, _points[i].velocity.dy);
    }

    if (_points[i].position.dy < -5) {
      _points[i].velocity = Offset(_points[i].velocity.dx, 1);
    }
    if (_points[i].position.dy > height + 5) {
      _points[i].velocity = Offset(_points[i].velocity.dx, -1);
    }
  }

  void _checkingWallsCollision(int i) {
    if (_points[i].position.dx < 0 || _points[i].position.dx > width) {
      _points[i].velocity =
          Offset(-_points[i].velocity.dx, _points[i].velocity.dy);
    }
    if (_points[i].position.dy < 0 || _points[i].position.dy > height) {
      _points[i].velocity =
          Offset(_points[i].velocity.dx, -_points[i].velocity.dy);
    }
  }

  void _checkingImageCollision(int i) {
    for (int j = 0; j < _points.length; j++) {
      if (i != j) {
        final distance = (_points[i].position - _points[j].position).distance;

        if (distance < imageSize) {
          final tempVelocity = _points[i].velocity;
          _points[i].velocity = _points[j].velocity;
          _points[j].velocity = tempVelocity;

          final overlap = imageSize - distance;
          final direction =
              (_points[i].position - _points[j].position).direction;
          _points[i].position += Offset(
            cos(direction) * overlap / 2,
            sin(direction) * overlap / 2,
          );
          _points[j].position += Offset(
            -cos(direction) * overlap / 2,
            -sin(direction) * overlap / 2,
          );
        }
      }
    }
  }

  void _updatePoints() {
    for (int i = 0; i < _points.length; i++) {
      _points[i].position += _points[i].velocity;

      // Проверка на столкновение со стенками
      _checkingWallsCollision(i);

      // Возврат точки обратно на видимую часть экрана, если она вылетела
      _returnPointToScreen(i);

      // Проверка на столкновение с другими изображениями
      _checkingImageCollision(i);
    }
    notifyListeners();
  }

  void onPanUpdate(Offset touchPosition) {
    for (int i = 0; i < _points.length; i++) {
      final distance = (touchPosition - _points[i].position).distance;
      if (distance < maxLineDistance) {
        final direction = _points[i].position - touchPosition;
        _points[i].velocity = direction * (maxSpeed / direction.distance);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
