import 'package:flutter/material.dart';
import 'package:flutter_empty_chat_animation/src/ui/pages/empty_chat_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: const EmptyChatPage(),
    );
  }
}
