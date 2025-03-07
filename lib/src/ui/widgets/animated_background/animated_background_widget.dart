import 'package:flutter/material.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';
import 'package:provider/provider.dart';

import '../components/components.dart'; // Для связи с ViewModel

class AnimatedBackgroundWidget extends StatefulWidget {
  final double width;
  final double height;
  final Widget? child;
  final int numPoints;
  final double maxSpeed;
  final List<String>? assetImages;
  final double wallCollisionOffset;
  final double imageSize;
  final double pointSize;
  final double maxLineDistance;
  final Color pointColor;
  final Color imageColor;
  final Color lineColor;
  final bool lineColorFading;
  final bool enableLines;
  final bool stopResizingAnimation;
  final bool enableTouchReaction;
  final double maxTouchDistance;
  final double touchSpeedMultiplier;
  final CustomPaint? customPaint;
  final double lineOpacity;
  final double pointOpacity;
  final double imageOpacity;
  final bool enableSmoothOpacityAnimation;
  final int opacityAnimationSeconds;

  const AnimatedBackgroundWidget({
    super.key,
    required this.width,
    required this.height,
    this.child,
    this.numPoints = 20,
    this.maxSpeed = 0.5,
    this.assetImages,
    this.wallCollisionOffset = 0,
    this.imageSize = 50,
    this.pointSize = 0,
    this.maxLineDistance = 100,
    this.pointColor =  Colors.black,
    this.imageColor = Colors.grey,
    this.lineColor = Colors.transparent,
    this.lineColorFading = true,
    this.enableLines = false,
    this.stopResizingAnimation = false,
    this.enableTouchReaction = false,
    this.maxTouchDistance = 100,
    this.touchSpeedMultiplier = 1,
    this.customPaint,
    this.lineOpacity = 1,
    this.pointOpacity = 1,
    this.imageOpacity = 1,
    this.enableSmoothOpacityAnimation = true,
    this.opacityAnimationSeconds = 2,
  });

  @override
  _AnimatedBackgroundWidgetState createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ChangeNotifierProvider(
          create: (_) => AnimatedBackgroundViewModel(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: widget.child,
            numPoints: widget.numPoints,
            maxSpeed: widget.maxSpeed,
            assetImages: widget.assetImages,
            wallCollisionOffset: widget.wallCollisionOffset,
            imageSize: widget.imageSize,
            pointSize: widget.pointSize,
            maxLineDistance: widget.maxLineDistance,
            pointColor: widget.pointColor,
            imageColor: widget.imageColor,
            lineColor: widget.lineColor,
            lineColorFading: widget.lineColorFading,
            maxDistance: widget.maxLineDistance,
            enableLines: widget.enableLines,
            stopResizingAnimation: widget.stopResizingAnimation,
            enableTouchReaction: widget.enableTouchReaction,
            maxTouchDistance: widget.maxTouchDistance,
            touchSpeedMultiplier: widget.touchSpeedMultiplier,
            customPaint: widget.customPaint,
            lineOpacity: widget.lineOpacity,
            pointOpacity: widget.pointOpacity,
            imageOpacity: widget.imageOpacity,
            enableSmoothOpacityAnimation: widget.enableSmoothOpacityAnimation,
            opacityAnimationSeconds: widget.opacityAnimationSeconds,
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
                child: viewModel.customPaint ??
                    CustomPaint(
                      painter: PointsPainter(
                        points: viewModel.points,
                        images: viewModel.images,
                        imageSize: viewModel.imageSize,
                        pointSize: viewModel.pointSize,
                        pointColor: viewModel.pointColor,
                        imageColor: viewModel.imageColor,
                        lineColor: viewModel.lineColor,
                        lineColorFading: viewModel.lineColorFading,
                        maxDistance: viewModel.maxLineDistance,
                        enableLines: viewModel.enableLines,
                        imagesLoaded: viewModel.imagesLoaded,
                        opacityAnimation: viewModel.opacityAnimation,
                        lineOpacity: viewModel.lineOpacity,
                        pointOpacity: viewModel.pointOpacity,
                        imageOpacity: viewModel.imageOpacity,
                      ),
                      child: viewModel.child ?? Container(),
                    ),
              );
            },
          ),
        );
      },
    );
  }
}
