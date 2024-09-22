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
  final String? assetImage;
  final double imageSize;
  final double maxLineDistance;

  const AnimatedBackgroundWidget({
    super.key,
    this.child,
    required this.width,
    required this.height,
    this.numPoints = 20,
    this.maxSpeed = 0.5,
    this.assetImage,
    this.imageSize = 50,
    this.maxLineDistance = 100,
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
            maxLineDistance: widget.maxLineDistance,
            vsync:
                this, // Теперь это доступно, так как мы используем StatefulWidget с миксином
          ),
          child: Consumer<AnimatedBackgroundViewModel>(
            builder: (context, viewModel, child) {
              // Обновляем размеры только если они изменились
              // Здесь мы используем addPostFrameCallback, чтобы обновление
              // размеров происходило после фазы build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.updateSize(
                    constraints.maxWidth, constraints.maxHeight);
              });
              return GestureDetector(
                onPanUpdate: (details) {
                  viewModel.onPanUpdate(details.localPosition);
                },
                child: CustomPaint(
                  painter: PointsPainter(
                    points: viewModel.points,
                    image: viewModel.image,
                    imageSize: viewModel.imageSize,
                    paintColor: Colors.black.withOpacity(0.1),
                    lineColor: Colors.black,
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
