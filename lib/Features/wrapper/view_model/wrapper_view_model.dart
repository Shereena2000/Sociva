import 'package:flutter/material.dart';

class WrapperViewModel with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Reset to home screen (index 0)
  void resetToHome() {
    _selectedIndex = 0;
    notifyListeners();
  }
}