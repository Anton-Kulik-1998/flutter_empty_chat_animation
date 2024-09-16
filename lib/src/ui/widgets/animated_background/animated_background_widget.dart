import 'package:flutter/material.dart';
import 'package:flutter_empty_chat_animation/src/ui/widgets/animated_background/animated_background.dart';
import 'package:provider/provider.dart';

import '../components/components.dart'; // Для связи с ViewModel

class AnimatedBackgroundWidget extends StatefulWidget {
  final double width;
  final double height;
  final Widget? child;

  const AnimatedBackgroundWidget({
    super.key,
    required this.width,
    required this.height,
    this.child,
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
            numPoints: 20,
            vsync:
                this, // Теперь это доступно, так как мы используем StatefulWidget с миксином
          ),
          child: Consumer<AnimatedBackgroundViewModel>(
            builder: (context, viewModel, child) {
              // Передаем новые значения ширины и высоты
              viewModel.updateSize(constraints.maxWidth, constraints.maxHeight);
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












// LayoutBuilder(builder: (context, constraints) {});

// GestureDetector(
//             onPanUpdate: (details) {
//               viewModel.onPanUpdate(details.localPosition);
//             },
//             child: CustomPaint(
//               painter: PointsPainter(
//                 points: viewModel.points,
//                 image: viewModel.image,
//                 imageSize: viewModel.imageSize,
//                 paintColor: Colors.black.withOpacity(0.1),
//                 lineColor: Colors.black,
//               ),
//               child: child,
//             ),
//           );