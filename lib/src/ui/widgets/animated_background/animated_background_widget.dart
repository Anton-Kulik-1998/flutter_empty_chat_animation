import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/points_painter.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  const AnimatedBackgroundWidget({
    super.key,
    required this.width,
    required this.height,
  });
  final double width;
  final double height;

  @override
  _AnimatedBackgroundWidgetState createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Offset> _points = [];
  final Random _random = Random();
  final int _numPoints = 20;
  final double _maxSpeed = 0.5;
  final double _imageSize = 50.0; // Размер изображения
  final List<Offset> _velocities = [];
  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    // Initialize points and velocities
    for (int i = 0; i < _numPoints; i++) {
      _points.add(Offset(_random.nextDouble() * widget.width,
          _random.nextDouble() * widget.height));
      _velocities.add(Offset(_random.nextDouble() * _maxSpeed * 2 - _maxSpeed,
          _random.nextDouble() * _maxSpeed * 2 - _maxSpeed));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {
          _updatePoints();
        });
      });

    _controller.repeat();
    _loadImage(); // Загружаем изображение при инициализации
  }

  // Метод для асинхронной загрузки изображения
  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/images/ufo.png');
    final Uint8List bytes = Uint8List.view(data.buffer);
    ui.decodeImageFromList(bytes, (img) {
      setState(() {
        _image = img;
      });
    });
  }

  void _updatePoints() {
    for (int i = 0; i < _points.length; i++) {
      _points[i] = _points[i] + _velocities[i];

      // Проверяем столкновение со стенками
      if (_points[i].dx < 0 || _points[i].dx > widget.width) {
        _velocities[i] = Offset(-_velocities[i].dx, _velocities[i].dy);
      }
      if (_points[i].dy < 0 || _points[i].dy > widget.height) {
        _velocities[i] = Offset(_velocities[i].dx, -_velocities[i].dy);
      }

      // Проверка на столкновение с другими изображениями
      for (int j = 0; j < _points.length; j++) {
        if (i != j) {
          final distance = (_points[i] - _points[j]).distance;

          // Если изображения пересекаются
          if (distance < _imageSize) {
            // Инвертируем скорости по обеим осям
            final tempVelocity = _velocities[i];
            _velocities[i] = _velocities[j];
            _velocities[j] = tempVelocity;

            // Сдвигаем изображения, чтобы они не пересекались
            final overlap = _imageSize - distance;
            final direction = (_points[i] - _points[j]).direction;
            _points[i] = _points[i].translate(
              cos(direction) * overlap / 2,
              sin(direction) * overlap / 2,
            );
            _points[j] = _points[j].translate(
              -cos(direction) * overlap / 2,
              -sin(direction) * overlap / 2,
            );
          }
        }
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final touchPosition = details.localPosition;
    for (int i = 0; i < _points.length; i++) {
      final distance = (touchPosition - _points[i]).distance;
      if (distance < _imageSize) {
        final direction = _points[i] - touchPosition;
        _velocities[i] = direction * (_maxSpeed / direction.distance);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final containerColor = isDarkTheme ? Colors.white : Colors.black;

    return GestureDetector(
      onPanUpdate: _onPanUpdate, // Обработка нажатий
      child: CustomPaint(
        painter: PointsPainter(
          _points,
          _image,
          _imageSize,
          containerColor.withOpacity(0.1),
          containerColor,
        ),
        child: Container(),
      ),
    );
  }
}
