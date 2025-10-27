import 'package:flutter/material.dart';

class MultiMediaCarouselProvider extends ChangeNotifier {
  final Map<String, int> _currentPageMap = {};

  int getCurrentPage(String key) => _currentPageMap[key] ?? 0;

  void setCurrentPage(String key, int page) {
    if (_currentPageMap[key] != page) {
      _currentPageMap[key] = page;
      notifyListeners();
    }
  }

  void disposeCarousel(String key) {
    _currentPageMap.remove(key);
  }
}

