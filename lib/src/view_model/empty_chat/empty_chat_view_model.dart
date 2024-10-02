import 'package:flutter/material.dart';

class EmptyChatViewModel extends ChangeNotifier {
  EmptyChatViewModel({
    required this.screenWidth,
    required this.screenHeight,
    this.minScreenWidth = 400,
  });

  double screenWidth;
  double screenHeight;
  final double minScreenWidth;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // Проверка, нужно ли отображать баннер
  bool get shouldDisplayBanner => screenHeight < 700;

  // Рассчитываем ширину баннера как процент от ширины экрана
  double get bannerWidth {
    return (screenWidth < minScreenWidth) ? screenWidth * 0.6 : 400;
  }

  double get sizedBoxHeight => screenHeight - 300;

  // Высота баннера с соотношением сторон 1:1
  double get bannerHeight => bannerWidth * 1;

  // Размер изображения - 80% от ширины баннера
  double get imageSize => bannerWidth * 0.8;

  void toggleSearch() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  // Новый метод для обновления размеров
  void updateSize(double newWidth, double newHeight) {
    if (newWidth != screenWidth || newHeight != screenHeight) {
      screenWidth = newWidth;
      screenHeight = newHeight;
      notifyListeners();
    }
  }

  // Можно добавить дополнительную логику, например, для работы с чатом
}


 // Если ширина экрана меньше порога, возвращаем пустой виджет
    // if (screenSize.height < 700) {
    //   return SliverToBoxAdapter(
    //       child: const SizedBox.shrink()); // Пустой виджет
    // }

    // final double bannerWidth;
    // // Рассчитываем ширину баннера как процент от ширины экрана
    // (screenSize.width < 400)
    //     ? bannerWidth =
    //         screenSize.width * 0.6 // Ширина баннера - 60% от ширины экрана
    //     : bannerWidth = 400;

    // final bannerHeight = bannerWidth; // Высота баннера

    // final sizedBoxHeight = screenSize.height - 300;

    // // Рассчитываем размеры изображения пропорционально
    // final imageSize =
    //     bannerWidth * 0.8; // Размер изображения - 80% от ширины баннера