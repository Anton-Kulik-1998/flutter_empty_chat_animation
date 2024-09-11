import 'dart:math';

import 'package:flutter/material.dart';
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
  final int _numPoints = 150;
  final double _maxSpeed = 0.5;
  final double _maxLineDistance = 100.0;
  final List<Offset> _velocities = [];

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
  }

  void _updatePoints() {
    for (int i = 0; i < _numPoints; i++) {
      final newPos = _points[i] + _velocities[i];
      if (newPos.dx < 0 || newPos.dx > widget.width) {
        _velocities[i] = Offset(-_velocities[i].dx, _velocities[i].dy);
      }
      if (newPos.dy < 0 || newPos.dy > widget.height) {
        _velocities[i] = Offset(_velocities[i].dx, -_velocities[i].dy);
      }
      _points[i] = _points[i] + _velocities[i];
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final touchPosition = details.localPosition;
    for (int i = 0; i < _points.length; i++) {
      final distance = (touchPosition - _points[i]).distance;
      if (distance < _maxLineDistance) {
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
    // Получение текущей темы
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Выбор цвета на основе текущей темы
    final containerColor = isDarkTheme ? Colors.white : Colors.black;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      child: CustomPaint(
        painter: PointsPainter(_points, _maxLineDistance,
            containerColor.withOpacity(0), containerColor),
        child: Container(),
      ),
    );
  }
}
