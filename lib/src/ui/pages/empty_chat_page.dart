import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/empty_chat/empty_chat_view_model.dart';
import '../theme/theme.dart';
import '../widgets/animated_background/animated_background.dart';

class EmptyChatPage extends StatelessWidget {
  const EmptyChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: ChangeNotifierProvider(
        create: (_) => EmptyChatViewModel(),
        child: AnimatedBackgroundWidget(
          width: size.width,
          height: size.height,
          assetImages: const [
            'assets/images/ufo.png',
            // 'assets/images/1.png'
          ],
          numPoints: 20,
          maxLineDistance: 500,
          enableTouchReaction: true,
          lineColor: Colors.black,
          paintColor: Colors.black,
          imageOpacity: 0.1,
          wallCollisionOffset: 25,
          stopResizingAnimation: true,
          child: const Center(
            child: Padding(
              padding: AppConstants.paddingAll16,
              child: CustomScrollView(
                slivers: [
                  _MySliverAppBar(),
                  _MySearchTextField(),
                  _EmptyChatBanner(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MySliverAppBar extends StatelessWidget {
  const _MySliverAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      backgroundColor: AppColors.appBarBackgroundTransparent,
      title: Text(
        "Чаты",
        style: AppTextStyles.appBarTitle,
      ),
      actions: [
        Icon(
          Icons.settings,
          color: AppColors.settingsIcon,
          size: AppConstants.iconSizeMedium,
        )
      ],
    );
  }
}

class _MySearchTextField extends StatelessWidget {
  const _MySearchTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<EmptyChatViewModel>(
        builder: (context, viewModel, child) {
          return TextField(
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              viewModel.toggleSearch();
            },
            decoration: const InputDecoration(
              hintText: "Поиск",
              fillColor:
                  AppColors.searchFieldBackground, // Цвет фона текстового поля
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: AppConstants.borderRadius10,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.searchIcon, // Цвет иконки поиска
                size: AppConstants.iconSizeMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyChatBanner extends StatelessWidget {
  const _EmptyChatBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Если ширина экрана меньше порога, возвращаем пустой виджет
    if (screenSize.height < 700) {
      return SliverToBoxAdapter(
          child: const SizedBox.shrink()); // Пустой виджет
    }

    final double bannerWidth;
    // Рассчитываем ширину баннера как процент от ширины экрана
    (screenSize.width < 400)
        ? bannerWidth =
            screenSize.width * 0.6 // Ширина баннера - 60% от ширины экрана
        : bannerWidth = 400;

    final bannerHeight = bannerWidth; // Высота баннера

    final sizedBoxHeight = screenSize.height - 300;

    // Рассчитываем размеры изображения пропорционально
    final imageSize =
        bannerWidth * 0.8; // Размер изображения - 80% от ширины баннера

    return SliverToBoxAdapter(
      child: SizedBox(
        height: sizedBoxHeight,
        child: Center(
          child: Container(
            width: bannerWidth,
            height: bannerHeight,
            decoration: const BoxDecoration(
              color: AppColors.chatBannerBackground,
              borderRadius: AppConstants.borderRadius24,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/1.png",
                    fit: BoxFit.contain,
                    width: imageSize,
                    height: imageSize,
                  ),
                  const Text("chat list is empty",
                      style: AppTextStyles.bannerText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
