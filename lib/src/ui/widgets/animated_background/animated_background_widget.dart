import 'package:flutter/material.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';
import 'package:provider/provider.dart';

import '../components/components.dart'; // Для связи с ViewModel

class AnimatedBackgroundWidget extends StatefulWidget {
  final double width;
  final double height;
  final int numPoints;
  final double maxSpeed;
  final String? assetImage;
  final double imageSize;
  final double pointSize;
  final double maxLineDistance;
  final Color paintColor;
  final Color lineColor;
  final bool enableLines;
  final bool stopResizingAnimation;
  final bool enableTouchReaction;
  final double touchSpeedMultiplier;
  final CustomPaint? customPaint;

  const AnimatedBackgroundWidget({
    super.key,
    required this.width,
    required this.height,
    this.numPoints = 20,
    this.maxSpeed = 0.5,
    this.assetImage,
    this.imageSize = 50,
    this.pointSize = 0,
    this.maxLineDistance = 100,
    this.paintColor = Colors.grey,
    this.lineColor = Colors.transparent,
    this.enableLines = false,
    this.stopResizingAnimation = false,
    this.enableTouchReaction = false,
    this.touchSpeedMultiplier = 1,
    this.customPaint,
  });

  @override
  _AnimatedBackgroundWidgetState createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ChangeNotifierProvider(
          create: (_) => AnimatedBackgroundViewModel(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            numPoints: widget.numPoints,
            maxSpeed: widget.maxSpeed,
            assetImage: widget.assetImage,
            imageSize: widget.imageSize,
            pointSize: widget.pointSize,
            maxLineDistance: widget.maxLineDistance,
            paintColor: widget.paintColor,
            lineColor: widget.lineColor,
            maxDistance: widget.maxLineDistance,
            enableLines: widget.enableLines,
            stopResizingAnimation: widget.stopResizingAnimation,
            enableTouchReaction: widget.enableTouchReaction,
            touchSpeedMultiplier: widget.touchSpeedMultiplier,
            customPaint: widget.customPaint,
            vsync:
                this, // Теперь это доступно, так как мы используем StatefulWidget с миксином
          ),
          child: Consumer<AnimatedBackgroundViewModel>(
            builder: (context, viewModel, child) {
              // Обновляем размеры только если они изменились
              // Здесь мы используем addPostFrameCallback, чтобы обновление
              // размеров происходило после текущей фазы build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.updateSize(
                    constraints.maxWidth, constraints.maxHeight);
              });
              return GestureDetector(
                onPanUpdate: (details) {
                  viewModel.onPanUpdate(details.localPosition);
                },
                child: viewModel.customPaint ?? CustomPaint(
                  painter: PointsPainter(
                    points: viewModel.points,
                    image: viewModel.image,
                    imageSize: viewModel.imageSize,
                    pointSize: viewModel.pointSize,
                    paintColor: viewModel.paintColor,
                    lineColor: viewModel.lineColor,
                    maxDistance: viewModel.maxLineDistance,
                    enableLines: viewModel.enableLines,
                  ),
                  child: Container(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
