import 'package:flutter/material.dart';

import '../widgets/animated_background/animated_background.dart';

class EmptyChatPage extends StatelessWidget {
  const EmptyChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      body: Stack(
        children: [
          AnimatedBackgroundWidget(
            width: size.width,
            height: size.height,
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CustomScrollView(
                slivers: [
                  _MySliverAppBar(),
                  _MySearchTextField(),
                  _EmptyChatBanner(),
                ],
              ),
            ),
          ),
        ],
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
    return SliverAppBar(
      backgroundColor: Colors.white.withOpacity(0),
      title: Text(
        "Чаты",
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        Icon(
          Icons.settings,
          color: Colors.black.withOpacity(0.7),
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
      child: Expanded(
        child: TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: "Поиск",
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChatBanner extends StatelessWidget {
  const _EmptyChatBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/1.png",
                    fit: BoxFit.contain,
                    width: 350,
                    height: 350,
                  ),
                  const Text("chat list is empty"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
