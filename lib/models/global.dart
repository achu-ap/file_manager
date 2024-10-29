import 'package:flutter/material.dart';

class Global with ChangeNotifier {
  final List<String> selected = [];

  void selectFile(String path) {
    if (selected.contains(path)) {
      selected.remove(path);
    } else {
      selected.add(path);
    }
    notifyListeners();
  }

  void unselectFile() {
    selected.clear();
    notifyListeners();
  }
}
