import 'package:flutter/widgets.dart';

class UpdateNotifier with ChangeNotifier {
  int updating = 0;
  bool hasChanged = false;

  void beginUpdate() {
    updating++;
  }

  void notify() {
    notifyListeners();
  }

  void endUpdate(bool changed) {
    updating--;
    hasChanged |= changed;

    if (updating <= 0 && hasChanged) {
      notify();
      hasChanged = false;
      updating = 0;
    }
  }
}
