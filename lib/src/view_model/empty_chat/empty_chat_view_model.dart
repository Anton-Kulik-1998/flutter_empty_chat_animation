import 'package:flutter/material.dart';

class EmptyChatViewModel extends ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  void toggleSearch() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  // Можно добавить дополнительную логику, например, для работы с чатом
}
