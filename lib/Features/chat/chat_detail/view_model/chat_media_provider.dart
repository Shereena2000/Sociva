import 'dart:io';
import 'package:flutter/material.dart';

class ChatMediaProvider extends ChangeNotifier {
  List<File> _selectedMedia = [];
  
  List<File> get selectedMedia => _selectedMedia;
  
  bool get hasMedia => _selectedMedia.isNotEmpty;
  
  int get mediaCount => _selectedMedia.length;

  void addMedia(File file) {
    _selectedMedia.add(file);
    notifyListeners();
  }

  void removeMedia(int index) {
    if (index >= 0 && index < _selectedMedia.length) {
      _selectedMedia.removeAt(index);
      notifyListeners();
    }
  }

  void clearMedia() {
    _selectedMedia.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedMedia.clear();
    super.dispose();
  }
}

