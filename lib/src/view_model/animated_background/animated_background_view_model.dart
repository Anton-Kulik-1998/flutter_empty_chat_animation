import 'dart:async'; // Для использования Timer
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';

class AnimatedBackgroundViewModel extends ChangeNotifier {
  double _width;
  double _height;
  final int numPoints;
  final double maxSpeed;
  final double imageSize;
  final double pointSize;
  final double maxLineDistance;
  final String? assetImage;
  final _wallCollisionOffset = 25; //TODO: Переделать _wallCollisionOffset!
  Timer? _resizeTimer; // Для задержки перед перезапуском анимации
  final Color paintColor;
  final Color lineColor;
  final double maxDistance;
  final bool enableLines;
  final bool stopResizingAnimation;
  final bool enableTouchReaction;
  final double touchSpeedMultiplier;
  final CustomPaint? customPaint;

  double get width => _width;
  double get height => _height;

  late List<PointModel> _points;
  ui.Image? _image;
  final Random _random = Random();
  late AnimationController _controller;

  List<PointModel> get points => _points;
  ui.Image? get image => _image;

  AnimatedBackgroundViewModel({
    required double width,
    required double height,
    required this.numPoints,
    required this.maxSpeed,
    required this.imageSize,
    required this.pointSize,
    required this.maxLineDistance,
    this.assetImage,
    required this.paintColor,
    required this.lineColor,
    required this.maxDistance,
    required this.enableLines,
    required this.stopResizingAnimation,
    required this.enableTouchReaction,
    required this.touchSpeedMultiplier,
    this.customPaint,
    required TickerProvider vsync,
  })  : _width = width,
        _height = height {
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
    _loadImage(assetImage);
  }

  // Новый метод для обновления размеров
  void updateSize(double newWidth, double newHeight) {
    if (newWidth != _width || newHeight != _height) {
      _width = newWidth;
      _height = newHeight;
      if (stopResizingAnimation) {
        stopAnimation();
        // Если продолжается изменение размеров, сбрасываем таймер
        _resizeTimer?.cancel();
        startAnimation(500);
      }
      notifyListeners();
    }
  }

  void startAnimation(int delay) {
    // Устанавливаем таймер для задержки перезапуска анимации
    _resizeTimer = Timer(
      Duration(milliseconds: delay),
      () {
        _controller.repeat();
      },
    );
    notifyListeners();
  }

  void stopAnimation() {
    _controller.stop();
    notifyListeners();
  }

  Future<void> _loadImage(String? assetImage) async {
    if (assetImage != null && assetImage.isNotEmpty) {
      final ByteData data = await rootBundle.load(assetImage);
      final Uint8List bytes = Uint8List.view(data.buffer);
      ui.decodeImageFromList(bytes, (img) {
        _image = img;
        notifyListeners();
      });
    }
  }

  void _isReturnToScreenCheck(int i) {
    // Если точка полностью вернулась на экран, сбрасываем флаг
    if (_points[i].position.dx >= _wallCollisionOffset &&
        _points[i].position.dx <= _width - _wallCollisionOffset &&
        _points[i].position.dy >= _wallCollisionOffset &&
        _points[i].position.dy <= _height - _wallCollisionOffset) {
      _points[i].isOutOfScreen = false;
    }
  }

  void _returnPointToScreen(int i, double enableOffset) {
    // //Возврат точек, которые попали за поле
    if (_points[i].position.dx < -enableOffset) {
      _points[i].velocity = Offset(1, _points[i].velocity.dy);
      _points[i].isOutOfScreen = true;
    }
    if (_points[i].position.dx > _width + enableOffset) {
      _points[i].velocity = Offset(-1, _points[i].velocity.dy);
      _points[i].isOutOfScreen = true;
    }

    if (_points[i].position.dy < -enableOffset) {
      _points[i].velocity = Offset(_points[i].velocity.dx, 1);
      _points[i].isOutOfScreen = true;
    }
    if (_points[i].position.dy > _height + enableOffset) {
      _points[i].velocity = Offset(_points[i].velocity.dx, -1);
      _points[i].isOutOfScreen = true;
    }
    _isReturnToScreenCheck(i);
  }

  void _checkingWallsCollision(int i) {
    // Проверяем, если точка за экраном, столкновение не проверяется
    if (_points[i].isOutOfScreen) return;

    if (_points[i].position.dx < _wallCollisionOffset ||
        _points[i].position.dx > _width - _wallCollisionOffset) {
      _points[i].velocity =
          Offset(-_points[i].velocity.dx, _points[i].velocity.dy);
    }
    if (_points[i].position.dy < _wallCollisionOffset ||
        _points[i].position.dy > _height - _wallCollisionOffset) {
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
      _returnPointToScreen(i, 5);

      // Проверка на столкновение с другими изображениями
      _checkingImageCollision(i);
    }
    notifyListeners();
  }

  void onPanUpdate(Offset touchPosition) {
    if (enableTouchReaction) {
      for (int i = 0; i < _points.length; i++) {
        final distance = (touchPosition - _points[i].position).distance;
        if (distance < maxLineDistance) {
          final direction = _points[i].position - touchPosition;
          _points[i].velocity = direction *
              (maxSpeed * touchSpeedMultiplier / direction.distance);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
