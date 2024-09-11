import 'package:flutter/material.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';
import 'package:provider/provider.dart';

import '../components/components.dart'; // Для связи с ViewModel

class AnimatedBackgroundWidget extends StatelessWidget {
  final double width;
  final double height;

  const AnimatedBackgroundWidget({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PointsViewModel(
        width: width,
        height: height,
        numPoints: 10,
        vsync: TickerProviderStateMixin.of(context), // Для анимации
      ),
      child: Consumer<PointsViewModel>(
        builder: (context, viewModel, child) {
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
              child: Container(),
            ),
          );
        },
      ),
    );
  }
}
