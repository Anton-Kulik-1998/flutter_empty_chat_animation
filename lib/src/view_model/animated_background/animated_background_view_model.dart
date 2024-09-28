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
  final List<String> assetImages;
  final double wallCollisionOffset;
  Timer? _resizeTimer; // Для задержки перед перезапуском анимации
  final Color paintColor;
  final Color lineColor;
  final bool lineColorFading;
  final double maxDistance;
  final bool enableLines;
  final bool stopResizingAnimation;
  final bool enableTouchReaction;
  final double touchSpeedMultiplier;
  final CustomPaint? customPaint;

  double get width => _width;
  double get height => _height;

  late List<PointModel> _points;
  final List<ui.Image> _images = []; // Список загруженных изображений
  final Random _random = Random();
  late AnimationController _controller;

  late AnimationController
      _opacityController; // Контроллер для анимации прозрачности
  late Animation<double> _opacityAnimation; // Анимация прозрачности

  double get opacityAnimation =>
      _opacityAnimation.value; // Текущее значение прозрачности

  // Флаг для отслеживания загрузки изображений
  bool _imagesLoaded = false;
  bool get imagesLoaded => _imagesLoaded; // Геттер для доступа к флагу

  List<PointModel> get points => _points;
  List<ui.Image> get images => _images; // Геттер для доступа к изображениям

  AnimatedBackgroundViewModel({
    required double width,
    required double height,
    required this.numPoints,
    required this.maxSpeed,
    required this.imageSize,
    required this.pointSize,
    required this.maxLineDistance,
    required this.assetImages,
    required this.wallCollisionOffset,
    required this.paintColor,
    required this.lineColor,
    required this.lineColorFading,
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
          position: Offset(
              _random.nextDouble() * width, _random.nextDouble() * height),
          velocity: Offset(_random.nextDouble() * maxSpeed * 2 - maxSpeed,
              _random.nextDouble() * maxSpeed * 2 - maxSpeed),
          imageNum: _random.nextInt(assetImages.length));
    });

    _opacityController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(_opacityController)
          ..addListener(() {
            notifyListeners();
          });

    _opacityController.forward(); // Запуск анимации прозрачности

    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePoints);
    _controller.repeat();
    _loadImages(assetImages);
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

  // Метод для загрузки списка изображений
  Future<void> _loadImages(List<String> assetImages) async {
    _images.clear(); // Очищаем список перед загрузкой новых изображений

    for (String assetImage in assetImages) {
      if (assetImage.isNotEmpty) {
        final ByteData data = await rootBundle.load(assetImage);
        final Uint8List bytes = Uint8List.view(data.buffer);

        // Используем Future для ожидания загрузки каждого изображения
        final completer = Completer<ui.Image>();
        ui.decodeImageFromList(bytes, (img) {
          completer.complete(img);
        });

        final image = await completer.future;
        _images.add(image); // Добавляем загруженное изображение в список
      }
    }
    _imagesLoaded = true;
    notifyListeners(); // Уведомляем слушателей после загрузки всех изображений
  }

  void _isReturnToScreenCheck(int i) {
    // Если точка полностью вернулась на экран, сбрасываем флаг
    if (_points[i].position.dx >= wallCollisionOffset &&
        _points[i].position.dx <= _width - wallCollisionOffset &&
        _points[i].position.dy >= wallCollisionOffset &&
        _points[i].position.dy <= _height - wallCollisionOffset) {
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

    if (_points[i].position.dx < wallCollisionOffset ||
        _points[i].position.dx > _width - wallCollisionOffset) {
      _points[i].velocity =
          Offset(-_points[i].velocity.dx, _points[i].velocity.dy);
    }
    if (_points[i].position.dy < wallCollisionOffset ||
        _points[i].position.dy > _height - wallCollisionOffset) {
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
    _opacityController.dispose();
    super.dispose();
  }
}
